//
//  ZAssetPreviewViewController.m
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppAssetPreviewViewController.h"
#import "YppAssetPreViewCollectionCell.h"
#import "YppAssetViewModel.h"
#import "YppCustomTopView.h"
#import "YppCustomBottomView.h"
#import "YppAssetNavigationController.h"
#import "YppImageCropViewController.h"
#import "YppPreviewAfterCropViewController.h"
#import "CreateFeedViewController.h"
#import "YppImageManager.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
static NSString *const cellID = @"cellPre";

@interface YppAssetPreviewViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<YppAssetViewModel *>  *dataSource;
@property (nonatomic, strong) NSMutableArray<YppAssetViewModel *>  *selectedDataSource;
@property (nonatomic, strong) NSIndexPath *offsetIndexPath;

@property (nonatomic, strong) YppCustomTopView     *customTopView;
@property (nonatomic, strong) YppCustomBottomView  *customBottomView;

//有空封装下
@property (nonatomic, strong) UIView            *bottomView;
@property (nonatomic, strong) UIButton          *sendBtn;
@property (nonatomic, strong) UIButton          *cropButton;
@property (nonatomic, strong) UILabel           *cropTipLabel;

@property (nonatomic, weak) YppAssetNavigationController            *assetNavigationController;

@property (nonatomic) BOOL isFirstTimeViewDidLayoutSubviews;
@end

@implementation YppAssetPreviewViewController

- (instancetype)initWithDataSource:(NSMutableArray *)dataSource  selectedDataSource:(NSMutableArray *)selectedDataSource indexPath:(NSIndexPath *)indexPath {
    if (self = [super init]) {
        _dataSource = dataSource;
        _selectedDataSource = selectedDataSource;
        _offsetIndexPath = indexPath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.assetNavigationController = (YppAssetNavigationController *)self.navigationController;
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self setupUI];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    self.isFirstTimeViewDidLayoutSubviews = YES;

    self.title = @"预览";
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    if (self.assetNavigationController.assetPickerType != YAssetPickerType_SingleImageChoose) {
        self.navigationController.navigationBar.hidden = YES;
    }
    
    //发动态界面点击已选择图片进入
    if (self.comeFromUpdateFeedImage)
    {
        self.navigationItem.leftBarButtonItem = [YppLifeUtility getLeftUIBarBtnItemWithTarget:self withSEL:@selector(finishPickingAssetsForPreview:)];
        self.navigationItem.rightBarButtonItem = [YppLifeUtility getTextItemWithTarget:NSLocalizedString(@"Delete", nil) forTarget:self withSEL:@selector(deleteChooseImage)];
        if ([self.bottomView superview])
        {
            [self.bottomView removeFromSuperview];
        }
        self.collectionView.scrollEnabled = NO;
    }
    else
    {
        self.title = NSLocalizedString(@"Preview", nil);
        self.navigationItem.leftBarButtonItem = [YppLifeUtility getLeftUIBarBtnItemWithTarget:self withSEL:@selector(popupMyself)];
        if (self.assetNavigationController.assetPickerType == YAssetPickerType_SingleImageChoose) {
            [self addButtomBar];
        }
    }

    YppAssetViewModel *assetViewModel = self.dataSource[self.offsetIndexPath.row];
    [[PHImageManager defaultManager] requestImageDataForAsset:assetViewModel.asset
                                                      options:nil
                                                resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                    
                                                    assetViewModel.size = imageData.length;
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.customBottomView updateImageSize:self.customBottomView.isAllSelectOrign?assetViewModel.size:0];
                                                        
                                                    });
                                                }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.assetNavigationController.assetPickerType != YAssetPickerType_SingleImageChoose) {
        self.navigationController.navigationBar.hidden = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.isFirstTimeViewDidLayoutSubviews) {
        self.isFirstTimeViewDidLayoutSubviews = NO;
        if (self.offsetIndexPath.row) {
            //animated : YES 不会自动调用scrollViewDidScroll
            [self.collectionView scrollToItemAtIndexPath:self.offsetIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        else {
            [self scrollViewDidScroll:self.collectionView];
        }
    }
}
- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (BOOL)prefersStatusBarHidden {
    self.assetNavigationController = (YppAssetNavigationController *)self.navigationController;
    if (self.assetNavigationController.assetPickerType != YAssetPickerType_SingleImageChoose) {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.dataSource enumerateObjectsUsingBlock:^(YppAssetViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.thumbImage = nil;
    }];
}

#pragma mark - Private 
- (void)popupMyself {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.customTopView];
    [self.view addSubview:self.customBottomView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
    
}

- (void)addButtomBar
{
    self.customBottomView.hidden = YES;
    self.customTopView.hidden = YES;
    
    int height = 50;
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor colorWithHexString:@"323232"];
    [self.view addSubview:_bottomView];
    [_bottomView addSubview:self.sendBtn];
    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
    
    //发动态, 需要裁剪
    if (self.assetNavigationController.isCreateFeed  || self.assetNavigationController.isApplyAptitude) {
        
        [_bottomView addSubview:self.cropButton];
        [self.cropButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomView);
            make.left.equalTo(_bottomView).offset(15);
        }];
        
        [_bottomView addSubview:self.cropTipLabel];
        [self.cropTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomView);
            make.left.equalTo(self.cropButton.mas_right).offset(11);
        }];
        
    }
}

- (void)finishPickingAssetsForPreview:(UIButton *)sendBtn
{
    [YppLifeUtility mobClickEvent:@"quedingzhaopian"];

    NSUInteger index = (NSUInteger) (self.collectionView.contentOffset.x / SCREEN_WIDTH);
    YppAssetViewModel *assetViewModel = self.dataSource[index];
    
    if (self.assetNavigationController.assetPickerType != YAssetPickerType_MultiChoose) {
        [[YppImageManager manager] getOriginalPhotoWithAsset:assetViewModel.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {

            if (isInCloud)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [YppLifeUtility showDetailTextHudInView:self.view animate:YES text:@"该图片尚未从iCloud下载, 请在系统给相册中下载到本地后重新尝试" duration:kYppShowHudDuration];
                    return;
                });
            }
            else {
                [self.selectedDataSource addObject:assetViewModel];
            }
        }];

    } else {
        if (![self.selectedDataSource containsObject:assetViewModel] && assetViewModel.isSelected) {
            [self.selectedDataSource addObject:assetViewModel];
        }
    }
    
    if (self.confirmBlock) {
        self.confirmBlock(self.selectedDataSource);
    }
    
}

- (void)cropButtonAction:(UIButton *)cropButton {
    // jump To crop vc
    YppAssetPreViewCollectionCell *cell = (YppAssetPreViewCollectionCell *)[[self.collectionView visibleCells] firstObject];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    YppAssetViewModel *assetViewModel = self.dataSource[indexPath.row];

    [[YppImageManager manager] getOriginalPhotoWithAsset:assetViewModel.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {

        if (isInCloud)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [YppLifeUtility showDetailTextHudInView:self.view animate:YES text:@"该图片尚未从iCloud下载, 请在系统给相册中下载到本地后重新尝试" duration:kYppShowHudDuration];
            });
        }
        else {
            YppImageCropViewController *imageCrop = [[YppImageCropViewController alloc] initWithImage:result cropFrame:CGRectMake(0, 100, MainWidth, self.assetNavigationController.isApplyAptitude?197:MainWidth) limitScaleRatio:3.0];
            [self.navigationController pushViewController:imageCrop animated:YES];

            [imageCrop setConfirmBlock:^(UIImage *cropImage) {
                YppPreviewAfterCropViewController *previewAfterCropViewController = [[YppPreviewAfterCropViewController alloc] initWithImageAfterCrop:cropImage];
                [self.navigationController pushViewController:previewAfterCropViewController animated:YES];

            }];
        }

    }];
    
}

- (void)deleteChooseImage {
    
    CreateFeedViewController *createFeed = [[CreateFeedViewController alloc] initWithImage:nil];
    [createFeed setDone:^
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:kYPP_NOTIFY_DONGTAI_CREATED object:nil];
     }];
    [self.navigationController pushViewController:createFeed animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YppAssetPreViewCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    YppAssetViewModel *assetViewModel = self.dataSource[indexPath.row];
    [cell configWithAsset:assetViewModel];
    
    __weak typeof(self) weakSelf = self;
    [cell setTapHiddenTopAndBottomViewBlock:^(){
        
        if (weakSelf.assetNavigationController.assetPickerType != YAssetPickerType_SingleImageChoose) {
            weakSelf.customTopView.hidden = !weakSelf.customTopView.isHidden;
            weakSelf.customBottomView.hidden = !weakSelf.customBottomView.isHidden;
        }
        
    }];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger row = (NSInteger)(scrollView.contentOffset.x * 1.0 / SCREEN_WIDTH + 0.5);
    YppAssetViewModel *assetViewModel = self.dataSource[row];
    self.customTopView.isSelected = assetViewModel.isSelected;
    [self.customBottomView updateImageSize:self.customBottomView.isAllSelectOrign?assetViewModel.size:0];
}

#pragma mark - getter && setter
- (UICollectionView *)collectionView
{
    if (!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.itemSize                 = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        layout.sectionInset             = UIEdgeInsetsZero;
        layout.minimumInteritemSpacing  = 0;
        layout.minimumLineSpacing       = 0;
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        _collectionView.pagingEnabled = YES;
        
        [_collectionView registerClass:[YppAssetPreViewCollectionCell class] forCellWithReuseIdentifier:cellID];
        
    }
    return _collectionView;
}

- (YppCustomTopView *)customTopView
{
	if (!_customTopView){
        _customTopView = [[YppCustomTopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        __weak typeof(self) weakSelf = self;
        [_customTopView setTopViewBackBlock:^{
            if (weakSelf.backRefreshBlock) {
                weakSelf.backRefreshBlock(weakSelf.selectedDataSource, weakSelf.customBottomView.isAllSelectOrign);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        
        //控制选择图片的数量
        __weak typeof(self.assetNavigationController) assetNavigationController = self.assetNavigationController;
        [_customTopView setTopViewSelectedBlock:^(UIButton *selectedButton) {
            YppAssetPreViewCollectionCell *cell = [[weakSelf.collectionView visibleCells] firstObject];
            NSIndexPath *indexPath = [weakSelf.collectionView indexPathForCell:cell];
            YppAssetViewModel *assetViewModel = weakSelf.dataSource[indexPath.row];

            [[YppImageManager  manager] getOriginalPhotoWithAsset:assetViewModel.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {

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
	}
	return _customTopView;
}

- (YppCustomBottomView *)customBottomView
{
	if (!_customBottomView){
        CGFloat viewY = SCREEN_HEIGHT - 50;
        _customBottomView = [[YppCustomBottomView alloc] initWithFrame:CGRectMake(0, viewY, SCREEN_WIDTH, 50) isShowPreButton:NO];
        
        WS(weakSelf);
        [_customBottomView setConfirmSelectedImagesBlock:^(){
            if ([weakSelf.selectedDataSource count] == 0)
            {
                [YppLifeUtility showSimpleAlertViewWithMessage:NSLocalizedString(@"You have not chosen images", nil)];
                return;
            }
            else {
                if (weakSelf.confirmBlock) {
                    weakSelf.confirmBlock(weakSelf.selectedDataSource);
                }
            }
            
        }];
        _customBottomView.isAllSelectOrign = self.isOrginImage;

        __weak YppCustomBottomView *weakBottom = _customBottomView;
        [_customBottomView setSelectedOrginImagesBlock:^(BOOL isShowOrgin)
        {
            YppAssetPreViewCollectionCell *cell = [[weakSelf.collectionView visibleCells] firstObject];
            NSIndexPath *indexPath = [weakSelf.collectionView indexPathForCell:cell];
            YppAssetViewModel *assetViewModel = weakSelf.dataSource[indexPath.row];

            if (isShowOrgin) {
                [weakBottom updateImageSize:assetViewModel.size];

                // 判断是否已选中
                if (!assetViewModel.isSelected && ![self.selectedDataSource containsObject:assetViewModel]) {

                    [[YppImageManager manager] getOriginalPhotoWithAsset:assetViewModel.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {
                        if (!isInCloud)
                        {
                            [weakSelf.selectedDataSource addObject:assetViewModel];
                            weakSelf.customTopView.isSelected = YES;
                            assetViewModel.isSelected = YES;
                            [weakBottom updateSelectedImageCount:weakSelf.selectedDataSource.count];
                        }
                    }];
                }

            }
            else {
                [weakBottom updateImageSize:0];
            }
        
        }];
        
	}
	return _customBottomView;
}

- (UIButton *)sendBtn
{
	if (!_sendBtn){
        
        int width = 118 / 2;
        _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - width - 10, 10, width, 30)];
        _sendBtn.tag = 123;
        _sendBtn.layer.cornerRadius = 3;
        _sendBtn.layer.masksToBounds = YES;
        [_sendBtn setTitle:@"确定" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [YppLifeUtility getFontForDeviceSize];
        [_sendBtn setTitleColor:YPPBlue forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(finishPickingAssetsForPreview:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _sendBtn;
}

- (UIButton *)cropButton
{
	if (!_cropButton){
        _cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cropButton setImage:[UIImage imageNamed:@"scop_shape"] forState:UIControlStateNormal];
        [_cropButton addTarget:self action:@selector(cropButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _cropButton;
}

- (UILabel *)cropTipLabel
{
	if (!_cropTipLabel){
        _cropTipLabel = [[UILabel alloc] init];
        _cropTipLabel.text = NSLocalizedString(@"Select cutting can ensure good display effect more", @"选择裁切更能保证良好的显示效果");
        _cropTipLabel.font = YPP_FONT(11.0f);
        _cropTipLabel.textColor = [UIColor colorWithHexString:@"9b9b9b"];
	}
	return _cropTipLabel;
}

@end
