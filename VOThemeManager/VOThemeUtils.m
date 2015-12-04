//
//  VOThemeUtils.m
//  netCafe
//
//  Created by Valo on 15/11/24.
//  Copyright © 2015年 Sicent. All rights reserved.
//

#import "VOThemeUtils.h"
#import "UIColor+VOHEX.h"
#import "NSObject+WebCacheOperation.h"

@implementation VOThemeUtils
+ (UIColor *)colorFormOriginColor:(id)originColor{
    UIColor *color = nil;
    if ([originColor isKindOfClass:[UIColor class]]) {
        color = originColor;
    }
    else if ([originColor isKindOfClass:[NSString class]]){
        NSString *colorString = (NSString *)originColor;
        color = [UIColor colorWithHexString:colorString];
    }
    else if ([originColor isKindOfClass:[NSNumber class]]){
        NSNumber *number = (NSNumber *)originColor;
        color = [UIColor colorWithHex:(UInt32)[number unsignedIntegerValue]];
    }
    return color;
}

+ (VOThemeImagePathType)imagePathType:(id)image{
    if ([image isKindOfClass:[UIImage class]] || image == nil) {
        return VOThemeImagePathImage;
    }
    if (![image isKindOfClass:[NSString class]]) {
        return VOThemeImagePathInvalid;
    }
    NSString *imagePath = image;
    if (imagePath.length <= 0) {
        return VOThemeImagePathInvalid;
    }
    NSRange range = [imagePath rangeOfString:@"/" options:NSLiteralSearch];
    if (range.length == 0) {
        return VOThemeImagePathMainBundle;
    }
    range = [imagePath rangeOfString:@"file:///" options:NSLiteralSearch];
    if (range.length > 0) {
        return VOThemeImagePathLocal;
    }
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isDirectory] && !isDirectory) {
        return VOThemeImagePathLocal;
    }
    range = [imagePath rangeOfString:@"http://" options:NSLiteralSearch];
    if (range.length > 0) {
        return VOThemeImagePathAbsoluteURL;
    }
    return VOThemeImagePathRelativeURL;
}

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size{
    return [[self class] scaleImage:image toSize:size fixSreenScale:YES];
}

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size fixSreenScale:(BOOL)flag{
    CGSize newSize = size;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (flag) {
        newSize = CGSizeMake(size.width * scale, size.height * scale);
    }
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (flag) {
        scaledImage = [UIImage imageWithCGImage:scaledImage.CGImage scale:scale orientation:UIImageOrientationUp];
    }
    return scaledImage;
}

+ (NSArray *)viewControllersOfApplictaion{
    NSArray *windows = [UIApplication sharedApplication].windows;
    NSMutableArray *array = @[].mutableCopy;
    for (UIWindow *window in windows) {
        UIViewController *viewController = window.rootViewController;
        [array addObjectsFromArray:[[self class] allViewControllersOfViewController:viewController]];
    }
    return array;
}

+ (NSArray *)allViewControllersOfViewController:(UIViewController *)viewController{
    if(!viewController || ![viewController isKindOfClass:[UIViewController class]]){
        return @[];
    }
    NSMutableArray *array = @[viewController].mutableCopy;
    if(viewController.childViewControllers.count > 0){
        for (UIViewController *child in viewController.childViewControllers) {
            [array addObjectsFromArray:[[self class] allViewControllersOfViewController:child]];
        }
    }
    return array;
}

+ (NSArray *)viewsOfClassInApplicationWindows:(Class)viewClass{
    NSMutableArray *array = @[].mutableCopy;
    NSString *className = NSStringFromClass(viewClass);
    NSRange range = [className rangeOfString:@"Controller"];
    NSArray *allVCs = [[self class] viewControllersOfApplictaion];
    if (range.location != NSNotFound && range.length > 0) {
        for (UIViewController *vc in allVCs) {
            if ([vc isKindOfClass:viewClass]) {
                [array addObject:vc];
            }
        }
    }
    else{
        for (UIViewController *vc in allVCs) {
            [array addObjectsFromArray:[[self class] viewsOfClass:viewClass inView:vc.view]];
        }
    }
    return array;
}

+ (NSArray *)viewsOfClass:(Class)viewClass inView:(UIView *)inview{
    return [[self class] viewsInView:inview matchingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, __unused id bindings) {
        return [evaluatedObject isKindOfClass:viewClass];
    }]];
}

+ (NSArray *)viewsInView:(UIView *)inview matchingPredicate:(NSPredicate *)predicate{
    if (![inview isKindOfClass:[UIView class]]) {
        return @[];
    }
    NSMutableArray *matches = [NSMutableArray array];
    if ([predicate evaluateWithObject:inview]){
        [matches addObject:inview];
    }
    for (UIView *view in inview.subviews){
        //check for subviews
        //avoid creating unnecessary array
        if ([view.subviews count]){
            [matches addObjectsFromArray:[[self class] viewsInView:inview matchingPredicate:predicate]];
        }
        else if ([predicate evaluateWithObject:view]){
            [matches addObject:view];
        }
    }
    return matches;
}


+ (BOOL)convertRealKey:(NSString *)realKey
          toPrimaryKey:(NSString **)primaryKey
                   tag:(NSInteger *)tag
              themeKey:(NSString **)themeKey{
    if (!(realKey && realKey.length > 0 && primaryKey && tag && themeKey)) {
        return NO;
    }
    NSArray *array = [realKey componentsSeparatedByString:@"|"];
    if (array.count != 3) {
        return NO;
    }
    *primaryKey = array[0];
    *tag = [array[1] integerValue];
    *themeKey = array[2];
    return YES;
}

+ (BOOL)convertPrimaryKey:(id)primaryKey
                      tag:(NSInteger)tag
                 themeKey:(NSString *)themeKey
                toRealKey:(NSString **)realKey{
    if (!(primaryKey && themeKey && realKey)) {
        return NO;
    }
    NSString *newPrimaryKey = nil;
    if ([primaryKey isKindOfClass:[NSString class]]) {
        newPrimaryKey = primaryKey;
        if (newPrimaryKey.length == 0) {
            return NO;
        }
    }
    else{
        newPrimaryKey = [NSString stringWithFormat:@"%p", primaryKey];
    }
    *realKey = [NSString stringWithFormat:@"%@|%@|%@",newPrimaryKey,@(tag),themeKey];
    return YES;
}

+ (void)configureImageForObject:(NSObject *)aObj
                          image:(id)aImage
                  baseImagePath:(NSString *)baseImagePath
                       themeKey:(NSString *)themeKey
                            tag:(NSInteger)tag
                   imageHandler:(VOImageHandler)imageHandler{
    NSString *loadKey = [NSString stringWithFormat:@"%@%@Loading", themeKey,NSStringFromClass([aObj class])];
    VOThemeImagePathType type = [VOThemeUtils imagePathType:aImage];
    switch (type) {
        case VOThemeImagePathMainBundle: {
            UIImage *image = [UIImage imageNamed:aImage];
            imageHandler(aObj,image, tag);
            break;
        }
        case VOThemeImagePathLocal:
        case VOThemeImagePathAbsoluteURL: {
            [aObj sd_setImageWithURL:[NSURL URLWithString:aImage] loadkey:loadKey loadImageBlock:^(UIImage *image) {
                imageHandler(aObj,image, tag);
            }];
            break;
        }
        case VOThemeImagePathRelativeURL:{
            if (baseImagePath && baseImagePath.length > 0) {
                NSString *fullPath = [baseImagePath stringByAppendingString:aImage];
                [aObj sd_setImageWithURL:[NSURL URLWithString:fullPath] loadkey:loadKey loadImageBlock:^(UIImage *image) {
                    imageHandler(aObj,image, tag);
                }];
            }
            break;
        }
        case VOThemeImagePathImage: {
            imageHandler(aObj,aImage, tag);
        }
        default: {
            break;
        }
    }
}

@end
