//
//  TCPSession.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/20.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef TCPSession_h
#define TCPSession_h
#endif /* TCPSession_h */
#import "IPv4Header.h"
#import "TCPHeader.h"
#import "GCDAsyncSocket.h"
@interface TCPSession : NSObject
@property (nonatomic) NSObject* syncSendAmount;
@property (nonatomic) NSString* sourceIP;
@property (nonatomic) uint16_t sourcePort;
@property (nonatomic) NSString* destIP;
@property (nonatomic) uint16_t destPort;
@property (nonatomic) bool connected;
@property (nonatomic) bool closingConnection;
@property (nonatomic) bool packetCorrupted;
@property (nonatomic) bool isacked;
@property (nonatomic) bool ackedToFin;
@property (nonatomic) bool abortingConnection;
@property (nonatomic) bool hasReceivedLastSegment;
@property (nonatomic) bool isDataForSendingReady;
@property (nonatomic) int sendNext;
@property (nonatomic) int sendWindow;
@property (nonatomic) int sendWindowSize;
@property (nonatomic) int sendWindowScale;
@property (nonatomic) int maxSegmentSize;
@property (nonatomic) int sendUnack;
@property (nonatomic) int recSequence;
@property (nonatomic) IPv4Header* lastIPheader;
@property (nonatomic) TCPHeader* lastTCPheader;
@property (nonatomic) int timestampSender;
@property (nonatomic) int timestampReplyto;
@property (nonatomic) int sendAmountSinceLastAck;
@property (nonatomic) NSMutableData* unackData;
@property (nonatomic) int resendPacketCounter;
@property (nonatomic) int count;
-(instancetype)init:(NSString*)ip port:(uint16_t)port srcIp:(NSString*)srcIp srcPort:(uint16_t)srcPort;
-(void)write:(NSData*)data;
-(void)close;
-(void)decreaseAmountSentSinceLastAck:(int)amount;
-(bool)isClientWindowFull;
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag;
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
-(void)setSendingData:(NSData*)data;
@end
