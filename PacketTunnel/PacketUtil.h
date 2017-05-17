//
//  PacketUtil.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/15.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef PacketUtil_h
#define PacketUtil_h
#endif /* PacketUtil_h */
#import "IPv4Header.h"
#import "TCPHeader.h"
#import "UDPHeader.h"
volatile static bool enabledDebugLog;
volatile static int packetid;
static NSObject *syncObj;
@interface PacketUtil : NSObject
+(int)getPacketId;
+(bool)isEnabledDebugLog;
+(void)setEnabledDebugLog;
+(void)Debug:(NSString*)str;
+(void)writeIntToBytes:(int)value buffer:(Byte[])buffer offset:(int)offset;
+(void)writeShortToBytes:(short)value buffer:(Byte[])buffer offset:(int)offset;
+(short)getNetworkShort:(Byte[])buffer start:(int)start;
+(int)getNetworkInt:(Byte[])buffer start:(int)start length:(int)length;
+(bool)isValidTCPChecksum:(int)source destination:(int)destination data:(Byte[])data tcplength:(short)tcplength tcpoffset:(int)tcpoffset;
+(bool)isValidIPChecksum:(Byte[])data length:(int)length;
+(Byte *)calculateChecksum:(Byte[])data offset:(int)offset length:(int)length;
+(Byte *)calculateTCPHeaderChecksum:(Byte[])data offset:(int)offset tcplength:(int)tcplength destip:(int)destip sourceip:(int)sourceip;
+(NSString *)intToIPAddress:(int)addressInt;
+(NSString *)getLocalIpAddress;
+(NSString *)getUDPoutput:(IPv4Header *)ipheader udp:(UDPHeader *)udp;
+(NSString *)getOutput:(IPv4Header *)ipheader tcpheader:(TCPHeader *)tcpheader packetdata:(Byte[])packetdata length:(int)length;
+(bool)isPacketCorrupted:(TCPHeader *)tcpheader;
+(NSString *)bytesToStringArray:(Byte[])bytes bytesLength:(int)bytesLength;
@end
