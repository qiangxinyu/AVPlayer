//
//  XYAVPlayerView.h
//  AVPlayer
//
//  Created by 强新宇 on 16/8/16.
//  Copyright © 2016年 强新宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYAVControlView.h"

@interface  XYAVPlayerView : UIView
@property (strong, nonatomic) XYAVControlView *playControlView;


@property (nonatomic, copy)NSString * videoUrl;


@property (nonatomic, strong)AVPlayer * avPlayer;
@property (nonatomic, strong)AVPlayerItem * avPlayerItem;
@property (nonatomic, strong)AVPlayerLayer * avPlayerLayer;

@end
