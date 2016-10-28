//
//  ZAssetCollectionViewCell.h
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedRefreshBlock)(UIButton *button);
typedef void(^ShowCameraBlock)();

@class YppAssetViewModel;
@interface YppAssetCollectionViewCell : UICollectionViewCell
@property (nonatomic, copy) SelectedRefreshBlock    selectedRefreshBlock;
@property (nonatomic, copy) ShowCameraBlock         showCameraBlock;

- (void)configWithAsset:(YppAssetViewModel *)assetViewModel assetPickerType:(NSInteger)assetPickerType indexPath:(NSIndexPath *)indexPath;

@end
