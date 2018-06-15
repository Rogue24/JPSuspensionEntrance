# JPSuspensionEntrance

[![CI Status](https://img.shields.io/travis/Rogue24/JPSuspensionEntrance.svg?style=flat)](https://travis-ci.org/Rogue24/JPSuspensionEntrance)
[![Version](https://img.shields.io/cocoapods/v/JPSuspensionEntrance.svg?style=flat)](https://cocoapods.org/pods/JPSuspensionEntrance)
[![License](https://img.shields.io/cocoapods/l/JPSuspensionEntrance.svg?style=flat)](https://cocoapods.org/pods/JPSuspensionEntrance)
[![Platform](https://img.shields.io/cocoapods/p/JPSuspensionEntrance.svg?style=flat)](https://cocoapods.org/pods/JPSuspensionEntrance)

## 简介

高仿微信悬浮窗口的小框架

    目前功能：
        1.滑动返回时可选择该控制器是否缩小成浮窗；
        2.浮窗可自由拖动，拖动结束后可自动贴边；
        3.一键创建、替换、取消浮窗；
        4.自适应横竖屏；
        5.自定义缓存（控制器信息、默认位置）方案；
        6.可作用于有导航栏的情况

    注意：
        1.目前仅作用于NavigationController

    之后的更新内容：
        1.Swift版本；
        2.适配自定义的转场动画
        3.更多的控制器整合的浮窗；
        4.更多的参数设定；
      
![image](https://github.com/Rogue24/JPSuspensionEntrance/raw/master/Cover/221529073066_.pic_hd.jpeg)
![image](https://github.com/Rogue24/JPSuspensionEntrance/raw/master/Cover/231529073069_.pic_hd.jpeg)

### 无导航栏的情况
![image](https://github.com/Rogue24/JPSuspensionEntrance/raw/master/Cover/QQ20180615-174626-HD.gif)

### 有导航栏的情况
![image](https://github.com/Rogue24/JPSuspensionEntrance/raw/master/Cover/QQ20180615-174820-HD.gif)

### 已有窗口的进入与返回
![image](https://github.com/Rogue24/JPSuspensionEntrance/raw/master/Cover/QQ20180615-175232-HD.gif)

## 如何使用

#### 获取单例
```ruby
// 使用单例的形式进行全局操作
[JPSuspensionEntrance sharedInstance]; 

// 也可以使用单例宏获取
// JPSEInstance
```
#### 绑定navigationController
```
// 绑定了则其delegate及interactivePopGestureRecognizer.delegate都为JPSuspensionEntrance代理
// 切换navigationController需要重新绑定最新的navigationController
JPSEInstance.navCtr = self.navigationController;
```
#### 配置可成为浮窗的控制器
```
// 控制器需要遵守<JPSuspensionEntranceProtocol>协议才可以变为浮窗

#pragma mark - JPSuspensionEntranceProtocol 代理方法

// 1.是否隐藏导航栏（必须实现）
- (BOOL)jp_isHideNavigationBar {
    return self.isHideNavBar;
}

// 2.缓存信息（可选）
- (NSString *)jp_suspensionCacheMsg {
    return self.title;
}

// 3.浮窗logo图标（可选）
- (UIImage *)jp_suspensionLogoImage {
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.title ofType:@"jpg"]];
}
```

#### 配置缓存方案
```
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{

    // 1.自定义缓存方案
    // 当需要缓存时则实现这两个block，会在适当的时机进行回调，缓存可自行另处清除

    // 1.1 缓存关键信息（例如URL）
    JPSEInstance.cacheMsgBlock = ^(NSString *cacheMsg) {
        // 这里就简单使用NSUserDefaults进行处理
        [[NSUserDefaults standardUserDefaults] setObject:cacheMsg forKey:JPSuspensionCacheMsgKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };

    // 1.2 缓存浮窗最新的位置
    JPSEInstance.cacheSuspensionFrameBlock = ^(CGRect suspensionFrame) {
        // 缓存x、y值即可，宽高使用默认值
        [[NSUserDefaults standardUserDefaults] setFloat:suspensionFrame.origin.x forKey:JPSuspensionDefaultXKey];
        [[NSUserDefaults standardUserDefaults] setFloat:suspensionFrame.origin.y forKey:JPSuspensionDefaultYKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };

    // 2.初始化缓存的窗口（有缓存的情况下才创建）
    NSString *cachaMsg = [[NSUserDefaults standardUserDefaults] stringForKey:JPSuspensionCacheMsgKey];
    if (cachaMsg) {
        // 创建并配置窗口的控制器
        ViewController *vc = [[ViewController alloc] init];
        vc.title = cachaMsg;
        vc.isHideNavBar = YES;

        CGFloat wh = [JPSuspensionEntrance sharedInstance].suspensionViewWH;
        CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:JPSuspensionDefaultXKey];
        CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:JPSuspensionDefaultYKey];

        // 创建窗口
        [JPSEInstance setupSuspensionViewWithTargetVC:vc suspensionFrame:CGRectMake(x, y, wh, wh)];
    }

});
```

## 安装

JPSuspensionEntrance 可通过[CocoaPods](http://cocoapods.org)安装，只需添加下面一行到你的podfile：

```ruby
pod 'JPSuspensionEntrance'
```

## 反馈地址

邮箱：zhoujianping24@hotmail.com
博客：https://www.jianshu.com/u/2edfbadd451c

## License

JPSuspensionEntrance is available under the MIT license. See the LICENSE file for more info.
