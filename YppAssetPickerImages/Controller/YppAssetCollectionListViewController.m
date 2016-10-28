//
//  ZAssetCollectionListViewController.m
//  Demo-Photos
//
//  Created by zhz on 7/6/16.
//  Copyright © 2016 zhz. All rights reserved.
//

#import "YppAssetCollectionListViewController.h"
#import <Photos/Photos.h>
#import "YppAssetCollectionViewModel.h"
#import "YppAssetViewModel.h"
#import "YppAssetCollectionTableViewCell.h"
#import "YppAssetPickerViewController.h"
#import "YppImageManager.h"

static NSString *reuseIdentifier = @"cellReuseIdentifier";

@interface YppAssetCollectionListViewController ()

@property (nonatomic, strong) NSMutableArray<YppAssetCollectionViewModel *> *dataSource;

@end

@implementation YppAssetCollectionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[YppAssetCollectionTableViewCell class] forCellReuseIdentifier:reuseIdentifier];

    [self getAssetCollectlist];

}

#pragma mark - Private
- (void)getAssetCollectlist
{
    [YppLifeUtility showHudWithTextInView:self.view animate:YES text:@""];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[YppImageManager manager] getAblumListWithImagesType:PHAssetMediaTypeImage completion:^(NSArray<YppAssetCollectionViewModel *> *assetCollectArray) {
            self.dataSource = assetCollectArray;

            dispatch_sync(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
            });
        }];

    });

}

- (void)dismiss:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YppAssetCollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    YppAssetCollectionViewModel *model = self.dataSource[indexPath.row];
    [cell configWithAsset:model];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = [self.dataSource copy];
    YppAssetCollectionViewModel *model = self.dataSource[indexPath.row];
    if (model.assetsArray.count)
    {
        YppAssetPickerViewController *assetPickerViewController = [[YppAssetPickerViewController alloc] initWithZAssetCollectionViewModel:arr[indexPath.row]];
        [self.navigationController pushViewController:assetPickerViewController animated:YES];
    }
}

@end
