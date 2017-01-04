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
    /* 设置要应用的对象 */
    VOThemeManager *manager = [VOThemeManager shared];
    NSArray *keys = @[@"btn1_titleColor",@"btn1_hlColor",@"btn1_selectedColor",@"btn1_disableColor"];
    NSArray *state = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected),@(UIControlStateDisabled)];
    for (NSInteger i = 0; i < keys.count; i ++) {
        UIColor *color = [self.testButton titleColorForState:[state[i] integerValue]];
        [manager setData:color forKey:keys[i] theme:VODefaultTheme];
        [manager registerThemeObject:self.testButton key:keys[i] applier:^(UIButton *btn, UIColor *color) {
            [btn setTitleColor:color forState:[state[i] integerValue]];
        }];
    }
    [manager setData:self.testButton.backgroundColor forKey:@"btn1_bgColor" theme:VODefaultTheme];
    [manager registerThemeObject:self.testButton key:@"btn1_bgColor" applier:^(UIButton *btn, UIColor *color) {
        btn.backgroundColor = color;
    }];
}

@end
