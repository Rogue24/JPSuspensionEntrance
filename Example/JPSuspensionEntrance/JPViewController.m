//
//  JPViewController.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPViewController.h"
#import "UIImageView+WebCache.h"

@interface JPViewController ()
@property (nonatomic, weak) UIButton *leftBtn;
@property (nonatomic, weak) UIButton *rightBtn;
@property (nonatomic, strong) UIImage *logoImage;
@end

@implementation JPViewController

#pragma mark - const

#pragma mark - setter

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

#pragma mark - getter

#pragma mark - init

#pragma mark - life cycle

static NSString *const JPTestImageURLStr = @"http://t2.hddhhn.com/uploads/tu/201901/58/4.jpg";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupImage];
    [self setupPushBtn];
    [self setupNavigationBar];
}

#pragma mark - setup subviews

- (void)setupBase {
    self.title = self.isHideNavBar ? @"没有导航栏的控制器" : @"有导航栏的控制器";
}

- (void)setupImage {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.imageName ofType:@"jpg"]];
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
}

- (void)setupPushBtn {
    UIButton *pushBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [pushBtn setTitle:[NSString stringWithFormat:@"  随机push%@导航栏的vc  ", !self.isHideNavBar ? @"无" : @"有"] forState:UIControlStateNormal];
    [pushBtn sizeToFit];
    pushBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    pushBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    [pushBtn addTarget:self action:@selector(pushVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushBtn];
}

- (void)setupNavigationBar {
    if (self.isHideNavBar) {
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
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        rightBtn.backgroundColor = [UIColor whiteColor];
        [rightBtn setTitle:(self.rightBtnTitle ? [NSString stringWithFormat:@"  %@  ", self.rightBtnTitle] : @"  创建浮窗  ") forState:UIControlStateNormal];
        [rightBtn sizeToFit];
        frame = rightBtn.frame;
        frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + 10;
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - rightBtn.bounds.size.width - 10;
        rightBtn.frame = frame;
        [rightBtn addTarget:self action:@selector(suspension) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:rightBtn];
        _rightBtn = rightBtn;
    } else {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:(_rightBtnTitle ? _rightBtnTitle : @"创建浮窗") style:UIBarButtonItemStylePlain target:self action:@selector(suspension)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

#pragma mark - system method

#pragma mark - notification method

#pragma mark - control method

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
    JPViewController *vc = [[JPViewController alloc] init];
    vc.imageName = [NSString stringWithFormat:@"pic_0%d", arc4random() % 4];
    vc.isHideNavBar = !self.isHideNavBar;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - private method

#pragma mark - public method

#pragma mark - JPSuspensionEntranceProtocol

- (BOOL)jp_isHideNavigationBar {
    return self.isHideNavBar;
}

- (NSString *)jp_suspensionCacheMsg {
    return self.title;
}

- (UIImage *)jp_suspensionLogoImage {
    return self.logoImage;
}

- (void)jp_requestSuspensionLogoImageWithLogoView:(UIImageView *)logoView {
    __weak typeof(self) weakSelf = self;
    [logoView sd_setImageWithURL:[NSURL URLWithString:JPTestImageURLStr] placeholderImage:nil options:SDWebImageTransformAnimatedImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (weakSelf) weakSelf.logoImage = image;
    }];
}

@end
