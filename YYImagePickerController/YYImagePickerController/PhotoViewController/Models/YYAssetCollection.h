//
//  YYAssetCollection.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface YYAssetCollection : NSObject

@property (nonatomic, strong) PHAssetCollection *assetCollection;
/**
 对象数量
 */
@property (assign, nonatomic) NSInteger count;

/**
 将最后一个对象获取
 */
@property (strong, nonatomic) PHAsset *lastAsset;

/**
 封面
 */
@property (strong, nonatomic) UIImage *coverImage;

/**
 根据mediaType获取分组的资源
 PHAssetMediaTypeImage ：图片
 PHAssetMediaTypeVideo ：视频
 
 @param assetCollection assetCollection description
 @param mediaType mediaType description
 @return return value description
 */
- (YYAssetCollection *)initWithPHAssetCollection:(PHAssetCollection *)assetCollection mediaType:(PHAssetMediaType)mediaType;
@end
