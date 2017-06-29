//
//  InitialViewController.h
//  PacketProcessing
//
//  Created by HWG on 2017/6/23.
//  Copyright © 2017年 HWG. All rights reserved.
//

#ifndef InitialViewController_h
#define InitialViewController_h
#endif /* InitialViewController_h */
#import <UIKit/UIKit.h>
#import "AddViewController.h"
#import "Message.h"
@interface  InitialViewController : UIViewController
@property (nonatomic,strong) UITextField *enterpriseID;
@property (nonatomic,strong) UITextField *userID;
@property (nonatomic,strong) UIButton *registerButton;
@property (nonatomic) UIViewController *addview;
-(void)alertRegister;
@end
