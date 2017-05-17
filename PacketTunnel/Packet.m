//
//  Packet.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/17.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Packet.h"

@implementation Packet

-(IPv4Header *)getIpheader{
    return self.ipheader;
}

-(void)setIpheader:(IPv4Header *)ipheader{
    self.ipheader=ipheader;
}

-(TCPHeader *)getTcpheader{
    return self.tcpheader;
}

-(void)setTcpheader:(TCPHeader *)tcpheader{
    self.tcpheader=tcpheader;
}

-(Byte *)getBuffer{
    return self.buffer;
}

-(void)setBuffer:(Byte *)buffer bufferLength:(int)bufferLength{
    self.buffer=buffer;
    self.bufferLength=bufferLength;
}

-(int)getBufferLength{
    return self.bufferLength;
}

-(int)getPacketodyLength{
    if(self.bufferLength>0){
        int offset=self.tcpheader.getTCPHeaderLength-self.ipheader.getIPHeaderLength;
        int len=self.bufferLength-offset;
        return len;
    }
    return 0;
}

-(Byte *)getPacketBody{
    if(self.bufferLength>0){
        int offset=self.tcpheader.getTCPHeaderLength-self.ipheader.getIPHeaderLength;
        int len=self.bufferLength-offset;
        if(len>0){
            Byte data[len];
            memccpy(data, self.buffer, 0,len);
            return data;
        }
    }
    static Byte zero[0];
    return zero;
}

@end
