//
//  ZWMusicTool.h
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWMusicModel.h"
@interface ZWMusicTool : NSObject
/*
 因为音乐播放不仅仅在当前控制器会使用，还会在其他控制器中进行切换，所以要封装成工具类
 */
/**
 所有音乐
 */
+ (NSArray *)musics;
/*
 正在播放的音乐
 */
+(ZWMusicModel *)playingMusic;

/*************
 设置默认播放的音乐
 */
+(void)setupPlayingMusic:(ZWMusicModel *)playingMusic;


/*返回上一首音乐*/
+ (ZWMusicModel *)previousMusic;
/*返回下一首音乐*/
+ (ZWMusicModel *)nextMusic;
@end
