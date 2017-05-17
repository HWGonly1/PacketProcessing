//
//  PakcetHeader.h
//  PacketProcessing
//
//  Created by HWG on 2017/4/26.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef PacketHeader_h
#define PacketHeader_h
#endif /* PacketHeader_h */

@interface IPv4Header : NSObject
@property (nonatomic) Byte ipVersion;
@property (nonatomic) Byte internetHeaderLength;
@property (nonatomic) Byte dscpOrTypeOfService;
@property (nonatomic) Byte ecn;
@property (nonatomic) int totalLength;
@property (nonatomic) int identification;
@property (nonatomic) Byte flag;
@property (nonatomic) bool mayFragment;
@property (nonatomic) bool lastFragment;
@property (nonatomic) short fragmentOffset;
@property (nonatomic) Byte timeToLive;
@property (nonatomic) Byte protocol;
@property (nonatomic) int headerChecksum;
@property (nonatomic) int sourceIP;
@property (nonatomic) int destinationIP;
@property (nonatomic) Byte * optionBytes;
@property (nonatomic) int optionLength;
-(instancetype)init:(NSData *)packet;
-(instancetype)init:(Byte)ipVersion internetHeaderLength:(Byte)internetHeaderLength dscpOrTypeOfService:(Byte)dscpOrTypeOfService ecn:(Byte)ecn totalLength:(int)totalLength identification:(int)identification mayFragment:(bool)mayFragment lastFragment:(bool)lastFrament fragmentOffset:(short)fragmentOffset timeToLive:(Byte)timeToLive protocol:(Byte)protocol headerChecksum:(int)headerChecksum sourceIP:(int)sourceIP destinationIP:(int)destinationIP optionBytes:(Byte *)optionBytes optionLength:(int)optionLength;
-(Byte)getIPVersion;
-(Byte)getInternetHeaderLength;
-(Byte)getDscpOrTypeOfService;
-(Byte)getEcn;
-(int)getTotalLength;
-(int)getIPHeaderLength;
-(int)getIdentification;
-(Byte)getFlag;
-(bool)isMayFragment;
-(bool)isLastFragment;
-(short)getFragmentOffset;
-(Byte)getTimeToLive;
-(Byte)getProtocol;
-(int)getHeaderCheckSum;
-(int)getsourceIP;
-(int)getdestinationIP;
-(Byte *)getOptionBytes;
-(void)setInternetHeaderLength:(Byte)internetHeaderLength;
-(void)setDscpOrTypeOfService:(Byte)dscpOrTypeOfService;
-(void)setEcn:(Byte)ecn;
-(void)setTotalLength:(int)totalLength;
-(void)setIdentification:(int)identification;
-(void)setFlag:(Byte)flag;
-(void)setMayFragment:(bool)mayFragment;
-(void)setLastFragment:(bool)lastFragment;
-(void)setFragmentOffset:(short)fragmentOffset;
-(void)setTimeToLive:(Byte)timeToLive;
-(void)setProtocol:(Byte)protocol;
-(void)setHeaderChecksum:(int)headerChecksum;
-(void)setSourceIP:(int)sourceIP;
-(void)setDestinationIP:(int)destinationIP;
-(void)setOptionBytes:(Byte *)optionBytes;
-(int)getOptionLength;
@end
