//
//  JPSuspensionEntranceProtocol.h
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

@protocol JPSuspensionEntranceProtocol <NSObject>

@required
- (BOOL)jp_isHideNavigationBar;

@optional
- (NSString *)jp_suspensionCacheMsg;
- (UIImage *)jp_suspensionLogoImage;

@end
