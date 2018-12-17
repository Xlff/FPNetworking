//
//  FPServiceProtocol.h
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPNetworkingDefines.h"
#import <AFNetworking/AFNetworking.h>


@protocol FPServiceProtocol <NSObject>

@property(nonatomic, assign) FPServiceAPIEnvironment apiEnvironment;

- (NSURLRequest *)requestWithParams:(NSDictionary *)params
                             method:(NSString *)methodName
                        requestType:(FPAPIManagerRequestType)requestType;
- (NSDictionary *)requestWithResponseObject:(id)responseObject
                                   response:(NSURLResponse *)response
                                    request:(NSURLRequest *)request
                                      error:(NSError *)error;

/**
 如果检查错误之后, 需要z继续走fail路径上报到业务层的, 返回YES, (网络错误,弹框等)
 不需要继续走fail上报到业务层的 返回NO (token失效, 此时挂起API，调用刷新token的API，成功之后再重新调用原来的API)
 */
- (BOOL)handleCommonErrorWithResponse:(FPURLResponse *)response manager:(FPAPIBaseManager *)manager errorType:(FPAPIManagerErrorType)errorType;

@optional
- (AFHTTPSessionManager *)sessionManager;
@end
