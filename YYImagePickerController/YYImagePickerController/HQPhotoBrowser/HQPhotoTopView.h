//
//  HQPhotoTopView.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/9/17.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HQPhotoTopView;

@protocol HQPhotoTopViewDelegate <NSObject>
@optional

- (void)didClickBackAtTopView:(UIView *)topView;

@end

@interface HQPhotoTopView : UIView
@property (nonatomic, weak) id <HQPhotoTopViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate;

+ (CGFloat)topHeight;

@end
