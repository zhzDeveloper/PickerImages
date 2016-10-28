//
//  PZPhotoView.h
//  PhotoZoom
//
//  Created by Brennan Stehling on 10/27/12.
//  Copyright (c) 2012 SmallSharptools LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YppPhotoViewDelegate;

@interface YppPhotoView : UIScrollView

@property (assign, nonatomic) id <YppPhotoViewDelegate> photoViewDelegate;

- (void)prepareForReuse;
- (void)displayImage:(UIImage *)image;

- (void)startWaiting;
- (void)stopWaiting;

- (void)updateZoomScale:(CGFloat)newScale;
- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center;

@end

@protocol YppPhotoViewDelegate <NSObject>

@optional

- (void)photoViewDidSingleTap:(YppPhotoView *)photoView;
- (void)photoViewDidDoubleTap:(YppPhotoView *)photoView;
- (void)photoViewDidTwoFingerTap:(YppPhotoView *)photoView;
- (void)photoViewDidDoubleTwoFingerTap:(YppPhotoView *)photoView;

@end
