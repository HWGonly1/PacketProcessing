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

+(NSMutableData *)createIPv4Header:(IPv4Header*)header{
    //Byte buffer[header.getIPHeaderLength];
    Byte array[[header getIPHeaderLength]];
    NSMutableData * buffer=[[NSMutableData alloc] init];
    Byte first = [header getInternetHeaderLength]&0xF;
    first = (Byte)(first|0x40);
    array[0]=first;
    //[buffer addObject:[NSNumber numberWithShort:first]];
    Byte second=(Byte)([header getDscpOrTypeOfService]<<2);
    Byte ecnMask=(Byte)([header getEcn]&0xFF);
    second=(Byte)(second&ecnMask);
    array[1]=second;
    //[buffer addObject:[NSNumber numberWithShort:second]];

    Byte totalLength1=(Byte)([header getTotalLength]>>8);
    Byte totalLength2=(Byte)([header getTotalLength]);
    array[2]=totalLength1;
    array[3]=totalLength2;
    //[buffer addObject:[NSNumber numberWithShort:totalLength1]];
    //[buffer addObject:[NSNumber numberWithShort:totalLength2]];

    Byte id1=(Byte)(header.getIdentification>>8);
    Byte id2=(Byte)(header.getIdentification);
    array[4]=id1;
    array[5]=id2;
    //[buffer addObject:[NSNumber numberWithShort:id1]];
    //[buffer addObject:[NSNumber numberWithShort:id2]];
    
    Byte leftfrag=(Byte)((header.getFragmentOffset>>8)&0x1F);
    Byte flag=(Byte)(header.getFlag|leftfrag);
    array[6]=flag;
    //[buffer addObject:[NSNumber numberWithShort:flag]];
    Byte rightfrag=(Byte)(header.getFragmentOffset&0xFF);
    array[7]=rightfrag;
    //[buffer addObject:[NSNumber numberWithShort:rightfrag]];
    
    Byte timeToLive=header.getTimeToLive;
    array[8]=timeToLive;
    //[buffer addObject:[NSNumber numberWithShort:timeToLive]];
    
    Byte protocol=header.getProtocol;
    array[9]=protocol;
    //[buffer addObject:[NSNumber numberWithShort:protocol]];
    
    Byte checksum1=(Byte)(header.getHeaderCheckSum>>8);
    Byte checksum2=(Byte)(header.getHeaderCheckSum);
    array[10]=checksum1;
    array[11]=checksum2;
    //[buffer addObject:[NSNumber numberWithShort:checksum1]];
    //[buffer addObject:[NSNumber numberWithShort:checksum2]];

    
    array[12] = (Byte)(header.getsourceIP>>24);
    array[13] = (Byte)(header.getsourceIP>>16);
    array[14] = (Byte)(header.getsourceIP>>8);
    array[15] = (Byte)(header.getsourceIP);
    //[buffer addObject:[NSNumber numberWithShort:(Byte)(header.getsourceIP>>24)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)(header.getsourceIP>>16)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)(header.getsourceIP>>8)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)(header.getsourceIP)]];

    
    array[16] = (Byte)(header.getdestinationIP>>24);
    array[17] = (Byte)(header.getdestinationIP>>16);
    array[18] = (Byte)(header.getdestinationIP>>8);
    array[19] = (Byte)(header.getdestinationIP);
    //[buffer addObject:[NSNumber numberWithShort:(Byte)(header.getdestinationIP>>24)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)(header.getdestinationIP>>16)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)(header.getdestinationIP>>8)]];
    //[buffer addObject:[NSNumber numberWithShort:(Byte)(header.getdestinationIP)]];
    
    //int optionCount=[header.optionBytes count];
    //if(optionCount>0){
    //    for(int i=0;i<optionCount;i++){
    //        buffer[20+i]=(Byte)[header.optionBytes[i] shortValue];
    //    }
    //}

    int optionCount=[header.optionBytes length];
    Byte* optionsarray=(Byte*)[header.optionBytes bytes];
    if(optionCount>0){
        for(int i=0;i<optionCount;i++){
            array[20+i]=optionsarray[i];
        }
    }
    [buffer appendBytes:array length:[header getIPHeaderLength]];
    return buffer;
}

+(IPv4Header *)createIPv4Header:(NSMutableData *)buffer start:(int)start{
    IPv4Header *head=nil;
    if([buffer length]-start<20){
        return nil;
    }
    Byte* array=(Byte*)[buffer bytes];
    Byte ipVersion=(Byte)(array[start])>>4;
    if(ipVersion!=0x04){
        return nil;
    }
    Byte internetHeaderLength=(Byte)(array[start]&0x0F);
    if([buffer length]<(start+internetHeaderLength*4)){
        return nil;
    }
    Byte dscp=(Byte)(array[start+1]>>2);
    Byte ecn=(Byte)(array[start+1]&0x03);
    int totalLength=[PacketUtil getNetworkInt:buffer start:start+2 length:2];
    int identification=[PacketUtil getNetworkInt:buffer start:start+4 length:2];
    Byte flag=array[start+6];
    bool mayFragment=(flag&0x40)>0x00;
    bool lastFragment=(flag&0x20)>0x00;
    int fragmentBits=[PacketUtil getNetworkInt:buffer start:start+6 length:2];
    int fragset=fragmentBits&0x1FFFF;
    short fragmentOffset=(short)fragset;
    Byte timeToLive=array[start+8];
    Byte protocol=array[start+9];
    int checksum=[PacketUtil getNetworkInt:buffer start:start+10 length:2];
    int sourceIP=[PacketUtil getNetworkInt:buffer start:start+12 length:4];
    int destIP=[PacketUtil getNetworkInt:buffer start:start+16 length:4];
    NSMutableData * options=[[NSMutableData alloc] init];
    if(internetHeaderLength==5){
    }else{
        int optionLength=(internetHeaderLength-5)*4;
        /*
        for(int i=20;i<(20+optionLength);i++){
            [options addObject:[NSNumber numberWithShort:(Byte)array[20+i]]];
        }
         */
        [options appendBytes:array+20 length:optionLength];
    }
    head=[[IPv4Header alloc] init:ipVersion internetHeaderLength:internetHeaderLength dscpOrTypeOfService:dscp ecn:ecn totalLength:totalLength identification:identification mayFragment:mayFragment lastFragment:lastFragment fragmentOffset:fragmentOffset timeToLive:timeToLive protocol:protocol headerChecksum:checksum sourceIP:sourceIP destinationIP:destIP optionBytes:options];
    return head;
}

@end
