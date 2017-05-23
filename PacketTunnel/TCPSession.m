//
//  TCPSession.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/20.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPSession.h"
#import "GCDAsyncSocket.h"
#import "IPv4Header.h"
#import "TCPHeader.h"
#import "SessionManager.h"
#import "TCPPacketFactory.h"
@interface TCPSession () <GCDAsyncSocketDelegate>
@property (nonatomic) GCDAsyncSocket* tcpSocket;
@end

@implementation TCPSession
-(instancetype)init:(NSString*)ip port:(uint16_t)port srcIp:(NSString*)srcIp srcPort:(uint16_t)srcPort{
    //NSString* key=[NSString stringWithFormat:@"%@:%d-%@:%d",srcIp,srcPort,ip,port];
    TCPSession* session=[[TCPSession alloc]init];
    [session setDestIP:ip];
    [session setDestPort:port];
    [session setSourceIP:srcIp];
    [session setSourcePort:srcPort];
    [session setConnected:true];
    self.tcpSocket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:[SessionManager sharedInstance].globalQueue];
    [self.tcpSocket connectToHost:ip onPort:port error:nil];
    
    return session;
}

-(void)write:(NSData*)data{
    [self.tcpSocket writeData:data withTimeout:30 tag:0];
}

-(void)close{
    [self.tcpSocket disconnect];
}

-(void)decreaseAmountSentSinceLastAck:(int)amount{
    @synchronized (self.syncSendAmount) {
        self.sendAmountSinceLastAck-=amount;
        if(self.sendAmountSinceLastAck<0){
            self.sendAmountSinceLastAck=0;
        }
    }
}

@end
