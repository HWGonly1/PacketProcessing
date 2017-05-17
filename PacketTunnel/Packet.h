//
//  Packet.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/17.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef Packet_h
#define Packet_h
#endif /* Packet_h */
#import "IPv4Header.h"
#import "TCPHeader.h"
@interface Packet : NSObject
@property (nonatomic) IPv4Header * ipheader;
@property (nonatomic) TCPHeader * tcpheader;
@property (nonatomic) NSMutableArray * buffer;
-(IPv4Header *)getIpheader;
-(void)setIpheader:(IPv4Header *)ipheader;
-(TCPHeader *)getTcpheader;
-(void)setTcpheader:(TCPHeader *)tcpheader;
-(NSMutableArray *)getBuffer;
-(void)setBuffer:(NSMutableArray *)buffer;
-(int)getPacketodyLength;
-(NSMutableArray *)getPacketBody;
@end
