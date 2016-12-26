//
//  SLImageCropViewController.h
//  chatApp
//
//  Created by gsw on 12/22/14.
//  Copyright (c) 2014 joychuang. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface YppImageCropViewController : UIViewController

@property (nonatomic, copy) void (^confirmBlock)(UIImage *image);
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, copy) NSString *confimString;

@property (nonatomic, assign) CGRect cropFrame;

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end
