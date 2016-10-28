//
//  ZAssetPreViewCollectionCell.h
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TapHiddenTopAndBottomViewBlock)();
@class YppAssetViewModel;
@interface YppAssetPreViewCollectionCell : UICollectionViewCell
@property (nonatomic, copy) TapHiddenTopAndBottomViewBlock tapHiddenTopAndBottomViewBlock;

- (void)configWithAsset:(YppAssetViewModel *)assetViewModel;

@end
