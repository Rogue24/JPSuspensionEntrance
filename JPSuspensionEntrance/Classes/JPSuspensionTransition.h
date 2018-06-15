//
//  JPSuspensionTransition.h
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPSuspensionView;

typedef NS_ENUM(NSUInteger, JPSuspensionTransitionType) {
    JPBasicPopTransitionType,               // 高仿的系统pop动画
    JPSpreadSuspensionViewTransitionType,   // 打开浮窗
    JPShrinkSuspensionViewTransitionType    // 合上浮窗
};

@interface JPSuspensionTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, readonly) JPSuspensionTransitionType transitionType;

@property (nonatomic, weak) JPSuspensionView *suspensionView;

// 高仿的系统pop动画 isInteraction：是否手势操控
+ (JPSuspensionTransition *)basicPopTransitionWithIsInteraction:(BOOL)isInteraction;

// 打开浮窗的动画
+ (JPSuspensionTransition *)spreadTransitionWithSuspensionView:(JPSuspensionView *)suspensionView;

// 合上浮窗的动画
+ (JPSuspensionTransition *)shrinkTransitionWithSuspensionView:(JPSuspensionView *)suspensionView;

- (instancetype)initWithTransitionType:(JPSuspensionTransitionType)transitionType;

@end
