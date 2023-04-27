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
    self.title = @"Example";
    self.isHideNavBar = YES;
    self.dics = @[@{@"title": @"百度",    @"url": @"https://www.baidu.com"},
                  @{@"title": @"游民星空", @"url": @"https://www.gamersky.com"},
                  @{@"title": @"哔哩哔哩", @"url": @"https://www.bilibili.com"},
                  @{@"title": @"掘金",    @"url": @"https://juejin.cn"}];
}

- (void)setupTableView {
    self.navigationController.view.backgroundColor = UIColor.systemBackgroundColor;
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

- (void)switchIsHideNavBar:(UISwitch *)sw {
    self.isHideNavBar = sw.isOn;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    if (!cell) return;
    cell.textLabel.text = self.isHideNavBar ? @"使用自定义导航栏" : @"使用系统导航栏";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.dics.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        NSDictionary *dic = self.dics[indexPath.row];
        cell.textLabel.text = dic[@"title"];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        cell.textLabel.text = self.isHideNavBar ? @"使用自定义导航栏" : @"使用系统导航栏";
        UISwitch *sw = (UISwitch *)[cell.contentView viewWithTag:66];
        [sw addTarget:self action:@selector(switchIsHideNavBar:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section != 0) return;
    
    NSDictionary *dic = self.dics[indexPath.row];
    NSString *url = dic[@"url"];
    JPWebViewController *webVC = [[JPWebViewController alloc] initWithURLStr:url isHideNavBar:self.isHideNavBar isSuspension:NO];
    [self.navigationController pushViewController:webVC animated:YES];
}

@end
