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
    NSArray *keys = @[@"btn1_titleColor",@"btn1_hlColor",@"btn1_selectedColor",@"btn1_disableColor"];
    NSArray *state = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected),@(UIControlStateDisabled)];
    for (NSInteger i = 0; i < keys.count; i ++) {
        [VOThemeManager setThemeObject:self.testButton forKey:keys[i] defaultBlock:^id(UIButton *button) {
            return [button titleColorForState:[state[i] integerValue]];
        } applier:^(UIButton *button, UIColor *color) {
            [button setTitleColor:color forState:[state[i] integerValue]];
        }];
    }
    [VOThemeManager setThemeObject:self.testButton forKey:@"btn1_bgColor" defaultBlock:^id(UIButton *button) {
        return button.backgroundColor;
    } applier:^(UIButton *button, UIColor *color) {
        button.backgroundColor = color;
    }];
}

@end
