//
//  YYPhotoView.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/6.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYPhotoItem;

extern const CGFloat kYYPhotoViewPadding;
extern const CGFloat kYYPhotoViewMaxScale;

@interface YYPhotoView : UIScrollView
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) YYPhotoItem *item;

- (void)setItem:(YYPhotoItem *)item determinate:(BOOL)determinate;
- (void)resizeImageView;

@end
