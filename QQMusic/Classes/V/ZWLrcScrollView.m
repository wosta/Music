//
//  ZWLrcScrollView.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWLrcScrollView.h"
#import "Masonry.h"
#import "ZWLrcCell.h"
#import "ZWLrcTool.h"
#import "ZWLrcModel.h"
#import "ZWMusicTool.h"
#import "ZWMusicModel.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ZWLrcScrollView ()
@property(nonnull,strong)UITableView *tableView;

@property(nonatomic,strong)NSArray *lrcList;
@end

@implementation ZWLrcScrollView
/***************************************/
//从SB创建时，会调用这个方法，而不是init方法,但是为了两种方式都采取，一般两个方法都会写
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self == [super initWithCoder:aDecoder]) {
        //初始化tableView
        [self setupTableView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        //初始化tableView
        [self setupTableView];
    }
    return self;
}
- (void)setupTableView{
    UITableView *tableView = [[UITableView alloc]init];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self addSubview:tableView];
    self.tableView = tableView;
    //去除tableView的上下滑动的背景色，有一点要注意：当tableView上有数据时，才会起作用。所以这里不起作用，在layoutSubviews中才有作用。
    self.tableView.backgroundColor = [UIColor clearColor];
    //去掉tableView的线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.rowHeight = 40;
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
   
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(self.mas_height);
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left).offset(self.bounds.size.width);
        make.width.equalTo(self.mas_width);
    }];
    //去除tableView的上下滑动的背景色，有一点要注意：当tableView上有数据时，才会起作用
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    /*****************************/
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.bounds.size.height * 0.5, 0, self.tableView.bounds.size.height * 0.5, 0);
    
}

#pragma mark -tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lrcList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZWLrcCell *cell = [ZWLrcCell lrcCellWithTableView:tableView];
    if (self.currentIndex == indexPath.row) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:20];
    }else{
         cell.lrcLabel.font = [UIFont systemFontOfSize:14];
         cell.lrcLabel.progress = 0;
    }
    //取出数据模型
    ZWLrcModel *lrcLineModel = self.lrcList[indexPath.row];
    cell.lrcLabel.text = lrcLineModel.text;
//    cell.textLabel.text = [NSString stringWithFormat:@"测试%ld",indexPath.row];
    return cell;
}
#pragma mark - 重写lrcName set方法（歌词静态界面布局）
- (void)setLrcName:(NSString *)lrcName{
    //-1.让tableView滚动到中间
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.bounds.size.height * 0.5) animated:YES];
    //0.将currentIndex置为0，否则在切换歌曲的时候可能出现越界导致崩溃
    self.currentIndex = 0;
    //1.记录歌词名
    _lrcName = lrcName;
    //2.解析歌词
    self.lrcList = [ZWLrcTool lrcToolWithLrcName:_lrcName];
    //2.1设置第一句歌词
    /*********************/
    //解决首次进入主界面不显示内容
    ZWLrcModel *firstLrcLineModel = self.lrcList[0];
    self.lrcLabel.text = firstLrcLineModel.text;
    //3.刷新表格
    [self.tableView reloadData];
}

#pragma mark - 重写currentTime set方法 定时器时时调用
-(void)setCurrentTime:(NSTimeInterval)currentTime{
    //1.记录当前播放的时间
    _currentTime = currentTime;
    //2.判断显示那一句歌词
    NSInteger count = self.lrcList.count;
    for (NSInteger i = 0; i < count; i++) {
        //2.1取出当前的歌词
        ZWLrcModel *currentLrcLineModel = self.lrcList[i];
        //2.2取出下一句歌词
        NSInteger nextIndex = i + 1;
        ZWLrcModel *nextLrcLineModel = nil;
        if (nextIndex < self.lrcList.count) {
            nextLrcLineModel = self.lrcList[nextIndex];
        }
        
        //2.3判断当前播放器的时间、当前的歌词时间，以及下一句歌词的时间。如果播放器时间大于当前歌词时间，并且小于下一句歌词时间，则显示当前的歌词
        //要记录当前刷新的是哪一行，如果是当前行，就不用滚动tableView了。否则CADisplayLink一秒钟调用60次，tableView一直设置滚动刷新界面，就无法正常拉动和显示
        if (self.currentIndex != i && _currentTime >= currentLrcLineModel.time && _currentTime < nextLrcLineModel.time) {
            //1.获取当前歌词和上一句歌词的indexPath
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
             NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            
            //2.记录当前刷新的是哪一行
            self.currentIndex = i;
            
            //3.刷新当前这句歌词，并且刷新上一句歌词
            [self.tableView reloadRowsAtIndexPaths:@[indexPath,previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            //4.滚动到tableView的中间
            //这里只能滚动到top或bottom，因为前面设置了tableView的contentInset，如果是滚动到中间就不能正常显示
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            /*******************************/
            //5、设置主界面歌词lrcLabel
            self.lrcLabel.text = currentLrcLineModel.text;
            //6.生成锁频图片
            [self generateLockImage];
        }
        
        /***************************************************/
        //设置当前这句歌词界面显示的渐变效果
        if (self.currentIndex == i) {//当前这句歌词
            //1.（当前播放器的时间 - 当前歌词的时间）/(下一句歌词时间 - 当前歌词时间) = value
            CGFloat value = (self.currentTime - currentLrcLineModel.time)/(nextLrcLineModel.time - currentLrcLineModel.time);
            //2.设置当前歌词播放的进度
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            ZWLrcCell *lrcCell = [self.tableView cellForRowAtIndexPath:indexPath];
            lrcCell.lrcLabel.progress = value;
            
            
            /*******************************/
            //3、设置主界面歌词lrcLabel进度
            self.lrcLabel.progress = value;
        }
    }
}

#pragma mark -生成锁屏照片
- (void)generateLockImage{
    //1.获取当前音乐的图片
    ZWMusicModel *playingMusic = [ZWMusicTool playingMusic];
    UIImage *currentImage = [UIImage imageNamed:playingMusic.icon];
    //2.取出歌词
    // 2.1取出当前的歌词
    ZWLrcModel *currentLrcLine = self.lrcList[self.currentIndex];
    // 2.2取出上一句歌词
    NSInteger previousIndex = self.currentIndex - 1;
    ZWLrcModel *previousLrcLine = nil;
    if (previousIndex >= 0) {
        previousLrcLine = self.lrcList[previousIndex];
    }
    // 2.3取出下一句歌词
    NSInteger nextIndex = self.currentIndex + 1;
    ZWLrcModel *nextLrcLine = nil;
    if (nextIndex < self.lrcList.count) {
        nextLrcLine = self.lrcList[nextIndex];
    }
    // 3.生成水印图片
    // 3.1获取上下文
    UIGraphicsBeginImageContext(currentImage.size);
    
    // 3.2将图片画上去
    [currentImage drawInRect:CGRectMake(0, 0, currentImage.size.width, currentImage.size.height)];
    
    // 3.3将文字画上去
    CGFloat titleH = 25;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment =  NSTextAlignmentCenter;
    NSDictionary *attributes1 = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                  NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                  NSParagraphStyleAttributeName : paragraphStyle};
    [previousLrcLine.text drawInRect:CGRectMake(0, currentImage.size.height - titleH * 3, currentImage.size.width, titleH) withAttributes:attributes1];
    [nextLrcLine.text drawInRect:CGRectMake(0, currentImage.size.height - titleH, currentImage.size.width, titleH) withAttributes:attributes1];
    
    NSDictionary *attributes2 =  @{NSFontAttributeName : [UIFont systemFontOfSize:20],NSForegroundColorAttributeName : [UIColor redColor],NSParagraphStyleAttributeName : paragraphStyle};
    [currentLrcLine.text drawInRect:CGRectMake(0, currentImage.size.height - titleH *2, currentImage.size.width, titleH) withAttributes:attributes2];
    // 3.4获取画好的图片
    UIImage *lockImage = UIGraphicsGetImageFromCurrentImageContext();
    // 3.5关闭上下文
    UIGraphicsEndImageContext();
    // 3.6设置锁屏界面的图片
    [self setupLockScreenInfoWithLockImage:lockImage];
}
#pragma mark - 设置锁屏信息
- (void)setupLockScreenInfoWithLockImage:(UIImage *)lockImage{
    /*
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
     */
    // 0.获取当前播放的歌曲
    ZWMusicModel *playingMusic = [ZWMusicTool playingMusic];
    
    // 1.获取锁屏中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    // 2.设置锁屏参数
    NSMutableDictionary *playingInfoDict = [NSMutableDictionary dictionary];
    // 2.1设置歌曲名
    [playingInfoDict setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle];
    // 2.2设置歌手名
    [playingInfoDict setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];
    // 2.3设置封面的图片
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:lockImage];
    [playingInfoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
    // 2.4设置歌曲的总时长
    [playingInfoDict setObject:@(self.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    // 2.4设置歌曲当前的播放时间
    [playingInfoDict setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    playingInfoCenter.nowPlayingInfo = playingInfoDict;
    // 3.开启远程交互
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

@end
