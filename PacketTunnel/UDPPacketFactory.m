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

+(UDPHeader*)createUDPHeader:(NSMutableData*)buffer start:(int)start{
    UDPHeader* header=nil;
    if(([buffer length]-start)<8){
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

+(NSMutableData*)createResponsePacket:(IPv4Header*)ip udp:(UDPHeader*)udp packetdata:(NSMutableData*)packetdata{

    NSMutableData* buffer=[[NSMutableData alloc]init];
    int udplen=8;
    if([packetdata length]!=0){
        udplen+=[packetdata length];
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
    NSMutableData* ipdata=[IPPacketFactory createIPv4Header:ipheader];
    
    Byte zeros[2]={0,0};
    [ipdata replaceBytesInRange:NSMakeRange(10, 2) withBytes:zeros length:2];
    
    //ipdata[10]=[NSNumber numberWithShort:0];
    //ipdata[11]=[NSNumber numberWithShort:0];
    
    NSMutableData* ipchecksum=[PacketUtil calculateChecksum:ipdata offset:0 length:[ipdata length]];
    Byte* temp=(Byte*)[ipchecksum bytes];
    [ipdata replaceBytesInRange:NSMakeRange(10, 2) withBytes:temp length:2];
    
    //ipdata[10]=ipchecksum[0];
    //ipdata[11]=ipchecksum[1];
    
    /*
    for(int i=0;i<[ipdata count];i++){
        [buffer addObject:ipdata[i]];
    }
    */
    [buffer appendData:ipdata];
    
    NSMutableData* intcontainer=[[NSMutableData alloc] init];
    Byte* tempcontainer;
    [PacketUtil writeIntToBytes:srcPort buffer:intcontainer offset:0];
    
    /*
    for(int i=2;i<4;i++){
        [buffer addObject:intcontainer[i]];
    }
    */
    tempcontainer=(Byte*)[intcontainer bytes];
    [buffer appendBytes:tempcontainer+2 length:2];
    
    [PacketUtil writeIntToBytes:destPort buffer:intcontainer offset:0];
    /*
    for(int i=2;i<4;i++){
        [buffer addObject:intcontainer[i]];
    }
     */
    tempcontainer=(Byte*)[intcontainer bytes];
    [buffer appendBytes:tempcontainer+2 length:2];
    
    [PacketUtil writeIntToBytes:udplen buffer:intcontainer offset:0];

    /*
    for(int i=2;i<4;i++){
        [buffer addObject:intcontainer[i]];
    }
    */
    tempcontainer=(Byte*)[intcontainer bytes];
    [buffer appendBytes:tempcontainer+2 length:2];
    
    [PacketUtil writeIntToBytes:checksum buffer:intcontainer offset:0];
    
    /*
    for(int i=2;i<4;i++){
        [buffer addObject:intcontainer[i]];
    }
     */
    tempcontainer=(Byte*)[intcontainer bytes];
    [buffer appendBytes:tempcontainer+2 length:2];
    
    /*
    for(int i=0;i<[packetdata count];i++){
        [buffer addObject:packetdata[i]];
    }
    */
    [buffer appendData:packetdata];
    
    //[[SessionManager sharedInstance].wormhole passMessageObject:[NSString stringWithFormat:@"UDPResponse长度：%lu",(unsigned long)[buffer count]] identifier:@"VPNStatus"];

    
    return buffer;
}

@end






































