//
//  VOThemeManager.h
//  Valo
//
//  Created by Valo on 15/11/20.
//  Copyright © 2015年 Valo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYCache.h"

/**
 *  加载/下载/删除过程中的操作
 *
 *  @param progress 加载/下载/删除的进度
 *  @param total    加载/下载/删除的总量
 */
typedef void(^VOThemeProgression)(NSInteger progress, NSInteger total);

/**
 *  加载/下载/删除完成后的操作
 *
 *  @param data     加载/下载/删除完成后要操作的数据
 *  @param error    处理过程中的错误
 *  @param finished 操作是否完成
 */
typedef void(^VOThemeCompletion)(id __nullable data, NSError *__nullable error, BOOL finished);
/**
 *  应用主题数据到指定对象
 *
 *  @param themeObj  要应用的主题对象
 *  @param themeData 要应用的主题数据
 */
typedef void(^VOThemeApplier)(id __nonnull themeObj, id __nonnull themeData);

/**
 *  获取主题默认值
 *
 *  @param themeObj 要获取默认值的对象
 *
 *  @return 默认的主题数据
 */
typedef id __nullable(^VOThemeDefaultBlock)(id __nonnull themeObj);

/**
 *  主题管理器
 */
@interface VOThemeManager : NSObject

/**
 *  @brief 当前主题名称
 *  @brief set方法为切换主题,设置nil或者不存在的主题名时使用默认主题
 */
@property (nonatomic, strong, nullable) NSString *currentTheme;

- (nonnull instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nonnull instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 *  皮肤管理器
 *
 *  @return 单例
 */
+ (nonnull instancetype)sharedManager;

#pragma mark - 主题相关操作
+ (NSString * _Nullable)currentTheme;

+ (void)setCurrentTheme:(NSString * _Nullable)currentTheme;

/**
 *  添加/修改一种主题
 *
 *  @param themeDic  主题数据,空数据表示删除该主题
 *  @param themeName 主题名
 */
+ (BOOL)setData:(nonnull NSDictionary *)themeDic
       forTheme:(nonnull NSString *)themeName;

/**
 *  删除主题,同时删除主题相关缓存
 *
 *  @param themeName 主题名称
 */
+ (void)removeTheme:(nonnull NSString *)themeName;

/**
 *  删除主题,同时删除主题相关缓存
 *
 *  @param themeName      主题名称
 *  @param progressBlock  删除过程中的操作
 *  @param completedBlock 删除完成后的操作
 */
+ (void)removeTheme:(nonnull NSString *)themeName
        progression:(nullable VOThemeProgression)progression
         completion:(nullable VOThemeCompletion)completion;

/**
 *  删除所有主题
 */
+ (void)removeAllThemes;

/**
 *  删除多个主题
 *
 *  @param progressBlock  删除过程中的操作
 *  @param completedBlock 删除完成后的操作
 */
+ (void)removeAllThemes:(nullable VOThemeProgression)progression
             completion:(nullable VOThemeCompletion)completion;
/**
 *  删除多个主题
 *
 *  @param themeNames     主题名称数组
 */
+ (void)removeThemes:(nullable NSArray *)themeNames;

/**
 *  删除多个主题
 *
 *  @param themeNames     主题名称数组
 *  @param progressBlock  删除过程中的操作
 *  @param completedBlock 删除完成后的操作
 */
+ (void)removeThemes:(nullable NSArray *)themeNames
         progression:(nullable VOThemeProgression)progression
          completion:(nullable VOThemeCompletion)completion;

#pragma mark - 要应用主题的对象相关操作
+ (void)setThemeObject:(nullable id)themeObject
                forKey:(nonnull NSString *)key
          defaultBlock:(nullable VOThemeDefaultBlock)defaultBlock
               applier:(nullable VOThemeApplier)applier;


@end
