//
//  JPSuspensionDecideView.h
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/15.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPSuspensionView;

@interface JPSuspensionDecideView : UIView

+ (instancetype)suspensionDecideView;

// 是否正在显示
@property (nonatomic, assign, readonly) BOOL isShowing;
// 是否碰到了
@property (nonatomic, assign, readonly) BOOL isTouch;

// 是否判断删除操作 还是判断创建操作
@property (nonatomic, assign) BOOL isDecideDelete;

// 判断点
@property (nonatomic, assign) CGPoint touchPoint;
// 显示百分比
@property (nonatomic, assign) CGFloat showPersent;

// 直接显示
- (void)show;
// 隐藏（suspensionView：需要移除的浮窗）
- (void)hideWithSuspensionView:(JPSuspensionView *)suspensionView;

@end
