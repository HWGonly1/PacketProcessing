//
//  IPPacketFactory.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/14.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef IPPacketFactory_h
#define IPPacketFactory_h
#endif /* IPPacketFactory_h */
#import "IPv4Header.h"
@interface IPPacketFactory : NSObject 
+(IPv4Header *)copyIPv4Header:(IPv4Header*)ipheader;
+(NSMutableArray *)createIPv4Header:(IPv4Header*)header;
+(IPv4Header *)createIPv4Header:(NSMutableArray *)buffer start:(int)start;
@end
