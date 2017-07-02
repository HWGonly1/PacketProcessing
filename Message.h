//
//  Message.h
//  PacketProcessing
//
//  Created by HWG on 2017/6/26.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef Message_h
#define Message_h
#endif /* Message_h */

@interface  Message : NSObject
-(instancetype)init:(bool)keepingAlive;
+(Message*)shareInstance;
-(NSMutableData*)responseData;
-(bool)initialRegister:(NSString*)version enterpriseID:(long long int)enterpriseID employeeID:(long long int)employeeID IDFV:(NSString*)IDFV;
-(void)keepAlive;
-(void)errorSend:(short)code;
- (void)startLoop;
- (void)loopMethod;
@end
