//
//  InitialViewController.m
//  PacketProcessing
//
//  Created by HWG on 2017/6/23.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InitialViewController.h"
#import "GSKeyChainManager.h"

@implementation InitialViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _enterpriseID=[[UITextField alloc] initWithFrame:CGRectMake(20, 120, self.view.frame.size.width-40, 50)];
    _enterpriseID.backgroundColor=[UIColor whiteColor];
    _enterpriseID.placeholder=[NSString stringWithFormat:@"企业ID"];
    _enterpriseID.layer.cornerRadius=5.0;
    [self.view addSubview:_enterpriseID];
    _userID=[[UITextField alloc] initWithFrame:CGRectMake(20, 180, self.view.frame.size.width-40, 50)];
    _userID.backgroundColor=[UIColor whiteColor];
    _userID.placeholder=[NSString stringWithFormat:@"员工ID"];
    _userID.layer.cornerRadius=5.0;
    [self.view addSubview:_userID];
    _registerButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_registerButton setFrame:CGRectMake(20, 240, self.view.frame.size.width-40, 50)];
    [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [_registerButton setBackgroundColor:[UIColor blueColor]];
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _registerButton.layer.cornerRadius=5.0;
    [_registerButton addTarget:self action:@selector(initialRegister) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerButton];
}

-(void)initialRegister{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    long long eid=[[_enterpriseID text] longLongValue];
    long long uid=[[_userID text] longLongValue];
        _addview=[[AddViewController alloc] init];
    if([GSKeyChainManager readUUID]==nil){
        NSString *deviceUUID = [[UIDevice currentDevice].identifierForVendor UUIDString];
        NSLog(@"DeviceUUID:%@",deviceUUID);
        [GSKeyChainManager saveUUID:deviceUUID];
    }
    //NSLog(@"%@", [GSKeyChainManager readUUID]);
    
    //NSLog(@"EID:%lld",[[defaults objectForKey:@"CFSMagentEnterpriseID"] longLongValue]);
    //NSLog(@"UID:%lld",[[defaults objectForKey:@"CFSMagentUserID"] longLongValue]);
    
    //bool success=[[Message shareInstance] initialRegister:[[UIDevice currentDevice] systemVersion] enterpriseID:eid longLongValue] employeeID:uid IDFV:[GSKeyChainManager readUUID]];
    bool success=true;
    if(!success){
        //注册失败提示重新注册
        [self alertRegister];
    }else{
        //注册成功跳转界面并且开始保活
        [defaults setObject:[NSNumber numberWithLongLong:eid] forKey:@"CFSMagentEnterpriseID"];
        [defaults setObject:[NSNumber numberWithLongLong:uid] forKey:@"CFSMagentUserID"];
        [defaults synchronize];
        
        
        CATransition *animation = [CATransition animation];
        animation.duration = 1.0;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromBottom;
        [self.view.window.layer addAnimation:animation forKey:nil];
        [self presentViewController:_addview animated:YES completion:nil];
    }
}

- (void)alertRegister
{
    NSString *title = @"注册异常";
    
    NSString *message = @"请点击按钮重试";
    
    NSString *okButtonTitle = @"OK";
    
    // 初始化
    
    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // 创建操作
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 操作具体内容
        
        // Nothing to do.
        
    }];
    
    // 添加操作
    
    [alertDialog addAction:okAction];
    
    // 呈现警告视图
    
    [self presentViewController:alertDialog animated:YES completion:nil];
}

@end
































