//
//  SMFeedTableViewCell.h
//  RSSRead
//
//  Created by a on 2017/12/21.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SMFeedModel;

@interface SMFeedTableViewCell : UITableViewCell

//绘制
- (void)draw;

//赋值
@property (nonatomic, strong) SMFeedModel *model;


@end
