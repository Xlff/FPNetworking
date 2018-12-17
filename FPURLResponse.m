//
//  FPURLResponse.m
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import "FPURLResponse.h"
#import "NSObject+FPNetworkingMethods.h"
#import "NSURLRequest+FPNetworkingMethods.h"

@interface FPURLResponse ()

@property (nonatomic, assign, readwrite) FPURLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *contentString;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;
@property (nonatomic, strong, readwrite) NSString *errorMessage;

@end

@implementation FPURLResponse

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId reqeust:(NSURLRequest *)request responseObject:(id)responseObject error:(NSError *)error
{
    if (self = [super init]) {
        self.contentString = [responseObject FP_defaultValue:@""];
        self.requestId = [requestId integerValue];
        self.request = request;
        self.actualRequestParams = request.actualRequestParams;
        self.originRequestParams = request.originRequestParams;
        self.isCache = NO;
        self.status = [self responseStatusWithError:error];
        self.content = responseObject ? responseObject : @{};
        self.errorMessage = [NSString stringWithFormat:@"%@",error];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        self.contentString = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
        self.status = FPURLResponseStatusSuccess;
        self.requestId = 0;
        self.responseData = data;
        self.request = nil;
        self.content = [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableContainers
                                                         error:NULL];
        self.isCache = YES;
    }
    return self;
}


- (FPURLResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        FPURLResponseStatus result = FPURLResponseStatusErrorNoNetwork;
        if (error.code == NSURLErrorTimedOut) {
            result = FPURLResponseStatusErrorTimeOut;
        }
        if (error.code == NSURLErrorCancelled) {
            result = FPURLResponseStatusErrorCancel;
        }
        if (error.code == NSURLErrorNotConnectedToInternet) {
            result = FPURLResponseStatusErrorNoNetwork;
        }
        return result;
    }
    return FPURLResponseStatusSuccess;
}

- (NSData *)responseData
{
    if (!_responseData) {
        NSError *error = nil;
        _responseData = [NSJSONSerialization dataWithJSONObject:self.content options:0 error:&error];
        if (error) {
            _responseData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return _responseData;
}


@end
