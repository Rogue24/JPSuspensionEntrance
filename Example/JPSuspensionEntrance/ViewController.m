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
        leftBtn.backgroundColor = [UIColor whiteColor];
        [leftBtn setTitle:@"  返回  " forState:UIControlStateNormal];
        [leftBtn sizeToFit];
        CGRect frame = leftBtn.frame;
        frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + 10;
        frame.origin.x = 10;
        leftBtn.frame = frame;
        [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:leftBtn];
        _leftBtn = leftBtn;
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        rightBtn.backgroundColor = [UIColor whiteColor];
        [rightBtn setTitle:(self.rightBtnTitle ? [NSString stringWithFormat:@"  %@  ", self.rightBtnTitle] : @"  创建浮窗  ") forState:UIControlStateNormal];
        [rightBtn sizeToFit];
        CGRect frame = rightBtn.frame;
        frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + 10;
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - rightBtn.bounds.size.width - 10;
        rightBtn.frame = frame;
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
    
    UIButton *pushBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [pushBtn setTitle:[NSString stringWithFormat:@"  随机push%@导航栏的vc  ", !self.isHideNavBar ? @"无" : @"有"] forState:UIControlStateNormal];
    [pushBtn sizeToFit];
    pushBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    pushBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    [pushBtn addTarget:self action:@selector(pushVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isHideNavBar) {
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

- (void)pushVC {
    ViewController *vc = [[ViewController alloc] init];
    vc.title = [NSString stringWithFormat:@"pic_0%d", arc4random() % 7 + 1];
    vc.isHideNavBar = !self.isHideNavBar;
    [self.navigationController pushViewController:vc animated:YES];
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
