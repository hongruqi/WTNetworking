//
//  WTNetworkingError.h
//  Pods
//
//  Created by walter on 28/07/2017.
//
//

#import <Foundation/Foundation.h>

@interface WTNetworkingError : NSError

@property (nonatomic, copy, readonly) NSString *errorMessage;

+ (void)setErrorDomain:(NSString *)errorDomain;
/**
 * 返回由Rest接口错误信息构建的错误对象.
 */
+ (WTNetworkingError *)errorWithRestInfo:(NSDictionary *)restInfo;
/**
 * 返回由error message.
 */
+ (NSString *)errorMessage:(WTNetworkingError *)error;

/**
 * 返回由NSError构建的错误对象.
 */
+ (WTNetworkingError *)errorWithNSError:(NSError *)error;

/**
 * 构造XYNetError错误。
 *
 * @param code 错误代码
 * @param errorMessage 错误信息
 *
 * 返回错误对象.
 */
+ (WTNetworkingError *)errorWithCode:(NSInteger)code errorMessage:(NSString *)errorMessage;

/**
 * 返回调用Rest Api 的 method字段的值.
 */
- (NSString *)methodForRestApi;


@end
