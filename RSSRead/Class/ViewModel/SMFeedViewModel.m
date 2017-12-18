//
//  SMFeedViewModel.m
//  RSSRead
//
//  Created by a on 2017/12/17.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import "SMFeedViewModel.h"
#import "SMNetManager.h"//网络请求
#import "SMFeedModel.h"//封装模型
#import "SMFeedStore.h"//解析、暂存数据
#import "SMDB.h"//本地数据库

@interface SMFeedViewModel()
@property (nonatomic, strong) SMFeedStore *feedStore;//解析、暂存数据
@end

@implementation SMFeedViewModel
//单例初始化
+ (SMFeedViewModel *)shareInstance
{
    static SMFeedViewModel *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SMFeedViewModel  shareInstance];
    });
    return instance;
}

//feeds数组
- (NSMutableArray *)feeds
{
    if (!_feeds) {
        self.feeds = [[NSMutableArray  alloc] init];
    }return _feeds;
}

//icons字典
- (NSMutableDictionary *)icons
{
    if (!_icons) {
        self.icons = [[NSMutableDictionary alloc] init];
    }return _icons;
}

//解析、暂存数据
- (SMFeedStore *)feedStore
{
    if (!_feedStore) {
        self.feedStore = [[SMFeedStore  alloc] init];
    }return _feedStore;
}

//传入交互的block回调
- (void)setBlockWithSuccessBlock:(SuccessBlock)successBlock
                 WithFailueBlock:(FailureBlock)failueBlock
{
    _successBlock = successBlock;
    _failureBlock = failueBlock;
}

#pragma mark 抓取数据
- (void)fetchAllFeedWithModelArray:(NSMutableArray *)modelArray
{
    //创建并行队列
    dispatch_queue_t  fetchFeedQueue = dispatch_queue_create("com.starming.fetchfeed.fetchfeed", DISPATCH_QUEUE_CONCURRENT);
    //创建全局队列组
    dispatch_group_t group = dispatch_group_create();
    
    //接收传进来的数据源(数组)
    self.feeds = modelArray;
    
    //加载网络请求数据
    SMNetManager *netManager = [SMNetManager   shareInstance];
    for (int i = 0; i < modelArray.count; i++) {
        //进入全局队列组
        dispatch_group_enter(group);
        
        //从数组取出model
        SMFeedModel *feedModel = modelArray[i];
        feedModel.isSync = NO;
        
        NSLog(@"feedUrl=%@, title=%@", feedModel.feedUrl, feedModel.title);
        //GET请求
        [netManager  GET:feedModel.feedUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //成功回调
            
            /*
            NSLog(@"responseObject=%@", responseObject);
            NSString *xmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"Data: %@", xmlString);
            NSLog(@"%@",feedModel);
             */
            
            
            //开启异步子线程
            dispatch_async(fetchFeedQueue, ^{
                //解析feed,xml格式
                self.feeds[i] = [self.feedStore   updateFeedModelWithData:responseObject preModel:feedModel];
                //入库存储
                SMDB *db = [SMDB  shareInstance];
                //接收(插入本地数据库并返回id)
                int fid = [db  insertWithFeedModel:self.feeds[i]];
                SMFeedModel *model = (SMFeedModel *)self.feeds[i];
                model.fid = fid;
                if (model.imageUrl.length > 0) {
                    NSString *fidString = [NSString  stringWithFormat:@"%d",fid];
                    db.feedIcons[fidString] = model.imageUrl;
                }
                //通知单个完成
                dispatch_group_leave(group);
                //插入本地数据库成功后,将下标返回
                _successBlock(i);//block下标
            });
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //失败回调
            NSLog(@"Error: %@", error);
            dispatch_async(fetchFeedQueue, ^{
                //入库存储
                SMDB *db = [SMDB  shareInstance];
                //接收(插入本地数据库并返回id)
                int fid = [db  insertWithFeedModel:self.feeds[i]];
                SMFeedModel *model = (SMFeedModel *)self.feeds[i];
                model.fid = fid;
                //通知单个完成
                dispatch_group_leave(group);
                //插入本地数据库成功后,将下标返回
                _failureBlock(error);//block下标
            });//end dispatch async
        }];
    }//end for
    //全完成后执行事件
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"主线程刷新");
    });
}

//是否wifi
+ (BOOL)isWifi
{
    UIApplication *application = [UIApplication  sharedApplication];
    NSArray  *foregroundViews = [[[application  valueForKeyPath:@"statusBar"]  valueForKeyPath:@"foregroundView"] subviews];
    
    int netType = 0;
    //获取网络状态码
    for (id foregroundView in foregroundViews) {
        if ([foregroundView isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取状态栏
            netType = [[foregroundView  valueForKeyPath:@"dataNetworkType"]  intValue];
            //0:无网络 1:2G 2:3G 3:4G 5:WIFI
            NSLog(@"netType = %d", netType);
            if (netType == 5) {
                return YES;
            }
        }
    }
    return NO;
}

@end




