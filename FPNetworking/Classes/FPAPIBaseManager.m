//
//  FPAPIBaseManager.m
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import "FPAPIBaseManager.h"
#import "FPApiProxy.h"
#import "FPServiceProtocol.h"
#import "FPServiceFactory.h"
#import "NSURLRequest+FPNetworkingMethods.h"

NSString *const kFPUserTokenInvalidNotification = @"kFPUserTokenInvalidNotification";
NSString *const kFPUserTokenIllegalNotification = @"kFPUserTokenIllegalNotification";
NSString *const kFPUserTokenNotificationUserInfoKeyManagerToContinue = @"kFPUserTokenNotificationUserInfoKeyManagerToContinue";

NSString *const kFPAPIBaseManagerRequestID = @"kFPAPIBaseManagerRequestID";

@interface FPAPIBaseManager ()
@property(nonatomic, strong) id fetchedRawData;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, copy, readwrite) NSString *errorMessage;
@property(nonatomic, readwrite) FPAPIManagerErrorType errorType;
@property (nonatomic, strong) NSMutableArray *requestIdList;
@property (nonatomic, copy, nullable) void (^successBlock)(FPAPIBaseManager *apimanager);
@property (nonatomic, copy, nullable) void (^failBlock)(FPAPIBaseManager *apimanager);

@end

@implementation FPAPIBaseManager

#pragma mark - Life Circle
- (instancetype)init
{
    if (self = [super init]) {
        _delegate = nil;
        _validator = nil;
        _paramSource = nil;
        _fetchedRawData = nil;
        _errorType = FPAPIManagerErrorTypeDefault;
        _errorMessage = nil;
        _memoryCacheSecond = 3 * 60;
        _diskCacheSecond = 3 * 60;
        
        if ([self conformsToProtocol:@protocol(FPAPIManager)]) {
            self.child = (id <FPAPIManager>)self;
        }
        else {
            NSException *exception = [[NSException alloc] init];
            @throw exception;
        }
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)cancelAllRequests
{
    [[FPApiProxy sharedInstance] cancelRequestWithRequestIds:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequest:(NSInteger)requestId
{
    [self removeRequestWithRequestId:requestId];
    [[FPApiProxy sharedInstance] cancelRequestWithRequestId:@(requestId)];
}

- (id)fetachDataWithReformer:(id<FPAPIManagerDataReformer>)reformer
{
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        resultData = [reformer manager:self reformData:self.fetchedRawData];
    }
    else {
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}

- (NSInteger)loadData
{
    NSDictionary *params = [self.paramSource paramsForApi:self];
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}

+ (NSInteger)loadDataWithParams:(NSDictionary *)params success:(void (^)(FPAPIBaseManager * _Nonnull))success fail:(void (^)(FPAPIBaseManager * _Nonnull))fail
{
    return [[[self alloc] init] loadDataWithParams:params success:success fail:fail];
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params success:(void(^)(FPAPIBaseManager *))success fail:(void(^)(FPAPIBaseManager *))fail
{
    self.successBlock = success;
    self.failBlock =  fail;
    return [self loadDataWithParams:params];
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params
{
    NSInteger requestId = 0;
    NSDictionary *reformedParams = [self reformParams:params];
    if (!reformedParams) {
        reformedParams = @{};
    }
    
    if ([self shouldCallApiWithParams:reformedParams]) {
        FPAPIManagerErrorType errorType = [self.validator manager:self isCorrentWithParamsData:reformedParams];
        if (errorType == FPAPIManagerErrorTypeNoError) {
            FPURLResponse *response = nil;
            // 先检查 内存 缓存
            if ((self.cachePolicy & FPAPIManagerCachePolicyMemory) && self.shouldIgnoreCache == NO) {
                //TODO: 取 内存缓存
            }
            
            // 检查 磁盘 缓存
            if ((self.cachePolicy & FPAPIManagerCachePolicyDisk) && self.shouldIgnoreCache == NO) {
                //TODO: 取 磁盘 缓存
            }
            
            if (response) {
                [self successedOnCallingAPI:response];
                return 0;
            }
            /// TODO: 判断网络状态
            /// 实际网络请求
            if (YES) {
                self.isLoading = YES;
                id <FPServiceProtocol> service = [[FPServiceFactory sharedInstance] serviceWithIdentifier:self.child.serviceIdentifier];
                NSURLRequest *request = [service requestWithParams:params
                                                            method:self.child.methodName
                                                       requestType:self.child.requestType];
                request.service = service;
                
                // 打印 请求
                NSNumber *requestId = [[FPApiProxy sharedInstance] callApiWithRequest:request success:^(FPURLResponse * _Nonnull response) {

                    [self successedOnCallingAPI:response];
                } fail:^(FPURLResponse * _Nonnull response) {
                    FPAPIManagerErrorType failType = FPAPIManagerErrorTypeDefault;
                    if (response.status == FPURLResponseStatusErrorCancel) {
                        failType = FPAPIManagerErrorTypeCanceled;
                    }
                    else if (response.status == FPURLResponseStatusErrorTimeOut) {
                        failType = FPAPIManagerErrorTypeTimeout;
                    }
                    else if (response.status == FPURLResponseStatusErrorNoNetwork) {
                        failType = FPAPIManagerErrorTypeNoNetWork;
                    }
                    [self failedOnCallingAPI:response error:failType];
                }];
                [self.requestIdList addObject:requestId];
                
                NSMutableDictionary *params = [reformedParams mutableCopy];
                params[kFPAPIBaseManagerRequestID] = requestId;
                [self afterCallingApiWithParams:params];
                return requestId.integerValue;
            }
            else {
                [self failedOnCallingAPI:nil error:FPAPIManagerErrorTypeNoNetWork];
            }
        }
        else {
            [self failedOnCallingAPI:nil error:errorType];
        }
    }
    
    
    return requestId;
}

#pragma mark - API CallBack
- (void)successedOnCallingAPI:(FPURLResponse *)response
{
    self.isLoading = NO;
    self.response = response;
    self.fetchedRawData = response.content ? [response.content copy] : [response.repsonseData copy];
    
    [self removeRequestWithRequestId:response.requestId];
    
    FPAPIManagerErrorType errorType = [self.validator manager:self isCorrentWithCallBackData:response.content];
    if (errorType == FPAPIManagerErrorTypeNoError) {
        if (self.cachePolicy != FPAPIManagerCachePolicyNoCache && response.isCache == NO) {
            // TODO: 存 缓存
            if (self.cachePolicy == FPAPIManagerCachePolicyMemory) {
                // 内存
            }
            else {
                // 磁盘
            }
        }
        
        if ([self.interceptor respondsToSelector:@selector(manager:didReceiveResponse:)]) {
            [self.interceptor manager:self didReceiveResponse:response];
        }
        
        if ([self beforePerformSuccessWithResponse:response]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(managerCallAPIDidSuccess:)]) {
                    [self.delegate managerCallAPIDidSuccess:self];
                }
                if (self.successBlock) {
                    self.successBlock(self);
                }
            });
        }
        [self afterPerformSuccessWithResponse:response];
    }
    else {
        [self failedOnCallingAPI:response error:errorType];
    }
}

- (void)failedOnCallingAPI:(FPURLResponse *)response error:(FPAPIManagerErrorType)errorType
{
    self.isLoading = NO;
    if (response) {
        self.response = response;
    }
    self.errorType = errorType;
    [self removeRequestWithRequestId:response.requestId];
    
    if (errorType == FPAPIManagerErrorTypeNeedLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFPUserTokenIllegalNotification
                                                            object:nil
                                                          userInfo:@{kFPUserTokenNotificationUserInfoKeyManagerToContinue : self}];
        return;
    }
    
    if (errorType == FPAPIManagerErrorTypeNeedAccessToken) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFPUserTokenInvalidNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kFPUserTokenNotificationUserInfoKeyManagerToContinue : self
                                                                     }];
        return;
    }
    
//    id<FPServiceProtocol> service = [
    if (errorType == FPAPIManagerErrorTypeNoNetWork) {
        self.errorMessage = @"无网络连接, 请检查网络";
    }
    else if (errorType == FPAPIManagerErrorTypeTimeout) {
        self.errorMessage = @"请求超时";
    }
    else if (errorType == FPAPIManagerErrorTypeCanceled) {
        self.errorMessage = @"您已取消";
    }
    else if (errorType == FPAPIManagerErrorTypeDownGrade) {
        self.errorMessage = @"网络拥塞";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.interceptor respondsToSelector:@selector(manager:didReceiveResponse:)]) {
            [self.interceptor manager:self didReceiveResponse:response];
        }
        
        if ([self beforePerformFailWithResponse:response]) {
            [self.delegate managerCallAPIDIdFail:self];
        }
        if (self.failBlock) {
            self.failBlock(self);
        }
        [self afterPerformFailWithResponse:response];
    });
}

#pragma mark - Interceptor Method 拦截器
/*
 拦截器的功能可以由子类通过继承实现，也可以由其它对象实现,两种做法可以共存
 当两种情况共存的时候，子类重载的方法一定要调用一下super
 然后它们的调用顺序是BaseManager会先调用子类重载的实现，再调用外部interceptor的实现
 
 notes:
 正常情况下，拦截器是通过代理的方式实现的，因此可以不需要以下这些代码
 但是为了将来拓展方便，如果在调用拦截器之前manager又希望自己能够先做一些事情，所以这些方法还是需要能够被继承重载的
 所有重载的方法，都要调用一下super,这样才能保证外部interceptor能够被调到
 这就是decorate pattern
*/

- (BOOL)beforePerformSuccessWithResponse:(FPURLResponse *)response
{
    BOOL result = YES;
    self.errorType = FPAPIManagerErrorTypeSuccess;
    if ((NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformSuccessWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
    return result;
}


- (void)afterPerformSuccessWithResponse:(FPURLResponse *)response
{
    if ((NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailWithResponse:(FPURLResponse *)response
{
    BOOL result = YES;
    if ((NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
    return result;
}

- (void)afterPerformFailWithResponse:(FPURLResponse *)response
{
    if ((NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

/// 只有返回YES 才继续调用API
- (BOOL)shouldCallApiWithParams:(NSDictionary *)params
{
    if ((NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    }
    return YES;
}

- (void)afterCallingApiWithParams:(NSDictionary *)params
{
    if ((NSInteger)self != (NSInteger)self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}

#pragma mark - Child Method
- (void)cleanData
{
    self.fetchedRawData = nil;
    self.errorType = FPAPIManagerErrorTypeDefault;
}

/// 如果需要在调用API之前额外添加一些参数, 比如pageNumber和pageSize之类的就在这添加... 子类中 覆盖这个函数的时候就y不要调用[super reformParams:params];
- (NSDictionary *)reformParams:(NSDictionary *)params
{
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    if (childIMP == selfIMP) {
        return params;
    }
    else {
        // 如果child是继承来的, 那么这里就不会跑到,会直接跑子类中的IMP
        // 如果child是另一个对象, 就会跑到这里
        NSDictionary *result = nil;
        result = [self.child reformParams:params];
        return result ? result : params;
    }
}

#pragma mark - Private Method
- (void)removeRequestWithRequestId:(NSInteger)requestId
{
    NSNumber *requestId2Remove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if (storedRequestId.integerValue == requestId) {
            requestId2Remove = storedRequestId;
            break;
        }
    }
    if (requestId2Remove) {
        [self.requestIdList removeObject:requestId2Remove];
    }
}

- (NSMutableArray *)requestIdList
{
    if (!_requestIdList) {
        _requestIdList = [NSMutableArray array];
    }
    return _requestIdList;
}

- (BOOL)isLoading
{
    if (self.requestIdList.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}

@end

