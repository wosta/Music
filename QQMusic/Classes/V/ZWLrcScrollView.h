//
//  ZWLrcScrollView.h
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWLrcLabel.h"

@interface ZWLrcScrollView : UIScrollView<UITableViewDelegate,UITableViewDataSource>
/*歌词名*/
@property(nonatomic,copy)NSString *lrcName;
/*当前播放器播放时间*/
@property(nonatomic,assign)NSTimeInterval currentTime;
/*记录当前刷新的是哪一行*/
@property(nonatomic,assign)NSInteger currentIndex;


@property(nonatomic,weak)ZWLrcLabel *lrcLabel;


/** 当前播放器总时间时间 */
@property (nonatomic, assign) NSTimeInterval duration;

@end
