//
//  TCPPacketFactory.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/14.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PacketUtil.h"
#import "IPPacketFactory.h"
#import "TCPPacketFactory.h"
#import "IPv4Header.h"
#import "TCPHeader.h"
#import "Packet.h"
#import "SessionManager.h"
@implementation TCPPacketFactory
+(TCPHeader*)copyTCPHeader:(TCPHeader*)tcpheader{
    TCPHeader *tcp=[[TCPHeader alloc] init:[tcpheader getSourcePort] destinationPort:[tcpheader getdestinationPort]  sequenceNumber:[tcpheader getSequenceNumber] dataOffset:[tcpheader getdataOffset] isns:[tcpheader isns] tcpFlags:[tcpheader getTCPFlags] windowSize:[tcpheader getWindowSize] checksum:[tcpheader getChecksum] urgentPointer:[tcpheader getUrgentPointer] options:[tcpheader getOptions] ackNum:[tcpheader getAckNumber]];
    [tcp setMaxSegmentSize:65535];
    [tcp setWindowScale:[tcpheader getWindowScale]];
    [tcp setIsSelectiveackPermitted:[tcpheader isSelectiveackPermitted]];
    [tcp setTimeStampSender:[tcpheader getTimestampSender]];
    [tcp setTimeStampReplyTo:[tcpheader getTimestampReplyTo]];
    return tcp;
}

+(NSMutableArray*)createFinAckData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader ackToClient:(int)ackToClient seqToClient:(int)seqToClient isfin:(bool)isfin isack:(bool)isack{
    NSMutableArray* buffer=[[NSMutableArray alloc] init];
    IPv4Header *ip=ipheader;
    TCPHeader *tcp=[self copyTCPHeader:tcpheader];
    int sourceIP=[ip getdestinationIP];
    int destIP=[ip getsourceIP];
    int sourcePort=[tcp getdestinationPort];
    int destPort=[tcp getSourcePort];
    int ackNumber=ackToClient;
    int seqNumber=seqToClient;
    [ip setDestinationIP:destIP];
    [ip setSourceIP:sourceIP];
    [tcp setDestinationPort:destPort];
    [tcp setSourcePort:sourcePort];
    [tcp setAckNum:ackNumber];
    [tcp setSequenceNumber:seqNumber];
    
    [ip setIdentification:[PacketUtil getPacketId]];
    [tcp setIsACK:isack];
    [tcp setIsSYN:false];
    [tcp setIsPSH:false];
    [tcp setIsFIN:isfin];
    
    [tcp setTimeStampReplyTo:[tcp getTimestampSender]];
    int recordTime = [[NSDate date] timeIntervalSince1970];
    [tcp setTimeStampSender:recordTime];
    
    int totalLength=ip.getIPHeaderLength+tcp.getTCPHeaderLength;
    [ip setTotalLength:totalLength];
    
    buffer=[self createPacketData:ip tcpheader:tcp data:[[NSMutableArray alloc] init]];
    return buffer;
}

+(NSMutableArray*)createFinData:(IPv4Header*)ip tcp:(TCPHeader*)tcp ackNumber:(int)ackNumber seqNumber:(int)seqNumber timeSender:(int)timeSender timeReplyto:(int)timeReplyto{
    NSMutableArray* buffer=[[NSMutableArray alloc] init];
    int sourceIp = [ip getdestinationIP];
    int destIp = [ip getsourceIP];
    int sourcePort = [tcp getdestinationPort];
    int destPort = [tcp getSourcePort];
    
    [tcp setAckNum:ackNumber];
    [tcp setSequenceNumber:seqNumber];
    
    [tcp setTimeStampSender:timeSender];
    [tcp setTimeStampReplyTo:timeReplyto];
    
    [ip setDestinationIP:destIp];
    [ip setSourceIP:sourceIp];
    [tcp setDestinationPort:destPort];
    [tcp setSourcePort:sourcePort];
    
    [ip setIdentification:[PacketUtil getPacketId]];
    
    [tcp setIsRST:false];
    [tcp setIsACK:false];
    [tcp setIssyn:false];
    [tcp setIsPSH:false];
    [tcp setIsCWR:false];
    [tcp setIsECE:false];
    [tcp setIsFIN:true];
    [tcp setIsNS:false];
    [tcp setIsURG:false];
    
    NSMutableArray* options=[[NSMutableArray alloc] init];
    [tcp setOptions:options];
    
    [tcp setWindowSize:0];
    int totalLength=ip.getIPHeaderLength+tcp.getTCPHeaderLength;
    [ip setTotalLength:totalLength];
    buffer=[self createPacketData:ip tcpheader:tcp data:[[NSMutableArray alloc] init]];
    return buffer;
}

+(NSMutableArray*)createRstData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader datalength:(int)datalength{

    NSMutableArray* buffer=[[NSMutableArray alloc] init];
    IPv4Header* ip=[IPPacketFactory copyIPv4Header:ipheader];
    TCPHeader* tcp=[self copyTCPHeader:tcpheader];

    int sourceIp = [ip getdestinationIP];
    int destIp = [ip getsourceIP];
    int sourcePort = [tcp getdestinationPort];
    int destPort = [tcp getSourcePort];

    int ackNumber=0;
    int seqNumber=0;
    
    if([tcp getAckNumber]>0){
        seqNumber=[tcp getAckNumber];
    }else{
        ackNumber=[tcp getSequenceNumber]+datalength;
    }
    [tcp setSequenceNumber:seqNumber];
    [tcp setAckNum:ackNumber];
    
    [ip setDestinationIP:destIp];
    [ip setSourceIP:sourceIp];
    [tcp setDestinationPort:destPort];
    [tcp setSourcePort:sourcePort];
    
    [ip setIdentification:0];

    [tcp setIsRST:true];
    [tcp setIsACK:false];
    [tcp setIssyn:false];
    [tcp setIsPSH:false];
    [tcp setIsCWR:false];
    [tcp setIsECE:false];
    [tcp setIsFIN:false];
    [tcp setIsNS:false];
    [tcp setIsURG:false];
    
    NSMutableArray* options=[[NSMutableArray alloc] init];
    [tcp setOptions:options];
    [tcp setWindowSize:0];
    
    int totalLength=[ip getIPHeaderLength]+[tcp getTCPHeaderLength];
    [ip setTotalLength:totalLength];

    buffer=[self createPacketData:ip tcpheader:tcp data:[[NSMutableArray alloc] init]];

    return buffer;
}

+(NSMutableArray*)createResponseAckData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader ackToClient:(int)ackToClient{
    NSMutableArray* buffer=[[NSMutableArray alloc] init];
    IPv4Header* ip=[IPPacketFactory copyIPv4Header:ipheader];
    TCPHeader* tcp=[self copyTCPHeader:tcpheader];
    
    int sourceIp = [ip getdestinationIP];
    int destIp = [ip getsourceIP];
    int sourcePort = [tcp getdestinationPort];
    int destPort = [tcp getSourcePort];

    int ackNumber=ackToClient;
    int seqNumber=[tcp getAckNumber];
    
    [ip setDestinationIP:destIp];
    [ip setSourceIP:sourceIp];
    [tcp setDestinationPort:destPort];
    [tcp setSourcePort:sourcePort];
    
    [tcp setSequenceNumber:seqNumber];
    [tcp setAckNum:ackNumber];
    
    [ip setIdentification:[PacketUtil getPacketId]];
    
    [tcp setIsACK:true];
    [tcp setIssyn:false];
    [tcp setIsPSH:false];
    
    [tcp setTimeStampReplyTo:[tcp getTimestampSender]];
    int recordTime = [[NSDate date] timeIntervalSince1970];
    [tcp setTimeStampSender:recordTime];
    
    int totalLength=[ip getIPHeaderLength]+[tcp getTCPHeaderLength];
    [ip setTotalLength:totalLength];

    buffer=[self createPacketData:ip tcpheader:tcp data:[[NSMutableArray alloc] init]];

    return buffer;
}

+(NSMutableArray*)createResponsePacketData:(IPv4Header*)ip tcp:(TCPHeader*)tcp packetdata:(NSMutableArray*)packetdata ispsh:(bool)ispsh ackNumber:(int)ackNumber seqNumber:(int)seqNumber timeSender:(int)timeSender timeReplyto:(int)timeReplyto{
    NSMutableArray* buffer=[[NSMutableArray alloc] init];
    IPv4Header* ipheader=[IPPacketFactory copyIPv4Header:ip];
    TCPHeader* tcpheader=[self copyTCPHeader:tcp];
    
    int sourceIp = [ip getdestinationIP];
    int destIp = [ip getsourceIP];
    int sourcePort = [tcp getdestinationPort];
    int destPort = [tcp getSourcePort];
    
    [ipheader setDestinationIP:destIp];
    [ipheader setSourceIP:sourceIp];
    [tcpheader setDestinationPort:destPort];
    [tcpheader setSourcePort:sourcePort];
    
    [tcpheader setSequenceNumber:seqNumber];
    [tcpheader setAckNum:ackNumber];
    
    [ip setIdentification:[PacketUtil getPacketId]];

    [tcp setIsACK:true];
    [tcp setIssyn:false];
    [tcp setIsPSH:ispsh];
    [tcp setIsFIN:false];
    
    [tcpheader setTimeStampSender:timeSender];
    [tcpheader setTimeStampReplyTo:timeReplyto];
    
    int totalLength=[ip getIPHeaderLength]+[tcp getTCPHeaderLength];
    if([packetdata count]!=0){
        totalLength+=[packetdata count];
    }
    [ipheader setTotalLength:totalLength];
    
    buffer=[self createPacketData:ipheader tcpheader:tcpheader data:packetdata];
    
    return buffer;

}

+(Packet*)createSynAckPacketData:(IPv4Header*)ip tcp:(TCPHeader*)tcp{

    NSMutableArray* buffer=[[NSMutableArray alloc] init];
    Packet* packet=[[Packet alloc] init];

    IPv4Header* ipheader=[IPPacketFactory copyIPv4Header:ip];
    TCPHeader* tcpheader=[self copyTCPHeader:tcp];

    int sourceIp = [ip getdestinationIP];
    int destIp = [ip getsourceIP];
    int sourcePort = [tcp getdestinationPort];
    int destPort = [tcp getSourcePort];

    int ackNumber=[tcpheader getSequenceNumber]+1;
    int seqNumber;
    seqNumber=arc4random()%INT32_MAX;

    [ipheader setDestinationIP:destIp];
    [ipheader setSourceIP:sourceIp];
    [tcpheader setDestinationPort:destPort];
    [tcpheader setSourcePort:sourcePort];

    [tcpheader setSequenceNumber:seqNumber];
    [tcpheader setAckNum:ackNumber];

    [tcpheader setIsACK:true];
    [tcpheader setIsSYN:true];

    [tcpheader setTimeStampReplyTo:[tcp getTimestampSender]];
    int recordTime = [[NSDate date] timeIntervalSince1970];
    [tcpheader setTimeStampSender:recordTime];

    [packet setIpheader:ipheader];
    [packet setTcpheader:tcpheader];

    buffer=[self createPacketData:ipheader tcpheader:tcpheader data:[[NSMutableArray alloc] init]];

    [packet setBuffer:buffer];

    return packet;
}

+(NSMutableArray*)createPacketData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader data:(NSMutableArray*)data{

    int datalength=[data count];
    NSMutableArray* buffer=[[NSMutableArray alloc] init];
    NSMutableArray* ipbuffer=[IPPacketFactory createIPv4Header:ipheader];
    NSMutableArray* tcpbuffer=[self createTCPHeaderData:tcpheader];
    int ipoffset=[ipbuffer count];

    for(int i=0;i<ipoffset;i++){
        [buffer addObject:ipbuffer[i]];
    }
    int tcpoffset=[tcpbuffer count];

    for(int i=0;i<tcpoffset;i++){

        [buffer addObject:tcpbuffer[i]];
    }
    

    if(datalength>0){
        for(int i=0;i<datalength;i++){
            [buffer addObject:data[i]];
        }
    }
    
    buffer[10]=[NSNumber numberWithShort:0];
    buffer[11]=[NSNumber numberWithShort:0];

    NSMutableArray* ipchecksum=[PacketUtil calculateChecksum:buffer offset:0 length:ipoffset];

    buffer[10]=ipchecksum[0];
    buffer[11]=ipchecksum[1];

    buffer[ipoffset+16]=[NSNumber numberWithShort:0];
    buffer[ipoffset+17]=[NSNumber numberWithShort:0];

    NSMutableArray* tcpchecksum=[PacketUtil calculateTCPHeaderChecksum:buffer offset:ipoffset tcplength:tcpoffset+datalength destip:[ipheader getdestinationIP] sourceip:[ipheader getsourceIP]];
    

    buffer[ipoffset+16]=tcpchecksum[0];
    buffer[ipoffset+17]=tcpchecksum[1];

    return buffer;
}

+(NSMutableArray*)createTCPHeaderData:(TCPHeader*)header{
    NSMutableArray* buffer=[[NSMutableArray alloc] init];
    Byte sourcePort1=(Byte)([header getSourcePort]>>8);
    Byte sourcePort2=(Byte)([header getSourcePort]);

    [buffer addObject:[NSNumber numberWithShort:sourcePort1]];
    [buffer addObject:[NSNumber numberWithShort:sourcePort2]];

    Byte destPort1=(Byte)([header getdestinationPort]>>8);
    Byte destPort2=(Byte)([header getdestinationPort]);
    
    [buffer addObject:[NSNumber numberWithShort:destPort1]];
    [buffer addObject:[NSNumber numberWithShort:destPort2]];
    
    [buffer addObject:[NSNumber numberWithShort:(Byte)([header getSequenceNumber]>>24)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)([header getSequenceNumber]>>16)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)([header getSequenceNumber]>>8)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)([header getSequenceNumber])]];

    [buffer addObject:[NSNumber numberWithShort:(Byte)([header getAckNumber]>>24)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)([header getAckNumber]>>16)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)([header getAckNumber]>>8)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)([header getAckNumber])]];

    Byte dataoffset=(Byte)[header getdataOffset];
    dataoffset<<=4;
    if([header isns]){
        dataoffset|=0x1;
    }
    
    [buffer addObject:[NSNumber numberWithShort:dataoffset]];

    Byte flag=[header getTCPFlags];
    [buffer addObject:[NSNumber numberWithShort:flag]];

    Byte window1=(Byte)([header getWindowSize]>>8);
    Byte window2=(Byte)[header getWindowSize];
    [buffer addObject:[NSNumber numberWithShort:window1]];
    [buffer addObject:[NSNumber numberWithShort:window2]];

    Byte checksum1=(Byte)([header getChecksum]>>8);
    Byte checksum2=(Byte)[header getChecksum];
    [buffer addObject:[NSNumber numberWithShort:checksum1]];
    [buffer addObject:[NSNumber numberWithShort:checksum2]];

    Byte urgPointer1=(Byte)([header getUrgentPointer]>>8);
    Byte urgPointer2=(Byte)[header getUrgentPointer];
    [buffer addObject:[NSNumber numberWithShort:urgPointer1]];
    [buffer addObject:[NSNumber numberWithShort:urgPointer2]];

    NSMutableArray* options=[header getOptions];
    Byte kind;
    Byte len;
    int timeSender=[header getTimestampSender];
    int timeReplyto=[header getTimestampReplyTo];
    
    for(int i=0;i<[options count];i++){
        kind=(Byte)[options[i] shortValue];
        if(kind>1){
            if(kind == 8){//timestamp
                i += 2;
                if((i + 7) < [options count]){
                    [PacketUtil writeIntToBytes:timeSender buffer:options offset:i];
                    i += 4;
                    [PacketUtil writeIntToBytes:timeReplyto buffer:options offset:i];
                }
                break;
            }else if((i+1) < [options count]){
                len = (Byte)[options[i+1] shortValue];
                i = i + len - 1;
            }
        }
    }
    if([options count]>0){
        for(int i=0;i<[options count];i++){
            [buffer addObject:options[i]];
        }
    }
    return buffer;
}

+(TCPHeader*)createTCPHeader:(NSMutableArray*)buffer start:(int)start{
    TCPHeader *head=nil;
    if([buffer count]<start+20){
        return head;
    }
    int sourPort=[PacketUtil getNetworkInt:buffer start:start length:2];
    int destPort=[PacketUtil getNetworkInt:buffer start:start+2 length:2];
    int sequenceNumber=[PacketUtil getNetworkInt:buffer start:start+4 length:4];
    int ackNumber=[PacketUtil getNetworkInt:buffer start:start+8 length:4];
    int dataOffset=([buffer[start+12] shortValue]>>4)&0x0F;
    if(dataOffset<5&&[buffer count]==60){
        dataOffset=10;
    }
    else if(dataOffset<5){
        dataOffset=5;
    }
    if([buffer count]<(start+dataOffset*4)){
        return head;
    }
    Byte nsbyte=(Byte)[buffer[start+12] shortValue];
    bool isns=(nsbyte&0x1)>0x0;
    int tcpflag=[PacketUtil getNetworkInt:buffer start:start+13 length:1];
    int windowsize=[PacketUtil getNetworkInt:buffer start:14 length:2];
    int checksum=[PacketUtil getNetworkInt:buffer start:16 length:2];
    int urgpointer=[PacketUtil getNetworkInt:buffer start:18 length:2];
    NSMutableArray* options=[[NSMutableArray alloc] init];
    if(dataOffset>5){
        int optionlength=(dataOffset-5)*4;
        for(int i=0;i<optionlength;i++){
            [options addObject:buffer[start+20+i]];
        }
    }
    head=[[TCPHeader alloc] init:sourPort destinationPort:destPort sequenceNumber:sequenceNumber dataOffset:dataOffset isns:isns tcpFlags:tcpflag windowSize:windowsize checksum:checksum urgentPointer:urgpointer options:options ackNum:ackNumber];
    [self extractOptionData:head];
    return head;
}

+(void)extractOptionData:(TCPHeader*)head{
    NSMutableArray* options=[head getOptions];
    Byte kind;
    for(int i=0;i<[options count];i++){
        kind=(Byte)[options[i] shortValue];
        if(kind == 2){
            i +=2;
            int segsize = [PacketUtil getNetworkInt:options start:i length:2];
            [head setMaxSegmentSize:segsize];
            i++;
        }else if(kind == 3){
            i += 2;
            int scale = [PacketUtil getNetworkInt:options start:i length:1];
            [head setWindowScale:scale];
        }else if(kind == 4){
            i++;
            [head setIsSelectiveackPermitted:true];
        }else if(kind == 5){//SACK => selective acknowledgment
            i++;
            int sacklength = [PacketUtil getNetworkInt:options start:i length:1];
            i = i + (sacklength - 2);
            //case 10, 18, 26 and 34
            //TODO: handle missing segments
            //rare case => low priority
        }else if(kind == 8){//timestamp and echo of previous timestamp
            i += 2;
            int timestampSender = [PacketUtil getNetworkInt:options start:i length:4];
            i += 4;
            int timestampReplyTo = [PacketUtil getNetworkInt:options start:i length:4];
            i += 3;
            [head setTimeStampSender:timestampSender];
            [head setTimeStampReplyTo:timestampReplyTo];
        }
    }
}
@end













































