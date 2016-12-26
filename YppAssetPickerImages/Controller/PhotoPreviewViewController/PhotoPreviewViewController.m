//
//  PhotoPreviewViewController.m
//  YppLife
//
//  Created by LiMengyu on 15/10/21.
//  Copyright (c) 2015年 WYWK. All rights reserved.
//

#import "PhotoPreviewViewController.h"
#import <Masonry.h>

@interface PhotoPreviewViewController ()
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIView *bottomView;
@property (nonatomic, strong)UIButton *confirmButton;
@property (nonatomic) YppPreviewImageSourceType imageSource;
@end

@implementation PhotoPreviewViewController

#pragma mark - Life Cycle
-(instancetype)initWithImage:(UIImage *)image withSource:(YppPreviewImageSourceType)source
{
    if(self = [super init])
    {
        self.imageSource = source;
        self.image=image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:NSLocalizedString(@"Preview",@"Preview")];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.confirmButton];
    [self.view addSubview:self.imageView];

    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make)
    {
        make.left.and.right.and.bottom.equalTo(self.view);
        make.height.equalTo(@44);
    }];

    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make)
    {
        make.centerY.equalTo(self.bottomView);
        make.right.equalTo(self.bottomView).with.offset(-8);
    }];

    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make)
    {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(@(18+64));
        make.bottom.equalTo(self.bottomView.mas_top).with.offset(- 18);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //发动态界面点击已选择图片进入
    if (self.comeFromUpdateFeedImage) {
        self.navigationItem.leftBarButtonItem = [YppLifeUtility getLeftUIBarBtnItemWithTarget:self withSEL:@selector(confirmButtonAction:)];
        self.navigationItem.rightBarButtonItem = [YppLifeUtility getTextItemWithTarget:NSLocalizedString(@"Delete", nil) forTarget:self withSEL:@selector(deleteChooseImage)];
    }
    else {
        self.navigationItem.leftBarButtonItem = [YppLifeUtility getLeftUIBarBtnItemWithTarget:self withSEL:@selector(popupMyself)];
    }
}

- (void)deleteChooseImage {
    
    CreateFeedViewController *createFeed = [[CreateFeedViewController alloc] initWithImage:nil];
    [createFeed setDone:^
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:kYPP_NOTIFY_DONGTAI_CREATED object:nil];
     }];
    [self.navigationController pushViewController:createFeed animated:YES];
}

- (void)popupMyself {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Event Response
-(void)confirmButtonAction:(UIButton *)confirmButton
{
    if(self.confirmButtonActionBlock)
    {
        self.confirmButtonActionBlock(self.image);
    }
    if (self.imageSource == messagePreviewImage) {
        [self popupMyself];
    }
}

#pragma mark - Getters and Setters
- (UIImageView *)imageView
{
    if(!_imageView)
    {
        _imageView= [[UIImageView alloc] initWithImage:self.image];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _imageView;
}

- (UIImage *)image
{
    return _image;
}

- (UIView *)bottomView
{
    if(!_bottomView)
    {
        _bottomView= [[UIView alloc] initWithFrame:CGRectZero];
        [_bottomView setBackgroundColor:COLOR_VIEW_BACKGROUND];
    }
    return _bottomView;
}

- (UIButton *)confirmButton
{
    if(!_confirmButton)
    {
        _confirmButton= [[UIButton alloc] initWithFrame:CGRectZero];
        [_confirmButton setTitleColor:YPPBlue forState:UIControlStateNormal];
        [_confirmButton setTitle:NSLocalizedString(@"Confirm",@"Confirm") forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.titleLabel.font = [YppLifeUtility getFontForDeviceSize];
    }
    return _confirmButton;
}

@end
