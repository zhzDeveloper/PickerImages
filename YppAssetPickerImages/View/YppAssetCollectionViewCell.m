//
//  ZAssetCollectionViewCell.m
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppAssetCollectionViewCell.h"
#import "YppAssetViewModel.h"
#import "YppImageManager.h"
#import <Masonry.h>

@interface YppAssetCollectionViewCell ()

@property (nonatomic, strong) UIImageView           *imageView;
@property (nonatomic, strong) UIButton              *takePhoto;
@property (nonatomic, strong) UIButton              *selectedButton;
@property (nonatomic, strong) UILabel               *timeLabel;

@end
@implementation YppAssetCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
        
    }
    return self;
}


#pragma mark - Public
- (void)configWithAsset:(YppAssetViewModel *)assetViewModel assetPickerType:(NSInteger)assetPickerType indexPath:(NSIndexPath *)indexPath {

    if(assetPickerType != 0)
    { // 单选
        self.selectedButton.hidden = YES;
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            self.takePhoto.hidden = NO;
        }
        else {
            self.takePhoto.hidden = YES;
        }
    }
    else {// 多选
        self.selectedButton.hidden = NO;
    }
    
    if (assetViewModel.thumbImage) {
        self.imageView.image = assetViewModel.thumbImage;
    }
    else {
        [[YppImageManager manager] getThumbPhotoWithAsset:assetViewModel.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud)
        {
            assetViewModel.thumbImage = result;
            self.imageView.image = result;
        }];
        
    }
    
    // 视频时长显示
    self.timeLabel.text = assetViewModel.videoTimeString;
    self.timeLabel.hidden =(assetViewModel.asset.mediaType == PHAssetMediaTypeVideo)?NO:YES;
    self.selectedButton.selected = assetViewModel.isSelected;
    
}

#pragma mark - Private
- (void)setupUI
{
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.selectedButton];
    [self.contentView addSubview:self.takePhoto];
    [self.contentView addSubview:self.timeLabel];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.takePhoto mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-0);
        make.size.mas_equalTo(CGSizeMake(49.0/2.0+6, 49.0/2.0+6));
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-3);
        make.right.equalTo(self.contentView).offset(-3);
    }];
}

- (void)selectedButtonAction:(UIButton *)selectedButton
{
    
    __weak typeof(selectedButton) weakSelectedButton = selectedButton;
    if (self.selectedRefreshBlock) {
        self.selectedRefreshBlock(weakSelectedButton);
    }
}

- (void)showCamera:(id)sender
{
    if (self.showCameraBlock) {
        self.showCameraBlock();
    }
}

#pragma mark - getter && setter
- (UIImageView *)imageView
{
	if (!_imageView){
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
	}
	return _imageView;
}

- (UIButton *)selectedButton
{
	if (!_selectedButton){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"AssetsPickerUnChecked"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"AssetsPickerChecked"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _selectedButton = button;
	}
	return _selectedButton;
}

- (UIButton *)takePhoto
{
	if (!_takePhoto){
        UIButton *takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [takePhoto addTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
        [takePhoto setImage:[UIImage imageNamed:@"newDongtai"] forState:UIControlStateNormal];
        takePhoto.backgroundColor = [UIColor grayColor];
        _takePhoto = takePhoto;
        _takePhoto.hidden = YES;
	}
	return _takePhoto;
}

- (UILabel *)timeLabel
{
	if (!_timeLabel){
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:11];
        _timeLabel.textColor = [UIColor whiteColor];
	}
	return _timeLabel;
}

@end
