//
//  Message.m
//  PacketProcessing
//
//  Created by HWG on 2017/6/26.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Message.h"

@interface Message () <NSURLSessionDataDelegate>
@property (nonatomic,strong) NSMutableData* responseData;
@property (nonatomic) bool keepingAlive;
@end

@implementation Message

-(instancetype)init:(bool)keepingAlive{
    _responseData=[NSMutableData data];
    _keepingAlive=keepingAlive;
    return self;
}

+(Message*)shareInstance{
    static dispatch_once_t onceToken;
    static Message* message;
    dispatch_once(&onceToken, ^{
        message = [Message new];
    });
    return message;
}

-(NSMutableData*)responseData{
    if(_responseData==nil){
        _responseData=[NSMutableData data];
    }
    return _responseData;
}

-(bool)initialRegister:(NSString*)version enterpriseID:(long long int)enterpriseID employeeID:(long long int)employeeID IDFV:(NSString*)IDFV{
    NSURL* url=[NSURL URLWithString:@""];
    NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:5000];
    request.HTTPMethod=@"POST";
    [request addValue:@"1.0" forHTTPHeaderField:@"version"];
    [request addValue:@"1" forHTTPHeaderField:@"type"];
    
    NSString* bodyStr=[NSString stringWithFormat:@"os type=%d&os version=%@&enterprise ID=%lld&user ID=%lld&MAgent ID=%@",1,version,enterpriseID,employeeID,IDFV];
    NSData* body=[bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody=body;
    [request addValue:[NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:[body length]]] forHTTPHeaderField:@"length"];
    
    
    NSURLSession* session=[NSURLSession sharedSession];
    NSURLSessionDataTask* task=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* res=(NSHTTPURLResponse*)response;
        NSArray* array=[[res allHeaderFields] allKeys];
        NSString* replyBody=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if([array containsObject:@"type"]&&[[[res allHeaderFields] objectForKey:@"type"] isEqualToNumber:[NSNumber numberWithShort:0x0002]]){
            if([replyBody containsString:@"is_connected=true"]){
                //注册成功处理
                _keepingAlive=true;
            }
            else if([replyBody containsString:@"is_connected=false"]){
                //暂时不知道是什么
            }
            else{
                [self errorSend:(short)2];
            }
        }else if([array containsObject:@"type"]&&[[[res allHeaderFields] objectForKey:@"type"] isEqualToNumber:[NSNumber numberWithShort:0x0005]]){
            if([replyBody containsString:@"error_type=1"]){
                //注册错误，提示重新注册
            }
            else{
                [self errorSend:(short)5];
            }
        }else{
            [self errorSend:(short)2];
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
    if(_keepingAlive)
        return true;
    return false;
}

-(void)keepAlive{
    if(self.keepingAlive){
        _keepingAlive=false;
        NSURL* url=[NSURL URLWithString:@""];
        NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:url];
        [request setTimeoutInterval:5000];
        request.HTTPMethod=@"POST";
        [request addValue:@"1.0" forHTTPHeaderField:@"version"];
        [request addValue:@"3" forHTTPHeaderField:@"type"];
        
        int time=[[NSDate date] timeIntervalSince1970];
        NSString* bodyStr=[NSString stringWithFormat:@"time:%d",time];
        NSData* body=[bodyStr dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody=body;
        [request addValue:[NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:[body length]]] forHTTPHeaderField:@"length"];
        
        
        NSURLSession* session=[NSURLSession sharedSession];
        NSURLSessionDataTask* task=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse* res=(NSHTTPURLResponse*)response;
            NSArray* array=[[res allHeaderFields] allKeys];
            NSString* replyBody=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if([array containsObject:@"type"]&&[[[res allHeaderFields] objectForKey:@"type"] isEqualToNumber:[NSNumber numberWithShort:0x0004]]){
                if([replyBody containsString:@"is_connected=true"]&&[replyBody containsString:@"the URL is="]&&[replyBody containsString:@"URL="]){
                    //保活成功，识别关键字，记录策略包url
                    unsigned long start=[replyBody rangeOfString:@"the URL is="].location+[replyBody rangeOfString:@"the URL is="].length;
                    unsigned long end=[replyBody rangeOfString:@"&URL="].location;
                    NSString* flag=[replyBody substringWithRange:NSMakeRange(start, end-start)];
                    if([flag isEqualToString:@""]){
                        _keepingAlive=true;
                        
                    }
                    else{
                        [self errorSend:(short)4];
                    }
                }else if([replyBody containsString:@"is_connected=false"]&&[replyBody containsString:@"the URL is="]&&[replyBody containsString:@"URL="]){
                    //可能是服务器判定连接断开？保活失败？
                }else{
                    //错误的服务器保活响应
                    [self errorSend:(short)4];
                }
            }else if([array containsObject:@"type"]&&[[[res allHeaderFields] objectForKey:@"type"] isEqualToNumber:[NSNumber numberWithShort:0x0005]]){
                _keepingAlive=false;
                if([replyBody containsString:@"error_type=3"]){
                    //保活错误响应，重新发送保活信号
                    [self keepAlive];
                }
                else{
                    [self errorSend:(short)5];
                }
            }else{
                [self errorSend:(short)4];
            }
        }];
        [task resume];
        [session finishTasksAndInvalidate];
    }
}

-(void)errorSend:(short)code{
    NSURL* url=[NSURL URLWithString:@""];
    NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:5000];
    request.HTTPMethod=@"POST";
    [request addValue:@"1.0" forHTTPHeaderField:@"version"];
    [request addValue:@"5" forHTTPHeaderField:@"type"];
    
    NSString* bodyStr=[NSString stringWithFormat:@"error_type=%d",code];
    NSData* body=[bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody=body;
    [request addValue:[NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:[body length]]] forHTTPHeaderField:@"length"];
    
    NSURLSession* session=[NSURLSession sharedSession];
    NSURLSessionDataTask* task=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

@end
