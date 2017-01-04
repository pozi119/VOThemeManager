//
//  VOThemeManager.h
//  Valo
//
//  Created by Valo on 15/11/20.
//  Copyright © 2015年 Valo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYCache.h"

FOUNDATION_EXPORT NSString *__nonnull const VODefaultTheme;

#pragma mark - block类型定义
/**
 *  加载/下载/删除过程中的操作
 *  @param progress 加载/下载/删除的进度
 *  @param total    加载/下载/删除的总量
 */
typedef void(^VOThemeProgression)(NSInteger progress, NSInteger total);

/**
 *  加载/下载/删除完成后的操作
 *  @param data     加载/下载/删除完成后要操作的数据
 *  @param error    处理过程中的错误
 *  @param finished 操作是否完成
 */
typedef void(^VOThemeCompletion)(id __nullable data, NSError *__nullable error, BOOL finished);
/**
 *  应用主题数据到指定对象
 *  @param themeObj  要应用的主题对象
 *  @param themeData 要应用的主题数据
 */
typedef void(^VOThemeApplier)(id __nonnull themeObj, id __nonnull themeData);

#pragma mark - 主题管理器
/**
 *  主题管理器
 */
@interface VOThemeManager : NSObject
@property (nonatomic, strong, nullable) NSString *currentTheme; ///< 当前主题名
@property (nonatomic, strong, nonnull, readonly) YYCache *currentCache;  ///< 当前主题数据

- (nonnull instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nonnull instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 *  主题管理器
 *  @return 单例
 */
+ (nonnull instancetype)shared;

#pragma mark - 主题相关操作

/**
 *  添加/修改一种主题(已经存在的主题将被替换)
 *  @param themeDic  主题数据,空数据表示删除该主题
 *  @param themeName 主题名
 */
- (BOOL)setData:(nonnull NSDictionary *)themeDic
       forTheme:(nonnull NSString *)themeName;

/**
 *  添加/修改某一跳主题数据
 *  @param themeDic  主题数据,空数据表示删除该主题
 *  @param themeName 主题名
 */
- (void)setData:(nonnull id)themeItem
         forKey:(nonnull NSString *)key
          theme:(nonnull NSString *)themeName;

/**
 *  删除主题,同时删除主题相关缓存
 *  @param themeName 主题名称
 */
- (void)removeTheme:(nonnull NSString *)themeName;

/**
 *  删除主题,同时删除主题相关缓存
 *  @param themeName      主题名称
 *  @param progressBlock  删除过程中的操作
 *  @param completedBlock 删除完成后的操作
 */
- (void)removeTheme:(nonnull NSString *)themeName
        progression:(nullable VOThemeProgression)progression
         completion:(nullable VOThemeCompletion)completion;

#pragma mark - 要应用主题的对象相关操作
- (void)registerThemeObject:(nonnull id)themeObject
                        key:(nonnull NSString *)key
                    applier:(nullable VOThemeApplier)applier;

@end
