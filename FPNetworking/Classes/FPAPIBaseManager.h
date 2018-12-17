//
//  FPAPIBaseManager.h
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPURLResponse.h"
#import "FPNetworkingDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface FPAPIBaseManager : NSObject <NSCopying>

// 输出
@property(nonatomic, weak) id<FPAPIManagerCallBackDelegate> _Nullable delegate;
@property(nonatomic, weak) id<FPAPIManagerParamSource> _Nullable paramSource;
@property(nonatomic, weak) id<FPAPIManagerValidator> _Nullable validator;
@property(nonatomic, weak) NSObject<FPAPIManager> *_Nullable child; // 需要用到NSObject中的方法
/// 拦截器
@property(nonatomic, weak) id<FPAPIManagerInterceptor> _Nullable interceptor;

// 缓存
@property(nonatomic, assign) FPAPIManagerCachePolicy cachePolicy;
@property(nonatomic, assign) NSTimeInterval memoryCacheSecond; //默认 3 * 60
@property(nonatomic, assign) NSTimeInterval diskCacheSecond; // 3 * 60
@property(nonatomic, assign) BOOL shouldIgnoreCache; // 默认NO

// response
@property(nonatomic, strong) FPURLResponse *_Nullable response;
@property(nonatomic, readonly) FPAPIManagerErrorType errorType;
@property(nonatomic, copy,readonly) NSString *_Nullable errorMessage;

- (NSInteger)loadData;
+ (NSInteger)loadDataWithParams:(NSDictionary *_Nullable)params success:(void(^_Nullable)(FPAPIBaseManager *_Nonnull apiManager))success fail:(void(^_Nullable)(FPAPIBaseManager *_Nonnull apiManager))fail;

- (void)cancelAllRequests;
- (void)cancelRequest:(NSInteger)requestId;

- (id _Nullable)fetachDataWithReformer:(id <FPAPIManagerDataReformer> _Nullable)reformer;
- (void)cleanData;

@end

// 拦截
@interface FPAPIBaseManager (InnerInterceptor)

- (BOOL)beforePerformSuccessWithResponse:(FPURLResponse *_Nullable)response;
- (void)afterPerformSuccessWithResponse:(FPURLResponse *_Nullable)response;

- (BOOL)beforePerformFailWithResponse:(FPURLResponse *_Nullable)response;
- (void)afterPerformFailWithResponse:(FPURLResponse *_Nullable)response;

- (BOOL)shouldCallApiWithParams:(NSDictionary *_Nullable)params;
- (void)afterCallingApiWithParams:(NSDictionary *_Nullable)params;
@end

NS_ASSUME_NONNULL_END
