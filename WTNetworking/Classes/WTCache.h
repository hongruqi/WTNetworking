//
//  WTCache.h
//  WTNetworking
//
//  Created by walter on 16/08/2017.
//

#import <Foundation/Foundation.h>

@interface WTCache : NSObject

+ (WTCache *)instance;

- (void)saveCacheData:(NSData*)data forKey:(NSString *)cacheKey;

- (NSData*)cachedDataForKey:(NSString *) cacheKey;

@end
