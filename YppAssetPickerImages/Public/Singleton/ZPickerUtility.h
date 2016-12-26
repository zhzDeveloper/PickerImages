//
//  ZPickerUtility.h
//  PickerImages
//
//  Created by zhz on 23/12/2016.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZPickerUtility : NSObject

+ (void)showHudWithTextInView:(UIView *)view
                      animate:(BOOL)animate
                         text:(NSString *)text;
@end
