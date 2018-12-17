//
//  FPServiceFactory.m
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import "FPServiceFactory.h"

@interface FPServiceFactory ()

@property(nonatomic, strong) NSMutableDictionary *serviceStorage;

@end

@implementation FPServiceFactory


+ (instancetype)sharedInstance
{
    static FPServiceFactory *factory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory = [[FPServiceFactory alloc] init];
    });
    return factory;
}

- (id<FPServiceProtocol>)serviceWithIdentifier:(NSString *)identifier
{
    if (!self.serviceStorage[identifier]) {
        self.serviceStorage[identifier] = [self createServiceWithIdentifier:identifier];
    }
    return self.serviceStorage[identifier];
}

- (id <FPServiceProtocol>)createServiceWithIdentifier:(NSString *)identifier
{
    Class class = NSClassFromString(identifier);
    if (class) {
        return [[class alloc] init];
    }
    @throw [[NSException alloc] init];
}


- (NSMutableDictionary *)serviceStorage
{
    if (!_serviceStorage) {
        _serviceStorage = [NSMutableDictionary dictionary];
    }
    return _serviceStorage;
}


@end
