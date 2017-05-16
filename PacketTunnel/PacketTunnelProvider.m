//
//  PacketTunnelProvider.m
//  PacketTunnel
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import "PacketTunnelProvider.h"
#import "TunnelInterface.h"
#import <MMWormhole.h>
@import NetworkExtension;

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {

    NSError *error = [TunnelInterface setupWithPacketTunnelFlow:self.packetFlow];
    self.wormhole=[[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.hwg.PacketProcessing" optionalDirectory:@"VPNStatus"];
    [self.wormhole passMessageObject:@"Start Tunnel" identifier:@"VPNStatus"];
    
    NEIPv4Settings *ipv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[@"10.0.0.1"] subnetMasks:@[@"255.255.255.0"]];
    ipv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"127.0.0.1"];
    settings.IPv4Settings = ipv4Settings;
    settings.MTU = @(TunnelMTU);
    settings.DNSSettings=[[NEDNSSettings alloc] initWithServers:@[@"219.141.136.10" , @"8.8.8.8"]];
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
    [self.wormhole passMessageObject:@"Start Tunnel End" identifier:@"VPNStatus"];
    [TunnelInterface processPackets];
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
	// Add code here to start the process of stopping the tunnel
	//[self.connection cancel];
	//completionHandler();
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
