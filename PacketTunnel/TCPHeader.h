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
@property (nonatomic) int sourcePort;
@property (nonatomic) int destinationPort;
@property (nonatomic) int sequenceNumber;;
@property (nonatomic) int dataOffset;
@property (nonatomic) int tcpFlags;
@property (nonatomic) bool isns;
@property (nonatomic) bool iscwr;
@property (nonatomic) bool isece;
@property (nonatomic) bool issyn;
@property (nonatomic) bool isack;
@property (nonatomic) bool isfin;
@property (nonatomic) bool isrst;
@property (nonatomic) bool ispsh;
@property (nonatomic) bool isurg;
@property (nonatomic) int windowSize;
@property (nonatomic) int checksum;
@property (nonatomic) int urgentPointer;
//@property (nonatomic) NSMutableArray * options;
@property (nonatomic) NSMutableData* options;
@property (nonatomic) int ackNum;
@property (nonatomic) int maxSegmentSize;
@property (nonatomic) int windowScale;
@property (nonatomic) bool isSelectiveackPermitted;
@property (nonatomic) int timeStampSender;
@property (nonatomic) int timeStampReplyTo;
-(instancetype)init:(NSData*)packet;
-(instancetype)init:(int)sourcePort destinationPort:(int)destinationPort sequenceNumber:(int)sequenceNumber dataOffset:(int)dataOffset isns:(bool)isns tcpFlags:(int)tcpFlags windowSize:(int)windowSize checksum:(int)checksum urgentPointer:(int)urgentPointer options:(NSMutableData *)options ackNum:(int)ackNum;
-(void)setFlagBits;
//-(bool)isNS;
-(void)setIsNS:(bool)isns;
//-(bool)isCWR;
-(void)setIsCWR:(bool)iscwr;
//-(bool)isece;
-(void)setIsECE:(bool)isece;
//-(bool)isurg;
-(void)setIsURG:(bool)isurg;
//-(bool)isack;
-(void)setIsACK:(bool)isack;
//-(bool)ispsh;
-(void)setIsPSH:(bool)ispsh;
//-(bool)isrst;
-(void)setIsRST:(bool)isrst;
//-(int)issyn;
-(void)setIsSYN:(bool)issyn;
//-(bool)isfin;
-(void)setIsFIN:(bool)isfin;
-(int)getSourcePort;
-(void)setSourcePort:(int)sourcePort;
-(int)getdestinationPort;
-(void)setDestinationPort:(int)destinationPort;
-(int)getSequenceNumber;
-(void)setSequenceNumber:(int)sequenceNumber;
-(int)getdataOffset;
-(void)setDataOffset:(int)dataOffset;
-(int)getTCPFlags;
-(void)setTCPFlags:(int)tcpFlags;
-(int)getWindowSize;
-(void)setWindowSize:(int)windowSize;
-(int)getChecksum;
-(void)setChecksum:(int)checksum;
-(int)getUrgentPointer;
-(void)setUrgentPointer:(int)urgentPointer;
-(NSMutableData *)getOptions;
//-(void)setOptions:(NSMutableArray *)options;
-(void)setOptions:(NSMutableData *)options;
-(int)getAckNumber;
-(void)setAckNumber:(int)ackNum;
-(int)getTCPHeaderLength;
-(int)getMaxSegmentSize;
-(void)setMaxSegmentSize:(int)maxSegmentSize;
-(int)getWindowScale;
-(void)setWindowScale:(int)windowScale;
-(bool)isSelectiveackPermitted;
-(void)setIsSelectiveackPermitted:(bool)isSelectiveackPermitted;
-(int)getTimestampSender;
-(void)setTimeStampSender:(int)timeStampSender;
-(int)getTimestampReplyTo;
-(void)setTimeStampReplyTo:(int)timeStampReplyTo;
@end
