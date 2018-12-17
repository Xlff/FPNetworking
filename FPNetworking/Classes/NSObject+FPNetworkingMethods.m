//
//  NSObject+FPNetworkingMethods.m
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import "NSObject+FPNetworkingMethods.h"

@implementation NSObject (FPNetworkingMethods)

- (id)FP_defaultValue:(id)defaultValue
{
    if (![defaultValue isKindOfClass:[self class]] || [self FP_isEmptyObject]) {
        return defaultValue;
    }
    
    return self;
}

- (BOOL)FP_isEmptyObject
{
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return  YES;
        }
    }
    return NO;
}

@end
