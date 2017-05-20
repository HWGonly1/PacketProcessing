//
//  UDPPacketFactory.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/18.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef UDPPacketFactory_h
#define UDPPacketFactory_h
#endif /* UDPPacketFactory_h */
@interface UDPPacketFactory : NSObject
-(instancetype)init;
+(UDPHeader*)createUDPHeader:(NSMutableArray*)buffer start:(int)start;
+(UDPHeader*)copyHeader:(UDPHeader*)header;
+(NSMutableArray*)createResponsePacket:(IPv4Header*)ip udp:(UDPHeader*)udp packetdata:(NSMutableArray*)packetdata;
@end
