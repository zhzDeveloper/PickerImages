//
//  SLImageCropViewController.m
//  chatApp
//
//  Created by gsw on 12/22/14.
//  Copyright (c) 2014 joychuang. All rights reserved.
//

#import "YppImageCropViewController.h"
#import "ZPickerHeader.h"
#import "UIColor+Hex.h"
#import <Masonry.h>

#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f

@interface YppImageCropViewController ()

@property (nonatomic, retain) UIImage *originalImage;
@property (nonatomic, retain) UIImage *editedImage;

@property (nonatomic, retain) UIImageView *showImgView;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIView *ratioView;

@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGFloat limitRatio;

@property (nonatomic, assign) CGRect latestFrame;

@end

@implementation YppImageCropViewController


- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio {
	self = [super init];
	if (self) {
		self.cropFrame = cropFrame;
		self.limitRatio = limitRatio;
		self.originalImage = [self fixOrientation:originalImage];
        if (!self.originalImage.size.width || !self.originalImage.size.height) {
            self.originalImage = originalImage;
        }
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initView];
	[self initControlBtn];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)initView {
	self.view.backgroundColor = [UIColor blackColor];

	self.showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	[self.showImgView setMultipleTouchEnabled:YES];
	[self.showImgView setUserInteractionEnabled:YES];
	[self.showImgView setImage:self.originalImage];
	[self.showImgView setUserInteractionEnabled:YES];
	[self.showImgView setMultipleTouchEnabled:YES];

	// scale to fit the screen
	CGFloat oriWidth = self.cropFrame.size.width;
    CGFloat scale = oriWidth / (self.originalImage.size.width?:1);
	CGFloat oriHeight = self.originalImage.size.height * scale;
	CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
	CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    if (oriHeight < self.cropFrame.size.height) {
        CGFloat newScale = self.cropFrame.size.height/oriHeight;
        oriWidth = self.cropFrame.size.width * newScale;
        oriHeight = self.cropFrame.size.height;
        oriY = self.cropFrame.origin.y;
    }
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
	self.latestFrame = self.oldFrame;
	self.showImgView.frame = self.oldFrame;

	self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);

	[self addGestureRecognizers];
	[self.view addSubview:self.showImgView];
    
    //添加遮罩层
	self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.overlayView.alpha = .5f;
	self.overlayView.backgroundColor = [UIColor blackColor];
	self.overlayView.userInteractionEnabled = NO;
	self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:self.overlayView];

	self.ratioView = [[UIView alloc] initWithFrame:self.cropFrame];
	self.ratioView.layer.borderColor = [UIColor whiteColor].CGColor;
	self.ratioView.layer.borderWidth = 0.5f;
	self.ratioView.autoresizingMask = UIViewAutoresizingNone;
	[self.view addSubview:self.ratioView];

	[self overlayClipping];
}

- (void)initControlBtn {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50.0f, SCREEN_WIDTH, 50)];
    bottomView.backgroundColor = [UIColor colorWithHexString:@"323232"];
    [self.view addSubview:bottomView];
	UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
	[cancelBtn setTitle:@"删除" forState:UIControlStateNormal];
	[cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
	[cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	[bottomView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView);
        make.left.equalTo(bottomView).offset(15);
    }];
    
    
	UIButton *confirmBtn = [[UIButton alloc] init];
    [confirmBtn setTitleColor:[UIColor colorWithRed:29.0f/255.0f green:154.0f/255.0f blue:255.0f/255.0f alpha:1] forState:UIControlStateNormal];
    [confirmBtn setTitle:self.confimString?:@"裁剪" forState:UIControlStateNormal];
	[confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
	[confirmBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
	[confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
	[bottomView addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView);
        make.right.equalTo(bottomView.mas_right).offset(-15);
    }];
}

- (void)cancel:(id)sender {
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirm:(id)sender {
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.confirmBlock) {
        self.confirmBlock([self getSubImage]);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
}

- (void)overlayClipping {
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
	CGMutablePathRef path = CGPathCreateMutable();
	// Left side of the ratio view
	CGPathAddRect(path, nil, CGRectMake(0, 0,
	                                    self.ratioView.frame.origin.x,
	                                    self.overlayView.frame.size.height));
	// Right side of the ratio view
	CGPathAddRect(path, nil, CGRectMake(
	                  self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
	                  0,
	                  self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
	                  self.overlayView.frame.size.height));
	// Top side of the ratio view
	CGPathAddRect(path, nil, CGRectMake(0, 0,
	                                    self.overlayView.frame.size.width,
	                                    self.ratioView.frame.origin.y));
	// Bottom side of the ratio view
	CGPathAddRect(path, nil, CGRectMake(0,
	                                    self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
	                                    self.overlayView.frame.size.width,
	                                    self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
	maskLayer.path = path;
	self.overlayView.layer.mask = maskLayer;
	CGPathRelease(path);
}

// register all gestures
- (void)addGestureRecognizers {
	// add pinch gesture
	UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
	[self.view addGestureRecognizer:pinchGestureRecognizer];

	// add pan gesture
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
	[self.view addGestureRecognizer:panGestureRecognizer];
}

// pinch gesture handler
- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
	UIView *view = self.showImgView;
	if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
		view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
		pinchGestureRecognizer.scale = 1;
	}
	else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		CGRect newFrame = self.showImgView.frame;
		newFrame = [self handleScaleOverflow:newFrame];
		newFrame = [self handleBorderOverflow:newFrame];
		[UIView animateWithDuration:BOUNDCE_DURATION animations: ^{
		    self.showImgView.frame = newFrame;
		    self.latestFrame = newFrame;
		}];
	}
}

// pan gesture handler
- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer {
	UIView *view = self.showImgView;
	if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
		// calculate accelerator
		CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
		CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / (self.cropFrame.size.width?:1);
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX?:1);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY?:1);
		CGPoint translation = [panGestureRecognizer translationInView:view.superview];
		[view setCenter:(CGPoint) {view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY }];
		[panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
	}
	else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		// bounce to original frame
		CGRect newFrame = self.showImgView.frame;
		newFrame = [self handleBorderOverflow:newFrame];
		[UIView animateWithDuration:BOUNDCE_DURATION animations: ^{
		    self.showImgView.frame = newFrame;
		    self.latestFrame = newFrame;
		}];
	}
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
	// bounce to original frame
	CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width / 2, newFrame.origin.y + newFrame.size.height / 2);
	if (newFrame.size.width < self.oldFrame.size.width) {
		newFrame = self.oldFrame;
	}
	if (newFrame.size.width > self.largeFrame.size.width) {
		newFrame = self.largeFrame;
	}
	newFrame.origin.x = oriCenter.x - newFrame.size.width / 2;
	newFrame.origin.y = oriCenter.y - newFrame.size.height / 2;
	return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
	// horizontally
	if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
	if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
	// vertically
	if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
	if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
		newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
	}
	// adapt horizontally rectangle
	if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
		newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
	}
	return newFrame;
}

- (UIImage *)getSubImage {
	CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / (self.originalImage.size.width?:1);
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / (scaleRatio?:1);
	CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / (scaleRatio?:1);
    CGFloat w = squareFrame.size.width / (scaleRatio?:1);
	CGFloat h = squareFrame.size.height / (scaleRatio?:1);
	if (self.latestFrame.size.width < self.cropFrame.size.width) {
		CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / (self.cropFrame.size.width?:1));
		x = 0; y = y + (h - newH) / 2;
		w = newH; h = newH;
	}
	if (self.latestFrame.size.height < self.cropFrame.size.height) {
		CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / (self.cropFrame.size.height?:1));
		x = x + (w - newW) / 2;
        y = 0;
		w = newH; h = newH;
	}
	CGRect myImageRect = CGRectMake(x, y, w, h);
	CGImageRef imageRef = self.originalImage.CGImage;
	CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
	CGSize size;
	size.width = myImageRect.size.width;
	size.height = myImageRect.size.height;
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, myImageRect, subImageRef);
	UIImage *smallImage = [UIImage imageWithCGImage:subImageRef];
	CGImageRelease(subImageRef);
	UIGraphicsEndImageContext();
	return smallImage;
}

- (UIImage *)fixOrientation:(UIImage *)srcImg {
	if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch (srcImg.imageOrientation) {
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;

		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;

		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;

		case UIImageOrientationUp:
		case UIImageOrientationUpMirrored:
			break;
	}

	switch (srcImg.imageOrientation) {
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;

		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;

		case UIImageOrientationUp:
		case UIImageOrientationDown:
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			break;
	}

	CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
	                                         CGImageGetBitsPerComponent(srcImg.CGImage), 0,
	                                         CGImageGetColorSpace(srcImg.CGImage),
	                                         CGImageGetBitmapInfo(srcImg.CGImage));
	CGContextConcatCTM(ctx, transform);
	switch (srcImg.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			CGContextDrawImage(ctx, CGRectMake(0, 0, srcImg.size.height, srcImg.size.width), srcImg.CGImage);
			break;

		default:
			CGContextDrawImage(ctx, CGRectMake(0, 0, srcImg.size.width, srcImg.size.height), srcImg.CGImage);
			break;
	}

	CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
	CGContextRelease(ctx);
	CGImageRelease(cgimg);
	return img;
}

@end
