//
//  JPWebViewController.m
//  Infinitee2.0
//
//  Created by guanning on 2017/1/17.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import "JPWebViewController.h"
#import <WebKit/WebKit.h>
#import "UIView+JPExtension.h"
#import "UIImageView+WebCache.h"

@interface JPWebViewController () <WKNavigationDelegate>
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) UIProgressView *progressView;

@property (nonatomic, strong) UIView *naviBar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *suspensionBtn;
@property (nonatomic, strong) UIButton *reloadBtn;

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) UIImage *logoImage;
@end

@implementation JPWebViewController

#pragma mark - setter

- (void)setIsSuspension:(BOOL)isSuspension {
    _isSuspension = isSuspension;
    self.suspensionBtn.selected = isSuspension;
}

- (void)setIsHideNavBar:(BOOL)isHideNavBar {
    if (_isHideNavBar == isHideNavBar) return;
    _isHideNavBar = isHideNavBar;
    [self setupNavigationBar];
}

#pragma mark - getter

- (UIView *)naviBar {
    if (!_naviBar) {
        BOOL isIphoneX = [UIScreen mainScreen].bounds.size.height > 736.0;
        _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, isIphoneX ? 88 : 64)];
        _naviBar.backgroundColor = UIColor.whiteColor;
        _naviBar.layer.zPosition = 99;
        CALayer *line = [CALayer layer];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
        line.frame = CGRectMake(0, _naviBar.jp_height - 0.33, _naviBar.jp_width, 0.33);
        line.zPosition = 10;
        [_naviBar.layer addSublayer:line];
    }
    return _naviBar;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.text = @"加载中...";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.jp_size = CGSizeMake(150, 44);
    }
    return _titleLabel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setImage:[UIImage imageNamed:@"jp_icon_back"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
            btn.jp_size = CGSizeMake(44, 44);
            btn;
        });
    }
    return _backBtn;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setImage:[UIImage imageNamed:@"jp_icon_close"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
            btn.jp_size = CGSizeMake(44, 44);
            btn;
        });
    }
    return _closeBtn;
}

- (UIButton *)suspensionBtn {
    if (!_suspensionBtn) {
        _suspensionBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setImage:[UIImage imageNamed:@"jp_icon_circle"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"jp_icon_circle_delete"] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(suspension) forControlEvents:UIControlEventTouchUpInside];
            btn.selected = self.isSuspension;
            btn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            btn.jp_size = CGSizeMake(44, 44);
            btn;
        });
    }
    return _suspensionBtn;
}

- (UIButton *)reloadBtn {
    if (!_reloadBtn) {
        _reloadBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setImage:[UIImage imageNamed:@"jp_icon_refresh"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(reloadWeb) forControlEvents:UIControlEventTouchUpInside];
            btn.jp_size = CGSizeMake(44, 44);
            btn;
        });
    }
    return _reloadBtn;
}

#pragma mark - 初始化

- (instancetype)initWithURLStr:(NSString *)urlStr isHideNavBar:(BOOL)isHideNavBar isSuspension:(BOOL)isSuspension {
    if (self = [super init]) {
        _urlStr = urlStr;
        _isHideNavBar = isHideNavBar;
        _isSuspension = isSuspension;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupSubViews];
    [self setupWebViewObserver:YES];
    [self loadRequest];
}

- (void)dealloc {
    [self setupWebViewObserver:NO];
    [self deleteWebCache];
}

- (void)deleteWebCache {
    if (@available(iOS 9.0, *)) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{}];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cookiesFolderPath]) [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:nil];
    }
}

#pragma mark - 页面布局

- (void)setupNavigationBar {
    self.titleLabel.text = self.webView.title;
    
    CGSize btnSize = CGSizeMake(44, 44);
    CGSize titleSize = CGSizeMake(150, btnSize.height);
    if (self.isHideNavBar) {
        self.navigationItem.titleView = nil;
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = nil;
        self.naviBar.hidden = NO;
        
        CGFloat y = self.naviBar.jp_height - btnSize.height;
        CGFloat titleX = (self.naviBar.jp_width - titleSize.width) * 0.5;
        self.titleLabel.frame = (CGRect){CGPointMake(titleX, y), titleSize};
        self.backBtn.frame = (CGRect){CGPointMake(0, y), btnSize};
        self.closeBtn.frame = (CGRect){CGPointMake(self.backBtn.jp_maxX, y), btnSize};
        self.reloadBtn.frame = (CGRect){CGPointMake(self.naviBar.jp_width - btnSize.width, y), btnSize};
        self.suspensionBtn.frame = (CGRect){CGPointMake(self.reloadBtn.jp_x - btnSize.width, y), btnSize};
        
        [self.naviBar addSubview:self.titleLabel];
        [self.naviBar addSubview:self.backBtn];
        [self.naviBar addSubview:self.closeBtn];
        [self.naviBar addSubview:self.reloadBtn];
        [self.naviBar addSubview:self.suspensionBtn];
        [self.view addSubview:self.naviBar];
    } else {
        if (_naviBar) {
            [_naviBar removeFromSuperview];
            [self.titleLabel removeFromSuperview];
            [self.backBtn removeFromSuperview];
            [self.closeBtn removeFromSuperview];
            [self.reloadBtn removeFromSuperview];
            [self.suspensionBtn removeFromSuperview];
        }
        self.titleLabel.frame = (CGRect){CGPointZero, titleSize};
        self.backBtn.frame = (CGRect){CGPointZero, btnSize};
        self.closeBtn.frame = self.backBtn.frame;
        self.reloadBtn.frame = self.backBtn.frame;
        self.suspensionBtn.frame = self.backBtn.frame;
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.closeBtn];
        
        UIBarButtonItem *suspensionButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.suspensionBtn];
        UIBarButtonItem *reloadButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.reloadBtn];
        
        self.navigationItem.titleView = self.titleLabel;
        self.navigationItem.leftBarButtonItems = @[backButtonItem, closeButtonItem];
        self.navigationItem.rightBarButtonItems = @[reloadButtonItem, suspensionButtonItem];
    }
}

- (void)setupSubViews {
    self.view.backgroundColor = UIColor.whiteColor;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    BOOL isIphoneX = screenH > 736.0;
    CGFloat topInset = 44 + (isIphoneX ? 44 : 20);
    CGFloat bottomInset = isIphoneX ? 34.0 : 0;
    CGRect frame = CGRectMake(0, topInset, screenW, screenH - topInset - bottomInset);
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.suppressesIncrementalRendering = NO;
    configuration.allowsInlineMediaPlayback = NO;
    if (@available(iOS 9.0, *)) {
        configuration.allowsAirPlayForMediaPlayback = YES;
        configuration.requiresUserActionForMediaPlayback = NO;
        configuration.allowsPictureInPictureMediaPlayback = YES;
    }
    WKWebView *webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    webView.allowsBackForwardNavigationGestures = YES;
    webView.navigationDelegate = self;
    webView.scrollView.alwaysBounceVertical = YES;
    webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    if (@available(iOS 11.0, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:webView];
    self.webView = webView;
    
    UIProgressView *progressView = [[UIProgressView alloc] init];
    progressView.trackTintColor = [UIColor clearColor];
    frame = progressView.frame;
    frame.origin.y = topInset;
    frame.size.width = screenW;
    progressView.frame = frame;
    [self.view addSubview:progressView];
    self.progressView = progressView;
}

- (void)loadRequest {
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    [self.webView loadRequest:self.request];
}

#pragma mark - KVO

- (void)setupWebViewObserver:(BOOL)isAdd {
    if (isAdd) {
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [self.webView removeObserver:self forKeyPath:@"title"];
        [self.webView removeObserver:self forKeyPath:@"canGoBack"];
        [self.webView removeObserver:self forKeyPath:@"canGoForward"];
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

// 只要观察对象属性有新值就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    self.titleLabel.text = self.webView.title.length ? self.webView.title : @"加载中...";
    self.closeBtn.hidden = !self.webView.canGoBack;
    self.progressView.progress = self.webView.estimatedProgress;
    self.progressView.hidden = self.webView.estimatedProgress >= 1;
}

#pragma mark - 事件监听

- (void)back {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self close];
    }
}

- (void)close {
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)suspension {
    if (self.isSuspension) {
        JPSEInstance.suspensionView = nil;
    } else {
        [JPSEInstance popViewController:self];
    }
    self.isSuspension = !self.isSuspension;
}

- (void)reloadWeb {
    [self.webView reload];
}

#pragma mark - WKNavigationDelegate

// 页面加载启动时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

#pragma mark - JPSuspensionEntranceProtocol

- (BOOL)jp_isHideNavigationBar {
    return self.isHideNavBar;
}

- (NSString *)jp_suspensionCacheMsg {
    return self.urlStr;
}

- (UIImage *)jp_suspensionLogoImage {
    return self.logoImage;
}

- (void)jp_requestSuspensionLogoImageWithLogoView:(UIImageView *)logoView {
    __weak typeof(self) weakSelf = self;
    [logoView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/favicon.ico", self.urlStr]] placeholderImage:[UIImage imageNamed:@"jp_icon_tabbar"] options:SDWebImageTransformAnimatedImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (weakSelf) weakSelf.logoImage = image;
    }];
}

@end
