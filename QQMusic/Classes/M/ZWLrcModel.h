//
//  ZWLrcModel.h
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWLrcModel : NSObject

@property(nonatomic,copy)NSString *text;
@property(nonatomic,assign)NSTimeInterval time;

- (instancetype)initWithLrcLineString:(NSString *)lrcLineString;
+ (instancetype)lrcLineString:(NSString *)lrcLineString;
@end
