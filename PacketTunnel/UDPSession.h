//
//  UDPSession.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/19.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef UDPSession_h
#define UDPSession_h
#endif /* UDPSession_h */

#import "GCDAsyncUdpSocket.h"

@interface UDPSession : NSObject
@property (nonatomic) NSString* sourceIP;
@property (nonatomic) uint16_t sourcePort;
@property (nonatomic) NSString* destIP;
@property (nonatomic) uint16_t destPort;
@property (nonatomic) NSTimeInterval* timeout;
@property (nonatomic) NSError* error;
-(instancetype)init:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort timeout:(NSTimeInterval*)timeout;
-(void)write:(NSData*)data;
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address;
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error;
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext;
@end
