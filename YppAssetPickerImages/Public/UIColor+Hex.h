//
//  UIColor+Hex.h
//  PickerImages
//
//  Created by zhz on 23/12/2016.
//  Copyright © 2016 zhz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;



@end
