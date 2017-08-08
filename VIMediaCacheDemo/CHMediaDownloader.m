//
//  CHMediaDownloader.m
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/26.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import "CHMediaDownloader.h"

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

@property(nonatomic,strong)

@end
@implementation CHActionWorker
@end


#pragma mark -Class CHMediaDownloader
@implementation CHMediaDownloader

@end
