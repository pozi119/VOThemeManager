# VOThemeManager(主题管理器)

[![License Apache](http://img.shields.io/cocoapods/l/VOThemeManager.svg?style=flat)](https://raw.githubusercontent.com/pozi119/VOThemeManager/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/VOThemeManager.svg?style=flat)](http://cocoapods.org/?q=VOThemeManager)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/VOThemeManager.svg?style=flat)](http://cocoapods.org/?q=VOThemeManager)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![Build Status](https://travis-ci.org/pozi119/VOThemeManager.svg?branch=master)](https://travis-ci.org/pozi119/VOThemeManager)

# 更新说明
* 本次改动较大,移除了预设,改为自行编写代码获取默认值以及设置主题值,增加了灵活度.
* 存取数据的Key不再是 **主键|tag|主题键**的方式,而是只使用 **主键**
* 添加/修改主题数据,不再在block中处理,改为用户自行处理成NSDictionary,可参考Demo.
* Demo中是预先下载图片,并将颜色字符串转为UIColor.这些也可以在某个对象设置主题时再转换

# 安装
* CocoaPods导入(目前使用YYCache缓存主题数据,会自动导入YYCache):
```ruby
pod 'VOThemeManager'
```
* 手动导入:
  * 将`VOThemeManager`文件夹内所有源码拽入项目
  * 导入`YYCache`

# 数据说明
   主题数据使用YYCache存储,不同主题所存放的文件夹不同.主题值的

   themeAppliers 应用主题数据的方法, themeObjs当前要应用主题的对象,它们都是 NSMapTable对象, 在被释放后会自动从NSMapTable中删除
   themeAppliers的key是 **主键** , value为block对象.  
   themeObjs的key是 **主键** , value为某个对象,通常为某种视图对象

# 使用
1.新增/修改主题
```objc
        [VOThemeManager setData:processedDic forTheme:@"test"];
```
注:新增主题之后不会自动使用新增的主题.

2.加载完主题数据后,应用指定的主题. 例如:
```objc
      VOThemeManager.currentTheme = @"test";  /* 设置为test主题 */
      VOThemeManager.currentTheme = nil;      /* 不使用主题 */
```

3.添加要使用的主题对象. 例如:
```objc
    [VOThemeManager setThemeObject:self.testButton  /* 主题对象 */
    forKey:@"btn1_bgColor"  /* 主键,用于关联主题值,主题对象,应用方式,默认值 */
    defaultBlock:^id(UIButton *button) { /* 获取默认值,不使用主题时将重设为此值 */
        return button.backgroundColor;   
    } 
    applier:^(UIButton *button, UIColor *color) { /* 应用主题的方式 */
        button.backgroundColor = color;  
    }];
```




  		