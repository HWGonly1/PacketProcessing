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
    //[self.udpSocket bindToPort:6790 error:nil];
    [self.udpSocket beginReceiving:nil];
    return self;
}

-(void)write{
    NSString* str=@"Begin UDP";
    NSData* data=[str dataUsingEncoding:NSUTF8StringEncoding];
    NSString* address=@"10.210.66.16";
    uint16_t port=6789;
    
    [self.udpSocket sendData:data toHost:address port:port withTimeout:-1 tag:0];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
}


@end
