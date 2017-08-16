//
//  WTRequest.h
//  Pods
//
//  Created by walter on 28/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "WTSessionManager.h"

@interface WTRequest : NSObject

/**
 * 请求方法
 */
@property (nonatomic, copy) NSString *httpMethod;

/**
 * 返回modelName
 */
@property (nonatomic, copy) NSString *modelName;

/**
 * 请求参数
 */
@property (nonatomic, strong) NSMutableDictionary *fields;
/**
 * 请求参数,需要方法签名
 */
@property (nonatomic, strong) NSMutableDictionary *body;
/**
 * 请求header
 */
@property (nonatomic, strong) NSMutableDictionary *header;

/**
 * api url
 */
@property (nonatomic, copy) NSString *apiUrl;

/**
 * 请求完成回调
 */
@property (nonatomic, copy) onCompletionBlock completionBlock;

/**
 * 错误回调
 */
@property (nonatomic, copy) onErrorBlock errorBlock;

/*
 * 是否自动显示错误
 */
@property (nonatomic, assign) BOOL autoShowError;

/*
 * 是否强制刷新数据
 */
@property (nonatomic, assign) BOOL forceReload;

/*
 * 是否缓存
 */
@property (nonatomic, assign, readonly) BOOL shouldCache;

/**
 列表存储到数据库中，非列表，缓存在内存中
 */
@property (nonatomic, assign, readonly) BOOL isList;

/**
 *  是否正在请求中
 */
@property (nonatomic, assign) BOOL isExecuting;

//设置api的版本
@property (nonatomic, strong) NSString *apiVersion;

@property (nonatomic, assign) BOOL isNeedLogin;

/**
 * 发送请求
 */
- (void)sendRequest;

/**
 * 取消请求
 */
- (void)cancelRequest;
@end
