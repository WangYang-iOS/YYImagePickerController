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
#import "YYTools.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickButton:(id)sender {
//    [YYTools showVideosWithCount:1 complete:^(id result) {
//        //
//    }];
    [YYTools showImagesWithCount:3 complete:^(id result) {
        //
    }];
}

@end
