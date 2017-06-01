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

+(NSMutableData*)createFinAckData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader ackToClient:(int)ackToClient seqToClient:(int)seqToClient isfin:(bool)isfin isack:(bool)isack{
    NSMutableData* buffer=[[NSMutableData alloc] init];
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
    
    buffer=[self createPacketData:ip tcpheader:tcp data:[[NSMutableData alloc] init]];
    return buffer;
}

+(NSMutableData*)createFinData:(IPv4Header*)ip tcp:(TCPHeader*)tcp ackNumber:(int)ackNumber seqNumber:(int)seqNumber timeSender:(int)timeSender timeReplyto:(int)timeReplyto{
    NSMutableData* buffer=[[NSMutableData alloc] init];
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
    
    NSMutableData* options=[[NSMutableData alloc] init];
    [tcp setOptions:options];
    
    [tcp setWindowSize:0];
    int totalLength=ip.getIPHeaderLength+tcp.getTCPHeaderLength;
    [ip setTotalLength:totalLength];
    buffer=[self createPacketData:ip tcpheader:tcp data:[[NSMutableData alloc] init]];
    return buffer;
}

+(NSMutableData*)createRstData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader datalength:(int)datalength{

    NSMutableData* buffer=[[NSMutableData alloc] init];
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
    
    NSMutableData* options=[[NSMutableData alloc] init];
    [tcp setOptions:options];
    [tcp setWindowSize:0];
    
    int totalLength=[ip getIPHeaderLength]+[tcp getTCPHeaderLength];
    [ip setTotalLength:totalLength];

    buffer=[self createPacketData:ip tcpheader:tcp data:[[NSMutableData alloc] init]];

    return buffer;
}

+(NSMutableData*)createResponseAckData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader ackToClient:(int)ackToClient{
    NSMutableData* buffer=[[NSMutableData alloc] init];
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

    buffer=[self createPacketData:ip tcpheader:tcp data:[[NSMutableData alloc] init]];

    return buffer;
}

+(NSMutableData*)createResponsePacketData:(IPv4Header*)ip tcp:(TCPHeader*)tcp packetdata:(NSMutableData*)packetdata ispsh:(bool)ispsh ackNumber:(int)ackNumber seqNumber:(int)seqNumber timeSender:(int)timeSender timeReplyto:(int)timeReplyto{
    NSMutableData* buffer=[[NSMutableData alloc] init];
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
    if([packetdata length]!=0){
        totalLength+=[packetdata length];
    }
    [ipheader setTotalLength:totalLength];
    
    buffer=[self createPacketData:ipheader tcpheader:tcpheader data:packetdata];
    
    return buffer;

}

+(Packet*)createSynAckPacketData:(IPv4Header*)ip tcp:(TCPHeader*)tcp{

    NSMutableData* buffer=[[NSMutableData alloc] init];
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

    buffer=[self createPacketData:ipheader tcpheader:tcpheader data:[[NSMutableData alloc] init]];

    [packet setBuffer:buffer];

    return packet;
}

+(NSMutableData*)createPacketData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader data:(NSMutableData*)data{

    int datalength=[data length];
    Byte* dataarray=(Byte*)[data bytes];
    NSMutableData* buffer=[[NSMutableData alloc] init];
    NSMutableData* ipbuffer=[IPPacketFactory createIPv4Header:ipheader];
    Byte* iparray=(Byte*)[ipbuffer bytes];
    NSMutableData* tcpbuffer=[self createTCPHeaderData:tcpheader];
    Byte* tcparray=(Byte*)[tcpbuffer bytes];
    Byte array[[ipheader getIPHeaderLength]+[tcpheader getTCPHeaderLength]+[data length]];
    int ipoffset=[ipbuffer length];
    /*
    for(int i=0;i<ipoffset;i++){
        [buffer addObject:ipbuffer[i]];
    }
     */
    for(int i=0;i<ipoffset;i++){
        array[i]=iparray[i];
    }
    int tcpoffset=[tcpbuffer length];
    for(int i=0;i<tcpoffset;i++){
        array[ipoffset+i]=tcparray[i];
    }
    /*
    for(int i=0;i<tcpoffset;i++){
        [buffer addObject:tcpbuffer[i]];
    }
    */
    if(datalength>0){
        for(int i=0;i<datalength;i++){
            array[ipoffset+tcpoffset+i]=dataarray[i];
        }
    }
    /*
    if(datalength>0){
        for(int i=0;i<datalength;i++){
            [buffer addObject:data[i]];
        }
    }
    */
    
    iparray[10]=0;
    iparray[11]=0;
    tcparray[16]=0;
    tcparray[17]=0;
    [buffer appendBytes:iparray length:ipoffset];
    [buffer appendBytes:tcparray length:tcpoffset];
    [buffer appendBytes:array length:datalength];
    
    //buffer[10]=[NSNumber numberWithShort:0];
    //buffer[11]=[NSNumber numberWithShort:0];
    
    NSMutableData* ipchecksum=[PacketUtil calculateChecksum:buffer offset:0 length:ipoffset];

    Byte* temparray1=(Byte*)[ipchecksum bytes];
    //buffer[10]=ipchecksum[0];
    //buffer[11]=ipchecksum[1];
    
    //iparray[10]=temparray1[0];
    //iparray[11]=temparray1[1];
    
    //buffer[ipoffset+16]=[NSNumber numberWithShort:0];
    //buffer[ipoffset+17]=[NSNumber numberWithShort:0];

    NSMutableData* tcpchecksum=[PacketUtil calculateTCPHeaderChecksum:buffer offset:ipoffset tcplength:tcpoffset+datalength destip:[ipheader getdestinationIP] sourceip:[ipheader getsourceIP]];
    Byte* temparray2=(Byte*)[tcpchecksum bytes];
    
    //tcparray[16]=temparray2[0];
    //tcparray[17]=temparray2[1];
    [buffer replaceBytesInRange:NSMakeRange(10, 2) withBytes:temparray1 length:2];
    [buffer replaceBytesInRange:NSMakeRange(ipoffset+16, 2) withBytes:temparray2 length:2];
    //buffer[ipoffset+16]=tcpchecksum[0];
    //buffer[ipoffset+17]=tcpchecksum[1];

    return buffer;
}

+(NSMutableData*)createTCPHeaderData:(TCPHeader*)header{
    NSMutableData* buffer=[[NSMutableData alloc] init];
    Byte array[[header getTCPHeaderLength]];
    Byte sourcePort1=(Byte)([header getSourcePort]>>8);
    Byte sourcePort2=(Byte)([header getSourcePort]);

    //[buffer addObject:[NSNumber numberWithShort:sourcePort1]];
    //[buffer addObject:[NSNumber numberWithShort:sourcePort2]];
    array[0]=sourcePort1;
    array[1]=sourcePort2;
    
    Byte destPort1=(Byte)([header getdestinationPort]>>8);
    Byte destPort2=(Byte)([header getdestinationPort]);
    
    //[buffer addObject:[NSNumber numberWithShort:destPort1]];
    //[buffer addObject:[NSNumber numberWithShort:destPort2]];
    array[2]=destPort1;
    array[3]=destPort2;
    
    //[buffer addObject:[NSNumber numberWithShort:(Byte)([header getSequenceNumber]>>24)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)([header getSequenceNumber]>>16)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)([header getSequenceNumber]>>8)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)([header getSequenceNumber])]];
    array[4]=(Byte)([header getSequenceNumber]>>24);
    array[5]=(Byte)([header getSequenceNumber]>>16);
    array[6]=(Byte)([header getSequenceNumber]>>8);
    array[7]=(Byte)([header getSequenceNumber]);
    
    //[buffer addObject:[NSNumber numberWithShort:(Byte)([header getAckNumber]>>24)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)([header getAckNumber]>>16)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)([header getAckNumber]>>8)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)([header getAckNumber])]];
    array[8]=(Byte)([header getAckNumber]>>24);
    array[9]=(Byte)([header getAckNumber]>>16);
    array[10]=(Byte)([header getAckNumber]>>8);
    array[11]=(Byte)([header getAckNumber]);
    
    Byte dataoffset=(Byte)[header getdataOffset];
    dataoffset<<=4;
    if([header isns]){
        dataoffset|=0x1;
    }
    
    //[buffer addObject:[NSNumber numberWithShort:dataoffset]];
    array[12]=dataoffset;
    
    Byte flag=[header getTCPFlags];
    //[buffer addObject:[NSNumber numberWithShort:flag]];
    array[13]=flag;
    
    Byte window1=(Byte)([header getWindowSize]>>8);
    Byte window2=(Byte)[header getWindowSize];
    //[buffer addObject:[NSNumber numberWithShort:window1]];
    //[buffer addObject:[NSNumber numberWithShort:window2]];
    array[14]=window1;
    array[15]=window2;
    
    Byte checksum1=(Byte)([header getChecksum]>>8);
    Byte checksum2=(Byte)[header getChecksum];
    //[buffer addObject:[NSNumber numberWithShort:checksum1]];
    //[buffer addObject:[NSNumber numberWithShort:checksum2]];
    array[16]=checksum1;
    array[17]=checksum2;
    
    Byte urgPointer1=(Byte)([header getUrgentPointer]>>8);
    Byte urgPointer2=(Byte)[header getUrgentPointer];
    //[buffer addObject:[NSNumber numberWithShort:urgPointer1]];
    //[buffer addObject:[NSNumber numberWithShort:urgPointer2]];
    array[18]=urgPointer1;
    array[19]=urgPointer2;
    
    NSMutableData* options=[header getOptions];
    Byte kind;
    Byte len;
    int timeSender=[header getTimestampSender];
    int timeReplyto=[header getTimestampReplyTo];
    Byte* optionsarray=(Byte*)[options bytes];
    for(int i=0;i<[options length];i++){
        kind=optionsarray[i];
        if(kind>1){
            if(kind == 8){//timestamp
                i += 2;
                if((i + 7) < [options length]){
                    [PacketUtil writeIntToBytes:timeSender buffer:options offset:i];
                    i += 4;
                    [PacketUtil writeIntToBytes:timeReplyto buffer:options offset:i];
                }
                break;
            }else if((i+1) < [options length]){
                len = (Byte)optionsarray[i+1];
                i = i + len - 1;
            }
        }
    }
    if([options length]>0){
        for(int i=0;i<[options length];i++){
            array[20+i]=optionsarray[i];
        }
    }
    [buffer appendBytes:array length:[header getTCPHeaderLength]];
    return buffer;
}

+(TCPHeader*)createTCPHeader:(NSMutableData*)buffer start:(int)start{
    TCPHeader *head=nil;
    Byte* array=(Byte*)[buffer length];
    if([buffer length]<start+20){
        return head;
    }
    int sourPort=[PacketUtil getNetworkInt:buffer start:start length:2];
    int destPort=[PacketUtil getNetworkInt:buffer start:start+2 length:2];
    int sequenceNumber=[PacketUtil getNetworkInt:buffer start:start+4 length:4];
    int ackNumber=[PacketUtil getNetworkInt:buffer start:start+8 length:4];
    int dataOffset=(array[start+12]>>4)&0x0F;
    if(dataOffset<5&&[buffer length]==60){
        dataOffset=10;
    }
    else if(dataOffset<5){
        dataOffset=5;
    }
    if([buffer length]<(start+dataOffset*4)){
        return head;
    }
    Byte nsbyte=(Byte)array[start+12];
    bool isns=(nsbyte&0x1)>0x0;
    int tcpflag=[PacketUtil getNetworkInt:buffer start:start+13 length:1];
    int windowsize=[PacketUtil getNetworkInt:buffer start:14 length:2];
    int checksum=[PacketUtil getNetworkInt:buffer start:16 length:2];
    int urgpointer=[PacketUtil getNetworkInt:buffer start:18 length:2];
    NSMutableData* options=[[NSMutableData alloc] init];
    if(dataOffset>5){
        int optionlength=(dataOffset-5)*4;
        Byte optionsarray[optionlength];
        for(int i=0;i<optionlength;i++){
            optionsarray[i]=array[start+20+i];
        }
        [options appendBytes:optionsarray length:optionlength];
    }
    head=[[TCPHeader alloc] init:sourPort destinationPort:destPort sequenceNumber:sequenceNumber dataOffset:dataOffset isns:isns tcpFlags:tcpflag windowSize:windowsize checksum:checksum urgentPointer:urgpointer options:options ackNum:ackNumber];
    [self extractOptionData:head];
    return head;
}

+(void)extractOptionData:(TCPHeader*)head{
    NSMutableData* options=[head getOptions];
    Byte* optionsarray=(Byte*)[options bytes];
    Byte kind;
    for(int i=0;i<[options length];i++){
        kind=(Byte)optionsarray[i];
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













































