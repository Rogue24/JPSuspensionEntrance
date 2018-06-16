//
//  JPSuspensionTransition.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPSuspensionTransition.h"
#import "JPSuspensionView.h"
#import "JPSuspensionEntrance.h"

@interface JPSuspensionTransition () <CAAnimationDelegate>
@property (nonatomic, assign) BOOL isInteraction;

@property (nonatomic, assign) id <UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, weak) UIViewController<JPSuspensionEntranceProtocol> *fromVC;
@property (nonatomic, weak) UIViewController<JPSuspensionEntranceProtocol> *toVC;

@property (nonatomic, weak) UIView *bgView;

@property (nonatomic, weak) UITabBar *tabBar;
@property (nonatomic, weak) UIView *tabBarSuperView;
@property (nonatomic, assign) NSInteger tabBarIndex;

@property (nonatomic, weak) UINavigationBar *navBar;
@property (nonatomic, weak) UIView *navBarSuperView;
@property (nonatomic, assign) NSInteger navBarIndex;

@property (nonatomic, assign) BOOL isTransitionCompletion;

@property (nonatomic, assign) BOOL fromViewOriginEnabled;
@property (nonatomic, assign) BOOL toViewOriginEnabled;
@end

@implementation JPSuspensionTransition

+ (JPSuspensionTransition *)basicPopTransitionWithIsInteraction:(BOOL)isInteraction {
    JPSuspensionTransition *suspensionTransition = [[self alloc] initWithTransitionType:JPBasicPopTransitionType];
    suspensionTransition.isInteraction = isInteraction;
    return suspensionTransition;
}

+ (JPSuspensionTransition *)spreadTransitionWithSuspensionView:(JPSuspensionView *)suspensionView {
    JPSuspensionTransition *suspensionTransition = [[self alloc] initWithTransitionType:JPSpreadSuspensionViewTransitionType];
    suspensionTransition.suspensionView = suspensionView;
    return suspensionTransition;
}

+ (JPSuspensionTransition *)shrinkTransitionWithSuspensionView:(JPSuspensionView *)suspensionView {
    JPSuspensionTransition *suspensionTransition = [[self alloc] initWithTransitionType:JPShrinkSuspensionViewTransitionType];
    suspensionTransition.suspensionView = suspensionView;
    return suspensionTransition;
}

- (instancetype)initWithTransitionType:(JPSuspensionTransitionType)transitionType {
    if (self = [super init]) {
        _transitionType = transitionType;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    switch (_transitionType) {
        case JPBasicPopTransitionType:
        {
            return 0.3;
        }
        case JPSpreadSuspensionViewTransitionType:
        case JPShrinkSuspensionViewTransitionType:
        {
            return 0.35;
        }
    }
}

/**
 *  transitionContext你可以看作是一个工具，用来获取一系列动画执行相关的对象，并且通知系统动画是否完成等功能。
 */
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    self.transitionContext = transitionContext;
    self.containerView = [transitionContext containerView];
    
    self.fromVC = (UIViewController<JPSuspensionEntranceProtocol> *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.toVC = (UIViewController<JPSuspensionEntranceProtocol> *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.fromViewOriginEnabled = self.fromVC.view.userInteractionEnabled;
    self.toViewOriginEnabled = self.toVC.view.userInteractionEnabled;
    self.fromVC.view.userInteractionEnabled = NO;
    self.toVC.view.userInteractionEnabled = NO;
    
    UITabBar *tabBar;
    if (self.toVC.tabBarController) {
        tabBar = self.toVC.tabBarController.tabBar;
    } else if (self.fromVC.tabBarController) {
        tabBar = self.fromVC.tabBarController.tabBar;
    }
    if (tabBar && tabBar.superview) {
        [tabBar.layer removeAllAnimations];
        self.tabBar = tabBar;
        self.tabBarSuperView = self.tabBar.superview;
        self.tabBarIndex = [self.tabBarSuperView.subviews indexOfObject:self.tabBar];
    }
    
    UIViewController<JPSuspensionEntranceProtocol> *targetVC = self.transitionType == JPSpreadSuspensionViewTransitionType ? self.toVC : self.fromVC;
    if ([targetVC respondsToSelector:@selector(jp_isHideNavigationBar)] && [targetVC jp_isHideNavigationBar]) {
        // 如果要盖住导航栏就必须得添加到containerView中
        UINavigationBar *navBar = targetVC.navigationController.navigationBar;
        if (navBar && navBar.superview) {
            self.navBar = navBar;
            self.navBarSuperView = navBar.superview;
            self.navBarIndex = [navBar.superview.subviews indexOfObject:navBar];
        }
    }
    
    switch (_transitionType) {
        case JPBasicPopTransitionType:
        {
            [self basicPopAnimation];
            break;
        }
        case JPSpreadSuspensionViewTransitionType:
        {
            [self spreadSuspensionViewAnimation];
            break;
        }
        case JPShrinkSuspensionViewTransitionType:
        {
            [self shrinkSuspensionViewAnimation];
            break;
        }
    }
}

#pragma mark - push & pop 动画

- (void)basicPopAnimation {
    NSTimeInterval duration = [self transitionDuration:self.transitionContext];
    
    JPSuspensionView *suspensionView = [JPSuspensionView suspensionViewWithViewController:self.fromVC];
    [suspensionView addSubview:self.fromVC.view];
    
    CGRect toVCFrame = self.toVC.view.frame;
    toVCFrame.origin.x = -JPSEInstance.window.bounds.size.width * 0.3;
    self.toVC.view.frame = toVCFrame;
    toVCFrame.origin.x = 0;
    
    CGRect fromVCFrame = self.fromVC.view.frame;
    fromVCFrame.origin.x = 0;
    suspensionView.frame = fromVCFrame;
    fromVCFrame.origin.x = JPSEInstance.window.bounds.size.width;
    
    CGRect tabBarFrame = CGRectZero;
    if (self.tabBar) {
        tabBarFrame = self.tabBar.frame;
        tabBarFrame.origin.x = self.toVC.view.frame.origin.x;
        self.tabBar.frame = tabBarFrame;
        tabBarFrame.origin.x = 0;
    }
    
    // 当使用【手势交互并且没有返回成功】时（就是还没划过一半），导航栏总是交替出现异常（正常然后不正常再正常如此类推）
    // 不正常的情况就是导航栏消失了
    // 所以在这里自定义导航栏的动画
    // 下面两种没有手势交互的动画也有一定几率发生该异常，所以都作统一处理
    CGRect navBarFrame = CGRectZero;
    if (self.navBar) {
        [self.navBar.layer removeAllAnimations];
        navBarFrame = self.navBar.frame;
        navBarFrame.origin.x = self.toVC.view.frame.origin.x;
        self.navBar.frame = navBarFrame;
        navBarFrame.origin.x = 0;
        // 导航栏removeAllAnimations之后就会置顶显示，为了盖住导航栏，需要将浮窗的zPosition增加
        suspensionView.layer.zPosition = 1;
    }
    
    [self.containerView addSubview:self.toVC.view];
    [self.containerView addSubview:self.tabBar];
    [self.containerView addSubview:self.navBar];
    [self.containerView addSubview:suspensionView];
    self.suspensionView = suspensionView;
    
    UIViewAnimationOptions options = self.isInteraction ? UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        if (self.tabBar) self.tabBar.frame = tabBarFrame;
        if (self.navBar) self.navBar.frame = navBarFrame;
        self.toVC.view.frame = toVCFrame;
        suspensionView.frame = fromVCFrame;
    } completion:^(BOOL finished) {
        [self transitionCompletion];
    }];
}

- (void)spreadSuspensionViewAnimation {
    NSTimeInterval duration = [self transitionDuration:self.transitionContext];
    
    CGRect suspensionFrame = self.suspensionView.frame;
    self.suspensionView.alpha = 0;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:suspensionFrame cornerRadius:suspensionFrame.size.width * 0.5].CGPath;
    [self.toVC.view.layer addSublayer:maskLayer];
    self.toVC.view.layer.mask = maskLayer;
    
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0;
    
    CGRect tabBarFrame = CGRectZero;
    if (self.tabBar) {
        tabBarFrame = self.tabBar.frame;
        tabBarFrame.origin.x = 0;
        self.tabBar.frame = tabBarFrame;
        tabBarFrame.origin.x = self.fromVC.view.bounds.size.width;
    }
    
    CGRect navBarFrame = CGRectZero;
    if (self.navBar) {
        [self.navBar.layer removeAllAnimations];
        navBarFrame = self.navBar.frame;
        navBarFrame.origin.x = 0;
        self.navBar.frame = navBarFrame;
        navBarFrame.origin.x = self.fromVC.view.bounds.size.width;
        // 导航栏removeAllAnimations之后就会置顶显示，为了盖住导航栏，需要将上层子视图的zPosition增加
        bgView.layer.zPosition = 1;
        self.toVC.view.layer.zPosition = 1;
    }
    
    [self.containerView addSubview:self.fromVC.view];
    [self.containerView addSubview:self.tabBar];
    [self.containerView addSubview:self.navBar];
    [self.containerView addSubview:bgView];
    [self.containerView addSubview:self.toVC.view];
    self.bgView = bgView;
    
    [JPSEInstance playSoundForSpread:YES delay:duration * 0.25];
    
    UIBezierPath *toPath1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.toVC.view.bounds.size.width, self.toVC.view.bounds.size.height) cornerRadius:suspensionFrame.size.width * 0.5];
    UIBezierPath *toPath2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.toVC.view.bounds.size.width, self.toVC.view.bounds.size.height) cornerRadius:0.1];
    CAKeyframeAnimation *kfAnim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    kfAnim.values = @[(id)maskLayer.path, (id)toPath1.CGPath, (id)toPath2.CGPath];
    kfAnim.keyTimes = @[@0, @(4.0 / 5.0), @(1)];
    kfAnim.duration = duration;
    kfAnim.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    kfAnim.fillMode = kCAFillModeForwards;
    kfAnim.removedOnCompletion = NO;
    [maskLayer addAnimation:kfAnim forKey:@"path"];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (self.tabBar) self.tabBar.frame = tabBarFrame;
        if (self.navBar) self.navBar.frame = navBarFrame;
        bgView.alpha = 1;
    } completion:^(BOOL finished) {
        [self transitionCompletion];
    }];
}

- (void)shrinkSuspensionViewAnimation {
    NSTimeInterval duration = [self transitionDuration:self.transitionContext];
    
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    
    CGRect tabBarFrame = CGRectZero;
    if (self.tabBar) {
        tabBarFrame = self.tabBar.frame;
        tabBarFrame.origin.x = 0;
        self.tabBar.frame = tabBarFrame;
    }
    
    CGRect navBarFrame = CGRectZero;
    if (self.navBar) {
        [self.navBar.layer removeAllAnimations];
        navBarFrame = self.navBar.frame;
        navBarFrame.origin.x = 0;
        self.navBar.frame = navBarFrame;
        // 导航栏removeAllAnimations之后就会置顶显示，为了盖住导航栏，需要将上层子视图的zPosition增加
        bgView.layer.zPosition = 1;
    }
    
    [self.containerView addSubview:self.toVC.view];
    [self.containerView addSubview:self.tabBar];
    [self.containerView addSubview:self.navBar];
    [self.containerView addSubview:bgView];
    self.bgView = bgView;
    
    if (JPSEInstance.suspensionView == self.suspensionView) {
        CGRect suspensionFrame = self.suspensionView.frame;
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.fromVC.view.bounds cornerRadius:0.1].CGPath;
        [self.fromVC.view.layer addSublayer:maskLayer];
        self.fromVC.view.layer.mask = maskLayer;
        
        // 导航栏removeAllAnimations之后就会置顶显示，为了盖住导航栏，需要将上层子视图的zPosition增加
        if (self.navBar) self.fromVC.view.layer.zPosition = 1;
        [self.containerView addSubview:self.fromVC.view];
        
        // 播放展开提示音
        [JPSEInstance playSoundForSpread:NO delay:duration * 0.5];
        
        UIBezierPath *toPath1 = [UIBezierPath bezierPathWithRoundedRect:self.fromVC.view.bounds cornerRadius:suspensionFrame.size.width * 0.5];
        UIBezierPath *toPath2 = [UIBezierPath bezierPathWithRoundedRect:suspensionFrame cornerRadius:suspensionFrame.size.width * 0.5];
        CAKeyframeAnimation *kfAnim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        kfAnim.values = @[(id)maskLayer.path, (id)toPath1.CGPath, (id)toPath2.CGPath];
        kfAnim.keyTimes = @[@0, @(1.0 / 5.0), @(1)];
        kfAnim.duration = duration;
        kfAnim.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        kfAnim.fillMode = kCAFillModeForwards;
        kfAnim.removedOnCompletion = NO;
        [maskLayer addAnimation:kfAnim forKey:@"path"];
    } else {
        [self.suspensionView shrinkSuspensionViewAnimation];
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (self.tabBar) self.tabBar.frame = tabBarFrame;
        if (self.navBar) self.navBar.frame = navBarFrame;
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self transitionCompletion];
    }];
}

#pragma mark - 转场结束

- (void)transitionCompletion {
    if (self.isTransitionCompletion) return;
    self.isTransitionCompletion = YES;
    
    // 转场结束后 导航栏又会多一个系统加上去的动画 会造成瞬间偏移 移除该动画
    [self.navBar.layer removeAllAnimations];
    [self.tabBar.layer removeAllAnimations];
    [self.navBarSuperView insertSubview:self.navBar atIndex:self.navBarIndex];
    [self.tabBarSuperView insertSubview:self.tabBar atIndex:self.tabBarIndex];
    
    self.fromVC.view.userInteractionEnabled = self.fromViewOriginEnabled;
    self.toVC.view.userInteractionEnabled = self.toViewOriginEnabled;
    
    switch (self.transitionType) {
        case JPBasicPopTransitionType:
        {
            [self basicPopTransitionCompletion];
            break;
        }
        case JPSpreadSuspensionViewTransitionType:
        {
            [self spreadSuspensionViewTransitionCompletion];
            break;
        }
        case JPShrinkSuspensionViewTransitionType:
        {
            [self shrinkSuspensionViewTransitionCompletion];
            break;
        }
    }
}

- (void)basicPopTransitionCompletion {
    if ([self.transitionContext transitionWasCancelled]) {
        [self.containerView addSubview:self.fromVC.view];
        [self.suspensionView removeFromSuperview];
        [self.transitionContext completeTransition:NO];
    } else {
        if (!self.suspensionView.isSuspensionState) [self.suspensionView removeFromSuperview];
        [self.transitionContext completeTransition:YES];
    }
}

- (void)spreadSuspensionViewTransitionCompletion {
    [self.bgView removeFromSuperview];
    [self.containerView addSubview:self.toVC.view];
    self.toVC.view.layer.mask = nil;
    self.toVC.view.layer.zPosition = 0;
    [self.transitionContext completeTransition:YES];
}

- (void)shrinkSuspensionViewTransitionCompletion {
    if (JPSEInstance.suspensionView == self.suspensionView) [JPSEInstance insertTransitionView:self.fromVC.view];
    [UIView animateWithDuration:0.15 animations:^{
        self.suspensionView.alpha = 1;
        self.fromVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self.fromVC.view removeFromSuperview];
        self.fromVC.view.alpha = 1;
        self.fromVC.view.layer.mask = nil;
        self.fromVC.view.layer.zPosition = 0;
        [self.transitionContext completeTransition:YES];
    }];
}

@end
