//
//  PacketTunnelProvider.h
//  PacketTunnel
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//
@import NetworkExtension;

@interface PacketTunnelProvider : NEPacketTunnelProvider
//@property NWTCPConnection *connection;
//@property (strong) void (^pendingStartCompletion)(NSError *);
-(void)appendStrategy:(NSString*)strategy;
@end
