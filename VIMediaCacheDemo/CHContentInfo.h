//
//  CHContentInfo.h
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/26.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHContentInfo : NSObject<NSCoding>

@property(nonatomic,copy)NSString *contentType;
@property(nonatomic,assign)BOOL byteRangeAccessSupported;
@property(nonatomic,assign)unsigned long long contentLength;
@property(nonatomic,assign)unsigned long long downloadedContentLength;

@end
