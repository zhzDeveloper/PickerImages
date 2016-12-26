//
//  ViewController.m
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppAssetPickerViewController.h"
#import <Photos/Photos.h>
#import "YppAssetCollectionViewCell.h"
#import "YppAssetViewModel.h"
#import "YppAssetPreviewViewController.h"
#import "YppAssetCollectionViewModel.h"
#import "YppAssetNavigationController.h"
#import "YppCustomBottomView.h"
#import "TOCropViewController.h"
#import "PhotoPreviewViewController.h"
#import "YppImageCropViewController.h"
#import "YppPreviewAfterCropViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "UIViewController+CurrentViewController.h"
#import "YppAssetVideoPreviewViewController.h"
#import "UIImage+Compress.h"
#import "YppIMService.h"
#import "YppImageManager.h"
#import <Masonry.h>
#import "ZPickerUtility.h"
#import "ZPickerHeader.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

static NSString *cellID = @"cellid";
static CGFloat const minimumInteritemSpacing = 5.0f;

@interface YppAssetPickerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TOCropViewControllerDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) YppAssetCollectionViewModel *assetCollectionViewModel;
@property(nonatomic, strong) NSMutableArray<YppAssetViewModel *> *dataSource;
@property(nonatomic, strong) NSMutableArray<YppAssetViewModel *> *selectedDataSource;

@property(nonatomic, strong) YppCustomBottomView *customBottomView;
@property(nonatomic, weak) YppAssetNavigationController *assetNavigationController;

@end

@implementation YppAssetPickerViewController

- (instancetype)initWithZAssetCollectionViewModel:(YppAssetCollectionViewModel *)assetCollectionViewModel {
    if (self = [super init]) {
        _dataSource = assetCollectionViewModel.assetsArray;
        _assetCollectionViewModel = assetCollectionViewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.assetNavigationController = (YppAssetNavigationController *) self.navigationController;


    // 相册权限
    BOOL flag = [[YppImageManager manager] requestAlbumAuthorizationStatus:^(BOOL hasAuthorization) {
        if (hasAuthorization) {
            if (!self.dataSource.count) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self getAllAlbums];
                });
            }
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];

    [self setupUI];

    self.selectedDataSource = [NSMutableArray array];
    if (!self.dataSource.count && flag) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self getAllAlbums];
        });
    }
}

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    [self.dataSource enumerateObjectsUsingBlock:^(YppAssetViewModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.thumbImage = nil;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.assetNavigationController.assetPickerType == YAssetPickerType_MultiChoose) {
        [self.customBottomView updateSelectedImageCount:self.selectedDataSource.count];
    }
}

#pragma mark - Private

- (void)setupUI {

    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.customBottomView];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(self.assetNavigationController.assetPickerType == YAssetPickerType_MultiChoose ? -50 : 0);
    }];
    [self.customBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
        make.height.mas_equalTo(50);
    }];
    self.customBottomView.hidden = self.assetNavigationController.assetPickerType != YAssetPickerType_MultiChoose;

    self.title = self.assetCollectionViewModel.albumsTitle ?: @"所有照片";
    if (self.assetNavigationController.isOnlyShowVideo) {
        self.title = @"所有视频";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    }
    else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
}

- (void)getAllAlbums {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [ZPickerUtility showHudWithTextInView:self.view animate:YES text:@""];
    });

    //  获取"相机胶卷"的所有照片/视频
    WS(weakSelf);
    [[YppImageManager manager] getCameraRollWithImagesType:self.assetNavigationController.isOnlyShowVideo ? ManagerAssetMediaTypeVideo : ManagerAssetMediaTypeImage completion:^(YppAssetCollectionViewModel *assetCollectionViewModel) {
        weakSelf.dataSource = assetCollectionViewModel.assetsArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [weakSelf.collectionView reloadData];
        });
    }];
}

- (void)checkIMServiceMediaBizType {
    [self showCamera];
}

- (void)showCamera {
    if (![UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController setDelegate:self];
    [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];

    if (self.assetNavigationController.isOnlyShowVideo) {

        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePickerController.sourceType];
        NSMutableArray *mediaTypes = [NSMutableArray arrayWithCapacity:availableMediaTypes.count];

        for (NSInteger i = 0; i < availableMediaTypes.count; i++) {
            if ([availableMediaTypes[i] isEqualToString:@"public.movie"]) {
                [mediaTypes addObject:availableMediaTypes[i]];
            }
        }
        imagePickerController.mediaTypes = mediaTypes;
        imagePickerController.videoMaximumDuration = 15.0f;
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
    }

    [self presentViewController:imagePickerController animated:YES completion:nil];

}

/* 完成 发送动态 */
- (void)finishPickingAssetsFromPreview:(NSMutableArray *)selectedAssert {
    BOOL single = self.assetNavigationController.assetPickerType == YAssetPickerType_SingleImageChoose;
    if (single) {
        YppAssetViewModel *lastAsset = [selectedAssert lastObject];
        if (self.assetNavigationController.isCreateFeed) {
            //ypp发动态定制
            WS(weakSelf);

            [[YppImageManager manager] getOriginalPhotoWithAsset:lastAsset.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {
                if (!isDegraded && result) {
                    CreateFeedViewController *createFeed = [[CreateFeedViewController alloc] initWithImage:result];
                    [createFeed setDone:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kYPP_NOTIFY_DONGTAI_CREATED object:nil];
                    }];
                    [weakSelf.navigationController pushViewController:createFeed animated:YES];

                }

            }];

        }
        else {
            self.selectedDataSource = [@[lastAsset] mutableCopy];
            [self finishPickingAssets];
        }
    }
    else {
        [self finishPickingAssets];
    }
}

- (void)finishPickingAssets {
    if ([self.selectedDataSource count] == 0) {
        [YppLifeUtility showSimpleAlertViewWithMessage:NSLocalizedString(@"You have not chosen images", nil)];
        return;
    }

    WS(weakSelf);
    if (self.assetNavigationController.assetPickerType != YAssetPickerType_MultiChoose) {
        YppAssetViewModel *_Nonnull obj = self.selectedDataSource.lastObject;

        [[YppImageManager manager] getOriginalPhotoWithAsset:obj.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {

            if (!isDegraded) {
                if ([self.assetNavigationController.pickerDelegate respondsToSelector:@selector(assetPickerController:didFinishPickingAssets:)]) {
                    [self.assetNavigationController.pickerDelegate assetPickerController:weakSelf.assetNavigationController didFinishPickingAssets:@[result]];
                }
                [weakSelf dismissViewControllerAnimated:YES completion:NULL];

            }
        }];
    }
    else {
        // 原始图片处理
        BOOL isOrginImage = self.customBottomView.isAllSelectOrign;
        __block NSInteger currentSend = self.selectedDataSource.count;
        NSString *HUDText = [NSString stringWithFormat:@"%zd/%zd", currentSend, self.selectedDataSource.count];
        [YppLifeUtility showHudWithTextInView:self.view animate:YES text:HUDText];

        [self.selectedDataSource enumerateObjectsUsingBlock:^(YppAssetViewModel *obj, NSUInteger idx, BOOL *stop) {

            [[YppImageManager manager] getPhotoWithAsset:obj.asset photoWidth:isOrginImage ? 0 : SCREEN_WIDTH * 2.0 completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {
                if (isInCloud) {
                    [YppLifeUtility showTextHudInView:self.view animate:YES text:@"在iCloud中, 请先下载" duration:kYppShowHudDuration];
                }
                else if (!isDegraded && result) {
                    if ([self.assetNavigationController.pickerDelegate respondsToSelector:@selector(assetPickerController:didFinishPickingAssets:)]) {
                        [self.assetNavigationController.pickerDelegate assetPickerController:weakSelf.assetNavigationController didFinishPickingAssets:@[result]];
                    }

                    currentSend--;
                    NSString *HUDText = [NSString stringWithFormat:@"%zd/%zd", currentSend, self.selectedDataSource.count];
                    [YppLifeUtility showHudWithTextInView:self.view animate:YES text:HUDText];
                    if (!currentSend) {
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }
                }

            }];

        }];

    }

}

- (void)upLoadeAsset:(PHAsset *)asset thumbImage:(UIImage *)thumbImage {
    __weak YppAssetNavigationController *assetNavigationController = (YppAssetNavigationController *) self.navigationController;
    if (assetNavigationController.isOnlyShowVideo && (asset.mediaType == PHAssetMediaTypeVideo)) {

        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        options.version = PHVideoRequestOptionsVersionOriginal;

        [[PHImageManager defaultManager] requestExportSessionForVideo:asset
                                                              options:options
                                                         exportPreset:AVAssetExportPresetPassthrough
                                                        resultHandler:^(AVAssetExportSession *_Nullable exportSession, NSDictionary *_Nullable info) {

                                                            NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                                                            NSString *fileName = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"mov"];
                                                            NSString *tempFile = [folderPath stringByAppendingPathComponent:fileName];
                                                            if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile] && [[NSFileManager defaultManager] isDeletableFileAtPath:tempFile] ) {
                                                                [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
                                                            }

                                                            NSURL *tempFileUrl = [NSURL fileURLWithPath:tempFile];

                                                            [exportSession setOutputFileType:AVFileTypeMPEG4];
                                                            [exportSession setOutputURL:tempFileUrl];

                                                            [exportSession exportAsynchronouslyWithCompletionHandler:^{

                                                                dispatch_async(dispatch_get_main_queue(), ^{

                                                                    if (asset.duration >= 16.0f) {
                                                                        [YppLifeUtility showTextHudInView:[UIApplication sharedApplication].keyWindow animate:YES text:@"拍摄视频不能大于视频15秒" duration:1.0f];
                                                                        return;
                                                                    }

                                                                    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                                                                        if (exportSession.status == AVAssetExportSessionStatusFailed) {
                                                                            [YppLifeUtility showTextHudInView:[UIApplication sharedApplication].keyWindow animate:YES text:@"导出视频失败" duration:kYppShowHudDuration];
                                                                        } else if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                                                                            if ([assetNavigationController.pickerDelegate respondsToSelector:@selector(assetPickerController:didSelectVideoAsset:)]) {
                                                                                [assetNavigationController.pickerDelegate assetPickerController:assetNavigationController didSelectVideoAsset:tempFile];
                                                                            }
                                                                        }

                                                                    }];

                                                                });

                                                            }];

                                                        }];


    } else {

    }

}

- (void)popViewController:(UIBarButtonItem *)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.selectedDataSource.count) {
            [self.selectedDataSource enumerateObjectsUsingBlock:^(YppAssetViewModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                obj.isSelected = NO;
            }];
        }
    });

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismiss:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)jumpToTOCropViewControllerForCropImage:(UIImage *)rawImage {
    if (!rawImage) {
        NSAssert(rawImage, @"图片不能为空");
        return;
    }

    TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:rawImage];
    [cropController setDelegate:self];
    [cropController setDefaultAspectRatio:(TOCropViewControllerAspectRatio) self.assetNavigationController.cropScale];
    [self presentViewController:cropController
                       animated:YES
                     completion:NULL];

}

- (void)jumpToSLImageCropViewControllerForConstantImage:(UIImage *)rawImage frame:(CGRect)frame isFromCamera:(BOOL)isFromCamera {
    if (!rawImage) {
        NSAssert(rawImage, @"图片不能为空");
        return;
    }

    if (CGRectEqualToRect(frame, CGRectZero)) {
        return;
    }

    YppImageCropViewController *imageCrop = [[YppImageCropViewController alloc] initWithImage:rawImage cropFrame:frame limitScaleRatio:3.0];
    imageCrop.confimString = @"确定";

    __weak typeof(self.assetNavigationController) assetNavigationController = self.assetNavigationController;
    [imageCrop setConfirmBlock:^(UIImage *cropImage) {
        if (isFromCamera) {
            if (assetNavigationController.isApplyAptitude) {
                if ([assetNavigationController.pickerDelegate respondsToSelector:@selector(assetPickerController:didFinishPickingAssets:)]) {
                    [assetNavigationController.pickerDelegate assetPickerController:assetNavigationController didFinishPickingAssets:@[cropImage]];
                }
                [assetNavigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
            }
            else {
                YppPreviewAfterCropViewController *previewAfterCropViewController = [[YppPreviewAfterCropViewController alloc] initWithImageAfterCrop:cropImage];
                [assetNavigationController pushViewController:previewAfterCropViewController animated:YES];
            }
        }
        else {
            if ([assetNavigationController.pickerDelegate respondsToSelector:@selector(assetPickerController:didFinishPickingAssets:)]) {
                [assetNavigationController.pickerDelegate assetPickerController:assetNavigationController didFinishPickingAssets:@[cropImage]];
            }
            [assetNavigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        }

    }];
    [self.navigationController pushViewController:imageCrop animated:YES];
}

- (void)jumpToVideoPreviewViewController:(CGFloat)limitDuration model:(YppAssetViewModel *)model playerItem:(AVPlayerItem *)playerItem {
    if (model.asset.duration >= limitDuration) {
        [YppLifeUtility showTextHudInView:self.view animate:YES text:@"请选择小于15秒的视频" duration:kYppShowHudDuration];
    }
    else {
        YppAssetVideoPreviewViewController *assetVideoPreviewViewController = [[YppAssetVideoPreviewViewController alloc] initWithPlayerItem:playerItem];
        [assetVideoPreviewViewController setDone:^() {
            [self upLoadeAsset:model.asset thumbImage:model.thumbImage];
        }];
        [self presentViewController:assetVideoPreviewViewController animated:YES completion:nil];
    }
}

- (void)jumpToImagePreviewViewController:(NSIndexPath *)index isShowAllAssets:(BOOL)yesOrNo {
    NSMutableArray *dataSource = yesOrNo ? [self.dataSource mutableCopy] : [self.selectedDataSource mutableCopy];

    YppAssetPreviewViewController *asetPreviewViewController = [[YppAssetPreviewViewController alloc] initWithDataSource:dataSource
                                                                                                      selectedDataSource:self.selectedDataSource
                                                                                                               indexPath:index];
    asetPreviewViewController.isOrginImage = self.customBottomView.isAllSelectOrign;
    [asetPreviewViewController setBackRefreshBlock:^(NSMutableArray *selectedArray, BOOL isShowOrginImage) {
        self.selectedDataSource = selectedArray;
        self.customBottomView.isAllSelectOrign = isShowOrginImage;
        [self.collectionView reloadData];
    }];
    [asetPreviewViewController setConfirmBlock:^(NSMutableArray *selectedArray) {
        [self finishPickingAssetsFromPreview:selectedArray];
    }];
    [self.navigationController pushViewController:asetPreviewViewController animated:YES];

}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.assetNavigationController.assetPickerType != YAssetPickerType_MultiChoose) {
        return self.dataSource.count + 1;
    }
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YppAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    YppAssetViewModel *assetViewModel = self.dataSource[indexPath.row];
    if (self.assetNavigationController.assetPickerType != YAssetPickerType_MultiChoose) {
        assetViewModel = self.dataSource[indexPath.row - 1];
    }
    [cell configWithAsset:assetViewModel assetPickerType:self.assetNavigationController.assetPickerType indexPath:indexPath];

    WS(weakSelf);
    // 拍照
    [cell setShowCameraBlock:^() {

        BOOL flag = [[YppImageManager manager] requestCameraStatus:^(BOOL hasAuthorization) {
            if (hasAuthorization) {
                [weakSelf checkIMServiceMediaBizType];
            }
        }];

        if (flag) {
            [weakSelf checkIMServiceMediaBizType];
        }
    }];

    // 控制选择图片的数量
    __weak typeof(self.assetNavigationController) assetNavigationController = self.assetNavigationController;

    [cell setSelectedRefreshBlock:^(UIButton *selectedButton) {

        [[YppImageManager manager] getOriginalPhotoWithAsset:assetViewModel.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {

            if (isInCloud) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [YppLifeUtility showDetailTextHudInView:weakSelf.view animate:YES text:@"该图片尚未从iCloud下载, 请在系统给相册中下载到本地后重新尝试" duration:kYppShowHudDuration];
                });
            }
            else {
                if (!assetViewModel.isSelected) {
                    if (assetNavigationController.selectedMaxCount &&
                            weakSelf.selectedDataSource.count >= assetNavigationController.selectedMaxCount) {
                        NSString *text = [NSString stringWithFormat:@"最多选择%zd张图片", assetNavigationController.selectedMaxCount];
                        [YppLifeUtility showTextHudInView:weakSelf.view animate:YES text:text duration:2.0];
                        return;
                    }

                    selectedButton.selected = !selectedButton.isSelected;
                    assetViewModel.isSelected = selectedButton.isSelected;
                    if (![weakSelf.selectedDataSource containsObject:assetViewModel]) {
                        [weakSelf.selectedDataSource addObject:assetViewModel];
                    }
                }
                else {
                    selectedButton.selected = !selectedButton.isSelected;
                    assetViewModel.isSelected = selectedButton.isSelected;
                    if ([weakSelf.selectedDataSource containsObject:assetViewModel]) {
                        [weakSelf.selectedDataSource removeObject:assetViewModel];
                    }
                }

                [weakSelf.customBottomView updateSelectedImageCount:weakSelf.selectedDataSource.count];
            }

        }];


    }];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WS(weakSelf);
    NSIndexPath *index = [NSIndexPath indexPathForRow:(self.assetNavigationController.assetPickerType != YAssetPickerType_MultiChoose) ? indexPath.row - 1 : indexPath.row inSection:indexPath.section];

    YppAssetViewModel *model = self.dataSource[index.row];
    if (self.assetNavigationController.isOnlyShowVideo && model.videoTimeString.length) {

        [[YppImageManager manager] getPlayerItemForVideo:model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info, BOOL isInCloud) {
            dispatch_async(dispatch_get_main_queue(), ^{

                if (isInCloud) {
                    [YppLifeUtility showDetailTextHudInView:self.view animate:YES text:@"该视频尚未从iCloud下载, 请在系统给相册中下载到本地后重新尝试" duration:kYppShowHudDuration];
                }
                else if (playerItem) {
                    [self jumpToVideoPreviewViewController:16.0f model:model playerItem:playerItem];
                }
            });

        }];

    }
    else {

        [[YppImageManager manager] getOriginalPhotoWithAsset:model.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {

            if (isInCloud) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [YppLifeUtility showDetailTextHudInView:self.view animate:YES text:@"该图片尚未从iCloud下载, 请在系统给相册中下载到本地后重新尝试" duration:kYppShowHudDuration];
                });
            }
            else if (self.assetNavigationController.isApplyAptitude || self.assetNavigationController.needEditToSquare) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.assetNavigationController.isApplyAptitude) {
                        CGFloat cropY = (SCREEN_HEIGHT - 197 - 50) / 2.0;
                        CGFloat cropH = SCREEN_WIDTH / 1.53;
                        CGRect frame = CGRectMake(0, cropY, MainWidth, cropH);
                        [weakSelf jumpToSLImageCropViewControllerForConstantImage:result
                                                                            frame:frame
                                                                     isFromCamera:NO];

                    }
                    else if (self.assetNavigationController.needEditToSquare) {
                        [self jumpToTOCropViewControllerForCropImage:result];
                    }

                });
            }
            else {
                [self jumpToImagePreviewViewController:index isShowAllAssets:YES];

            }
        }];

    }

}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __weak typeof(self) weakSelf = self;

    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    [picker dismissViewControllerAnimated:NO completion:^{
        
        if ([mediaType isEqualToString:@"public.image"]) {
            UIImage *rawImage = info[UIImagePickerControllerOriginalImage];
            if (weakSelf.assetNavigationController.needEditToSquare) {
                [weakSelf jumpToTOCropViewControllerForCropImage:rawImage];
            }
            else {
                if (weakSelf.assetNavigationController.isCreateFeed || weakSelf.assetNavigationController.isApplyAptitude) {
                    CGFloat cropY = (SCREEN_HEIGHT - (weakSelf.assetNavigationController.isApplyAptitude ? 197 : MainWidth) - 50) / 2.0;
                    CGFloat cropH = SCREEN_WIDTH / 1.53;
                    CGRect frame = CGRectMake(0, cropY, MainWidth, weakSelf.assetNavigationController.isApplyAptitude ? cropH : MainWidth);
                    [weakSelf jumpToSLImageCropViewControllerForConstantImage:rawImage
                                                                        frame:frame
                                                                 isFromCamera:YES];

                }
                else {
                    YppPreviewAfterCropViewController *previewAfterCropViewController = [[YppPreviewAfterCropViewController alloc] initWithImageAfterCrop:rawImage];
                    [weakSelf.navigationController pushViewController:previewAfterCropViewController animated:YES];
                }
            }

        }
        else if ([mediaType isEqualToString:@"public.movie"]) {

            WS(weakSelf);
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[info objectForKey:UIImagePickerControllerMediaURL]];

            }                                 completionHandler:^(BOOL success, NSError *_Nullable error) {

                if (success) {

                    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions];
                    if ([fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo] > 0) {
                        PHAsset *asset = [fetchResult firstObject];
                        [weakSelf upLoadeAsset:asset thumbImage:nil];
                    }

                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [self getAllAlbums];
                    });
                }
                else {
                    [YppLifeUtility showTextHudInView:self.view animate:YES text:@"拍照失败, 请重新拍摄" duration:kYppShowHudDuration];
                }

            }];

        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TOCropViewController Delegate

- (void)cropViewController:(TOCropViewController *)cropViewController
            didCropToImage:(UIImage *)image
                  withRect:(CGRect)cropRect
                     angle:(NSInteger)angle {
    [cropViewController dismissViewControllerAnimated:YES
                                           completion:^{
                                               [self.navigationController dismissViewControllerAnimated:NO completion:^() {
                                                   if (self.assetNavigationController.pickerDelegate != nil && [self.assetNavigationController.pickerDelegate respondsToSelector:@selector(assetPickerController:didFinishCrop:)]) {
                                                       [self.assetNavigationController.pickerDelegate assetPickerController:self.assetNavigationController didFinishCrop:image];
                                                   }
                                               }];
                                           }];

}

#pragma mark - getter && setter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        YppAssetNavigationController *assetNavigationController = (YppAssetNavigationController *) self.navigationController;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        NSUInteger number = assetNavigationController.lineCount ?: 4;
        CGFloat itemW = (SCREEN_WIDTH - minimumInteritemSpacing * (1 + number)) / number;
        layout.itemSize = CGSizeMake(itemW, itemW);
        layout.minimumInteritemSpacing = minimumInteritemSpacing;
        layout.minimumLineSpacing = minimumInteritemSpacing;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

        [_collectionView registerClass:[YppAssetCollectionViewCell class] forCellWithReuseIdentifier:cellID];

    }
    return _collectionView;
}

- (YppCustomBottomView *)customBottomView {
    if (!_customBottomView) {
        _customBottomView = [[YppCustomBottomView alloc] initWithFrame:CGRectZero isShowPreButton:YES];

        WS(weakSelf);
        [_customBottomView setPreviewImagesBlock:^() {
            [weakSelf jumpToImagePreviewViewController:[NSIndexPath indexPathForRow:0 inSection:0] isShowAllAssets:NO];
        }];

        [_customBottomView setConfirmSelectedImagesBlock:^() {
            [weakSelf finishPickingAssetsFromPreview:[weakSelf.selectedDataSource mutableCopy]];
        }];

    }
    return _customBottomView;
}

@end
