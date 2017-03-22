//
//  ZWMusicTool.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWMusicTool.h"


static NSMutableArray *_musics;
//正在播放的音乐
static ZWMusicModel *_playingMusic;


@implementation ZWMusicTool

+(void)initialize{
    if (_musics == nil) {
         _musics = [NSMutableArray array];
    }
   
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Musics" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    for (int i =0; i < array.count; i++) {
        ZWMusicModel *model = [[ZWMusicModel alloc]initWithDict:array[i]];
        [_musics addObject:model];
    }
    if (_playingMusic == nil) {
         _playingMusic = _musics[1];
    }
   
}

+ (NSArray *)musics{
    return [_musics copy];
}

+(ZWMusicModel *)playingMusic{
    return _playingMusic;
}

+(void)setupPlayingMusic:(ZWMusicModel *)playingMusic{
    _playingMusic = playingMusic;
}


+ (ZWMusicModel *)previousMusic{
    //1.获取当前音乐的下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    //2.获取上一首音乐的下标值
    NSInteger previousindex = --currentIndex;
    ZWMusicModel *previousMusic = nil;
    if (previousindex < 0) {
        previousindex = _musics.count - 1;
    }
    previousMusic = _musics[previousindex];
    return previousMusic;
}

+ (ZWMusicModel *)nextMusic{
    //1.获取当前音乐的下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    //2.获取上一首音乐的下标值
    NSInteger nextIndex = ++currentIndex;
    ZWMusicModel *nextMusic = nil;
    if (nextIndex >= _musics.count) {
        nextIndex = 0;
    }
    nextMusic = _musics[nextIndex];
    return nextMusic;
}
@end
