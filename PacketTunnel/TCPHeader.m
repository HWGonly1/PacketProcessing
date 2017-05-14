//
//  TCPHeader.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/10.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPHeader.h"
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
    /*
    self.isurg=data[13]&0x20;
    self.isack=data[13]&0x10;
    self.ispsh=data[13]&0x08;
    self.isrst=data[13]&0x04;
    self.issyn=data[13]&0x02;
    self.isfin=data[13]&0x01;
    */
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
    
    self.options=&(data[20]);
    
    [self setFlagBits];
    return self;
}
-(instancetype)init:(unsigned)sourcePort destinationPort:(unsigned)destinationPort sequenceNumber:(unsigned)sequenceNumber dataOffset:(unsigned)dataOffset isns:(bool)isns tcpFlags:(unsigned)tcpFlags windowSize:(unsigned)windowSize checksum:(unsigned)checksum urgentPointer:(unsigned)urgentPointer options:(Byte *)options ackNum:(unsigned)ackNum{

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
    self.options=options;
    self.ackNum=ackNum;
    [self setFlagBits];
    return self;
}

-(void)setFlagBits{
    self.iscwr = (self.tcpFlags & 0x80) > 0;
    self.isece = (self.tcpFlags & 0x40) > 0;
    self.isurg = (self.tcpFlags & 0x20) > 0;
    self.isack = (self.tcpFlags & 0x10) > 0;
    self.ispsh = (self.tcpFlags & 0x08) > 0;
    self.isrst = (self.tcpFlags & 0x04) > 0;
    self.issyn = (self.tcpFlags & 0x02) > 0;
    self.isfin = (self.tcpFlags & 0x01) > 0;
}

-(bool)isNS{
    return self.isns;
}

-(void)setIsNS:(bool)isns{
    self.isns=isns;
}

-(bool)isCWR{
    return self.iscwr;
}

-(void)setIsCWR:(bool)iscwr{
    self.iscwr=iscwr;
    if(self.iscwr){
        self.tcpFlags|=0x80;
    }else{
        self.tcpFlags&=0x7F;
    }
}

-(bool)isece{
    return self.isece;
}

-(void)setIsECE:(bool)isece{
    self.isece=isece;
    if(self.isece){
        self.tcpFlags|=0x40;
    }else{
        self.tcpFlags&=0xBF;
    }
}

-(bool)isurg{
    return self.isurg;
}

-(void)setIsURG:(bool)isurg{
    self.isurg=isurg;
    if(self.isurg){
        self.tcpFlags|=0x20;
    }else{
        self.tcpFlags&=0xDF;
    }
}

-(bool)isack{
    return self.isack;
}

-(void)setIsACK:(bool)isack{
    self.isack=isack;
    if(self.isack){
        self.tcpFlags|=0x10;
    }else{
        self.tcpFlags&=0xEF;
    }
}

-(bool)ispsh{
    return self.ispsh;
}

-(void)setIsPSH:(bool)ispsh{
    self.ispsh=ispsh;
    if(self.ispsh){
        self.tcpFlags|=0x08;
    }else{
        self.tcpFlags&=0xF7;
    }
}

-(bool)isrst{
    return self.isrst;
}

-(void)setIsRST:(bool)isrst{
    self.isrst=isrst;
    if(self.isrst){
        self.tcpFlags|=0x04;
    }else{
        self.tcpFlags&=0xFB;
    }
}

-(bool)issyn{
    return self.issyn;
}

-(void)setIsSYN:(bool)issyn{
    self.issyn=issyn;
    if(self.issyn){
        self.tcpFlags|=0x02;
    }else{
        self.tcpFlags&=0xFD;
    }
}

-(bool)isfin{
    return self.isfin;
}

-(void)setIsFIN:(bool)isfin{
    self.isfin=isfin;
    if(self.isfin){
        self.tcpFlags|=0x01;
    }else{
        self.tcpFlags&=0xFE;
    }
}

-(unsigned)getSourcePort{
    return self.sourcePort;
}

-(void)setSourcePort:(unsigned)sourcePort{
    self.sourcePort=sourcePort;
}

-(unsigned)getdestinationPort{
    return self.destinationPort;
}

-(void)setDestinationPort:(unsigned)destinationPort{
    self.destinationPort=destinationPort;
}

-(unsigned)getSequenceNumber{
    return self.sequenceNumber;
}

-(void)setSequenceNumber:(unsigned)sequenceNumber{
    self.sequenceNumber=sequenceNumber;
}

-(unsigned)getdataOffset{
    return self.dataOffset;
}

-(void)setDataOffset:(unsigned)dataOffset{
    self.dataOffset=dataOffset;
}

-(unsigned)getTCPFlags{
    return self.tcpFlags;
}

-(void)setTCPFlags:(unsigned)tcpFlags{
    self.tcpFlags=tcpFlags;
}

-(unsigned)getWindowSize{
    return self.windowSize;
}

-(void)setWindowSize:(unsigned)windowSize{
    self.windowSize=windowSize;
}

-(unsigned)getChecksum{
    return self.checksum;
}

-(void)setChecksum:(unsigned)checksum{
    self.checksum=checksum;
}

-(unsigned)getUrgentPointer{
    return self.urgentPointer;
}

-(void)setUrgentPointer:(unsigned)urgentPointer{
    self.urgentPointer=urgentPointer;
}

-(Byte *)getOptions{
    return self.options;
}

-(void)setOptions:(Byte *)options{
    self.options=options;
}

-(unsigned)getAckNumber{
    return self.ackNum;
}

-(void)setAckNumber:(unsigned)ackNum{
    self.ackNum=ackNum;
}

-(int)getTCPHeaderLength{
    return self.dataOffset*4;
}

-(int)getMexSegmentSize{
    return self.maxSegmentSize;
}

-(void)setMaxSegmentSize:(int)maxSegmentSize{
    self.maxSegmentSize=maxSegmentSize;
}

-(int)getWindowScale{
    return self.windowScale;
}

-(void)setWindowScale:(int)windowScale{
    self.windowScale=windowScale;
}

-(bool)isSelectiveAckPermitted{
    return self.isSelectiveAckPermitted;
}

-(void)setIsSelectiveAckPermitted:(bool)isSelectiveAckPermitted{
    self.isSelectiveAckPermitted=isSelectiveAckPermitted;
}

-(int)getTimestampSender{
    return self.timeStampSender;
}

-(void)setTimeStampSender:(int)timeStampSender{
    self.timeStampSender=timeStampSender;
}

-(int)getTimestampReplyTo{
    return self.timeStampReplyTo;
}

-(void)setTimeStampReplyTo:(int)timeStampReplyTo{
    self.timeStampReplyTo=timeStampReplyTo;
}

@end






































