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
#import "TCPSession.h"
#import "MMWormhole.h"
@import NetworkExtension;
@interface SessionManager : NSObject
@property (nonatomic) NEPacketTunnelFlow* packetFlow;
@property (nonatomic) NSMutableDictionary *tcpdict;
@property (nonatomic) NSMutableDictionary *udpdict;
@property (nonatomic) dispatch_queue_t globalQueue;
@property (nonatomic) NSMutableDictionary* dict;
@property (nonatomic) MMWormhole* wormhole;
+(SessionManager*)sharedInstance;
-(instancetype)init;
+(void)setupWithPacketTunnelFlow:(NEPacketTunnelFlow *)packetFlow;
-(void)addUDPSession:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort;
-(bool)existUDPSession:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort;
-(UDPSession*)getUDPSession:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort;
-(TCPSession*)createNewSession:(int)ip port:(int)port srcIp:(int)srcIp srcPort:(int)srcPort;
-(bool)existTCPSession:(int)ip port:(int)port srcIp:(int)srcIp srcPort:(int)srcPort;
-(int)addClientData:(IPv4Header*)ip tcp:(TCPHeader*)tcp buffer:(NSMutableData*)buffer;
-(void)closeSession:(int)ip port:(int)port srcIp:(int)srcIp srcPort:(int)srcPort;
-(void)closeSession:(TCPSession*)session;
-(void)closeUDPSession:(UDPSession*)session;
-(void)keepSessionAlive:(TCPSession*)session;
@end
