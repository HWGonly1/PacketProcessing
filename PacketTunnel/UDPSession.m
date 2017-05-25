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
#import "MMWormhole.h"
#import "UDPPacketFactory.h"
#import "IPPacketFactory.h"
@import NetworkExtension;

@interface UDPSession () <GCDAsyncUdpSocketDelegate>
@property (nonatomic) GCDAsyncUdpSocket* udpSocket;
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
    
    int port=12345;
    
    NSError* error=nil;
    do{
        error=nil;
        [self.udpSocket bindToPort:port error:&error];
        port++;
    }while(error!=nil);
    
    [self.udpSocket beginReceiving:nil];
    
    //[self.wormhole passMessageObject:(error==nil)?@"Error NIL":@"Error NOT NIL" identifier:@"VPNStatus"];

    //[self.wormhole passMessageObject:error identifier:@"VPNStatus"];

    //[self.udpSocket connectToHost:self.destIP onPort:self.destPort error:nil];
    return self;
}

-(void)write:(NSData*)data{
    [self.udpSocket sendData:data toHost:self.destIP port:self.destPort withTimeout:30 tag:0];
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
    
    NSMutableArray* rawdata=[[NSMutableArray alloc] init];
    Byte* array=(Byte*)[data bytes];
    for(int i=0;i<[data length];i++){
        [rawdata addObject:[NSNumber numberWithShort:array[i]]];
    }
    
    [self.wormhole passMessageObject:[NSString stringWithFormat:@"记录：%@:%d-%@:%d",[PacketUtil intToIPAddress:[self.lastIPheader getsourceIP]],[self.lastUDPheader getsourcePort],[PacketUtil intToIPAddress:[self.lastIPheader getdestinationIP]],[self.lastUDPheader getdestinationPort]] identifier:@"VPNStatus"];

    
    NSMutableArray* packetdata=[UDPPacketFactory createResponsePacket:self.lastIPheader udp:self.lastUDPheader packetdata:rawdata];
    Byte response[[packetdata count]];
    [self.wormhole passMessageObject:[NSString stringWithFormat:@"响应长度：%lu",(unsigned long)[packetdata count]] identifier:@"VPNStatus"];

    for(int i=0;i<[packetdata count];i++){
        response[i]=(Byte)[packetdata[i] shortValue];
    }
    NSMutableData* packet=[[NSMutableData alloc] initWithBytes:response length:[packetdata count]];
    //测试部分
    
    IPv4Header* iphdr=[[IPv4Header alloc] init:packet];
    
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"%d",11] identifier:@"VPNStatus"];
    
    int ipheaderLength=[iphdr getIPHeaderLength];
    
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"%d",12] identifier:@"VPNStatus"];
    
    Byte* arraytest = (Byte*)[packet bytes];
    
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"%d",13] identifier:@"VPNStatus"];
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"IP长度：%d",ipheaderLength] identifier:@"VPNStatus"];
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"总长度：%d",[packet length]] identifier:@"VPNStatus"];

    UDPHeader* udphdr=[[UDPHeader alloc]init:[NSData dataWithBytes:&arraytest[ipheaderLength] length:([packet length]-ipheaderLength)]];
    
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"%d",14] identifier:@"VPNStatus"];
    
    [self.wormhole passMessageObject:[NSString stringWithFormat:@"生成：%@:%d-%@:%d",[PacketUtil intToIPAddress:[iphdr getsourceIP]],[udphdr getsourcePort],[PacketUtil intToIPAddress:[iphdr getdestinationIP]],[udphdr getdestinationPort]] identifier:@"VPNStatus"];
    bool flag=[PacketUtil isValidIPChecksum:[IPPacketFactory createIPv4Header:iphdr] length:[iphdr getIPHeaderLength]];
    [self.wormhole passMessageObject:[NSString stringWithFormat:@"CheckSum：%d",flag] identifier:@"VPNStatus"];

    //测试结束

    @synchronized ([SessionManager sharedInstance].packetFlow) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SessionManager sharedInstance].packetFlow writePackets:@[packet] withProtocols:@[@(AF_INET)]];
        });
    }
}
@end
