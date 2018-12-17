//
//  NSObject+FPNetworkingMethods.h
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (FPNetworkingMethods)

- (id)FP_defaultValue:(id)defaultValue;

- (BOOL)FP_isEmptyObject;

@end

NS_ASSUME_NONNULL_END
