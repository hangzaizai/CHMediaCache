//
//  CHCacheManager.h
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/8/8.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCacheConfiguration.h"

extern NSString *CHCacheManagerDidUpdateCacheNotification;
extern NSString *CHCacheManagerDidFinishCacheNotification;
extern NSString *CHCacheConfigurationKey;
extern NSString *CHCacheFinishedErrorKey;

@interface CHCacheManager : NSObject

+ (void)setCacheDirectory:(NSString *)cacheDirectory;
+ (NSString *)cacheDirectory;

+ (void)setCacheUpdateNotifyInterval:(NSTimeInterval)interval;
+ (NSTimeInterval)cacheUpdateNotifyInterval;

+ (NSString *)cachedFilePathForURL:(NSURL *)url;
+ (CHCacheConfiguration *)cacheConfigurationForURL:(NSURL *)url;

+ (unsigned long long)calculateCacheSizeWithError:(NSError **)error;
+ (void)cleanAllCacheWithError:(NSError **)error;
+ (void)cleanCacheForURL:(NSURL *)url error:(NSError **)error;

+ (BOOL)addCacheFile:(NSString *)filePath forURL:(NSURL *)url error:(NSError **)error;

@end
