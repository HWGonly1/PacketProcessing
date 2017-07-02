//
//  AddViewController.h
//  PacketProcessing
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef AddViewController_h
#define AddViewController_h
#endif /* AddViewController_h */
#import <UIKit/UIKit.h>
#import "InitialViewController.h"

@import NetworkExtension;
@interface AddViewController:UIViewController
@property (nonatomic) NEVPNManager * targetManager;
@property (nonatomic) NSArray<NEVPNManager *> * managers;
@property (nonatomic) bool flag;
@property (nonatomic,strong) UIButton* logoutButton;
@property (nonatomic) UIViewController* initialview;
-(void)appendStrategy:(NSString*)strategy;
@end
