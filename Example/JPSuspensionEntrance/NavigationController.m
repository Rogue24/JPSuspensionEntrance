//
//  NavigationController.m
//  JPSuspensionEntrance_Example
//
//  Created by 周健平 on 2018/6/15.
//  Copyright © 2018 Rogue24. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}

@end
