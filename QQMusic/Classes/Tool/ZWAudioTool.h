//
//  ZWAudioTool.h
//  02-播放音效
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ZWAudioTool : NSObject

// 播放音乐 fileName:音乐文件
+ (AVAudioPlayer *)playMusicWithFileName:(NSString *)fileName;

// 暂停音乐 fileName:音乐文件
+ (void)pauseMusicWithFileName:(NSString *)fileName;

// 停止音乐 fileName:音乐文件
+ (void)stopMusicWithFileName:(NSString *)fileName;

// 播放音效 soundName:音效文件
+ (void)playSoundWithSoundName:(NSString *)soundName;


@end
