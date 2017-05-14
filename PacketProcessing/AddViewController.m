//
//  AddViewController.m
//  PacketProcessing
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddViewController.h"
#import <UIKit/UIKit.h>
#import <MMWormhole.h>
@import NetworkExtension;

@interface AddViewController()
@property (nonatomic) MMWormhole *wormhole;
@end
@implementation AddViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    self.wormhole=[[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.hwg.PacketProcessing" optionalDirectory:@"VPNStatus"];
    [self.wormhole listenForMessageWithIdentifier:@"VPNStatus" listener:^(id  _Nullable messageObject) {
        NSLog(@"%@", messageObject);
    }];
    
    self.targetManager = [NEVPNManager sharedManager];
    UIButton *btnAdd=[[UIButton alloc] initWithFrame:CGRectMake(120, 250, 60, 40)];
    [btnAdd setTitle:@"连接／断开" forState:UIControlStateNormal];
    [btnAdd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btnAdd.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    btnAdd.backgroundColor = [UIColor redColor];
    [btnAdd addTarget:self action:@selector(VPN) forControlEvents :UIControlEventTouchUpInside];
    [self.view addSubview:btnAdd];
    //[btnAdd release];
}

-(void)VPN{
    //    AddViewController *ad=[[AddViewController alloc] init];
    system("ls /etc/");

    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * newMangers,NSError * error){
        NSArray<NETunnelProviderManager *> * vpnManagers=newMangers;
        if(vpnManagers.count>0){
            self.targetManager=vpnManagers[0];
            NSLog(@"0");
        }else{
            [self setTargetManger:(nil)];
            NSLog(@"1");
        }
        NETunnelProviderSession *session = (NETunnelProviderSession*) self.targetManager.connection;
        NSError * startError;
        if(self.targetManager.connection.status == NEVPNStatusDisconnected || self.targetManager.connection.status == NEVPNStatusInvalid){
            //[self.targetManager.connection startVPNTunnelWithOptions : nil:^(NSError * error){}];
            [session startVPNTunnelWithOptions:nil andReturnError:&startError];
            NSLog(@"%@", startError);
            NSLog(@"2");
        }else{
            [session stopVPNTunnel];
            NSLog(@"3");
        }
        switch(self.targetManager.connection.status){
            case NEVPNStatusInvalid:
                NSLog(@".Invalid");
                break;
            case NEVPNStatusDisconnected:
                NSLog(@".Disconnected");
                break;
            case NEVPNStatusConnected:
                NSLog(@".Connected");
                break;
            case NEVPNStatusConnecting:
                NSLog(@".Connecting");
                break;
            case NEVPNStatusDisconnecting:
                NSLog(@".Disconnecting");
                break;
            default:
                NSLog(@".Reasserting");
        }
    }];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    //    [ad release];
}

-(void)setTargetManger :(NEVPNManager *)manager{
    if (manager!=nil){
        self.targetManager=manager;
    }else{
        NETunnelProviderManager *newManager=[[NETunnelProviderManager alloc] init];
        NETunnelProviderProtocol *proto=[[NETunnelProviderProtocol alloc] init];
        proto.providerBundleIdentifier = @"com.hwg.PacketProcessing.PacketTunnel";
        proto.serverAddress = @"Server";
        newManager.protocolConfiguration=proto;
        newManager.localizedDescription = @"Demo VPN";
        [newManager setEnabled:true];
        self.targetManager=newManager;
        [self.targetManager saveToPreferencesWithCompletionHandler:^(NSError * error){
            if(error!=nil){
                NSLog(@"Failed to save the configuration: \(saveError)");
            }
        }];
    }
}
@end






































