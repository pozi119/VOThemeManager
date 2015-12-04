//
//  VOThemeManager+Preset.m
//  VOThemeManagerDemo
//
//  Created by Valo on 15/11/26.
//  Copyright © 2015年 Valo. All rights reserved.
//

#import "VOThemeManager.h"
#import "NSObject+WebCacheOperation.h"
#import "NSObject+VOTheme.h"
#import "UIColor+VOHEX.h"

@implementation VOThemeManager (Preset)

#pragma mark - 预设集合
- (void)themeApplierPresets{
    [self presetForUIView];
    [self presetForUILabel];
    [self presetForUIButton];
    [self presetForUINavigationBar];
    [self presetForUIBarButtonItem];
    [self presetForUIBarItemWithChildClass:[UITabBarItem class]];
    [self presetForUIImageView];
    [self presetForUINavigationBarAppearance];
    [self presetForUIBarButtonItemAppearance];
    [self presetForUIBarItemAppearance];
}

#pragma mark - 普通对象
- (void)presetForUIView{
    NSString *className = NSStringFromClass([UIView class]);
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeColorKey applier:^(UIView *view, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        view.tintColor = color;
    } getter:^id(UIView *view, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return view.tintColor;
    }];
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeBackgroundColorKey applier:^(UIView *view, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        view.backgroundColor = color;
    } getter:^id(UIView *view, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return view.backgroundColor;
    }];
}

- (void)presetForUILabel{
    NSString *className = NSStringFromClass([UILabel class]);
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeColorKey applier:^(UILabel *label, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        label.textColor = color;
    } getter:^id(UILabel *label, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return label.textColor;
    }];
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeBackgroundColorKey applier:^(UILabel *label, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        label.backgroundColor = color;
    } getter:^id(UILabel *label, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return label.backgroundColor;
    }];
}


- (void)presetForUIButton{
    NSString *className = NSStringFromClass([UIButton class]);
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeBackgroundColorKey applier:^(UIButton *button, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        button.backgroundColor = color;
    } getter:^id(UIButton *button, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return button.backgroundColor;
    }];
    NSArray *states = @[@(UIControlStateNormal),@(UIControlStateHighlighted),@(UIControlStateSelected),@(UIControlStateDisabled)];
    [states enumerateObjectsUsingBlock:^(NSNumber *stateNum, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger tag = stateNum.integerValue;
        [self themeApplierAndGetterForClass:className tag:tag themeKey:VOThemeColorKey applier:^(UIButton *button, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
            UIColor *color = [VOThemeUtils colorFormOriginColor:value];
            [button setTitleColor:color forState:tag];
        } getter:^id(UIButton *button, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
            return [button titleColorForState:tag];
        }];
        [self themeApplierAndGetterForClass:className tag:tag themeKey:VOThemeImageKey applier:^(UIButton *button, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
            [VOThemeUtils configureImageForObject:button image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(UIButton *button,UIImage *image, NSInteger tag) {
                CGSize size = CGSizeZero;
                if (button.vo_attach) {
                    size = [button.vo_attach CGSizeValue];
                }
                if (CGSizeEqualToSize(size, CGSizeZero)) {
                    CGFloat edge = MIN(button.frame.size.width, button.frame.size.height) * 0.6;
                    size = CGSizeMake(edge, edge);
                }
                UIImage *newImage = [VOThemeUtils scaleImage:image toSize:size];
                [button setImage:newImage forState:tag];
            }];
        } getter:^id(UIButton *button, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
            return [button imageForState:tag];
        }];
        [self themeApplierAndGetterForClass:className tag:tag themeKey:VOThemeBackgroundImageKey applier:^(UIButton *button, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
            [VOThemeUtils configureImageForObject:button image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(UIButton *button,UIImage *image, NSInteger tag) {
                UIImage *newImage = [VOThemeUtils scaleImage:image toSize:button.frame.size];
                [button setBackgroundImage:newImage forState:tag];
            }];
        } getter:^id(UIButton *button, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
            return [button backgroundImageForState:tag];
        }];
    }];
}

- (void)presetForUINavigationBar{
    NSString *className = NSStringFromClass([UINavigationBar class]);
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeColorKey applier:^(UINavigationBar *bar, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        bar.tintColor = color;
    } getter:^id(UINavigationBar *bar, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return bar.tintColor;
    }];
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeBackgroundColorKey applier:^(UINavigationBar *bar, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        bar.backgroundColor = color;
    } getter:^id(UINavigationBar *bar, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return bar.backgroundColor;
    }];
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeBackgroundImageKey applier:^(UINavigationBar *bar, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
        [VOThemeUtils configureImageForObject:bar image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(UINavigationBar *bar,UIImage *image, NSInteger tag) {
            CGSize newSize = CGSizeMake(bar.frame.size.width, bar.frame.size.height + 20);
            UIImage *newImage = [VOThemeUtils scaleImage:image toSize:newSize];
            [bar setBackgroundImage:newImage forBarMetrics:UIBarMetricsDefault];
        }];
    } getter:^id(UINavigationBar *bar, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return [bar backgroundImageForBarMetrics:UIBarMetricsDefault];
    }];
}


- (void)presetForUIBarButtonItem{
    NSString *className = NSStringFromClass([UIBarButtonItem class]);
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeColorKey applier:^(UIBarButtonItem *barButtonItem, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        barButtonItem.tintColor = color;
    } getter:^id(UIBarButtonItem *barButtonItem, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return barButtonItem.tintColor;
    }];
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeImageKey applier:^(UIBarButtonItem *barButtonItem, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
        [VOThemeUtils configureImageForObject:barButtonItem image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(UIBarButtonItem *barButtonItem,UIImage *image, NSInteger tag) {
            UIImage *newImage = [VOThemeUtils scaleImage:image toSize:CGSizeMake(36, 36)];
            barButtonItem.image = newImage;
        }];
    } getter:^id(UIBarButtonItem *barButtonItem, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return barButtonItem.image;
    }];
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeBackgroundImageKey applier:^(UIBarButtonItem *barButtonItem, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
        [VOThemeUtils configureImageForObject:barButtonItem image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(UIBarButtonItem *barButtonItem,UIImage *image, NSInteger tag) {
            UIImage *newImage = [VOThemeUtils scaleImage:image toSize:CGSizeMake(image.size.width * 22 / image.size.height, 22)];
            [barButtonItem setBackgroundImage:newImage forState:tag barMetrics:UIBarMetricsDefault];
        }];
    } getter:^id(UIBarButtonItem *barButtonItem, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return [barButtonItem backgroundImageForState:tag barMetrics:UIBarMetricsDefault];
    }];
}

- (void)presetForUIBarItemWithChildClass:(Class)aChildClass{
    NSString *className = NSStringFromClass(aChildClass);
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeImageKey applier:^(UIBarItem *barItem, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
        [VOThemeUtils configureImageForObject:barItem image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(UIBarItem *barItem,UIImage *image, NSInteger tag) {
            CGSize size = CGSizeZero;
            if (barItem.vo_attach) {
                size = [barItem.vo_attach CGSizeValue];
            }
            if (CGSizeEqualToSize(size, CGSizeZero)) {
                size = CGSizeMake(22, 22);
            }
            UIImage *newImage = [VOThemeUtils scaleImage:image toSize:size];
            barItem.image = newImage;
        }];
    } getter:^id(UIBarItem *barItem, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return barItem.image;
    }];
}

- (void)presetForUIImageView{
    NSString *className = NSStringFromClass([UIImageView class]);
    [self themeApplierAndGetterForClass:className tag:0 themeKey:VOThemeImageKey applier:^(UIImageView *imageView, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
        [VOThemeUtils configureImageForObject:imageView image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(UIImageView *imageView,UIImage *image, NSInteger tag) {
            UIImage *newImage = [VOThemeUtils scaleImage:image toSize:imageView.frame.size];
            imageView.image = newImage;
        }];
    } getter:^id(UIImageView *imageView, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return imageView.image;
    }];
}

#pragma mark - Appearance,单例
- (void)presetForUINavigationBarAppearance{
    [self themeApplierAndGetterForSingleton:[UINavigationBar appearance] tag:0 themeKey:VOThemeColorKey applier:^(id<UIAppearance> bar, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        [UINavigationBar appearance].tintColor = color;
        NSArray *navControllers = [VOThemeUtils viewsOfClassInApplicationWindows:[UINavigationController class]];
        [navControllers enumerateObjectsUsingBlock:^(UINavigationController *navController, NSUInteger idx, BOOL *stop) {
            navController.navigationBar.tintColor = color;
        }];
    } getter:^id(id obj, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return [UINavigationBar appearance].tintColor;
    }];
    [self themeApplierAndGetterForSingleton:[UINavigationBar appearance] tag:0 themeKey:VOThemeBackgroundColorKey applier:^(id<UIAppearance> bar, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        [UINavigationBar appearance].backgroundColor = color;
        NSArray *navControllers = [VOThemeUtils viewsOfClassInApplicationWindows:[UINavigationController class]];
        [navControllers enumerateObjectsUsingBlock:^(UINavigationController *navController, NSUInteger idx, BOOL *stop) {
            navController.navigationBar.backgroundColor = color;
        }];
    } getter:^id(id obj, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return [UINavigationBar appearance].backgroundColor;
    }];
    [self themeApplierAndGetterForSingleton:[UINavigationBar appearance] tag:0 themeKey:VOThemeBackgroundImageKey applier:^(id<UIAppearance> bar, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
        [VOThemeUtils configureImageForObject:[UINavigationBar appearance] image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(id<UIAppearance> appearance,UIImage *image, NSInteger tag) {
            CGSize newSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 64);
            UIImage *newImage = [VOThemeUtils scaleImage:image toSize:newSize];
            [[UINavigationBar appearance] setBackgroundImage:newImage forBarMetrics:UIBarMetricsDefault];
            NSArray *navControllers = [VOThemeUtils viewsOfClassInApplicationWindows:[UINavigationController class]];
            [navControllers enumerateObjectsUsingBlock:^(UINavigationController *navController, NSUInteger idx, BOOL *stop) {
                [navController.navigationBar setBackgroundImage:newImage forBarMetrics:UIBarMetricsDefault];
            }];
        }];
    } getter:^id(id obj, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
    }];
}


- (void)presetForUIBarButtonItemAppearance{
    [self themeApplierAndGetterForSingleton:[UIBarButtonItem appearance] tag:0 themeKey:VOThemeColorKey applier:^(id<UIAppearance> barButtonItem, NSString *primaryKey, NSInteger tag, NSString *themeKey, id value) {
        UIColor *color = [VOThemeUtils colorFormOriginColor:value];
        [UIBarButtonItem appearance].tintColor = color;
        NSArray *bars = [VOThemeUtils viewsOfClassInApplicationWindows:[UINavigationBar class]];
        [bars enumerateObjectsUsingBlock:^(UINavigationBar *bar, NSUInteger idx, BOOL *stop) {
            for (UIBarButtonItem *item in bar.items) {
                item.tintColor = color;
            };
        }];
        NSArray *toolbars = [VOThemeUtils viewsOfClassInApplicationWindows:[UIToolbar class]];
        [toolbars enumerateObjectsUsingBlock:^(UIToolbar *toolbar, NSUInteger idx, BOOL *stop) {
            for (UIBarButtonItem *item in toolbar.items) {
                item.tintColor = color;
            };
        }];
    } getter:^id(id obj, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return [UIBarButtonItem appearance].tintColor;
    }];
    [self themeApplierAndGetterForSingleton:[UIBarButtonItem appearance] tag:0 themeKey:VOThemeImageKey applier:^(id<UIAppearance> barButtonItem, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
        [VOThemeUtils configureImageForObject:[UIBarButtonItem appearance] image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(id<UIAppearance> appearance,UIImage *image, NSInteger tag) {
            UIImage *newImage = [VOThemeUtils scaleImage:image toSize:CGSizeMake(36, 36)];
            [UIBarButtonItem appearance].image = newImage;
            NSArray *bars = [VOThemeUtils viewsOfClassInApplicationWindows:[UINavigationBar class]];
            [bars enumerateObjectsUsingBlock:^(UINavigationBar *bar, NSUInteger idx, BOOL *stop) {
                for (UIBarButtonItem *item in bar.items) {
                    item.image = newImage;
                };
            }];
            NSArray *toolbars = [VOThemeUtils viewsOfClassInApplicationWindows:[UIToolbar class]];
            [toolbars enumerateObjectsUsingBlock:^(UIToolbar *toolbar, NSUInteger idx, BOOL *stop) {
                for (UIBarButtonItem *item in toolbar.items) {
                    item.image = newImage;
                };
            }];
        }];
    } getter:^id(id obj, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return [UIBarButtonItem appearance].image;
    }];
    [self themeApplierAndGetterForSingleton:[UIBarButtonItem appearance] tag:0 themeKey:VOThemeBackgroundImageKey applier:^(id<UIAppearance> barButtonItem, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
        [VOThemeUtils configureImageForObject:[UIBarButtonItem appearance] image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(id<UIAppearance> appearance,UIImage *image, NSInteger tag) {
            UIImage *newImage = [VOThemeUtils scaleImage:image toSize:CGSizeMake(image.size.width * 44 / image.size.height, 44)];
            [[UIBarButtonItem appearance] setBackgroundImage:newImage forState:tag barMetrics:UIBarMetricsDefault];
            NSArray *bars = [VOThemeUtils viewsOfClassInApplicationWindows:[UINavigationBar class]];
            [bars enumerateObjectsUsingBlock:^(UINavigationBar *bar, NSUInteger idx, BOOL *stop) {
                for (UIBarButtonItem *item in bar.items) {
                    [item setBackgroundImage:newImage forState:tag barMetrics:UIBarMetricsDefault];
                };
            }];
            NSArray *toolbars = [VOThemeUtils viewsOfClassInApplicationWindows:[UIToolbar class]];
            [toolbars enumerateObjectsUsingBlock:^(UIToolbar *toolbar, NSUInteger idx, BOOL *stop) {
                for (UIBarButtonItem *item in toolbar.items) {
                    [item setBackgroundImage:newImage forState:tag barMetrics:UIBarMetricsDefault];
                };
            }];
        }];
    } getter:^id(id obj, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return [[UIBarButtonItem appearance] backgroundImageForState:tag barMetrics:UIBarMetricsDefault];
    }];
}

- (void)presetForUIBarItemAppearance{
    [self themeApplierAndGetterForSingleton:[UIBarItem appearance] tag:0 themeKey:VOThemeImageKey applier:^(id<UIAppearance> barItem, NSString *primaryKey, NSInteger tag, NSString *themeKey, id aImage) {
        [VOThemeUtils configureImageForObject:[UIBarItem appearance] image:aImage baseImagePath:self.baseImagePath themeKey:themeKey tag:tag imageHandler:^(id<UIAppearance> appearance,UIImage *image, NSInteger tag) {
            UIImage *newImage = [VOThemeUtils scaleImage:image toSize:CGSizeMake(25, 25)];
            [UIBarItem appearance].image = newImage;
            NSArray *tabbars = [VOThemeUtils viewsOfClassInApplicationWindows:[UITabBar class]];
            [tabbars enumerateObjectsUsingBlock:^(UITabBar *tabbar, NSUInteger idx, BOOL *stop) {
                for (UIBarItem *item in tabbar.items) {
                    item.image = newImage;
                };
            }];
        }];
    } getter:^id(id obj, NSString *primaryKey, NSInteger tag, NSString *themeKey) {
        return [UIBarItem appearance].image;
    }];
}
@end
