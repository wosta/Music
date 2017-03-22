//
//  ZWLrcModel.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWLrcModel.h"

@implementation ZWLrcModel

- (instancetype)initWithLrcLineString:(NSString *)lrcLineString{
    if (self = [super init]) {
        //[01:02.38]想你时你在天边
        NSArray *lrcArray = [lrcLineString componentsSeparatedByString:@"]"];
        self.text = lrcArray[1];//想你时你在天边
        self.time = [self timeWithString:[lrcArray[0] substringFromIndex:1]];//01:02.38
    }
    return self;
}

- (NSTimeInterval )timeWithString:(NSString *)timeString{
    //01:02.38
    NSInteger min = [[timeString componentsSeparatedByString:@":"][0] integerValue];
    NSInteger sec = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue];
    NSInteger hs = [[timeString componentsSeparatedByString:@"."][1] integerValue];
    return min * 60 + sec + hs * 0.01;
}

+ (instancetype)lrcLineString:(NSString *)lrcLineString{
    return [[self alloc]initWithLrcLineString:lrcLineString];
}
@end
