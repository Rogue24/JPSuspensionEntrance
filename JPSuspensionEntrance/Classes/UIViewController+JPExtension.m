//
//  UIViewController+JPExtension.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/9/5.
//

#import "UIViewController+JPExtension.h"
#import <objc/runtime.h>

@implementation UIViewController (JPExtension)

static const char JPApearFrameKey = '\0';
- (void)setJp_apearFrame:(CGRect)jp_apearFrame {
    objc_setAssociatedObject(self, &JPApearFrameKey, @(jp_apearFrame), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGRect)jp_apearFrame {
    return [objc_getAssociatedObject(self, &JPApearFrameKey) CGRectValue];
}

@end
