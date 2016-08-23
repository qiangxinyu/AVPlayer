//
//  XYAVPlayerView.m
//  AVPlayer
//
//  Created by 强新宇 on 16/8/16.
//  Copyright © 2016年 强新宇. All rights reserved.
//

#import "XYAVPlayerView.h"

@interface XYAVPlayerView ()

@end


@implementation XYAVPlayerView
- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.playControlView];
    }
    return self;
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.avPlayerLayer.frame = self.bounds;
    self.playControlView.frame = self.bounds;
}

- (void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl = videoUrl.copy;
    [self createAVPlayer];

}


- (void)createAVPlayer
{
    
    NSURL *url = [NSURL URLWithString:self.videoUrl];
    if (!url) {
        return;
    }
  

    /**
     *  AVPlayer
     */
    _avPlayerItem = [AVPlayerItem playerItemWithURL:url];
    _avPlayer = [AVPlayer playerWithPlayerItem:_avPlayerItem];
    _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    _avPlayerLayer.frame = self.bounds;
    _avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//
    
    
    [self.layer addSublayer:_avPlayerLayer];
    
    [_avPlayer play];
    
    self.autoresizesSubviews = YES; //子视图Size自适应
    
    _playControlView.avPlayer = self.avPlayer;
    _playControlView.avPlayerItem = self.avPlayerItem;
    _playControlView.avPlayerLayer = self.avPlayerLayer;
    
    [_playControlView addObserver];
    [_playControlView playerTimerAction];
    
    
    [self bringSubviewToFront:self.playControlView];
}

- (XYAVControlView *)playControlView
{
    if (!_playControlView) {
        _playControlView = [XYAVControlView getXYAVControlView];
    }
    return _playControlView;
}



@end
