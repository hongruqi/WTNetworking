//
//  WTRequest.m
//  Pods
//
//  Created by walter on 28/07/2017.
//
//

#import "WTRequest.h"
#import "WTNetworkingError.h"
#import "WTCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "YYModel.h"

@interface WTRequest()

@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation WTRequest
- (id)init
{
    if(self = [super init]) {
        self.fields = [NSMutableDictionary dictionaryWithCapacity:3];
        self.body = [NSMutableDictionary dictionaryWithCapacity:3];
        self.header = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return self;
}

- (NSString *)httpMethod
{
    return @"GET";
}

- (NSString *)modelName
{
    return _modelName;
}

- (BOOL)isRegularUrl:(NSString *)urlStirng
{
    NSURL *finalURL = [NSURL URLWithString:urlStirng];
    if (!finalURL) {
        return NO;
    }
    return YES;
}

- (BOOL)shouldCache {
    return YES;
}

- (BOOL)forceReload
{
    return YES;
}

- (NSString *)apiUrl
{
    return nil;
}

- (NSMutableDictionary *)header
{
    return nil;
}

- (void)sendRequest
{
    if ([self isCache]) {
        if (self.isList) {
            [self cachedList];
        }else{
            [self cachedData:[self uniqueIdentifier] url:self.apiUrl];
        }
    }else{
        if ([self.httpMethod isEqualToString:@"GET"]) {
            self.task = [[WTSessionManager sharedInstance] getRequestWithUrl:self.apiUrl params:self.fields completeBlock:[self completeBlock] errorBlock:[self errorBlock]];
        }else if ([self.httpMethod isEqualToString:@"POST"]){
            self.task = [[WTSessionManager sharedInstance] postRequestWithUrl:self.apiUrl params:self.fields completeBlock:[self completeBlock] errorBlock:[self errorBlock]];
        }
    }
}

- (onCompletionBlock)completeBlock
{
    __weak typeof(self) weakSelf = self;
    
    onCompletionBlock block = ^(WTResponseModel *model){
        weakSelf.task = nil;
        NSData *data = model.responseData;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options: 0 error:nil];
        
        if(data.length <= 0){
            NSInteger code = [jsonDict[@"errCode"] intValue];
            NSString *errorMessage = jsonDict[@"errMessage"];
            WTNetworkingError *netError = [WTNetworkingError errorWithCode:code errorMessage:errorMessage];
            if(weakSelf.errorBlock)
                weakSelf.errorBlock(netError);
            return ;
        }
        
        if (self.completionBlock){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                Class clzz = NSClassFromString(self.modelName);
                id dataModel = nil;
                 if (self.shouldCache) {
                    if (self.isList) {
                        dataModel = [NSArray yy_modelArrayWithClass:clzz json:data];
                        if ([dataModel isKindOfClass:[NSArray class]]) {
                            [[WTCache instance] saveListWithArray:dataModel objectClass:clzz version:self.apiVersion];
                        }
                    }else{
                        dataModel = [clzz yy_modelWithJSON:data];
                        [[WTCache instance] saveCacheData:data forKey:self.uniqueIdentifier];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (dataModel && [dataModel isKindOfClass:[WTNetworkingError class]]) {
                        //error
                        self.completionBlock(nil);
                    } else if (dataModel) {
                        self.completionBlock(dataModel);
                    }
                });
            });
        }
    };
    
    return [block copy];
}

- (onErrorBlock)errorBlock
{
    //block将持有self
    __weak typeof(self) weakSelf = self;
    
    onErrorBlock block = ^(WTNetworkingError *error){
        
        if(weakSelf.errorBlock){
            weakSelf.errorBlock(error);
        }
        
        weakSelf.task = nil;
    };
    
    return [block copy];
}

- (void)cachedList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Class clzz = NSClassFromString(self.modelName);
        NSArray *list = [[WTCache instance] cacheDataWithClass:clzz version:self.apiVersion];
        id dataModel = nil;
        
        if(list) {
            dataModel = list;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dataModel) {
                self.completionBlock(dataModel);
            }
            
            self.task = [[WTSessionManager sharedInstance] getRequestWithUrl:self.apiUrl params:self.fields completeBlock:[self completeBlock] errorBlock:[self errorBlock]];
            
        });
    });
}
- (void)cachedData:(NSString *)key url:(NSString *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id dataModel = nil;
        NSData *cacheData = [[WTCache instance] cachedDataForKey:key];
        if(cacheData) {
            id responseObject = [NSJSONSerialization JSONObjectWithData:cacheData options:NSJSONReadingMutableContainers error:nil];
            dataModel = responseObject;
            if (responseObject) {
                Class clzz = NSClassFromString(self.modelName);
                dataModel = [clzz yy_modelWithJSON:dataModel];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dataModel) {
                self.completionBlock(dataModel);
            }
            
            self.task = [[WTSessionManager sharedInstance] getRequestWithUrl:self.apiUrl params:self.fields completeBlock:[self completeBlock] errorBlock:[self errorBlock]];
            
        });
    });
}

- (void)cancelRequest
{
    if (self.task) {
        [self.task cancel];
        self.task = nil;
    }
}

- (BOOL)isExecuting
{
    return self.task && self.task.state == NSURLSessionTaskStateRunning;
}

- (NSString *)uniqueIdentifier {
    NSMutableString *filename = [[NSMutableString alloc] init];
    filename = [NSMutableString stringWithFormat:@"%@", [self apiUrl]];
    [self.fields enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL * stop) {
        [filename appendFormat:@"%@%@", key, obj];
    }];
    return [self md5:filename];
}

- (BOOL)isCache
{
    if (self.shouldCache && !self.forceReload) {
        return YES;
    }
    
    return NO;
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    if(cStr)
    {
        CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
        return [[NSString stringWithFormat:
                 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
                 ] lowercaseString];
    }
    else {
        return nil;
    }
}

@end
