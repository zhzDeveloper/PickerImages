//
//  CustomBottomView.m
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppCustomBottomView.h"
#import <Masonry.h>
#import "ZPickerHeader.h"
#import "UIColor+Hex.h"

@interface YppCustomBottomView ()

@property(nonatomic, strong) UIButton *orignImageButton;
@property(nonatomic, strong) UILabel *orignImageLabel;
@property(nonatomic, strong) UIButton *preViewButton;
@property(nonatomic, strong) UIButton *sendButton;

@end
@implementation YppCustomBottomView

- (instancetype)initWithFrame:(CGRect)frame isShowPreButton:(BOOL)isShowPreButton
{
    self = [super initWithFrame:frame];
    if (self) {
        _isShowPreButton = isShowPreButton;
        
        [self setupUI];
    }
    return self;
}

#pragma mark - Public
- (void)updateSelectedImageCount:(NSInteger)imageCount {
    self.preViewButton.enabled = imageCount;
    
    NSString *title = [[NSString alloc] initWithFormat:@"确定(%zd)", imageCount];
    [self.sendButton setTitle:[title stringByReplacingOccurrencesOfString:@"确定(0)" withString:@"确定"] forState:UIControlStateNormal];
}

#pragma mark - Private
- (void)setupUI {
    
    [self addSubview:self.preViewButton];
    [self addSubview:self.orignImageButton];
    [self addSubview:self.orignImageLabel];
    [self addSubview:self.sendButton];
    
    [self.preViewButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(self.isShowPreButton?50:0, 28));
    }];
    
    [self.orignImageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.preViewButton.mas_right);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];

    [self.orignImageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.orignImageButton.mas_right).offset(-11);
        make.size.mas_equalTo(CGSizeMake(150, 44));
    }];
    
    [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(118/2, 30));
    }];
    
    self.backgroundColor = self.isShowPreButton ? YPP_RGB(242, 242, 242):[UIColor colorWithHexString:@"323232"];;
}

- (void)orignImageButtonAction:(UIButton *)orignImageButton {
    orignImageButton.selected = !orignImageButton.selected;
    _isAllSelectOrign = orignImageButton.selected;
    if (self.selectedOrginImagesBlock) {
        self.selectedOrginImagesBlock(_isAllSelectOrign);
    }
    
    if (!_isAllSelectOrign) {
        [self updateImageSize:0];
    }
}

- (void)preViewButtonAction:(UIButton *)preViewButton {
    if (self.previewImagesBlock) {
        self.previewImagesBlock();
    }
}

- (void)sendButtonAction:(UIButton *)sendButton {
    if (self.confirmSelectedImagesBlock) {
        self.confirmSelectedImagesBlock();
    }
}

- (void)updateImageSize:(long long)size
{
    if (size == 0)
    {
        _orignImageLabel.text = NSLocalizedString(@"Original image", @"原图");
    }
    if (size > 1024 * 1024)
    {
        _orignImageLabel.text = [NSString stringWithFormat:@"%@(%.1fMB)", NSLocalizedString(@"Original image", @"原图"), size / (1024 * 1024.00)];
    }
    else if (size > 1024)
    {
        _orignImageLabel.text = [NSString stringWithFormat:@"%@(%.1fKB)", NSLocalizedString(@"Original image", @"原图"), size / 1024.00];
    }
}

#pragma mark - getter && setter
- (void)setIsAllSelectOrign:(BOOL)isAllSelectOrign {
    _isAllSelectOrign = isAllSelectOrign;
    self.orignImageButton.selected = isAllSelectOrign;
}

- (UIButton *)orignImageButton
{
	if (!_orignImageButton){
        self.orignImageButton = [[UIButton alloc] init];
        [self.orignImageButton setImage:[UIImage imageNamed:@"msg_pic_unorign.png"] forState:UIControlStateNormal];
        [self.orignImageButton setImage:[UIImage imageNamed:@"msg_pic_orign.png"] forState:UIControlStateSelected];
        [self.orignImageButton addTarget:self action:@selector(orignImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _orignImageButton;
}

- (UILabel *)orignImageLabel
{
	if (!_orignImageLabel){
        _orignImageLabel = [[UILabel alloc] init];
        _orignImageLabel.backgroundColor = [UIColor clearColor];
        _orignImageLabel.text = NSLocalizedString(@"Original image", @"原图");
        _orignImageLabel.font = [UIFont systemFontOfSize:15];
        _orignImageLabel.textColor = [UIColor colorWithHexString:@"C6C6C6"];
	}
	return _orignImageLabel;
}

- (UIButton *)preViewButton
{
	if (!_preViewButton){
        _preViewButton = [[UIButton alloc] init];
        [_preViewButton setTitle:@"预览" forState:UIControlStateNormal];
        _preViewButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _preViewButton.enabled = NO;
        _preViewButton.layer.cornerRadius = 4.0f;
        _preViewButton.layer.masksToBounds = YES;
        _preViewButton.backgroundColor = [UIColor whiteColor];
        _preViewButton.layer.borderWidth = 0.5f;
        _preViewButton.layer.borderColor = [UIColor grayColor].CGColor;
        [_preViewButton setTitleColor:[UIColor colorWithHexString:@"4a4a4a"] forState:UIControlStateNormal];
        [_preViewButton setTitleColor:[UIColor colorWithHexString:@"c6c6c6"] forState:UIControlStateDisabled];
        [_preViewButton addTarget:self action:@selector(preViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _preViewButton;
}

- (UIButton *)sendButton
{
	if (!_sendButton){
        _sendButton = [[UIButton alloc] init];
        _sendButton.layer.cornerRadius = 3;
        _sendButton.layer.masksToBounds = YES;
        [_sendButton setTitle:@"确定" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendButton setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
        [_sendButton setBackgroundColor:[UIColor blueColor]];
        [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
	return _sendButton;
}

@end
