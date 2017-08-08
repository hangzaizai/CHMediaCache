//
//  CHMediaDownloader.m
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/26.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import "CHMediaDownloader.h"
#import "CHCacheAction.h"
#import "CHMediaCacheWorker.h"
#import "CHCacheSessionManager.h"

@protocol CHURLSessionDelegateObjectDelegate <NSObject>

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler;

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data;

- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error;

@end



static NSInteger kBufferSize = 10 * 1024;
@interface CHURLSessionDelegateObject : NSObject<NSURLSessionDelegate,NSURLSessionDataDelegate>

- (instancetype)initWithDelegate:(id<CHURLSessionDelegateObjectDelegate>)delegate;

@property(nonatomic,weak)id<CHURLSessionDelegateObjectDelegate>delegate;

@property(nonatomic,strong)NSMutableData *bufferData;

@end

@implementation CHURLSessionDelegateObject

- (instancetype)initWithDelegate:(id<CHURLSessionDelegateObjectDelegate>)delegate
{
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _bufferData = [NSMutableData data];
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    if ( self.delegate && [self.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        [self.delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    @synchronized (self.bufferData) {
        [self.bufferData appendData:data];
        if ( self.bufferData.length > kBufferSize ) {
            NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
            NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
            [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
            
            if ( self.delegate && [self.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)] ) {
                [self.delegate URLSession:session dataTask:dataTask didReceiveData:chunkData];
            }
            
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionDataTask *)task didCompleteWithError:(NSError *)error
{
    @synchronized (self.bufferData) {
        if ( self.bufferData.length > 0 && !error ) {
            NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
            NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
            [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
            [self.delegate URLSession:session dataTask:task didReceiveData:chunkData];

        }
    }
    
    [self.delegate URLSession:session task:task didCompleteWithError:error];

}

@end

#pragma mark -CHActionWorker

@class CHActionWorker;

@protocol CHACtionWorkerDelegate <NSObject>

- (void)actionWorker:(CHActionWorker *)actionWorker didReceiveResponse:(NSURLResponse *)response;

- (void)actionWorker:(CHActionWorker *)actionWorker didReceiveData:(NSData *)data isLocal:(BOOL)isLocal;

- (void)actionworker:(CHActionWorker *)actionWorker didFinishWithError:(NSError *)error;

@end

@interface CHActionWorker : NSObject<CHURLSessionDelegateObjectDelegate>

@property(nonatomic,strong)NSMutableArray <CHCacheAction *> *actions;

- (instancetype)initWithActions:(NSArray<CHCacheAction *> *)actions url:(NSURL *)url cacheWorker:(CHMediaCacheWorker *)cacheWorker;

@property(nonatomic,weak) id<CHACtionWorkerDelegate> delegate;

- (void)start;
- (void)cancel;

@property(nonatomic,getter=isCancelled)BOOL cancelled;

@property(nonatomic,strong)CHMediaCacheWorker *cacheWorker;

@property(nonatomic,strong)NSURL *url;

@property(nonatomic,strong)NSURLSession *session;

@property(nonatomic,strong)CHURLSessionDelegateObject *sessionDelegateObject;
@property(nonatomic,strong)NSURLSessionDataTask *task;

@property(nonatomic,assign)NSInteger startOffset;


@end

@interface CHActionWorker ()

@property(nonatomic,assign)NSTimeInterval notifyTime;

@end

@implementation CHActionWorker

- (void)dealloc
{
    [self cancel];
}

- (instancetype)initWithActions:(NSArray<CHCacheAction *> *)actions url:(NSURL *)url cacheWorker:(CHMediaCacheWorker *)cacheWorker
{
    self = [super init];
    if ( self ) {
        _actions = [actions mutableCopy];
        _cacheWorker = cacheWorker;
        _url = url;
    }
    
    return self;
}

- (void)start
{
    [self processActions];
}

-(void)cancel
{
    if ( _session ) {
        [self.session invalidateAndCancel];
    }
    self.cancelled = YES;
}

- (CHURLSessionDelegateObject *)sessionDelegateObject
{
    if ( !_sessionDelegateObject ) {
        _sessionDelegateObject = [[CHURLSessionDelegateObject alloc] initWithDelegate:self];
    }
    return _sessionDelegateObject;
}

- (NSURLSession *)session
{
    if ( !_session ) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self.sessionDelegateObject delegateQueue:[CHCacheSessionManager shared].downloadQueue];
        _session = session;
    }
    
    return _session;
}

#pragma mark -private
- (void)processActions
{
    if ( self.isCancelled ) {
        return;
    }
    CHCacheAction *action = [self.actions firstObject];
    if ( !action ) {
        if ( [self.delegate respondsToSelector:@selector(actionworker:didFinishWithError:)]) {
            [self.delegate actionworker:self didFinishWithError:nil];
        }
        return;
    }
    [self.actions removeObjectAtIndex:0];
    if ( action.actionType == CHCacheActionTypeLocal ) {
        NSError *error;
        NSData *data = [self.cacheWorker cachedDataForRange:action.range error:&error];
        if ( error ) {
            if ( [self.delegate respondsToSelector:@selector(actionworker:didFinishWithError:)]) {
                [self.delegate actionworker:self didFinishWithError:error];
            }
        }else{
            if ( [self.delegate respondsToSelector:@selector(actionWorker:didReceiveData:isLocal:)] ) {
                [self.delegate actionWorker:self didReceiveData:data isLocal:YES];
            }
            [self processActions];
        }
    }else{
        long long fromOffset = action.range.location;
        long long endOffset = action.range.location + action.range.length - 1;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-%lld",fromOffset,endOffset];
        [request setValue:range forHTTPHeaderField:@"range"];
        self.startOffset = action.range.location;
        self.task = [self.session dataTaskWithRequest:request];
        [self.task resume];
    }
}

#pragma mark -CHURLSessionDelegateObjectDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSString *mimeType = response.MIMEType;
    if ( [mimeType rangeOfString:@"video/"].location == NSNotFound && [mimeType rangeOfString:@"audio/"].location == NSNotFound ) {
        completionHandler(NSURLSessionResponseCancel);
    }else{
        if ( [self.delegate respondsToSelector:@selector(actionWorker:didReceiveResponse:)]) {
            [self.delegate actionWorker:self didReceiveResponse:response];
        }
        [self.cacheWorker startWriting];
        completionHandler(NSURLSessionResponseAllow);
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if ( self.isCancelled ) {
        return;
    }
    NSRange range = NSMakeRange(self.startOffset, data.length);
    NSError *error;
    [self.cacheWorker cacheData:data forRange:range error:&error];
    if ( error ) {
        if ( [self.delegate respondsToSelector:@selector(actionworker:didFinishWithError:)]) {
            [self.delegate actionworker:self didFinishWithError:error];
        }
        return;
    }
    [self.cacheWorker save];
    self.startOffset += data.length;
    if ( [self.delegate respondsToSelector:@selector(actionWorker:didReceiveData:isLocal:)]) {
        [self.delegate actionWorker:self didReceiveData:data isLocal:NO];
    }
}

- (void)notifyDownloadProgressWithFlush:(BOOL)flush finished:(BOOL)finished{
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.cacheWorker finishWriting];
    [self.cacheWorker save];
    if ( error ) {
        if ( [self.delegate respondsToSelector:@selector(actionworker:didFinishWithError:)]) {
            [self.delegate actionworker:self didFinishWithError:error];
        }
    }else{
        [self processActions];
    }
}

@end

@interface CHMediaDownloaderStatus()

@property(nonatomic,strong)NSMutableSet *downloadingURLS;

@end

@implementation CHMediaDownloaderStatus

+ (instancetype)shared
{
    static CHMediaDownloaderStatus *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.downloadingURLS = [NSMutableSet set];
    });
    return instance;
}

- (void)addURL:(NSURL *)url
{
    @synchronized (self.downloadingURLS) {
        [self.downloadingURLS addObject:url];
    }
}

- (void)removeURL:(NSURL *)url
{
    @synchronized (self.downloadingURLS) {
        [self.downloadingURLS removeObject:url];
    }
}

- (BOOL)containsURL:(NSURL *)url
{
    return [self.downloadingURLS containsObject:url];
}

- (NSSet *)urls
{
    return [self.downloadingURLS copy];
}


@end

@interface  CHMediaDownloader()<CHACtionWorkerDelegate>

@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)CHMediaCacheWorker *cacheWorker;
@property(nonatomic,strong)CHActionWorker *actionWorker;
@property(nonatomic,assign)BOOL downloadToEnd;

@end

#pragma mark -Class CHMediaDownloader
@implementation CHMediaDownloader

- (void)dealloc
{
    [[CHMediaDownloaderStatus shared] removeURL:self.url];
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if ( self ) {
        _url = url;
        _cacheWorker = [[CHMediaCacheWorker alloc] initWithURL:url];
        _info = _cacheWorker.cacheConfiguration.contentInfo;
    }
    
    return self;
}

- (void)downloadTaskFromOffset:(unsigned long long)fromOffset length:(NSUInteger)length toEnd:(BOOL)toEnd
{
    
}


@end
