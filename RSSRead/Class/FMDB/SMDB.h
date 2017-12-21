//
//  SMDB.h
//  RSSRead
//
//  Created by a on 2017/11/6.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "SMFeedModel.h"
#import "SMFeedItemModel.h"

#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface SMDB : NSObject
@property (nonatomic, strong) NSMutableDictionary *feedIcons;

+ (SMDB *)shareInstance;
- (int)insertWithFeedModel:(SMFeedModel *)feedModel; //插入feed内容,并返回id
- (NSMutableArray *)selectAllFeeds; //读取所有feeds
@end
