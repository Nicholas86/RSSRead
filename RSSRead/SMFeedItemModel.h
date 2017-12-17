//
//  SMFeedItemModel.h
//  RSSRead
//
//  Created by a on 2017/12/17.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface SMFeedItemModel : JSONModel
@property (nonatomic) NSUInteger iid;
@property (nonatomic) NSUInteger fid;
@property (nonatomic, copy) NSString<Optional> *link;         //文章链接
@property (nonatomic, copy) NSString<Optional> *title;        //文章标题
@property (nonatomic, copy) NSString<Optional> *author;       //作者
@property (nonatomic, copy) NSString<Optional> *category;     //分类
@property (nonatomic, copy) NSString<Optional> *pubDate;      //发布日期
@property (nonatomic, copy) NSString<Optional> *des;          //正文内容
@property (nonatomic) NSUInteger isRead;                      //是否已读
@property (nonatomic) NSUInteger isCached;                    //是否缓存
@property (nonatomic, copy) NSString<Optional> *iconUrl;      //频道icon
@end
