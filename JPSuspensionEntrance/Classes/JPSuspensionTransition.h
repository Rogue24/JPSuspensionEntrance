//
//  JPSuspensionTransition.h
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+JPExtension.h"
@class JPSuspensionView;

typedef NS_ENUM(NSUInteger, JPSuspensionTransitionType) {
    JPBasicPopTransitionType,               // 高仿的系统pop
    JPSpreadSuspensionViewTransitionType,   // 展开浮窗
    JPShrinkSuspensionViewTransitionType    // 闭合浮窗
};

@interface JPSuspensionTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, readonly) JPSuspensionTransitionType transitionType;

@property (nonatomic, weak) JPSuspensionView *suspensionView;

@property (nonatomic, assign) BOOL isShrinkSuspension; // 是否要创建浮窗

- (void)transitionCompletion;

// 高仿的系统pop动画 isInteraction：是否手势操控
+ (JPSuspensionTransition *)basicPopTransitionWithIsInteraction:(BOOL)isInteraction;

// 展开浮窗的动画
+ (JPSuspensionTransition *)spreadTransitionWithSuspensionView:(JPSuspensionView *)suspensionView;

// 闭合浮窗的动画
+ (JPSuspensionTransition *)shrinkTransitionWithSuspensionView:(JPSuspensionView *)suspensionView;

- (instancetype)initWithTransitionType:(JPSuspensionTransitionType)transitionType;

@end
