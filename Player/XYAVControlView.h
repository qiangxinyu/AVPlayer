//
//  XYAVControl.h
//  AVPlayer
//
//  Created by 强新宇 on 16/8/16.
//  Copyright © 2016年 强新宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <MediaPlayer/MediaPlayer.h>

@class XYAVControlView;

typedef void(^ClickFullScreenBtnBlock)(XYAVControlView * avControlView);

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

@interface XYAVControlView : UIView

+ (XYAVControlView *)getXYAVControlView;

@property (nonatomic, assign)BOOL  isFullScreen;



@property (nonatomic, strong)AVPlayer * avPlayer;
@property (nonatomic, strong)AVPlayerItem * avPlayerItem;
@property (nonatomic, strong)AVPlayerLayer * avPlayerLayer;



@property (nonatomic,assign)PanDirection pandirection;


/**
 *  调节音量 亮度
 */
@property (weak, nonatomic) IBOutlet UIView *adjustView;

/**
 *  屏幕中间的Label
 */
@property (weak, nonatomic) IBOutlet UILabel *changeTimeLabel;


/**
 *  控制条
 */
@property (weak, nonatomic) IBOutlet UIView *controlStripView;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *allTimeLabel;


@property (strong, nonatomic)UISlider *volumeSlider;


@property (nonatomic, copy)ClickFullScreenBtnBlock clickFullScreenBtnBlock;
- (void)clickFullScreenBtnWithBlock:(ClickFullScreenBtnBlock)block;



- (void)playerTimerAction;
- (void)addObserver;

- (void)playerPlay;

- (void)playerPause;

- (void)hiddenViews;
@end
