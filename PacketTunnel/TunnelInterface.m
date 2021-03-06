//
//  TunnelInterface.m
//  PacketProcessing
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import "TunnelInterface.h"
#include <CocoaAsyncSocket/AsyncSocket.h>
#include <CocoaAsyncSocket/AsyncUdpSocket.h>
#include <CocoaAsyncSocket/GCDAsyncSocket.h>
#include <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface TunnelInterface () <GCDAsyncUdpSocketDelegate>
@property (nonatomic) NEPacketTunnelFlow *tunnelPacketFlow;
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
    [[TunnelInterface sharedInterface] setTunnelPacketFlow:packetFlow];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.processing=true;
    }
    return self;
}

+ (void)writePacket:(NSData *)packet {
    @synchronized ([SessionManager sharedInstance].packetFlow) {
        [[TunnelInterface sharedInterface].tunnelPacketFlow writePackets:@[packet] withProtocols:@[@(AF_INET)]];
    }
}


+ (void)processPackets {
    __weak typeof(self) weakSelf = self;
    if([TunnelInterface sharedInterface].processing){
        [[TunnelInterface sharedInterface].tunnelPacketFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> * _Nonnull packets, NSArray<NSNumber *> * _Nonnull protocols) {
            for (NSData *packet in packets) {
                @autoreleasepool {
                    NSMutableData* data=[[NSMutableData alloc] initWithData:packet];
                    IPv4Header * ipheader=[[IPv4Header alloc] init:packet];
                    TCPHeader* tcpheader=nil;
                    UDPHeader* udpheader=nil;
                    Byte proto = [ipheader getProtocol];
                    if (proto == 17) {
                        udpheader=[UDPPacketFactory createUDPHeader:data start:[ipheader getIPHeaderLength]];
                    }else if (proto == 6) {
                        tcpheader=[TCPPacketFactory createTCPHeader:data start:[ipheader getIPHeaderLength]];
                    }
                    if(tcpheader!=nil){
                        [self handleTCPPacket:packet];
                    }else if(udpheader!=nil){
                        [self handleUDPPacket:packet];
                    }
                }
            }
            [weakSelf processPackets];
        }];
    }
}

+ (void)handleTCPPacket: (NSData *)packet {
    
    int length=[packet length];
    Byte *data = (Byte*)[packet bytes];
    @autoreleasepool {
        
        IPv4Header * ipheader=[[IPv4Header alloc] init:packet];
        TCPHeader* tcpheader=[[TCPHeader alloc] init:[NSData dataWithBytes:(data+[ipheader getIPHeaderLength]) length:[packet length]-[ipheader getIPHeaderLength]]];
        int datalength=length-[ipheader getIPHeaderLength]-[tcpheader getTCPHeaderLength];
        NSMutableData* buffer=[[NSMutableData alloc]init];
        [buffer appendData:packet];
        
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
                
                [TunnelInterface ackFinAck:ipheader tcp:tcpheader session:session];
            }else if([tcpheader isrst]){
                
                [TunnelInterface resetConnection:ipheader tcp:tcpheader];
            }else if(session!=nil&&[session isClientWindowFull]&&![session abortingConnection]){
                
                [[SessionManager sharedInstance] keepSessionAlive:session];
            }
        }else if([tcpheader isfin]){
            
            TCPSession* session=[[SessionManager sharedInstance].tcpdict objectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:[ipheader getsourceIP]],[tcpheader getSourcePort],[PacketUtil intToIPAddress:[ipheader getdestinationIP]],[tcpheader getdestinationPort]]];
            if(session==nil){
                [TunnelInterface ackFinAck:ipheader tcp:tcpheader session:session];
            }else{
                [[SessionManager sharedInstance] keepSessionAlive:session];
            }
        }else if([tcpheader isrst]){
            [TunnelInterface resetConnection:ipheader tcp:tcpheader];
        }
    }
}

+ (void)handleUDPPacket: (NSData *)packet {
    @autoreleasepool {
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
            [udpsession write:[NSData dataWithBytes:&array[ipheaderLength+8] length:([packet length]-ipheaderLength-8)]];
        }
    }
}

+(void)replySynAck:(IPv4Header*)ip tcp:(TCPHeader*)tcp{
    @autoreleasepool {
        
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
        [session setMaxSegmentSize:[tcpheader getMaxSegmentSize]];
        [session setSendUnack:[tcpheader getSequenceNumber]];
        [session setSendNext:[tcpheader getSequenceNumber]+1];
        [session setRecSequence:[tcpheader getAckNumber]];
        
        @synchronized ([SessionManager sharedInstance].packetFlow) {
            [[SessionManager sharedInstance].packetFlow writePackets:@[packet.buffer] withProtocols:@[@(AF_INET)]];
        }
    }
}

+(void)sendRstPacket:(IPv4Header*)ip tcp:(TCPHeader*)tcp datalength:(int)datalength{
    @autoreleasepool {
        
        NSMutableData* packet=[TCPPacketFactory createRstData:ip tcpheader:tcp datalength:datalength];        
        @synchronized ([SessionManager sharedInstance].packetFlow) {
            [[SessionManager sharedInstance].packetFlow writePackets:@[packet] withProtocols:@[@(AF_INET)]];
        }
    }
}

+(void)sendAck:(IPv4Header*)ipheader tcp:(TCPHeader*)tcpheader acceptedDataLength:(int)acceptedDataLength session:(TCPSession*)session{
    @autoreleasepool {
        
        int acknumber=[session recSequence]+acceptedDataLength;
        [session setRecSequence:acknumber];
        NSMutableData* array=[TCPPacketFactory createResponseAckData:ipheader tcpheader:tcpheader ackToClient:acknumber];
        @synchronized ([SessionManager sharedInstance].packetFlow) {
            [[SessionManager sharedInstance].packetFlow writePackets:@[array] withProtocols:@[@(AF_INET)]];
        }
    }
}

+(void)pushDataToDestination:(TCPSession*)session ip:(IPv4Header*)ip tcp:(TCPHeader*)tcp{
    @synchronized (session) {
        [session setIsDataForSendingReady:true];
        [session setLastIPheader:ip];
        [session setLastTCPheader:tcp];
        [session setTimestampReplyto:[tcp getTimestampSender]];
        int recordTime = [[NSDate date] timeIntervalSince1970];
        [session setTimestampSender:recordTime];
    }
}

+(void)sendFinAck:(IPv4Header*)ip tcp:(TCPHeader*)tcp session:(TCPSession*)session{
    @autoreleasepool {
        int ack=[tcp getSequenceNumber];
        int seq=[tcp getAckNumber];
        NSMutableData* array=[TCPPacketFactory createFinAckData:ip tcpheader:tcp ackToClient:ack seqToClient:seq isfin:true isack:false];
        @synchronized ([SessionManager sharedInstance].packetFlow) {
            [[SessionManager sharedInstance].packetFlow writePackets:@[array] withProtocols:@[@(AF_INET)]];
        }
        [session setSendNext:seq+1];
        [session setClosingConnection:false];
    }
}

+(void)acceptAck:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader session:(TCPSession*)session{
    bool iscorrupted=[PacketUtil isPacketCorrupted:tcpheader];
    [session setPacketCorrupted:iscorrupted];
    if([tcpheader getAckNumber]>[session sendUnack]||[tcpheader getAckNumber]==[session sendNext]){
        [session setIsacked:true];
        if([tcpheader getWindowSize]>0){
            [session setSendWindowSize:[tcpheader getWindowSize]];
            [session setSendWindowScale:[session sendWindowScale]];
            [session setSendWindow:[tcpheader getWindowSize]*[session sendWindowScale]];
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
    else{
        [session setIsacked:false];
    }
}

+(void)ackFinAck:(IPv4Header*)ip tcp:(TCPHeader*)tcp session:(TCPSession*)session{
    @autoreleasepool {
        int ack=[tcp getSequenceNumber]+1;
        int seq=[tcp getAckNumber];
        NSMutableData* array=[TCPPacketFactory createFinAckData:ip tcpheader:tcp ackToClient:ack seqToClient:seq isfin:true isack:true];
        @synchronized ([SessionManager sharedInstance].packetFlow) {
            [[SessionManager sharedInstance].packetFlow writePackets:@[array] withProtocols:@[@(AF_INET)]];
        }
        [[SessionManager sharedInstance] closeSession:session];
    }
}

+(void)resetConnection:(IPv4Header*)ip tcp:(TCPHeader*)tcp{
    TCPSession* session=[[SessionManager sharedInstance].tcpdict objectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:[ip getsourceIP]],[tcp getSourcePort],[PacketUtil intToIPAddress:[ip getdestinationIP]],[tcp getdestinationPort]]];
    if(session!=nil){
        [session setAbortingConnection:true];
    }
}
@end


































