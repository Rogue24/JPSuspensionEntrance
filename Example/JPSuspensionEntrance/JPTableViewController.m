//
//  JPTableViewController.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPTableViewController.h"
#import "JPWebViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JPTableViewController ()
@property (nonatomic, copy) NSArray<NSDictionary *> *dics;
@property (nonatomic, assign) BOOL isHideNavBar;
@end

@implementation JPTableViewController

static BOOL isHideNavBar_ = YES;
static NSString *const JPSuspensionCacheMsgKey = @"JPSuspensionCacheMsgKey";
static NSString *const JPSuspensionDefaultXKey = @"JPSuspensionDefaultXKey";
static NSString *const JPSuspensionDefaultYKey = @"JPSuspensionDefaultYKey";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupTableView];
    [self setupJPSEInstance];
    [self setupSuspensionView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    JPSEInstance.navCtr = self.navigationController;
    
    __weak typeof(self) weakSelf = self;
    JPSEInstance.willSpreadSuspensionViewControllerBlock = ^(UIViewController<JPSuspensionEntranceProtocol> *targetVC) {
        [(JPWebViewController *)targetVC setIsHideNavBar:weakSelf.isHideNavBar];
    };
}

- (void)setupBase {
    self.isHideNavBar = isHideNavBar_;
    isHideNavBar_ = !isHideNavBar_;
    self.title = self.isHideNavBar ? @"Example-没导航栏" : @"Example-有导航栏";
    self.tableView.backgroundColor = self.isHideNavBar ? UIColor.magentaColor : UIColor.cyanColor;
    self.dics = @[@{@"title": @"百度",    @"url": @"https://www.baidu.com"},
                  @{@"title": @"游民星空", @"url": @"https://www.gamersky.com"},
                  @{@"title": @"哔哩哔哩", @"url": @"https://www.bilibili.com"},
                  @{@"title": @"简书",    @"url": @"https://www.jianshu.com"}];
}

- (void)setupTableView {
    self.navigationController.view.backgroundColor = UIColor.whiteColor;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
}

- (void)setupJPSEInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 是否可以播放提示音
        JPSEInstance.canPlaySound = YES;
        
//        // 配置展开时的提示音
//        JPSEInstance.playSpreadSoundBlock = ^{
//            
//        };
//        
//        // 配置闭合时的提示音
//        JPSEInstance.playShrinkSoundBlock = ^{
//            
//        };
        
        JPSEInstance.cacheMsgBlock = ^(NSString *cacheMsg) {
            [[NSUserDefaults standardUserDefaults] setObject:cacheMsg forKey:JPSuspensionCacheMsgKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        };
        
        JPSEInstance.cacheSuspensionFrameBlock = ^(CGRect suspensionFrame) {
            [[NSUserDefaults standardUserDefaults] setFloat:suspensionFrame.origin.x forKey:JPSuspensionDefaultXKey];
            [[NSUserDefaults standardUserDefaults] setFloat:suspensionFrame.origin.y forKey:JPSuspensionDefaultYKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        };
        
    });
}

- (void)setupSuspensionView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachaMsg = [[NSUserDefaults standardUserDefaults] stringForKey:JPSuspensionCacheMsgKey];
        if (cachaMsg) {
            JPWebViewController *webVC = [[JPWebViewController alloc] initWithURLStr:cachaMsg isHideNavBar:self.isHideNavBar isSuspension:YES];
            CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:JPSuspensionDefaultXKey];
            CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:JPSuspensionDefaultYKey];
            [JPSEInstance setupSuspensionViewWithTargetVC:webVC suspensionXY:CGPointMake(x, y)];
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dics[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = UIColor.clearColor;
    cell.textLabel.text = dic[@"title"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dics[indexPath.row];
    NSString *url = dic[@"url"];
    JPWebViewController *webVC = [[JPWebViewController alloc] initWithURLStr:url isHideNavBar:self.isHideNavBar isSuspension:NO];
    [self.navigationController pushViewController:webVC animated:YES];
}

@end
