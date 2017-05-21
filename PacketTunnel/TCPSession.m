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



@end

@implementation TCPSession
+(void)replySynAck:(IPv4Header*)ip tcp:(TCPHeader*)tcp{
    [ip setIdentification:0];
    Packet* packet=[TCPPacketFactory createSynAckPacketData:ip tcp:tcp];
    TCPHeader* tcpheader=[packet getTcpheader];
    Session session = sdata.createNewSession(ip.getDestinationIP(), tcp.getDestinationPort(),
                                             ip.getSourceIP(), tcp.getSourcePort());
    if(session == null){
        return;
    }
    
}


@end
