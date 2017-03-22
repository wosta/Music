//
//  CALayer+PauseAimate.h
//  QQ
//
//  Created by apple on 16/8/14.
//  Copyright (c) 2016年 郑亚伟. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (PauseAimate)

// 暂停动画
- (void)pauseAnimate;

// 恢复动画
- (void)resumeAnimate;

@end
