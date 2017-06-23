//
//  InitialViewController.m
//  PacketProcessing
//
//  Created by HWG on 2017/6/23.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InitialViewController.h"

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
    //[defaults setObject:[_enterpriseID text] forKey:@"CFSMagentEnterpriseID"];
    //[defaults setObject:[_userID text] forKey:@"CFSMagentUserID"];
    [defaults setObject:[NSNumber numberWithLong:[[_enterpriseID text] longLongValue]] forKey:@"CFSMagentEnterpriseID"];
    [defaults setObject:[NSNumber numberWithLong:[[_userID text] longLongValue]] forKey:@"CFSMagentUserID"];
    [defaults synchronize];
    _addview=[[AddViewController alloc] init];
    
    NSLog(@"EID:%ld",[[defaults objectForKey:@"CFSMagentEnterpriseID"] longLongValue]);
    NSLog(@"UID:%ld",[[defaults objectForKey:@"CFSMagentUserID"] longLongValue]);
    
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self presentViewController:_addview animated:YES completion:nil];
}

@end
































