//
//  ZAssetCollectionViewModel.m
//  Demo-Photos
//
//  Created by zhz on 7/6/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppAssetCollectionViewModel.h"
#import "YppAssetViewModel.h"
#import "YppImageManager.h"

@implementation YppAssetCollectionViewModel

- (instancetype)initWithFetchResult:(PHFetchResult *)fetchResult title:(NSString *)title assetMediaType:(PHAssetMediaType)assetMediaType{
    if (self = [super init]) {
        
        _assets = fetchResult;
        
        _collectionCountText = [NSString stringWithFormat:@"(%zd)", fetchResult.count];
        _albumsTitle = title;
        
        _assetsArray = [NSMutableArray arrayWithCapacity:fetchResult.count];
        [[YppImageManager manager] getAssetsFromFetchResult:fetchResult assetMediaType:(ManagerAssetMediaType)assetMediaType completion:^(NSArray<YppAssetViewModel *> *assetModels) {
            
            _assetsArray = [NSMutableArray arrayWithArray:assetModels];
        }];
        
    }
    return self;
}

@end
