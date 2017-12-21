//
//  SMDB.m
//  RSSRead
//
//  Created by a on 2017/11/6.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import "SMDB.h"

@interface SMDB()
@property (nonatomic, copy) NSString *feedDBPath;
@property (nonatomic, copy) NSString *feedItemDBPath;
@end

@implementation SMDB

+ (SMDB *)shareInstance
{
    static SMDB *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SMDB  alloc] init];
    });
    return instance;
}

#pragma mark - Getter
- (NSMutableDictionary *)feedIcons {
    if (!_feedIcons) {
        _feedIcons = [NSMutableDictionary dictionary];
    }
    return _feedIcons;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //创建feedModel数据库文件
        _feedDBPath = [PATH_OF_DOCUMENT  stringByAppendingPathComponent:@"feeds.sqlite"];
        if ([[NSFileManager  defaultManager] fileExistsAtPath:_feedDBPath] == NO) {
            //存在就创建
            FMDatabase *db = [FMDatabase  databaseWithPath:_feedDBPath];
            if ([db   open]) {
                /*
                 unread：未读数
                 updatetime：最后更新时间用来排序
                 ishide：是否隐藏，0表示显示，1表示不显示
                 */
                NSString *createSql = @"create table feeds (fid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, title text, link text, des text, copyright text, generator text, imageurl text, feedurl text, unread integer, updatetime integer, ishide integer)";
                [db executeUpdate:createSql];
                /*
                 des：正文内容
                 isread：是否点开查看过，0表示没看过，1表示看过
                 isCached：是否缓存了内容
                 thumbnails：图片集，各个图片地址使用|作为分隔符
                 */
                NSString *createItemSql = @"create table feeditem (iid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, fid integer, link text, title text, author text, category text, pubdate text, des blob, isread integer, iscached integer, thumbnails text)";
                [db executeUpdate:createItemSql];
            }
        }
        
        
    }return self;
}


//插入数据SMFeedModel,并返回model的id
- (int)insertWithFeedModel:(SMFeedModel *)feedModel
{
    FMDatabase *db = [FMDatabase  databaseWithPath:_feedDBPath];
    //打开数据库
    if ([db  open]) {
        
        /*****1.SMFeedModel****/
        //查询数据-->SMFeedModel 所有id
        FMResultSet *result = [db  executeQuery:@"select fid from feeds where feedurl = ?", feedModel.feedUrl];
        int fid = 0;
        if ([result  next]) {
            //存在返回fid
            fid = [result  intForColumn:@"fid"];
        }else{
            //不存在就将传进来的SMFeedModel对象存入数据库,同时返回fid
            [db executeUpdate:@"insert into feeds (title, link, des, copyright, generator, imageurl, feedurl, ishide) values (?, ?, ?, ?, ?, ?, ?, ?)", feedModel.title, feedModel.link, feedModel.des, feedModel.copyright, feedModel.generator, feedModel.imageUrl, feedModel.feedUrl, @(0)];
            
            //将上面刚插入到数据库中的数据fid查找出来,并返回
            FMResultSet *fidRsl = [db executeQuery:@"select fid from feeds where feedurl = ?",feedModel.feedUrl];
            if ([fidRsl next]) {
                //返回fid
                fid = [fidRsl intForColumn:@"fid"];
            }
        }
        
        /*****2.SMFeedItemModel****/
        //添加feed item :关联了一个外键fid
        if (feedModel.items.count > 0) {
            for (SMFeedItemModel *itemModel in feedModel.items) {
                FMResultSet *iRsl = [db executeQuery:@"select iid from feeditem where link = ?",itemModel.link];
                if ([iRsl next]) {
                    
                } else {
                    //过滤字符串
                    NSString *badChars = @"\\\'";
                    NSCharacterSet *badCharSet = [NSCharacterSet characterSetWithCharactersInString: badChars];
                    itemModel.title = [itemModel.title stringByTrimmingCharactersInSet:badCharSet];
                    itemModel.des = [itemModel.des stringByTrimmingCharactersInSet:badCharSet];
                    //入库
                    [db executeUpdate:@"insert into feeditem (fid, link, title, author, category, pubdate, des, isread, iscached) values (?, ?, ?, ?, ?, ?, ?, ?, ?)", @(fid), itemModel.link, itemModel.title, itemModel.author, itemModel.category, itemModel.pubDate, itemModel.des, @0, @0];
                    [db executeUpdate:@"update feeds set updatetime = ? where fid = ?",@(time(NULL)),@(fid)];
                }
            }
        }
        
        //3.读取未读item数
        FMResultSet *uRsl = [db executeQuery:@"select iid from feeditem where fid = ? and isread = ?",@(fid), @0];
        NSUInteger count = 0;
        while ([uRsl next]) {
            count++;
        }
        feedModel.unReadCount = count;
        //存在的话同时更新下feed信息
        [db executeUpdate:@"update feeds set title = ?, link = ?, des = ?, copyright = ?, generator = ?, imageurl = ?, unread = ? where fid = ?",feedModel.title, feedModel.link, feedModel.des, feedModel.copyright, feedModel.generator, feedModel.imageUrl, @(count), @(fid)];
        //告知完成可以接下来的操作
        [db close];
        
        return fid;//返回feedModel的id:fid
    }
    
    
    return 0;
}

//本地读取首页订阅源数据
- (NSMutableArray *)selectAllFeeds {
    FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select * from feeds where ishide = ? order by updatetime desc",@(0)];
        NSUInteger count = 0;
        NSMutableArray *feedsArray = [NSMutableArray array];
        while ([rs next]) {
            SMFeedModel *feedModel = [[SMFeedModel alloc] init];
            feedModel.fid = [rs intForColumn:@"fid"];
            feedModel.title = [rs stringForColumn:@"title"];
            feedModel.link = [rs stringForColumn:@"link"];
            feedModel.des = [rs stringForColumn:@"des"];
            feedModel.copyright = [rs stringForColumn:@"copyright"];
            feedModel.generator = [rs stringForColumn:@"generator"];
            feedModel.imageUrl = [rs stringForColumn:@"imageurl"];
            feedModel.feedUrl = [rs stringForColumn:@"feedurl"];
            feedModel.unReadCount = [rs intForColumn:@"unread"];
            [feedsArray addObject:feedModel];
            count++;
            //feedicons
            if (feedModel.imageUrl.length > 0) {
                NSString *fidStr = [NSString stringWithFormat:@"%lu",(unsigned long)feedModel.fid];
                self.feedIcons[fidStr] = feedModel.imageUrl;
            }
        }
        [db close];
        return feedsArray;
    }
    
    return nil;
}

@end







