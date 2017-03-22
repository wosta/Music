//
//  ZWLrcCell.h
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWLrcLabel.h"
@interface ZWLrcCell : UITableViewCell
@property(nonatomic,strong)ZWLrcLabel *lrcLabel;

+ (instancetype)lrcCellWithTableView:(UITableView *)tableView;
@end
