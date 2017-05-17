//
//  UDPHeader.m
//  PacketProcessing
//
//  Created by HWG on 2017/4/26.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDPHeader.h"

@implementation UDPHeader
-(instancetype)init:(NSData *)packet{
    Byte * data=(Byte *)packet.bytes;
    
    self.sourcePort=0;
    self.sourcePort|=data[0]&0xFF;
    self.sourcePort<<=8;
    self.sourcePort|=data[1]&0xFF;
    
    self.destinationPort=0;
    self.destinationPort|=data[2]&0xFF;
    self.destinationPort<<=8;
    self.destinationPort|=data[3]&0xFF;
    
    self.length=0;
    self.length|=data[4]&0xFF;
    self.length<<=8;
    self.length|=data[5]&0xFF;
    
    self.checksum=0;
    self.checksum|=data[6]&0xFF;
    self.checksum<<=8;
    self.checksum|=data[7]&0xFF;
    
    return self;
}

-(instancetype)init:(int)srcPort destPort:(int)destPort length:(int)length checksum:(int)checksum{
    self.sourcePort=srcPort;
    self.destinationPort=destPort;
    self.length=length;
    self.checksum=checksum;
    return self;
}

-(int)getsourcePort{
    return self.sourcePort;
}

-(void)setSourcePort:(int)sourcePort{
    _sourcePort=sourcePort;
}

-(int)getdestinationPort{
    return self.destinationPort;
}

-(void)setDestinationPort:(int)destinationPort{
    _destinationPort=destinationPort;
}

-(int)getlength{
    return self.length;
}

-(void)setLength:(int)length{
    _length=length;
}

-(int)getchecksum{
    return self.checksum;
}

-(void)setChecksum:(int)checksum{
    _checksum=checksum;
}

@end
