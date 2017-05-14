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
@property (nonatomic) Byte dscpOrTypeOfervice;
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
-(Byte)getVersion;
-(Byte)getProtocol;
-(Byte)getinternetHeaderLength;
-(unsigned)getsourceIP;
-(unsigned)getdestinationIP;
-(void)setSourceIP:(unsigned)sourceIP;
-(void)setDestinationIP:(unsigned)destinationIP;
@end
