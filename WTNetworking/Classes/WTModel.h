//
//  WTModel.h
//  Pods
//
//  Created by walter on 30/07/2017.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol WTModel <NSObject>

+ (NSDictionary *)wt_propertyGenericClass;

@end

@interface WTModel : NSObject

/**
 * object c 本地dictionary 转化为object
 * 仅仅设置dict中有的属性 属性名和key必须一致
 */
+ (NSDictionary *)wt_dictionaryWithModel:(NSObject *)model;

+ (nullable instancetype)wt_modelWithDictionary:(NSDictionary *)dict className:(NSString *)className;

+ (nullable instancetype)wt_modelWithJSON:(id)json className:(NSString *)className;

@end

@interface NSString (WTModel)

- (NSDictionary *)wt_dictionaryWithJson;

@end

@interface NSObject (WTModel)

- (NSDictionary *)wt_dictionaryWithObject;

@end

NS_ASSUME_NONNULL_END

