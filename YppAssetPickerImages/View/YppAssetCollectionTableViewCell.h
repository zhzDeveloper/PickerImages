//
//  ZAssetCollectionTableViewCell.h
//  Demo-Photos
//
//  Created by zhz on 7/6/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YppAssetCollectionViewModel;
@interface YppAssetCollectionTableViewCell : UITableViewCell

- (void)configWithAsset:(YppAssetCollectionViewModel *)assetCollectionViewModel;

@end
