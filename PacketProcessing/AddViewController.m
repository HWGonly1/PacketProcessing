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
        //NSLog(@"%@", messageObject);
    }];
    self.targetManager = [NEVPNManager sharedManager];
    
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * newMangers,NSError * error){
        NSArray<NETunnelProviderManager *> * vpnManagers=newMangers;
        if(vpnManagers.count>0){
            self.targetManager=vpnManagers[0];
        }else{
            [self setTargetManger:(nil)];
        }
        NETunnelProviderSession *session = (NETunnelProviderSession*) self.targetManager.connection;
        NSError * startError;
        if(self.targetManager.connection.status == NEVPNStatusDisconnected || self.targetManager.connection.status == NEVPNStatusInvalid){
            [session startVPNTunnelWithOptions:nil andReturnError:&startError];
        }else{
            [session stopVPNTunnel];
        }
    }];
    
    _logoutButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_logoutButton setFrame:CGRectMake(20, 240, self.view.frame.size.width-40, 50)];
    [_logoutButton setTitle:@"登出" forState:UIControlStateNormal];
    [_logoutButton setBackgroundColor:[UIColor blueColor]];
    [_logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _logoutButton.layer.cornerRadius=5.0;
    [_logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_logoutButton];

}

-(void)logout{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSLog(@"EID:%ld",[[defaults objectForKey:@"CFSMagentEnterpriseID"] longLongValue]);
    NSLog(@"UID:%ld",[[defaults objectForKey:@"CFSMagentUserID"] longLongValue]);
    
    [defaults removeObjectForKey:@"CFSMagentEnterpriseID"];
    [defaults removeObjectForKey:@"CFSMagentUserID"];
    [defaults synchronize];
    _initialview=[[InitialViewController alloc] init];
    NETunnelProviderSession* session=(NETunnelProviderSession*)self.targetManager.connection;
    [session stopVPNTunnel];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self presentViewController:_initialview animated:YES completion:nil];
}

-(void)VPN{
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * newMangers,NSError * error){
        NSArray<NETunnelProviderManager *> * vpnManagers=newMangers;
        if(vpnManagers.count>0){
            self.targetManager=vpnManagers[0];
        }else{
            [self setTargetManger:(nil)];
        }
        NETunnelProviderSession *session = (NETunnelProviderSession*) self.targetManager.connection;
        NSError * startError;
        while(self.targetManager.connection.status == NEVPNStatusDisconnected || self.targetManager.connection.status == NEVPNStatusInvalid){
            [session startVPNTunnelWithOptions:nil andReturnError:&startError];
        }
    }];
}

-(void)setTargetManger :(NEVPNManager *)manager{
    if (manager!=nil){
        self.targetManager=manager;
    }else{
        NETunnelProviderManager *newManager=[[NETunnelProviderManager alloc] init];
        NETunnelProviderProtocol *proto=[[NETunnelProviderProtocol alloc] init];
        proto.providerBundleIdentifier = @"com.hwg.PacketProcessing.PacketTunnel";
        proto.serverAddress = @"Localhost";
        newManager.protocolConfiguration=proto;
        newManager.localizedDescription = @"Magent";
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






































