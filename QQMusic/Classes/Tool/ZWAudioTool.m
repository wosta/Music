//
//  ZWAudioTool.m
//  02-播放音效
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWAudioTool.h"


@implementation ZWAudioTool
/*
 音乐播放底层是C++写的
 一个页面可能要播放多个音效，所以最好用soundIDs将soundID保存。通过判断soundID是否为0，不用反复创建soundID。
 一个音乐对应一个播放器，一个音效对应一个soundID，但是这里的播放器和soundID最好都给保存一下。
 */
static NSMutableDictionary *_soudIDs;
static NSMutableDictionary *_players;

+ (void)initialize{
    _soudIDs = [NSMutableDictionary dictionary];
    _players = [NSMutableDictionary dictionary];
}


+ (AVAudioPlayer *)playMusicWithFileName:(NSString *)fileName{
    // 1.创建空的播放器
    AVAudioPlayer *player = nil;
    // 2.从字典中取出播放器
    player = _players[fileName];
    // 3.判断播放器是否为空
    //第一次播放因为的时候，字典中的播放器会为空，player不存在，所以这里要判断一下是否为nil，为nil的时候要创建
    if (player == nil) {
        // 4.生成对应音乐资源
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        /************************************************/
        //如果资源文件不存在，则不会创建player，即player为nil，二字典中如果存nil,，则会崩溃，所以要做这样的判断
        if (fileUrl == nil) return player;
        // 5.创建对应的播放器
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        // 6.保存到字典中
        [_players setObject:player forKey:fileName];
        // 7.准备播放  目的：将资源加载到内存中
        [player prepareToPlay];
    }
    // 8.开始播放
    [player play];
    return player;
}

+ (void)pauseMusicWithFileName:(NSString *)fileName{
    // 1.从字典中取出播放器
    AVAudioPlayer *player = _players[fileName];
    // 2.暂停音乐
    if (player) {
        [player pause];
    }
}

+ (void)stopMusicWithFileName:(NSString *)fileName{
    // 1.从字典中取出播放器
    AVAudioPlayer *player = _players[fileName];
    // 2.停止音乐
    if (player) {
        [player stop];
        //停止音乐后，将字典中的播放器移除，之后再置为nil
        [_players removeObjectForKey:fileName];
        player = nil;
    }
}


+ (void)playSoundWithSoundName:(NSString *)soundName{
    /*
     这个方法里不能借助属性soudIDs保存，因为在类方法中self.soudIDs中的self代表类对象，不能直接使用实例对象的属性
     */
    // 1.创建soundID = 0
    SystemSoundID soundID = 0;
    // 2.从字典中取出soundID
    soundID = [_soudIDs[soundName] unsignedIntValue];;
    // 3.判断soundID是否为0
    if (soundID == 0) {
        // 3.1生成soundID
        CFURLRef url = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
        if (url == nil) return;
        AudioServicesCreateSystemSoundID(url, &soundID);
        // 3.2将soundID保存到字典中
        [_soudIDs setObject:@(soundID) forKey:soundName];
    }
    // 4.播放音效
    AudioServicesPlaySystemSound(soundID);
}

@end
