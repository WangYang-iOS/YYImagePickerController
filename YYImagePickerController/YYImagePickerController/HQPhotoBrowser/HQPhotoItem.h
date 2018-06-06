//
//  HQPhotoItem.h
//  HQPhotoBrowser
//
//  Created by wangyang on 2018/4/25.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQPhotoItem : NSObject

@property (nonatomic, strong, readonly) UIView *sourceView;
@property (nonatomic, strong, readonly) UIImage *thumbImage;//缩略图 占位图
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) NSURL *imageUrl;
@property (nonatomic, assign) BOOL finished;

- (instancetype)initWithSourceView:(UIView *)view
                                thumbImage:(UIImage *)image
                                  imageUrl:(NSURL *)url;
- (instancetype)initWithSourceView:(UIImageView * )view
                                  imageUrl:(NSURL *)url;
- (instancetype)initWithSourceView:(UIImageView *)view
                                     image:(UIImage *)image;

+ (instancetype)itemWithSourceView:(UIView *)view
                                thumbImage:(UIImage *)image
                                  imageUrl:(NSURL *)url;
+ (instancetype)itemWithSourceView:(UIImageView *)view
                                  imageUrl:(NSURL *)url;
+ (instancetype)itemWithSourceView:(UIImageView *)view
                                     image:(UIImage *)image;

@end
