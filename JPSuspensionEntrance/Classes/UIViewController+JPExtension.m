//
//  UIViewController+JPExtension.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/9/5.
//

#import "UIViewController+JPExtension.h"
#import <objc/runtime.h>

@implementation UIViewController (JPExtension)

static const char JP_ApearFrame = '\0';
- (void)setJp_apearFrame:(CGRect)jp_apearFrame {
    [self willChangeValueForKey:@"jp_apearFrame"]; // KVO
    objc_setAssociatedObject(self, &JP_ApearFrame, @(jp_apearFrame), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"jp_apearFrame"];
}

- (CGRect)jp_apearFrame {
    return [objc_getAssociatedObject(self, &JP_ApearFrame) CGRectValue];
}

@end
