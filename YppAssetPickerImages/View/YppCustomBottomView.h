//
//  CustomBottomView.h
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PreviewImagesBlock)();
typedef void(^SelectedOrginImagesBlock)(BOOL isShowOrgin);
typedef void(^ConfirmSelectedImagesBlock)();

@interface YppCustomBottomView : UIView

@property (nonatomic, assign) BOOL isShowPreButton;
@property (nonatomic, assign) BOOL isAllSelectOrign;
@property (nonatomic, copy) PreviewImagesBlock previewImagesBlock;
@property (nonatomic, copy) ConfirmSelectedImagesBlock confirmSelectedImagesBlock;
@property (nonatomic, copy) SelectedOrginImagesBlock selectedOrginImagesBlock;

- (instancetype)initWithFrame:(CGRect)frame isShowPreButton:(BOOL)isShowPreButton;

- (void)updateSelectedImageCount:(NSInteger)imageCount;

- (void)updateImageSize:(long long)size;
@end
