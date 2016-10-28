//
//  ZAssetPreviewViewController.h
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BackRefreshBlock)(NSMutableArray *selectedArray, BOOL isShowOrginImag);
typedef void (^ConfirmBlock)(NSMutableArray *selectedArray);

@class YppAssetViewModel;
@interface YppAssetPreviewViewController : UIViewController
@property (nonatomic, copy) BackRefreshBlock    backRefreshBlock;
@property (nonatomic, copy) ConfirmBlock        confirmBlock;
@property (nonatomic, assign) BOOL      comeFromUpdateFeedImage;
@property (nonatomic, assign) BOOL      isOrginImage;

- (instancetype)initWithDataSource:(NSMutableArray *)dataSource  selectedDataSource:(NSMutableArray *)selectedDataSource indexPath:(NSIndexPath *)indexPath;

@end
