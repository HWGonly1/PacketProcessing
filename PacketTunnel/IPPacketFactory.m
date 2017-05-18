//
//  IPPacketFactory.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/14.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPPacketFactory.h"
#import "IPv4Header.h"
#import "PacketUtil.h"
@implementation IPPacketFactory
+(IPv4Header *)copyIPv4Header:(IPv4Header*)ipheader{
    IPv4Header *ip=[[IPv4Header alloc] init:ipheader.getIPVersion internetHeaderLength:ipheader.getInternetHeaderLength dscpOrTypeOfService:ipheader.getDscpOrTypeOfService ecn:ipheader.getEcn totalLength:ipheader.getTotalLength identification:ipheader.getIdentification mayFragment:ipheader.isMayFragment lastFragment:ipheader.isLastFragment fragmentOffset:ipheader.getFragmentOffset timeToLive:ipheader.getTimeToLive protocol:ipheader.getProtocol headerChecksum:ipheader.getHeaderCheckSum sourceIP:ipheader.getsourceIP destinationIP:ipheader.getdestinationIP optionBytes:ipheader.getOptionBytes];
    return ip;
}

+(NSMutableArray *)createIPv4Header:(IPv4Header*)header{
    //Byte buffer[header.getIPHeaderLength];
    NSMutableArray * buffer=[[NSMutableArray alloc] init];
    Byte first = [header getInternetHeaderLength]&0xF;
    first = (Byte)(first|0x40);
    //buffer[0]=first;
    [buffer addObject:[NSNumber numberWithShort:first]];
    Byte second=(Byte)([header getDscpOrTypeOfService]<<2);
    Byte ecnMask=(Byte)([header getEcn]&0xFF);
    second=(Byte)(second&ecnMask);
    //buffer[1]=second;
    [buffer addObject:[NSNumber numberWithShort:second]];

    Byte totalLength1=(Byte)([header getTotalLength]>>8);
    Byte totalLength2=(Byte)([header getTotalLength]);
    //buffer[2]=totalLength1;
    //buffer[3]=totalLength2;
    [buffer addObject:[NSNumber numberWithShort:totalLength1]];
    [buffer addObject:[NSNumber numberWithShort:totalLength2]];

    Byte id1=(Byte)(header.getIdentification>>8);
    Byte id2=(Byte)(header.getIdentification);
    //buffer[4]=id1;
    //buffer[5]=id2;
    [buffer addObject:[NSNumber numberWithShort:id1]];
    [buffer addObject:[NSNumber numberWithShort:id2]];
    
    Byte leftfrag=(Byte)((header.getFragmentOffset>>8)&0x1F);
    Byte flag=(Byte)(header.getFlag|leftfrag);
    //buffer[6]=flag;
    [buffer addObject:[NSNumber numberWithShort:flag]];
    Byte rightfrag=(Byte)(header.getFragmentOffset);
    //buffer[7]=rightfrag;
    [buffer addObject:[NSNumber numberWithShort:rightfrag]];
    
    Byte timeToLive=header.getTimeToLive;
    //buffer[8]=timeToLive;
    [buffer addObject:[NSNumber numberWithShort:timeToLive]];
    
    Byte protocol=header.getProtocol;
    //buffer[9]=protocol;
    [buffer addObject:[NSNumber numberWithShort:protocol]];
    
    Byte checksum1=(Byte)(header.getHeaderCheckSum>>8);
    Byte checksum2=(Byte)(header.getHeaderCheckSum);
    //buffer[10]=checksum1;
    //buffer[11]=checksum2;
    [buffer addObject:[NSNumber numberWithShort:checksum1]];
    [buffer addObject:[NSNumber numberWithShort:checksum2]];

    
    //buffer[12] = (Byte)(header.getsourceIP>>24);
    //buffer[13] = (Byte)(header.getsourceIP>>16);
    //buffer[14] = (Byte)(header.getsourceIP>>8);
    //buffer[15] = (Byte)(header.getsourceIP);
    [buffer addObject:[NSNumber numberWithShort:(Byte)(header.getsourceIP>>24)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)(header.getsourceIP>>16)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)(header.getsourceIP>>8)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)(header.getsourceIP)]];

    
    //buffer[16] = (Byte)(header.getdestinationIP>>24);
    //buffer[17] = (Byte)(header.getdestinationIP>>16);
    //buffer[18] = (Byte)(header.getdestinationIP>>8);
    //buffer[19] = (Byte)(header.getdestinationIP);
    [buffer addObject:[NSNumber numberWithShort:(Byte)(header.getdestinationIP>>24)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)(header.getdestinationIP>>16)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)(header.getdestinationIP>>8)]];
    [buffer addObject:[NSNumber numberWithShort:(Byte)(header.getdestinationIP)]];
    
    //int optionCount=[header.optionBytes count];
    //if(optionCount>0){
    //    for(int i=0;i<optionCount;i++){
    //        buffer[20+i]=(Byte)[header.optionBytes[i] shortValue];
    //    }
    //}

    int optionCount=[header.optionBytes count];
    if(optionCount>0){
        for(int i=0;i<optionCount;i++){
            [buffer addObject:header.optionBytes[i]];
        }
    }
    return buffer;
}

+(IPv4Header *)createIPv4Header:(NSMutableArray *)buffer start:(int)start{
    IPv4Header *head=nil;
    if([buffer count]-start<20){
        return nil;
    }
    Byte ipVersion=(Byte)([buffer[start] shortValue])>>4;
    if(ipVersion!=0x04){
        return nil;
    }
    Byte internetHeaderLength=(Byte)([buffer[start] shortValue]&0x0F);
    if([buffer count]<(start+internetHeaderLength*4)){
        return nil;
    }
    Byte dscp=(Byte)([buffer[start+1] shortValue]>>2);
    Byte ecn=(Byte)([buffer[start+1] shortValue]&0x03);
    int totalLength=[PacketUtil getNetworkInt:buffer start:start+2 length:2];
    int identification=[PacketUtil getNetworkInt:buffer start:start+4 length:2];
    Byte flag=[buffer[start+6] shortValue];
    bool mayFragment=(flag&0x40)>0x00;
    bool lastFragment=(flag&0x20)>0x00;
    int fragmentBits=[PacketUtil getNetworkInt:buffer start:start+6 length:2];
    int fragset=fragmentBits&0x1FFFF;
    short fragmentOffset=(short)fragset;
    Byte timeToLive=[buffer[start+8] shortValue];
    Byte protocol=[buffer[start+9] shortValue];
    int checksum=[PacketUtil getNetworkInt:buffer start:start+10 length:2];
    int sourceIP=[PacketUtil getNetworkInt:buffer start:start+12 length:4];
    int destIP=[PacketUtil getNetworkInt:buffer start:start+16 length:4];
    NSMutableArray * options=[[NSMutableArray alloc] init];
    if(internetHeaderLength==5){
    }else{
        int optionLength=(internetHeaderLength-5)*4;
        for(int i=20;i<(20+optionLength);i++){
            [options addObject:[NSNumber numberWithShort:(Byte)[buffer[20+i] shortValue]]];
        }
    }
    head=[[IPv4Header alloc] init:ipVersion internetHeaderLength:internetHeaderLength dscpOrTypeOfService:dscp ecn:ecn totalLength:totalLength identification:identification mayFragment:mayFragment lastFragment:lastFragment fragmentOffset:fragmentOffset timeToLive:timeToLive protocol:protocol headerChecksum:checksum sourceIP:sourceIP destinationIP:destIP optionBytes:options];
    return head;
}

@end
