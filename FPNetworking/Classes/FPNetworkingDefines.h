//
//  FPNetworkingDefines.h
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#ifndef FPNetworkingDefines_h
#define FPNetworkingDefines_h

#import <UIKit/UIKit.h>

@class FPAPIBaseManager;
@class FPURLResponse;

typedef NS_ENUM(NSUInteger, FPServiceAPIEnvironment) {
    FPServiceAPIEnvironmentDevelop,
    FPServiceAPIEnvironmentReleaseCandiadate,
    FPServiceAPIEnvironmentRelease,
};

typedef NS_ENUM(NSUInteger, FPAPIManagerRequestType) {
    FPAPIManagerRequestTypeGet,
    FPAPIManagerRequestTypePost,
    FPAPIManagerRequestTypePut,
    FPAPIManagerRequestTypeDelete
};

typedef NS_ENUM(NSUInteger, FPAPIManagerErrorType) {
    FPAPIManagerErrorTypeNeedAccessToken, // 需要重新刷新accessToken
    FPAPIManagerErrorTypeNeedLogin,       // 需要登陆
    FPAPIManagerErrorTypeDefault,         // 没有产生过API请求，这个是manager的默认状态。
    FPAPIManagerErrorTypeLoginCanceled,   // 调用API需要登陆态，弹出登陆页面之后用户取消登陆了
    FPAPIManagerErrorTypeSuccess,         // API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    FPAPIManagerErrorTypeNoContent,       // API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    FPAPIManagerErrorTypeParamsError,     // 参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    FPAPIManagerErrorTypeTimeout,         // 请求超时。FPAPIProxy设置的是20秒超时，具体超时时间的设置请自己去看FPAPIProxy的相关代码。
    FPAPIManagerErrorTypeNoNetWork,       // 网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    FPAPIManagerErrorTypeCanceled,        // 取消请求
    FPAPIManagerErrorTypeNoError,         // 无错误
    FPAPIManagerErrorTypeDownGrade,       // APIManager被降级了
};

typedef NS_OPTIONS(NSUInteger, FPAPIManagerCachePolicy) {
    FPAPIManagerCachePolicyNoCache = 0,
    FPAPIManagerCachePolicyMemory = 1 << 0,
    FPAPIManagerCachePolicyDisk = 1 << 1,
};

// ->FPAPIBaseManager.m
extern NSString * _Nonnull const kFPAPIBaseManagerRequestID;

/// 通知 -> FPAPIBaseManager.m
extern NSString * _Nonnull const kFPUsetTokenInvalidNotification;
extern NSString * _Nonnull const kFPUserTokenIllegalNotification;
extern NSString * _Nonnull const kFPUserTokenNotificationUserInfoKeyManagerToContinue;

/// 结果 -> FPAPIProxy.m
extern NSString * _Nonnull const kFPApiProxyValidateResultKeyResponseObject;
extern NSString * _Nonnull const kFPApiProxyValidateResultKeyResponseString;

/// *****************API管理协议
@protocol FPAPIManager <NSObject>
@required
- (NSString * _Nonnull)methodName;
- (NSString * _Nonnull)serviceIdentifier;
- (FPAPIManagerRequestType)requestType;

@optional
- (void)cleanData;
- (NSDictionary *_Nullable)reformParams:(NSDictionary *_Nullable)params;
- (NSInteger)loadDataWithParams:(NSDictionary *_Nullable)params;

@end

/// ************ API 拦截协议
@protocol FPAPIManagerInterceptor <NSObject>

@optional
- (BOOL)manager:(FPAPIBaseManager *_Nonnull)manager beforePerformSuccessWithResponse:(FPURLResponse *_Nonnull)response;
- (void)manager:(FPAPIBaseManager *_Nonnull)manager afterPerformSuccessWithResponse:(FPURLResponse *_Nonnull)response;

- (BOOL)manager:(FPAPIBaseManager *_Nonnull)manager beforePerformFailWithResponse:(FPURLResponse *_Nonnull)response;
- (void)manager:(FPAPIBaseManager *_Nonnull)manager afterPerformFailWithResponse:(FPURLResponse *_Nonnull)response;

- (BOOL)manager:(FPAPIBaseManager *_Nonnull)manager shouldCallAPIWithParams:(NSDictionary *_Nullable)params;
- (void)manager:(FPAPIBaseManager *_Nonnull)manager afterCallingAPIWithParams:(NSDictionary *_Nullable)params;
- (void)manager:(FPAPIBaseManager *)manager didReceiveResponse:(FPURLResponse *_Nullable)reponse;

@end

/// ************* CallBack
@protocol FPAPIManagerCallBackDelegate <NSObject>

@required
- (void)managerCallAPIDidSuccess:(FPAPIBaseManager *_Nonnull)manager;
- (void)managerCallAPIDIdFail:(FPAPIBaseManager *_Nonnull)manager;

@end

/// ********  分页 请求
@protocol FPPageableAPIManager <NSObject>

@property(nonatomic, assign) NSInteger pageSize;
@property(nonatomic, assign, readonly) NSUInteger currentPageNumber;
@property(nonatomic, assign, readonly) BOOL isFirstPage;
@property(nonatomic, assign, readonly) BOOL isLastPage;

- (void)loadNextPage;

@end

/// ********  数据整理
@protocol FPAPIManagerDataReformer <NSObject>

@required
- (id _Nullable)manager:(FPAPIBaseManager *_Nonnull)manager reformData:(NSDictionary *_Nullable)data;

@end

/// ******* 校验
@protocol FPAPIManagerValidator <NSObject>

@required
- (FPAPIManagerErrorType)manager:(FPAPIBaseManager *_Nonnull)manager isCorrentWithCallBackData:(NSDictionary *_Nullable)data;
- (FPAPIManagerErrorType)manager:(FPAPIBaseManager *_Nonnull)manager isCorrentWithParamsData:(NSDictionary *_Nullable)data;

@end

@protocol FPAPIManagerParamSource <NSObject>

@required
- (NSDictionary *_Nullable)paramsForApi:(FPAPIBaseManager *_Nonnull)manager;

@end




#endif /* FPNetworkingDefines_h */
