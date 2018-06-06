//
//  YYPhotoItem.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/6.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYPhotoItem.h"
#import "YYAsset.h"

@interface YYPhotoItem ()

@property (nonatomic, strong, readwrite) UIView *sourceView;
@property (nonatomic, strong, readwrite) YYAsset *asset;

@end
@implementation YYPhotoItem

- (instancetype)initWithSourceView:(UIImageView *)view
                             asset:(YYAsset *)asset {
    self = [super init];
    if (self) {
        _sourceView = view;
        _asset = asset;
    }
    return self;
}

+ (instancetype)itemWithSourceView:(UIImageView *)view
                             asset:(YYAsset *)asset
{
    return [[YYPhotoItem alloc] initWithSourceView:view
                                             asset:asset];
}

- (void)originalImage:(UIImage *)image {
    self.asset.originalImage = image;
}
@end
