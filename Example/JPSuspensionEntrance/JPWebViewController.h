//
//  JPWebViewController.h
//  Infinitee2.0
//
//  Created by guanning on 2017/1/17.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPSuspensionEntrance.h"

@interface JPWebViewController : UIViewController <JPSuspensionEntranceProtocol>
- (instancetype)initWithURLStr:(NSString *)urlStr isHideNavBar:(BOOL)isHideNavBar isSuspension:(BOOL)isSuspension;
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, assign) BOOL isHideNavBar;
@property (nonatomic, assign) BOOL isSuspension;
@end
