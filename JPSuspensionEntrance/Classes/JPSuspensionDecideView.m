//
//  JPSuspensionDecideView.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/15.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPSuspensionDecideView.h"
#import "JPSuspensionEntrance.h"

@interface JPSuspensionDecideView ()
@property (nonatomic, weak) UIVisualEffectView *effectView;
@property (nonatomic, weak) CALayer *deleteBgLayer;
@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation JPSuspensionDecideView
{
    CGFloat _radius;
    CGFloat _diagonalLength;
    CGPoint _showCenter;
}

+ (instancetype)suspensionDecideView {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.userInteractionEnabled = NO;
        
        CGFloat scale = [UIScreen mainScreen].bounds.size.width / 375.0;
        _radius = 160.0 * scale;
        _diagonalLength = sqrt(pow(_radius, 2) * 0.5);
    
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        effectView.layer.cornerRadius = _radius;
        effectView.layer.masksToBounds = YES;
        [self addSubview:effectView];
        self.effectView = effectView;
        
        CALayer *deleteBgLayer = [CALayer layer];
        deleteBgLayer.backgroundColor = [UIColor colorWithRed:232.0 / 255.0 green:81.0 / 255.0 blue:83.0 / 255.0 alpha:1.0].CGColor;
        deleteBgLayer.cornerRadius = _radius;
        deleteBgLayer.masksToBounds = YES;
        [self.layer addSublayer:deleteBgLayer];
        self.deleteBgLayer = deleteBgLayer;
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.text = @"取消浮窗";
        [titleLabel sizeToFit];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        self.isDecideDelete = NO;
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    _showCenter = CGPointMake(self.superview.bounds.size.width, self.superview.bounds.size.height);
    
    CGFloat wh = _radius * 2;
    self.frame = CGRectMake(0, 0, wh, wh);
    self.center = CGPointMake(_showCenter.x + _diagonalLength, _showCenter.y + _diagonalLength);
    
    self.effectView.frame = self.bounds;
    self.deleteBgLayer.frame = self.bounds;
    
    CGFloat scale = [UIScreen mainScreen].bounds.size.width / 375.0;
    self.iconView.frame = CGRectMake(78.0 * scale, 60 * scale, self.iconView.frame.size.width, self.iconView.frame.size.height);
    
    self.titleLabel.center = CGPointMake(CGRectGetMidX(self.iconView.frame), CGRectGetMaxY(self.iconView.frame) + 10 + self.titleLabel.frame.size.height * 0.5);
}

- (void)show {
    if (_isShowing) return;
    _showPersent = 1.0;
    _isShowing = YES;
    _isTouch = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.center = self->_showCenter;
    }];
}

- (void)hideWithSuspensionView:(JPSuspensionView *)suspensionView {
    if (_showPersent == 0) return;
    _showPersent = 0.0;
    _isShowing = NO;
    
    BOOL isDelete = suspensionView != nil;
    if (isDelete) {
        suspensionView.frame = suspensionView.superview ? [suspensionView.superview convertRect:suspensionView.frame toView:self] : [suspensionView convertRect:suspensionView.bounds toView:self];
        [self addSubview:suspensionView];
    }
    
    CGFloat x = _showCenter.x + _diagonalLength;
    CGFloat y = _showCenter.y + _diagonalLength;
    [UIView animateWithDuration:0.25 animations:^{
        self.effectView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        self.deleteBgLayer.transform = CATransform3DMakeScale(1, 1, 1);
        self.iconView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        if (!self.isDecideDelete) {
            self.effectView.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
        self.center = CGPointMake(x, y);
    } completion:^(BOOL finished) {
        self->_isTouch = NO;
        if (isDelete) JPSEInstance.suspensionView = nil;
    }];
}

- (void)setIsDecideDelete:(BOOL)isDecideDelete {
    _isDecideDelete = isDecideDelete;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.iconView.image = [UIImage imageWithContentsOfFile:isDecideDelete ? JPSEInstance.removeSuspensionIconPath : JPSEInstance.suspensiconIconPath];
    self.titleLabel.text = isDecideDelete ? @"取消浮窗" : @"浮窗";
    if (isDecideDelete) {
        self.deleteBgLayer.hidden = NO;
        self.effectView.hidden = YES;
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.deleteBgLayer.hidden = YES;
        self.effectView.hidden = NO;
        self.effectView.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.titleLabel.textColor = [UIColor lightGrayColor];
    }
    [CATransaction commit];
}

- (void)setShowPersent:(CGFloat)showPersent {
    if (showPersent < 0) showPersent = 0;
    if (showPersent > 1) showPersent = 1;
    if (_showPersent == showPersent) return;
    _showPersent = showPersent;
    
    self.isShowing = showPersent == 1;
    
    CGFloat scale = 1 - showPersent;
    CGFloat x = _showCenter.x + _diagonalLength * scale;
    CGFloat y = _showCenter.y + _diagonalLength * scale;
    self.center = CGPointMake(x, y);
}

- (void)setIsShowing:(BOOL)isShowing {
    if (_isShowing == isShowing) return;
    _isShowing = isShowing;
    if (!isShowing) self.isTouch = NO;
}

- (void)setTouchPoint:(CGPoint)touchPoint {
    if (!self.isShowing) return;
    
    // 计算点击的位置距离圆心的距离
    CGFloat distance = sqrt(pow(_showCenter.x - touchPoint.x, 2) + pow(_showCenter.y - touchPoint.y, 2));
    
    // 判定圆形区域之外
    if (distance > _radius) {
        self.isTouch = NO;
    } else {
        self.isTouch = YES;
    }
}

- (void)setIsTouch:(BOOL)isTouch {
    if (_isTouch == isTouch) return;
    _isTouch = isTouch;
    
    CGFloat scale = isTouch ? 1.1 : 1.0;
    [UIView animateWithDuration:0.25 animations:^{
        self.effectView.layer.transform = CATransform3DMakeScale(scale, scale, 1);
        self.deleteBgLayer.transform = CATransform3DMakeScale(scale, scale, 1);
        self.iconView.layer.transform = CATransform3DMakeScale(scale, scale, 1);
        if (!self.isDecideDelete) {
            self.effectView.layer.backgroundColor = isTouch ? [UIColor darkGrayColor].CGColor : [UIColor clearColor].CGColor;
            self.iconView.image = [UIImage imageWithContentsOfFile:isTouch ? JPSEInstance.confimSuspensionIconPath : JPSEInstance.suspensiconIconPath];
        }
    }];
}

@end
