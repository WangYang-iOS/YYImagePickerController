//
//  YYGroupViewController.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYGroupViewController.h"
#import "YYAssetCollectionVC.h"
#import "YYAssetCollection.h"
#import "YYGroupCell.h"
#import "YYData.h"
@interface YYGroupViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation YYGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"本地相册";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 44);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, - 19, 0, 0);
    [button setImage:[UIImage imageNamed:@"icon_yy_back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"YYGroupCell" bundle:nil] forCellReuseIdentifier:@"YYGroupCell"];
    self.mediaType = PHAssetMediaTypeImage;
    self.isCamera = YES;
    self.maxCount = 9;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self allGroupCollection];
            }else if (status == PHAuthorizationStatusDenied) {
                //被拒绝 弹出提示
            }else if (status == PHAuthorizationStatusRestricted) {
                //受限制 例如家长模式
            }
        }];
    }else if (status == PHAuthorizationStatusAuthorized) {
        [self allGroupCollection];
    }else if (status == PHAuthorizationStatusDenied) {
        //被拒绝 弹出提示
    }else if (status == PHAuthorizationStatusRestricted) {
        //受限制 例如家长模式
    }
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YYGroupCell" forIndexPath:indexPath];
    
    id obj = self.dataArray[indexPath.row];
    YYAssetCollection *assetCollection;
    if ([obj isKindOfClass:[PHAssetCollection class]]) {
        assetCollection = [[YYAssetCollection alloc] initWithPHAssetCollection:obj mediaType:self.mediaType];
        [self.dataArray replaceObjectAtIndex:indexPath.row withObject:assetCollection];
    }else if ([obj isKindOfClass:[YYAssetCollection class]]) {
        assetCollection = (YYAssetCollection *)obj;
    }
    
    NSString *groupName = @"";
    if (assetCollection.assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
        groupName = [NSString stringWithFormat:@"相机胶卷（%ld）",assetCollection.count];
    }else {
        groupName = [NSString stringWithFormat:@"%@（%ld）",assetCollection.assetCollection.localizedTitle,assetCollection.count];;
    }
    if (assetCollection.coverImage) {
        [cell layoutGroupCell:assetCollection.coverImage groupName:groupName];
    }else {
        [YYData imageHighQualityFormatFromPHAsset:assetCollection.lastAsset imageSize:CGSizeMake(200, 200) complete:^(UIImage *image) {
            if (image) {
                assetCollection.coverImage = image;
                [cell layoutGroupCell:image groupName:groupName];
            }
        }];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YYAssetCollection *assetCollection = self.dataArray[indexPath.row];
    NSString *groupName = @"";
    if (assetCollection.assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
        groupName = [NSString stringWithFormat:@"相机胶卷（%ld）",assetCollection.count];
    }else {
        groupName = [NSString stringWithFormat:@"%@（%ld）",assetCollection.assetCollection.localizedTitle,assetCollection.count];;
    }
    YYAssetCollectionVC *vc = [YYAssetCollectionVC new];
    vc.navigationItem.title = groupName;
    vc.assetCollection = assetCollection;
    vc.mediaType = self.mediaType;
    vc.isCamera = self.isCamera;
    vc.maxCount = self.maxCount;
    vc.callBack = self.callBack;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark -
#pragma mark - paravite Methods

- (void)allGroupCollection {
    [YYData allMediaDataSourceWithMediaType:self.mediaType callback:^(NSMutableArray<PHAssetCollection *> *array) {
        self.dataArray = array;
        [self.tableView reloadData];
        
        if (array.count > 0) {
            id obj = self.dataArray.firstObject;
            YYAssetCollection *assetCollection;
            if ([obj isKindOfClass:[PHAssetCollection class]]) {
                assetCollection = [[YYAssetCollection alloc] initWithPHAssetCollection:obj mediaType:self.mediaType];
                [self.dataArray addObject:assetCollection];
            }else if ([obj isKindOfClass:[YYAssetCollection class]]) {
                assetCollection = (YYAssetCollection *)obj;
            }
            
            NSString *groupName = @"";
            if (assetCollection.assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                groupName = [NSString stringWithFormat:@"相机胶卷（%ld）",assetCollection.count];
            }else {
                groupName = [NSString stringWithFormat:@"%@（%ld）",assetCollection.assetCollection.localizedTitle,assetCollection.count];
            }
            YYAssetCollectionVC *vc = [YYAssetCollectionVC new];
            vc.navigationItem.title = groupName;
            vc.assetCollection = assetCollection;
            vc.mediaType = self.mediaType;
            vc.isCamera = self.isCamera;
            vc.maxCount = self.maxCount;
            __weak typeof(self) weakSelf = self;
            vc.callBack = ^(NSArray *array) {
                if (weakSelf.callBack) {
                    weakSelf.callBack(array);
                }
            };
            [self.navigationController pushViewController:vc animated:NO];
        }
    }];
}

#pragma mark -
#pragma mark - interface

- (void)clickBackButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}
                      
#pragma mark -
#pragma mark - lazy

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
