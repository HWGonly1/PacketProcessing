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
    //[self.wormhole passMessageObject:@"UDPSocket Connected" identifier:@"VPNStatus"];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    //[self.wormhole passMessageObject:@"UDPSocket Disconnected" identifier:@"VPNStatus"];
    /*
    @synchronized ([SessionManager sharedInstance].udpdict) {
        [self.udpSocket close];
        [[SessionManager sharedInstance].udpdict removeObjectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",self.sourceIP,self.sourcePort,self.destIP,self.destPort]];
    }
     */
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    //[self.wormhole passMessageObject:@"UDPSocket DataSent" identifier:@"VPNStatus"];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    //[self.wormhole passMessageObject:@"UDPSocket DataReceived" identifier:@"VPNStatus"];
    
    NSMutableArray* rawdata=[[NSMutableArray alloc] init];
    Byte* array=(Byte*)[data bytes];
    for(int i=0;i<[data length];i++){
        [rawdata addObject:[NSNumber numberWithShort:array[i]]];
    }
    
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"记录：%@:%d-%@:%d",[PacketUtil intToIPAddress:[self.lastIPheader getsourceIP]],[self.lastUDPheader getsourcePort],[PacketUtil intToIPAddress:[self.lastIPheader getdestinationIP]],[self.lastUDPheader getdestinationPort]] identifier:@"VPNStatus"];

    
    NSMutableArray* packetdata=[UDPPacketFactory createResponsePacket:self.lastIPheader udp:self.lastUDPheader packetdata:rawdata];
    Byte response[[packetdata count]];
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"响应长度：%lu",(unsigned long)[packetdata count]] identifier:@"VPNStatus"];

    for(int i=0;i<[packetdata count];i++){
        response[i]=(Byte)[packetdata[i] shortValue];
    }
    NSMutableData* packet=[[NSMutableData alloc] initWithBytes:response length:[packetdata count]];
    //测试部分
    //Byte *test=(Byte*)[packet bytes];
    
    IPv4Header* iphdr=[[IPv4Header alloc] init:packet];
    
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"%d",11] identifier:@"VPNStatus"];
    
    //int ipheaderLength=[iphdr getIPHeaderLength];
    //bool flag=[PacketUtil isValidIPChecksum:packetdata length:ipheaderLength];

    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"%d",12] identifier:@"VPNStatus"];
    
    //Byte* arraytest = (Byte*)[packet bytes];
    
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"%d",13] identifier:@"VPNStatus"];
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"IP长度：%d",ipheaderLength] identifier:@"VPNStatus"];
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"原IP长度：%d",[self.lastIPheader getIPHeaderLength]] identifier:@"VPNStatus"];

    //UDPHeader* udphdr=[[UDPHeader alloc]init:[NSData dataWithBytes:&arraytest[ipheaderLength] length:([packet length]-ipheaderLength)]];
    
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"%d",14] identifier:@"VPNStatus"];
    
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"生成：%@:%d-%@:%d",[PacketUtil intToIPAddress:[iphdr getsourceIP]],[udphdr getsourcePort],[PacketUtil intToIPAddress:[iphdr getdestinationIP]],[udphdr getdestinationPort]] identifier:@"VPNStatus"];
    //NSMutableArray* array2=[IPPacketFactory createIPv4Header:iphdr];
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"对比1：%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d",[packetdata[0] shortValue],[array2[0] shortValue],[packetdata[1] shortValue],[array2[1] shortValue],[packetdata[2] shortValue],[array2[2] shortValue],[packetdata[3] shortValue],[array2[3] shortValue],[packetdata[4] shortValue],[array2[4] shortValue],[packetdata[5] shortValue],[array2[5] shortValue],[packetdata[6] shortValue],[array2[6] shortValue],[packetdata[7] shortValue],[array2[7] shortValue],[packetdata[8] shortValue],[array2[8] shortValue],[packetdata[9] shortValue],[array2[9] shortValue],[packetdata[10] shortValue],[array2[10] shortValue],[packetdata[11] shortValue],[array2[11] shortValue],[packetdata[12] shortValue],[array2[12] shortValue],[packetdata[13] shortValue],[array2[13] shortValue],[packetdata[14] shortValue],[array2[14] shortValue],[packetdata[15] shortValue],[array2[15] shortValue],[packetdata[16] shortValue],[array2[16] shortValue],[packetdata[17] shortValue],[array2[17] shortValue],[packetdata[18] shortValue],[array2[18] shortValue],[packetdata[19] shortValue],[array2[19] shortValue]] identifier:@"VPNStatus"];
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"对比2：%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d-%d:%d",[packetdata[0] shortValue],response[0],[packetdata[1] shortValue],response[1],[packetdata[2] shortValue],response[2],[packetdata[3] shortValue],response[3],[packetdata[4] shortValue],response[4],[packetdata[5] shortValue],response[5],[packetdata[6] shortValue],response[6],[packetdata[7] shortValue],test[7],[packetdata[8] shortValue],response[8],[packetdata[9] shortValue],response[9],[packetdata[10] shortValue],response[10],[packetdata[11] shortValue],test[11],[packetdata[12] shortValue],response[12],[packetdata[13] shortValue],response[13],[packetdata[14] shortValue],response[14],[packetdata[15] shortValue],response[15],[packetdata[16] shortValue],response[16],[packetdata[17] shortValue],response[17],[packetdata[18] shortValue],response[18],[packetdata[19] shortValue],response[19]] identifier:@"VPNStatus"];

    //bool flag=[PacketUtil isValidIPChecksum:[IPPacketFactory createIPv4Header:iphdr] length:ipheaderLength];
    //[self.wormhole passMessageObject:[NSString stringWithFormat:@"CheckSum：%d",flag] identifier:@"VPNStatus"];

    //测试结束

    @synchronized ([SessionManager sharedInstance].packetFlow) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SessionManager sharedInstance].packetFlow writePackets:@[packet] withProtocols:@[@(AF_INET)]];
        });
    }
}
@end
