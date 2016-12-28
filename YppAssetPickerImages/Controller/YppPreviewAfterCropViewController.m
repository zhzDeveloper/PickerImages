//
//  SLPreviewAfterCropViewController.m
//  YppLife
//
//  Created by zhz on 7/8/16.
//  Copyright © 2016 WYWK. All rights reserved.
//

#import "YppPreviewAfterCropViewController.h"
#import "YppPhotoView.h"
#import "YppAssetNavigationController.h"
#import "UIColor+Hex.h"

@interface YppPreviewAfterCropViewController ()<YppPhotoViewDelegate>

@property (nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UIButton *sendBtn;
@property(nonatomic, strong) UIButton *cropButton;

@end

@implementation YppPreviewAfterCropViewController

- (instancetype)initWithImageAfterCrop:(UIImage *)cropImage {
    if (self = [super init]) {
        _image = cropImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Preview", nil);
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:UIBarButtonItemStylePlain target:self action:@selector(jumpToOrginImageVC:)];
    [self setupUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    if (self.isUpdateFeedImage) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteChooseImage)];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    }
}

- (void)deleteChooseImage {
    
   
}

- (void)setupUI
{
    int height = 50;
    CGRect windowBounds = [[UIScreen mainScreen] bounds];
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, windowBounds.size.height - height, SCREEN_WIDTH, height)];
    _bottomView.backgroundColor = [UIColor colorWithHexString:@"323232"];
    
    [_bottomView addSubview:self.sendBtn];
    [_bottomView addSubview:self.cropButton];
    [self.cropButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_bottomView);
        make.left.equalTo(_bottomView).offset(15);
    }];
    
    YppPhotoView *photoView = [[YppPhotoView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_WIDTH, SCREEN_HEIGHT)];;
    photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    photoView.photoViewDelegate = self;
    photoView.backgroundColor = [UIColor blackColor];
    [photoView displayImage:self.image];
    [self.view addSubview:photoView];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    [photoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.width.height.equalTo(self.view);
    }];
    
    [self.view addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)finishPickingAssetsForPreview {
    
    __weak YppAssetNavigationController *assetNavigationController = (YppAssetNavigationController *)self.navigationController;
    if (assetNavigationController.isApplyAptitude) {
        if ([assetNavigationController.pickerDelegate respondsToSelector:@selector(assetPickerController:didFinishPickingAssets:)])
            [assetNavigationController.pickerDelegate assetPickerController:assetNavigationController didFinishPickingAssets:@[self.image]];
        [assetNavigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
    else if (assetNavigationController.isCreateFeed) {
        
        NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
        UIImage *image = [UIImage imageWithData:imageData];
        CreateFeedViewController *createFeed = [[CreateFeedViewController alloc] initWithImage:image];
        [createFeed setDone:^
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:kYPP_NOTIFY_DONGTAI_CREATED object:nil];
         }];
        [self.navigationController pushViewController:createFeed animated:YES];
    }
    
    
}

- (void)cropButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)jumpToOrginImageVC:(id)sender {
	[self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"YppAssetPickerViewController")]) {
            [self.navigationController popToViewController:obj animated:YES];
            *stop = YES;
        }
    }];
}

- (void)toggleFullScreen
{
    self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.hidden;
    _bottomView.hidden = !_bottomView.hidden;
}

#pragma mark - PZPhotoViewDelegate
- (void)photoViewDidSingleTap:(YppPhotoView *)photoView
{
    [self toggleFullScreen];
}

- (void)photoViewDidDoubleTap:(YppPhotoView *)photoView
{
    // do nothing
}

- (void)photoViewDidTwoFingerTap:(YppPhotoView *)photoView
{
    // do nothing
}

- (void)photoViewDidDoubleTwoFingerTap:(YppPhotoView *)photoView
{
}

#pragma mark - getter && setter
- (UIButton *)sendBtn
{
	if (!_sendBtn){
        
        int width = 118 / 2;
        _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - width - 10, 10, width, 30)];
        [_sendBtn setTitle:@"确定" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [YppLifeUtility getFontForDeviceSize];
        [_sendBtn setTitleColor:YPPBlue forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor clearColor]];
        [_sendBtn addTarget:self action:@selector(finishPickingAssetsForPreview) forControlEvents:UIControlEventTouchUpInside];
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


@end
