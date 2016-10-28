//
//  ZAsset.h
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <Photos/Photos.h>

@interface YppAssetViewModel : NSObject

@property (nonatomic, readonly) PHAsset *asset;

@property (nonatomic, strong) UIImage       *thumbImage;
@property (nonatomic, copy)   NSString      *filePath;
@property (nonatomic, assign) CGFloat       videoTime;
@property (nonatomic, copy)   NSString      *videoTimeString;
@property (nonatomic, strong) NSDictionary  *info;
@property (nonatomic, assign) long long      size;

/// defult (100, 100)
@property (nonatomic, assign) CGSize  thumbSize;

@property (nonatomic, assign) BOOL  isSelected;

- (instancetype)initWithPHAsset:(PHAsset *)asset;

- (instancetype)initWithPHAsset:(PHAsset *)asset thumbSize:(CGSize)thumbSize;

@end
