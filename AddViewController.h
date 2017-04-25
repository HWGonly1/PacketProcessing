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
@import NetworkExtension;
@interface AddViewController:UIViewController
@property (strong,nonatomic) NEVPNManager * targetManager;
@property (strong,nonatomic) NSArray<NEVPNManager *> * managers;
@end
