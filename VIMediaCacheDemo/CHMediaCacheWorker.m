//
//  CHMediaCacheWorker.m
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/27.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import "CHMediaCacheWorker.h"
#import "CHCacheConfiguration.h"

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

@end
