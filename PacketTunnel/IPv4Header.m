//
//  PacketHeader.m
//  PacketProcessing
//
//  Created by HWG on 2017/4/26.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPv4Header.h"

@implementation IPv4Header

-(instancetype)init:(NSData *)packet{
    Byte * data=(Byte *)packet.bytes;
    self.ipVersion=data[0]>>4;
    self.internetHeaderLength=data[0]&0x0F;
    self.dscpOrTypeOfService=data[1]>>2;
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
        Byte array[optionLength];
        for(int i=0;i<optionLength;i++){
            array[i]=data[20+i];
        }
        self.optionBytes=array;
    }
    return self;
}

-(instancetype)init:(Byte)ipVersion internetHeaderLength:(Byte)internetHeaderLength dscpOrTypeOfService:(Byte)dscpOrTypeOfService ecn:(Byte)ecn totalLength:(unsigned)totalLength identification:(unsigned)identification mayFragment:(bool)mayFragment lastFragment:(bool)lastFrament fragmentOffset:(short)fragmentOffset timeToLive:(Byte)timeToLive protocol:(Byte)protocol headerChecksum:(unsigned)headerChecksum sourceIP:(unsigned)sourceIP destinationIP:(unsigned)destinationIP optionBytes:(Byte *)optionBytes{
    self.ipVersion=ipVersion;
    self.internetHeaderLength=internetHeaderLength;
    self.dscpOrTypeOfService=dscpOrTypeOfService;
    self.ecn=ecn;
    self.totalLength=totalLength;
    self.identification=identification;
    self.mayFragment=mayFragment;
    if(mayFragment){
        self.flag |= 0x40;
    }
    self.lastFragment=lastFrament;
    if(lastFrament){
        self.flag |=0x20;
    }
    self.fragmentOffset=fragmentOffset;
    self.timeToLive=timeToLive;
    self.protocol=protocol;
    self.headerChecksum=headerChecksum;
    self.sourceIP=sourceIP;
    self.destinationIP=destinationIP;
    self.optionBytes=optionBytes;
    return self;
}

-(Byte)getIPVersion{
    return self.ipVersion;
}

-(Byte)getInternetHeaderLength{
    return self.internetHeaderLength;
}

-(Byte)getDscpOrTypeOfService{
    return self.dscpOrTypeOfService;
}

-(Byte)getEcn{
    return self.ecn;
}

-(unsigned)getTotalLength{
    return self.totalLength;
}

-(unsigned)getIPHeaderLength{
    return self.internetHeaderLength*4;
}

-(unsigned)getIdentification{
    return self.identification;
}

-(Byte)getFlag{
    return self.flag;
}

-(bool)isMayFragment{
    return self.mayFragment;
}

-(bool)isLastFragment{
    return self.lastFragment;
}

-(short)getFragmentOffset{
    return self.fragmentOffset;
}

-(Byte)getTimeToLive{
    return self.timeToLive;
}

-(Byte)getProtocol{
    return self.protocol;
}

-(unsigned)getHeaderCheckSum{
    return self.headerChecksum;
}

-(unsigned)getsourceIP{
    return self.sourceIP;
}
-(unsigned)getdestinationIP{
    return self.destinationIP;
}

-(Byte *)getOptionBytes{
    return self.optionBytes;
}

-(void)setInternetHeaderLength:(Byte)internetHeaderLength{
    self.internetHeaderLength=internetHeaderLength;
}

-(void)setDscpOrTypeOfService:(Byte)dscpOrTypeOfService{
    self.dscpOrTypeOfService=dscpOrTypeOfService;
}

-(void)setEcn:(Byte)ecn{
    self.ecn=ecn;
}

-(void)setTotalLength:(unsigned)totalLength{
    self.totalLength=totalLength;
}

-(void)setIdentification:(unsigned)identification{
    self.identification=identification;
}

-(void)setFlag:(Byte)flag{
    self.flag=flag;
}

-(void)setMayFragment:(Boolean)mayFragment{
    self.mayFragment=mayFragment;
    if(mayFragment){
        self.flag |= 0x40;
    }else{
        self.flag &= 0xBF;
    }
}

-(void)setLastFragment:(Boolean)lastFragment{
    self.lastFragment=lastFragment;
    if(lastFragment){
        self.flag |= 0x20;
    }else{
        self.flag &= 0xDF;
    }
}

-(void)setFragmentOffset:(short)fragmentOffset{
    self.fragmentOffset=fragmentOffset;
}

-(void)setTimeToLive:(Byte)timeToLive{
    self.timeToLive=timeToLive;
}

-(void)setProtocol:(Byte)protocol{
    self.protocol=protocol;
}

-(void)setHeaderChecksum:(unsigned)headerChecksum{
    self.headerChecksum=headerChecksum;
}

-(void)setSourceIP:(unsigned)sourceIP{
    self.sourceIP=sourceIP;
}
-(void)setDestinationIP:(unsigned)destinationIP{
    self.destinationIP=destinationIP;
}

-(void)setOptionBytes:(Byte *)optionBytes{
    self.optionBytes=optionBytes;
}
@end
