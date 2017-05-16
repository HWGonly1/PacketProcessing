//
//  TCPPacketFactory.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/14.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPPacketFactory.h"
#import "IPv4Header.h"
#import "TCPHeader.h"
@implementation TCPPacketHeader
-(TCPHeader*)copyTCPHeader:(TCPHeader*)tcpheader{
    TCPHeader *tcp=[[TCPHeader alloc] init:[tcpheader getSourcePort] destinationPort:[tcpheader getdestinationPort]  sequenceNumber:[tcpheader getSequenceNumber] dataOffset:[tcpheader getdataOffset] isns:[tcpheader isNS] tcpFlags:[tcpheader getTCPFlags] windowSize:[tcpheader getWindowSize] checksum:[tcpheader getChecksum] urgentPointer:[tcpheader getUrgentPointer] options:[tcpheader getOptions] ackNum:[tcpheader getAckNumber]];
    [tcp setMaxSegmentSize:65535];
    [tcp setWindowScale:[tcpheader getWindowScale]];
    [tcp setIsSelectiveAckPermitted:[tcpheader isSelectiveAckPermitted]];
    [tcp setTimeStampSender:[tcpheader getTimestampSender]];
    [tcp setTimeStampReplyTo:[tcpheader getTimestampReplyTo]];
    return tcp;
}

-(Byte *) createFinAckData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader ackToClient:(int)ackToClient seqToClient:(int)seqToClient isfin:(bool)isfin isack:(bool)isack{
    Byte * buffer;
    IPv4Header *ip=ipheader;
    TCPHeader *tcp=[self copyTCPHeader:tcpheader];
    int sourceIP=[ip getsourceIP];
    int destIP=[ip getdestinationIP];
    int sourcePort=[tcp getSourcePort];
    int destPort=[tcp getdestinationPort];
    int ackNumber=ackToClient;
    int seqNumber=seqToClient;
    [ip setDestinationIP:destIP];
    [ip setSourceIP:sourceIP];
    [tcp setDestinationPort:destPort];
    [tcp setSourcePort:sourcePort];
    [tcp setAckNum:ackNumber];
    [tcp setSequenceNumber:seqNumber];
    
    return buffer;
}
@end
