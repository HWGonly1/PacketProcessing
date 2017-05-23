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
#import "TCPSession.h"
#import "PacketUtil.h"
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
    self.wormhole=[[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.hwg.PacketProcessing" optionalDirectory:@"VPNStatus"];
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
    [self.wormhole passMessageObject:[NSString stringWithFormat:@"%@:%d-%@:%d",sourceIP,sourcePort,destIP,destPort] identifier:@"VPNStatus"];
    @synchronized (self.udpdict) {
        [self.udpdict setValue:[[UDPSession alloc] init:sourceIP sourcePort:sourcePort destIP:destIP destPort:destPort timeout:30] forKey:[NSString stringWithFormat:@"%@:%d-%@:%d",sourceIP,sourcePort,destIP,destPort]];
    }
}

-(bool)existUDPSession:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort{
    return [[self.udpdict allKeys]containsObject:[NSString stringWithFormat:@"%@:%d-%@:%d",sourceIP,sourcePort,destIP,destPort]];
}

-(UDPSession*)getUDPSession:(NSString*)sourceIP sourcePort:(uint16_t)sourcePort destIP:(NSString*)destIP destPort:(uint16_t)destPort{
    return [self.udpdict objectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",sourceIP,sourcePort,destIP,destPort]];
}

-(TCPSession*)createNewSession:(int)ip port:(int)port srcIp:(int)srcIp srcPort:(int)srcPort{
    NSString* key=[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:srcIp],srcPort,[PacketUtil intToIPAddress:ip],port];
    bool found=false;
    @synchronized ([SessionManager sharedInstance].tcpdict) {
        found=[[[SessionManager sharedInstance].tcpdict allKeys]containsObject:key];
    }
    if(found){
        return nil;
    }
    TCPSession* session=[[TCPSession alloc]init:[PacketUtil intToIPAddress:ip] port:port srcIp:[PacketUtil intToIPAddress:srcIp] srcPort:srcPort];
    @synchronized ([SessionManager sharedInstance].tcpdict) {
        if(![[[SessionManager sharedInstance].tcpdict allKeys]containsObject:key]){
            [[SessionManager sharedInstance].tcpdict setValue:session forKey:[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:srcIp],srcPort,[PacketUtil intToIPAddress:ip],port]];
        }
        else{
            found=true;
        }
    }
    if(found){
        session=nil;
    }
    return session;
}

-(bool)existTCPSession:(int)ip port:(int)port srcIp:(int)srcIp srcPort:(int)srcPort{
    return [[self.tcpdict allKeys]containsObject:[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:srcIp],srcPort,[PacketUtil intToIPAddress:ip],port]];
}

-(int)addClientData:(IPv4Header*)ip tcp:(TCPHeader*)tcp buffer:(NSMutableArray*)buffer{
    TCPSession* session=[[SessionManager sharedInstance].tcpdict objectForKey:[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:[ip getsourceIP]],[tcp getSourcePort],[PacketUtil intToIPAddress:[ip getdestinationIP]],[tcp getdestinationPort]]];
    int len=0;
    if([session recSequence]!=0&&[tcp getSequenceNumber]<[session recSequence]){
        return len;
    }
    int start=[ip getIPHeaderLength]+[tcp getTCPHeaderLength];
    len=[buffer count]-start;
    Byte array[len];
    for(int i=start;i<[buffer count];i++){
        array[i-start]=(Byte)[buffer[i] shortValue];
    }
    NSData* data=[NSData dataWithBytes:array length:len];
    [session write:data];
    return len;
}

-(void)closeSession:(int)ip port:(int)port srcIp:(int)srcIp srcPort:(int)srcPort{
    NSString* keys=[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:srcIp],srcPort,[PacketUtil intToIPAddress:ip],port];
    @synchronized ([SessionManager sharedInstance].tcpdict) {
        TCPSession* session=[[SessionManager sharedInstance].tcpdict objectForKey:keys];
        [[SessionManager sharedInstance].tcpdict removeObjectForKey:keys];
        [session close];
        session=nil;
    }
}

-(void)closeSession:(TCPSession*)session{
    if(session==nil){
        return;
    }
    NSString* keys=[NSString stringWithFormat:@"%@:%d-%@:%d",[session sourceIP],[session sourcePort],[session destIP],[session destPort]];
    @synchronized ([SessionManager sharedInstance].tcpdict) {
        TCPSession* session=[[SessionManager sharedInstance].tcpdict objectForKey:keys];
        [[SessionManager sharedInstance].tcpdict removeObjectForKey:keys];
        [session close];
        session=nil;
    }
}

/*
-(void)addTCPSession:(int)ip port:(int)port srcIp:(int)srcIp srcPort:(int)srcPort{
    NSString* key=[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:srcIp],srcPort,[PacketUtil intToIPAddress:ip],port];
    bool found=false;
    @synchronized ([SessionManager sharedInstance].tcpdict) {
        found=[[[SessionManager sharedInstance].tcpdict allKeys]containsObject:key];
    }
    if(found){
        return;
    }
    TCPSession* session=[[TCPSession alloc]init:[PacketUtil intToIPAddress:ip] port:port srcIp:[PacketUtil intToIPAddress:srcIp] srcPort:srcPort];
    @synchronized ([SessionManager sharedInstance].tcpdict) {
        if(![[[SessionManager sharedInstance].tcpdict allKeys]containsObject:key]){
            [[SessionManager sharedInstance].tcpdict setValue:session forKey:[NSString stringWithFormat:@"%@:%d-%@:%d",[PacketUtil intToIPAddress:srcIp],srcPort,[PacketUtil intToIPAddress:ip],port]];
        }
        else{
            found=true;
        }
    }
    return;
}
*/
@end




























