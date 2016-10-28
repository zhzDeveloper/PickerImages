//
//  YAssetVideoPreviewViewController.h
//  YppLife
//
//  Created by zhz on 7/15/16.
//  Copyright © 2016 WYWK. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

typedef void(^Done)();

@interface YppAssetVideoPreviewViewController : AVPlayerViewController
@property (nonatomic, copy) Done done;

- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem;

- (instancetype)initWithUrl:(NSURL *)itemURL;

@end
