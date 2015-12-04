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
    if (barItems.count >= 3) {
        [[VOThemeManager sharedManager] setThemeObject:barItems[0] primaryKey:@"tb1" tag:UIControlStateNormal themeKey:VOThemeImageKey];
        [[VOThemeManager sharedManager] setThemeObject:barItems[1] primaryKey:@"tb2" tag:UIControlStateNormal themeKey:VOThemeImageKey];
        [[VOThemeManager sharedManager] setThemeObject:barItems[2] primaryKey:@"tb3" tag:UIControlStateNormal themeKey:VOThemeImageKey];
    }
    self.tabBar.tintColor = [UIColor redColor];
    self.tabBar.shadowImage = [UIImage imageNamed:@"tmp_theme_9"];
}

@end
