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
@import NetworkExtension;
#define TunnelMTU 1600
#define kTun2SocksStoppedNotification @"kTun2SocksStoppedNotification"

@interface TunnelInterface : NSObject
+ (TunnelInterface *)sharedInterface;
+ (void)setPacketFlow:(NEPacketTunnelFlow*)packetFlow;
+ (NSError *)setupWithPacketTunnelFlow:(NEPacketTunnelFlow *)packetFlow;
+ (void)processPackets;
+ (void)writePacket: (NSData *)packet;
+ (void)stop;
@end

