# AVPlayer

`AVPlayer` 是一个强大的视频播放器，可以播放多种格式的视频，缺点是没有控制界面，需要自己去实现。

效果图
![AVPlayer](https://github.com/qiangxinyu/blogImages/blob/master/AVPlayer/avplayer.gif?raw=true)

[项目地址](https://github.com/qiangxinyu/AVPlayer)

  
先看下它的结构

![overview](https://github.com/qiangxinyu/blogImages/blob/master/AVPlayer/Overview.png?raw=true)
首先初始化播放器，设置播放URL。

```objectivec
self.avPlayerView = [[XYAVPlayerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, VIDEO_HEIGHT)];
self.avPlayerView.videoUrl = m3u;
[self.view addSubview:self.avPlayerView];
```

初始化方法，添加一个视频控制器。
```objectivec

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.playControlView];
    }
    return self;
}
```
设置视频URL

```objectivec

- (void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl = videoUrl.copy;
    [self createAVPlayer];

}
```

初始化` AVPlayer`，给`_playControlView` 引用`AVPlayer`，方便进行控制， `[_playControlView addObserver];`和`  [_playControlView playerTimerAction];`会在后面说明。
```objectivec

- (void)createAVPlayer
{
    
    NSURL *url = [NSURL URLWithString:self.videoUrl];
    if (!url) {
        return;
    }
  

    /**
     *  AVPlayer
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
```

到这里只是创建了一个View，上面加载了一个AVPlayer，一个视频控制器视图。

视频控制器代码：
我用的`xib`创建的View，所以初始化方法是`awakeFromNib`

```objectivec

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
```

```objectivec

/**
 *  获取系统音量
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
```

第一个手势`screenTap`，是控制下方控制条的显示与隐藏的
```objectivec
- (void)screenTap {
    self.controlStripView.hidden = !self.controlStripView.hidden;
}
```
第二个手势则是用来控制快进、快退、音量、亮度调节的
```objectivec
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
```

对于`slider`的方法，在开始手势的时候暂停视频播放，显示时间`label`
```objectivec

- (void)progressSliderTouchBegan: (UISlider *)sender {
    
    self.changeTimeLabel.hidden = NO;
    
    [self playerPause];
    
    
    NSLog(@" --- began touch");
}
```
在开始手势的时候seek到`slider`对应时间的时间点，然后开始视频播放，隐藏时间`label`
```objectivec

- (void)progressSliderTouchEnded: (UISlider *)sender {
    CMTime durationTime = self.avPlayerItem.duration;
    
    NSTimeInterval currentTime = CMTimeGetSeconds(durationTime) * sender.value;
    
    [self seekWithTime:currentTime];
    
    self.changeTimeLabel.hidden = YES;
    
    [self playerPlay];
    
    
    NSLog(@" ---- end touch");
}
```


在 `slider`滑动的时候，只是改变`label`上显示的时间
```objectivec

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
    
    
    
    NSLog(@" --- event touch  %f",sender.value);
    
    
}
```

`slider`的单击方法则是直接seek到对应时间点，`AVPlayer`会自动处理的。
```objectivec

/**
 *  Slider Tap
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
```

前面用的 `addObserver`方法，则是给播放器添加观察者，用来检测播放器状态，还有APP的状态。
```objectivec

- (void)addObserver
{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [self.avPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [self.avPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    /**
     *  进入后台  暂停播放
     *
     */
    [kNotificationCenter addObserver:self selector:@selector(applicationDidEnterBackground_Notification) name:ApplicationDidEnterBackground_Notification object:nil];
    
    /**
     *  进入活跃状态  继续播放
     *
     */
    [kNotificationCenter addObserver:self selector:@selector(applicationDidBecomeActive_Notification) name:ApplicationDidBecomeActive_Notification object:nil];
    
    [kNotificationCenter addObserver:self selector:@selector(playerReset) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
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
```

`playerTimerAction`方法则是制定每秒进行一次返回，返回当前播放进度。
```objectivec

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
```


最后在 `ViewController` 里面监控屏幕方向的变化，来处理全屏效果


```objectivec

[kNotificationCenter  addObserver:self
                             selector:@selector(onDeviceOrientationChange)
                                 name:UIDeviceOrientationDidChangeNotification
                               object:nil];






/**
 *  屏幕方向发生变化会调用这里
 */
- (void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation             = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:{
            self.view.frame = (CGRect){0,0,ScreenWidth,ScreenHeight};
            self.avPlayerView.frame = CGRectMake(0, 0,ScreenWidth,VIDEO_HEIGHT);
            self.avPlayerView.playControlView.isFullScreen = NO;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:{
            self.view.frame = (CGRect){0,0,ScreenWidth,ScreenHeight};
            self.avPlayerView.frame = self.view.bounds;
            self.avPlayerView.playControlView.isFullScreen = YES;
            break;
        }
        default:
            break;
    }
}
```

到这里一个简单的视频播放器就做完了。
