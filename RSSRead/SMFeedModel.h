//
//  SMFeedModel.h
//  RSSRead
//
//  Created by a on 2017/11/6.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface SMFeedModel : JSONModel
@property (nonatomic) NSUInteger fid;
@property (nonatomic, copy) NSString<Optional> *title;        //名称
@property (nonatomic, copy) NSString<Optional> *link;         //博客链接
@property (nonatomic, copy) NSString<Optional> *des;          //简介
@property (nonatomic, copy) NSString<Optional> *copyright;
@property (nonatomic, copy) NSString<Optional> *generator;
@property (nonatomic, copy) NSString<Optional> *imageUrl;     //icon图标
@property (nonatomic, strong) NSMutableArray *items;          //SMFeedItemModel
@property (nonatomic, copy) NSString<Optional> *feedUrl;      //博客feed的链接
@property (nonatomic) NSUInteger unReadCount;
@property (nonatomic) BOOL isSync;
@end
