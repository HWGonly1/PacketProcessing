//
//  UDPSendTest.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/20.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "UDPSendTest.h"

@interface UDPSendTest () <GCDAsyncUdpSocketDelegate>
@property (nonatomic) GCDAsyncUdpSocket* udpSocket;
@end

@implementation UDPSendTest

-(instancetype)init{
    dispatch_queue_t globalQueue= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.udpSocket=[[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:globalQueue];
    [self.udpSocket bindToPort:6789 error:nil];
    [self.udpSocket beginReceiving:nil];
    return self;
}

-(void)write{
    NSString* str=@"Begin UDP";
    NSString* address=@"192.168.1.100";
    [self.udpSocket sendData:[str dataUsingEncoding:kCFStringEncodingUTF8]] toHost:address port:(uint16_t)6789 withTimeout:3 tag:0];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSLog(@"%@", [[NSString alloc]initWithData:data encoding:kCFStringEncodingUTF8]);
}


@end
