//
//  UDPSession.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/19.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PacketUtil.h"
#import "UDPSession.h"
#import "SessionManager.h"
#import "UDPPacketFactory.h"
#import "IPPacketFactory.h"
@import NetworkExtension;

@interface UDPSession () <GCDAsyncUdpSocketDelegate>
@property (nonatomic) GCDAsyncUdpSocket* udpSocket;
@end

@implementation UDPSession

-(instancetype)init:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort{
    self.sourceIP=sourceIP;
    self.sourcePort=sourcePort;
    self.destIP=destIP;
    self.destPort=destPort;
    //self.timeout=timeout;
    //self.udpSocket=[[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:[SessionManager sharedInstance].globalQueue];
    self.udpSocket=[[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    int port=12345;
    
    NSError* error=nil;
    do{
        error=nil;
        [self.udpSocket bindToPort:port error:&error];
        port++;
    }while(error!=nil);
    
    [self.udpSocket beginReceiving:nil];

    //[self.udpSocket connectToHost:self.destIP onPort:self.destPort error:nil];
    return self;
}

-(void)write:(NSData*)data{
    [self.udpSocket sendData:data toHost:self.destIP port:self.destPort withTimeout:-1 tag:0];
    NSLog(@"NSData Wrote Out on UDPSocket!!!");
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    /*
     @synchronized ([SessionManager sharedInstance].udpdict) {
     [self.udpSocket close];
     [[SessionManager sharedInstance].udpdict removeObjectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",self.sourceIP,self.sourcePort,self.destIP,self.destPort]];
     }
     */
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    @autoreleasepool {
        
        NSMutableData* rawdata=[[NSMutableData alloc] init];
        /*
         Byte* array=(Byte*)[data bytes];
         for(int i=0;i<[data length];i++){
         [rawdata addObject:[NSNumber numberWithShort:array[i]]];
         }
         */
        [rawdata appendData:data];
        
        NSMutableData* packetdata=[UDPPacketFactory createResponsePacket:self.lastIPheader udp:self.lastUDPheader packetdata:rawdata];
        /*
         Byte response[[packetdata count]];
         
         for(int i=0;i<[packetdata count];i++){
         response[i]=(Byte)[packetdata[i] shortValue];
         }
         */
        
        @synchronized ([SessionManager sharedInstance].packetFlow) {
            [[SessionManager sharedInstance].packetFlow writePackets:@[packetdata] withProtocols:@[@(AF_INET)]];
        }
        data=nil;
    }
    [[SessionManager sharedInstance] closeUDPSession:self];
    /*
    [self.udpSocket close];
    [[SessionManager sharedInstance].udpdict removeObjectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",self.sourceIP,self.sourcePort,self.destIP,self.destPort]];
     */
}

-(void)close{
    [self.udpSocket close];
}
@end
