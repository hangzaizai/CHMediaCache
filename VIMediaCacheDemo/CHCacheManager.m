//
//  CHCacheManager.m
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/8/8.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import "CHCacheManager.h"
#import "CHMediaDownloader.h"

NSString *CHCacheManagerDidUpdateCacheNotification = @"CHCacheManagerDidUpdateCacheNotification";
NSString *CHCacheManagerDidFinishCacheNotification = @"CHCacheManagerDidFinishCacheNotification";

NSString *CHCacheConfigurationKey = @"CHCacheConfigurationKey";
NSString *CHCacheFinishedErrorKey = @"CHCacheFinishedErrorKey";

static NSString *kMCMediaCacheDirectory;
static NSTimeInterval kMCMediaCacheNotifyInterval;


@implementation CHCacheManager

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSTemporaryDirectory() stringByAppendingPathComponent:@"chmedia"];
    });
}

+ (void)setCacheDirectory:(NSString *)cacheDirectory
{
    kMCMediaCacheDirectory = cacheDirectory;
}

+ (NSString *)cacheDirectory
{
    return kMCMediaCacheDirectory;
}

+ (void)setCacheUpdateNotifyInterval:(NSTimeInterval)interval {
    kMCMediaCacheNotifyInterval = interval;
}

+ (NSTimeInterval)cacheUpdateNotifyInterval {
    return kMCMediaCacheNotifyInterval;
}

+ (NSString *)cachedFilePathForURL:(NSURL *)url
{
    return [[self cacheDirectory] stringByAppendingPathComponent:[url lastPathComponent]];
}

+ (CHCacheConfiguration *)cacheConfigurationForURL:(NSURL *)url
{
    NSString *filePath = [self cachedFilePathForURL:url];
    CHCacheConfiguration *configuration = [CHCacheConfiguration configurationWithFilePath:filePath];
    return configuration;
}

//计算缓存大小
+ (unsigned long long)calculateCacheSizeWithError:(NSError *__autoreleasing *)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDirectory = [self cacheDirectory];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:error];
    unsigned long long size = 0;
    if ( files ) {
        for ( NSString *path in files ) {
            NSString *filePath = [cacheDirectory stringByAppendingPathComponent:path];
            NSDictionary<NSFileAttributeKey,id> *attribute = [fileManager attributesOfItemAtPath:filePath error:error];
            if ( !attribute ) {
                size = -1;
                break;
            }
            size += [attribute fileSize];
        }
    }
    
    return size;
}

@end
