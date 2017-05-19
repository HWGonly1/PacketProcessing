//
//  SessionManager.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/19.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionManager.h"
#import "UDPSession.h"
@implementation SessionManager

+(SessionManager*)sharedInstance{
    static dispatch_once_t onceToken;
    static SessionManager* sessionmanager;
    dispatch_once(&onceToken, ^{
        sessionmanager = [SessionManager new];
    });
    return sessionmanager;
}

-(instancetype)init{
    self = [super init];
    self.tcpdict=[[NSMutableDictionary alloc]init];
    self.udpdict=[[NSMutableDictionary alloc]init];
    self.globalQueue= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return self;
}

+ (void)setupWithPacketTunnelFlow:(NEPacketTunnelFlow *)packetFlow {
    [SessionManager sharedInstance].packetFlow = packetFlow;
}

-(void)addUDPSession:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort{
    @synchronized (self.udpdict) {
        [self.udpdict setValue:[[UDPSession alloc] init:sourceIP sourcePort:sourcePort destIP:destIP destPort:destPort timeout:30] forKey:[NSString stringWithFormat:@"%@:%d-%@:%d",sourceIP,sourcePort,destIP,destPort]];
    }
}

-(UDPSession*)getUDPSocket:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort{
    return [self.udpdict objectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",sourceIP,sourcePort,destIP,destPort]];
}

@end
