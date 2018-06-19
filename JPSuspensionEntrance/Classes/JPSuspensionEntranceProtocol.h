//
//  JPSuspensionEntranceProtocol.h
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

@protocol JPSuspensionEntranceProtocol <NSObject>

@required
/** 是否隐藏导航栏 */
- (BOOL)jp_isHideNavigationBar;

@optional

/**
 * 需要缓存的信息（例如url）
 */
- (NSString *)jp_suspensionCacheMsg;

/**
 * 浮窗的logo图标
 */
- (UIImage *)jp_suspensionLogoImage;

/**
 * 加载浮窗的logo图标的回调
 * 当“jp_suspensionLogoImage”没有实现或者返回的是nil，就会调用该方法，需要自定义加载方案，这里只提供调用时机
 */
- (void)jp_requestSuspensionLogoImageWithLogoView:(UIImageView *)logoView;

@end
