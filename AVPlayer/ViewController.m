//
//  ViewController.m
//  AVPlayer
//
//  Created by 强新宇 on 16/8/16.
//  Copyright © 2016年 强新宇. All rights reserved.
//

#import "ViewController.h"
#import "XYAVPlayerView.h"
#define VIDEO_HEIGHT (0.565 * ScreenWidth)

@interface ViewController ()

@property (strong, nonatomic) XYAVPlayerView *avPlayerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString * m3u_4 = @"http://pl.youku.com/playlist/m3u8?vid=XMTY3MzQwOTM1Ng==&type=mp4&ts=1470795311&keyframe=0&ep=dCaTGk6EU80A4ybcjT8bYSm3dHcHXJZ3knaG%2FJgDR8RANenBzjPcqJ%2B5TPY%3D&sid=64707953065351265e008&token=2929&ctype=12&ev=1&oip=3722188266";
    
    
    NSString * m3u1 = @"http://www.wsp360.org/play/1.m3u8?clarityType=HIGH&Expires=1471861206&OSSAccessKeyId=8078zo0Yx82VoUi0&Signature=LF0cjzRUfd2E4o%2BzwtDQ5wnsFj8%3D";
    
    
    NSString * mp4 = @"http://wsp360-output-test.oss-cn-hangzhou.aliyuncs.com/vod/77126ad141fa47099a10ee46e99fbcf5/MP4/HIGH/70c5b3cd3acc63f72501a100bdc00371--.mp4?Expires=1471861423&OSSAccessKeyId=8078zo0Yx82VoUi0&Signature=%2B1vgN4mV7d9E4gtAGr0xVmmO0/g%3D";
    
    NSString * m3u = @"http://pl-dxk.youku.com/playlist/m3u8?vid=XMTY5MTcyMzUwOA==&type=mp4&ts=1471779649&keyframe=0&ep=dyaTG06KX8gE4ifZij8bMi3mdSIOXJZ3knaA%252FLYxScZuLa%252FA6DPcqJ%252B1T%252Fs%253D&sid=547177964746212e141e1&token=2514&ctype=12&ev=1&oip=3056762236";

    
    self.avPlayerView = [[XYAVPlayerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, VIDEO_HEIGHT)];
    self.avPlayerView.videoUrl = m3u;
    [self.view addSubview:self.avPlayerView];
    
    
    [self.avPlayerView.playControlView clickFullScreenBtnWithBlock:^(XYAVControlView *avControlView) {
        

        avControlView.isFullScreen = !avControlView.isFullScreen;
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            
            SEL selector             = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = avControlView.isFullScreen ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
            // 从2开始是因为0 1 两个参数已经被selector和target占用
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
            //项目必须支持 UIInterfaceOrientationLandscapeRight
            
        }
    }];
    
    
    [kNotificationCenter  addObserver:self
                             selector:@selector(onDeviceOrientationChange)
                                 name:UIDeviceOrientationDidChangeNotification
                               object:nil
     ];
}


/**
 *  屏幕方向发生变化会调用这里
 */
- (void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation             = [UIDevice currentDevice].orientation;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
