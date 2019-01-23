//
//  JPSuspensionEntrance.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPSuspensionEntrance.h"
#import "JPPopInteraction.h"
#import "JPSuspensionTransition.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JPSuspensionEntrance () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) JPPopInteraction *popInteraction;

@property (nonatomic, strong) JPSuspensionTransition *suspensionTransition;

@property (nonatomic, strong) JPSuspensionView *popNewSuspensionView;

@property (nonatomic, assign) BOOL isFromSpreadSuspensionView;

@end

@implementation JPSuspensionEntrance
{
    CGFloat _suspensionScreenEdgeBottomInset;
}

#pragma mark - const

static JPSuspensionEntrance *_sharedInstance;

#pragma mark - single init

+ (instancetype)sharedInstance {
    if(_sharedInstance == nil) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super init];
        [_sharedInstance setup];
    });
    return _sharedInstance;
}

#pragma mark - setup

- (void)setup {
    _window = [UIApplication sharedApplication].keyWindow;
    [self setupBase];
    [self setupPopInteraction];
    [self setupNotificationCenter];
}

- (void)setupBase {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat scale = screenW / 375.0;
    BOOL isIphoneX = MAX(screenW, screenH) > 736.0;
    
    _suspensionViewWH = 64.0 * scale;
    _suspensionLogoMargin = 7.0 * scale;
    _suspensionScreenEdgeInsets = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 15.0, isIphoneX ? 34.0 : 0, 15.0);
    _suspensionScreenEdgeBottomInset = _suspensionScreenEdgeInsets.bottom;
    
    CGFloat x;
    CGFloat y;
    if (screenW < screenH) {
        x = MIN(screenW, screenH);
        y = MAX(screenW, screenH);
    } else {
        x = MAX(screenW, screenH);
        y = MIN(screenW, screenH);
    }
    x = _suspensionScreenEdgeInsets.left;
    y = _suspensionScreenEdgeInsets.top;
    _suspensionFrame = CGRectMake(x, y, self.suspensionViewWH, self.suspensionViewWH);
    
    CGFloat imageScale = [UIScreen mainScreen].scale;
    if (imageScale < 2) imageScale = 2;
    if (imageScale > 3) imageScale = 3;
    NSString *imageScaleStr = [NSString stringWithFormat:@"%.0lf", imageScale];
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *bundleName = [NSString stringWithFormat:@"%@.bundle", bundle.infoDictionary[@"CFBundleName"]];
    NSString *type = @"png";
    
    self.suspensiconIconPath = [bundle pathForResource:[NSString stringWithFormat:@"circle_little@%@x", imageScaleStr] ofType:type inDirectory:bundleName];
    self.confimSuspensionIconPath = [bundle pathForResource:[NSString stringWithFormat:@"circle_big@%@x", imageScaleStr] ofType:type inDirectory:bundleName];
    self.removeSuspensionIconPath = [bundle pathForResource:[NSString stringWithFormat:@"circle_delete@%@x", imageScaleStr] ofType:type inDirectory:bundleName];
}

- (void)setupPopInteraction {
    self.popInteraction = [[JPPopInteraction alloc] init];
    self.popInteraction.edgeLeftPanGR.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    
    self.popInteraction.panBegan = ^(UIScreenEdgePanGestureRecognizer *edgeLeftPanGR) {
        if (!weakSelf) return;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.navCtr popViewControllerAnimated:YES];
        if (!strongSelf.isFromSpreadSuspensionView) {
            strongSelf.decideView.isDecideDelete = NO;
        }
    };
    
    self.popInteraction.panChanged = ^(CGFloat persent, UIScreenEdgePanGestureRecognizer *edgeLeftPanGR) {
        if (!weakSelf) return;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        CGFloat kPersent = persent * 2.0;
        if (kPersent > 1) kPersent = 1;
        if (strongSelf.isFromSpreadSuspensionView) {
            strongSelf.suspensionView.alpha = kPersent;
        } else {
            if (strongSelf.popInteraction.interaction) {
                CGPoint point = [edgeLeftPanGR locationInView:strongSelf.window];
                strongSelf.decideView.showPersent = kPersent;
                strongSelf.decideView.touchPoint = point;
            }
        }
    };
    
    self.popInteraction.panWillEnded = ^(BOOL isToFinish, UIScreenEdgePanGestureRecognizer *edgeLeftPanGR) {
        if (!weakSelf) return;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.isFromSpreadSuspensionView) {
            if (isToFinish) {
                strongSelf.suspensionTransition.isShrinkSuspension = YES;
                [strongSelf.suspensionTransition.suspensionView shrinkSuspensionViewAnimationWithComplete:^{
                    [strongSelf.suspensionTransition transitionCompletion];
                }];
            }
        } else {
            if (strongSelf.decideView.isTouch) {
                strongSelf.suspensionTransition.isShrinkSuspension = YES;
                [strongSelf.suspensionTransition.suspensionView shrinkSuspensionViewAnimationWithComplete:^{
                    [strongSelf.suspensionTransition transitionCompletion];
                }];
            }
            [strongSelf.decideView hideWithSuspensionView:nil];
        }
    };
    
    self.popInteraction.panEnded = ^(BOOL isFinish, UIScreenEdgePanGestureRecognizer *edgeLeftPanGR) {
        if (!weakSelf) return;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf.suspensionTransition.isShrinkSuspension) {
            [strongSelf.suspensionTransition transitionCompletion];
        }
        if (strongSelf.isFromSpreadSuspensionView) {
            strongSelf.suspensionView.alpha = isFinish ? 1 : 0;
            strongSelf.isFromSpreadSuspensionView = NO;
        } else {
            [strongSelf.decideView hideWithSuspensionView:nil];
        }
    };
}

- (void)setupNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - getter

- (JPSuspensionDecideView *)decideView {
    if (!_decideView) {
        _decideView = [JPSuspensionDecideView suspensionDecideView];
        if (self.suspensionView) {
            [self.window insertSubview:_decideView belowSubview:self.suspensionView];
        } else {
            [self.window addSubview:_decideView];
        }
    }
    return _decideView;
}

#pragma mark - setter

- (void)setWindow:(UIWindow *)window {
    _window = window;
    [window addSubview:_decideView];
    [window addSubview:_suspensionView];
}

- (void)setNavCtr:(UINavigationController *)navCtr {
    if (_navCtr && _navCtr == navCtr) return;
    if (_navCtr) {
        _navCtr.delegate = nil;
        _navCtr.interactivePopGestureRecognizer.delegate = self;
        [_navCtr.view removeGestureRecognizer:self.popInteraction.edgeLeftPanGR];
    }
    _navCtr = navCtr;
    
    navCtr.delegate = self;
    navCtr.interactivePopGestureRecognizer.delegate = self;
    [navCtr.view addGestureRecognizer:self.popInteraction.edgeLeftPanGR];
}

- (void)setIsHideNavBar:(BOOL)isHideNavBar {
    _isHideNavBar = isHideNavBar;
    if (self.navCtr.viewControllers.count == 1 || ![self.navCtr.viewControllers.lastObject conformsToProtocol:@protocol(JPSuspensionEntranceProtocol)]) {
        [self.navCtr setNavigationBarHidden:isHideNavBar animated:NO];
    }
}

- (void)setSuspensionView:(JPSuspensionView *)suspensionView {
    if (self.popNewSuspensionView) {
        if (self.popNewSuspensionView != suspensionView) {
            [self.popNewSuspensionView removeFromSuperview];
        }
        self.popNewSuspensionView = nil;
    }
    
    _suspensionView.tapGR.delegate = nil;
    _suspensionView.panGR.delegate = nil;
    _suspensionView.panBegan = nil;
    _suspensionView.panChanged = nil;
    _suspensionView.panEnded = nil;
    _suspensionView.suspensionFrameDidChanged = nil;
    [_suspensionView removeFromSuperview];
    
    _suspensionView = suspensionView;
    
    NSString *cacheMsg = nil;
    if (suspensionView) {
        if (suspensionView.superview && suspensionView.superview != self.window) suspensionView.frame = [suspensionView.superview convertRect:suspensionView.frame toView:self.window];
        [self.window addSubview:suspensionView];
        
        suspensionView.tapGR.delegate = self;
        suspensionView.panGR.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        
        suspensionView.panBegan = ^(UIPanGestureRecognizer *panGR) {
            if (!weakSelf) return;
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.decideView.isDecideDelete = YES;
            [strongSelf.decideView show];
        };
        
        suspensionView.panChanged = ^(UIPanGestureRecognizer *panGR) {
            if (!weakSelf) return;
            __strong typeof(weakSelf) strongSelf = weakSelf;
            CGPoint point = [panGR locationInView:strongSelf.window];
            strongSelf.decideView.touchPoint = point;
        };
        
        suspensionView.panEnded = ^BOOL(JPSuspensionView *targetSuspensionView, UIPanGestureRecognizer *panGR) {
            if (!weakSelf) return NO;
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.decideView hideWithSuspensionView:(strongSelf.decideView.isTouch ? targetSuspensionView : nil)];
            return strongSelf.decideView.isTouch;
        };
        
        suspensionView.suspensionFrameDidChanged = ^(CGRect suspensionFrame) {
            if (!weakSelf) return;
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.suspensionFrame = suspensionFrame;
        };
        
        if ([suspensionView.targetVC respondsToSelector:@selector(jp_suspensionCacheMsg)]) {
            cacheMsg = [suspensionView.targetVC jp_suspensionCacheMsg];
        }
    }
    
    !self.cacheMsgBlock ? : self.cacheMsgBlock(cacheMsg);
}

- (void)setSuspensionFrame:(CGRect)suspensionFrame {
    _suspensionFrame = suspensionFrame;
    !self.cacheSuspensionFrameBlock ? : self.cacheSuspensionFrameBlock(suspensionFrame);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notification method

- (void)didChangeStatusBarOrientation {
    [self fixSuspensionFrame];
    [self.suspensionView updateSuspensionFrame:self.suspensionFrame animated:YES];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    if (!self.suspensionView) return;
    NSDictionary *userInfo = notification.userInfo;
    CGFloat keyboardY = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat alpha = keyboardY < CGRectGetMaxY(self.suspensionFrame) ? 0 : 1;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.suspensionView.alpha = alpha;
    }];
}

#pragma mark - private method

- (void)fixSuspensionFrame {
    CGFloat x = self.suspensionFrame.origin.x;
    CGFloat y = self.suspensionFrame.origin.y;
    CGFloat w = self.suspensionViewWH;
    CGFloat h = self.suspensionViewWH;
    if (x < self.suspensionScreenEdgeInsets.left) x = self.suspensionScreenEdgeInsets.left;
    if (CGRectGetMaxX(self.suspensionFrame) > self.window.bounds.size.width - self.suspensionScreenEdgeInsets.right) x = self.window.bounds.size.width - self.suspensionScreenEdgeInsets.right - w;
    if (y < self.suspensionScreenEdgeInsets.top) y = self.suspensionScreenEdgeInsets.top;
    if (CGRectGetMaxY(self.suspensionFrame) > (self.window.bounds.size.height - self.suspensionScreenEdgeInsets.bottom)) y = self.window.bounds.size.height - self.suspensionScreenEdgeInsets.bottom - h;
    self.suspensionFrame = CGRectMake(x, y, w, h);
}

#pragma mark - public method

- (void)setupSuspensionViewWithTargetVC:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC suspensionXY:(CGPoint)suspensionXY {
    _suspensionFrame = CGRectMake(suspensionXY.x, suspensionXY.y, _suspensionViewWH, _suspensionViewWH);
    [self fixSuspensionFrame];
    JPSuspensionView *suspensionView = [JPSuspensionView suspensionViewWithViewController:targetVC isSuspensionState:YES];
    self.suspensionView = suspensionView;
}

- (void)insertTransitionView:(UIView *)transitionView {
    if (_suspensionView && transitionView == _suspensionView) {
        [self.window addSubview:transitionView];
    } else {
        if (_decideView) {
            [self.window insertSubview:transitionView belowSubview:_decideView];
        } else if (_suspensionView) {
            [self.window insertSubview:transitionView belowSubview:_suspensionView];
        } else {
            [self.window addSubview:transitionView];
        }
    }
}

- (void)playSoundForSpread:(BOOL)isSpread delay:(NSTimeInterval)delay {
    if (!self.canPlaySound) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isSpread) {
            if (self.playSpreadSoundBlock) {
                self.playSpreadSoundBlock();
            } else {
                AudioServicesPlaySystemSound(1397);
            }
        } else {
            if (self.playShrinkSoundBlock) {
                self.playShrinkSoundBlock();
            } else {
                AudioServicesPlaySystemSound(1396);
            }
        }
    });
}

- (void)pushViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC {
    if (!targetVC) return;
    !self.willSpreadSuspensionViewControllerBlock ? : self.willSpreadSuspensionViewControllerBlock(targetVC);
    [self.navCtr pushViewController:targetVC animated:YES];
}

- (void)popViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC {
    if (!targetVC) return;
    self.popNewSuspensionView = [JPSuspensionView suspensionViewWithViewController:targetVC];
    [self.navCtr popViewControllerAnimated:YES];
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    BOOL isPush = operation == UINavigationControllerOperationPush;
    self.suspensionTransition = nil;
    BOOL isToVCConformsToProtocol = [toVC conformsToProtocol:@protocol(JPSuspensionEntranceProtocol)];
    if (isPush) {
        // 当fromVC.edgesForExtendedLayout为UIRectEdgeNone的情况下
        // fromVC.view的y值为导航栏的最大高度，保存此时frame
        fromVC.jp_apearFrame = fromVC.view.frame;
        if (!isToVCConformsToProtocol) return nil;
        if (self.suspensionView && self.suspensionView.targetVC == toVC) {
            self.suspensionTransition = [JPSuspensionTransition spreadTransitionWithSuspensionView:self.suspensionView];
        }
    } else {
        if (![fromVC conformsToProtocol:@protocol(JPSuspensionEntranceProtocol)]) return nil;
        if (!self.popInteraction.interaction) {
            // 不是通过手势滑动
            if (self.popNewSuspensionView) {
                // 1.创建新的浮窗
                self.suspensionTransition = [JPSuspensionTransition shrinkTransitionWithSuspensionView:self.popNewSuspensionView];
            } else if (self.suspensionView && self.suspensionView.targetVC == fromVC) {
                // 2.闭合已经展开的浮窗
                self.suspensionTransition = [JPSuspensionTransition shrinkTransitionWithSuspensionView:self.suspensionView];
            }
            // 3.都不是以上两种情况，返回nil
        } else {
            // 判断之前是否从浮窗进入的控制器
            self.isFromSpreadSuspensionView = fromVC == self.suspensionView.targetVC;
            self.suspensionTransition = [JPSuspensionTransition basicPopTransitionWithIsInteraction:self.popInteraction.interaction];
        }
    }
    if (!self.suspensionTransition) {
        BOOL isHideNavBar = isToVCConformsToProtocol ? [(UIViewController<JPSuspensionEntranceProtocol> *)toVC jp_isHideNavigationBar] : JPSEInstance.isHideNavBar;
        [navigationController setNavigationBarHidden:isHideNavBar animated:YES];
    }
    return self.suspensionTransition;
}

/**
 * 如果上面方法返回是nil，改方法是不会调用的，也就是说，只有自定义的动画才可以与控制器交互
 */
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:JPSuspensionTransition.class] &&
        self.popInteraction.interaction) return self.popInteraction;
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.navCtr.interactivePopGestureRecognizer ||
        gestureRecognizer == self.popInteraction.edgeLeftPanGR) {
        if (self.navCtr.viewControllers.count <= 1) {
            return NO;
        }
        BOOL conformsToProtocol = [self.navCtr.viewControllers.lastObject conformsToProtocol:@protocol(JPSuspensionEntranceProtocol)];
        if (gestureRecognizer == self.navCtr.interactivePopGestureRecognizer && conformsToProtocol) {
            return NO;
        }
        if (gestureRecognizer == self.popInteraction.edgeLeftPanGR) {
            if (!conformsToProtocol || (self.suspensionView.panGR.state == UIGestureRecognizerStateBegan || self.suspensionView.panGR.state == UIGestureRecognizerStateChanged) ) {
                return NO;
            }
        }
    }
    if (gestureRecognizer == self.suspensionView.panGR) {
        if (self.popInteraction.edgeLeftPanGR.state == UIGestureRecognizerStateBegan || self.popInteraction.edgeLeftPanGR.state == UIGestureRecognizerStateChanged) {
            return NO;
        }
    }
    return YES;
}

@end
