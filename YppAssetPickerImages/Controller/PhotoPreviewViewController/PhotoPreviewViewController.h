//
//  PhotoPreviewViewController.h
//  YppLife
//
//  Created by LiMengyu on 15/10/21.
//  Copyright (c) 2015年 WYWK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YppPreviewImageSourceType)
{
    messagePreviewImage,
    feedPreviewImage,
};

@interface PhotoPreviewViewController : UIViewController
@property(nonatomic, copy) void (^confirmButtonActionBlock)(UIImage *image);

- (instancetype)initWithImage:(UIImage *)image withSource:(YppPreviewImageSourceType)source;

@property(nonatomic) BOOL comeFromUpdateFeedImage;

@end
