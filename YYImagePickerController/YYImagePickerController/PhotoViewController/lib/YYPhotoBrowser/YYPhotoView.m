//
//  YYPhotoView.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/6.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYPhotoView.h"
#import "YYPhotoItem.h"
#import "YYAsset.h"
#import "YYData.h"

#import <AVFoundation/AVFoundation.h>

const CGFloat kYYPhotoViewPadding = 10;
const CGFloat kYYPhotoViewMaxScale = 3;

@interface YYPhotoView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) YYPhotoItem *item;
@property (nonatomic, strong, readwrite) UIButton *playButton;
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation YYPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bouncesZoom = YES;
        self.maximumZoomScale = kYYPhotoViewMaxScale;
        self.multipleTouchEnabled = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        self.delegate = self;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        _imageView = [[UIImageView alloc] init];
//        _imageView.backgroundColor = [UIColor darkGrayColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        [self resizeImageView];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playButton.frame = CGRectMake(0, 0, 80, 80);
        self.playButton.center = _imageView.center;
        [self.playButton setImage:[UIImage imageNamed:@"icon_yy_play"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
        [self addSubview:self.playButton];
        [self.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        self.playButton.hidden = YES;
        
    }
    return self;
}


#pragma mark -
#pragma mark - interface

- (void)playVideo:(UIButton *)button {
    if (self.item.asset.asset.mediaType == PHAssetMediaTypeVideo) {
        [YYData videoUrlWithAsset:self.item.asset.asset complete:^(NSURL *url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayer *player = [AVPlayer playerWithURL:url];
                AVPlayerLayer *avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                avplayerLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                [self.layer addSublayer:avplayerLayer];
                self.player = player;
                [player play];
            });
        }];
    }
}


#pragma mark -
#pragma mark - pravate methods

- (void)setItem:(YYPhotoItem *)item determinate:(BOOL)determinate {
    _item = item;
    if (item) {
        if (item.asset) {
            if (item.asset.asset.mediaType == PHAssetMediaTypeVideo) {
                self.playButton.hidden = NO;
                self.bouncesZoom = NO;
                self.maximumZoomScale = 1;
            }
            if (item.asset.originalImage) {
                self.imageView.image = item.asset.originalImage;
                [self resizeImageView];
                self.item.finished = YES;
            }else {
                __weak typeof(self) wself = self;
                [YYData originalImageFromPHAsset:item.asset.asset complete:^(UIImage *image) {
                    __strong typeof(wself) sself = wself;
                    if (image) {
                        sself.imageView.image = image;
                        [sself resizeImageView];
                        sself.item.finished = YES;
                    }
                }];
            }
        }
    } else {
        _imageView.image = nil;
        [self resizeImageView];
    }
}

- (void)resizeImageView {
    if (_imageView.image) {
        CGSize imageSize = _imageView.image.size;
        CGFloat width = _imageView.frame.size.width;
        CGFloat height = width * (imageSize.height / imageSize.width);
        CGRect rect = CGRectMake(0, 0, width, height);
        _imageView.frame = rect;
        
        // If image is very high, show top content.
        if (height <= self.bounds.size.height) {
            _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            _imageView.center = CGPointMake(self.bounds.size.width/2, height/2);
        }
        
        // If image is very wide, make sure user can zoom to fullscreen.
        if (width / height > 2) {
            self.maximumZoomScale = self.bounds.size.height / height;
        }
    } else {
        CGFloat width = self.frame.size.width - 2 * kYYPhotoViewPadding;
        _imageView.frame = CGRectMake(0, 0, width, width * 2.0 / 3);
        _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    self.contentSize = _imageView.frame.size;
}

- (BOOL)isScrollViewOnTopOrBottom {
    CGPoint translation = [self.panGestureRecognizer translationInView:self];
    if (translation.y > 0 && self.contentOffset.y <= 0) {
        return YES;
    }
    CGFloat maxOffsetY = floor(self.contentSize.height - self.bounds.size.height);
    if (translation.y < 0 && self.contentOffset.y >= maxOffsetY) {
        return YES;
    }
    return NO;
}

#pragma mark - ScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - GestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
            if ([self isScrollViewOnTopOrBottom]) {
                return NO;
            }
        }
    }
    return YES;
}

@end
