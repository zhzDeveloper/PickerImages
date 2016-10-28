//
//  YppPreviewAfterCropViewController.h
//  YppLife
//
//  Created by zhz on 7/8/16.
//  Copyright © 2016 WYWK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YppPreviewAfterCropViewController : UIViewController

@property (nonatomic, assign) BOOL isUpdateFeedImage;

- (instancetype)initWithImageAfterCrop:(UIImage *)cropImage;

@end
