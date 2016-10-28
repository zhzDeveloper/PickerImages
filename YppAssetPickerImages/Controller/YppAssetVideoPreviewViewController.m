//
//  YAssetVideoPreviewViewController.m
//  YppLife
//
//  Created by zhz on 7/15/16.
//  Copyright © 2016 WYWK. All rights reserved.
//

#import "YppAssetVideoPreviewViewController.h"

@interface YppAssetVideoPreviewViewController ()

@property (nonatomic, strong) AVPlayerItem      *playerItem;
@property (nonatomic, strong) AVPlayer          *avPlayer;

@property (nonatomic, strong) UIView            *bottomView;
@property (nonatomic, strong) UIButton          *submitButton;
@property (nonatomic, strong) UIButton          *cancelButton;
@property (nonatomic, strong) UIButton          *playOrPauseButton;

@end

@implementation YppAssetVideoPreviewViewController

- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem {
    if (self = [super init]) {

        _playerItem = playerItem;

        self.avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        self.player = self.avPlayer;
        self.showsPlaybackControls = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(avPlayerPlayFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
                                                             



    }
    return self;
}

- (instancetype)initWithUrl:(NSURL *)itemURL
{
    if (self = [super init]) {
        
        self.avPlayer = [AVPlayer playerWithURL:itemURL];
        self.player = self.avPlayer;
        self.showsPlaybackControls = NO;
        [self.avPlayer play];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(avPlayerPlayFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.playerItem?self.avPlayer.currentItem:nil];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.bottomView.hidden = !self.bottomView.isHidden;
    self.playOrPauseButton.selected = !self.playOrPauseButton.isSelected;
    if (self.playOrPauseButton.selected) {
        [self.avPlayer pause];
        self.bottomView.hidden = NO;
    }
    else {
        [self.avPlayer play];
        self.bottomView.hidden = YES;
    }
}

- (void)avPlayerPlayFinish:(NSNotification *)notification {
    
    self.bottomView.hidden = NO;
    self.playOrPauseButton.selected = YES;
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [self.player seekToTime:CMTimeMake(0, 1)];
}

#pragma mark - Private

- (void)setupUI {
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.submitButton];
    [self.bottomView addSubview:self.cancelButton];
    [self.bottomView addSubview:self.playOrPauseButton];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-15);
        make.centerY.equalTo(self.bottomView);
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(15);
        make.centerY.equalTo(self.bottomView);
    }];
    [self.playOrPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
}

- (void)playOrPauseButtonAction:(UIButton *)playOrPauseButton {
    playOrPauseButton.selected = !playOrPauseButton.isSelected;
    
    if (playOrPauseButton.selected) {
        [self.avPlayer pause];
        self.bottomView.hidden = NO;
    }
    else {
        [self.avPlayer play];
        self.bottomView.hidden = YES;
    }
    
}

- (void)cancelButtonAction:(UIButton *)cancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)submitButtonAction:(UIButton *)submitButton {
    if (self.playerItem) {
        if (self.done) {
            self.done();
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - getter && setter
- (UIButton *)submitButton
{
	if (!_submitButton){
        
        UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitButton.titleLabel setFont:YPP_FONT(14.0f)];
        [submitButton setTitle:@"确定" forState:UIControlStateNormal];
        [submitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(submitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _submitButton = submitButton;
        
	}
	return _submitButton;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton){
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton.titleLabel setFont:YPP_FONT(14.0f)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)playOrPauseButton
{
    if (!_playOrPauseButton){
        _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseButton.titleLabel setFont:YPP_FONT(14.0f)];
        _playOrPauseButton.selected = YES;
        [_playOrPauseButton setImage:[UIImage imageNamed:@"record_audio_stop"] forState:UIControlStateNormal];
        [_playOrPauseButton setImage:[UIImage imageNamed:@"record_audio_play"] forState:UIControlStateSelected];
        [_playOrPauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playOrPauseButton addTarget:self action:@selector(playOrPauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseButton;
}


- (UIView *)bottomView
{
	if (!_bottomView){
        _bottomView = [UIView new];
        _bottomView.backgroundColor = [UIColor clearColor];
	}
	return _bottomView;
}



@end
