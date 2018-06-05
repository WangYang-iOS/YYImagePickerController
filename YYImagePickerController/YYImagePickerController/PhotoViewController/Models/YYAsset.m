//
//  YYAsset.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYAsset.h"
#import "YYData.h"

@implementation YYAsset

- (YYAsset *)initWithPHAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
        self.selected = NO;
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",asset.duration];
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            self.timeLength = timeLength;
        }
    }
    return self;
}


#pragma mark -
#pragma mark - pravate methods

/**
 获取视频时间
 
 @param duration duration description
 @return return value description
 */
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}
@end
