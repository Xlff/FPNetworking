//
//  FPServiceFactory.h
//  FPNetworking
//
//  Created by Max xie on 2018/12/13.
//  Copyright © 2018 w!zzard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPServiceProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface FPServiceFactory : NSObject

+ (instancetype)sharedInstance;

- (id<FPServiceProtocol>)serviceWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
