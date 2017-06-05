//
//  TCPSession.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/20.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPSession.h"
#import "GCDAsyncSocket.h"
#import "IPv4Header.h"
#import "TCPHeader.h"
#import "SessionManager.h"
#import "TCPPacketFactory.h"
@interface TCPSession () <GCDAsyncSocketDelegate>
@property (nonatomic) GCDAsyncSocket* tcpSocket;
@end

@implementation TCPSession
-(instancetype)init:(NSString*)ip port:(uint16_t)port srcIp:(NSString*)srcIp srcPort:(uint16_t)srcPort{
    //NSString* key=[NSString stringWithFormat:@"%@:%d-%@:%d",srcIp,srcPort,ip,port];
    self.destIP=ip;
    self.destPort=port;
    self.sourceIP=srcIp;
    self.sourcePort=srcPort;
    NSError* error=nil;
    //self.tcpSocket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:[SessionManager sharedInstance].globalQueue];
    self.tcpSocket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    //[[SessionManager sharedInstance].wormhole passMessageObject:@"Before Connect" identifier:@"VPNStatus"];
    [self.tcpSocket connectToHost:ip onPort:port error:&error];
    if(error!=nil){
        [[SessionManager sharedInstance].wormhole passMessageObject:error identifier:@"VPNStatus"];
    }
    //[[SessionManager sharedInstance].wormhole passMessageObject:@"After Connect" identifier:@"VPNStatus"];
    self.connected=[self.tcpSocket isConnected];
    self.syncSendAmount=[[NSObject alloc]init];
    self.recSequence=0;
    self.sendUnack=0;
    self.isacked=false;
    self.sendNext=0;
    self.sendWindow=0;
    self.sendWindowSize=0;
    self.sendWindowScale=0;
    self.sendAmountSinceLastAck=0;
    self.maxSegmentSize=0;
    self.connected=false;
    self.closingConnection=false;
    self.packetCorrupted=false;
    self.ackedToFin=false;
    self.abortingConnection=false;
    self.hasReceivedLastSegment=false;
    self.isDataForSendingReady=false;
    self.lastIPheader=nil;
    self.lastTCPheader=nil;
    self.timestampSender=0;
    self.timestampReplyto=0;
    self.unackData=[[NSMutableData alloc]init];
    self.resendPacketCounter=0;
    return self;
}

-(void)write:(NSData*)data{
    [self.tcpSocket writeData:data withTimeout:-1 tag:0];
}

-(void)close{
    [self.tcpSocket disconnect];
}

-(void)decreaseAmountSentSinceLastAck:(int)amount{
    @synchronized (self.syncSendAmount) {
        self.sendAmountSinceLastAck-=amount;
        if(self.sendAmountSinceLastAck<0){
            self.sendAmountSinceLastAck=0;
        }
    }
}

-(bool)isClientWindowFull{
    bool yes=false;
    //[[SessionManager sharedInstance].dict setObject:@"" forKey:[NSString stringWithFormat:@"%@:%d",@"sendwindow",self.sendWindow]];
    //[[SessionManager sharedInstance].dict setObject:@"" forKey:[NSString stringWithFormat:@"%@:%d",@"sendAmount",self.sendAmountSinceLastAck]];
    if(self.sendWindow>0&&self.sendAmountSinceLastAck>=0){
        yes=true;
    }else if(self.sendWindow==0&&self.sendAmountSinceLastAck>65535){
        yes=true;
    }
    return yes;
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{

    [[SessionManager sharedInstance].wormhole passMessageObject:@"TCPSession Connected" identifier:@"VPNStatus"];

    self.connected=true;
    
    //NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
    //允许自签名证书手动验证
    //[settings setObject:@YES forKey:GCDAsyncSocketManuallyEvaluateTrust];
    //GCDAsyncSocketSSLPeerName
    //[settings setObject:@"tv.diveinedu.com" forKey:GCDAsyncSocketSSLPeerName];
    
    // 如果不是自签名证书，而是那种权威证书颁发机构注册申请的证书
    // 那么这个settings字典可不传。
    [sock startTLS:nil]; // 开始SSL握手
}
-(void)socketDidSecure:(GCDAsyncSocket *)sock{
    //[[SessionManager sharedInstance].dict setObject:@"GOT" forKey:[NSString stringWithFormat:@"%@:%@",self.destIP,@"Secure"]];

    [sock readDataWithTimeout:-1 tag:0];
    
    //[[SessionManager sharedInstance].dict setObject:@"GG" forKey:[NSString stringWithFormat:@"%@:%@",self.destIP,@"StartRead"]];

}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [[SessionManager sharedInstance].wormhole passMessageObject:@"TCPSocket DataSent" identifier:@"VPNStatus"];

}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if(!self.isClientWindowFull){
        [[SessionManager sharedInstance].wormhole passMessageObject:@"TCPSocket DataReceived" identifier:@"VPNStatus"];
        [[SessionManager sharedInstance].dict setObject:@"GOT" forKey:self.destIP];

        NSMutableData* buffer=[[NSMutableData alloc]init];
        /*
        Byte* array=(Byte*)[data bytes];
        for(int i=0;i<[data length];i++){
            [buffer addObject:[NSNumber numberWithShort:array[i]]];
        }
         */
        [buffer appendData:data];
        IPv4Header* ipheader=self.lastIPheader;
        TCPHeader* tcpheader=self.lastTCPheader;
        int unack=[self sendNext];
        int nextunack=unack+[data length];
        [self setSendNext:nextunack];
        [self setUnackData:[NSMutableData dataWithData:data]];
        [self setResendPacketCounter:0];
        NSMutableData* packetbody=[TCPPacketFactory createResponsePacketData:ipheader tcp:tcpheader packetdata:[NSMutableData dataWithData:data] ispsh:[self hasReceivedLastSegment] ackNumber:[self recSequence] seqNumber:unack timeSender:[self timestampSender] timeReplyto:[self timestampReplyto]];
        @synchronized ([SessionManager sharedInstance].packetFlow) {
            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SessionManager sharedInstance].packetFlow writePackets:@[packetbody] withProtocols:@[@(AF_INET)]];
            //});
        }
    }
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [[SessionManager sharedInstance].wormhole passMessageObject:@"TCPSession Disconnected" identifier:@"VPNStatus"];
    [self setConnected:false];
    NSMutableData* rstarray=[TCPPacketFactory createRstData:self.lastIPheader tcpheader:self.lastTCPheader datalength:0];
    /*
    Byte array[[rstarray count]];
    for(int i=0;i<[rstarray count];i++){
        array[i]=(Byte)[rstarray[i] shortValue];
    }
    NSData* data=[NSData dataWithBytes:array length:[rstarray count]];
     */
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SessionManager sharedInstance].packetFlow writePackets:@[rstarray] withProtocols:@[@(AF_INET)]];
        //});
    }
    [self setAbortingConnection:true];
    [[SessionManager sharedInstance]closeSession:self];
}

-(void)sendToRequester:(NSMutableData*)buffer socket:(GCDAsyncSocket*)socket datasize:(int)datasize sess:(TCPSession*)sess{
    if(sess==nil){
        return;
    }
    if(datasize<65535){
        [sess setHasReceivedLastSegment:true];
    }else{
        [sess setHasReceivedLastSegment:false];
    }
}

-(void)pushDataToClient:(NSMutableData*)buffer session:(TCPSession*)session{
    IPv4Header* ipheader=self.lastIPheader;
    TCPHeader* tcpheader=self.lastTCPheader;
    int max=session.maxSegmentSize-60;
    if(max<1){
        max=1024;
    }
    int unack=session.sendNext;
    int nextUnack=self.sendNext+[buffer length];
    [session setSendNext:nextUnack];
    [session setUnackData:buffer];
    [session setResendPacketCounter:0];
    NSMutableData* data=[TCPPacketFactory createResponsePacketData:ipheader tcp:tcpheader packetdata:buffer ispsh:[session hasReceivedLastSegment] ackNumber:[session recSequence] seqNumber:unack timeSender:[session timestampSender] timeReplyto:[session timestampReplyto]];
    /*
    Byte array[[data count]];
    for(int i=0;i<[data count];i++){
        array[i]=(Byte)[data[i] shortValue];
    }
     */
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[SessionManager sharedInstance].packetFlow writePackets:@[data] withProtocols:@[@AF_INET]];
    }
}

-(void)setSendingData:(NSData*)data{
    
}
@end


























