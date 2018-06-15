//
//  ViewController2.m
//  JPSuspensionEntrance
//
//  Created by 周健平 on 2018/6/14.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 44)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"点击打开键盘";
    [self.view addSubview:textField];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
