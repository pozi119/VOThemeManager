//
//  VOThemeUtils.h
//  netCafe
//
//  Created by Valo on 15/11/24.
//  Copyright © 2015年 Sicent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VOThemeImagePathType) {
    VOThemeImagePathInvalid,
    VOThemeImagePathMainBundle,
    VOThemeImagePathLocal,
    VOThemeImagePathAbsoluteURL,
    VOThemeImagePathRelativeURL,
    VOThemeImagePathImage,
};

/**
 *  设置图片的方法
 *
 *  @param aObj  要设置图片的对象
 *  @param image 图片
 *  @param tag   标签,灵活应用,可以是UIControlState,也可以用于区分同一主题的多个主题对象
 */
typedef void(^VOImageHandler)(id aObj, UIImage *image, NSInteger tag);

@interface VOThemeUtils : NSObject
/**
 *  获取颜色
 *
 *  @param originColor 原始数据(表示颜色的UIColor对象,字符串,数字)
 *
 *  @return UIColor对象
 */
+ (UIColor *)colorFormOriginColor:(id)originColor;

/**
 *  获取图片路径类型
 *
 *  @param image 图片或图片路径
 *
 *  @return 图片路径类型
 */
+ (VOThemeImagePathType)imagePathType:(id)image;

/**
 *  调整图片尺寸,默认适应Retina屏幕
 *
 *  @param image 源图片
 *  @param size  调整后的尺寸
 *
 *  @return 调整后的图片
 */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

/**
 *  调整图片尺寸
 *
 *  @param image 源图片
 *  @param size  调整后的尺寸
 *  @param flag  是否适应Retina屏幕
 *
 *  @return 调整后的图片
 */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size fixSreenScale:(BOOL)flag;

/**
 *  当前App存在的指定类的对象
 *
 *  @param viewClass 指定类
 *
 *  @return 所有对象
 */
+ (NSArray *)viewsOfClassInApplicationWindows:(Class)viewClass;

/**
 *  获取某个View中属于指定类的subview
 *
 *  @param viewClass 类
 *  @param inview    源View
 *
 *  @return 所有属于viewClass的subview
 */
+ (NSArray *)viewsOfClass:(Class)viewClass inView:(UIView *)inview;

/**
 *  获取某个View中属于符合指定规则的subview
 *
 *  @param inview    源View
 *  @param predicate 规则
 *
 *  @return 所有属于指定规则的subview
 */
+ (NSArray *)viewsInView:(UIView *)inview matchingPredicate:(NSPredicate *)predicate;


+ (BOOL)convertRealKey:(NSString *)realKey
          toPrimaryKey:(NSString **)primaryKey
                   tag:(NSInteger *)tag
              themeKey:(NSString **)themeKey;

+ (BOOL)convertPrimaryKey:(id)primaryKey
                      tag:(NSInteger)tag
                 themeKey:(NSString *)themeKey
                toRealKey:(NSString **)realKey;

+ (void)configureImageForObject:(NSObject *)aObj
                          image:(id)aImage
                  baseImagePath:(NSString *)baseImagePath
                       themeKey:(NSString *)themeKey
                            tag:(NSInteger)tag
                   imageHandler:(VOImageHandler)imageHandler;


@end
