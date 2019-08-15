//
//  UIView+JPExtension.h
//  WoTV
//
//  Created by 周健平 on 2018/1/22.
//  Copyright © 2018年 zhanglinan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JPExtension)

+ (instancetype)jp_viewLoadFromNib;

- (BOOL)jp_isShowingOnKeyWindow;

/** 获取顶层控制器 */
- (UIViewController *)jp_topViewController;
+ (UIViewController *)jp_getTopViewController;
/** 获取顶层导航控制器控制器 */
- (UINavigationController *)jp_topNavigationController;

- (UIImage *)jp_convertToImage;

@property (nonatomic, assign) CGFloat jp_x;
@property (nonatomic, assign) CGFloat jp_y;
@property (nonatomic, assign) CGFloat jp_centerX;
@property (nonatomic, assign) CGFloat jp_centerY;
@property (nonatomic, assign) CGFloat jp_width;
@property (nonatomic, assign) CGFloat jp_height;
@property (nonatomic, assign) CGPoint jp_origin;
@property (nonatomic, assign) CGSize jp_size;
@property (nonatomic, assign, readonly) CGFloat jp_midX;
@property (nonatomic, assign, readonly) CGFloat jp_midY;
@property (nonatomic, assign, readonly) CGFloat jp_maxX;
@property (nonatomic, assign, readonly) CGFloat jp_maxY;

@property (nonatomic, assign, readonly) CGFloat jp_radian;
@property (nonatomic, assign, readonly) CGFloat jp_angle;

@property (nonatomic, assign, readonly) CGFloat jp_scaleX;
@property (nonatomic, assign, readonly) CGFloat jp_scaleY;
@property (nonatomic, assign, readonly) CGPoint jp_scale;

+ (UIWindow *)jp_frontWindow;
@end

@interface CALayer (JPExtension)

- (UIImage *)jp_convertToImage;

@property (nonatomic, assign) CGFloat jp_x;
@property (nonatomic, assign) CGFloat jp_y;
@property (nonatomic, assign) CGFloat jp_positionX;
@property (nonatomic, assign) CGFloat jp_positionY;
@property (nonatomic, assign) CGFloat jp_width;
@property (nonatomic, assign) CGFloat jp_height;
@property (nonatomic, assign) CGPoint jp_origin;
@property (nonatomic, assign) CGSize jp_size;
@property (nonatomic, assign, readonly) CGFloat jp_midX;
@property (nonatomic, assign, readonly) CGFloat jp_midY;
@property (nonatomic, assign, readonly) CGFloat jp_maxX;
@property (nonatomic, assign, readonly) CGFloat jp_maxY;

@property (nonatomic, assign, readonly) CGFloat jp_radian;
@property (nonatomic, assign, readonly) CGFloat jp_angle;

@property (nonatomic, assign, readonly) CGFloat jp_scaleX;
@property (nonatomic, assign, readonly) CGFloat jp_scaleY;
@property (nonatomic, assign, readonly) CGPoint jp_scale;

@end

