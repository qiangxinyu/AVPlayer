//
//  XYAVControl.m
//  AVPlayer
//
//  Created by 强新宇 on 16/8/16.
//  Copyright © 2016年 强新宇. All rights reserved.
//

#import "XYAVControlView.h"


@interface XYAVControlView () <UIGestureRecognizerDelegate>

@end

@implementation XYAVControlView
+ (XYAVControlView *)getXYAVControlView
{
    return [[NSBundle mainBundle] loadNibNamed:@"XYAVControlView" owner:self options:nil].firstObject;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureVolume];
    
    
    UITapGestureRecognizer * screenTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(screenTap)];
    [self addGestureRecognizer:screenTap];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    pan.delegate = self;
    
    [_adjustView addGestureRecognizer:pan];
    
    
    [self.slider setThumbImage:[UIImage imageNamed:@"verify_code_button"] forState:UIControlStateNormal];
    
    // slider开始滑动事件
    [_slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [_slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    // slider 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sliderTap:)];
    [_slider addGestureRecognizer:tap];
    
    
    [self hiddenViews];

}



#pragma mark -------------------------------------------------------------
#pragma mark  Mehotd
- (void)playerTimerAction
{
    __weak XYAVControlView * weakSelf = self;
    
    [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float current=CMTimeGetSeconds(time);
        if (current) {
            //当前播放进度
            weakSelf.currentTimeLabel.text = [weakSelf timeFormatterForServiceWithTimeStamp:CMTimeGetSeconds(weakSelf.avPlayerItem.currentTime)];
            //滑块进度
            double totalTempTime = CMTimeGetSeconds(weakSelf.avPlayerItem.duration);
            double scale = CMTimeGetSeconds(weakSelf.avPlayerItem.currentTime) / totalTempTime;
            weakSelf.slider.value = scale;
        }
    }];
}


/**
 *  重置播放器初始状态
 */
- (void)playerReset {
    
    
    
    self.currentTimeLabel.text = @"00:00:00";
    self.allTimeLabel.text = @"00:00:00";
    self.progressView.progress = 0.00;
    self.slider.value = 0.00;
    _playBtn.highlighted = NO;
    
    
    [self seekWithTime:0];
    
}

/**
 *  播放
 */
- (void)playerPlay {
    
    [self.avPlayer play];
    _playBtn.selected = YES;
}

/**
 *  暂停
 */
- (void)playerPause {
    
    [self.avPlayer pause];
    _playBtn.selected = NO;
}

/**
 *  隐藏子控件
 */
- (void)hiddenViews {
    
    [self performSelector:@selector(hiddenViewsAction) withObject:self afterDelay:4];
    
}

/**
 *  隐藏子空间Action
 */
- (void)hiddenViewsAction {
    
    self.controlStripView.hidden = YES;
    
}

/**
 *  显示子控件
 */
- (void)showViews {
    
    self.controlStripView.hidden = NO;

}


- (NSString *)timeFormatterForServiceWithTimeStamp:(NSTimeInterval )timeStamp {
    
    //四舍五入
    timeStamp = (int)(timeStamp + .5);
    
    
    NSTimeInterval time = timeStamp - 28800;
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    
    return currentDateStr;
    
}


- (void)seekWithTime:(double)time
{
    CMTime durationTime = self.avPlayerItem.duration;
    
    [self.avPlayerItem seekToTime:CMTimeMakeWithSeconds(time,durationTime.timescale) toleranceBefore:CMTimeMake(1, durationTime.timescale) toleranceAfter:CMTimeMake(1, durationTime.timescale)];
    
}

/**
 *  获取系统音量
 */
- (void)configureVolume {
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
    
}

- (void)clickFullScreenBtnWithBlock:(ClickFullScreenBtnBlock)block
{
    self.clickFullScreenBtnBlock = block;
}

#pragma mark -------------------------------------------------------------
#pragma mark Click Method 
- (IBAction)clickPlayBtn:(UIButton *)sender {
    !sender.selected ? [self playerPlay] : [self playerPause];
}
- (IBAction)clickFullScreenBtn:(id)sender {
    [self hiddenViews];
    !self.clickFullScreenBtnBlock?:self.clickFullScreenBtnBlock(self);
}

#pragma mark -------------------------------------------------------------
#pragma mark Pan GesTure

- (void)panGestureRecognizerAction: (UIPanGestureRecognizer *)sender {
    
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [sender locationInView:self];
    
    CGPoint veloctyPoint = [sender velocityInView:self];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            
            if (x > y) { //水平移动
                [self showViews];
                [self playerPause];
                self.pandirection = PanDirectionHorizontalMoved;
            }else { //垂直移动
                self.pandirection = PanDirectionVerticalMoved;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            switch (_pandirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x];
                    break;
                }
                case PanDirectionVerticalMoved:{
                    if (locationPoint.x > self.bounds.size.width / 2) {//音量调节-右侧
                        [self verticalMovedForVolume:veloctyPoint.y];
                    }else {//亮度调节-左侧
                        [self verticalMovedForBrightness:veloctyPoint.y];
                    }
                    break;
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{
            switch (_pandirection) {
                case PanDirectionHorizontalMoved:{
                    [self hiddenViews];
                    [self playerPlay];
                    break;
                }
                case PanDirectionVerticalMoved:{
                    break;
                }
            }
            break;
        }
        default:break;
    }
}

/**
 *  水平滑动
 *
 *  @param value 水平滑动value
 */
- (void)horizontalMoved:(CGFloat)value {
    
    //进度
    CGFloat tempValue = value / 100000;
    NSTimeInterval progressTime = CMTimeGetSeconds(self.avPlayerItem.duration) * tempValue + CMTimeGetSeconds(self.avPlayerItem.currentTime);
    //当前时间
    NSString * tempCurrentTime = [self timeFormatterForServiceWithTimeStamp:progressTime];
    
    if (progressTime >= 0) {
        CMTime durationTime = self.avPlayerItem.duration;
        
        
        [self seekWithTime:progressTime];
        
        self.changeTimeLabel.text = tempCurrentTime;
        self.currentTimeLabel.text = tempCurrentTime;
        
        //滑块进度
        double totalTempTime = CMTimeGetSeconds(durationTime);
        double scale = progressTime / totalTempTime;
        self.slider.value = scale;
        
    }
}
/**
 *  垂直滑动 - 音量调节
 *
 *  @param value 垂直滑动value
 */
- (void)verticalMovedForVolume:(CGFloat)value {
    
    self.volumeSlider.value -= value / 10000;
    
}

/**
 *  垂直滑动 - 亮度调节
 *
 *  @param value 垂直滑动value
 */
- (void)verticalMovedForBrightness: (CGFloat)value {
    
    [UIScreen mainScreen].brightness -= value / 10000;
    
}


#pragma mark -------------------------------------------------------------
#pragma mark Slider Method

/**
 *  滑块相关方法
 *
 */
- (void)progressSliderTouchBegan: (UISlider *)sender {
    
    self.changeTimeLabel.hidden = NO;
    
    [self playerPause];
    
    
    NSLog(@" --- began touch");
}

- (void)progressSliderValueChanged: (UISlider *)sender {
    
    CGFloat currentTime = sender.value * CMTimeGetSeconds(self.avPlayerItem.duration);
    
    NSString *tempCurrentTime = [self timeFormatterForServiceWithTimeStamp:currentTime];
    
    //当前播放时间
    self.currentTimeLabel.text = tempCurrentTime;
    
    //屏幕中间时间
    self.changeTimeLabel.text = tempCurrentTime;
    
    
    CGFloat sliderProgress = sender.value / sender.maximumValue;
    
    if (self.progressView.progress < sliderProgress) {
        self.progressView.progress = sender.value / sender.maximumValue;
    }
    
    
    
    NSLog(@" --- event touch  %f",sender.value);
    
    
}

- (void)progressSliderTouchEnded: (UISlider *)sender {
    
    
    CMTime durationTime = self.avPlayerItem.duration;
    
    NSTimeInterval currentTime = CMTimeGetSeconds(durationTime) * sender.value;
    
    [self seekWithTime:currentTime];
    
    self.changeTimeLabel.hidden = YES;
    
    [self playerPlay];
    
    
    NSLog(@" ---- end touch");
}

/**
 *  Slider Tap
 */
- (void)sliderTap: (UITapGestureRecognizer *)sender {
    
    if ([sender.view isKindOfClass:[UISlider class]]) {
        
        UISlider *slider = (UISlider *)sender.view;
        CGPoint point = [sender locationInView:slider];
        CGFloat length = slider.frame.size.width;
        
        CGFloat tempValue = point.x / length;
        
        NSTimeInterval currentTime = CMTimeGetSeconds(self.avPlayerItem.duration) * tempValue;
        
        CGFloat progress = currentTime/CMTimeGetSeconds(self.avPlayerItem.duration);
        
        if (progress > slider.value) {
            self.progressView.progress = progress;
        }
        
        
        [self seekWithTime:currentTime];
    }
    
}


#pragma mark -------------------------------------------------------------
#pragma mark Screen Tap

- (void)screenTap {
    self.controlStripView.hidden = !self.controlStripView.hidden;
}


#pragma mark -------------------------------------------------------------
#pragma mark KVO & Notification

- (void)addObserver
{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [self.avPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [self.avPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    /**
     *  进入后台  暂停播放
     *
     */
    [kNotificationCenter addObserver:self selector:@selector(applicationDidEnterBackground_Notification) name:ApplicationDidEnterBackground_Notification object:nil];
    
    /**
     *  进入活跃状态  继续播放
     *
     */
    [kNotificationCenter addObserver:self selector:@selector(applicationDidBecomeActive_Notification) name:ApplicationDidBecomeActive_Notification object:nil];
    
    [kNotificationCenter addObserver:self selector:@selector(playerReset) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}

- (void)applicationDidEnterBackground_Notification
{
    [self playerPause];
}
- (void)applicationDidBecomeActive_Notification
{
    [self playerPlay];
}

- (void)removeObserver
{
    [self.avPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.avPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    
    [kNotificationCenter removeObserver:self];
}
/** * 通过KVO监控播放器状态 *
 * @param keyPath 监控属性
 * @param object 监视器
 * @param change 状态改变
 * @param context 上下文 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            //总时长
            self.allTimeLabel.text = [self timeFormatterForServiceWithTimeStamp:CMTimeGetSeconds(playerItem.duration)];
            self.currentTimeLabel.text = @"00:00:00";
            
            
//            [self.beginView removeFromSuperview];
            
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }
    else if([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
        double ableScale = totalBuffer / CMTimeGetSeconds(playerItem.duration);
        if (ableScale <= 1) {
            self.progressView.progress = ableScale;
        }
    }
}


@end
