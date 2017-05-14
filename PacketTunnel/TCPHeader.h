//
//  TCPHeader.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/10.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef TCPHeader_h
#define TCPHeader_h
#endif /* TCPHeader_h */
@interface TCPHeader : NSObject
@property (nonatomic) unsigned sourcePort;
@property (nonatomic) unsigned destinationPort;
@property (nonatomic) unsigned sequenceNumber;;
@property (nonatomic) unsigned dataOffset;
@property (nonatomic) unsigned tcpFlags;
@property (nonatomic) bool isns;
@property (nonatomic) bool iscwr;
@property (nonatomic) bool isece;
@property (nonatomic) bool issyn;
@property (nonatomic) bool isack;
@property (nonatomic) bool isfin;
@property (nonatomic) bool isrst;
@property (nonatomic) bool ispsh;
@property (nonatomic) bool isurg;
@property (nonatomic) unsigned windowSize;
@property (nonatomic) unsigned checksum;
@property (nonatomic) unsigned urgentPointer;
@property (nonatomic) Byte * options;
@property (nonatomic) unsigned ackNum;
@property (nonatomic) int maxSegmentSize;
@property (nonatomic) int windowScale;
@property (nonatomic) bool isSelectiveAckPermitted;
@property (nonatomic) int timeStampSender;
@property (nonatomic) int timeStampReplyTo;
-(instancetype)init:(NSData*)packet;
-(instancetype)init:(unsigned)sourcePort destinationPort:(unsigned)destinationPort sequenceNumber:(unsigned)sequenceNumber dataOffset:(unsigned)dataOffset isns:(bool)isns tcpFlags:(unsigned)tcpFlags windowSize:(unsigned)windowSize checksum:(unsigned)checksum urgentPointer:(unsigned)urgentPointer options:(Byte *)options ackNum:(unsigned)ackNum;
-(void)setFlagBits;
-(bool)isNS;
-(void)setIsNS:(bool)isns;
-(bool)isCWR;
-(void)setIsCWR:(bool)iscwr;
-(bool)isece;
-(void)setIsECE:(bool)isece;
-(bool)isurg;
-(void)setIsURG:(bool)isurg;
-(bool)isack;
-(void)setIsACK:(bool)isack;
-(bool)ispsh;
-(void)setIsPSH:(bool)ispsh;
-(bool)isrst;
-(void)setIsRST:(bool)isrst;
-(bool)issyn;
-(void)setIsSYN:(bool)issyn;
-(bool)isfin;
-(void)setIsFIN:(bool)isfin;
-(unsigned)getSourcePort;
-(void)setSourcePort:(unsigned)sourcePort;
-(unsigned)getdestinationPort;
-(void)setDestinationPort:(unsigned)destinationPort;
-(unsigned)getSequenceNumber;
-(void)setSequenceNumber:(unsigned)sequenceNumber;
-(unsigned)getdataOffset;
-(void)setDataOffset:(unsigned)dataOffset;
-(unsigned)getTCPFlags;
-(void)setTCPFlags:(unsigned)tcpFlags;
-(unsigned)getWindowSize;
-(void)setWindowSize:(unsigned)windowSize;
-(unsigned)getChecksum;
-(void)setChecksum:(unsigned)checksum;
-(unsigned)getUrgentPointer;
-(void)setUrgentPointer:(unsigned)urgentPointer;
-(Byte *)getOptions;
-(void)setOptions:(Byte *)options;
-(unsigned)getAckNumber;
-(void)setAckNumber:(unsigned)ackNum;
-(int)getTCPHeaderLength;
-(int)getMexSegmentSize;
-(void)setMaxSegmentSize:(int)maxSegmentSize;
-(int)getWindowScale;
-(void)setWindowScale:(int)windowScale;
-(bool)isSelectiveAckPermitted;
-(void)setIsSelectiveAckPermitted:(bool)isSelectiveAckPermitted;
-(int)getTimestampSender;
-(void)setTimeStampSender:(int)timeStampSender;
-(int)getTimestampReplyTo;
-(void)setTimeStampReplyTo:(int)timeStampReplyTo;
@end
