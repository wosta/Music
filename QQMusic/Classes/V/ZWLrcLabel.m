//
//  ZWLrcLabel.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/30.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWLrcLabel.h"

@implementation ZWLrcLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGRect fillRect = CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height);
    [[UIColor greenColor] set];
    //这个是填充整个背景
   // UIRectFill(fillRect);
    //这个只是设置文字的颜色
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self setNeedsDisplay];
}

@end
