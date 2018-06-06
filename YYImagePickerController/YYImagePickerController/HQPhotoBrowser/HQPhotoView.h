//
//  HQPhotoView.h
//  HQPhotoBrowser
//
//  Created by wangyang on 2018/4/25.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HQPhotoItem;

extern const CGFloat kHQPhotoViewPadding;
extern const CGFloat kHQPhotoViewMaxScale;

@interface HQPhotoView : UIScrollView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) HQPhotoItem *item;

- (void)setItem:(HQPhotoItem *)item determinate:(BOOL)determinate;
- (void)resizeImageView;

@end
