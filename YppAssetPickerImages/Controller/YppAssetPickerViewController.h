//
//  ViewController.h
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YppAssetCollectionViewModel;
@interface YppAssetPickerViewController : UIViewController

- (instancetype)initWithZAssetCollectionViewModel:(YppAssetCollectionViewModel *)assetCollectionViewModel;

@end

