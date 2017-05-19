//
//  UDPSession.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/19.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDPSession.h"
#import "SessionManager.h"
#import "MMWormhole.h"
@import NetworkExtension;

@interface UDPSession () <GCDAsyncUdpSocketDelegate>
@property (nonatomic) GCDAsyncUdpSocket* udpSocket;
@property (nonatomic) NEPacketTunnelFlow *tunnelPacketFlow;
@property (nonatomic) MMWormhole* wormhole;
@end

@implementation UDPSession

-(instancetype)init:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort timeout:(NSTimeInterval*)timeout{
    self.wormhole=[[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.hwg.PacketProcessing" optionalDirectory:@"VPNStatus"];
    self.sourceIP=sourceIP;
    self.sourcePort=sourcePort;
    self.destIP=destIP;
    self.destPort=destPort;
    self.timeout=timeout;
    self.udpSocket=[[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:[SessionManager sharedInstance].globalQueue];
    [self.udpSocket connectToHost:self.destIP onPort:self.destPort error:nil];
    return self;
}

-(void)write:(NSData*)data{
    [self.udpSocket sendData:data withTimeout:30 tag:0];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    [self.wormhole passMessageObject:@"UDPSocket Connected" identifier:@"VPNStatus"];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    [self.wormhole passMessageObject:@"UDPSocket Disconnected" identifier:@"VPNStatus"];
    @synchronized ([SessionManager sharedInstance].udpdict) {
        [self.udpSocket close];
        [[SessionManager sharedInstance].udpdict removeObjectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",self.sourceIP,self.sourcePort,self.destIP,self.destPort]];
    }
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    [self.wormhole passMessageObject:@"UDPSocket DataSent" identifier:@"VPNStatus"];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    [self.wormhole passMessageObject:@"UDPSocket DataReceived" identifier:@"VPNStatus"];
    /*
    NSMutableData completeData=[[NSMutableData alloc] init];
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[SessionManager sharedInstance].packetFlow writePackets:@[data] withProtocols:@[[NSNumber numberWithInt:17]]];
    }
     */
}
@end
