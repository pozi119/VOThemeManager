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
    for (NSInteger i = 0; i < barItems.count; i ++) {
        NSString *key = [NSString stringWithFormat:@"item%@_image",@(i+1)];
        [VOThemeManager setThemeObject:barItems[i] forKey:key defaultBlock:^id(UITabBarItem *item) {
            return item.image;
        } applier:^(UITabBarItem *item, UIImage *image) {
            item.image = image;
        }];
    }
    self.tabBar.tintColor = [UIColor redColor];
//    self.tabBar.shadowImage = [UIImage imageNamed:@"tmp_theme_9"];
}

@end
