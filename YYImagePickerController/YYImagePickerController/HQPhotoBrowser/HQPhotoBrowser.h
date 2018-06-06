//
//  HQPhotoBrowser.h
//  HQPhotoBrowser
//
//  Created by wangyang on 2018/4/25.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQPhotoItem.h"

typedef NS_ENUM(NSUInteger, HQPhotoBrowserInteractiveDismissalStyle) {
    HQPhotoBrowserInteractiveDismissalStyleRotation,
    HQPhotoBrowserInteractiveDismissalStyleScale,
    HQPhotoBrowserInteractiveDismissalStyleSlide,
    HQPhotoBrowserInteractiveDismissalStyleNone
};

typedef NS_ENUM(NSUInteger, HQPhotoBrowserBackgroundStyle) {
    HQPhotoBrowserBackgroundStyleBlurPhoto,
    HQPhotoBrowserBackgroundStyleBlur,
    HQPhotoBrowserBackgroundStyleBlack
};

typedef NS_ENUM(NSUInteger, HQPhotoBrowserPageIndicatorStyle) {
    HQPhotoBrowserPageIndicatorStyleDot,
    HQPhotoBrowserPageIndicatorStyleText
};

typedef NS_ENUM(NSUInteger, HQPhotoBrowserImageLoadingStyle) {
    HQPhotoBrowserImageLoadingStyleIndeterminate,
    HQPhotoBrowserImageLoadingStyleDeterminate
};

@interface HQPhotoBrowser : UIViewController
@property (nonatomic, assign) HQPhotoBrowserInteractiveDismissalStyle dismissalStyle;
@property (nonatomic, assign) HQPhotoBrowserBackgroundStyle backgroundStyle;
@property (nonatomic, assign) HQPhotoBrowserPageIndicatorStyle pageindicatorStyle;
@property (nonatomic, assign) HQPhotoBrowserImageLoadingStyle loadingStyle;
@property (nonatomic, assign) BOOL bounces;

+ (instancetype)browserWithPhotoItems:(NSArray<HQPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex;
- (instancetype)initWithPhotoItems:(NSArray<HQPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex;
- (void)showFromViewController:(UIViewController *)vc;

@end
