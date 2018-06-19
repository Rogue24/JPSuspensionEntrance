//
//  JPSuspensionEntrance.h
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPSuspensionEntranceProtocol.h"
#import "JPSuspensionView.h"
#import "JPSuspensionDecideView.h"

#define JPSEInstance [JPSuspensionEntrance sharedInstance]

@interface JPSuspensionEntrance : NSObject

/**
 * 单例对象
 */
+ (instancetype)sharedInstance;

/**
 * 配置浮窗（用于初始化配置缓存的控制器，使用xy值）
 */
- (void)setupSuspensionViewWithTargetVC:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC suspensionXY:(CGPoint)suspensionXY;

/**
 * 转场时的临时视图插入
 */
- (void)insertTransitionView:(UIView *)transitionView;

/**
 * 播放浮窗提示音
 */
- (void)playSoundForSpread:(BOOL)isSpread delay:(NSTimeInterval)delay;

/**
 * 展开当前浮窗
 */
- (void)pushViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC;

/**
 * 创建/闭合浮窗
 */
- (void)popViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC;

/** 主窗口，浮窗的载体（可自定义 默认为[UIApplication sharedApplication].keyWindow） */
@property (nonatomic, strong) UIWindow *window;

/** 绑定的NavigationController 成为其及interactivePopGestureRecognizer的代理 */
@property (nonatomic, strong) UINavigationController *navCtr;

/** navCtr的根控制器和没有遵守<JPSuspensionEntranceProtocol>协议的子控制器是否隐藏导航栏（默认是no） */
@property (nonatomic, assign) BOOL isHideNavBar;

/** 当前浮窗（为nil时移除） */
@property (nonatomic, strong) JPSuspensionView *suspensionView;

/** 右下角的判别视图（是否创建、删除浮窗） */
@property (nonatomic, strong) JPSuspensionDecideView *decideView;

/** 浮窗宽高 */
@property (nonatomic, assign, readonly) CGFloat suspensionViewWH;
/** 浮窗logo的边距 */
@property (nonatomic, assign, readonly) CGFloat suspensionLogoMargin;
/** 浮窗在窗口的内边距 */
@property (nonatomic, assign, readonly) UIEdgeInsets suspensionScreenEdgeInsets;
/** 浮窗位置（默认在窗口的左上方，当前浮窗位置发生改变时该值也会随之改变并回调缓存位置的block） */
@property (nonatomic, assign, readonly) CGRect suspensionFrame;

/** 是否创建浮窗的图标（可自定义 path路径） */
@property (nonatomic, copy) NSString *suspensiconIconPath;
/** 确认创建浮窗的图标（可自定义 path路径） */
@property (nonatomic, copy) NSString *confimSuspensionIconPath;
/** 是否删除浮窗的图标（可自定义 path路径） */
@property (nonatomic, copy) NSString *removeSuspensionIconPath;

/** 展开/闭合/创建浮窗时是否有提示音，默认为NO */
@property (nonatomic, assign) BOOL canPlaySound;

/**
 * 自定义浮窗提示音的block
    - 默认展开为系统id为1397的提示音（低版本没有该铃声）
    - 默认闭合为系统id为1396的提示音（低版本没有该铃声）
 */
@property (nonatomic, copy) void (^playSpreadSoundBlock)(void); // 展开浮窗
@property (nonatomic, copy) void (^playShrinkSoundBlock)(void); // 创建/闭合浮窗

/**
 * 浮窗即将展开时调用的block（可在此block里对push的控制器做相应配置）
 */
@property (nonatomic, copy) void (^willSpreadSuspensionViewControllerBlock)(UIViewController<JPSuspensionEntranceProtocol> *targetVC);

/**
 * 需要缓存信息时调用的block（创建/替换浮窗时调用）
 */
@property (nonatomic, copy) void (^cacheMsgBlock)(NSString *cacheMsg);

/**
 * 需要缓存最后一次浮窗位置时调用的block（浮窗停止时的位置，默认左上角位置）
 */
@property (nonatomic, copy) void (^cacheSuspensionFrameBlock)(CGRect suspensionFrame);

@end
