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

@property (nonatomic, assign) BOOL isHideFromVCNavBar;
@property (nonatomic, assign) BOOL isHideToVCNavBar;

@property (nonatomic, assign) BOOL isCurrSuspensionView;
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
    self.isShrinkSuspension = NO;
    
    self.transitionContext = transitionContext;
    self.containerView = [transitionContext containerView];
    
    self.fromVC = (UIViewController<JPSuspensionEntranceProtocol> *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.toVC = (UIViewController<JPSuspensionEntranceProtocol> *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.isHideFromVCNavBar = [self.fromVC conformsToProtocol:@protocol(JPSuspensionEntranceProtocol)] ? [self.fromVC jp_isHideNavigationBar] : JPSEInstance.isHideNavBar;
    self.isHideToVCNavBar = [self.toVC conformsToProtocol:@protocol(JPSuspensionEntranceProtocol)] ? [self.toVC jp_isHideNavigationBar] : JPSEInstance.isHideNavBar;
    
    self.fromViewOriginEnabled = self.fromVC.view.userInteractionEnabled;
    self.toViewOriginEnabled = self.toVC.view.userInteractionEnabled;
    self.fromVC.view.userInteractionEnabled = NO;
    self.toVC.view.userInteractionEnabled = NO;
    
    UIViewController *targetVC = _transitionType == JPSpreadSuspensionViewTransitionType ? self.toVC : self.fromVC;
    if (targetVC.hidesBottomBarWhenPushed) {
        UITabBarController *tabBarController = self.toVC.tabBarController ? self.toVC.tabBarController : self.fromVC.tabBarController;
        UITabBar *tabBar = tabBarController.tabBar;
        if (tabBar && tabBar.superview) {
            self.tabBar = tabBar;
            self.tabBarSuperView = tabBar.superview;
            self.tabBarIndex = [tabBar.superview.subviews indexOfObject:tabBar];
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
    
    // 当toVC.edgesForExtendedLayout为UIRectEdgeNone的情况下
    // toVC.view的y值应该为导航栏最大高度，但在这里时为窗口大小
    // 所以使用jp_apearFrame属性来保存了这个vc在push时vc.view的frame，pop时应该为push时的frame
    CGRect toVCFrame = CGRectIsNull(self.toVC.jp_apearFrame) ? self.toVC.view.frame : self.toVC.jp_apearFrame;
    toVCFrame.origin.x = -JPSEInstance.window.bounds.size.width * 0.3;
    self.toVC.view.frame = toVCFrame;
    toVCFrame.origin.x = 0;
    
    JPSuspensionView *suspensionView = [JPSuspensionView suspensionViewWithViewController:self.fromVC];
    
    CGRect fromVCFrame = self.fromVC.view.frame;
    fromVCFrame.origin.x = 0;
    suspensionView.frame = fromVCFrame;
    fromVCFrame.origin.x = JPSEInstance.window.bounds.size.width;
    
    // 当fromVC.edgesForExtendedLayout为UIRectEdgeNone且有导航栏的情况下
    // fromVC.view的y值为导航栏的最大高度，导致在suspensionView上会往下偏移，这里调整位置
    self.fromVC.view.frame = suspensionView.bounds;
    [suspensionView addSubview:self.fromVC.view];
    
    [self.containerView addSubview:self.toVC.view];
    [self.containerView addSubview:self.tabBar];
    [self.containerView addSubview:suspensionView];
    self.suspensionView = suspensionView;
    
    UINavigationController *navCtr = self.toVC.navigationController;
    UINavigationBar *navBar = navCtr.navigationBar;
    CGRect navBarFrame = navBar.frame;
    // 如果fromVC本来就隐藏了导航栏，就不需要添加系统动画效果
    [navCtr setNavigationBarHidden:self.isHideToVCNavBar animated:YES];
    if (navBar && navBar.superview) {
        self.navBar = navBar;
        self.navBarSuperView = navBar.superview;
        self.navBarIndex = [navBar.superview.subviews indexOfObject:navBar];
        // 如果fromVC本来就隐藏了导航栏，不添加系统动画，而且将它挪到suspensionView底下，然后自定义动画
        if (self.isHideFromVCNavBar) {
            [navBar.layer removeAllAnimations];
            navBarFrame.origin.x = self.toVC.view.frame.origin.x;
            navBar.frame = navBarFrame;
            navBarFrame.origin.x = 0;
            [self.containerView insertSubview:self.navBar belowSubview:suspensionView];
            // 导航栏removeAllAnimations之后就会置顶显示，为了盖住导航栏，需要将浮窗的zPosition增加
            suspensionView.layer.zPosition = 1;
        }
    }
    
    // 触发了【setNavigationBarHidden:animated:】之后tabBar也会自动添加一个系统动画，将之移除
    CGRect tabBarFrame = CGRectZero;
    if (self.tabBar) {
        [self.tabBar.layer removeAllAnimations];
        tabBarFrame = self.tabBar.frame;
        tabBarFrame.origin.x = self.toVC.view.frame.origin.x;
        self.tabBar.frame = tabBarFrame;
        tabBarFrame.origin.x = 0;
    }
    
    UIViewAnimationOptions options = self.isInteraction ? UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseOut;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        if (self.tabBar) self.tabBar.frame = tabBarFrame;
        if (self.navBar) self.navBar.frame = navBarFrame;
        self.toVC.view.frame = toVCFrame;
        suspensionView.frame = fromVCFrame;
    } completion:^(BOOL finished) {
        if (!self.isShrinkSuspension) {
            [self transitionCompletion];
        }
    }];
}

- (void)spreadSuspensionViewAnimation {
    NSTimeInterval duration = [self transitionDuration:self.transitionContext];
    
    // 当toVC.edgesForExtendedLayout为UIRectEdgeNone的情况下
    // toVC.view的y值为导航栏的最大高度，若没有导航栏的话toVC.view应该为窗口大小
    if (self.isHideToVCNavBar) self.toVC.view.frame = JPSEInstance.window.bounds;
    
    CGRect suspensionFrame = [self.suspensionView.superview convertRect:self.suspensionView.frame toView:self.toVC.view];
    self.suspensionView.alpha = 0;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:suspensionFrame cornerRadius:suspensionFrame.size.width * 0.5].CGPath;
    [self.toVC.view.layer addSublayer:maskLayer];
    self.toVC.view.layer.mask = maskLayer;
    
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0;
    
    [self.containerView addSubview:self.fromVC.view];
    [self.containerView addSubview:self.tabBar];
    [self.containerView addSubview:bgView];
    [self.containerView addSubview:self.toVC.view];
    self.bgView = bgView;
    
    UINavigationController *navCtr = self.toVC.navigationController;
    UINavigationBar *navBar = navCtr.navigationBar;
    [navCtr setNavigationBarHidden:self.isHideToVCNavBar animated:YES];
    if (navBar && navBar.superview) {
        self.navBar = navBar;
        self.navBarSuperView = navBar.superview;
        self.navBarIndex = [navBar.superview.subviews indexOfObject:navBar];
        if (self.isHideToVCNavBar) [self.containerView insertSubview:self.navBar belowSubview:bgView];
    }
    
    // 触发了【setNavigationBarHidden:animated:】之后tabBar也会自动添加一个系统动画，将之移除
    CGRect tabBarFrame = CGRectZero;
    if (self.tabBar) {
        [self.tabBar.layer removeAllAnimations];
        tabBarFrame = self.tabBar.frame;
        tabBarFrame.origin.x = 0;
        self.tabBar.frame = tabBarFrame;
        if (!self.isHideToVCNavBar) tabBarFrame.origin.x = JPSEInstance.window.bounds.size.width;
    }
    
    [JPSEInstance playSoundForSpread:YES delay:duration * 0.25];
    
    CGRect rect = self.toVC.view.bounds;
    UIBezierPath *toPath1 = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:suspensionFrame.size.width * 0.5];
    UIBezierPath *toPath2 = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:0.1];
    CAKeyframeAnimation *kfAnim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    kfAnim.values = @[(id)maskLayer.path, (id)toPath1.CGPath, (id)toPath2.CGPath];
    kfAnim.keyTimes = @[@0, @(4.0 / 5.0), @(1)];
    kfAnim.duration = duration;
    kfAnim.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    kfAnim.fillMode = kCAFillModeForwards;
    kfAnim.removedOnCompletion = NO;
    [maskLayer addAnimation:kfAnim forKey:@"path"];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        bgView.alpha = 1;
        if (self.tabBar) self.tabBar.frame = tabBarFrame;
    } completion:^(BOOL finished) {
        [self transitionCompletion];
    }];
}

- (void)shrinkSuspensionViewAnimation {
    NSTimeInterval duration = [self transitionDuration:self.transitionContext];
    
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    
    [self.containerView addSubview:self.toVC.view];
    [self.containerView addSubview:self.tabBar];
    [self.containerView addSubview:bgView];
    self.bgView = bgView;
    
    UINavigationController *navCtr = self.toVC.navigationController;
    UINavigationBar *navBar = navCtr.navigationBar;
    [navCtr setNavigationBarHidden:self.isHideToVCNavBar animated:YES];
    if (navBar && navBar.superview) {
        self.navBar = navBar;
        self.navBarSuperView = navBar.superview;
        self.navBarIndex = [navBar.superview.subviews indexOfObject:navBar];
        if (self.isHideFromVCNavBar) [self.containerView insertSubview:self.navBar belowSubview:bgView];
    }
    
    // 触发了【setNavigationBarHidden:animated:】之后tabBar也会自动添加一个系统动画，将之移除
    if (self.tabBar) {
        [self.tabBar.layer removeAllAnimations];
        CGRect tabBarFrame = self.tabBar.frame;
        tabBarFrame.origin.x = 0;
        self.tabBar.frame = tabBarFrame;
    }
    
    self.isCurrSuspensionView = JPSEInstance.suspensionView == self.suspensionView;
    if (self.isCurrSuspensionView) {
        CGRect suspensionFrame = [self.suspensionView.superview convertRect:self.suspensionView.frame toView:self.fromVC.view];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.fromVC.view.bounds cornerRadius:0.1].CGPath;
        [self.fromVC.view.layer addSublayer:maskLayer];
        self.fromVC.view.layer.mask = maskLayer;
        
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
        [self.containerView addSubview:self.suspensionView];
        [self.suspensionView shrinkSuspensionViewAnimationWithComplete:nil];
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self transitionCompletion];
    }];
}

#pragma mark - 转场结束

- (void)transitionCompletion {
    if (self.isTransitionCompletion) return;
    self.isTransitionCompletion = YES;
    
    [self.tabBarSuperView insertSubview:self.tabBar atIndex:self.tabBarIndex];
    [self.navBarSuperView insertSubview:self.navBar atIndex:self.navBarIndex];
    
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
        // 如果fromVC本来就隐藏了导航栏，我pop的时候移除了它本来的系统动画，这里取消了就要将导航栏恢复
        if (self.isHideFromVCNavBar) {
            [self.toVC.navigationController setNavigationBarHidden:self.isHideFromVCNavBar animated:YES];
        } else {
            // iOS8中这里的navBar的alpha为0
            [self.navBar.layer removeAllAnimations];
            self.navBar.alpha = 1;
        }
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
    [self.transitionContext completeTransition:YES];
}

- (void)shrinkSuspensionViewTransitionCompletion {
    if (self.isCurrSuspensionView) [JPSEInstance insertTransitionView:self.fromVC.view];
    [UIView animateWithDuration:0.2 animations:^{
        self.suspensionView.alpha = 1;
        if (self.isCurrSuspensionView) self.fromVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self.fromVC.view removeFromSuperview];
        self.fromVC.view.alpha = 1;
        self.fromVC.view.layer.mask = nil;
        [self.transitionContext completeTransition:YES];
    }];
}

@end
