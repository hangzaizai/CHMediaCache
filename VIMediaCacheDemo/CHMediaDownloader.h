//
//  CHMediaDownloader.h
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/26.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHMediaDownloadDelegate;
@class CHContentInfo;

@interface CHMediaDownloaderStatus : NSObject

+ (instancetype)shared;

//如果正在下载则返回YES
- (BOOL)containsURL:(NSURL *)url;
- (NSSet *)urls;

@end

//下载器
@interface CHMediaDownloader : NSObject

- (instancetype)initWithURL:(NSURL *)url;
@property(nonatomic,strong,readonly)NSURL *url;
@property(nonatomic,weak)id<CHMediaDownloadDelegate>delegate;
@property(nonatomic,strong)CHContentInfo *info;

- (void)downloadTaskFromOffset:(unsigned long long)fromOffset length:(NSUInteger)length toEnd:(BOOL)toEnd;

- (void)downloadFromStartToEnd;

- (void)cancel;

- (void)invalidateAndCancel;

@end


@protocol CHMediaDownloadDelegate <NSObject>
@optional
- (void)mediaDownloader:(CHMediaDownloader *)downloader didReceiveResponse:(NSURLResponse *)response;
- (void)mediaDownloader:(CHMediaDownloader *)downloader didReceiveData:(NSData *)data;
- (void)mediaDownloader:(CHMediaDownloader *)downloader didFinishedWithError:(NSError *)error;
@end
