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
    self.tcpSocket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [self.tcpSocket connectToHost:ip onPort:port error:&error];
    if(error!=nil){
    }
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
    self.sendcount=0;
    self.receivecount=0;
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
    if(self.sendWindow>0&&self.sendAmountSinceLastAck>=0){
        yes=true;
    }else if(self.sendWindow==0&&self.sendAmountSinceLastAck>65535){
        yes=true;
    }
    return yes;
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    self.connected=true;
    [sock readDataWithTimeout:-1 tag:0];
}
-(void)socketDidSecure:(GCDAsyncSocket *)sock{
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    self.sendcount++;
    NSLog(@"SendCount:%d",self.sendcount);
}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //if(!self.isClientWindowFull){
    
    Byte* array=(Byte*)[data bytes];
    int flag=0;
    while(([data length]-flag)>1400){
        self.receivecount++;
        NSLog(@"ReceiveCount:%d",self.receivecount);

        @autoreleasepool {
            NSMutableData* segment=[NSMutableData dataWithBytes:array+flag length:1400];
            flag+=1400;
            IPv4Header* ipheader=self.lastIPheader;
            TCPHeader* tcpheader=self.lastTCPheader;
            int unack=[self sendNext];
            int nextunack=unack+1400;
            [self setSendNext:nextunack];
            [self setUnackData:[NSMutableData dataWithData:segment]];
            [self setResendPacketCounter:0];
            NSMutableData* packetbody=[TCPPacketFactory createResponsePacketData:ipheader tcp:tcpheader packetdata:[NSMutableData dataWithData:segment] ispsh:true ackNumber:[self recSequence] seqNumber:unack timeSender:[self timestampSender] timeReplyto:[self timestampReplyto]];
            @synchronized ([SessionManager sharedInstance].packetFlow) {
                [[SessionManager sharedInstance].packetFlow writePackets:@[packetbody] withProtocols:@[@(AF_INET)]];
            }
        }
    }
    
    if(([data length]-flag)>0){
        self.receivecount++;
        NSLog(@"ReceiveCount:%d",self.receivecount);
        @autoreleasepool {
            NSMutableData* segment=[NSMutableData dataWithBytes:array+flag length:([data length]-flag)];
            IPv4Header* ipheader=self.lastIPheader;
            TCPHeader* tcpheader=self.lastTCPheader;
            int unack=[self sendNext];
            int nextunack=unack+([data length]-flag);
            [self setSendNext:nextunack];
            [self setUnackData:segment];
            [self setResendPacketCounter:0];
            NSMutableData* packetbody=[TCPPacketFactory createResponsePacketData:ipheader tcp:tcpheader packetdata:[NSMutableData dataWithData:segment] ispsh:true ackNumber:[self recSequence] seqNumber:unack timeSender:[self timestampSender] timeReplyto:[self timestampReplyto]];
            @synchronized ([SessionManager sharedInstance].packetFlow) {
                [[SessionManager sharedInstance].packetFlow writePackets:@[packetbody] withProtocols:@[@(AF_INET)]];
            }
        }
    }
    data=nil;
    /*
     NSMutableData* buffer=[[NSMutableData alloc]init];
     [buffer appendData:data];
     IPv4Header* ipheader=self.lastIPheader;
     TCPHeader* tcpheader=self.lastTCPheader;
     int unack=[self sendNext];
     int nextunack=unack+[data length];
     [self setSendNext:nextunack];
     [self setUnackData:[NSMutableData dataWithData:data]];
     [self setResendPacketCounter:0];
     NSMutableData* packetbody=[TCPPacketFactory createResponsePacketData:ipheader tcp:tcpheader packetdata:[NSMutableData dataWithData:data] ispsh:true ackNumber:[self recSequence] seqNumber:unack timeSender:[self timestampSender] timeReplyto:[self timestampReplyto]];
     [[SessionManager sharedInstance].dict setObject:data forKey:[NSString stringWithFormat:@"%@-%d",self.destIP,[data length]]];
     [[SessionManager sharedInstance].dict setObject:packetbody forKey:[NSString stringWithFormat:@"%@-%d",self.destIP,[packetbody length]]];
     @synchronized ([SessionManager sharedInstance].packetFlow) {
     [[SessionManager sharedInstance].packetFlow writePackets:@[packetbody] withProtocols:@[@(AF_INET)]];
     }
     */
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [self setConnected:false];
    NSMutableData* rstarray=[TCPPacketFactory createRstData:self.lastIPheader tcpheader:self.lastTCPheader datalength:0];
    
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[SessionManager sharedInstance].packetFlow writePackets:@[rstarray] withProtocols:@[@(AF_INET)]];
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
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[SessionManager sharedInstance].packetFlow writePackets:@[data] withProtocols:@[@AF_INET]];
    }
}

-(void)setSendingData:(NSData*)data{
    
}
@end


























