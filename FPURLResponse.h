//
//  FPURLResponse.h
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FPURLResponseStatus) {
    FPURLResponseStatusSuccess, // 作为底层,请求是否成功只考虑是否成功收到服务器的反馈,至于签名是否正确,返回的数据是否完整,由上层FPAPIBaseManager决定
    FPURLResponseStatusErrorTimeOut,
    FPURLResponseStatusErrorCancel,
    FPURLResponseStatusErrorNoNetwork  // 默认除超时外的错误都是无网络错误
};

@interface FPURLResponse : NSObject

@property(nonatomic, assign, readonly) FPURLResponseStatus status;
@property(nonatomic, copy, readonly) NSString *contentString;
@property(nonatomic, copy, readonly) id content;
@property(nonatomic, assign, readonly) NSInteger requestId;
@property(nonatomic, copy, readonly) NSURLRequest *request;
@property(nonatomic, copy, readonly) NSData *repsonseData;
@property(nonatomic, strong, readonly) NSString *errorMessage;

@property(nonatomic, copy) NSDictionary *actualRequestParams;
@property(nonatomic, copy) NSDictionary *originRequestParams;
@property(nonatomic, strong) NSString *logString;

@property(nonatomic, assign, readonly) BOOL isCache;

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId reqeust:(NSURLRequest *)request responseObject:(id)responseObject error:(NSError *)error;

/// isCache 是YES
- (instancetype)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
