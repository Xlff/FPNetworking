//
//  NSURLRequest+FPNetworkingMethods.h
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (FPNetworkingMethods)

@property(nonatomic, copy) NSDictionary *actualRequestParams;
@property(nonatomic, copy) NSDictionary *originRequestParams;
@property(nonatomic, strong) id<FPServiceProtocol> service;
@end

NS_ASSUME_NONNULL_END
