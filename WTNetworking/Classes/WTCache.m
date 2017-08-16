//
//  WTCache.m
//  WTNetworking
//
//  Created by walter on 16/08/2017.
//

#import "WTCache.h"
#import "WTCoreData.h"

@interface WTCache ()

@property (strong, nonatomic) NSCache *memCache;

@end

@implementation WTCache

+ (WTCache *)instance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _memCache = [[NSCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)saveCacheData:(NSData *)data forKey:(NSString *)cacheKey
{
    [self.memCache setObject:data forKey:cacheKey];
}

- (NSData *)cachedDataForKey:(NSString *)cacheKey
{
    return (NSData *)[self.memCache objectForKey:cacheKey];
}

- (NSArray *)cacheDataWithClass:(Class)objectClass version:(NSString *)version
{
    WTCoreDataContext *context = [[WTCoreDataContext alloc] initWithObjectClass:objectClass version:version];
    return [context fetchAllObjects];
}

- (void)saveListWithArray:(NSArray *)array objectClass:(Class)objectClass version:(NSString *)version
{
    WTCoreDataContext *context = [[WTCoreDataContext alloc] initWithObjectClass:objectClass version:version];
    [context insertOrReplaceObjects:array];
}

- (void)clearMemory
{
    [self.memCache removeAllObjects];
}

@end
