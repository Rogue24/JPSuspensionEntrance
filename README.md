# JPSuspensionEntrance

[![CI Status](https://img.shields.io/travis/Rogue24/JPSuspensionEntrance.svg?style=flat)](https://travis-ci.org/Rogue24/JPSuspensionEntrance)
[![Version](https://img.shields.io/cocoapods/v/JPSuspensionEntrance.svg?style=flat)](https://cocoapods.org/pods/JPSuspensionEntrance)
[![License](https://img.shields.io/cocoapods/l/JPSuspensionEntrance.svg?style=flat)](https://cocoapods.org/pods/JPSuspensionEntrance)
[![Platform](https://img.shields.io/cocoapods/p/JPSuspensionEntrance.svg?style=flat)](https://cocoapods.org/pods/JPSuspensionEntrance)

#### 博客讲解：https://www.jianshu.com/p/6834b95eeb6d

## 简介

高仿微信悬浮小窗口的小框架

    目前功能：
        1.滑动返回时可选择该控制器是否缩小成浮窗；
        2.浮窗可自由拖动，拖动结束后可自动贴边；
        3.一键创建、替换、关闭浮窗；
        4.自适应横竖屏、键盘弹出；
        5.可自定义缓存（控制器信息、默认位置）方案；
        6.可自定义展开/闭合的提示音
        7.可作用于有或无导航栏的情况
        8.可自定义浮窗logo

    注意：
        1.目前仅作用于NavigationController

    之后的更新内容：
        1.Swift版本；
        2.适配自定义的转场动画
        3.更多的控制器整合的浮窗；
        4.更多的参数设定；
      
### 预览
![预览](https://github.com/Rogue24/JPSuspensionEntrance/raw/master/Cover/QQ20180615-233849.gif)

### 无导航栏的样式
![无导航栏的情况](https://github.com/Rogue24/JPSuspensionEntrance/raw/master/Cover/QQ20180615-174626-HD.gif)

### 有导航栏的样式
![有导航栏的情况](https://github.com/Rogue24/JPSuspensionEntrance/raw/master/Cover/QQ20180615-174820-HD.gif)

### 已有浮窗的进入与返回
![已有浮窗的进入与返回](https://github.com/Rogue24/JPSuspensionEntrance/raw/master/Cover/QQ20180615-175232-HD.gif)

## 如何使用

#### 获取单例
```obj
// 使用单例的形式进行全局操作
[JPSuspensionEntrance sharedInstance]; 

// 也可以使用单例宏获取
// JPSEInstance
```
#### 绑定 NavigationController
```obj
// 绑定了则其delegate及interactivePopGestureRecognizer.delegate都为JPSuspensionEntrance代理
// 切换navigationController需要重新绑定最新的navigationController
JPSEInstance.navCtr = self.navigationController;

// 设置绑定的navigationController的根控制器和没有遵守<JPSuspensionEntranceProtocol>协议的子控制器是否隐藏导航栏
JPSEInstance.isHideNavBar = NO;
```
#### 配置可成为浮窗的控制器
```obj
// push的控制器需要遵守<JPSuspensionEntranceProtocol>协议才可以变为浮窗
// JPSuspensionEntranceProtocol的代理方法：
/**
 * 需要缓存的信息（必须实现，例如url）
 */
- (NSString *)jp_suspensionCacheMsg;

/**
 * 浮窗的logo图标（可选）
 */
- (UIImage *)jp_suspensionLogoImage;

/**
 * 加载浮窗的logo图标的回调（可选，“jp_suspensionLogoImage”优先调用）
 * 当“jp_suspensionLogoImage”没有实现或者返回的是nil才会回调该方法，有值返回则不会执行，需要自定义加载方案，这里只提供调用时机
 * Example:
    // 在push的控制器中实现的代理方法：
    - (UIImage *)jp_suspensionLogoImage {
        // 返回下载的图片
        return self.logoImage;
    }
    
    // 如果jp_suspensionLogoImage没有实现或者返回的是nil则会执行该方法
    - (void)jp_requestSuspensionLogoImageWithLogoView:(UIImageView *)logoView {
        // 这里使用了sdwebimage来进行下载
        __weak typeof(self) weakSelf = self;
        [logoView sd_setImageWithURL:[NSURL URLWithString:JPTestImageURLStr] placeholderImage:nil options:SDWebImageTransformAnimatedImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            // 保存下载好的图片
            if (weakSelf) weakSelf.logoImage = image;
        }];
    }
 */
- (void)jp_requestSuspensionLogoImageWithLogoView:(UIImageView *)logoView;
```

#### 展开、闭合浮窗
```obj
/**
 * 展开当前浮窗
 */
- (void)pushViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC;

/**
 * 闭合/创建/替换浮窗
 */
- (void)popViewController:(UIViewController<JPSuspensionEntranceProtocol> *)targetVC;
```

#### 设置浮窗提示音
```obj
// 是否可以播放提示音 默认为no
JPSEInstance.canPlaySound = YES;

// 可在该block中配置展开时的提示音
// 默认为系统的id为1397提示音
JPSEInstance.playSpreadSoundBlock = ^{

};

// 可在该block中配置闭合时的提示音
// 默认为系统的id为1396提示音
JPSEInstance.playShrinkSoundBlock = ^{

};
```

#### 配置缓存方案
```obj
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{

    // 自定义缓存方案
    // 当需要缓存时则实现这两个block，会在适当的时机进行回调，缓存可自行另处清除

    // 1.关键信息的缓存（例如URL），当浮窗被新建、替换时会调用
    JPSEInstance.cacheMsgBlock = ^(NSString *cacheMsg) {
        // 缓存操作，可参考Demo
    };

    // 2.浮窗最新的位置的缓存，当浮窗位置发生改变时会调用
    JPSEInstance.cacheSuspensionFrameBlock = ^(CGRect suspensionFrame) {
        // 缓存操作，可参考Demo
    };

});
```

#### 初始化配置缓存浮窗
```obj
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    // 初始化缓存浮窗
    // 获取缓存信息，有缓存关键信息的情况下才创建
    NSString *cachaMsg = [[NSUserDefaults standardUserDefaults] stringForKey:JPSuspensionCacheMsgKey];
    if (cachaMsg) {
        // 1.创建浮窗的控制器
        ViewController *vc = [[ViewController alloc] init];
        vc.title = cachaMsg;
        vc.isHideNavBar = YES;
        
        // 2.获取缓存的浮窗位置
        // Demo中使用了NSUserDefaults缓存的x、y值
        CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:JPSuspensionDefaultXKey];
        CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:JPSuspensionDefaultYKey];

        // 创建浮窗
        [JPSEInstance setupSuspensionViewWithTargetVC:vc suspensionXY:CGPointMake(x, y)];
    }
});
```

## 安装

JPSuspensionEntrance 可通过[CocoaPods](http://cocoapods.org)安装，只需添加下面一行到你的podfile：

```obj
pod 'JPSuspensionEntrance'
```

## 反馈地址

    扣扣：184669029
    博客：https://www.jianshu.com/u/2edfbadd451c

## License

JPSuspensionEntrance is available under the MIT license. See the LICENSE file for more info.
