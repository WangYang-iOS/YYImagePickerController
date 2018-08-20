//
//  YYTools.m
//  YYImagePickerController
//
//  Created by wangyang on 2018/6/5.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "YYTools.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "YYGroupViewController.h"
#import "RSKImageCropViewController.h"

typedef void(^YYToolCameraSureBlock)(id result);
typedef void(^YYToolCancelBlock)(void);
typedef void(^YYToolDismissBlock)(void);

static YYTools *manager;

@interface YYTools ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
/**
 照相机 单选
 */
@property (strong, nonatomic) UIImagePickerController *pickerViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (copy, nonatomic)  YYToolCameraSureBlock cameraSureBlock;
@property (copy, nonatomic)  YYToolCancelBlock cancelBlock;
@property (copy, nonatomic)  YYToolDismissBlock dismissBlock;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (assign, nonatomic) BOOL cameraCanCrop;
@end

@implementation YYTools

+ (YYTools *)shareManager {
    if (!manager) {
        manager = [[YYTools alloc] init];
    }
    return manager;
}

/**
 调取照相机和摄像机 单张
 
 @param viewController 试图控制器
 @param sure 确定
 @param cancel 取消
 */
+ (void)showCameraInViewController:(UIViewController *)viewController cameraType:(CameraType)cameraType sure:(void(^)(id result))sure cancel:(void(^)(void))cancel dismiss:(void(^)(void))dismiss {
    // 判断是否有相机
    [YYTools shareManager].cameraCanCrop = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if (cameraType == PhotoCameraType) {
            picker.mediaTypes = @[(NSString *)kUTTypeImage];
        }else if (cameraType == VideoCameraType) {
            picker.mediaTypes = @[(NSString *)kUTTypeMovie];
        }else {
            picker.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
        }
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;//设置相机后摄像头
        picker.videoMaximumDuration = 10;//最长拍摄时间
        picker.videoQuality = UIImagePickerControllerQualityTypeHigh;//拍摄质量
        
        picker.allowsEditing = NO;//是否可编辑
        picker.delegate = [YYTools shareManager];
        [viewController presentViewController:picker animated:YES completion:nil];
        [YYTools shareManager].pickerViewController = picker;
    }else {
        NSLog(@"该设备无摄像头");
    }
    [YYTools shareManager].cameraSureBlock = sure;
    [YYTools shareManager].cancelBlock = cancel;
    [YYTools shareManager].dismissBlock = dismiss;
}

/**
 调取照相机 单张 方形切割
 
 @param viewController 试图控制器
 @param sure 确定
 @param cancel 取消
 */
+ (void)showCameraWithCropInViewController:(UIViewController *)viewController sure:(void(^)(id result))sure cancel:(void(^)(void))cancel dismiss:(void(^)(void))dismiss {
    // 判断是否有相机
    [YYTools shareManager].cameraCanCrop = YES;
    [YYTools shareManager].currentViewController = viewController;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = @[(NSString *)kUTTypeImage];
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;//设置相机后摄像头
        picker.videoMaximumDuration = 10;//最长拍摄时间
        picker.videoQuality = UIImagePickerControllerQualityTypeHigh;//拍摄质量
        
        picker.allowsEditing = NO;//是否可编辑
        picker.delegate = [YYTools shareManager];
        [viewController presentViewController:picker animated:YES completion:nil];
        [YYTools shareManager].pickerViewController = picker;
    }else {
        NSLog(@"该设备无摄像头");
    }
    [YYTools shareManager].cameraSureBlock = sure;
    [YYTools shareManager].cancelBlock = cancel;
    [YYTools shareManager].dismissBlock = dismiss;
}

/**
 调取照相机
 
 @param viewController 视图控制器
 @param sure 确定
 @param cancel 取消
 */
+ (void)showPhotoCameraInViewController:(UIViewController *)viewController sure:(void(^)(UIImage *image))sure cancel:(void(^)(void))cancel dismiss:(void(^)(void))dismiss {
    [YYTools showCameraInViewController:viewController cameraType:PhotoCameraType sure:sure cancel:cancel dismiss:dismiss];
}

/**
 调取摄像机拍摄视频
 
 @param viewController 视图控制器
 @param sure 确定
 @param cancel 取消
 */
+ (void)showVideoCameraInViewController:(UIViewController *)viewController sure:(void(^)(NSURL *videoUrl))sure cancel:(void(^)(void))cancel dismiss:(void(^)(void))dismiss {
    [YYTools showCameraInViewController:viewController cameraType:VideoCameraType sure:sure cancel:cancel dismiss:dismiss];
}

#pragma mark -
#pragma mark - PRIVATE METHOD <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([YYTools shareManager].cancelBlock) {
        [YYTools shareManager].cancelBlock ();
    }
    [[YYTools shareManager].pickerViewController dismissViewControllerAnimated:YES completion:^{
        if ([YYTools shareManager].dismissBlock) {
            [YYTools shareManager].dismissBlock();
        }
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (picker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        if ([YYTools shareManager].cameraCanCrop) {
            //            RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeSquare];
            //            imageCropVC.delegate = [PHTool shareManager];
            //            imageCropVC.ratio = 5.0f;
            //            [[PHTool shareManager].pickerViewController presentViewController:imageCropVC animated:YES completion:nil];
        }else {
            if ([YYTools shareManager].cameraSureBlock) {
                [YYTools shareManager].cameraSureBlock (image);
                [[YYTools shareManager].pickerViewController dismissViewControllerAnimated:YES completion:^{
                    if ([YYTools shareManager].dismissBlock) {
                        [YYTools shareManager].dismissBlock();
                    }
                }];
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
        }
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSLog(@"video...");
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if ([YYTools shareManager].cameraSureBlock) {
            [YYTools shareManager].cameraSureBlock (url);
            [[YYTools shareManager].pickerViewController dismissViewControllerAnimated:YES completion:^{
                if ([YYTools shareManager].dismissBlock) {
                    [YYTools shareManager].dismissBlock();
                }
            }];
        }
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
        
    }
}
#pragma mark - Delegate Method: RSKImageCropViewControllerDelegate

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect {
    [controller dismissViewControllerAnimated:YES completion:nil];
    if ([YYTools shareManager].cameraSureBlock) {
        [YYTools shareManager].cameraSureBlock (croppedImage);
        [[YYTools shareManager].pickerViewController dismissViewControllerAnimated:YES completion:^{
            if ([YYTools shareManager].dismissBlock) {
                [YYTools shareManager].dismissBlock();
            }
        }];
    }
    UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);//保存到相簿
}
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"用户放弃裁剪图片");
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
}

#pragma mark --
#pragma mark -- 弹出相册

/**
 弹出自定义相册 默认到所有照片中 (无视频)
 不裁剪
 @param count 选择数量
 */
+ (void)showImagesWithCount:(NSInteger)count complete:(void(^)(id result))complete {
    [YYTools showImagesWithCount:count isCropping:NO complete:^(id result) {
        if (complete) {
            complete(result);
        }
    }];
}

/**
 弹出自定义相册 默认到所有照片中 (无视频，默认可以拍照)
 @param count 选择数量
 @param isCropping 是否裁剪（count == 1有效）
 */
+ (void)showImagesWithCount:(NSInteger)count isCropping:(BOOL)isCropping complete:(void(^)(id result))complete {
    [YYTools showAssetWithCount:count mediaType:OnlyPhotosType isCamera:YES isCropping:isCropping complete:^(id result) {
        if (complete) {
            complete(result);
        }
    }];
}

/**
 弹出自定义相册 默认到所有视频中
 
 @param complete complete
 */
+ (void)showVideosWithCount:(NSInteger)count complete:(void(^)(id result))complete {
    [YYTools showAssetWithCount:count mediaType:OnlyVideosType isCamera:NO isCropping:NO complete:^(id result) {
        if (complete) {
            complete(result);
        }
    }];
}

/**
 弹出自定义相册 包含视频和图片
 
 @param count count description
 @param complete complete description
 */
+ (void)showAllAssetWithCount:(NSInteger)count complete:(void(^)(id result))complete {
    [YYTools showAssetWithCount:count mediaType:AllMediaType isCamera:NO isCropping:NO complete:^(id result) {
        if (complete) {
            complete(result);
        }
    }];
}

/**
 弹出相册 （默认到第一个分组）
 
 @param count 选择数量
 @param mediaType mediaType description
 @param isCropping 是否裁剪（mediaType = OnlyPhotoType count = 1有效）
 @param complete complete description
 */
+ (void)showAssetWithCount:(NSInteger)count
                 mediaType:(SelectMediaType)mediaType
                  isCamera:(BOOL)isCamera
                isCropping:(BOOL)isCropping
                  complete:(void(^)(id result))complete {
    YYGroupViewController *vc = [[YYGroupViewController alloc] init];
    vc.maxCount = count;
    vc.isCropping = isCropping;
    vc.mediaType = mediaType;
    vc.isCamera = isCamera;
    vc.callBack = ^(id asset) {
        if (complete) {
            complete (asset);
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window.rootViewController presentViewController:nav animated:YES completion:nil];
}

+ (void)release {
    manager = nil;
    [YYTools shareManager].cancelBlock = nil;
    [YYTools shareManager].navigationController = nil;
    [YYTools shareManager].cameraSureBlock = nil;
}
@end
