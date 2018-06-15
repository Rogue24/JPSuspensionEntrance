//
//  ViewController.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPSuspensionEntrance.h"

@interface ViewController ()
@property (nonatomic, weak) UIButton *leftBtn;
@property (nonatomic, weak) UIButton *rightBtn;
@end

@implementation ViewController

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        leftBtn.backgroundColor = [UIColor yellowColor];
        [leftBtn setTitle:@"  返回  " forState:UIControlStateNormal];
        [leftBtn sizeToFit];
        leftBtn.center = CGPointMake(50, [UIApplication sharedApplication].statusBarFrame.size.height + 20);
        [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:leftBtn];
        _leftBtn = leftBtn;
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        rightBtn.backgroundColor = [UIColor yellowColor];
        [rightBtn setTitle:(self.rightBtnTitle ? [NSString stringWithFormat:@"  %@  ", self.rightBtnTitle] : @"  创建浮窗  ") forState:UIControlStateNormal];
        [rightBtn sizeToFit];
        rightBtn.center = CGPointMake(250, [UIApplication sharedApplication].statusBarFrame.size.height + 20);
        [rightBtn addTarget:self action:@selector(suspension) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:rightBtn];
        _rightBtn = rightBtn;
    }
    return _rightBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.title ofType:@"jpg"]];
    [self.view addSubview:imageView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isHideNavBar) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.leftBtn.hidden = NO;
        self.rightBtn.hidden = NO;
    } else {
        _leftBtn.hidden = YES;
        _rightBtn.hidden = YES;
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = backItem;
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:(self.rightBtnTitle ? self.rightBtnTitle : @"创建浮窗") style:UIBarButtonItemStylePlain target:self action:@selector(suspension)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isHideNavBar) [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setRightBtnTitle:(NSString *)rightBtnTitle {
    _rightBtnTitle = rightBtnTitle;
    if (self.isHideNavBar) {
        [self.rightBtn setTitle:(rightBtnTitle ? [NSString stringWithFormat:@"  %@  ", rightBtnTitle] : @"  创建浮窗  ") forState:UIControlStateNormal];
        [self.rightBtn sizeToFit];
    } else {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:(rightBtnTitle ? rightBtnTitle : @"创建浮窗") style:UIBarButtonItemStylePlain target:self action:@selector(suspension)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)suspension {
    if (self.rightBtnTitle) {
        JPSEInstance.suspensionView = nil;
        self.rightBtnTitle = nil;
    } else {
        [JPSEInstance popViewController:self];
    }
}

#pragma mark - JPSuspensionEntranceProtocol

- (BOOL)jp_isHideNavigationBar {
    return self.isHideNavBar;
}

- (NSString *)jp_suspensionCacheMsg {
    return self.title;
}

- (UIImage *)jp_suspensionLogoImage {
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.title ofType:@"jpg"]];
}


@end
