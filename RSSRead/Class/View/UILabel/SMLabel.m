//
//  SMLabel.m
//  RSSRead
//
//  Created by a on 2017/12/21.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import "SMLabel.h"

@implementation SMLabel

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
        self.backgroundColor = [UIColor  clearColor];
        self.font = [SMStyle  fontNormal];//14号
        self.textColor = [SMStyle  colorGrayDark];//冷色
    }return self;
}

@end
