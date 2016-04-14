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
    [VOThemeManager setThemeObject:self.label forKey:@"lb1_textColor" defaultBlock:^id(UILabel *label) {
        return label.textColor;
    } applier:^(UILabel *label, UIColor *color) {
        label.textColor = color;
    }];
    VOThemeManager *manager = [VOThemeManager sharedManager];
    NSLog(@"%@", manager);
}

@end
