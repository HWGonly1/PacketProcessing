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

@interface ip_hdr : NSObject
@property (nonatomic) uint8_t ipVersion;
@property (nonatomic) uint8_t internetHeaderLength;
@property (nonatomic) uint8_t dscpOrTypeOfervice;
@property (nonatomic) uint8_t ecn;
@property (nonatomic) uint32_t totalLength;
@property (nonatomic) uint32_t identification;
@property (nonatomic) uint8_t flag;
@property (nonatomic) Boolean mayFragment;
@property (nonatomic) Boolean lastFragment;
@property (nonatomic) uint16_t fragmentOffset;
@property (nonatomic) uint8_t timeToLive;
@property (nonatomic) uint8_t protocol;
@property (nonatomic) uint32_t headerChecksum;
@property (nonatomic) uint32_t sourceIP;
@property (nonatomic) uint32_t destinationIP;
@property (nonatomic) uint8_t * optionBytes;
-(instancetype)init:(NSData *)packet;
-(uint8_t)getVersion;
-(uint8_t)getProtocol;
@end
