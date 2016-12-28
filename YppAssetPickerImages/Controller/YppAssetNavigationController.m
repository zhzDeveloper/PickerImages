//
//  ZAssetNavigationController.m
//  Demo-Photos
//
//  Created by zhz on 7/6/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppAssetNavigationController.h"
#import "YppAssetCollectionListViewController.h"
#import "YppAssetPickerViewController.h"

@interface YppAssetNavigationController ()

@end

@implementation YppAssetNavigationController

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self) {
        
        YppAssetCollectionListViewController *assetCollectionListViewController = [[YppAssetCollectionListViewController alloc] init];
        NSArray *viewControllers = @[assetCollectionListViewController];
        [self setValue:viewControllers forKey:@"viewControllers"];
        
        YppAssetPickerViewController *assetPickerViewController = [[YppAssetPickerViewController alloc] init];
        [self pushViewController:assetPickerViewController animated:NO];
        
        _selectedMaxCount   = 0;
        _lineCount          = 4;
       
    }
    
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        
        YppAssetPickerViewController *assetPickerViewController = [[YppAssetPickerViewController alloc] init];
        [self pushViewController:assetPickerViewController animated:NO];
        
        _selectedMaxCount   = 0;
        _lineCount          = 4;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [self.navigationBar setBarTintColor:[UIColor blueColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
