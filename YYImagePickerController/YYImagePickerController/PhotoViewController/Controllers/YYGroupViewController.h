//
//  YYGroupViewController.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "YYEnumeration.h"

@interface YYGroupViewController : UIViewController
@property (nonatomic, copy) void (^callBack)(id result);

@property (nonatomic, assign) NSInteger mediaType;
@property (nonatomic, assign) BOOL isCamera;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, assign) BOOL isCropping;

@end
