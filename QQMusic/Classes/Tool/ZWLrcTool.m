//
//  ZWLrcTool.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWLrcTool.h"
#import "ZWLrcModel.h"
@implementation ZWLrcTool

+(NSArray *)lrcToolWithLrcName:(NSString *)lrcName{
    //1.获取路径
    NSString *path = [[NSBundle mainBundle]pathForResource:lrcName ofType:nil];
    //2.获取歌词
    NSString *lrcString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //3.转化成歌词数组
    NSMutableArray *tempArray = [NSMutableArray array];
    NSArray *lrcArray = [lrcString componentsSeparatedByString:@"\n"];
    for (NSString * lrcLineString in lrcArray) {
        //4.过滤不需要的字符串
        /*
         [ti:简单爱]
         [ar:周杰伦]
         [al:范特西]
         */
        // 4.过滤不需要的字符串
        if ([lrcLineString hasPrefix:@"[ti:"] ||
            [lrcLineString hasPrefix:@"[ar:"] ||
            [lrcLineString hasPrefix:@"[al:"] ||
            ![lrcLineString hasPrefix:@"["]) {
            continue;
        }
        // 5.将歌词转化成模型
        ZWLrcModel *lrcLineModel = [ZWLrcModel lrcLineString:lrcLineString];
        [tempArray addObject:lrcLineModel];
    }
//    for (ZWLrcModel *lrcLineModel in tempArray) {
//        NSLog(@"%@ %f",lrcLineModel.text,lrcLineModel.time);
//    }
    return tempArray;
}
@end
