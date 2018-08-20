//
//  YYEnumeration.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/8/20.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#ifndef YYEnumeration_h
#define YYEnumeration_h

/**
 选择的媒体类型
 OnlyPhotosType,图片
 OnlyVideosType,视频
 AllMediaType,图片和视频
 */
typedef enum : NSUInteger {
    AllMediaType = 0,
    OnlyPhotosType,
    OnlyVideosType,
} SelectMediaType;

/**
 拍摄的媒体类型
 PhotoCameraType,拍摄图片
 VideoCameraType,拍摄视频
 AllMediaCameraType,拍摄图片和视频
 */
typedef enum : NSUInteger {
    PhotoCameraType,
    VideoCameraType,
    AllMediaCameraType,
} CameraType;

#endif /* YYEnumeration_h */
