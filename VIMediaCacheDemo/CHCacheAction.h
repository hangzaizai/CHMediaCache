//
//  CHCacheAction.h
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/26.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,CHCacheActionType){
    CHCacheActionTypeLocal = 0,
    CHCacheActionTypeRemote
};

@interface CHCacheAction : NSObject

- (instancetype)initWithActionType:(CHCacheActionType)actionType range:(NSRange)range;
@property(nonatomic,assign)CHCacheActionType actionType;
@property(nonatomic,assign)NSRange range;

@end
