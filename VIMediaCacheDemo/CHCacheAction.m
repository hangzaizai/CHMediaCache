//
//  CHCacheAction.m
//  VIMediaCacheDemo
//
//  Created by chenhang on 2017/7/26.
//  Copyright © 2017年 Vito. All rights reserved.
//

#import "CHCacheAction.h"

@implementation CHCacheAction

- (instancetype)initWithActionType:(CHCacheActionType)actionType range:(NSRange)range
{
    self = [super init];
    if ( self ) {
        _actionType = actionType;
        _range = range;
        //测试git
    }
    
    return self;
}

- (BOOL)isEqual:(CHCacheAction *)object
{
    if ( !NSEqualRanges(object.range, self.range)) {
        return NO;
    }
    if ( object.actionType != self.actionType ) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@%@", NSStringFromRange(self.range), @(self.actionType)] hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"actionType %@ range:%@",@(self.actionType),NSStringFromRange(self.range)];
}

@end
