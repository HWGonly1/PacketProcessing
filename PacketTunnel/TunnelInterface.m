//
//  TunnelInterface.m
//  PacketProcessing
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import "TunnelInterface.h"
#import "IPv4Header.h"
#import "UDPHeader.h"
#import "TCPHeader.h"
#import "IPPacketFactory.h"
#import "TCPPacketFactory.h"
#import "UDPPacketFactory.h"
#import "PacketUtil.h"
#import "SessionManager.h"
#import "UDPSession.h"
#import "TCPSession.h"
#import <MMWormhole.h>
#include <CocoaAsyncSocket/AsyncSocket.h>
#include <CocoaAsyncSocket/AsyncUdpSocket.h>
#include <CocoaAsyncSocket/GCDAsyncSocket.h>
#include <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#define kTunnelInterfaceErrorDomain @"com.hwg.PacketProcessing.TunnelInterface"


@interface TunnelInterface () <GCDAsyncUdpSocketDelegate>
@property (nonatomic) NEPacketTunnelFlow *tunnelPacketFlow;
@property (nonatomic) NSMutableDictionary *udpSession;
@property (nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic) MMWormhole *wormhole;
@property (nonatomic) int readFd;
@property (nonatomic) int writeFd;
+(void)replySynAck:(IPv4Header*)ip tcp:(TCPHeader*)tcp;
+(void)sendRstPacket:(IPv4Header*)ip tcp:(TCPHeader*)tcp datalength:(int)datalength;
+(void)sendAck:(IPv4Header*)ipheader tcp:(TCPHeader*)tcpheader acceptedDataLength:(int)acceptedDataLength session:(TCPSession*)session;
+(void)acceptAck:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader session:(TCPSession*)session;

@end

@implementation TunnelInterface

+ (TunnelInterface *)sharedInterface {
    static dispatch_once_t onceToken;
    static TunnelInterface *interface;
    dispatch_once(&onceToken, ^{
        interface = [TunnelInterface new];
    });
    return interface;
}

+(void)setPacketFlow:(NEPacketTunnelFlow*)packetFlow{
    [TunnelInterface.sharedInterface setTunnelPacketFlow:packetFlow];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.wormhole=[[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.hwg.PacketProcessing" optionalDirectory:@"VPNStatus"];
        
        
        _udpSession = [NSMutableDictionary dictionaryWithCapacity:5];
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("udp", NULL)];
        
        
    }
    return self;
}

+ (void)writePacket:(NSData *)packet {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TunnelInterface sharedInterface].tunnelPacketFlow writePackets:@[packet] withProtocols:@[@(AF_INET)]];
    });
}


+ (void)processPackets {
    __weak typeof(self) weakSelf = self;
    [[TunnelInterface sharedInterface].wormhole passMessageObject:@"See if Function works"  identifier:@"VPNStatus"];
    [[TunnelInterface sharedInterface].tunnelPacketFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> * _Nonnull packets, NSArray<NSNumber *> * _Nonnull protocols) {
        for (NSData *packet in packets) {
            NSMutableArray* clientpacketdata=[[NSMutableArray alloc] init];
            Byte * data = [packet bytes];
            for(int i=0;i<[packet length];i++){
                [clientpacketdata addObject:[NSNumber numberWithShort:data[i]]];
            }

            IPv4Header * ipheader=[[IPv4Header alloc] init:packet];
            TCPHeader* tcpheader=nil;
            UDPHeader* udpheader=nil;
            Byte proto = [ipheader getProtocol];
            if (proto == 17) {

                udpheader=[UDPPacketFactory createUDPHeader:clientpacketdata start:[ipheader getIPHeaderLength]];
            }else if (proto == 6) {

                tcpheader=[TCPPacketFactory createTCPHeader:clientpacketdata start:[ipheader getIPHeaderLength]];
            }
            if(tcpheader!=nil){
                //handleTCPPacket(clientpacketdata, ipheader, tcpheader);
            }else if(udpheader!=nil){
                [self handleUDPPacket:packet];
            }
        }
        [weakSelf processPackets];
    }];
}

+ (void)handleTCPPPacket: (NSData *)packet {
    int length=[packet length];
    Byte *data = (Byte*)[packet bytes];
    int data_len = (int)[packet length];
    IPv4Header * ipheader=[[IPv4Header alloc] init:packet];
    TCPHeader* tcpheader=[[TCPHeader alloc] init:[NSData dataWithBytes:&data[[ipheader getInternetHeaderLength]] length:[packet length]-[ipheader getInternetHeaderLength]]];
    int datalength=length-[ipheader getIPHeaderLength]-[tcpheader getTCPHeaderLength];
    NSMutableArray* buffer=[[NSMutableArray alloc]init];
    for (int i=0; i< length; i++) {
        [buffer addObject:[NSNumber numberWithShort:data[i]]];
    }
    
    if([tcpheader issyn]){
        [TunnelInterface replySynAck:ipheader tcp:tcpheader];
    }else if ([tcpheader isack]){
        if(![[[SessionManager sharedInstance].tcpdict allKeys]containsObject:[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:[ipheader getsourceIP]],[tcpheader getSourcePort],[PacketUtil intToIPAddress:[ipheader getdestinationIP]],[tcpheader getdestinationPort]]]){
            if(![tcpheader isrst]&&![tcpheader isfin]){
                [TunnelInterface sendRstPacket:ipheader tcp:tcpheader datalength:datalength];
            }
            return;
        }
        TCPSession* session=[[SessionManager sharedInstance].tcpdict objectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:[ipheader getsourceIP]],[tcpheader getSourcePort],[PacketUtil intToIPAddress:[ipheader getdestinationIP]],[tcpheader getdestinationPort]]];
        if(datalength>0){
            int totalAdded=[[SessionManager sharedInstance] addClientData:ipheader tcp:tcpheader buffer:buffer];
            if(totalAdded>0){
                [TunnelInterface sendAck:ipheader tcp:tcpheader acceptedDataLength:totalAdded session:session];
            }
        }else{
            [TunnelInterface acceptAck:ipheader tcpheader:tcpheader session:session];
            if([session closingConnection]){
                [TunnelInterface sendFinAck:ipheader tcp:tcpheader session:session];
            }else if([session ackedToFin]&&![tcpheader isfin]){
                [[SessionManager sharedInstance] closeSession:[ipheader getdestinationIP] port:[tcpheader getdestinationPort] srcIp:[ipheader getsourceIP] srcPort:[tcpheader getSourcePort]];
            }
        }
        if([tcpheader ispsh]){
            [TunnelInterface pushDataToDestination:session ip:ipheader tcp:tcpheader];
        }else if([tcpheader isfin]){
            [TunnelInterface ];
        }else if([tcpheader isrst]){
            
        }else if(session!=nil&&[session ]&&[session ]){
        }
    }else if([tcpheader isfin]){
        
    }else if([tcpheader isrst]){
        
    }
    //[[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d.%d.%d.%d",[iphdr getsourceIP]/256/256/256,[iphdr getsourceIP]/256/256%256,[iphdr getsourceIP]/256%256,[iphdr getsourceIP]%256] identifier:@"VPNStatus"];
    //[[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d.%d.%d.%d",[iphdr getdestinationIP]/256/256/256,[iphdr getdestinationIP]/256/256%256,[iphdr getdestinationIP]/256%256,[iphdr getdestinationIP]%256] identifier:@"VPNStatus"];
    //[[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d",[iphdr getProtocol]] identifier:@"VPNStatus"];
}

+ (void)handleUDPPacket: (NSData *)packet {

    IPv4Header* ipheader=[[IPv4Header alloc] init:packet];
    int ipheaderLength=[ipheader getIPHeaderLength];
    Byte* array = (Byte*)[packet bytes];
    UDPHeader* udpheader=[[UDPHeader alloc]init:[NSData dataWithBytes:&array[ipheaderLength] length:([packet length]-ipheaderLength)]];
    UDPSession* udpsession;
    bool flag=[[SessionManager sharedInstance] existUDPSession:[PacketUtil intToIPAddress:[ipheader getsourceIP]] sourcePort:[udpheader getsourcePort] destIP:[PacketUtil intToIPAddress:[ipheader getdestinationIP]]  destPort:[udpheader getdestinationPort]];
    if(!flag){
        [[SessionManager sharedInstance] addUDPSession:[PacketUtil intToIPAddress:[ipheader getsourceIP]] sourcePort:[udpheader getsourcePort] destIP:[PacketUtil intToIPAddress:[ipheader getdestinationIP]]destPort:[udpheader getdestinationPort]];
        udpsession=[[SessionManager sharedInstance] getUDPSession:[PacketUtil intToIPAddress:[ipheader getsourceIP]] sourcePort:[udpheader getsourcePort] destIP:[PacketUtil intToIPAddress:[ipheader getdestinationIP]]  destPort:[udpheader getdestinationPort]];
    }else{
        udpsession=[[SessionManager sharedInstance] getUDPSession:[PacketUtil intToIPAddress:[ipheader getsourceIP]] sourcePort:[udpheader getsourcePort] destIP:[PacketUtil intToIPAddress:[ipheader getdestinationIP]]  destPort:[udpheader getdestinationPort]];
    }
    
    @synchronized (udpsession) {
        [udpsession setLastIPheader:ipheader];
        [udpsession setLastUDPheader:udpheader];
        [[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%@",@"WriteStart"] identifier:@"VPNStatus"];
        [udpsession write:[NSData dataWithBytes:&array[ipheaderLength+8] length:([packet length]-ipheaderLength-8)]];
        [[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%@",@"WriteStop"] identifier:@"VPNStatus"];
    }
    
    //[[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d.%d.%d.%d",[ipheader getsourceIP]/256/256/256,[ipheader getsourceIP]/256/256%256,[ipheader getsourceIP]/256%256,[ipheader getsourceIP]%256] identifier:@"VPNStatus"];
    //[[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d.%d.%d.%d",[ipheader getdestinationIP]/256/256/256,[ipheader getdestinationIP]/256/256%256,[ipheader getdestinationIP]/256%256,[ipheader getdestinationIP]%256] identifier:@"VPNStatus"];
}

+(void)replySynAck:(IPv4Header*)ip tcp:(TCPHeader*)tcp{
    [ip setIdentification:0];
    Packet* packet=[TCPPacketFactory createSynAckPacketData:ip tcp:tcp];
    TCPHeader* tcpheader=[packet getTcpheader];
    TCPSession* session=[[SessionManager sharedInstance] createNewSession:[ip getdestinationIP] port:[tcp getdestinationPort] srcIp:[ip getsourceIP] srcPort:[tcp getSourcePort]];
    if(session==nil){
        return;
    }
    int windowScaleFactor = (int)pow(2,[tcpheader getWindowScale]);
    [session setSendWindowSize:[tcpheader getWindowSize]];
    [session setSendWindowScale:windowScaleFactor];
    [session setSendWindow:[tcpheader getWindowSize]*windowScaleFactor];
    [session setMaxSegmentSize:[tcpheader getMexSegmentSize]];
    [session setSendUnack:[tcpheader getSequenceNumber]];
    [session setSendNext:[tcpheader getSequenceNumber]+1];
    [session setRecSequence:[tcpheader getAckNumber]];
    
    Byte array[[packet.buffer count]];
    for(int i=0;i<[packet.buffer count];i++){
        array[i]=(Byte)[packet.buffer[i] shortValue];
    }
    
    NSMutableData* data=[[NSMutableData alloc]init];
    [data appendBytes:array length:[packet.buffer count]];
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[SessionManager sharedInstance].packetFlow writePackets:data withProtocols:@[[NSNumber numberWithShort:6]]];
    }
}

+(void)sendRstPacket:(IPv4Header*)ip tcp:(TCPHeader*)tcp datalength:(int)datalength{
    NSMutableArray* packet=[TCPPacketFactory createRstData:ip tcpheader:tcp datalength:datalength];
    Byte array[[packet count]];
    for(int i=0;i<[packet count];i++){
        array[i]=(Byte)[packet[i] shortValue];
    }
    
    NSMutableData* data=[[NSMutableData alloc]init];
    [data appendBytes:array length:[packet count]];
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[SessionManager sharedInstance].packetFlow writePackets:@[data] withProtocols:@[[NSNumber numberWithShort:6]]];
    }
}

+(void)sendAck:(IPv4Header*)ipheader tcp:(TCPHeader*)tcpheader acceptedDataLength:(int)acceptedDataLength session:(TCPSession*)session{
    int acknumber=[session recSequence]+acceptedDataLength;
    [session setRecSequence:acknumber];
    NSArray* array=[TCPPacketFactory createResponseAckData:ipheader tcpheader:tcpheader ackToClient:acknumber];
    Byte arr[[array count]];
    for(int i=0;i<[array count];i++){
        arr[i]=(Byte)[array[i] shortValue];
    }
    NSMutableData* data=[NSMutableData dataWithBytes:arr length:[array count]];
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[SessionManager sharedInstance].packetFlow writePackets:data withProtocols:@[[NSNumber numberWithShort:6]]];
    }
}

+(void)pushDataToDestination:(TCPSession*)session ip:(IPv4Header*)ip tcp:(TCPHeader*)tcp{
    [session setLastIPheader:ip];
    [session setLastTCPheader:tcp];
    [session setTimestampReplyto:[tcp getTimestampSender]];
    int recordTime = [[NSDate date] timeIntervalSince1970];
    [session setTimestampSender:recordTime];
}

+(void)sendFinAck:(IPv4Header*)ip tcp:(TCPHeader*)tcp session:(TCPSession*)session{
    int ack=[tcp getSequenceNumber];
    int seq=[tcp getAckNumber];
    NSMutableArray* array=[TCPPacketFactory createFinAckData:ip tcpheader:tcp ackToClient:ack seqToClient:seq isfin:true isack:false];
    Byte arr[[array count]];
    for(int i=0;i<[array count];i++){
        arr[i]=(Byte)[array[i] shortValue];
    }
    NSMutableData* data=[NSMutableData dataWithBytes:arr length:[array count]];
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[SessionManager sharedInstance].packetFlow writePackets:@[data] withProtocols:@[[NSNumber numberWithShort:6]]];
    }
    [session setSendNext:seq+1];
    [session setClosingConnection:false];
}

+(void)acceptAck:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader session:(TCPSession*)session{
    bool iscorrupted=[PacketUtil isPacketCorrupted:tcpheader];
    [session setPacketCorrupted:iscorrupted];
    if([tcpheader getAckNumber]>[session sendUnack]||[tcpheader getAckNumber]==[session sendNext]){
        [session setIsacked:true];
    }
    if([tcpheader getWindowSize]>0){
        [session setSendWindowSize:[tcpheader getWindowSize]];
        [session setSendWindowScale:[tcpheader getWindowScale]];
        [session setSendWindow:[tcpheader getWindowScale]*[tcpheader getWindowSize]];
    }
    int byteReceived=[tcpheader getAckNumber]-[session sendUnack];
    if(byteReceived>0){
        [session decreaseAmountSentSinceLastAck:byteReceived];
    }
    [session setSendUnack:[tcpheader getAckNumber]];
    [session setRecSequence:[tcpheader getSequenceNumber]];
    [session setTimestampReplyto:[tcpheader getTimestampSender]];
    int recordTime = [[NSDate date] timeIntervalSince1970];
    [session setTimestampSender:recordTime];
}

+(void)ackFinAck:(IPv4Header*)ip tcp:(TCPHeader*)tcp session:(TCPSession*)session{
    int ack=[tcp getSequenceNumber]+1;
    int seq=[tcp getAckNumber];
    NSMutableArray* array=[TCPPacketFactory createFinAckData:ip tcpheader:tcp ackToClient:ack seqToClient:seq isfin:true isack:true];
    Byte arr[[array count]];
    for(int i=0;i<[array count];i++){
        arr[i]=(Byte)[array[i] shortValue];
    }
    NSMutableData* data=[NSMutableData dataWithBytes:arr length:[array count]];
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[SessionManager sharedInstance].packetFlow writePackets:@[data] withProtocols:@[[NSNumber numberWithShort:6]]];
    }
    [[SessionManager sharedInstance] closeSession:session];
}
@end


































