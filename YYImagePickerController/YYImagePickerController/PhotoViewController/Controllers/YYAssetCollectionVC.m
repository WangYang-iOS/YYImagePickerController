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
#import "HQPhotoBrowser.h"
#import "YYPhotoBrowser.h"

@interface YYAssetCollectionVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isSingle;//是否单选
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, strong) NSMutableArray *selectArray;
@end

@implementation YYAssetCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"YYAssetCell" bundle:nil] forCellWithReuseIdentifier:@"YYAssetCell"];
    
    self.isSingle = (self.maxCount == 1);
    self.countLabel.text = [NSString stringWithFormat:@"已选择 %lu/%ld",(unsigned long)self.selectArray.count,(long)self.maxCount];
    
    NSMutableArray *array = [YYData allAssetsInAssetCollection:self.assetCollection.assetCollection mediaType:self.mediaType];
    if (self.isCamera) {
        YYAsset *asset = [[YYAsset alloc] init];
        asset.isCamera = YES;
        asset.cameraImage = [UIImage imageNamed:@"icon_yy_camera"];
        [array insertObject:asset atIndex:0];
    }
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
    //判断是否是相机位
    if (asset.isCamera) {
        [cell layoutCameraAssetCell:asset.cameraImage];
    }else {
        if (asset.coverImage) {
            [cell layoutAssetCell:asset.coverImage timeLength:asset.timeLength isSelected:asset.selected];
        }else {
            PHImageRequestID requestID = [YYData imageHighQualityFormatFromPHAsset:asset.asset imageSize:CGSizeMake(200, 200) complete:^(UIImage *image) {
                if (image) {
                    asset.coverImage = image;
                    [cell layoutAssetCell:image timeLength:asset.timeLength isSelected:asset.selected];
                }
            }];
            asset.requestID = requestID;
        }
    }
    
    cell.callback = ^(UIButton *button) {
        if (self.isSingle) {
            //单选
            if ([self.selectArray containsObject:asset]) {
                button.selected = !button.selected;
                asset.selected = !asset.selected;
                [self.selectArray removeObject:asset];
            }else {
                if (self.selectArray.count > 0) {
                    YYAsset *exsitAsset = self.selectArray.firstObject;
                    exsitAsset.selected = !exsitAsset.selected;
                    [self.selectArray removeAllObjects];
                    if (self.lastIndexPath) {
                        [self.collectionView reloadItemsAtIndexPaths:@[self.lastIndexPath]];
                    }
                }
                
                button.selected = !button.selected;
                asset.selected = !asset.selected;
                [self.selectArray addObject:asset];
            }
            self.lastIndexPath = indexPath;
        }else {
            //多选
            if ([self.selectArray containsObject:asset]) {
                button.selected = !button.selected;
                asset.selected = !asset.selected;
                [self.selectArray removeObject:asset];
            }else {
                if (self.selectArray.count == self.maxCount) {
                    //不可再选了
                }else {
                    button.selected = !button.selected;
                    asset.selected = !asset.selected;
                    [self.selectArray addObject:asset];
                }
            }
        }
        self.countLabel.text = [NSString stringWithFormat:@"已选择 %lu/%ld",(unsigned long)self.selectArray.count,(long)self.maxCount];
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
    YYAsset *asset = self.dataArray[indexPath.item];
    //判断点击的是否是相机位
    if (asset.isCamera) {
        if (self.mediaType == PHAssetMediaTypeImage) {
            //拍照
        }else if (self.mediaType == PHAssetMediaTypeVideo || self.mediaType == PHAssetMediaTypeAudio) {
            //视频
        }else {
            //拍照或者视频
        }
    }else {
        //预览
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        YYAssetCell *cell = (YYAssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (self.mediaType ==  PHAssetMediaTypeImage) {
            for (int i = 1; i < self.dataArray.count; i++) {
                id asset = self.dataArray[i];
                if ([asset isKindOfClass:[YYAsset class]]) {
                    YYPhotoItem *item = [YYPhotoItem itemWithSourceView:cell.photoImgView asset:asset];
                    [array addObject:item];
                }else {
                    YYAsset *yAsset = [[YYAsset alloc] initWithPHAsset:asset];
                    YYPhotoItem *item = [YYPhotoItem itemWithSourceView:cell.photoImgView asset:yAsset];
                    [array addObject:item];
                }
            }
            NSInteger index = self.isCamera ? (indexPath.row - 1) : indexPath.row;
            YYPhotoBrowser *browser = [YYPhotoBrowser browserWithPhotoItems:array selectedIndex:index];
            browser.pageindicatorStyle = YYPhotoBrowserPageIndicatorStyleText;
            [browser showFromViewController:self];
        }else if (self.mediaType ==  PHAssetMediaTypeVideo) {
            for (int i = 1; i < self.dataArray.count; i++) {
                id asset = self.dataArray[i];
                if ([asset isKindOfClass:[YYAsset class]]) {
                    YYPhotoItem *item = [YYPhotoItem itemWithSourceView:cell.photoImgView asset:asset];
                    [array addObject:item];
                }else {
                    YYAsset *yAsset = [[YYAsset alloc] initWithPHAsset:asset];
                    YYPhotoItem *item = [YYPhotoItem itemWithSourceView:cell.photoImgView asset:yAsset];
                    [array addObject:item];
                }
            }
            NSInteger index = self.isCamera ? (indexPath.row - 1) : indexPath.row;
            YYPhotoBrowser *browser = [YYPhotoBrowser browserWithPhotoItems:array selectedIndex:index];
            browser.pageindicatorStyle = YYPhotoBrowserPageIndicatorStyleText;
            [browser showFromViewController:self];
        }
    }
}

#pragma mark -
#pragma mark - interface

- (IBAction)clickSureButton:(id)sender {
    //确认
    if (self.selectArray.count == 0) {
        //请选择图片
        return;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if (self.mediaType == PHAssetMediaTypeImage) {
        //只选择图片
        for (int i = 0; i < self.selectArray.count; i++) {
            YYAsset *asset = self.selectArray[i];
            [array addObject:asset.coverImage];
        }
        if (self.callBack) {
            self.callBack(array);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (self.mediaType == PHAssetMediaTypeVideo) {
        //只选择视频
    }
}

- (IBAction)clickPreviewButton:(id)sender {
    //预览
    if (self.selectArray.count == 0) {
        //请选择图片
        return;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if (self.mediaType == PHAssetMediaTypeImage) {
        //只选择图片
        for (int i = 0; i < self.selectArray.count; i++) {
            YYAsset *asset = self.selectArray[i];
            NSInteger index = [self.dataArray indexOfObject:asset];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            YYAssetCell *cell = (YYAssetCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            HQPhotoItem *item = [HQPhotoItem itemWithSourceView:cell.photoImgView asset:asset.asset];
            [array addObject:item];
        }
        HQPhotoBrowser *browser = [HQPhotoBrowser browserWithPhotoItems:array selectedIndex:0];
        [browser showFromViewController:self];
        
    }else if (self.mediaType == PHAssetMediaTypeVideo) {
        //只选择视频
    }
}

#pragma mark -
#pragma mark - lazy

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"%@", [NSString stringWithFormat:@"%@释放了",NSStringFromClass([self class])]);
}

@end
