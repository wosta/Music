//
//  ZWMusicModel.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWMusicModel.h"

@implementation ZWMusicModel

- (instancetype)initWithDict:(NSDictionary *)dic{
    if (self == [super init]) {
//        NSLog(@"%@",dic);
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
