//
//  SMNetManager.m
//  RSSRead
//
//  Created by a on 2017/12/17.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import "SMNetManager.h"

@implementation SMNetManager

//单例初始化
+ (SMNetManager *)shareInstance {
    static SMNetManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SMNetManager manager];
        instance.responseSerializer = [AFHTTPResponseSerializer serializer];
        instance.requestSerializer.timeoutInterval = 20.f;
    });
    return instance;
}

@end






