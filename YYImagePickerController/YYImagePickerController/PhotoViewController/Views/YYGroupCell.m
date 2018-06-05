//
//  YYGroupCell.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYGroupCell.h"

@interface YYGroupCell ()
@property (weak, nonatomic) IBOutlet UIImageView *groupIcon;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;

@end

@implementation YYGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutGroupCell:(UIImage *)image groupName:(NSString *)groupName {
    self.groupIcon.image = image;
    self.groupLabel.text = groupName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
