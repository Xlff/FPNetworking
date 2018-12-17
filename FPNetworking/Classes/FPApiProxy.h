//
//  FPApiProxy.h
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPURLResponse.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^FPCallBack)(FPURLResponse *response);

@interface FPApiProxy : NSObject

+ (instancetype)sharedInstance;

- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(FPCallBack)success fail:(FPCallBack)fail;
- (void)cancelRequestWithRequestId:(NSNumber *)requestId;
- (void)cancelRequestWithRequestIds:(NSArray *)requestIds;

@end

NS_ASSUME_NONNULL_END
