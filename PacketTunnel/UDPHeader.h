//
//  UDPHeader.h
//  PacketProcessing
//
//  Created by HWG on 2017/4/26.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef UDPHeader_h
#define UDPHeader_h
#endif /* UDPHeader_h */
@interface UDPHeader : NSObject
@property (nonatomic) int sourcePort;
@property (nonatomic) int destinationPort;
@property (nonatomic) int length;
@property (nonatomic) int checksum;
-(instancetype)init:(NSData *)packet;
-(instancetype)init:(int)srcPort destPort:(int)destPort length:(int)length checksum:(int)checksum;
-(int)getsourcePort;
-(void)setSourcePort:(int)sourcePort;
-(int)getdestinationPort;
-(void)setDestinationPort:(int)destinationPort;
-(int)getlength;
-(void)setLength:(int)length;
-(int)getchecksum;
-(void)setChecksum:(int)checksum;
@end
