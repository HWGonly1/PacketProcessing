//
//  TunnelInterface.m
//  PacketProcessing
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import "TunnelInterface.h"
#import "IPv4Header.h"
#import "UDPHeader.h"
#import "TCPHeader.h"
#import "IPPacketFactory.h"
#import "TCPPacketFactory.h"
#import "UDPPacketFactory.h"
#import "PacketUtil.h"
#import <MMWormhole.h>
#include <CocoaAsyncSocket/AsyncSocket.h>
#include <CocoaAsyncSocket/AsyncUdpSocket.h>
#include <CocoaAsyncSocket/GCDAsyncSocket.h>
#include <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#define kTunnelInterfaceErrorDomain @"com.hwg.PacketProcessing.TunnelInterface"


@interface TunnelInterface () <GCDAsyncUdpSocketDelegate>
@property (nonatomic) NEPacketTunnelFlow *tunnelPacketFlow;
@property (nonatomic) NSMutableDictionary *udpSession;
@property (nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic) MMWormhole *wormhole;
@property (nonatomic) int readFd;
@property (nonatomic) int writeFd;
@end

@implementation TunnelInterface

+ (TunnelInterface *)sharedInterface {
    static dispatch_once_t onceToken;
    static TunnelInterface *interface;
    dispatch_once(&onceToken, ^{
        interface = [TunnelInterface new];
    });
    return interface;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.wormhole=[[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.hwg.PacketProcessing" optionalDirectory:@"VPNStatus"];
        
        
        _udpSession = [NSMutableDictionary dictionaryWithCapacity:5];
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("udp", NULL)];
        
        
    }
    return self;
}

+ (NSError *)setupWithPacketTunnelFlow:(NEPacketTunnelFlow *)packetFlow {
    if (packetFlow == nil) {
        return [NSError errorWithDomain:kTunnelInterfaceErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: @"PacketTunnelFlow can't be nil."}];
    }
    [TunnelInterface sharedInterface].tunnelPacketFlow = packetFlow;
    
    NSError *error;
    GCDAsyncUdpSocket *udpSocket = [TunnelInterface sharedInterface].udpSocket;
    [udpSocket bindToPort:0 error:&error];
    if (error) {
        return [NSError errorWithDomain:kTunnelInterfaceErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"UDP bind fail(%@).", [error localizedDescription]]}];
    }
    [udpSocket beginReceiving:&error];
    if (error) {
        return [NSError errorWithDomain:kTunnelInterfaceErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"UDP bind fail(%@).", [error localizedDescription]]}];
    }
    /*
    int fds[2];
    if (pipe(fds) < 0) {
        return [NSError errorWithDomain:kTunnelInterfaceErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unable to pipe."}];
    }
    [TunnelInterface sharedInterface].readFd = fds[0];
    [TunnelInterface sharedInterface].writeFd = fds[1];
     */
    return nil;
}
/*
+ (void)startTun2Socks: (int)socksServerPort{
[NSThread detachNewThreadSelector:@selector(_startTun2Socks:) toTarget:[TunnelInterface sharedInterface] withObject:@(socksServerPort)];
}

+ (void)stop {
    stop_tun2socks();
}
*/
+ (void)writePacket:(NSData *)packet {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TunnelInterface sharedInterface].tunnelPacketFlow writePackets:@[packet] withProtocols:@[@(AF_INET)]];
    });
}


+ (void)processPackets {
    __weak typeof(self) weakSelf = self;
    [[TunnelInterface sharedInterface].wormhole passMessageObject:@"See if Function works"  identifier:@"VPNStatus"];
    [[TunnelInterface sharedInterface].tunnelPacketFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> * _Nonnull packets, NSArray<NSNumber *> * _Nonnull protocols) {
        [[TunnelInterface sharedInterface].wormhole passMessageObject:@"See if Packets" identifier:@"VPNStatus"];
        [[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%lu",(unsigned long)[packets count]] identifier:@"VPNStatus"];
        
        for (NSData *packet in packets) {
            NSMutableArray* clientpacketdata=[[NSMutableArray alloc] init];

            Byte * data = [packet bytes];
            
            for(int i=0;i<[packet length];i++){
                [clientpacketdata addObject:[NSNumber numberWithShort:data[i]]];
            }
            
            IPv4Header * ipheader=[[IPv4Header alloc] init:packet];
            TCPHeader* tcpheader=nil;
            UDPHeader* udpheader=nil;
            
            //[[TunnelInterface sharedInterface].wormhole passMessageObject:[packet length]==[iphdr getTotalLength]?@"true":@"false" identifier:@"VPNStatus"];
            //[[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d",[packet length]] identifier:@"VPNStatus"];
            //[[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d",[iphdr getTotalLength]]identifier:@"VPNStatus"];
            
            Byte proto = [ipheader getProtocol];
            if (proto == 17) {
                udpheader=[UDPPacketFactory createUDPHeader:clientpacketdata start:[ipheader getIPHeaderLength]];
                //[[TunnelInterface sharedInterface].wormhole passMessageObject:@"UDP" identifier:@"VPNStatus"];
                //[[TunnelInterface sharedInterface] handleUDPPacket:packet];
            }else if (proto == 6) {
                tcpheader=[TCPPacketFactory createTCPHeader:clientpacketdata start:[ipheader getIPHeaderLength]];
                //[[TunnelInterface sharedInterface].wormhole passMessageObject:@"TCP" identifier:@"VPNStatus"];
                //[[TunnelInterface sharedInterface] handleTCPPPacket:packet];
            }
            if(tcpheader!=nil){
                handleTCPPacket(clientpacketdata, ipheader, tcpheader);
            }else if(udpheader!=nil){
                handleUDPPacket(clientpacketdata, ipheader, udpheader);
            }
        }
        [weakSelf processPackets];
    }];
}

- (void)handleTCPPPacket: (NSData *)packet {
    //uint8_t message[TunnelMTU+2];
    //memcpy(message + 2, packet.bytes, packet.length);
    //message[0] = packet.length / 256;
    //message[1] = packet.length % 256;
    //write(self.writeFd , message , packet.length + 2);
    uint8_t *data = (uint8_t *)packet.bytes;
    int data_len = (int)packet.length;
    IPv4Header * iphdr=[[IPv4Header alloc] init:packet];
    Byte version = [iphdr getIPVersion];
    [[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d.%d.%d.%d",[iphdr getsourceIP]/256/256/256,[iphdr getsourceIP]/256/256%256,[iphdr getsourceIP]/256%256,[iphdr getsourceIP]%256] identifier:@"VPNStatus"];
    [[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d.%d.%d.%d",[iphdr getdestinationIP]/256/256/256,[iphdr getdestinationIP]/256/256%256,[iphdr getdestinationIP]/256%256,[iphdr getdestinationIP]%256] identifier:@"VPNStatus"];
    [[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d",[iphdr getProtocol]] identifier:@"VPNStatus"];
}

- (void)handleUDPPacket: (NSData *)packet {
    IPv4Header * iphdr=[[IPv4Header alloc] init:packet];
    Byte version = [iphdr getIPVersion];
    [[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d.%d.%d.%d",[iphdr getsourceIP]/256/256/256,[iphdr getsourceIP]/256/256%256,[iphdr getsourceIP]/256%256,[iphdr getsourceIP]%256] identifier:@"VPNStatus"];
    [[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d.%d.%d.%d",[iphdr getdestinationIP]/256/256/256,[iphdr getdestinationIP]/256/256%256,[iphdr getdestinationIP]/256%256,[iphdr getdestinationIP]%256] identifier:@"VPNStatus"];
    [[TunnelInterface sharedInterface].wormhole passMessageObject:[NSString stringWithFormat:@"%d",[iphdr getProtocol]] identifier:@"VPNStatus"];
    /*
    switch (version) {
        case 4: {
            uint16_t iphdr_hlen = [iphdr getinternetHeaderLength] * 4;
            data = data + iphdr_hlen;
            data_len -= iphdr_hlen;
            struct udp_hdr *udphdr = (struct udp_hdr *)data;
            
            data = data + sizeof(struct udp_hdr *);
            data_len -= sizeof(struct udp_hdr *);
            
            NSData *outData = [[NSData alloc] initWithBytes:data length:data_len];
            struct in_addr dest = { [iphdr getdestinationIP] };
            NSString *destHost = [NSString stringWithUTF8String:inet_ntoa(dest)];
            NSString *key = [self strForHost:[iphdr getdestinationIP] port:udphdr->dest];
            NSString *value = [self strForHost:[iphdr getdestinationIP]  port:udphdr->src];;
            self.udpSession[key] = value;
            [self.udpSocket sendData:outData toHost:destHost port:ntohs(udphdr->dest) withTimeout:30 tag:0];
        } break;
        case 6: {
            
        } break;
    }
     */
}
/*
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    const struct sockaddr_in *addr = (const struct sockaddr_in *)[address bytes];
    ip_addr_p_t dest ={ addr->sin_addr.s_addr };
    in_port_t dest_port = addr->sin_port;
    NSString *strHostPort = self.udpSession[[self strForHost:dest.addr port:dest_port]];
    NSArray *hostPortArray = [strHostPort componentsSeparatedByString:@":"];
    int src_ip = [hostPortArray[0] intValue];
    int src_port = [hostPortArray[1] intValue];
    uint8_t *bytes = (uint8_t *)[data bytes];
    int bytes_len = (int)data.length;
    int udp_length = sizeof(struct udp_hdr) + bytes_len;
    int total_len = IP_HLEN + udp_length;
    
    ip_addr_p_t src = {src_ip};
    struct ip_hdr *iphdr = generateNewIPHeader(IP_PROTO_UDP, dest, src, total_len);
    
    struct udp_hdr udphdr;
    udphdr.src = dest_port;
    udphdr.dest = src_port;
    udphdr.len = hton16(udp_length);
    udphdr.chksum = hton16(0);
    
    uint8_t *udpdata = malloc(sizeof(uint8_t) * udp_length);
    memcpy(udpdata, &udphdr, sizeof(struct udp_hdr));
    memcpy(udpdata + sizeof(struct udp_hdr), bytes, bytes_len);
    
    ip_addr_t odest = { dest.addr };
    ip_addr_t osrc = { src_ip };
    
    struct pbuf *p_udp = pbuf_alloc(PBUF_TRANSPORT, udp_length, PBUF_RAM);
    pbuf_take(p_udp, udpdata, udp_length);
    
    struct udp_hdr *new_udphdr = (struct udp_hdr *) p_udp->payload;
    new_udphdr->chksum = inet_chksum_pseudo(p_udp, IP_PROTO_UDP, p_udp->len, &odest, &osrc);
    
    uint8_t *ipdata = malloc(sizeof(uint8_t) * total_len);
    memcpy(ipdata, iphdr, IP_HLEN);
    memcpy(ipdata + sizeof(struct ip_hdr), p_udp->payload, udp_length);
    
    NSData *outData = [[NSData alloc] initWithBytes:ipdata length:total_len];
    free(ipdata);
    free(iphdr);
    free(udpdata);
    pbuf_free(p_udp);
    [TunnelInterface writePacket:outData];
}
 */

/*struct ip_hdr *generateNewIPHeader(u8_t proto, ip_addr_p_t src, ip_addr_p_t dest, uint16_t total_len) {
    struct ip_hdr *iphdr = malloc(sizeof(struct ip_hdr));
    IPH_VHL_SET(iphdr, 4, IP_HLEN / 4);
    IPH_TOS_SET(iphdr, 0);
    IPH_LEN_SET(iphdr, htons(total_len));
    IPH_ID_SET(iphdr, 0);
    IPH_OFFSET_SET(iphdr, 0);
    IPH_TTL_SET(iphdr, 64);
    IPH_PROTO_SET(iphdr, IP_PROTO_UDP);
    iphdr->src = src;
    iphdr->dest = dest;
    IPH_CHKSUM_SET(iphdr, 0);
    IPH_CHKSUM_SET(iphdr, inet_chksum(iphdr, IP_HLEN));
    return iphdr;
}*/

- (NSString *)strForHost: (int)host port: (int)port {
    return [NSString stringWithFormat:@"%d:%d",host, port];
}



@end

