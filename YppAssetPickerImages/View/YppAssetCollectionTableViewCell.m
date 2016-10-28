
//  ZAssetCollectionTableViewCell.m
//  Demo-Photos
//
//  Created by zhz on 7/6/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppAssetCollectionTableViewCell.h"
#import "YppAssetCollectionViewModel.h"
#import "YppAssetViewModel.h"
#import "YppImageManager.h"

static CGFloat const padding = 10.0f;
@interface YppAssetCollectionTableViewCell ()

@property (nonatomic, strong) UIImageView   *thumbImageView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *countLabel;

@end
@implementation YppAssetCollectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.thumbImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.countLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.thumbImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView);
            make.width.height.equalTo(self.contentView.mas_height);
        }];
        [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.countLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.thumbImageView.mas_right).offset(padding);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.countLabel.mas_left).offset(-padding);
        }];
        [self.countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).offset(padding);
            make.centerY.equalTo(self.contentView);
            make.right.lessThanOrEqualTo(self.contentView.mas_right);
        }];
        
    }
    return self;
}

- (void)configWithAsset:(YppAssetCollectionViewModel *)assetCollectionViewModel {
    
    if (assetCollectionViewModel.thumbImage) {
        self.thumbImageView.image = assetCollectionViewModel.thumbImage;
    }
    else {
        PHAsset *firstAsset = [assetCollectionViewModel.assets firstObject];
        [[YppImageManager manager] getThumbPhotoWithAsset:firstAsset completion:^(UIImage *result, PHAsset *orginAsset, NSError *error, BOOL isDegraded, BOOL isInCloud) {
            //保存一份
            dispatch_async(dispatch_get_main_queue(), ^{
                self.thumbImageView.image = result;
            });
            assetCollectionViewModel.thumbImage = result;
        }];
    }
    
    _titleLabel.text = assetCollectionViewModel.albumsTitle;
    _countLabel.text = assetCollectionViewModel.collectionCountText;

}

#pragma mark - getter && setter
- (UIImageView *)thumbImageView
{
    if (!_thumbImageView){
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
    }
    return _thumbImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = YPP_FONT_BOLD(16.0f);
        [_titleLabel sizeToFit];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UILabel *)countLabel
{
    if (!_countLabel){
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = YPP_FONT_BOLD(16.0f);
        _countLabel.textColor = [UIColor grayColor];
    }
    return _countLabel;
}


@end
