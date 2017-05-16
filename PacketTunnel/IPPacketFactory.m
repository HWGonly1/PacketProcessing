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
@implementation IPPacketFactory

-(IPv4Header *)copyIPv4Header:(IPv4Header*)ipheader{
    IPv4Header *ip=[[IPv4Header alloc] init:ipheader.getIPVersion internetHeaderLength:ipheader.getInternetHeaderLength dscpOrTypeOfService:ipheader.getDscpOrTypeOfService ecn:ipheader.getEcn totalLength:ipheader.getTotalLength identification:ipheader.getIdentification mayFragment:ipheader.isMayFragment lastFragment:ipheader.isLastFragment fragmentOffset:ipheader.getFragmentOffset timeToLive:ipheader.getTimeToLive protocol:ipheader.getProtocol headerChecksum:ipheader.getHeaderCheckSum sourceIP:ipheader.getsourceIP destinationIP:ipheader.getdestinationIP optionBytes:ipheader.getOptionBytes];
    return ip;
}
/*
-(IPv4Header *)createIPv4Header:(Byte[])buffer start:(int)start{
    IPv4Header *head=nil;
    if((sizeof(buffer)/sizeof(Byte))-start<20){
        return nil;
    }
    Byte ipVersion=(Byte)(buffer[start]>>4);
    if(ipVersion!=0x04){
        return nil;
    }
    Byte internetHeaderLength=(Byte)(buffer[start]&0x0F);
    if((sizeof(buffer)/sizeof(Byte))<(start+internetHeaderLength*4)){
        return nil;
    }
    Byte dscp=(Byte)(buffer[start+1]>>2);
    Byte ecn=(Byte)(buffer[start+1]&0x03);
    unsigned totalLength=PacketUtil.getNetworkInt(buffer,start+2,2);
    unsigned identification=PacketUtil.getNetworkInt(buffer,start+4,2);
    Byte flag=buffer[start+6];
    bool mayFragment=(flag&0x40)>0x00;
    bool lastFragment=(flag&0x20)>0x00;
    unsigned fragmentBits=PacketUtil.getNetworkInt(buffer,start+6,2);
    unsigned fragset=fragmentBits&0x1FFFF;
    short fragmentOffset=(short)fragset;
    Byte timeToLive=buffer[start+8];
    Byte protocol=buffer[start+9];
    unsigned checksum=PacketUtil.getNetworkInt(buffer,start+10,2);
    unsigned sourceIP=PacketUtil.getNetworkInt(buffer,start+12,4);
    unsigned destIP=PacketUtil.getNetworkInt(buffer,start+16,4);
    Byte * options=nil;
    if(internetHeaderLength==5){
        //options=Byte[0];
    }else{
        int optionLength=(internetHeaderLength-5)*4;
        Byte temp[optionLength];
        for(int i=20;i<(20+optionLength);i++){
            temp[i-20]=buffer[i];
        }
        options=temp;
    }
    head=[[IPv4Header alloc] init:ipVersion internetHeaderLength:internetHeaderLength dscpOrTypeOfService:dscp ecn:ecn totalLength:totalLength identification:identification mayFragment:mayFragment lastFragment:lastFragment fragmentOffset:fragmentOffset timeToLive:timeToLive protocol:protocol headerChecksum:checksum sourceIP:sourceIP destinationIP:destIP optionBytes:options];
    return head;
}

-(Byte *)createIPv4Header:(IPv4Header)header{
    Byte buffer[header.getIPHeaderLength];
    Byte first = [header getInternetHeaderLength]&0xF;
    first = (Byte)(first|0x40);
    buffer[0]=first;
    Byte second=(Byte)([header getDscpOrTypeOfService]<<2);
    Byte ecnMask=(Byte)([header getEcn]&0xFF);
    second=(Byte)(second&ecnMask);
    buffer[1]=second;
    
    Byte totalLength1=(Byte)([header getTotalLength]>>8);
    Byte totalLength2=(Byte)([header getTotalLength]);
    buffer[2]=totalLength1;
    buffer[3]=totalLength2;
    
    
}
*/
@end
