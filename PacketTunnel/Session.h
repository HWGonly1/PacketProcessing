
//
//  Session.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/18.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef Session_h
#define Session_h
#endif /* Session_h */
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "IPv4Header.h"
#import "TCPHeader.h"
#import "UDPHeader.h"
@interface Session : NSObject
@property (nonatomic) NSObject* syncReceive;
@property (nonatomic) NSObject* syncSend;
@property (nonatomic) NSObject* syncSendAmount;
@property (nonatomic) NSObject* syncLastHeader;
@property (nonatomic) GCDAsyncSocket* socketchannel;
@property (nonatomic) GCDAsyncUdpSocket* udpchannel;
@property (nonatomic) int destAddress;
@property (nonatomic) int destPort;
@property (nonatomic) int sourceIp;
@property (nonatomic) int sourcePort;
@property (nonatomic) int recSequence;
@property (nonatomic) int sendUnack;
@property (nonatomic) bool isacked;
@property (nonatomic) int sendNext;
@property (nonatomic) int sendWindow;
@property (nonatomic) int sendWindowSize;
@property (nonatomic) int sendWindowScale;
@property (nonatomic) int sendAmountSinceLastAck;
@property (nonatomic) int maxSegmentSize;
@property (nonatomic) bool isConnected;
@property (nonatomic) NSStream* receivingStream;
@property (nonatomic) NSStream* sendingStream;
@property (nonatomic) bool hasReceivedLastSegment;
@property (nonatomic) IPv4Header* lastIPheader;
@property (nonatomic) TCPHeader* lastTCPheader;
@property (nonatomic) UDPHeader* lastUDPheader;
@property (nonatomic) bool closingConnection;
@property (nonatomic) bool isDataForSendingReady;
@property (nonatomic) NSMutableArray* unackData;
@property (nonatomic) bool packetCorrupted;
@property (nonatomic) int resendPacketCounter;
@property (nonatomic) int timestampSender;
@property (nonatomic) int timestampReplyto;
@property (nonatomic) bool ackedToFin;
@property (nonatomic) long ackedToFinTime;
@property (nonatomic) bool isbusyread;
@property (nonatomic) bool isbusywrite;
@property (nonatomic) bool abortingConnection;
@property (nonatomic) long connectionStartTime;

-(instancetype)init;


@end





































