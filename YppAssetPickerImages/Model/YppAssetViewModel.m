//
//  ZAsset.m
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppAssetViewModel.h"

@implementation YppAssetViewModel

- (instancetype)initWithPHAsset:(PHAsset *)asset {
    return [self initWithPHAsset:asset thumbSize:CGSizeMake(150, 150)];
}

- (instancetype)initWithPHAsset:(PHAsset *)asset thumbSize:(CGSize)thumbSize {
    if (self = [super init]) {
        
        _asset = asset;
        if (CGSizeEqualToSize(thumbSize, CGSizeZero)) {
            _thumbSize = CGSizeMake(350, 350);
        }
        else {
            _thumbSize = thumbSize;
        }
        _videoTime = asset.mediaType == PHAssetMediaTypeVideo?asset.duration:0;
        _videoTimeString = asset.mediaType == PHAssetMediaTypeVideo?[NSString stringWithFormat:@"%02.0f:%02.0f", asset.duration / 60, (CGFloat)((int)asset.duration % 60)] : @"";

    }
    return self;
}

@end
