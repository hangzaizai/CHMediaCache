//
//  CHResourceLoader.h
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/26.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CHResourceLoaderDelegate;

@interface CHResourceLoader : NSObject

@property(nonatomic,strong,readonly)NSURL *url;
@property(nonatomic,weak)id <CHResourceLoaderDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url;

- (void)addRequest:(AVAssetResourceLoadingRequest *)request;

- (void)removeRequest:(AVAssetResourceLoadingDataRequest *)request;

- (void)cancel;

@end


@protocol CHResourceLoaderDelegate <NSObject>

- (void)resourceLoader:(CHResourceLoader *)resourceLoader didFailWithError:(NSError *)error;

@end
