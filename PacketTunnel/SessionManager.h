//
//  SessionManager.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/19.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef SessionManager_h
#define SessionManager_h
#endif /* SessionManager_h */
#import "UDPSession.h"
#import "MMWormhole.h"
@import NetworkExtension;
@interface SessionManager : NSObject
@property (nonatomic) NEPacketTunnelFlow* packetFlow;
@property (nonatomic) NSMutableDictionary *tcpdict;
@property (nonatomic) NSMutableDictionary *udpdict;
@property (nonatomic) dispatch_queue_t globalQueue;
@property (nonatomic) MMWormhole* wormhole;
+(SessionManager*)sharedInstance;
-(instancetype)init;
+(void)setupWithPacketTunnelFlow:(NEPacketTunnelFlow *)packetFlow;
-(void)addUDPSession:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort;
-(bool)existUDPSession:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort;
-(UDPSession*)getUDPSession:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort;
@end
