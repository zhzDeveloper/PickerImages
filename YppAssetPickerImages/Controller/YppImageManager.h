//
//  YppImageManager.h
//  YppLife
//
//  Created by zhz on 9/26/16.
//  Copyright © 2016 WYWK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, ManagerAssetMediaType) {
    ManagerAssetMediaTypeUnknown = 0,
    ManagerAssetMediaTypeImage   = 1,
    ManagerAssetMediaTypeVideo   = 2,
    ManagerAssetMediaTypeAudio   = 3,
};

@class YppAssetCollectionViewModel;
@class YppAssetViewModel;

typedef void(^YppImageManagerReturnBlcok)(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud);

@interface YppImageManager : NSObject

+ (instancetype)manager;

/* 获取"相机胶卷"的照片 */
- (void)getCameraRollWithImagesType:(ManagerAssetMediaType)assetMediaType completion:(void (^)(YppAssetCollectionViewModel *assetCollectionViewModel))completion;

/* 获取 相册列表 */
- (void)getAblumListWithImagesType:(ManagerAssetMediaType)assetMediaType completion:(void (^)(NSArray<YppAssetCollectionViewModel *> *assetCollectArray))completion;

/* 获取某个相册中的所有照片/视频 */
- (void)getAssetsFromFetchResult:(PHFetchResult *)result assetMediaType:(ManagerAssetMediaType)assetMediaType completion:(void (^)(NSArray<YppAssetViewModel *> *assetModels))completion;

/* 获取单张 缩略图 照片 */
- (PHImageRequestID)getThumbPhotoWithAsset:(PHAsset *)asset completion:(YppImageManagerReturnBlcok)completion;

/* 获取原图 */
- (void)getOriginalPhotoWithAsset:(PHAsset *)asset completion:(YppImageManagerReturnBlcok)completion;

/* 获取 屏幕大小的宽度的图片 */
- (PHImageRequestID)getScreenWithPhotoWithAsset:(PHAsset *)asset completion:(YppImageManagerReturnBlcok)completion;

- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(YppImageManagerReturnBlcok)completion;

/* 获取视频 */
- (PHImageRequestID)getPlayerItemForVideo:(PHAsset *)asset completion:(void (^)(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info, BOOL isInCloud))completion;

/* 判断相机权限  */
- (BOOL)requestAlbumAuthorizationStatus:(void (^)(BOOL hasAuthorization))block;
- (BOOL)requestCameraStatus:(void (^)(BOOL hasAuthorization))block;

@end
