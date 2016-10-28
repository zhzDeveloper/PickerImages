//
//  CustomTopView.h
//  Demo-Photos
//
//  Created by zhz on 7/5/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^TopViewBackBlock)();
typedef void (^TopViewSelectedBlock)(UIButton *selectedButton);

@interface YppCustomTopView : UIView

@property(nonatomic, copy) TopViewBackBlock topViewBackBlock;
@property(nonatomic, copy) TopViewSelectedBlock topViewSelectedBlock;

@property (nonatomic, assign) BOOL isSelected;


@end
