//
//  WTNetworkingError.m
//  Pods
//
//  Created by walter on 28/07/2017.
//
//

#import "WTNetworkingError.h"

static NSString *kQuvideoErrorDomain = @"com.quvideo.xy";

@interface WTNetworkingError()

@property (nonatomic, copy, readwrite) NSString *errorMessage;

@end


@implementation WTNetworkingError

+ (void)setErrorDomain:(NSString *)errorDomain
{
    kQuvideoErrorDomain = errorDomain;
}

+ (WTNetworkingError *)errorWithRestInfo:(NSDictionary*)restInfo
{
    NSNumber* errorCode = [restInfo objectForKey:@"errCode"];
    WTNetworkingError *error = [WTNetworkingError errorWithDomain:kQuvideoErrorDomain code:[errorCode intValue] userInfo:restInfo];
    return error;
}

+ (NSString *)errorMessage:(WTNetworkingError *)error
{
    return error.userInfo[@"errMessage"];
}


+ (WTNetworkingError*)errorWithNSError:(NSError*)error
{
    WTNetworkingError *myError = [WTNetworkingError errorWithDomain:error.domain code:error.code userInfo:error.userInfo];
    return myError;
}

+ (WTNetworkingError*)errorWithCode:(NSInteger)code errorMessage:(NSString*)errorMessage
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [userInfo setObject:[NSString stringWithFormat:@"%ld", (long)code] forKey:@"errCode"];
    if (errorMessage) {
        [userInfo setObject:errorMessage forKey:@"errMessage"];
    }
    
    WTNetworkingError* error = [WTNetworkingError errorWithDomain:kQuvideoErrorDomain code:code userInfo:userInfo];
    error.errorMessage = errorMessage;
    
    return error;
    
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
    
    if (self = [super initWithDomain:domain code:code userInfo:dict]) {
    }
    
    return self;
}

- (NSString *)methodForRestApi
{
    NSDictionary* userInfo = self.userInfo;
    if (!userInfo) {
        return nil;
    }
    
    NSArray* requestArgs = [userInfo objectForKey:@"request_args"];
    if (!requestArgs) {
        return nil;
    }
    
    for (NSDictionary* pair in requestArgs) {
        if (NSOrderedSame == [@"method" compare:[pair objectForKey:@"key"]]) {
            return [pair objectForKey:@"value"];
        }
    }
    
    return nil;
}

@end
