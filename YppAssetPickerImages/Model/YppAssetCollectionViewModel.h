//
//  ZAssetCollectionViewModel.h
//  Demo-Photos
//
//  Created by zhz on 7/6/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class YppAssetViewModel;
@class YppImageManager;

@interface YppAssetCollectionViewModel : NSObject

@property (nonatomic, readonly) PHFetchResult<PHAsset *>            *assets;

@property (nonatomic, strong)   UIImage                             *thumbImage;
@property (nonatomic, readonly) NSString                            *collectionCountText;
@property (nonatomic, readonly) NSString                            *albumsTitle;
@property (nonatomic, readonly) NSMutableArray<YppAssetViewModel *> *assetsArray;

- (instancetype)initWithFetchResult:(PHFetchResult *)fetchResult title:(NSString *)title assetMediaType:(PHAssetMediaType)assetMediaType;

@end
