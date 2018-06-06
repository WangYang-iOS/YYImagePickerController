//
//  YYAssetCell.h
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYAssetCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;

@property (nonatomic, copy) void(^callback)(UIButton *button);

- (void)layoutAssetCell:(UIImage *)image timeLength:(NSString *)timeLength isSelected:(BOOL)isSelected;

- (void)layoutCameraAssetCell:(UIImage *)image;

@end
