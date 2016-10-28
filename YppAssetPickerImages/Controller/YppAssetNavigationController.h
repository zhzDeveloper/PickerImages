//
//  ZAssetNavigationController.h
//  Demo-Photos
//
//  Created by zhz on 7/6/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>

typedef NS_ENUM(NSUInteger, YAssetPickerType) {
	YAssetPickerType_MultiChoose = 0,
	YAssetPickerType_SingleImageChoose,
	YAssetPickerType_SingleImageCropChoose
};

typedef NS_ENUM(NSInteger, YAssetPickerCropScale) {
    YAssetPickerCropScaleOriginal,
    YAssetPickerCropScaleSquare,
    YAssetPickerCropScale3x2,
    YAssetPickerCropScale5x3,
    YAssetPickerCropScale4x3,
    YAssetPickerCropScale5x4,
    YAssetPickerCropScale7x5,
    YAssetPickerCropScale16x9,
    YAssetPickerCropScaleGodAptitude,
};

@protocol YppAssetPickerControllerDelegate;
@interface YppAssetNavigationController : UINavigationController

@property (nonatomic, weak) id <YppAssetPickerControllerDelegate> pickerDelegate;

@property (nonatomic, strong) NSString *confirmString;

@property (nonatomic, assign) NSUInteger lineCount;
@property (nonatomic, assign) NSUInteger selectedMaxCount;
@property (nonatomic, assign) YAssetPickerType assetPickerType;

@property (nonatomic, assign) BOOL needEditToSquare;
@property (nonatomic, assign) BOOL isCreateFeed;        // 动态
@property (nonatomic, assign) BOOL isApplyAptitude;     // 资质
@property (nonatomic, assign) BOOL isOnlyShowVideo;     // 小视频

@property (nonatomic, assign) YAssetPickerCropScale cropScale;

@end

@protocol YppAssetPickerControllerDelegate <NSObject>

@optional

- (void)assetPickerController:(YppAssetNavigationController *)picker didFinishPickingAssets:(NSArray<UIImage *> *)assets;

- (void)assetPickerController:(YppAssetNavigationController *)picker didSelectVideoAsset:(NSString *)filtPath;

- (void)assetPickerController:(YppAssetNavigationController *)picker didFinishCrop:(UIImage *)image;

@end
