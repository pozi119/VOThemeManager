//
//  ViewController.m
//  VOThemeManagerDemo
//
//  Created by Valo on 15/11/27.
//  Copyright © 2015年 Valo. All rights reserved.
//

#import "ViewController.h"
#import "VOThemeManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *testButton;
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [[VOThemeManager sharedManager] setThemeObject:self.testButton primaryKey:@"btn1" tag:UIControlStateNormal themeKey:VOThemeColorKey];
    [[VOThemeManager sharedManager] setThemeObject:self.testButton primaryKey:@"btn1" tag:UIControlStateNormal themeKey:VOThemeBackgroundColorKey];
    [[VOThemeManager sharedManager] setThemeObject:self.testButton primaryKey:@"btn1" tag:UIControlStateHighlighted themeKey:VOThemeColorKey];
    [[VOThemeManager sharedManager] setThemeObject:self.testButton primaryKey:@"btn1" tag:UIControlStateSelected themeKey:VOThemeColorKey];
    [[VOThemeManager sharedManager] setThemeObject:self.testButton primaryKey:@"btn1" tag:UIControlStateDisabled themeKey:VOThemeColorKey];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[VOThemeManager sharedManager] applyThemeWithName:nil];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[VOThemeManager sharedManager] applyThemeWithName:@"test"];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[VOThemeManager sharedManager] applyThemeWithName:@"aaa"];
    });
}

@end
