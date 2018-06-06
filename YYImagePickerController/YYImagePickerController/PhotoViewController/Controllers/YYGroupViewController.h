//
//  YYGroupViewController.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface YYGroupViewController : UIViewController
@property (nonatomic, copy) void (^callBack)(NSArray *array);

@property (nonatomic, assign) PHAssetMediaType mediaType;
@property (nonatomic, assign) BOOL isCamera;
@property (nonatomic, assign) NSInteger maxCount;

@end
