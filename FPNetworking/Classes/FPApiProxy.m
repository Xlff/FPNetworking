//
//  FPApiProxy.m
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import "FPApiProxy.h"
#import <AFNetworking/AFNetworking.h>
#import "FPServiceProtocol.h"
#import "NSURLRequest+FPNetworkingMethods.h"

static NSString * const kFPApiProxyDispatchItemKeyCallbackSuccess = @"kFPApiProxyDispatchItemCallbackSuccess";
static NSString * const kFPApiProxyDispatchItemKeyCallbackFail = @"kFPApiProxyDispatchItemCallbackFail";

NSString * const kFPApiProxyValidateResultKeyResponseObject = @"kFPApiProxyValidateResultKeyResponseObject";
NSString * const kFPApiProxyValidateResultKeyResponseString = @"kFPApiProxyValidateResultKeyResponseString";

@interface FPApiProxy ()

@property(nonatomic, strong) NSMutableDictionary *dispatchTable;
@property(nonatomic, strong) NSNumber *recordedRequestId;
@end

@implementation FPApiProxy

+ (instancetype)sharedInstance
{
    static FPApiProxy *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[FPApiProxy alloc] init];
    });
    return shared;
}

- (AFHTTPSessionManager *)sessionManagerWithService:(id<FPServiceProtocol>)service
{
    AFHTTPSessionManager *sessionManager = nil;
    if ([service respondsToSelector:@selector(sessionManager)]) {
        sessionManager = service.sessionManager;
    }
    if (!sessionManager) {
        sessionManager = [AFHTTPSessionManager manager];
    }
    return sessionManager;
}

/// 这个函数的意义在于 若要换AFNetworking 只要修改这个函数的实现即可
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(FPCallBack)success fail:(FPCallBack)fail
{
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [[self sessionManagerWithService:request.service] dataTaskWithRequest:request
                                                                      uploadProgress:nil
                                                                    downloadProgress:nil
                                                                   completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                                       NSNumber *requestId = @([dataTask taskIdentifier]);
                                                                       [self.dispatchTable removeObjectForKey:requestId];
                                                                       
                                                                       NSDictionary *result = [request.service ilrequestWithResponseObject:responseObject
                                                                                                                                response:response
                                                                                                                                 request:request
                                                                                                                                   error:error];
                                                                       //输出返回数据
                                                                       FPURLResponse *fpResponse = [[FPURLResponse alloc] initWithResponseString:result[kFPApiProxyValidateResultKeyResponseString]
                                                                                                                                       requestId:requestId
                                                                                                                                         reqeust:request
                                                                                                                                  responseObject:result[kFPApiProxyValidateResultKeyResponseObject]
                                                                                                                                           error:error];
                                                                       
                                                                       if (error) {
                                                                           fail ? fail(fpResponse) : nil;
                                                                       }
                                                                       else {
                                                                           success ? success(fpResponse) : nil;
                                                                       }
                                                                       
                                                                   }];
    NSNumber *requestId = @([dataTask taskIdentifier]);
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    
    return  requestId;
}

- (void)cancelRequestWithRequestId:(NSNumber *)requestId
{
    NSURLSessionDataTask *dataTask = self.dispatchTable[requestId];
    [dataTask cancel];
    [self.dispatchTable removeObjectForKey:requestId];
}

- (void)cancelRequestWithRequestIds:(NSArray *)requestIds
{
    for (NSNumber *requestId in requestIds) {
        [self cancelRequestWithRequestId:requestId];
    }
}

- (NSMutableDictionary *)dispatchTable
{
    if (!_dispatchTable) {
        _dispatchTable = [NSMutableDictionary dictionary];
    }
    return _dispatchTable;
}


@end
