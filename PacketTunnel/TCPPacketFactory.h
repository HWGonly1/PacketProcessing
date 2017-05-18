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
+(NSMutableArray*)createFinAckData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader ackToClient:(int)ackToClient seqToClient:(int)seqToClient isfin:(bool)isfin isack:(bool)isack;
+(NSMutableArray*)createFinData:(IPv4Header*)ip tcp:(TCPHeader*)tcp ackNumber:(int)ackNumber seqNumber:(int)seqNumber timeSender:(int)timeSender timeReplyto:(int)timeReplyto;
+(NSMutableArray*)createRstData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader datalength:(int)datalength;
+(NSMutableArray*)createResponseAckData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader ackToClient:(int)ackToClient;
+(NSMutableArray*)createResponsePacketData:(IPv4Header*)ip tcp:(TCPHeader*)tcp packetdata:(NSMutableArray*)packetdata ispsh:(bool)ispsh ackNumber:(int)ackNumber seqNumber:(int)seqNumber timeSender:(int)timeSender timeReplyto:(int)timeReplyto;
+(Packet*)createSynAckPacketData:(IPv4Header*)ip tcp:(TCPHeader*)tcp;
+(NSMutableArray*)createPacketData:(IPv4Header*)ipheader tcpheader:(TCPHeader*)tcpheader data:(NSMutableArray*)data;
+(TCPHeader*)createTCPHeader:(NSMutableArray*)buffer start:(int)start;
+(void)extractOptionData:(TCPHeader*)head;
@end
