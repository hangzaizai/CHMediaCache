//
//  CHMediaCacheWorker.m
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/27.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import "CHMediaCacheWorker.h"

#import "CHCacheManager.h"

@import UIKit;

static NSInteger const kPackageLength = 204800;// 200kb per package

static NSString *kMCMediaCacheResponseKey = @"kMCMediaCacheResponseKey";

static NSString *VIMediaCacheErrorDoamin = @"com.vimediacache";

@interface CHMediaCacheWorker()

@property(nonatomic,strong)NSFileHandle *readFileHandle;
@property(nonatomic,strong)NSFileHandle *writeFileHandle;
@property(nonatomic,strong,readwrite)NSError *setupError;
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,strong)CHCacheConfiguration *internalCacheConfiguraiton;

@property(nonatomic,assign)long long currentOffset;
@property(nonatomic,strong)NSDate *startWriteDate;
@property(nonatomic,assign)float writeBytes;
@property(nonatomic,assign)BOOL writting;

@end

@implementation CHMediaCacheWorker

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_readFileHandle closeFile];
    [_writeFileHandle closeFile];
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if ( self ) {
        NSString *path = [CHCacheManager cachedFilePathForURL:url];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        _filePath = path;
        NSError *error;
        NSString *cacheFolder = [path stringByDeletingLastPathComponent];
        if ( ![fileManager fileExistsAtPath:cacheFolder] ) {
            [fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        //创建空文件
        if ( !error ) {
            if ( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
                
            }
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            _readFileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
            if ( !error ) {
                _writeFileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&error];
                _internalCacheConfiguraiton = [CHCacheConfiguration configurationWithFilePath:path];
                _internalCacheConfiguraiton.url = url;
            }
        }
        _setupError = error;
    }
    
    return self;
}

- (CHCacheConfiguration *)cacheConfiguration
{
    return self.internalCacheConfiguraiton;
}

- (void)cacheData:(NSData *)data forRange:(NSRange)range error:(NSError *__autoreleasing *)error
{
    @synchronized (self.writeFileHandle) {
        @try {
            [self.writeFileHandle seekToFileOffset:range.location];
            [self.writeFileHandle writeData:data];
            self.writeBytes += data.length;
            [self.internalCacheConfiguraiton addCacheFragment:range];
        } @catch (NSException *exception) {
            NSLog(@"write to file error");
            *error = [NSError errorWithDomain:exception.name code:123 userInfo:@{
                                                                
                                                                                 NSLocalizedDescriptionKey:exception.reason,@"exception":exception}];
        }
    }
}

- (NSData *)cachedDataForRange:(NSRange)range error:(NSError *__autoreleasing *)error
{
    @synchronized (self.readFileHandle) {
        @try {
            [self.readFileHandle seekToFileOffset:range.location];
            NSData *data = [self.readFileHandle readDataOfLength:range.length];
            return data;
        } @catch (NSException *exception) {
            NSLog(@"read cached data error %@",exception);
            *error = [NSError errorWithDomain:exception.name code:123 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
        }
    }
    
    return nil;
}


@end
