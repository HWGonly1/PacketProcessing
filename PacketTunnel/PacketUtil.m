//
//  PacketUtil.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/15.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PacketUtil.h"

@implementation PacketUtil

+(int)getPacketId{
    int id;
    @synchronized (syncObj) {
        id=packetid++;
    }
    return id;
}

+(bool)isEnabledDebugLog{
    return enabledDebugLog;
}

+(void)setEnabledDebugLog{
    enabledDebugLog=true;
}

+(void)Debug:(NSString*)str{
    NSLog(@"%@", str);
}

+(void)writeIntToBytes:(int)value buffer:(Byte[])buffer offset:(int)offset{
    /*
    if(sizeof(buffer)/sizeof(Byte)-offset<4){
        return;
    }
     */
    buffer[offset]=(Byte)((value>>24)&0x000000FF);
    buffer[offset+1]=(Byte)((value>>16)&0x000000FF);
    buffer[offset+2]=(Byte)((value>>8)&0x000000FF);
    buffer[offset+3]=(Byte)(value&0x000000FF);
}

+(void)writeShortToBytes:(short)value buffer:(Byte[])buffer offset:(int)offset{
    buffer[offset]=(Byte)((value>>8)&0x00FF);
    buffer[offset+1]=(Byte)(value&0x00FF);
}

+(short)getNetworkShort:(Byte[])buffer start:(int)start{
    short value=0x0000;
    value |= buffer[start]&0xFF;
    value <<= 8;
    value |= buffer[start+1]&0xFF;
    return value;
}

+(int)getNetworkInt:(Byte[])buffer start:(int)start length:(int)length{
    int value=0x00000000;
    int end= start+(length>4?4:length);
    /*
    if(end>(sizeof(buffer)/sizeof(Byte))){
        end=sizeof(buffer)/sizeof(Byte);
    }
     */
    for(int i=start;i<end;i++){
        value |= buffer[i]&0xFF;
        if(i<(end-1)){
            value<<=8;
        }
    }
    return value;
}

@end





















