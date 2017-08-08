//
//  CHMediaCacheWorker.h
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/27.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCacheConfiguration.h"

@class CHCacheAction;

@interface CHMediaCacheWorker : NSObject

- (instancetype)initWithURL:(NSURL *)url;

@property(nonatomic,strong,readonly)CHCacheConfiguration *cacheConfiguration;

@property (nonatomic, strong, readonly) NSError *setupError;

- (void)cacheData:(NSData *)data forRange:(NSRange)range error:(NSError **)error;

- (NSArray<CHCacheAction *> *)cachedDataActionsForRange:(NSRange)range;

- (NSData *)cachedDataForRange:(NSRange)range error:(NSError **)error;

- (void)setContentInfo:(CHContentInfo *)contentInfo error:(NSError **)error;

- (void)save;

- (void)startWriting;

- (void)finishWriting;

@end
