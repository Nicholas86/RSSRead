//
//  SMSubContentLabel.m
//  RSSRead
//
//  Created by a on 2017/12/21.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import "SMSubContentLabel.h"

@implementation SMSubContentLabel

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
        self.font = [SMStyle  fontSmall];
        self.textColor = [SMStyle  colorGrayLight];
        self.textAlignment = NSTextAlignmentCenter;
    }return self;
}

@end
