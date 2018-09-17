//
//  HQPhotoTopView.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/9/17.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "HQPhotoTopView.h"

@interface HQPhotoTopView ()

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation HQPhotoTopView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:self.backButton];
    }
    return self;
}

#pragma mark -
#pragma mark - pravate methods

+ (CGFloat)topHeight {
    return 49;
}

#pragma mark -
#pragma mark - interface

- (void)clickBackButton {
    if ([self.delegate respondsToSelector:@selector(didClickBackAtTopView:)]) {
        [self.delegate didClickBackAtTopView:self];
    }
}

#pragma mark -
#pragma mark - lazy

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 49, 49);
        [_backButton setImage:[UIImage imageNamed:@"icon_yy_back_white"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

@end
