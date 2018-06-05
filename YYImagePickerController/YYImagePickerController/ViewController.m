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
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[YYGroupViewController new]] animated:YES completion:nil];
}

@end
