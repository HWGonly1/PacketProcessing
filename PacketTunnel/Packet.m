//
//  Packet.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/17.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Packet.h"
#import "SessionManager.h"
@implementation Packet

-(IPv4Header *)getIpheader{
    return self.ipheader;
}
/*
-(void)setIpheader:(IPv4Header *)ipheader{
    self.ipheader=ipheader;
}
*/
-(TCPHeader *)getTcpheader{
    return self.tcpheader;
}
/*
-(void)setTcpheader:(TCPHeader *)tcpheader{
    self.tcpheader=tcpheader;
}
*/
-(NSMutableArray *)getBuffer{
    return self.buffer;
}
/*
-(void)setBuffer:(NSMutableArray *)buffer{
    self.buffer=[buffer copy];
}
*/
-(int)getPacketodyLength{
    if([self.buffer count]>0){
        int offset=self.tcpheader.getTCPHeaderLength-self.ipheader.getIPHeaderLength;
        int len=[self.buffer count]-offset;
        return len;
    }
    return 0;
}

-(NSMutableArray *)getPacketBody{
    NSMutableArray* data=[[NSMutableArray alloc] init];
    if([self.buffer count]>0){
        int offset=self.tcpheader.getTCPHeaderLength-self.ipheader.getIPHeaderLength;
        int len=[self.buffer count]-offset;
        if(len>0){
            for(int i=0;i<len;i++){
                [data addObject:self.buffer[i]];
            }
        }
    }
    return data;
}

@end
