//
//  VOThemeUtils.m
//  Valo
//
//  Created by Valo on 15/11/24.
//  Copyright © 2015年 Valo. All rights reserved.
//

#import "VOThemeUtils.h"
#import "UIColor+VOHEX.h"

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
    CGSize iSize = image.size;
    CGFloat x = MIN(size.width/iSize.width, size.height/iSize.height);
    CGSize newSize = CGSizeMake(iSize.width * x, iSize.height * x);
    CGFloat scale = [UIScreen mainScreen].scale;
    if (flag) {
        newSize = CGSizeMake(newSize.width * scale, newSize.height * scale);
    }
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
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

@end
