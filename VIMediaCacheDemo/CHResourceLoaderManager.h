//
//  CHResourceLoaderManager.h
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/26.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CHResourceLoaderManagerDelegate;

@interface CHResourceLoaderManager : NSObject<AVAssetResourceLoaderDelegate>

@property(nonatomic,weak) id<CHResourceLoaderManagerDelegate> delegate;

- (void)cleanCache;

- (void)cancelLoaders;

@end


@protocol CHResourceLoaderManagerDelegate <NSObject>

- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end
