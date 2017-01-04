//
//  SecondViewController.m
//  VOThemeManagerDemo
//
//  Created by Valo on 16/4/14.
//  Copyright © 2016年 Valo. All rights reserved.
//

#import "SecondViewController.h"
#import "VOThemeManager.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    VOThemeManager *manager = [VOThemeManager shared];
    [manager setData:self.label.textColor forKey:@"lb1_textColor" theme:VODefaultTheme];
    [manager registerThemeObject:self.label key:@"lb1_textColor" applier:^(UILabel *label, UIColor *color) {
        label.textColor = color;
    }];
}

@end
