//
//  ViewController.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/4/25.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "ViewController.h"
#import "YYImagePickerController.h"
#import "YYGroupViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)clickButton:(id)sender {
    YYGroupViewController *vc = [YYGroupViewController new];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
    vc.callBack = ^(NSArray *array) {
        //
    };
}

@end
