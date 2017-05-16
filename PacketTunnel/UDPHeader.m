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
-(int)getsourcePort{
    return self.sourcePort;
}
-(int)getdestinationPort{
    return self.destinationPort;
}
-(int)getlength{
    return self.length;
}
-(int)getchecksum{
    return self.checksum;
}

@end
