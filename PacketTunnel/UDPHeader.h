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
@property (nonatomic) unsigned sourcePort;
@property (nonatomic) unsigned destinationPort;
@property (nonatomic) unsigned length;
@property (nonatomic) unsigned checksum;
-(instancetype)init:(NSData *)packet;
-(unsigned)getsourcePort;
-(unsigned)getdestinationPort;
-(unsigned)getlength;
-(unsigned)getchecksum;
@end
