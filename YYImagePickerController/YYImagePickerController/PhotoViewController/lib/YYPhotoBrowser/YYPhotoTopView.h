//
//  YYPhotoTopView.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/9/17.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YYPhotoTopView;

@protocol YYPhotoTopViewDelegate <NSObject>
@optional

- (void)didClickBackAtTopView:(UIView *)topView;
- (void)topView:(UIView *)topView didSelectedItem:(UIButton *)button;


@end

@interface YYPhotoTopView : UIView
@property (nonatomic, weak) id <YYPhotoTopViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate;

- (void)showTotalNumber:(NSInteger)totalNumber selectNumber:(NSInteger)selectNumber selected:(BOOL)selected;

+ (CGFloat)topHeight;

@end
