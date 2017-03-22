//
//  ZWPlayViewController.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWPlayViewController.h"
#import "Masonry.h"
#import "ZWMusicTool.h"
#import "ZWAudioTool.h"
#import "NSString+ZWTime.h"
#import "CALayer+PauseAimate.h"
#import "ZWLrcScrollView.h"

#import <MediaPlayer/MediaPlayer.h>

#define ZWColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
@interface ZWPlayViewController ()<UIScrollViewDelegate,AVAudioPlayerDelegate>

/**歌手背景图片*/
@property (weak, nonatomic) IBOutlet UIImageView *albumView;
/**进度条*/
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
/**旋转图片*/
@property (weak, nonatomic) IBOutlet UIImageView *rotateImageView;
/*歌曲名*/
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
/*歌手名*/
@property (weak, nonatomic) IBOutlet UILabel *signerLabel;
/*当前播放时间*/
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
/*总时间*/
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
/*进度条更新定时器 一秒钟调用一次*/
@property(nonatomic,strong)NSTimer *progressTimer;
/*歌词的定时器 一秒钟调用60次*/
@property(nonatomic,strong)CADisplayLink *lrcTimer;
/*当前播放器*/
@property(nonatomic,strong)AVAudioPlayer *currentPlayer;

/*显示歌词的scrollView*/
@property (weak, nonatomic) IBOutlet ZWLrcScrollView *lrcScrollVIew;
/*歌词label*/
@property (weak, nonatomic) IBOutlet ZWLrcLabel *lrcLabel;

/*播放按钮*/
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation ZWPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    
    //1.设置毛玻璃
    [self setupBlur];
    //2.设置滑块图片   sb中无法设置
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateSelected];
    /*
     旋转图片添加圆角
     //这里的设置之所以不起作用，因为self.rotateImageView.bound并不是当前屏幕显示的大小，而是sb中实际的大小。为了解决这个问题，应该在viewWillLayoutSubviews写以下代码
     self.rotateImageView.layer.cornerRadius = self.rotateImageView.bounds.size.width/2.0;
    self.rotateImageView.clipsToBounds = YES;
    self.rotateImageView.layer.borderColor = ZWColor(36, 36, 36, 1.0).CGColor;
    self.rotateImageView.layer.borderWidth = 5;
     */

    /***************************************************/
    
    //3.将ZWLrcScrollView中的lrcLabel设置为主控制器的lrcLabel
    //将主界面的lrcLabel传递给ZWLrcScrollView，在ZWLrcScrollView这个类中设置主界面lrcLabel的内容，因为里面有定时器的方法。 但是要在开始播放音乐之前，因为要提前设置主界面的歌词内容
    self.lrcScrollVIew.lrcLabel = self.lrcLabel;
    
  //4.开始播放音乐
   [self startPlayingMusic];
  //5.slider事件
    [self.progressSlider addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchDown];
    
    [self.progressSlider addTarget:self action:@selector(end) forControlEvents:UIControlEventTouchUpInside];
    [self.progressSlider addTarget:self action:@selector(end) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.progressSlider addTarget:self action:@selector(progressValueChange) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sliderClick:)];
    [self.progressSlider addGestureRecognizer:tap];
   //6.设置歌词界面
    self.lrcScrollVIew.contentSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
    self.lrcScrollVIew.delegate = self;
    self.lrcScrollVIew.showsHorizontalScrollIndicator = NO;
    self.lrcScrollVIew.bounces = NO;
    //***********************************
    //7.接受进入前台开始旋转动画的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addIconViewAnimate) name:@"RotationImageViewNotification" object:nil];
}

#pragma mark-开始播放音乐
- (void)startPlayingMusic{
    //0.清除之前的歌词
    //??????????
    self.lrcLabel.text = @"";
    
    //1.获取当前正在播放的音乐
    ZWMusicModel *playingMusic = [ZWMusicTool playingMusic];
    //2.设置界面信息
    self.albumView.image = [UIImage imageNamed:playingMusic.icon];
    self.songLabel.text = playingMusic.name;
    self.signerLabel.text = playingMusic.singer;
    self.rotateImageView.image = [UIImage imageNamed:playingMusic.icon];
    //3.正式开始播放音乐
    AVAudioPlayer *currentPlayer =  [ZWAudioTool playMusicWithFileName:playingMusic.filename];
    currentPlayer.delegate = self;
    self.currentTimeLabel.text = [NSString stringWithTime:currentPlayer.currentTime];
    self.totalTimeLabel.text = [NSString stringWithTime:currentPlayer.duration];
    self.currentPlayer = currentPlayer;
      //3.1、设置播放按钮状态
    self.playButton.selected = self.currentPlayer.isPlaying;
      //3.2设置歌词
    self.lrcScrollVIew.lrcName = playingMusic.lrcname;
    self.lrcScrollVIew.duration = self.currentPlayer.duration;
   
    //4.开启进度条和歌词定时器  开启之前先移除上一曲播放的定时器
    [self removeProgressTimer];
    [self addProgressTimer];
    
    [self removeLrcTimer];
    [self addLrcTimer];
    //5.添加旋转动画
    [self addIconViewAnimate];
    //6.设置锁屏界面信息
//    [self setupLockScreenInfo];
}
#pragma mark - 添加旋转动画
- (void)addIconViewAnimate{
    
    CABasicAnimation *rotateAnimate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimate.fromValue = @(0);
    rotateAnimate.toValue = @(M_PI * 2);
    rotateAnimate.repeatCount = MAXFLOAT;
    rotateAnimate.duration = 35;
    [self.rotateImageView.layer addAnimation:rotateAnimate forKey:nil];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"iconViewAnimate"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

/****************************/
//设置毛玻璃
- (void)setupBlur{
    //设置毛玻璃的另外一种方式，通过添加在ImageView上添加toolBar来实现iOS7也可以使用
    //这是什么意思？？？？设置毛玻璃？？？？
    UIToolbar *toolBar =[[UIToolbar alloc]init];
    [self.albumView addSubview:toolBar];
    toolBar.barStyle = UIBarStyleBlack;
    //约束和translatesAutoresizingMask是有冲突的，所以要去掉
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.albumView);
    }];
}

/***************************************/
//这个方法在加载sb时会调用一次，加载控制器也会再次调用
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.rotateImageView.layer.cornerRadius = self.rotateImageView.frame.size.width/2.0;
    self.rotateImageView.clipsToBounds = YES;
    self.rotateImageView.layer.borderColor = ZWColor(36, 36, 36, 1.0).CGColor;
    self.rotateImageView.layer.borderWidth = 5;
}
#pragma mark -对歌词定时器处理
- (void)addLrcTimer{
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcInfo)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
-(void)removeLrcTimer{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}
#pragma mark- 更新歌词
- (void)updateLrcInfo{
    //播放器当前时间传递给歌词界面
    self.lrcScrollVIew.currentTime = self.currentPlayer.currentTime;
}

#pragma mark -对进度条定时器处理
- (void)addProgressTimer{
    [self updateProgressInfo];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}
- (void)removeProgressTimer{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}
#pragma mark -更新进度条
- (void)updateProgressInfo{
    //1.更新播放时间
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    //2.更新滑动条
    self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
    
}
#pragma mark - slider事件处理
- (void)start{
    //开始拖动，先移除定时器
    [self removeProgressTimer];
}
-(void)end{
    //1.更新播放时间
    self.currentPlayer.currentTime = self.progressSlider.value * self.currentPlayer.duration;
    //2.结束拖动，添加定时器
    [self addProgressTimer];
}
-(void)progressValueChange{
    //滑动的时候更新时间
    self.currentTimeLabel.text = [NSString stringWithTime:self.progressSlider.value * self.currentPlayer.duration];
}
- (void)sliderClick:(UITapGestureRecognizer *)tap{
    //1.获取点击的点
    CGPoint point = [tap locationInView:tap.view];
    //2.获取点击的比例
    CGFloat ratio = point.x / self.progressSlider.bounds.size.width;
    //3.更新播放时间
    self.currentPlayer.currentTime = self.currentPlayer.duration * ratio;
    //4.更新显示时间和滑块的位置
    [self updateProgressInfo];
}
#pragma mark- 播放按钮点击事件,不涉及播放和暂停，但是时间要对应
- (IBAction)playOrPause:(UIButton *)sender {
    self.playButton.selected = !self.playButton.selected;
    if(self.currentPlayer.isPlaying){
        //1.停止播放
        [self.currentPlayer pause];
        //2.移除定时器
        [self removeProgressTimer];
        //3.暂停动画
        [self.rotateImageView.layer pauseAnimate];
    }else{
        //1.开始播放
        [self.currentPlayer play];
        //2.添加定时器
        [self addProgressTimer];
        //3.开始动画
        [self.rotateImageView.layer resumeAnimate];
    }
}
- (IBAction)previous:(UIButton *)sender {
    //1.获取上一首歌
    ZWMusicModel *previousMusic = [ZWMusicTool previousMusic];
    //2.播放
    [self playMusicWithMusic:previousMusic];
}
- (IBAction)next:(UIButton *)sender {
    //1.获取上一首歌
    ZWMusicModel *nextMusic = [ZWMusicTool nextMusic];
    //2.播放
    [self playMusicWithMusic:nextMusic];
}
-(void)playMusicWithMusic:(ZWMusicModel *)music{
    //1.获取当前播放的歌曲,并停止
    ZWMusicModel *currentMusic = [ZWMusicTool playingMusic];
    [ZWAudioTool stopMusicWithFileName:currentMusic.filename];
    //2.设置music为默认歌曲
    [ZWMusicTool setupPlayingMusic:music];
    //3.播放音乐，并更新界面信息
    [self startPlayingMusic];
}
#pragma mark - UIScrollViewDelegate代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //1.获取偏移量
    CGPoint point = scrollView.contentOffset;
    //2.获取滑动比例
    CGFloat alpha = 1- point.x / scrollView.bounds.size.width;
    //3.设置alpha
    self.rotateImageView.alpha = alpha;
    self.lrcLabel.alpha = alpha;
}
#pragma mark - AVAudioPlayerDelegate播放器代理方法
//播放完毕的代理方法 播放完毕后，自动播放下一曲
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        [self next:self.nextButton];
    }
}


#pragma mark -改变状态栏
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark-移除通知
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - ****设置锁屏信息****
/*- (void)setupLockScreenInfo{
 
     // MPMediaItemPropertyAlbumTitle
     // MPMediaItemPropertyAlbumTrackCount
     // MPMediaItemPropertyAlbumTrackNumber
     // MPMediaItemPropertyArtist
     // MPMediaItemPropertyArtwork
     // MPMediaItemPropertyComposer
     // MPMediaItemPropertyDiscCount
     // MPMediaItemPropertyDiscNumber
     // MPMediaItemPropertyGenre
     // MPMediaItemPropertyPersistentID
     // MPMediaItemPropertyPlaybackDuration
     // MPMediaItemPropertyTitle
 
    //0.获取当前播放的歌曲
    ZWMusicModel *playingMusic = [ZWMusicTool playingMusic];
    //1.获取锁屏中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    //2、设置屏幕参数
    NSDictionary *playingInfoDict = [NSMutableDictionary dictionary];
    //2.1设置歌曲名
    [playingInfoDict setValue:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle];
    //2.2设置歌手名
    [playingInfoDict setValue:playingMusic.singer forKey:MPMediaItemPropertyArtist];
    //2.3设置封面图片
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc]initWithImage:[UIImage imageNamed:playingMusic.icon]];
     [playingInfoDict setValue:artWork forKey:MPMediaItemPropertyArtwork];
    //2.4歌曲的总时长
    [playingMusic setValue:@(self.currentPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    
    playingInfoCenter.nowPlayingInfo = playingInfoDict;
    //3.开启远程交互
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
}
*/

#pragma mark - 后台音乐播放切换的远程交互
//系统方法
- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    /*
     UIEventSubtypeRemoteControlPlay                 = 100,
     UIEventSubtypeRemoteControlPause                = 101,
     UIEventSubtypeRemoteControlStop                 = 102,
     UIEventSubtypeRemoteControlTogglePlayPause      = 103,
     UIEventSubtypeRemoteControlNextTrack            = 104,
     UIEventSubtypeRemoteControlPreviousTrack        = 105,
     UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
     UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
     UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
     UIEventSubtypeRemoteControlEndSeekingForward    = 109,
     */
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause:self.playButton];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next:self.nextButton];
            break;
            
        case  UIEventSubtypeRemoteControlPreviousTrack:
            [self next:self.previousButton];
            break;
            
        default:
            break;
    }
}


@end
