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
@implementation TCPHeader
-(instancetype)init:(NSData*)packet{
    Byte * data=(Byte *)packet.bytes;
    
    self.isns=false;
    
    self.sourcePort=0;
    self.sourcePort|=data[0]&0xFF;
    self.sourcePort<<=8;
    self.sourcePort|=data[1]&0xFF;
    
    self.destinationPort=0;
    self.destinationPort|=data[2]&0xFF;
    self.destinationPort<<=8;
    self.destinationPort|=data[3]&0xFF;
    
    self.sequenceNumber=0;
    self.sequenceNumber=data[4]&0xFF;
    self.sequenceNumber<<8;
    self.sequenceNumber=data[5]&0xFF;
    self.sequenceNumber<<8;
    self.sequenceNumber=data[6]&0xFF;
    self.sequenceNumber<<8;
    self.sequenceNumber=data[7]&0xFF;
    
    self.ackNum=0;
    self.ackNum=data[8]&0xFF;
    self.ackNum<<8;
    self.ackNum=data[9]&0xFF;
    self.ackNum<<8;
    self.ackNum=data[10]&0xFF;
    self.ackNum<<8;
    self.ackNum=data[11]&0xFF;
    
    self.dataOffset=data[12]>>4;
    self.tcpFlags=data[13]&0xFF;
    
    self.windowSize=0;
    self.windowSize=data[14]&0xFF;
    self.windowSize<<8;
    self.windowSize=data[15]&0xFF;
    
    self.checksum=0;
    self.checksum|=data[16]&0xFF;
    self.checksum<<=8;
    self.checksum|=data[17]&0xFF;
    
    self.urgentPointer=0;
    self.urgentPointer=data[18]&0xFF;
    self.urgentPointer<<8;
    self.urgentPointer=data[19]&0xFF;
    
    self.options=[[NSMutableArray alloc] init];

    if(self.dataOffset==5){
    }
    else{
        int length=(self.dataOffset-5)*4;
        for(int i=0;i<length;i++){
            [self.options addObject:[NSNumber numberWithShort:data[20+i]]];
        }
    }
    [self setFlagBits];
    return self;
}
-(instancetype)init:(int)sourcePort destinationPort:(int)destinationPort sequenceNumber:(int)sequenceNumber dataOffset:(int)dataOffset isns:(bool)isns tcpFlags:(int)tcpFlags windowSize:(int)windowSize checksum:(int)checksum urgentPointer:(int)urgentPointer options:(NSMutableArray *)options ackNum:(int)ackNum{

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

-(NSMutableArray *)getOptions{
    return self.options;
}

-(void)setOptions:(NSMutableArray *)options{
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






































