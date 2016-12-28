//
//  YppImageManager.m
//  YppLife
//
//  Created by zhz on 9/26/16.
//  Copyright © 2016 WYWK. All rights reserved.
//

#import "YppImageManager.h"
#import "YppAssetCollectionViewModel.h"
#import "YppAssetViewModel.h"
#import "UIViewController+CurrentViewController.h"
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface YppImageManager ()


@end
@implementation YppImageManager

+ (instancetype)manager
{
    static YppImageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;

}

/* 获取"相机胶卷"的照片 */
- (void)getCameraRollWithImagesType:(ManagerAssetMediaType)assetMediaType completion:(void (^)(YppAssetCollectionViewModel *assetCollectionViewModel))completion
{
    if (NSClassFromString(@"PHFetchResult"))
    {
        PHAssetMediaType type = [self switchMediaType:assetMediaType];

        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", type];

        PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
            [smartAlbums enumerateObjectsWithOptions:0 usingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL *stop) {
                if (![obj isKindOfClass:[PHAssetCollection class]]) return;

                // 只获取"相机胶卷"的照片
                if ([self isCameraRollAlbum:obj.localizedTitle]) {
                    
                    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:obj options:fetchOptions];
                    
                    YppAssetCollectionViewModel *model = [[YppAssetCollectionViewModel alloc] initWithFetchResult:fetchResult title:obj.localizedTitle assetMediaType:type];
                    if (completion) completion(model);
                    *stop = YES;
                }

            }];
        }
}

/* 获取某个相册中的所有照片/视频 */
- (void)getAssetsFromFetchResult:(PHFetchResult<PHAsset *> *)result assetMediaType:(ManagerAssetMediaType)assetMediaType completion:(void (^)(NSArray<YppAssetViewModel *> *assetModels))completion
{
    PHAssetMediaType type = [self switchMediaType:assetMediaType];
    NSMutableArray<YppAssetViewModel *> *photoArr = [NSMutableArray array];

    // 遍历相册中的每个相册
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![asset isKindOfClass:[PHAsset class]]) return;
        if (asset.mediaType != type) return;
                
        YppAssetViewModel *assetModel = [[YppAssetViewModel alloc] initWithPHAsset:asset];
        [photoArr addObject:assetModel];
        
    }];
    if (completion) {
        completion(photoArr);
    }
    
}

/* 获取"相册列表"的照片 */
- (void)getAblumListWithImagesType:(ManagerAssetMediaType)assetMediaType completion:(void (^)(NSArray<YppAssetCollectionViewModel *> *assetCollectArray))completion
{
    NSMutableArray *ablums = [NSMutableArray array];
    if (NSClassFromString(@"PHFetchResult")) {
        PHAssetMediaType type = [self switchMediaType:assetMediaType];
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", type];

        // 系统
        PHFetchResult<PHAssetCollection *> *smartAlbumFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        [smartAlbumFetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *_Nonnull collection, NSUInteger idx, BOOL *_Nonnull stop) {

            // 获取一个相册（PHAssetCollection）
            @autoreleasepool {
                PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
                if (fetchResult.count != 0) {

                    YppAssetCollectionViewModel *assetCollectionViewModel = [[YppAssetCollectionViewModel alloc] initWithFetchResult:fetchResult title:collection.localizedTitle assetMediaType:type];

                    if ([self isCameraRollAlbum:collection.localizedTitle]) {
                        [ablums insertObject:assetCollectionViewModel atIndex:0];
                    }
                    else {
                        [ablums addObject:assetCollectionViewModel];
                    }

                }

            }

        }];

        // 用户自定义相册
        PHFetchResult<PHAssetCollection *> *userFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        [userFetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *_Nonnull collection, NSUInteger idx, BOOL *_Nonnull stop) {
            @autoreleasepool {
                PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
                if (fetchResult.count != 0) {
                    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];

                    YppAssetCollectionViewModel *assetCollectionViewModel = [[YppAssetCollectionViewModel alloc] initWithFetchResult:fetchResult title:collection.localizedTitle assetMediaType:type];
                    [ablums addObject:assetCollectionViewModel];
                }

            }

        }];

    }

    if (completion && ablums.count)(completion(ablums));
}

#pragma mark - 获取单张图片
/* 获取单张 缩略图 照片 */
- (PHImageRequestID)getThumbPhotoWithAsset:(PHAsset *)asset completion:(YppImageManagerReturnBlcok)completion
{
    return [self getPhotoWithAsset:asset photoWidth:150 completion:completion];
}

/* 获取 屏幕大小 的宽度 */
- (PHImageRequestID)getScreenWithPhotoWithAsset:(PHAsset *)asset completion:(YppImageManagerReturnBlcok)completion
{
    return [self getPhotoWithAsset:asset photoWidth:SCREEN_WIDTH*2.0 completion:completion];
}

/* 获取原图 */
- (void)getOriginalPhotoWithAsset:(PHAsset *)asset completion:(YppImageManagerReturnBlcok)completion
{
    [self getPhotoWithAsset:asset photoWidth:0 completion:completion];
}

//photoWidth = 0: 获取原图
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(YppImageManagerReturnBlcok)completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;

    if (!asset.pixelHeight || !asset.pixelWidth) return 0;
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGSize imageSize = CGSizeMake(photoWidth, photoWidth/aspectRatio);
    
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset
                                                                                 targetSize:photoWidth?imageSize:PHImageManagerMaximumSize
                                                                                contentMode:photoWidth?PHImageContentModeAspectFill:PHImageContentModeAspectFit
                                                                                    options:option
                                                                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                                  
        if (info[PHImageErrorKey])
        {
            NSLog(@"error: %@", info[PHImageErrorKey]);
            if (completion) completion(result, asset, info[PHImageErrorKey], [info[PHImageResultIsDegradedKey] boolValue], [info[PHImageResultIsInCloudKey] boolValue]);
        }

        BOOL downloadFinished = (![info[PHImageCancelledKey] boolValue] && !info[PHImageErrorKey]);
        if (downloadFinished && result) {
            if (completion) completion(result, asset, info[PHImageErrorKey], [info[PHImageResultIsDegradedKey] boolValue], [info[PHImageResultIsInCloudKey] boolValue]);
        }
                                                                                  
        // 从iCloud下载图片
        // TODO: 判断是否需要处理iCloud
        if ( [info[PHImageResultIsInCloudKey] boolValue] && !result) {

            // 如果是 iCloud 先不处理
            if (completion) completion(result, asset, info[PHImageErrorKey], [info[PHImageResultIsDegradedKey] boolValue], [info[PHImageResultIsInCloudKey] boolValue]);
            return;

            PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
            option.networkAccessAllowed = YES;
            option.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                              options:option
                                                        resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

                                                            UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                                                            if (photoWidth) {
                                                                resultImage = [self scaleImage:resultImage toSize:imageSize];
                                                            }
                                                            if (resultImage) {
                                                                if (completion) completion(resultImage, asset, info[PHImageErrorKey], [info[PHImageResultIsDegradedKey] boolValue], [info[PHImageResultIsInCloudKey] boolValue]);
                                                            }
                                                        }];
        }
    }];
    return imageRequestID;
}

/* 获取视频 */
- (PHImageRequestID)getPlayerItemForVideo:(PHAsset *)asset completion:(void (^)(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info, BOOL isInCloud))completion
{
    return [[PHImageManager defaultManager] requestPlayerItemForVideo:asset
                                                       options:nil
                                                 resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {

                                                     if (!info[PHImageErrorKey])
                                                     {
                                                        completion(playerItem, info, [info[PHImageResultIsInCloudKey] boolValue]);
                                                     }

                                                 }];
}

#pragma mark - 权限
/* 判断相机权限  */
- (BOOL)requestAlbumAuthorizationStatus:(void (^)(BOOL hasAuthorization))block
{
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if(authorStatus == AVAuthorizationStatusRestricted || authorStatus == AVAuthorizationStatusDenied)
    {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil
                                                                           message:@"请在iPhone的\"设置\"-\"隐私\"-\"照片\"选项中, 允许鱼泡泡访问您的照片"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [[UIViewController currentViewController] dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        [alertView addAction:cancelAction];
        [[UIViewController currentViewController] presentViewController:alertView animated:YES completion:nil];

        return NO;
    }
    else if (authorStatus == PHAuthorizationStatusNotDetermined) {

        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
        {
            if(block)
            {
                block(status == PHAuthorizationStatusAuthorized);
            }
        }];
        return NO;
    }

    return YES;

}

- (BOOL)requestCameraStatus:(void (^)(BOOL hasAuthorization))block
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil
                                                                           message:@"检测不到相机设备"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertView addAction:cancelAction];
        [[UIViewController currentViewController] presentViewController:alertView animated:YES completion:nil];

        return NO;
    }
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil
                                                                           message:@"请在iPhone的\"设置\"-\"隐私\"-\"相机\"选项中, 允许鱼泡泡访问您的相机"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertView addAction:cancelAction];
        [[UIViewController currentViewController] presentViewController:alertView animated:YES completion:nil];
        return NO;
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(block)
            {
                block(authStatus == AVAuthorizationStatusNotDetermined);
            }
        }];
        return NO;
    }

    return YES;
}

#pragma mark - Private
/* 转换类型 */
- (PHAssetMediaType)switchMediaType:(ManagerAssetMediaType)assetMediaType
{
    switch (assetMediaType) {
        case ManagerAssetMediaTypeUnknown:
            return PHAssetMediaTypeUnknown;
            break;
        case ManagerAssetMediaTypeImage:
            return PHAssetMediaTypeImage;
            break;
        case ManagerAssetMediaTypeVideo:
            return PHAssetMediaTypeVideo;
            break;
        case ManagerAssetMediaTypeAudio:
            return PHAssetMediaTypeAudio;
            break;
    }
}

/* 判断是否是全部相册 */
- (BOOL)isCameraRollAlbum:(NSString *)albumName
{
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
}

/* iCloud 图片修正到规定的size */
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

@end
