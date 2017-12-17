//
//  SMNetManager.h
//  RSSRead
//
//  Created by a on 2017/12/17.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

@interface SMNetManager : AFHTTPSessionManager

+ (SMNetManager *)shareInstance;

@end
