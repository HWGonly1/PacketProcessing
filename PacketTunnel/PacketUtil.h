//
//  PacketUtil.h
//  PacketProcessing
//
//  Created by HWG on 2017/5/15.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef PacketUtil_h
#define PacketUtil_h
#endif /* PacketUtil_h */
volatile static bool enabledDebugLog;
volatile static int packetid;
static NSObject *syncObj;
@interface PacketUtil : NSObject{
    NSCondition * condition;
}
@end
