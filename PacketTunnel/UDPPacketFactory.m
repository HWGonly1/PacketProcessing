//
//  UDPPacketFactory.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/18.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PacketUtil.h"
#import "UDPPacketFactory.h"
#import "UDPHeader.h"
#import "IPPacketFactory.h"
#import "SessionManager.h"
@implementation UDPPacketFactory

-(instancetype)init{
    return self;
}

+(UDPHeader*)createUDPHeader:(NSMutableArray*)buffer start:(int)start{
    UDPHeader* header=nil;
    if(([buffer count]-start)<8){
        return header;
    }
    int srcPort=[PacketUtil getNetworkInt:buffer start:start length:2];
    int destPort=[PacketUtil getNetworkInt:buffer start:start+2 length:2];
    int length=[PacketUtil getNetworkInt:buffer start:start+4 length:2];
    int checksum=[PacketUtil getNetworkInt:buffer start:start+6 length:2];

    NSMutableString* str=[[NSMutableString alloc] init];
    [str appendFormat:@"\r\n..... new UDP header .....\r\nstarting position in buffer: %d\r\nSrc port: %d\r\nDest port: %d\r\nLength: %d\r\nChecksum: %d\r\n...... end UDP header .....",start,srcPort,destPort,length,checksum];
    header=[[UDPHeader alloc]init:srcPort destPort:destPort length:length checksum:checksum];
    return header;
}

+(UDPHeader*)copyHeader:(UDPHeader*)header{
    UDPHeader* newh=[[UDPHeader alloc] init:header.getsourcePort destPort:header.getdestinationPort length:header.getlength checksum:header.getchecksum];
    return newh;
}

+(NSMutableArray*)createResponsePacket:(IPv4Header*)ip udp:(UDPHeader*)udp packetdata:(NSMutableArray*)packetdata{
    NSMutableArray* buffer=[[NSMutableArray alloc]init];
    int udplen=8;
    if([packetdata count]!=0){
        udplen+=[packetdata count];
    }
    int srcPort=[udp getdestinationPort];
    int destPort=[udp getsourcePort];
    short checksum=0;
    
    IPv4Header* ipheader=[IPPacketFactory copyIPv4Header:ip];
    int srcIp=[ip getdestinationIP];
    int destIp=[ip getsourceIP];
    
    [ipheader setMayFragment:false];
    [ipheader setSourceIP:srcIp];
    [ipheader setDestinationIP:destIp];
    [ipheader setIdentification:[PacketUtil getPacketId]];
    
    int totalLength=[ip getIPHeaderLength]+udplen;
    
    [ipheader setTotalLength:totalLength];
    NSMutableArray* ipdata=[IPPacketFactory createIPv4Header:ipheader];
    
    ipdata[10]=[NSNumber numberWithShort:0];
    ipdata[11]=[NSNumber numberWithShort:0];
    
    NSMutableArray* ipchecksum=[PacketUtil calculateChecksum:ipdata offset:0 length:[ipdata count]];
    
    ipdata[10]=ipchecksum[0];
    ipdata[11]=ipchecksum[1];
    
    for(int i=0;i<[ipdata count];i++){
        [buffer addObject:ipdata[i]];
    }
    
    NSMutableArray* intcontainer=[[NSMutableArray alloc] init];

    [PacketUtil writeIntToBytes:srcPort buffer:intcontainer offset:0];
    
    for(int i=2;i<4;i++){
        [buffer addObject:intcontainer[i]];
    }
    
    [PacketUtil writeIntToBytes:destPort buffer:intcontainer offset:0];
    for(int i=2;i<4;i++){
        [buffer addObject:intcontainer[i]];
    }

    [PacketUtil writeIntToBytes:udplen buffer:intcontainer offset:0];

    for(int i=2;i<4;i++){
        [buffer addObject:intcontainer[i]];
    }
    
    [PacketUtil writeIntToBytes:checksum buffer:intcontainer offset:0];
    for(int i=2;i<4;i++){
        [buffer addObject:intcontainer[i]];
    }
    
    for(int i=0;i<[packetdata count];i++){
        [buffer addObject:packetdata[i]];
    }
    
    [[SessionManager sharedInstance].wormhole passMessageObject:[NSString stringWithFormat:@"UDPResponse长度：%lu",(unsigned long)[buffer count]] identifier:@"VPNStatus"];

    
    return buffer;
}

@end






































