//
//  CHCacheSessionManager.h
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/8/8.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHCacheSessionManager : NSObject

@property(nonatomic,strong,readonly)NSOperationQueue *downloadQueue;

+ (instancetype)shared;

@end
