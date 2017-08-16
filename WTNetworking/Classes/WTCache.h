//
//  WTCache.h
//  WTNetworking
//
//  Created by walter on 16/08/2017.
//

#import <Foundation/Foundation.h>

@interface WTCache : NSObject

+ (WTCache *)instance;

- (NSArray *)cacheDataWithClass:(Class)objectClass version:(NSString *)version;

- (void)saveListWithArray:(NSArray *)array objectClass:(Class)objectClass version:(NSString *)version;

- (void)saveCacheData:(NSData*)data forKey:(NSString *)cacheKey;

- (NSData*)cachedDataForKey:(NSString *) cacheKey;

@end
