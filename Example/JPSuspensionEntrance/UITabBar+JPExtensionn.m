//
//  UITabBar+JPExtensionn.m
//  JPSuspensionEntrance_Example
//
//  Created by 周健平 on 2019/7/24.
//  Copyright © 2019 Rogue24. All rights reserved.
//

#import "UITabBar+JPExtensionn.h"
#import <objc/runtime.h>

@implementation UITabBar (JPExtensionn)

CG_INLINE BOOL
OverrideImplementation(Class targetClass, SEL targetSelector, id (^implementationBlock)(Class originClass, SEL originCMD, IMP originIMP)) {
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    if (!originMethod) {
        return NO;
    }
    IMP originIMP = method_getImplementation(originMethod);
    method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originIMP)));
    return YES;
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#pragma mark - 针对 iOS 12.1 的处理
        /**
         * 参考：https://github.com/ChenYilong/CYLTabBarController/issues/312
         * 这个问题是 iOS 12.1 Beta 2 的问题，只要 UITabBar 是磨砂的，并且 push viewController 时 hidesBottomBarWhenPushed = YES 则手势返回的时候就会触发。
         * 出现这个现象的直接原因是 tabBar 内的按钮 UITabBarButton 被设置了错误的 frame，frame.size 变为 (0, 0) 导致的。如果12.1正式版Apple修复了这个bug可以移除调这段代码（来源于QMUIKit的处理方式）
         */
        if (@available(iOS 12.1, *)) {
            OverrideImplementation(NSClassFromString(@"UITabBarButton"), @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP originIMP) {
                return ^(UIView *selfObject, CGRect firstArgv) {
                    
                    if ([selfObject isKindOfClass:originClass]) {
                        // 如果发现即将要设置一个 size 为空的 frame，则屏蔽掉本次设置
                        if (!CGRectIsEmpty(selfObject.frame) && CGRectIsEmpty(firstArgv)) {
                            return;
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, CGRect);
                    originSelectorIMP = (void (*)(id, SEL, CGRect))originIMP;
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                };
            });
        }
        
#pragma mark - 针对 iOS 15 的处理
        /**
         * 在iOS 15的Tabbar会莫名其妙的变大，高度会一瞬间变大49然后还原，视觉上就是跳动了一下
         * 因此这里临时处理一下：强制设置默认的frame（PS：此Demo只考虑【竖屏】的情况）
         */
        if (@available(iOS 15, *)) {
            Method originalMethod = class_getInstanceMethod(self, @selector(setFrame:));
            Method swizzledMethod = class_getInstanceMethod(self, @selector(jp_setFrame:));
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

- (void)jp_setFrame:(CGRect)frame {
    if (frame.size.height > JPTabBarH) {
        frame.size.height = JPTabBarH;
        frame.origin.y = JPPortraitScreenHeight - JPTabBarH;
    }
    [self jp_setFrame:frame];
}

@end
