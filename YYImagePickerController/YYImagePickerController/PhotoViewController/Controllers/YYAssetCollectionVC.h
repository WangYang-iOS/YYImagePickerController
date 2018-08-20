//
//  YYAssetCollectionVC.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class YYAssetCollection;

@interface YYAssetCollectionVC : UIViewController

@property (nonatomic, copy) void (^callBack)(NSArray *array);

@property (nonatomic, strong) YYAssetCollection *assetCollection;
@property (nonatomic, assign) NSInteger mediaType;

@property (nonatomic, assign) BOOL isCamera;
@property (nonatomic, assign) NSInteger maxCount;

@end
