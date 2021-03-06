//
//  HJGVideoPlayController.m
//  战旗TV
//
//  Created by 黄建国 on 2016/9/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "HJGVideoPlayController.h"
#import <AVFoundation/AVFoundation.h>
#import "HJGPlayVideoView.h"
#import<MediaPlayer/MediaPlayer.h>
#import<CoreMedia/CoreMedia.h>
#import "HJGVideoPlaySelectedView.h"
#import "HJGVideoPlayMenueView.h"
@interface HJGVideoPlayController ()<HJGVideoPlaySelectedViewDelegate,HJGVideoPlayMenueViewDelegate>

@property (nonatomic ,strong)AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic ,strong) HJGPlayVideoView *playerView;
@property (nonatomic ,strong)  UIButton  *swtichBtn;
@property (nonatomic, assign) CATransform3D myTransform;
@property (nonatomic, strong) HJGVideoPlaySelectedView *selectedView;
@property (nonatomic, strong) HJGVideoPlayMenueView *menueView;
//横屏缩回按钮
@property (nonatomic, strong) UIButton *backSwtichBut;

@end

@implementation HJGVideoPlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    [self createBasicConfig];
    [self playVideo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self hiddenNaviGation];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.alpha = 1;
}

#pragma mark - 设置导航栏隐藏
- (void)hiddenNaviGation{
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - 播放视频
- (void)playVideo{
    NSString *filePath = [NSString stringWithFormat:@"%@%@.m3u8",VIDEO_URL , self.videoID];
    filePath=[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *videoUrl = [NSURL URLWithString: filePath];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView.player = _player;
    [self.playerView.player play];
    
}

- (void)createBasicConfig{
    
    _playerView=[[HJGPlayVideoView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 320)];
    _myTransform = _playerView.layer.transform;
    [self.view addSubview: _playerView];
    
    //初始化选择view
    self.selectedView = [[HJGVideoPlaySelectedView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.playerView.frame) - H(33), WIDTH,H(25))];
    self.selectedView.backgroundColor = [UIColor whiteColor];
    self.selectedView.delegate = self;
    [self.view addSubview:self.selectedView];
    
    //初始化下方菜单内容view
    self.menueView = [[HJGVideoPlayMenueView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.selectedView.frame), WIDTH, HEIGHT - H(100))];
    self.menueView.delegate = self;
    [self.view addSubview:self.menueView];
    
    _swtichBtn  =  [UIButton ButtonWithRect:CGRectMake(WIDTH - 44, 240 , 44, 44) title:@"" titleColor:[UIColor whiteColor] BackgroundImageWithColor:[UIColor clearColor] clickAction:@selector(swtichTouch) viewController:self titleFont:14 contentEdgeInsets:UIEdgeInsetsZero];
    [_swtichBtn setImage:[UIImage imageNamed:@"movie_fullscreen"] forState:UIControlStateNormal];
    [self.view addSubview:_swtichBtn];
    
    _backSwtichBut = [UIButton ButtonWithRect:CGRectMake(44, HEIGHT - 60, 44, 44) title:@"缩小" titleColor:[UIColor whiteColor] BackgroundImageWithColor:[UIColor clearColor] clickAction:@selector(backSwtichTouch) viewController:self titleFont:14 contentEdgeInsets:UIEdgeInsetsZero];
    [_backSwtichBut setImage:[UIImage imageNamed:@"movie_fullscreen"] forState:UIControlStateNormal];
    [self.view addSubview:_backSwtichBut];
    _backSwtichBut.hidden = YES;
    
}


//因为想要手动旋转，所以先关闭自动旋转
- (BOOL)shouldAutorotate{
    return NO;
}

#pragma mark - 放大
- (void)swtichTouch{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _playerView.frame = CGRectMake(0, 0, HEIGHT, WIDTH);
    _swtichBtn.hidden=YES;
    _backSwtichBut.hidden = NO;
    self.selectedView.hidden = YES;
    self.menueView.hidden = YES;
    self.navigationController.navigationBarHidden=YES;
    
    //旋转屏幕，但是只旋转当前的View
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    _playerView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _playerView.center = self.view.center;
    
}


#pragma mark - 缩小
- (void)backSwtichTouch{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    _swtichBtn.hidden = NO;
    _backSwtichBut.hidden = YES;
    self.selectedView.hidden = NO;
    self.menueView.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    
    //旋转屏幕，但是只旋转当前的View
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
    _playerView.transform = CGAffineTransformIdentity;
    _playerView.frame = CGRectMake(0, 0, WIDTH, 320);
    
}

- (void)selectedView:(HJGVideoPlaySelectedView *)selectedView int:(NSInteger)butTag{
    [self.menueView setScrollViewOffset:CGPointMake(butTag * WIDTH, 0)];
}


#pragma mark - playMenueView delegate
- (void)playMenueView:(HJGVideoPlayMenueView *)playMenueView contentOffsetX:(CGFloat)offsetX{
    if (offsetX == 0) {
        [self.selectedView setTiaoViewFrame:CGRectMake(0, H(20), WIDTH/4.0, H(5))];
    }else if (offsetX == WIDTH){
        [self.selectedView setTiaoViewFrame:CGRectMake(WIDTH/4.0, H(20), WIDTH/4.0, H(5))];
    }else if(offsetX == WIDTH*2){
        [self.selectedView setTiaoViewFrame:CGRectMake(WIDTH *2.0/4.0, H(20), WIDTH/4.0, H(5))];
    }else if(offsetX == WIDTH *3){
        [self.selectedView setTiaoViewFrame:CGRectMake(WIDTH *3/4.0, H(20), WIDTH/4.0, H(5))];
    }else{
    }
}

@end


