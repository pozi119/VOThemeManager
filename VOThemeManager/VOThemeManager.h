//
//  VOThemeManager.h
//  netCafe
//
//  Created by Valo on 15/11/20.
//  Copyright © 2015年 Sicent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VOThemeUtils.h"

FOUNDATION_EXTERN NSString *const VOThemeColorKey;
FOUNDATION_EXTERN NSString *const VOThemeBackgroundColorKey;
FOUNDATION_EXTERN NSString *const VOThemeImageKey;
FOUNDATION_EXTERN NSString *const VOThemeBackgroundImageKey;

/**
 *  某个对象应用主题的方法
 *
 *  @param obj        某个对象
 *  @param primaryKey 基本键
 *  @param tag        标签,灵活应用,可以是UIControlState,也可以用于区分同一主题的多个主题对象
 *  @param themeKey   主题属性Key
 *  @param value      主题属性值
 */
typedef void (^VOThemeApplier)(id obj, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value);

/**
 *  获取某个对象的主题值,通常用于保持该主题的原始属性值
 *
 *  @param obj        某天对象
 *  @param primaryKey 基本键
 *  @param tag        标签,灵活应用,可以是UIControlState,也可以用于区分同一主题的多个主题对象
 *  @param themeKey   主题属性Key
 *
 *  @return 主题属性值
 */
typedef id (^VOThemeGetter)(id obj, NSString *primaryKey, NSInteger tag, NSString *themeKey);

/**
 *  主题转换器
 *  将源主题数据转换成本管理器支持的主题数据格式
 *
 *  @param sourceTheme 源主题数据
 */
typedef NSDictionary * (^VOThemeCoverter)(id sourceTheme);

@protocol VOThemeProtocol;
@interface VOThemeManager : NSObject
@property (nonatomic, weak) id<VOThemeProtocol> delegate;   /**< 代理 */
@property (nonatomic, copy) NSString *baseImagePath;        /**< 图片基本路径 */
/**
 *  皮肤管理器
 *
 *  @return 单例
 */
+ (instancetype)sharedManager;

/**
 *  获取当前主题名称
 *
 *  @return 当前主题名称
 */
- (NSString *)currentThemeName;

/**
 *  添加/修改一种主题
 *
 *  @param theme          主题
 *  @param themeName      主题名
 *  @param themeConverter 主题转换器,转换为本管理器支持的主题数据格式
 */
- (void)setTheme:(id)theme
        withName:(NSString *)themeName
  themeConverter:(VOThemeCoverter)themeConverter;

/**
 *  删除一种主题
 *
 *  @param themeName   主题名称
 */
- (void)removeThemeWithName:(NSString *)themeName;

/**
 *  应用某个主题
 *
 *  @param themeName    主题名称
 */
- (void)applyThemeWithName:(NSString *)themeName;

/**
 *  应用一条主题数据
 *
 *  @param themeName    主题名称
 *  @param realKey      对应的键,唯一
 */
- (void)applyThemeWithName:(NSString *)themeName
             forRealKeyKey:(NSString *)realKey;

/**
 *  添加一个要使用主题的对象
 *  在themeObjs中添加/修改一个字典对象,键为 primaryKey|tag|themeKey,值为 themeObj
 *
 *  @param themeObj   要使用主题的对象
 *  @param primaryKey 基本键
 *  @param tag        标签,灵活应用,可以是UIControlState,也可以用于区分同一主题的多个主题对象
 *  @param themeKey   相应的主题属性
 */
- (void)setThemeObject:(NSObject *)themeObj
            primaryKey:(NSString *)primaryKey
                   tag:(NSInteger)tag
              themeKey:(NSString *)themeKey;

/**
 *  添加一个要使用主题的对象
 *  在themeObjs中添加/修改一个字典对象,键为 primaryKey|tag|themeKey,值为 themeObj
 *
 *  @param themeObj   要使用主题的对象
 *  @param primaryKey 基本键
 *  @param tag        标签,灵活应用,可以是UIControlState,也可以用于区分同一主题的多个主题对象
 *  @param themeKey   相应的主题属性
 *  @param attach     附加参数,预设的方法中都用来表示图片的实际大小
 */
- (void)setThemeObject:(NSObject *)themeObj
            primaryKey:(NSString *)primaryKey
                   tag:(NSInteger)tag
              themeKey:(NSString *)themeKey
                attach:(id)attach;

/**
 *  移除一组key对应的对象
 *  移除themeObjs中以 primaryKeys中所有 主键. 开头的键的字典对象
 *
 *  @param primaryKeys 基本键数组
 */
- (void)removeThemeObjectWithPrimaryKeys:(NSArray *)primaryKeys;

/**
 *  移除某个key对应的对象
 *  移除themeObjs中以 primaryKey.开头的键的字典对象
 *
 *  @param primaryKeys 基本键
 */
- (void)removeThemeObjectWithPrimaryKey:(NSString *)primaryKey;

/**
 *  移除某个key的对应的对象在指定状态下应用主题
 *  移除themeObjs中以 primaryKey|tag|themeKey 为键的字典对象
 *
 *  @param primaryKey 基本键
 *  @param tag        标签,灵活应用,可以是UIControlState,也可以用于区分同一主题的多个主题对象
 *  @param themeKey   相应的主题属性
 */
- (void)removeThemeObjectWithPrimaryKey:(NSString *)primaryKey
                                    tag:(NSInteger)tag
                               themeKey:(NSString *)themeKey;

/**
 *  设置某个类使用主题的方式
 *  在themeAppliers中添加/修改一个字典对象,键为 className|tag|themeKey,值为 applier
 *  在themeGetters中添加/修改一个字典对象,键为 className|tag|themeKey,值为 getter
 *
 *  @param className 类名(基本键)
 *  @param tag       标签,灵活应用,可以是UIControlState,也可以用于区分同一主题的多个主题对象
 *  @param themeKey  相应的主题属性
 *  @param applier   使用主题的方式
 *  @param getter    获取主题属性值的方式
 */
- (void)themeApplierAndGetterForClass:(NSString *)className
                                  tag:(NSInteger)tag
                             themeKey:(NSString *)themeKey
                              applier:(VOThemeApplier)applier
                               getter:(VOThemeGetter)getter;

/**
 *  设置某个单例对象使用主题的方式
 *  在themeAppliers中添加/修改一个字典对象,键为 singleton内存地址|tag|themeKey,值为 applier
 *  在themeGetters中添加/修改一个字典对象,键为 singleton内存地址|tag|themeKey,值为 getter
 *
 *  @param singleton 单例对象(基本键)
 *  @param tag       标签,灵活应用,可以是UIControlState,也可以用于区分同一主题的多个主题对象
 *  @param themeKey  相应的主题属性
 *  @param applier   使用主题的方式
 *  @param getter    获取主题属性值的方式
 */
- (void)themeApplierAndGetterForSingleton:(id)singleton
                                      tag:(NSInteger)tag
                                 themeKey:(NSString *)themeKey
                                  applier:(VOThemeApplier)applier
                                   getter:(VOThemeGetter)getter;


@end

@interface VOThemeManager (Preset)

/**
 *  预设主题应用方式
 *  包含类:UIView,UILabel,UIbutton,UINavigationBar,UIBarButtonItem,UIBarItem,UIImageView
 *  包含单例:[UINavigationBar appearance],[UIBarButtonItem appearance],[UIBarItem appearance]
 */
- (void)themeApplierPresets;

@end


@protocol VOThemeProtocol <NSObject>
@optional
/**
 *  是否存在某个主题
 *
 *  @param themeManager 主题管理
 *  @param themeName    主题名称
 *
 *  @return 是否存在
 */
- (BOOL)themeManager:(VOThemeManager *)themeManager
    isExistThemeName:(NSString *)themeName;

/**
 *  读取一个主题(整体读取)
 *
 *  @param themeManager 主题管理器
 *  @param themeName    主题名称
 *  @param cacheHandler 缓存主题的方法
 *
 *  @return 是否读取成功
 */
- (BOOL)themeManager:(VOThemeManager *)themeManager
   readthemeWithName:(NSString *)themeName
        cacheHandler:(void (^)(NSDictionary *))cacheHandler;


/**
 *  自定义读取一条主题数据并引用的方法(单条读取)
 *
 *  @param themeManager 主题管理器
 *  @param themeName    主题名
 *  @param realKey      主题内容的键,primaryKey|tag|themeKey
 *  @param themeHandler 主题内容的处理方式
 */
- (void)themeManager:(VOThemeManager *)themeManager
  applyThemeWithName:(NSString *)themeName
          forRealKey:(NSString *)realKey
        themeApplier:(VOThemeApplier)themeApplier
         themeGetter:(VOThemeGetter)themeGetter;

/**
 *  自定义主题存储方法(整体存储)
 *
 *  @param themeManager   主题管理器
 *  @param theme          主题
 *  @param themeName      主题名
 */
- (void)themeManager:(VOThemeManager *)themeManager
          storeTheme:(id)theme
            withName:(NSString *)themeName;

/**
 *  自定义主题删除方式(整体删除)
 *
 *  @param themeManager 主题管理器
 *  @param themeName    主题名
 */
- (void)themeManager:(VOThemeManager *)themeManager
 removeThemeWithName:(NSString *)themeName;

@end
