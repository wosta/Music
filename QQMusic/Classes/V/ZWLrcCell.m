//
//  ZWLrcCell.m
//  QQMusic
//
//  Created by 郑亚伟 on 2016/12/29.
//  Copyright © 2016年 郑亚伟. All rights reserved.
//

#import "ZWLrcCell.h"
#import "ZWLrcLabel.h"
#import "Masonry.h"

@implementation ZWLrcCell


+ (instancetype)lrcCellWithTableView:(UITableView *)tableView{
    static NSString *cellId = @"cell";
    ZWLrcCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[ZWLrcCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //1.初始化ZWLabel
        _lrcLabel = [[ZWLrcLabel alloc]init];
         [_lrcLabel sizeToFit];
        _lrcLabel.center = self.contentView.center;
        [self.contentView addSubview:_lrcLabel];
        
        //2.设置基本数据
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.lrcLabel.textColor = [UIColor whiteColor];
         self.lrcLabel.textAlignment = NSTextAlignmentCenter;
         self.lrcLabel.font = [UIFont systemFontOfSize:14];
        //设置cell的背景颜色为透明
         self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

//不在这里面写会有bug
//??????????????????????
- (void)layoutSubviews{
    [super layoutSubviews];

    [_lrcLabel sizeToFit];
    _lrcLabel.center = self.contentView.center;
}

@end
