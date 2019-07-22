//
//  ViewController.h
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPSuspensionEntrance.h"

@interface ViewController : UIViewController <JPSuspensionEntranceProtocol>
@property (nonatomic, assign) BOOL isHideNavBar;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *rightBtnTitle;
@end

