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
//#import "dns.h"
//#import <sys/syslog.h>
//#import <ShadowPath/ShadowPath.h>
//#import <sys/socket.h>
//#import <arpa/inet.h>

@interface PacketTunnelProvider ()
@property NWTCPConnection *connection;
@property (strong) void (^pendingStartCompletion)(NSError *);
@property (nonatomic) MMWormhole *wormhole;
@end

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
    
    self.wormhole=[[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.hwg.PacketProcessing" optionalDirectory:@"VPNStatus"];
    [self.wormhole passMessageObject:@"Start Tunnel" identifier:@"VPNStatus"];
    
    NEIPv4Settings *ipv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[@"10.0.0.1"] subnetMasks:@[@"255.255.255.0"]];
    ipv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"127.0.0.1"];
    settings.IPv4Settings = ipv4Settings;
    settings.MTU = @(TunnelMTU);
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
    //NSError *error = [TunnelInterface setupWithPacketTunnelFlow:self.packetFlow];
    //if (error) {
    //    completionHandler(error);
    //    exit(1);
    //    return;
    //}
    //self.pendingStartCompletion = completionHandler;
    /*
    [self startProxies];
    [self startPacketForwarders];
    [self setupWormhole];
     */
}
/*
- (void)setupStatusSocket {
    NSError *error;
    self.statusSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    [self.statusSocket acceptOnInterface:@"127.0.0.1" port:0 error:&error];
    [self.statusSocket performBlock:^{
        int port = sock_port(self.statusSocket.socket4FD);
        [[Potatso sharedUserDefaults] setObject:@(port) forKey:@"tunnelStatusPort"];
        [[Potatso sharedUserDefaults] synchronize];
    }];
}

- (void)startProxies {
    __block NSError *proxyError;
    dispatch_group_t g = dispatch_group_create();
    dispatch_group_enter(g);
    NSLog(@"starting shadowsocks....");
    [[ProxyManager sharedManager] startShadowsocks:^(int port, NSError *error) {
        proxyError = error;
        dispatch_group_leave(g);
    }];
    dispatch_group_wait(g, DISPATCH_TIME_FOREVER);
    if (proxyError) {
        NSLog(@"shadowsocks error: %@", [proxyError localizedDescription]);
        exit(1);
        return;
    }
    dispatch_group_enter(g);
    NSLog(@"starting http proxy....");
    [[ProxyManager sharedManager] startHttpProxy:^(int port, NSError *error) {
        proxyError = error;
        dispatch_group_leave(g);
    }];
    dispatch_group_wait(g, DISPATCH_TIME_FOREVER);
    if (proxyError) {
        NSLog(@"http proxy error: %@", [proxyError localizedDescription]);
        exit(1);
        return;
    }
    dispatch_group_enter(g);
    NSLog(@"starting socks proxy....");
    [[ProxyManager sharedManager] startSocksProxy:^(int port, NSError *error) {
        proxyError = error;
        dispatch_group_leave(g);
    }];
    dispatch_group_wait(g, DISPATCH_TIME_FOREVER);
    if (proxyError) {
        NSLog(@"socks proxy error: %@", [proxyError localizedDescription]);
        exit(1);
        return;
    }
}

- (void)startPacketForwarders {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTun2SocksFinished) name:kTun2SocksStoppedNotification object:nil];
    [self startVPNWithOptions:nil completionHandler:^(NSError *error) {
        if (error == nil) {
            [weakSelf addObserver:weakSelf forKeyPath:@"defaultPath" options:NSKeyValueObservingOptionInitial context:nil];
            [TunnelInterface startTun2Socks:[ProxyManager sharedManager].socksProxyPort];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [TunnelInterface processPackets];
            });
        }
        if (weakSelf.pendingStartCompletion) {
            weakSelf.pendingStartCompletion(error);
            weakSelf.pendingStartCompletion = nil;
        }
    }];
}

- (void)startVPNWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *error))completionHandler {
    NSString *generalConfContent = [NSString stringWithContentsOfURL:[Potatso sharedGeneralConfUrl] encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *generalConf = [generalConfContent jsonDictionary];
    NSString *dns = generalConf[@"dns"];
    NEIPv4Settings *ipv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[@"192.0.2.1"] subnetMasks:@[@"255.255.255.0"]];
    NSArray *dnsServers;
    if (dns.length) {
        dnsServers = [dns componentsSeparatedByString:@","];
        NSLog(@"custom dns servers: %@", dnsServers);
    }else {
        dnsServers = [DNSConfig getSystemDnsServers];
        NSLog(@"system dns servers: %@", dnsServers);
    }
    NSMutableArray *excludedRoutes = [NSMutableArray array];
    [excludedRoutes addObject:[[NEIPv4Route alloc] initWithDestinationAddress:@"192.168.0.0" subnetMask:@"255.255.0.0"]];
    [excludedRoutes addObject:[[NEIPv4Route alloc] initWithDestinationAddress:@"10.0.0.0" subnetMask:@"255.0.0.0"]];
    [excludedRoutes addObject:[[NEIPv4Route alloc] initWithDestinationAddress:@"172.16.0.0" subnetMask:@"255.240.0.0"]];
    ipv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
    ipv4Settings.excludedRoutes = excludedRoutes;
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"192.0.2.2"];
    settings.IPv4Settings = ipv4Settings;
    settings.MTU = @(TunnelMTU);
    NEProxySettings* proxySettings = [[NEProxySettings alloc] init];
    NSInteger proxyServerPort = [ProxyManager sharedManager].httpProxyPort;
    NSString *proxyServerName = @"localhost";
    
    proxySettings.HTTPEnabled = YES;
    proxySettings.HTTPServer = [[NEProxyServer alloc] initWithAddress:proxyServerName port:proxyServerPort];
    proxySettings.HTTPSEnabled = YES;
    proxySettings.HTTPSServer = [[NEProxyServer alloc] initWithAddress:proxyServerName port:proxyServerPort];
    proxySettings.excludeSimpleHostnames = YES;
    settings.proxySettings = proxySettings;
    NEDNSSettings *dnsSettings = [[NEDNSSettings alloc] initWithServers:dnsServers];
    dnsSettings.matchDomains = @[@""];
    settings.DNSSettings = dnsSettings;
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
}
- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
    // Add code here to start the process of stopping the tunnel
    self.pendingStopCompletion = completionHandler;
    [self stop];
}



















- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"state"]) {
		NWTCPConnection *conn = (NWTCPConnection *)object;
		if (conn.state == NWTCPConnectionStateConnected) {
			NWHostEndpoint *ra = (NWHostEndpoint *)conn.remoteAddress;
			__weak PacketTunnelProvider *weakself = self;
			[self setTunnelNetworkSettings:[[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:ra.hostname] completionHandler:^(NSError *error) {
				if (error == nil) {
					[weakself addObserver:weakself forKeyPath:@"defaultPath" options:NSKeyValueObservingOptionInitial context:nil];
					[weakself.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> *packets, NSArray<NSNumber *> *protocols) {
						// Add code here to deal with packets, and call readPacketsWithCompletionHandler again when ready for more.
					}];
					[conn readMinimumLength:0 maximumLength:8192 completionHandler:^(NSData *data, NSError *error) {
						// Add code here to parse packets from the data, call [self.packetFlow writePackets] with the result
					}];
				}
				if (weakself.pendingStartCompletion != nil) {
					weakself.pendingStartCompletion(nil);
					weakself.pendingStartCompletion = nil;
				}
			}];
		} else if (conn.state == NWTCPConnectionStateDisconnected) {
			NSError *error = [NSError errorWithDomain:@"PacketTunnelProviderDomain" code:-1 userInfo:@{ NSLocalizedDescriptionKey: @"Connection closed by server" }];
			if (self.pendingStartCompletion != nil) {
				self.pendingStartCompletion(error);
				self.pendingStartCompletion = nil;
			} else {
				[self cancelTunnelWithError:error];
			}
			[conn cancel];
		} else if (conn.state == NWTCPConnectionStateCancelled) {
			[self removeObserver:self forKeyPath:@"defaultPath"];
			[conn removeObserver:self forKeyPath:@"state"];
			self.connection = nil;
		}
	} else if ([keyPath isEqualToString:@"defaultPath"]) {
		// Add code here to deal with changes to the network
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}
 */

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
