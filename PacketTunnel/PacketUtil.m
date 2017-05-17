//
//  PacketUtil.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/15.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "PacketUtil.h"
#import "IPv4Header.h"
#import "TCPHeader.h"
#import "UDPHeader.h"


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

+(bool)isValidTCPChecksum:(int)source destination:(int)destination data:(Byte[])data tcplength:(short)tcplength tcpoffset:(int)tcpoffset{
    int buffersize=tcplength+12;
    bool isodd=false;
    if(buffersize%2!=0){
        buffersize++;
        isodd=true;
    }
    Byte buffer[buffersize];
    buffer[0]=(Byte)((source>>24)&0xFF);
    buffer[1]=(Byte)((source>>16)&0xFF);
    buffer[2]=(Byte)((source>>8)&0xFF);
    buffer[3]=(Byte)((source)&0xFF);

    buffer[4]=(Byte)((destination>>24)&0xFF);
    buffer[5]=(Byte)((destination>>16)&0xFF);
    buffer[6]=(Byte)((destination>>8)&0xFF);
    buffer[7]=(Byte)((destination)&0xFF);

    buffer[8]=(Byte)0;
    buffer[9]=(Byte)6;
    
    buffer[10]=(Byte)((tcplength>>8)&0xFF);
    buffer[11]=(Byte)((tcplength)&0xFF);
    
    memccpy(&buffer[12], buffer, tcpoffset, tcplength);
    
    if(isodd){
        buffer[buffersize-1]=(Byte)0;
    }
    
    return [PacketUtil isValidIPChecksum:buffer length:buffersize];
    
}

+(bool)isValidIPChecksum:(Byte[])data length:(int)length{
    int start=0;
    int sum=0;
    int value=0;
    while(start<length){
        value=[PacketUtil getNetworkInt:data start:start length:2];
        sum+=value;
        start+=2;
    }
    while((sum>>16)>0){
        sum=(sum&0xFFFF)+(sum>>16);
    }
    sum=~sum;
    Byte buffer[4];
    buffer[0]=(Byte)((sum>>24)&0xFF);
    buffer[1]=(Byte)((sum>>16)&0xFF);
    buffer[2]=(Byte)((sum>>8)&0xFF);
    buffer[3]=(Byte)((sum)&0xFF);

    return (buffer[2]==0&&buffer[3]==0);
}

+(Byte *)calculateChecksum:(Byte[])data offset:(int)offset length:(int)length{
    int start=offset;
    int sum=0;
    int value=0;
    while(start<length){
        value=[PacketUtil getNetworkInt:data start:start length:2];
        sum+=value;
        start+=2;
    }
    while ((sum>>16)>0) {
        sum = (sum & 0xFFFF) + (sum >> 16);
    }
    sum=~sum;
    static Byte checksum[2];
    checksum[0]=(Byte)(sum>>8);
    checksum[1]=(Byte)sum;
    
    return checksum;
}

+(Byte *)calculateTCPHeaderChecksum:(Byte[])data offset:(int)offset tcplength:(int)tcplength destip:(int)destip sourceip:(int)sourceip{
    int buffersize=tcplength+12;
    bool odd=false;
    if(buffersize % 2 != 0){
        buffersize++;
        odd = true;
    }
    Byte buffer[buffersize];
    buffer[0]=(Byte)((sourceip>>24)&0xFF);
    buffer[1]=(Byte)((sourceip>>16)&0xFF);
    buffer[2]=(Byte)((sourceip>>8)&0xFF);
    buffer[3]=(Byte)((sourceip)&0xFF);
    
    buffer[4]=(Byte)((destip>>24)&0xFF);
    buffer[5]=(Byte)((destip>>16)&0xFF);
    buffer[6]=(Byte)((destip>>8)&0xFF);
    buffer[7]=(Byte)((destip)&0xFF);
    
    buffer[8]=(Byte)0;
    buffer[9]=(Byte)6;
    
    buffer[10]=(Byte)((tcplength>>8)&0xFF);
    buffer[11]=(Byte)((tcplength)&0xFF);
    
    memccpy(&buffer[12], buffer, offset, tcplength);
    
    if(odd){
        buffer[buffersize-1]=(Byte)0;
    }
    
    Byte * tcpchecksum=[PacketUtil calculateChecksum:buffer offset:0 length:buffersize];
    return tcpchecksum;
}

+(NSString *)intToIPAddress:(int)addressInt{
    NSString * buffer=@"";
    buffer=[buffer stringByAppendingFormat:@"%d.%d.%d.%d",((addressInt>>24)&0x000000FF),((addressInt>>16)&0x000000FF),((addressInt>>8)&0x000000FF),((addressInt)&0x000000FF)];
    return buffer;
}

+(NSString *)getLocalIpAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+(NSString *)getUDPoutput:(IPv4Header *)ipheader udp:(UDPHeader*)udp{
    NSString * str=@"";
    str=[str stringByAppendingFormat:@"\r\nIP Version: %d\r\nProtocol: %d\r\nID# %d\r\nIP Total Length: %d\r\nIP Header length: %d\r\nIP checksum: %d\r\nMay fragement? %@\r\nLast fragment? %@\r\nFlag: %d\r\nFragment Offset: %d\r\nDest: %@:%d\r\nSrc: %@:%d\r\nUDP Length: %d\r\nUDP Checksum: %d",
         ipheader.getIPVersion,
         ipheader.getProtocol,
         ipheader.getIdentification,
         ipheader.getTotalLength,
         ipheader.getIPHeaderLength,
         ipheader.getHeaderCheckSum,
         ipheader.isMayFragment?@"true":@"false",
         ipheader.isLastFragment?@"true":@"false",
         ipheader.getFlag,
         ipheader.getFragmentOffset,
         [PacketUtil intToIPAddress:ipheader.getdestinationIP],
         udp.getdestinationPort,
         [PacketUtil intToIPAddress:ipheader.getsourceIP],
         udp.getsourcePort,
         udp.getlength,
         udp.getchecksum
         ];
    return str;
}

+(NSString *)getOutput:(IPv4Header *)ipheader tcpheader:(TCPHeader *)tcpheader packetdata:(Byte[])packetdata length:(int)length{
    short tcplength=(short)(length-ipheader.getIPHeaderLength);
    bool isvalidchecksum=[PacketUtil isValidTCPChecksum:ipheader.getsourceIP destination:ipheader.getdestinationIP data:packetdata tcplength:tcplength tcpoffset:ipheader.getIPHeaderLength];
    bool isvalidipchecksum=[PacketUtil isValidIPChecksum:packetdata length:ipheader.getIPHeaderLength];
    int packetbodylength=length-ipheader.getIPHeaderLength-tcpheader.getTCPHeaderLength;
    NSString * str=@"";
    str=[str stringByAppendingFormat:@"\r\nIP Version: %d\r\nProtocol: %d\r\nID# %d\r\nTotal Length: %d\r\nData Length: %d\r\nDest: %@:%d\r\nSrc: %@:@d\r\nACK: %d\r\nSeq: %d\r\nIP Header length: %d\r\nTCP %dHeader length: %d\r\nACK: %@\r\nSYN: %@\r\nCWR: %@\r\nECE: %@\r\nFIN: %@\r\nNS: %@\r\nPSH: %@\r\nRST: %@\r\nURG: %@\r\nIP checksum: %d\r\nIs Valid IP Checksum: %@\r\nTCP Checksum: %d\r\nIs Valid TCP checksum: %@\r\nMay fragement? %@\r\nLast fragment? %@\r\nFlag: %d\r\nFragment Offset: %d\r\nWindow: %d\r\nWindow scale: %d\r\nData Offset: %d",
         ipheader.getIPVersion,
         ipheader.getProtocol,
         ipheader.getIdentification,
         ipheader.getTotalLength,
         packetbodylength,
         [PacketUtil intToIPAddress:ipheader.getdestinationIP],
         tcpheader.getdestinationPort,
         [PacketUtil intToIPAddress:ipheader.getsourceIP],
         tcpheader.getSourcePort,
         tcpheader.getAckNumber,
         tcpheader.getSequenceNumber,
         ipheader.getIPHeaderLength,
         tcpheader.getTCPHeaderLength,
         tcpheader.isack?@"true":@"false",
         tcpheader.issyn?@"true":@"false",
         tcpheader.isCWR?@"true":@"false",
         tcpheader.isece?@"true":@"false",
         tcpheader.isfin?@"true":@"false",
         tcpheader.isns?@"true":@"false",
         tcpheader.ispsh?@"true":@"false",
         tcpheader.isrst?@"true":@"false",
         tcpheader.isurg?@"true":@"false",
         ipheader.getHeaderCheckSum,
         isvalidipchecksum?@"true":@"false",
         tcpheader.getChecksum,
         isvalidchecksum?@"true":@"false",
         ipheader.isMayFragment?@"true":@"false",
         ipheader.isLastFragment?@"true":@"false",
         ipheader.getFlag,
         ipheader.fragmentOffset,
         tcpheader.getWindowSize,
         tcpheader.getWindowScale,
         tcpheader.getdataOffset];
    if(tcpheader.getOptionsLength>0){
        str=[str stringByAppendingString:@"\r\nTCP Options: \r\n.........."];
        Byte * options=tcpheader.getOptions;
        Byte kind;
        for(int i=0;i<tcpheader.getOptionsLength;i++){
            kind = options[i];
            if(kind == 0){
                [str stringByAppendingString:@"\r\n...End of options list"];
            }else if(kind == 1){
                [str stringByAppendingString:@"\r\n...NOP"];
            }else if(kind == 2){
                i += 2;
                int segsize = [PacketUtil getNetworkInt:options start:i length:2];
                i++;
                [str stringByAppendingFormat:@"%@%d",@"\r\n...Max Seg Size: ",segsize];
            }else if(kind == 3){
                i += 2;
                int windowsize = [PacketUtil getNetworkInt:options start:i length:1];
                [str stringByAppendingFormat:@"%@%d",@"\r\n...Window Scale: ",windowsize];
            }else if(kind == 4){
                i++;
                [str stringByAppendingString:@"\r\n...Selective Ack"];
            }else if(kind == 5){
                i = i + options[++i] - 2;
                [str stringByAppendingString:@"\r\n...selective ACK (SACK)"];
            }else if(kind == 8){
                i += 2;
                int tttt = [PacketUtil getNetworkInt:options start:i length:4];
                i += 4;
                int eeee = [PacketUtil getNetworkInt:options start:i length:4];
                i += 3;
                [str stringByAppendingFormat:@"%@%d%@%d",@"\r\n...Timestamp: ",tttt,@"-",eeee];
            }else if(kind == 14){
                i +=2;
                [str stringByAppendingString:@"\r\n...Alternative Checksum request"];
            }else if(kind == 15){
                i = i + options[++i] - 2;
                [str stringByAppendingString:@"\r\n...TCP Alternate Checksum Data"];
            }else{
                [str stringByAppendingFormat:@"%@%d%@%d",@"\r\n... unknown option# ",kind,@", int: ",(int)kind];
            }
        }
    }
    return str;
}

+(bool)isPacketCorrupted:(TCPHeader *)tcpheader{
    bool iscorrupted=false;
    Byte * options=tcpheader.getOptions;
    Byte kind;
    for(int i=0;i<tcpheader.getOptionsLength;i++){
        kind = options[i];
        if(kind == 0 || kind == 1){
        }else if(kind == 2){
            i += 3;
        }else if(kind == 3 || kind == 14){
            i += 2;
        }else if(kind == 4){
            i++;
        }else if(kind == 5 || kind == 15){
            i = i + options[++i] - 2;
        }else if(kind == 8){
            i += 9;
        }else if(kind == (Byte)23){
            iscorrupted = true;
            break;
        }else{
        }
    }
    return iscorrupted;
}

+(NSString *)bytesToStringArray:(Byte[])bytes bytesLength:(int)bytesLength{
    NSString * str=@"";
    str=[str stringByAppendingString:@"{"];
    for(int i =0;i<bytesLength;i++){
        if(i == 0){
            str=[str stringByAppendingFormat:@"%d",bytes[i]];
        }else{
            str=[str stringByAppendingFormat:@"%@%d",@",",bytes[i]];
        }
    }
    str=[str stringByAppendingString:@"}"];
    return str;
}
@end





















