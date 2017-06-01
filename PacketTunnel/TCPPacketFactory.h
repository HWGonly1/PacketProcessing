//
//  TCPPacketFactory.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/14.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef TCPPacketFactory_h
#define TCPPacketFactory_h
#endif /* TCPPacketFactory_h */
#import "PacketUtil.h"
#import "IPPacketFactory.h"
#import "IPv4Header.h"
#import "TCPHeader.h"
#import "Packet.h"
@interface TCPPacketFactory : NSObject
+(TCPHeader*)copyTCPHeader:(TCPHeader*)tcpheader;
+(NSMutableData*)createFinAckData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader ackToClient:(int)ackToClient seqToClient:(int)seqToClient isfin:(bool)isfin isack:(bool)isack;
+(NSMutableData*)createFinData:(IPv4Header*)ip tcp:(TCPHeader*)tcp ackNumber:(int)ackNumber seqNumber:(int)seqNumber timeSender:(int)timeSender timeReplyto:(int)timeReplyto;
+(NSMutableData*)createRstData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader datalength:(int)datalength;
+(NSMutableData*)createResponseAckData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader ackToClient:(int)ackToClient;
+(NSMutableData*)createResponsePacketData:(IPv4Header*)ip tcp:(TCPHeader*)tcp packetdata:(NSMutableData*)packetdata ispsh:(bool)ispsh ackNumber:(int)ackNumber seqNumber:(int)seqNumber timeSender:(int)timeSender timeReplyto:(int)timeReplyto;
+(Packet*)createSynAckPacketData:(IPv4Header*)ip tcp:(TCPHeader*)tcp;
+(NSMutableData*)createPacketData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader data:(NSMutableData*)data;
+(TCPHeader*)createTCPHeader:(NSMutableData*)buffer start:(int)start;
+(void)extractOptionData:(TCPHeader*)head;
@end
