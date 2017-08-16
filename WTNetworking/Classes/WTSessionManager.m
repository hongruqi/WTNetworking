//
//  WTSessionManager.m
//  Pods
//
//  Created by walter on 28/07/2017.
//
//

#import "WTSessionManager.h"
#import "WTNetworkingError.h"
#import "AFNetworking.h"

@implementation WTResponseModel

@end

@implementation WTDownLoadRespModel

@end

@interface WTSessionManager()

@property (nonatomic, strong) AFHTTPSessionManager *afSessionManager;

@end


@implementation WTSessionManager

+ (WTSessionManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void)setValue:(NSString *)value forField:(NSString *)headerField
{
    [self.afSessionManager.requestSerializer setValue:value forHTTPHeaderField:headerField];
}

- (NSURLSessionTask *)getRequestWithUrl:(NSString *)url
                                 params:(NSDictionary *)params
                          completeBlock:(onCompletionBlock)completeBlock
                             errorBlock:(onErrorBlock)onError
{
    return [self httpRequestWithType:@"GET" url:url params:params data:nil completeBlock:completeBlock errorBlock:onError];
}

- (NSURLSessionTask *)postRequestWithUrl:(NSString *)url
                                  params:(NSDictionary *)params
                           completeBlock:(onCompletionBlock)completeBlock
                              errorBlock:(onErrorBlock)onError
{
    return [self httpRequestWithType:@"POST" url:url params:params data:nil completeBlock:completeBlock errorBlock:onError];
}

- (NSURLSessionTask *)uploadFileWithUrl:(NSString *)url
                                 params:(NSDictionary *)dict
                                   data:(NSData *)data
                          completeBlock:(onCompletionBlock)completeBlock
                             errorBlock:(onErrorBlock)onError
{
    return [self uploadFileWithUrl:url params:dict data:data progressBlock:nil completeBlock:completeBlock errorBlock:onError ];
}

- (NSURLSessionUploadTask *)uploadFileWithUrl:(NSString *)url
                                       params:(NSDictionary *)dict
                                         data:(NSData *)data
                                progressBlock:(onProgressBlock)progressBlock
                                completeBlock:(onCompletionBlock)completeBlock
                                   errorBlock:(onErrorBlock)onError

{
    return [self uploadFileWithUrl:url
                            params:dict
                              data:data
                              name:@"file"
                          fileName:@"file"
                          mimeType:@"application/octet-stream"
                     progressBlock:progressBlock
                     completeBlock:completeBlock
                        errorBlock:onError
                     ];
}


- (NSURLSessionTask *)httpRequestWithType:(NSString *)type
                                      url:(NSString *)url
                                   params:(NSDictionary *)params
                                     data:(NSData *)data
                            completeBlock:(onCompletionBlock)completeBlock
                               errorBlock:(onErrorBlock)onError
{
    NSMutableString *urlString = nil;
    
    if (![url hasPrefix:@"http"]) {
        urlString = [NSMutableString stringWithFormat:@"%@://%@", @"http", url];
    } else {
        urlString = [url copy];
    }
    // 设置证书
    //    [self setPinnedCertificates:nil url:url];
    
    if (self.timeoutInterval > 0) {
        self.afSessionManager.requestSerializer.timeoutInterval = self.timeoutInterval;
    } else {
        self.afSessionManager.requestSerializer.timeoutInterval = 15;
    }
    
    if ([type isEqualToString:@"POST"]) {
        NSURLSessionTask *task = [self.afSessionManager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completeBlock) {
                //存入缓存
                WTResponseModel *respModel = [WTResponseModel new];
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)task.response;
                respModel.response = httpResp;
                respModel.responseData = (NSData *)responseObject;
                respModel.httpHeaders = httpResp.allHeaderFields;
                completeBlock(respModel);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (onError) {
                onError([WTNetworkingError errorWithNSError:error]);
            }
        }];
        return task;
    } else if ([type isEqualToString:@"GET"]) {
        NSURLSessionTask *task = [self.afSessionManager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completeBlock) {
                WTResponseModel *respModel = [WTResponseModel new];
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)task.response;
                respModel.response = httpResp;
                respModel.responseData = (NSData *)responseObject;
                respModel.httpHeaders = httpResp.allHeaderFields;
                completeBlock(respModel);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (onError) {
                onError([WTNetworkingError errorWithNSError:error]);
            }
        }];
        return task;
    } else {
        return nil;
    }
}

- (NSURLSessionUploadTask *)uploadFileWithUrl:(NSString *)url
                                       params:(NSDictionary *)dict
                                         data:(NSData *)data
                                         name:(NSString *)name
                                     fileName:(NSString *)fileName
                                     mimeType:(NSString *)mimeType
                                progressBlock:(onProgressBlock)progressBlock
                                completeBlock:(onCompletionBlock)completeBlock
                                   errorBlock:(onErrorBlock)onError

{
    NSMutableString *urlString = nil;
    if (![url hasPrefix:@"http"]) {
        urlString = [NSMutableString stringWithFormat:@"%@://%@", @"http", url];
    } else {
        urlString = [url copy];
    }
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
    } error:nil];
    
    
    NSURLSessionUploadTask *uploadTask = [self.afSessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update the progress view
                progressBlock(uploadProgress);
            });
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completeBlock && responseObject) {
            NSData *responseData;
            if ([responseObject isKindOfClass:[NSData class]]) {
                responseData = responseObject;
            } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
            }
            
            WTResponseModel *respModel = [WTResponseModel new];
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            respModel.response = httpResp;
            respModel.responseData = responseData;
            respModel.httpHeaders = httpResp.allHeaderFields;
            completeBlock(respModel);
        } else if (onError && error) {
            onError(error);
        }
    }];
    
    [uploadTask resume];
    return uploadTask;
}

- (NSURLSessionDownloadTask *)downloadFileWithUrl:(NSString *)url
                                         filePath:(NSURL *)filePath
                                    progressBlock:(onProgressBlock)progressBlock
                                    downloadBlock:(onDownloadRespBlock)downloadBlock

{
    NSString *allowedUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *URL = [NSURL URLWithString:allowedUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [self.afSessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update the progress view
                progressBlock(downloadProgress);
            });
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        if (filePath) {
            documentsDirectoryURL = filePath;
        }
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        WTDownLoadRespModel *downModel = [WTDownLoadRespModel new];
        downModel.response = response;
        downModel.filePath = filePath;
        downModel.error = error;
        downloadBlock(downModel);
    }];
    
    [downloadTask resume];
    return downloadTask;
}

- (NSString *)headerCookie
{
    return @"";
}

- (NSArray *)operationQueue
{
    return self.afSessionManager.tasks;
}

- (void)setPinnedCertificates:(NSArray *)pinnedCertificates
{
    AFSecurityPolicy *securityPolicy;
    securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    NSSet *certSets = [NSSet setWithArray:pinnedCertificates];
    [securityPolicy setPinnedCertificates:certSets];
}

- (void)setPinnedCertificates:(NSData *)certData url:(NSString *)url
{
    AFSecurityPolicy *securityPolicy;
    if ([url hasPrefix:@"https"]) {
        //add https certificate
        securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        
        if (certData) {
            NSSet *certSets = [NSSet setWithArray:@[certData]];
            [securityPolicy setPinnedCertificates:certSets];
        }
    }else{
        securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    }
    
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    
    self.afSessionManager.securityPolicy = securityPolicy;
}

#pragma mark accesory
- (AFHTTPSessionManager *)afSessionManager {
    if (!_afSessionManager) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _afSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:config];
        _afSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [_afSessionManager.requestSerializer setValue:[self headerCookie] forHTTPHeaderField:@"Cookie"];
        [_afSessionManager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    return _afSessionManager;
}
@end
