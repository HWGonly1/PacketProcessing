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
@property (nonatomic) unsigned totalLength;
@property (nonatomic) unsigned identification;
@property (nonatomic) Byte flag;
@property (nonatomic) Boolean mayFragment;
@property (nonatomic) Boolean lastFragment;
@property (nonatomic) short fragmentOffset;
@property (nonatomic) Byte timeToLive;
@property (nonatomic) Byte protocol;
@property (nonatomic) unsigned headerChecksum;
@property (nonatomic) unsigned sourceIP;
@property (nonatomic) unsigned destinationIP;
@property (nonatomic) Byte * optionBytes;
-(instancetype)init:(NSData *)packet;
-(instancetype)init:(Byte)ipVersion internetHeaderLength:(Byte)internetHeaderLength dscpOrTypeOfService:(Byte)dscpOrTypeOfService ecn:(Byte)ecn totalLength:(unsigned)totalLength identification:(unsigned)identification mayFragment:(bool)mayFragment lastFragment:(bool)lastFrament fragmentOffset:(short)fragmentOffset timeToLive:(Byte)timeToLive protocol:(Byte)protocol headerChecksum:(unsigned)headerChecksum sourceIP:(unsigned)sourceIP destinationIP:(unsigned)destinationIP optionBytes:(Byte *)optionBytes;
-(Byte)getIPVersion;
-(Byte)getInternetHeaderLength;
-(Byte)getDscpOrTypeOfService;
-(Byte)getEcn;
-(unsigned)getTotalLength;
-(unsigned)getIPHeaderLength;
-(unsigned)getIdentification;
-(Byte)getFlag;
-(bool)isMayFragment;
-(bool)isLastFragment;
-(short)getFragmentOffset;
-(Byte)getTimeToLive;
-(Byte)getProtocol;
-(unsigned)getHeaderCheckSum;
-(unsigned)getsourceIP;
-(unsigned)getdestinationIP;
-(Byte *)getOptionBytes;
-(void)setInternetHeaderLength:(Byte)internetHeaderLength;
-(void)setDscpOrTypeOfService:(Byte)dscpOrTypeOfService;
-(void)setEcn:(Byte)ecn;
-(void)setTotalLength:(unsigned)totalLength;
-(void)setIdentification:(unsigned)identification;
-(void)setFlag:(Byte)flag;
-(void)setMayFragment:(Boolean)mayFragment;
-(void)setLastFragment:(Boolean)lastFragment;
-(void)setFragmentOffset:(short)fragmentOffset;
-(void)setTimeToLive:(Byte)timeToLive;
-(void)setProtocol:(Byte)protocol;
-(void)setHeaderChecksum:(unsigned)headerChecksum;
-(void)setSourceIP:(unsigned)sourceIP;
-(void)setDestinationIP:(unsigned)destinationIP;
-(void)setOptionBytes:(Byte *)optionBytes;
@end
