//
//  SMFeedViewModel.h
//  RSSRead
//
//  Created by a on 2017/12/17.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SMFeedModel;

typedef void(^SuccessBlock)(int i, SMFeedModel *model);
typedef void(^FailureBlock)(NSError *error);
typedef void(^FinishBlock)(BOOL isFinish);


@interface SMFeedViewModel : NSObject

//单例初始化
+ (SMFeedViewModel *)shareInstance;

//feeds数组
@property (nonatomic, strong) NSMutableArray *feeds;

//icons字典
@property (nonatomic, strong) NSMutableDictionary *icons;

//成功回调
@property (nonatomic, copy) SuccessBlock successBlock;

//失败回调
@property (nonatomic, copy) FailureBlock failureBlock;

//抓取所有数据完成
@property (nonatomic, copy) FinishBlock finishBlock;


// 传入交互的Block块
- (void)setBlockWithSuccessBlock: (SuccessBlock)successBlock
                     failueBlock: (FailureBlock)failueBlock
                     finishBlock: (FinishBlock)failueBlock;

//抓取数据
- (void)fetchAllFeedWithModelArray:(NSMutableArray *)modelArray;

//是否WiFi
+ (BOOL)isWifi;

@end




