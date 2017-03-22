//
//  NSString+ZWTime.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "NSString+ZWTime.h"

@implementation NSString (ZWTime)

+ (NSString *)stringWithTime:(NSTimeInterval)time{
    NSInteger min = time / 60;
    //round(time) 是四舍五入
    NSInteger sec = (int)round(time) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
}
@end
