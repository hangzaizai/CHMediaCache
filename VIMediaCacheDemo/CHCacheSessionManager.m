//
//  CHCacheSessionManager.m
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/8/8.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import "CHCacheSessionManager.h"

@interface CHCacheSessionManager()

@property(nonatomic,strong)NSOperationQueue *downloadQueue;

@end

@implementation CHCacheSessionManager

+ (instancetype)shared
{
    static CHCacheSessionManager *instance  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.name = @"com.chmediacache.download";
        _downloadQueue = queue;
    }
    return self;
}

@end
