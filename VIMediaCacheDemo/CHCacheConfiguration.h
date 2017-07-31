//
//  CHCacheConfiguration.h
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/27.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHContentInfo.h"

/**
下载辅助类，保存文件信息(暂时猜测)
 */
@interface CHCacheConfiguration : NSObject<NSCopying>

+ (NSString *)configurationFilePathForFilePath:(NSString *)filePath;

+ (instancetype)configurationWithFilePath:(NSString *)filePath;

@property(nonatomic,copy,readonly)NSString *filePath;
@property(nonatomic,strong)CHContentInfo *contentInfo;
@property(nonatomic,strong)NSURL *url;

- (NSArray<NSValue *> *)cacheFragments;

@property(nonatomic,readonly)float progress;

@property(nonatomic,readonly)long long downloadedBytes;

@property(nonatomic,readonly)float downloadSpeed; //kb/s


- (void)save;
- (void)addCacheFragment:(NSRange)fragment;


/**
 记录下载速度
 */
- (void)addDownloadedBytes:(long long)bytes spent:(NSTimeInterval)time;

@end

@interface CHCacheConfiguration (CHConvenient)

+ (BOOL)createAndSaveDownloadedConfigurationForURL:(NSURL *)url error:(NSError **)error;

@end
