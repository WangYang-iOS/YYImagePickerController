//
//  YYPhotoItem.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/6.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYAsset;

@interface YYPhotoItem : NSObject

@property (nonatomic, strong, readonly) UIView *sourceView;
@property (nonatomic, strong, readonly) YYAsset *asset;
@property (nonatomic, assign) BOOL finished;

- (instancetype)initWithSourceView:(UIImageView *)view
                             asset:(YYAsset *)asset;

+ (instancetype)itemWithSourceView:(UIImageView *)view
                             asset:(YYAsset *)asset;

- (void)originalImage:(UIImage *)image;

@end
