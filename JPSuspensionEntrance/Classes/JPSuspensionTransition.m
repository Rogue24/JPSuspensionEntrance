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
            return 0.37;
        }
    }
}

/**
 *  transitionContext你可以看作是一个工具，用来获取一系列动画执行相关的对象，并且通知系统动画是否完成等功能。
 */
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    switch (_transitionType) {
        case JPBasicPopTransitionType:
        {
            [self basicPopAnimationWithContainerView:containerView fromVC:(UIViewController<JPSuspensionEntranceProtocol> *)fromVC toVC:toVC duration:duration transitionContext:transitionContext];
            break;
        }
        case JPSpreadSuspensionViewTransitionType:
        {
            [self spreadSuspensionViewAnimationWithContainerView:containerView fromVC:fromVC toVC:(UIViewController<JPSuspensionEntranceProtocol> *)toVC duration:duration transitionContext:transitionContext];
            break;
        }
        case JPShrinkSuspensionViewTransitionType:
        {
            [self shrinkSuspensionViewAnimationWithContainerView:containerView fromVC:(UIViewController<JPSuspensionEntranceProtocol> *)fromVC toVC:toVC duration:duration transitionContext:transitionContext];
            break;
        }
    }
}

#pragma mark - push & pop 动画

- (void)basicPopAnimationWithContainerView:(UIView *)containerView fromVC:(UIViewController<JPSuspensionEntranceProtocol> *)fromVC toVC:(UIViewController *)toVC duration:(NSTimeInterval)duration transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    toVC.view.layer.transform = CATransform3DMakeTranslation(-[UIScreen mainScreen].bounds.size.width * 0.3, 0, 0);
    [containerView addSubview:toVC.view];
    
    UITabBar *tabBar;
    if (toVC.tabBarController) tabBar = toVC.tabBarController.tabBar;
    [tabBar.layer removeAllAnimations];
    CGRect tabBarFrame = tabBar.frame;
    tabBarFrame.origin.x = toVC.view.frame.origin.x;
    tabBar.frame = tabBarFrame;
    tabBarFrame.origin.x = 0;
    UIView *tabBarSuperView = tabBar.superview;
    NSInteger tabBarIndex = 0;
    if (tabBarSuperView) tabBarIndex = [tabBarSuperView.subviews indexOfObject:tabBar];
    [containerView addSubview:tabBar];
    
    JPSuspensionView *suspensionView = [JPSuspensionView suspensionViewWithViewController:fromVC];
    if ([fromVC respondsToSelector:@selector(jp_isHideNavigationBar)] && [fromVC jp_isHideNavigationBar]) {
        [JPSEInstance insertTransitionView:suspensionView];
    } else {
        [containerView addSubview:suspensionView];
    }
    self.suspensionView = suspensionView;
    
    UIViewAnimationOptions options = self.isInteraction ? UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseOut;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        tabBar.frame = tabBarFrame;
        toVC.view.layer.transform = CATransform3DIdentity;
        suspensionView.layer.transform = CATransform3DMakeTranslation([UIScreen mainScreen].bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        [tabBarSuperView insertSubview:tabBar atIndex:tabBarIndex];
        toVC.view.layer.transform = CATransform3DIdentity;
        if ([transitionContext transitionWasCancelled]) {
            [suspensionView removeFromSuperview];
            [transitionContext completeTransition:NO];
        } else {
            // 1.浮窗的缩小动画跟这里的动画有所不同
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 2.因此进行延迟处理 判断是否添加到窗口上 不是就移除
                if (suspensionView != JPSEInstance.suspensionView) [suspensionView removeFromSuperview];
            });
            [transitionContext completeTransition:YES];
        }
    }];
    
}

- (void)spreadSuspensionViewAnimationWithContainerView:(UIView *)containerView fromVC:(UIViewController *)fromVC toVC:(UIViewController<JPSuspensionEntranceProtocol> *)toVC duration:(NSTimeInterval)duration transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    [containerView addSubview:fromVC.view];
    
    CGRect suspensionFrame = self.suspensionView.frame;
    self.suspensionView.alpha = 0;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:suspensionFrame cornerRadius:suspensionFrame.size.width * 0.5].CGPath;
    [toVC.view.layer addSublayer:maskLayer];
    toVC.view.layer.mask = maskLayer;
    
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0;
    [containerView addSubview:bgView];
    
    UITabBar *tabBar;
    if (fromVC.tabBarController) tabBar = fromVC.tabBarController.tabBar;
    [tabBar.layer removeAllAnimations];
    CGRect tabBarFrame = tabBar.frame;
    tabBarFrame.origin.x = 0;
    tabBar.frame = tabBarFrame;
    tabBarFrame.origin.x = fromVC.view.bounds.size.width;
    UIView *tabBarSuperView = tabBar.superview;
    NSInteger tabBarIndex = 0;
    if (tabBarSuperView) tabBarIndex = [tabBarSuperView.subviews indexOfObject:tabBar];
    [containerView addSubview:tabBar];
    
    if ([toVC respondsToSelector:@selector(jp_isHideNavigationBar)] && [toVC jp_isHideNavigationBar]) {
        [JPSEInstance insertTransitionView:toVC.view];
    } else {
        [containerView addSubview:toVC.view];
    }
    
    UIBezierPath *toPath1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, toVC.view.bounds.size.width, toVC.view.bounds.size.height) cornerRadius:suspensionFrame.size.width * 0.5];
    UIBezierPath *toPath2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, toVC.view.bounds.size.width, toVC.view.bounds.size.height) cornerRadius:0.1];
    CAKeyframeAnimation *kfAnim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    kfAnim.values = @[(id)maskLayer.path, (id)toPath1.CGPath, (id)toPath2.CGPath];
    kfAnim.keyTimes = @[@0, @(4.0 / 5.0), @(1)];
    kfAnim.duration = duration;
    kfAnim.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    kfAnim.fillMode = kCAFillModeForwards;
    kfAnim.removedOnCompletion = NO;
    [maskLayer addAnimation:kfAnim forKey:@"path"];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        tabBar.frame = tabBarFrame;
        bgView.alpha = 1;
    } completion:^(BOOL finished) {
        [tabBarSuperView insertSubview:tabBar atIndex:tabBarIndex];
        [containerView addSubview:toVC.view];
        toVC.view.layer.mask = nil;
        self.suspensionView = nil;
        [bgView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (void)shrinkSuspensionViewAnimationWithContainerView:(UIView *)containerView fromVC:(UIViewController<JPSuspensionEntranceProtocol> *)fromVC toVC:(UIViewController *)toVC duration:(NSTimeInterval)duration transitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    [containerView addSubview:toVC.view];
    
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    [containerView addSubview:bgView];
    
    UITabBar *tabBar;
    if (toVC.tabBarController) tabBar = toVC.tabBarController.tabBar;
    [tabBar.layer removeAllAnimations];
    CGRect tabBarFrame = tabBar.frame;
    tabBarFrame.origin.x = 0;
    tabBar.frame = tabBarFrame;
    UIView *tabBarSuperView = tabBar.superview;
    NSInteger tabBarIndex = 0;
    if (tabBarSuperView) tabBarIndex = [tabBarSuperView.subviews indexOfObject:tabBar];
    [containerView addSubview:tabBar];
    
    JPSuspensionView *currSuspensionView = JPSEInstance.suspensionView;
    if (currSuspensionView == self.suspensionView) {
        CGRect suspensionFrame = self.suspensionView.frame;
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:fromVC.view.bounds cornerRadius:0.1].CGPath;
        [fromVC.view.layer addSublayer:maskLayer];
        fromVC.view.layer.mask = maskLayer;
        
        if ([fromVC respondsToSelector:@selector(jp_isHideNavigationBar)] && [fromVC jp_isHideNavigationBar]) {
            [JPSEInstance insertTransitionView:fromVC.view];
        } else {
            [containerView addSubview:fromVC.view];
        }
        
        UIBezierPath *toPath1 = [UIBezierPath bezierPathWithRoundedRect:fromVC.view.bounds cornerRadius:suspensionFrame.size.width * 0.5];
        UIBezierPath *toPath2 = [UIBezierPath bezierPathWithRoundedRect:suspensionFrame cornerRadius:suspensionFrame.size.width * 0.5];
        CAKeyframeAnimation *kfAnim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        kfAnim.values = @[(id)maskLayer.path, (id)toPath1.CGPath, (id)toPath2.CGPath];
        kfAnim.keyTimes = @[@0, @(1.0 / 5.0), @(1)];
        kfAnim.duration = duration;
        kfAnim.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        kfAnim.fillMode = kCAFillModeForwards;
        kfAnim.removedOnCompletion = NO;
        [maskLayer addAnimation:kfAnim forKey:@"path"];
        
    } else {
        if ([fromVC respondsToSelector:@selector(jp_isHideNavigationBar)] && [fromVC jp_isHideNavigationBar]) {
            [JPSEInstance insertTransitionView:self.suspensionView];
        } else {
            [containerView addSubview:self.suspensionView];
        }
        [self.suspensionView shrinkSuspensionViewAnimation];
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        tabBar.frame = tabBarFrame;
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [tabBarSuperView insertSubview:tabBar atIndex:tabBarIndex];
        self.suspensionView.alpha = 1;
        fromVC.view.layer.mask = nil;
        [fromVC.view removeFromSuperview];
        [bgView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end
