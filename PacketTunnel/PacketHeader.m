//
//  PacketHeader.m
//  PacketProcessing
//
//  Created by HWG on 2017/4/26.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PacketHeader.h"

@interface ip_hdr : NSObject
@property (nonatomic) uint8_t ipVersion;
@property (nonatomic) uint8_t internetHeaderLength;
@property (nonatomic) uint8_t dscpOrTypeOfervice;
@property (nonatomic) uint8_t ecn;
@property (nonatomic) uint32_t totalLength;
@property (nonatomic) uint32_t identification;
@property (nonatomic) uint8_t flag;
@property (nonatomic) Boolean mayFragment;
@property (nonatomic) Boolean lastFragment;
@property (nonatomic) uint16_t fragmentOffset;
@property (nonatomic) uint8_t timeToLive;
@property (nonatomic) uint8_t protocol;
@property (nonatomic) uint32_t headerChecksum;
@property (nonatomic) uint32_t sourceIP;
@property (nonatomic) uint32_t destinationIP;
@property (nonatomic) uint8_t * optionBytes;
@end

@implementation ip_hdr

-(instancetype)init:(NSData *)packet{
    uint8_t * data=(uint8_t *)packet.bytes;
    self.ipVersion=data[0]>>4;
    self.internetHeaderLength=data[0]&0x0F;
    self.dscpOrTypeOfervice=data[1]>>2;
    self.ecn=data[1]&0x03;
    
    self.totalLength=0;
    self.totalLength|=data[2]&0xFF;
    self.totalLength<<=8;
    self.totalLength|=data[3]&0xFF;
    
    self.identification=0;
    self.identification|=data[4]&0xFF;
    self.identification<<=8;
    self.identification|=data[5]&0xFF;

    self.flag=data[6];
    self.mayFragment=(self.flag&0x40)>0x00;
    self.lastFragment=(self.flag&0x20)>0x00;
    
    self.fragmentOffset=0;
    self.fragmentOffset|=data[6]&0xFF;
    self.fragmentOffset<<=8;
    self.fragmentOffset|=data[7]&0xFF;
    self.fragmentOffset&=0x1FFFF;
    
    self.timeToLive=data[8];
    self.protocol=data[9];
    
    self.headerChecksum=0;
    self.headerChecksum|=data[10]&0xFF;
    self.headerChecksum<<=8;
    self.fragmentOffset|=data[11]&0xFF;
    
    self.sourceIP=0;
    self.sourceIP|=data[12]&0xFF;
    self.sourceIP<<=8;
    self.sourceIP|=data[13]&0xFF;
    self.sourceIP<<=8;
    self.sourceIP|=data[14]&0xFF;
    self.sourceIP<<=8;
    self.sourceIP|=data[15]&0xFF;
    
    self.destinationIP=0;
    self.destinationIP|=data[16]&0xFF;
    self.destinationIP<<=8;
    self.destinationIP|=data[17]&0xFF;
    self.destinationIP<<=8;
    self.destinationIP|=data[18]&0xFF;
    self.destinationIP<<=8;
    self.destinationIP|=data[19]&0xFF;
    
    self.optionBytes=NULL;
    
    if(self.internetHeaderLength==5){
    }
    else{
        int optionLength=(self.internetHeaderLength-5)*4;
        uint8_t array[optionLength];
        for(int i=0;i<optionLength;i++){
            array[i]=data[20+i];
        }
        self.optionBytes=array;
    }
    return self;
}

-(uint8_t)getVersion{
    return self.ipVersion;
}

-(uint8_t)getProtocol{
    return self.protocol;
}

@end
