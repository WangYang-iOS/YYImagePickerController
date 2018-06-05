//
//  YYAssetCollectionVC.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYAssetCollectionVC.h"
#import "YYData.h"
#import "YYTools.h"
#import "YYAssetCollection.h"
#import "YYAssetCell.h"
#import "YYAsset.h"

@interface YYAssetCollectionVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation YYAssetCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"YYAssetCell" bundle:nil] forCellWithReuseIdentifier:@"YYAssetCell"];
    
    NSMutableArray *array = [YYData allAssetsInAssetCollection:self.assetCollection.assetCollection mediaType:self.mediaType];
    self.dataArray = array;
    [self.collectionView reloadData];
}

#pragma mark -
#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YYAssetCell" forIndexPath:indexPath];
    id obj = self.dataArray[indexPath.item];
    __block YYAsset *asset;
    if ([obj isKindOfClass:[PHAsset class]]) {
        asset = [[YYAsset alloc] initWithPHAsset:obj];
        [self.dataArray replaceObjectAtIndex:indexPath.row withObject:asset];
    }else if ([obj isKindOfClass:[YYAsset class]]) {
        asset = (YYAsset *)obj;
    }
    
    if (asset.coverImage) {
        [cell layoutAssetCell:asset.coverImage timeLength:asset.timeLength isSelected:asset.selected];
    }else {
        [YYData imageHighQualityFormatFromPHAsset:asset.asset imageSize:CGSizeMake(200, 200) complete:^(UIImage *image) {
            if (image) {
                asset.coverImage = image;
                [cell layoutAssetCell:image timeLength:asset.timeLength isSelected:asset.selected];
            }
        }];
    }
    
    cell.callback = ^(UIButton *button) {
        button.selected = !button.selected;
        asset.selected = !asset.selected;
    };
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark -
#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake((width - 10) / 3.0, (width - 10) / 3.0);
}

#pragma mark -
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark -
#pragma mark - lazy

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"%@", [NSString stringWithFormat:@"%@释放了",NSStringFromClass([self class])]);
}

@end