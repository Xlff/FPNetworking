//
//  NSURLRequest+FPNetworkingMethods.m
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import "NSURLRequest+FPNetworkingMethods.h"
#import <objc/runtime.h>

static void *FPNetworkingActualReqeustParams = &FPNetworkingActualReqeustParams;
static void *FPNetworkingOriginReqeustParams = &FPNetworkingOriginReqeustParams;
static void *FPNetworkingRequestService = &FPNetworkingRequestService;

@implementation NSURLRequest (FPNetworkingMethods)

- (void)setActualRequestParams:(NSDictionary *)actualRequestParams
{
    objc_setAssociatedObject(self, FPNetworkingActualReqeustParams, actualRequestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)actualRequestParams
{
    return objc_getAssociatedObject(self, FPNetworkingActualReqeustParams);
}

- (void)setOriginRequestParams:(NSDictionary *)originRequestParams
{
    objc_setAssociatedObject(self, FPNetworkingOriginReqeustParams, originRequestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)originRequestParams
{
    return objc_getAssociatedObject(self, FPNetworkingOriginReqeustParams);
}

- (void)setService:(id<FPServiceProtocol>)service
{
    objc_setAssociatedObject(self, FPNetworkingRequestService, service, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<FPServiceProtocol>)service
{
    return objc_getAssociatedObject(self, FPNetworkingRequestService);
}

@end
