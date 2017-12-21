//
//  SMTitleLabel.m
//  RSSRead
//
//  Created by a on 2017/12/21.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import "SMTitleLabel.h"

@implementation SMTitleLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.font = [SMStyle  fontHuge];//18号字体
        self.textColor = [SMStyle  colorPaperBlack];//黑色
    }return self;
}

@end
