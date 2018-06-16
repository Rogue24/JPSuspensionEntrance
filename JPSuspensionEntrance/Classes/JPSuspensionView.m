//
//  JPSuspensionView.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPSuspensionView.h"
#import "JPSuspensionEntrance.h"

@interface JPSuspensionView ()
@property (nonatomic, weak) UIVisualEffectView *effectView;
@property (nonatomic, weak) UIView *snapshotView;
@property (nonatomic, weak) UIImageView *logoView;
@property (nonatomic, weak) CAShapeLayer *maskLayer;
- (CGFloat)suspensionViewWH;
- (CGFloat)suspensionLogoMargin;
- (UIEdgeInsets)suspensionScreenEdgeInsets;
@end

@implementation JPSuspensionView

- (CGFloat)suspensionViewWH {
    return JPSEInstance.suspensionViewWH;
}

- (CGFloat)suspensionLogoMargin {
    return JPSEInstance.suspensionLogoMargin;
}

- (UIEdgeInsets)suspensionScreenEdgeInsets {
    return JPSEInstance.suspensionScreenEdgeInsets;
}

+ (JPSuspensionView *)suspensionViewWithViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC {
    return [self suspensionViewWithViewController:targetVC isSuspensionState:NO];
}

+ (JPSuspensionView *)suspensionViewWithViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC isSuspensionState:(BOOL)isSuspensionState {
    JPSuspensionView *suspensionView = [[self alloc] initWithTargetVC:targetVC isSuspensionState:isSuspensionState];
    return suspensionView;
}

- (instancetype)initWithTargetVC:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC isSuspensionState:(BOOL)isSuspensionState {
    if (self = [super init]) {
        _isSuspensionState = isSuspensionState;
        self.targetVC = targetVC;
        self.userInteractionEnabled = isSuspensionState;
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushTargetVC)];
        [self addGestureRecognizer:tapGR];
        self.tapGR = tapGR;
        
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
        [self addGestureRecognizer:panGR];
        self.panGR = panGR;
        
        self.frame = isSuspensionState ? JPSEInstance.suspensionFrame : targetVC.view.bounds;
        
        if ([targetVC respondsToSelector:@selector(jp_suspensionLogoImage)]) {
            UIImage *logoImage = [targetVC jp_suspensionLogoImage];
            if (logoImage) {
                [self createLogoView];
                self.logoView.image = logoImage;
            }
        }

        if (isSuspensionState) {
            self.layer.cornerRadius = self.bounds.size.height * 0.5;
            self.layer.masksToBounds = YES;
            [self createEffectView];
        } else {
            UIView *snapshotView = [targetVC.view snapshotViewAfterScreenUpdates:NO];
            snapshotView.layer.shadowPath = [UIBezierPath bezierPathWithRect:snapshotView.bounds].CGPath;
            snapshotView.layer.shadowOpacity = 1.0;
            snapshotView.layer.shadowRadius = 10.0;
            snapshotView.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.35].CGColor;
            [self addSubview:snapshotView];
            self.snapshotView = snapshotView;
            
            self.logoView.layer.opacity = 0;
        }
    }
    return self;
}

- (void)createLogoView {
    if (self.logoView) return;
    CGFloat x = self.bounds.size.width * (self.suspensionLogoMargin / self.suspensionViewWH);
    CGFloat wh = self.bounds.size.width - 2 * x;
    CGFloat y = (self.bounds.size.height - wh) * 0.5;
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, wh, wh)];
    logoView.contentMode = UIViewContentModeScaleAspectFill;
    logoView.layer.cornerRadius = wh * 0.5;
    logoView.layer.masksToBounds = YES;
    [self addSubview:logoView];
    self.logoView = logoView;
}

- (void)createEffectView {
    if (self.effectView) return;
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.frame = CGRectInset(self.bounds, -1, -1);
    [self insertSubview:effectView atIndex:0];
    self.effectView = effectView;
}

- (void)shrinkSuspensionViewAnimation {
    if (_isSuspensionState) return;
    _isSuspensionState = YES;
    
    self.userInteractionEnabled = NO;
    
    BOOL isHideNavigationBar = [self.targetVC respondsToSelector:@selector(jp_isHideNavigationBar)] && [self.targetVC jp_isHideNavigationBar];
    
    CGRect frame = self.layer.presentationLayer ? self.layer.presentationLayer.frame : self.layer.frame;
    [self.layer removeAllAnimations];
    self.layer.transform = CATransform3DIdentity;
    self.layer.zPosition = 0;
    
    if (isHideNavigationBar) {
        self.frame = [JPSEInstance.window convertRect:frame fromView:JPSEInstance.window];
        [JPSEInstance insertTransitionView:self];
    } else {
        self.frame = [JPSEInstance.navCtr.view convertRect:frame fromView:JPSEInstance.navCtr.view];
        [JPSEInstance.navCtr.view insertSubview:self belowSubview:JPSEInstance.navCtr.navigationBar];
    }
    
    [self createEffectView];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.snapshotView.bounds cornerRadius:0.1].CGPath;
    [self.layer addSublayer:maskLayer];
    self.maskLayer = maskLayer;
    self.layer.mask = self.maskLayer;
    
    NSTimeInterval duration = 0.375;
    
    [JPSEInstance playSoundForSpread:NO delay:duration * 0.5];
    
    UIBezierPath *toPath1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, frame.size.width, frame.size.height) cornerRadius:frame.size.width * 0.5];
    UIBezierPath *toPath2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, (frame.size.height - frame.size.width) * 0.5, frame.size.width, frame.size.width) cornerRadius:frame.size.width * 0.5];
    CAKeyframeAnimation *kfAnim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    kfAnim.values = @[(id)self.maskLayer.path, (id)toPath1.CGPath, (id)toPath2.CGPath];
    kfAnim.keyTimes = @[@0, @0.5, @(1)];
    kfAnim.duration = duration;
    kfAnim.beginTime = CACurrentMediaTime();
    kfAnim.fillMode = kCAFillModeForwards;
    kfAnim.removedOnCompletion = NO;
    [self.maskLayer addAnimation:kfAnim forKey:@"path"];
    
    CGFloat toScale = self.suspensionViewWH / frame.size.width;
    CGPoint toPos = CGPointMake(CGRectGetMidX(JPSEInstance.suspensionFrame), CGRectGetMidY(JPSEInstance.suspensionFrame));
    CATransform3D transform = self.layer.transform;
    transform = CATransform3DMakeTranslation(toPos.x - self.layer.position.x, toPos.y - self.layer.position.y, 0);
    transform = CATransform3DScale(transform, toScale, toScale, 1);
    
    [UIView animateWithDuration:duration delay:0 options:kNilOptions animations:^{
        JPSEInstance.suspensionView.alpha = 0;
        self.snapshotView.layer.opacity = 0;
        self.logoView.layer.opacity = 1;
        self.layer.transform = transform;
    } completion:^(BOOL finished) {
        JPSEInstance.suspensionView = self;
        
        [self.snapshotView removeFromSuperview];
        [self.maskLayer removeFromSuperlayer];
        
        self.layer.transform = CATransform3DIdentity;
        self.layer.cornerRadius = self.suspensionViewWH * 0.5;
        self.layer.masksToBounds = YES;
        self.layer.mask = nil;
        self.frame = JPSEInstance.suspensionFrame;
        
        self.effectView.frame = CGRectInset(self.bounds, -1, -1);
        
        if (self.logoView) {
            CGFloat logoMargin = self.suspensionLogoMargin;
            self.logoView.frame = CGRectInset(self.bounds, logoMargin, logoMargin);
            self.logoView.layer.cornerRadius = self.logoView.frame.size.height * 0.5;
        }
        
        self.userInteractionEnabled = YES;
    }];
}

#pragma mark - 手势控制

- (void)pushTargetVC {
    [JPSEInstance pushViewController:self.targetVC];
}

- (void)panHandle:(UIPanGestureRecognizer *)panGR {
    
    CGPoint transition = [panGR translationInView:self];
    [panGR setTranslation:CGPointZero inView:self];
    
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan:
        {
            !self.panBegan ? : self.panBegan(panGR);
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat x = self.frame.origin.x + transition.x;
            CGFloat y = self.frame.origin.y + transition.y;
            CGFloat maxX = self.superview.bounds.size.width - self.frame.size.width;
            CGFloat maxY = self.superview.bounds.size.height - self.frame.size.height;
            if (x < 0) x = 0;
            if (x > maxX) x = maxX;
            if (y < 0) y = 0;
            if (y > maxY) y = maxY;
            self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
            !self.panChanged ? : self.panChanged(panGR);
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (!self.userInteractionEnabled) return;
            
            BOOL isDelete = NO;
            if (self.panEnded) {
                isDelete = self.panEnded(self, panGR);
            }
            if (isDelete) return;
            
            BOOL isToLeft = CGRectGetMidX(self.frame) < self.superview.bounds.size.width * 0.5;
            CGFloat x;
            CGFloat y = self.frame.origin.y;
            CGFloat w = self.frame.size.width;
            CGFloat h = self.frame.size.height;
            if (isToLeft) {
                x = self.suspensionScreenEdgeInsets.left;
            } else {
                x = self.superview.bounds.size.width - self.suspensionScreenEdgeInsets.right - w;
            }
            if (y < self.suspensionScreenEdgeInsets.top) y = self.suspensionScreenEdgeInsets.top;
            if (CGRectGetMaxY(self.frame) > (self.superview.bounds.size.height - self.suspensionScreenEdgeInsets.bottom)) y = self.superview.bounds.size.height - self.suspensionScreenEdgeInsets.bottom - h;
            CGRect suspensionFrame = CGRectMake(x, y, w, h);
            !self.suspensionFrameDidChanged ? : self.suspensionFrameDidChanged(suspensionFrame);
            [self updateSuspensionFrame:suspensionFrame animated:YES];
            break;
        }
        default:
            break;
    }
    
}

- (void)updateSuspensionFrame:(CGRect)suspensionFrame animated:(BOOL)animated {
    if (JPSEInstance.suspensionView != self) return;
    if (animated) {
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.55 delay:0 usingSpringWithDamping:0.78 initialSpringVelocity:0.1 options:kNilOptions animations:^{
            self.frame = suspensionFrame;
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    } else {
        self.frame = suspensionFrame;
        self.userInteractionEnabled = YES;
    }
}

@end
