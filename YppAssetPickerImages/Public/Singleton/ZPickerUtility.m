//
//  ZPickerUtility.m
//  PickerImages
//
//  Created by zhz on 23/12/2016.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "ZPickerUtility.h"
#import <MBProgressHUD.h>

@implementation ZPickerUtility

+ (void)showHudWithTextInView:(UIView *)view animate:(BOOL)animate text:(NSString *)text
{
    if (!view)
    {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:animate];
    [hud.bezelView setStyle:MBProgressHUDBackgroundStyleSolidColor];
    [hud setContentColor:[UIColor whiteColor]];
    [hud.bezelView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:1.0f]];
    [hud.label setText:text];
    [hud.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
}


@end
