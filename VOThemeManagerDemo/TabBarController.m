//
//  TabBarController.m
//  VOThemeManagerDemo
//
//  Created by Valo on 15/11/27.
//  Copyright © 2015年 Valo. All rights reserved.
//

#import "TabBarController.h"
#import "VOThemeManager.h"

@implementation TabBarController

- (void)viewDidLoad{
    [super viewDidLoad];
    NSArray *barItems = self.tabBar.items;
    VOThemeManager *manager = [VOThemeManager shared];
    for (NSInteger i = 0; i < barItems.count; i ++) {
        UITabBarItem *item = barItems[i];
        NSString *key = [NSString stringWithFormat:@"item%@_image",@(i+1)];
        [manager setData:item.image forKey:key theme:VODefaultTheme];
        [manager registerThemeObject:item key:key applier:^(UITabBarItem *item, UIImage *image) {
            item.image = image;
        }];
    }
    self.tabBar.tintColor = [UIColor redColor];
}

@end
