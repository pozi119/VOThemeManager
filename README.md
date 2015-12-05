# VOThemeManager(主题管理器)

[![License Apache](http://img.shields.io/cocoapods/l/VOThemeManager.svg?style=flat)](https://raw.githubusercontent.com/pozi119/VOThemeManager/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/VOThemeManager.svg?style=flat)](http://cocoapods.org/?q=VOThemeManager)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/VOThemeManager.svg?style=flat)](http://cocoapods.org/?q=VOThemeManager)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![Build Status](https://travis-ci.org/pozi119/VOThemeManager.svg?branch=master)](https://travis-ci.org/pozi119/VOThemeManager)

# 安装
* CocoaPods导入(目前使用SDWebImage加载图片,会自动导入SDWebImage):
```ruby
pod 'VOThemeManager'
```
* 手动导入:
  * 将`VOThemeManager`文件夹内所有源码拽入项目
  * 导入`SDWebImage`


# 数据说明
   themes 存放所有主题数据,key表示主题名,value为对应主题数据.  
   主题数据也是NSDictionary类型, key的格式为 主键|标签|主题键,value为相应的值  
   示例如下:
```ruby
{
    test = {
        "nav|0|image" = "tmp_nav_bg";
        "sample|0|color" = "#FFF000";
        "sample|0|image" = "tmp_nav_bg";
    };
 }
```
   主题数据可以用自定义的方式存储,提供了相应的代理方法,但暂未进行调试.

   themeAppliers 应用主题数据的方法, themeGetters 获取对象的某个主题属性, themeObjs 当前要应用主题的对象  
   它们都是 NSMutableDictionary 对象.  
   themeAppliers和themeGetters的key都是 `类名(单列对象内存地址)|标签|主题键`, value为block对象.  
   themeObjs的key是 `主键|标签|主题键`, value为某个对象,通常为某种视图对象

   注: 主键-->自定义的键,用于表示某个主题对象.  
   标签-->比较灵活,可以是UIControlState,比如UIButton的各种状态. 也可以是某个View的tag,用于区分相同类型的不同对象.也可以是一些自定义的状态  
   主题键-->预定义了四种,`color`,`backgroundColor`,`image`,`backgroundImage`(对应`VOThemeColorKey`,`VOThemeBackgroundColorKey`,`VOThemeImageKey`,`VOThemeBackgroundImageKey`).当然也可以自定义主题键.  
   `主键(类名 或 单列对象内存地址))|标签|主题键` 组合起来构成 存储各种数据的 真实键

# 使用
1.唤醒APP时,将主题数据转换为本管理器支持的格式. 例如:
```objc
[[VOThemeManager sharedManager] themeApplierPresets];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"VOThemeSample" ofType:@"plist"];
		NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
	[[VOThemeManager sharedManager] setTheme:dic withName:@"test" themeConverter:^NSDictionary *(NSDictionary *sourceTheme) {
  		return sourceTheme;
	}];
```
通常在` - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`中调用

2.加载完主题数据后,应用指定的主题. 例如:
```objc
[[VOThemeManager sharedManager] applyThemeWithName:@"test"];
```
通常在`- (void)applicationDidBecomeActive:(UIApplication *)application`中调用

3.添加要使用的主题对象. 例如:
```objc
[[VOThemeManager sharedManager] setThemeObject:self.testButton primaryKey:@"btn1" tag:UIControlStateNormal themeKey:VOThemeColorKey];
```
4.设置应用主题的方式.  
在 VOThemeManager+Preset.m 中已经有一部分预置方案.若需要自定义,请参考此文件中的方法.




  		