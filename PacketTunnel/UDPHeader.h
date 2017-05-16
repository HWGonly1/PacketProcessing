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
-(int)getsourcePort;
-(int)getdestinationPort;
-(int)getlength;
-(int)getchecksum;
@end
