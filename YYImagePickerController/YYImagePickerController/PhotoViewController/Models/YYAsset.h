//
//  YYAsset.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface YYAsset : NSObject

@property (nonatomic, strong)  PHAsset *asset;
/**
 是否被选中
 */
@property (assign, nonatomic) BOOL selected;

/**
 是否是相机位
 */
@property (assign, nonatomic) BOOL isCamera;

/**
 相机照片
 */
@property (strong, nonatomic) UIImage * cameraImage;

/**
 视频本地url
 */
@property (strong, nonatomic) NSURL *videoUrl;

/**
 视频时长
 */
@property (copy, nonatomic) NSString * timeLength;

/**
 视频是否在播放
 */
@property (assign, nonatomic) BOOL isPlaying;

/**
 封面截图
 */
@property (nonatomic, strong) UIImage *coverImage;

/**
 原图
 */
@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, assign) PHImageRequestID requestID;

- (YYAsset *)initWithPHAsset:(PHAsset *)asset;

@end
