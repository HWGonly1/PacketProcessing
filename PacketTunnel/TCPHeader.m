//
//  TCPHeader.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/10.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPHeader.h"
#import "SessionManager.h"
#import "PacketUtil.h"
@implementation TCPHeader
-(instancetype)init:(NSData*)packet{
    Byte * data=(Byte *)packet.bytes;
    
    self.isns=false;
    
    self.sourcePort=0;
    self.sourcePort|=data[0];
    self.sourcePort<<=8;
    self.sourcePort|=data[1];
    
    self.destinationPort=0;
    self.destinationPort|=data[2];
    self.destinationPort<<=8;
    self.destinationPort|=data[3];

    self.sequenceNumber=0;
    self.sequenceNumber=data[4];
    self.sequenceNumber<<=8;
    self.sequenceNumber=data[5];
    self.sequenceNumber<<=8;
    self.sequenceNumber=data[6];
    self.sequenceNumber<<=8;
    self.sequenceNumber=data[7];
    
    self.ackNum=0;
    self.ackNum=data[8];
    self.ackNum<<=8;
    self.ackNum=data[9];
    self.ackNum<<=8;
    self.ackNum=data[10];
    self.ackNum<<=8;
    self.ackNum=data[11];
    
    self.dataOffset=(data[12]>>4)&0x0F;

    Byte nsbyte=data[12];
    self.isns=(nsbyte&0x1)>0x0;
    
    self.tcpFlags=data[13];
    
    self.windowSize=0;
    self.windowSize=data[14];
    self.windowSize<<=8;
    self.windowSize=data[15];
    
    self.checksum=0;
    self.checksum|=data[16];
    self.checksum<<=8;
    self.checksum|=data[17];
    
    self.urgentPointer=0;
    self.urgentPointer=data[18];
    self.urgentPointer<<=8;
    self.urgentPointer=data[19];
    
    self.options=[[NSMutableData alloc] init];

    if(self.dataOffset==5){
    }
    else{
        int length=(self.dataOffset-5)*4;
        /*
        for(int i=0;i<length;i++){
            [self.options addObject:[NSNumber numberWithShort:data[20+i]]];
        }
         */
        [self.options appendBytes:data+20 length:length];
    }
    [self setFlagBits];
    return self;
}
-(instancetype)init:(int)sourcePort destinationPort:(int)destinationPort sequenceNumber:(int)sequenceNumber dataOffset:(int)dataOffset isns:(bool)isns tcpFlags:(int)tcpFlags windowSize:(int)windowSize checksum:(int)checksum urgentPointer:(int)urgentPointer options:(NSMutableData *)options ackNum:(int)ackNum{

    self.isns=false;

    self.sourcePort=sourcePort;
    self.destinationPort=destinationPort;
    self.sequenceNumber=sequenceNumber;
    self.dataOffset=dataOffset;
    self.isns=isns;
    self.tcpFlags=tcpFlags;
    self.windowSize=windowSize;
    self.checksum=checksum;
    self.urgentPointer=urgentPointer;
    self.options=[options mutableCopy];
    self.ackNum=ackNum;
    [self setFlagBits];
    [TCPHeader extractOptionData:self];
    return self;
}

-(void)setFlagBits{
    _iscwr = (self.tcpFlags & 0x80) > 0;
    _isece = (self.tcpFlags & 0x40) > 0;
    _isurg = (self.tcpFlags & 0x20) > 0;
    _isack = (self.tcpFlags & 0x10) > 0;
    _ispsh = (self.tcpFlags & 0x08) > 0;
    _isrst = (self.tcpFlags & 0x04) > 0;
    _issyn = (self.tcpFlags & 0x02) > 0;
    _isfin = (self.tcpFlags & 0x01) > 0;
}

+(void)extractOptionData:(TCPHeader*)head{
    NSMutableData* options=[head getOptions];
    Byte kind;
    for(int i=0;i<[options length];i++){
        Byte* optionsarray=(Byte*)[options bytes];
        kind=(Byte)optionsarray[i];
        if(kind == 2){
            i +=2;
            int segsize = [PacketUtil getNetworkInt:options start:i length:2];
            [head setMaxSegmentSize:segsize];
            i++;
        }else if(kind == 3){
            i += 2;
            int scale = [PacketUtil getNetworkInt:options start:i length:1];
            [head setWindowScale:scale];
        }else if(kind == 4){
            i++;
            [head setIsSelectiveackPermitted:true];
        }else if(kind == 5){//SACK => selective acknowledgment
            i++;
            int sacklength = [PacketUtil getNetworkInt:options start:i length:1];
            i = i + (sacklength - 2);
            //case 10, 18, 26 and 34
            //TODO: handle missing segments
            //rare case => low priority
        }else if(kind == 8){//timestamp and echo of previous timestamp
            i += 2;
            int timestampSender = [PacketUtil getNetworkInt:options start:i length:4];
            i += 4;
            int timestampReplyTo = [PacketUtil getNetworkInt:options start:i length:4];
            i += 3;
            [head setTimeStampSender:timestampSender];
            [head setTimeStampReplyTo:timestampReplyTo];
        }
    }
}
/*
-(bool)isNS{
    return self.isns;
}
*/
-(void)setIsNS:(bool)isns{
    _isns=isns;
}
/*
-(bool)isCWR{
    return self.iscwr;
}
*/
-(void)setIsCWR:(bool)iscwr{
    _iscwr=iscwr;
    if(_iscwr){
        _tcpFlags|=0x80;
    }else{
        _tcpFlags&=0x7F;
    }
}
/*
-(bool)isece{
    return self.isece;
}
*/
-(void)setIsECE:(bool)isece{
    _isece=isece;
    if(_isece){
        _tcpFlags|=0x40;
    }else{
        _tcpFlags&=0xBF;
    }
}
/*
-(bool)isurg{
    return self.isurg;
}
*/
-(void)setIsURG:(bool)isurg{
    _isurg=isurg;
    if(_isurg){
        _tcpFlags|=0x20;
    }else{
        _tcpFlags&=0xDF;
    }
}
/*
-(bool)isack{
    return self.isack;
}
*/
-(void)setIsACK:(bool)isack{
    _isack=isack;
    if(_isack){
        _tcpFlags|=0x10;
    }else{
        _tcpFlags&=0xEF;
    }
}
/*
-(bool)ispsh{
    return self.ispsh;
}
*/
-(void)setIsPSH:(bool)ispsh{
    _ispsh=ispsh;
    if(_ispsh){
        _tcpFlags|=0x08;
    }else{
        _tcpFlags&=0xF7;
    }
}
/*
-(bool)isrst{
    return self.isrst;
}
*/
-(void)setIsRST:(bool)isrst{
    _isrst=isrst;
    if(_isrst){
        _tcpFlags|=0x04;
    }else{
        _tcpFlags&=0xFB;
    }
}
/*
-(int)issyn{
    return self.issyn;
}
*/
-(void)setIsSYN:(bool)issyn{
    _issyn=issyn;
    if(_issyn){
        _tcpFlags|=0x02;
    }else{
        _tcpFlags&=0xFD;
    }
}
/*
-(bool)isfin{
    return self.isfin;
}
*/
-(void)setIsFIN:(bool)isfin{
    _isfin=isfin;
    if(_isfin){
        _tcpFlags|=0x01;
    }else{
        _tcpFlags&=0xFE;
    }
}

-(int)getSourcePort{
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

-(int)getSequenceNumber{
    return self.sequenceNumber;
}

-(void)setSequenceNumber:(int)sequenceNumber{
    _sequenceNumber=sequenceNumber;
}

-(int)getdataOffset{
    return self.dataOffset;
}

-(void)setDataOffset:(int)dataOffset{
    _dataOffset=dataOffset;
}

-(int)getTCPFlags{
    return self.tcpFlags;
}

-(void)setTCPFlags:(int)tcpFlags{
    _tcpFlags=tcpFlags;
}

-(int)getWindowSize{
    return self.windowSize;
}

-(void)setWindowSize:(int)windowSize{
    _windowSize=windowSize;
}

-(int)getChecksum{
    return self.checksum;
}

-(void)setChecksum:(int)checksum{
    _checksum=checksum;
}

-(int)getUrgentPointer{
    return self.urgentPointer;
}

-(void)setUrgentPointer:(int)urgentPointer{
    _urgentPointer=urgentPointer;
}

-(NSMutableData *)getOptions{
    return self.options;
}

-(void)setOptions:(NSMutableData *)options{
    _options=[options mutableCopy];
}

-(int)getAckNumber{
    return self.ackNum;
}

-(void)setAckNumber:(int)ackNum{
    _ackNum=ackNum;
}

-(int)getTCPHeaderLength{
    return self.dataOffset*4;
}

-(int)getMexSegmentSize{
    return self.maxSegmentSize;
}

-(void)setMaxSegmentSize:(int)maxSegmentSize{
    maxSegmentSize=maxSegmentSize;
}

-(int)getWindowScale{
    return self.windowScale;
}

-(void)setWindowScale:(int)windowScale{
    _windowScale=windowScale;
}
/*
-(bool)isSelectiveackPermitted{
    return self.isSelectiveackPermitted;
}
*/
-(void)setIsSelectiveAckPermitted:(bool)isSelectiveackPermitted{
    _isSelectiveackPermitted=isSelectiveackPermitted;
}

-(int)getTimestampSender{
    return self.timeStampSender;
}

-(void)setTimeStampSender:(int)timeStampSender{
    _timeStampSender=timeStampSender;
}

-(int)getTimestampReplyTo{
    return self.timeStampReplyTo;
}

-(void)setTimeStampReplyTo:(int)timeStampReplyTo{
    _timeStampReplyTo=timeStampReplyTo;
}
@end






































