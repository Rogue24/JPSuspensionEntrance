//
//  JPSuspensionView.h
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPSuspensionEntranceProtocol.h"
@class JPSuspensionView;

typedef void (^JPSuspensionViewPanBegan)(UIPanGestureRecognizer *panGR);
typedef void (^JPSuspensionViewPanChanged)(UIPanGestureRecognizer *panGR);
typedef BOOL (^JPSuspensionViewPanEnded)(JPSuspensionView *targetSuspensionView, UIPanGestureRecognizer *panGR);

@interface JPSuspensionView : UIView

/**
 * 实例化浮窗 targetVC：控制器， isSuspensionState：是否为浮窗状态（yes直接为浮窗，no为临时状态需缩小动画转成浮窗）
 */
+ (JPSuspensionView *)suspensionViewWithViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC isSuspensionState:(BOOL)isSuspensionState;

/**
 * 实例化浮窗，该方法isSuspensionState为no，用于创建转成浮窗前的视图
 */
+ (JPSuspensionView *)suspensionViewWithViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC;

/** 是否已经为浮窗状态 */
@property (nonatomic, assign, readonly) BOOL isSuspensionState;

/** 保存的控制器 */
@property (nonatomic, strong) UIViewController<JPSuspensionEntranceProtocol> *targetVC;

/** 浮窗的logo视图 */
@property (nonatomic, weak) UIImageView *logoView;

/** 点击手势->展开浮窗显示控制器 */
@property (nonatomic, weak) UITapGestureRecognizer *tapGR;
/** 拖动手势->移动浮窗，松手后自动贴边 */
@property (nonatomic, weak) UIPanGestureRecognizer *panGR;
/** 浮窗状态下的手势回调 */
@property (nonatomic, copy) JPSuspensionViewPanBegan panBegan;
@property (nonatomic, copy) JPSuspensionViewPanChanged panChanged;
@property (nonatomic, copy) JPSuspensionViewPanEnded panEnded;

/** 浮窗状态下的位置更新回调 */
@property (nonatomic, copy) void (^suspensionFrameDidChanged)(CGRect suspensionFrame);

/** 转成浮窗的动画 */
- (void)shrinkSuspensionViewAnimationWithComplete:(void(^)(void))complete;

/** 更新浮窗位置 */
- (void)updateSuspensionFrame:(CGRect)suspensionFrame animated:(BOOL)animated;

@end
