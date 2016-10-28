//
//  CustomTopView.m
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppCustomTopView.h"

@interface YppCustomTopView ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *selectedButton;

@end
@implementation YppCustomTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self addSubview:self.backButton];
        [self addSubview:self.selectedButton];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backButton.frame = CGRectMake(12, (64-41)/2.0, 26, 41);
    self.selectedButton.frame = CGRectMake(self.frame.size.width - 15 - 24.5, (64-24.5)/2.0, 49.0/2.0+6, 49.0/2.0+6);
    
}

#pragma mark - private
- (void)backButtonAction:(UIButton *)backButton {
    if (self.topViewBackBlock) {
        self.topViewBackBlock();
    }
}

- (void)selectedButtonAction:(UIButton *)selectedButton {
    if (self.topViewSelectedBlock) {
        self.topViewSelectedBlock(selectedButton);
    }
}

#pragma mark - getter && setter
- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.selectedButton.selected = isSelected;
}

- (UIButton *)backButton
{
	if (!_backButton){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _backButton = button;
	}
	return _backButton;
}

- (UIButton *)selectedButton
{
	if (!_selectedButton){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"AssetsPickerUnChecked"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"AssetsPickerChecked"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _selectedButton = button;
	}
	return _selectedButton;
}

@end
