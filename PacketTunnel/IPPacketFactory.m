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

-(NSData *)createIPv4Header:(IPv4Header)header{
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

@end
