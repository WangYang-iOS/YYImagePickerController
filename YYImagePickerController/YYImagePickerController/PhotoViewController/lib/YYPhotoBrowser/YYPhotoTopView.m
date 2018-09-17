//
//  YYPhotoTopView.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/9/17.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYPhotoTopView.h"

@interface YYPhotoTopView ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UILabel *numberLabel;
@end

@implementation YYPhotoTopView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:self.backButton];
        [self addSubview:self.selectButton];
        [self addSubview:self.numberLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:self.backButton];
        [self addSubview:self.selectButton];
        [self addSubview:self.numberLabel];
    }
    return self;
}

#pragma mark -
#pragma mark - pravate methods

- (void)showTotalNumber:(NSInteger)totalNumber selectNumber:(NSInteger)selectNumber selected:(BOOL)selected {
    self.numberLabel.text = [NSString stringWithFormat:@"%ld / %ld",(long)selectNumber,(long)totalNumber];
    self.selectButton.selected = selected;
}

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

- (void)clickSelectButton:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(topView:didSelectedItem:)]) {
        [self.delegate topView:self didSelectedItem:button];
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

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.frame = CGRectMake(self.bounds.size.width - 49, 0, 49, 49);
        [_selectButton setImage:[UIImage imageNamed:@"icon_yy_unSelected"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"icon_yy_selected"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(clickSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(49, 0, self.bounds.size.width - 49 * 2, 49)];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.font = [UIFont systemFontOfSize:16];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _numberLabel;
}

@end
