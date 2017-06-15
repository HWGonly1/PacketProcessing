//
//  TunnelInterface.h
//  PacketProcessing
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef TunnelInterface_h
#define TunnelInterface_h
#endif /* TunnelInterface_h */
#import <Foundation/Foundation.h>
#import "IPv4Header.h"
#import "UDPHeader.h"
#import "TCPHeader.h"
#import "IPPacketFactory.h"
#import "TCPPacketFactory.h"
#import "UDPPacketFactory.h"
#import "PacketUtil.h"
#import "SessionManager.h"
#import "UDPSession.h"
#import "TCPSession.h"
#import <MMWormhole.h>
@import NetworkExtension;

@interface TunnelInterface : NSObject
@property (nonatomic) bool processing;
+ (TunnelInterface *)sharedInterface;
+ (void)setPacketFlow:(NEPacketTunnelFlow*)packetFlow;
+ (void)processPackets;
+ (void)writePacket:(NSData *)packet;
@end

