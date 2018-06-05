//
//  YYAssetCollection.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYAssetCollection.h"
#import "YYData.h"

@implementation YYAssetCollection

/**
 根据mediaType获取分组的资源
 PHAssetMediaTypeImage ：图片
 PHAssetMediaTypeVideo ：视频
 
 @param assetCollection assetCollection description
 @param mediaType mediaType description
 @return return value description
 */
- (YYAssetCollection *)initWithPHAssetCollection:(PHAssetCollection *)assetCollection mediaType:(PHAssetMediaType)mediaType {
    self = [super init];
    if (self) {
        self.assetCollection = assetCollection;
        // 获取分组内对象数量
        
        // 创建过滤器
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        //根据mediaType筛选
        if (mediaType > 0) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",mediaType];
        }
        
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        self.count = assetsFetchResult.count;
        PHAsset *asset = [assetsFetchResult lastObject];
        self.lastAsset = asset;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.coverImage) {
                [YYData imageHighQualityFormatFromPHAsset:asset imageSize:CGSizeMake(200, 200) complete:^(UIImage *image) {
                    if (image) {
                        self.coverImage = image;
                    }else {
                        self.coverImage = [UIImage imageNamed:@"ic_PH_default"];
                    }
                }];
            }
        });
    }
    return self;
}
@end
