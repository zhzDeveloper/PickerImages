//
//  ZAssetPreViewCollectionCell.m
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppAssetPreViewCollectionCell.h"
#import "YppAssetViewModel.h"
#import "YppPhotoView.h"
#import "YppImageManager.h"

@interface YppAssetPreViewCollectionCell ()<YppPhotoViewDelegate>

@property (nonatomic, strong) YppPhotoView      *imageView;
@property (nonatomic, copy)   NSString          *assetIdentifier;

@end
@implementation YppAssetPreViewCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
        
    }
    return self;
}

#pragma mark - Public
- (void)configWithAsset:(YppAssetViewModel *)assetViewModel
{
    self.assetIdentifier = assetViewModel.asset.localIdentifier;
    [[YppImageManager manager] getScreenWithPhotoWithAsset:assetViewModel.asset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result && [orginAsset.localIdentifier isEqualToString:self.assetIdentifier]) {
                [self.imageView prepareForReuse];
                [self.imageView displayImage:result];
            }
        });

    }];
}

#pragma mark - Private
- (void)setupUI
{
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark - photoViewDelegate
- (void)photoViewDidSingleTap:(YppPhotoView *)photoView
{
    if (self.tapHiddenTopAndBottomViewBlock) {
        self.tapHiddenTopAndBottomViewBlock();
    }
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
- (YppPhotoView *)imageView
{
    if (!_imageView){
        _imageView = [[YppPhotoView alloc] init];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.minimumZoomScale = 0.5;
        _imageView.maximumZoomScale = 2.5;
        _imageView.photoViewDelegate = self;
    }
    return _imageView;
}
@end
