//
//  TableViewController.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"
#import "ViewController2.h"
#import <AudioToolbox/AudioToolbox.h>

@interface TableViewController ()
@property (nonatomic, strong) NSMutableArray *imgNames;
@property (nonatomic, assign) BOOL isHideNavBar;
@end

@implementation TableViewController

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
        [(ViewController *)targetVC setIsHideNavBar:weakSelf.isHideNavBar];
        [(ViewController *)targetVC setRightBtnTitle:@"取消浮窗"];
    };
}

- (void)setupBase {
    self.isHideNavBar = isHideNavBar_;
    isHideNavBar_ = !isHideNavBar_;
    
    self.title = self.isHideNavBar ? @"Example-没导航栏" : @"Example-有导航栏";
    
    self.imgNames = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        [self.imgNames addObject:[NSString stringWithFormat:@"pic_0%d", i + 1]];
    }
    [self.imgNames addObject:@"没有浮窗操作的控制器"];
}

- (void)setupTableView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(isHideNavBar_ ? @"pic_08" : @"pic_09") ofType:@"jpg"]];
    self.tableView.backgroundView = imageView;
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
            ViewController *vc = [[ViewController alloc] init];
            vc.title = cachaMsg;
            vc.isHideNavBar = YES;
            
            CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:JPSuspensionDefaultXKey];
            CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:JPSuspensionDefaultYKey];
            [JPSEInstance setupSuspensionViewWithTargetVC:vc suspensionXY:CGPointMake(x, y)];
        }
        
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imgNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor yellowColor];
    cell.textLabel.text = self.imgNames[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.imgNames.count - 1) {
        ViewController2 *vc = [[ViewController2 alloc] init];
        vc.title = self.imgNames[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    ViewController *vc = [[ViewController alloc] init];
//    vc.edgesForExtendedLayout = UIRectEdgeNone;
    vc.title = self.imgNames[indexPath.row];
    vc.isHideNavBar = self.isHideNavBar;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
