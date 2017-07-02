//
//  PacketTunnelProvider.m
//  PacketTunnel
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import "PacketTunnelProvider.h"
#import "TunnelInterface.h"
#import "PacketUtil.h"
#import "SessionManager.h"
@import NetworkExtension;

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
    [SessionManager setupWithPacketTunnelFlow:self.packetFlow];
    NEIPv4Settings *ipv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[[PacketUtil getLocalIpAddress]] subnetMasks:@[@"255.255.255.0"]];
    ipv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"127.0.0.1"];
    settings.IPv4Settings = ipv4Settings;
    settings.MTU = [NSNumber numberWithInt:1600];
    settings.DNSSettings=[[NEDNSSettings alloc] initWithServers:@[@"8.8.8.8",@"219.141.136.10"]];
    [self setTunnelNetworkSettings:settings completionHandler:^(NSError * _Nullable error) {
        if (error) {
            if (completionHandler) {
                completionHandler(error);
            }
        }else{
            if (completionHandler) {
                completionHandler(nil);
            }
        }
    }];
    [TunnelInterface setPacketFlow:self.packetFlow];
    
    [TunnelInterface processPackets];
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
    // Add code here to start the process of stopping the tunnel
    [TunnelInterface sharedInterface].processing=false;
    for(NSString* key in [SessionManager sharedInstance].tcpdict.allKeys){
        TCPSession* session=[[SessionManager sharedInstance].tcpdict objectForKey:key];
        [[SessionManager sharedInstance]closeSession:session];
    }
    for(NSString* key in [SessionManager sharedInstance].udpdict.allKeys){
        UDPSession* session=[[SessionManager sharedInstance].udpdict objectForKey:key];
        [[SessionManager sharedInstance]closeUDPSession:session];
    }
    completionHandler();
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler
{
    // Add code here to handle the message
    if (completionHandler != nil) {
        completionHandler(messageData);
    }
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler
{
    // Add code here to get ready to sleep
    completionHandler();
}

- (void)wake
{
    // Add code here to wake up
}

@end
