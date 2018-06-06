//
//  YYAssetCell.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYAssetCell.h"

@interface YYAssetCell ()

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation YYAssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)clickSelectButton:(UIButton *)sender {
    if (self.callback) {
        self.callback(sender);
    }
}

- (void)layoutAssetCell:(UIImage *)image timeLength:(NSString *)timeLength isSelected:(BOOL)isSelected {
    self.photoImgView.image = image;
    if (timeLength.length == 0) {
        self.bottomView.hidden = YES;
        self.timeLabel.text = timeLength;
    }else {
        self.bottomView.hidden = NO;
        self.timeLabel.text = timeLength;
    }
    self.selectButton.hidden = NO;
    self.selectButton.selected = isSelected;
}

- (void)layoutCameraAssetCell:(UIImage *)image {
    self.photoImgView.image = image;
    self.bottomView.hidden = YES;
    self.selectButton.hidden = YES;
}

@end
