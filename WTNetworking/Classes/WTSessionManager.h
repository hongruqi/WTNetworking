//
//  WTSessionManager.h
//  Pods
//
//  Created by walter on 28/07/2017.
//
//

#import <Foundation/Foundation.h>

typedef void (^onCompletionBlock)(id result);
typedef void (^onErrorBlock) (id error);
typedef void (^onProgressBlock)(id progeress);
typedef void (^onDownloadRespBlock)(id respModel);

@interface WTDownLoadRespModel : NSObject

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSURL *filePath;
@property (nonatomic, strong) NSError *error;

@end

@interface WTResponseModel : NSObject

@property (nonatomic, copy) NSHTTPURLResponse *response;
@property (nonatomic, copy) NSDictionary *httpHeaders;
@property (nonatomic, copy) NSData *responseData;

@end

@interface WTSessionManager : NSObject
/**
 *  缓存策略，仅生效一次
 */
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/**
 *  超时时间
 */
@property (nonatomic, assign) NSInteger timeoutInterval;

@property (nonatomic, strong) NSArray *operationQueue;

+ (WTSessionManager *)sharedInstance;

/**
 *  以get方式去做网络请求
 *
 *  @param url              请求地址
 *  @param params           请求参数
 *  @param completeBlock    请求成功回调
 *  @param onError          请求失败回调
 *
 *  @return NSURLSessionTask
 */
- (NSURLSessionTask *)getRequestWithUrl:(NSString *)url
                                 params:(NSDictionary *)params
                          completeBlock:(onCompletionBlock)completeBlock
                             errorBlock:(onErrorBlock)onError;

/**
 *  以post方式去做网络请求
 *
 *  @param url              请求地址
 *  @param params           请求参数
 *  @param completeBlock    请求成功回调
 *  @param onError          请求失败回调
 *
 *  @return NSURLSessionTask
 */
- (NSURLSessionTask *)postRequestWithUrl:(NSString *)url
                                  params:(NSDictionary *)params
                           completeBlock:(onCompletionBlock)completeBlock
                              errorBlock:(onErrorBlock)onError;

/**
 *  上传文件
 *
 *  @param url              请求地址
 *  @param params           请求参数
 *  @param data             fileData
 *  @param completeBlock    上传成功回调
 *  @param onError          上传失败回调
 *
 *  @return NSURLSessionTask
 */
- (NSURLSessionTask *)uploadFileWithUrl:(NSString *)url
                                 params:(NSDictionary *)params
                                   data:(NSData *)data
                          completeBlock:(onCompletionBlock)completeBlock
                             errorBlock:(onErrorBlock)onError;

//支持progress
- (NSURLSessionUploadTask *)uploadFileWithUrl:(NSString *)url
                                       params:(NSDictionary *)dict
                                         data:(NSData *)data
                                progressBlock:(onProgressBlock)progressBlock
                                completeBlock:(onCompletionBlock)completionBlock
                                   errorBlock:(onErrorBlock)onError;

/**
 *  上传文件
 *
 *  @param url              请求地址
 *  @param dict             请求参数
 *  @param data             fileData
 *  @param name             文件对应的表单项名字
 *  @param fileName         文件名
 *  @param mimeType         文件 mime
 *  @param completeBlock    上传成功回调
 *  @param onError          上传失败回调
 *  @param progressBlock    上传进度回调
 *
 *  @return NSURLSessionUploadTask
 */
- (NSURLSessionUploadTask *)uploadFileWithUrl:(NSString *)url
                                       params:(NSDictionary *)dict
                                         data:(NSData *)data name:(NSString *)name
                                     fileName:(NSString *)fileName
                                     mimeType:(NSString *)mimeType
                                progressBlock:(onProgressBlock)progressBlock
                                completeBlock:(onCompletionBlock)completeBlock
                                   errorBlock:(onErrorBlock)onError;

/**
 *  下载
 *
 *  @param url                 url
 *  @param filePath            存储地址
 *  @param downloadBlock       RespBlock
 *  @param progressBlock       progressBlock
 *
 *  @return task
 */
- (NSURLSessionDownloadTask *)downloadFileWithUrl:(NSString *)url
                                         filePath:(NSURL *)filePath
                                    progressBlock:(onProgressBlock)progressBlock
                                    downloadBlock:(onDownloadRespBlock)downloadBlock;
/**
 *  header
 *
 *  @param value       value
 *  @param headerField field
 */
- (void)setValue:(NSString *)value forField:(NSString *)headerField;

/**
 Certificate
 
 @param pinnedCertificates 证书
 */
- (void)setPinnedCertificates:(NSArray *)pinnedCertificates;

@end
