//
//  VOThemeManager.m
//  Valo
//
//  Created by Valo on 15/11/20.
//  Copyright © 2015年 Valo. All rights reserved.
//

#import "VOThemeManager.h"

NSString * const VOThemeDownLoadedNotification = @"VOThemeDownLoadedNotification";
NSString * const VOCurrentThemeKey             = @"VOCurrentThemeKey";
NSString * const VODefaultTheme                = @"VODefaultTheme";
NSString * const VOThemeDomain                 = @"com.valo.themeManager";

#define VOThemeError(msg) [NSError errorWithDomain:VOThemeDomain code:-1 userInfo:@{@"code":@(-1),@"message":msg}]

//主题对象及应用方法
@interface VOThemeMap : NSObject
@property (nonatomic, weak) id             object;  ///< 要应用主题的对象
@property (nonatomic, copy) NSString       *key;    ///< 对应的key
@property (nonatomic, copy) VOThemeApplier applier; ///< 如何应用主题
@end

@implementation VOThemeMap
@end

@interface VOThemeManager ()
@property (nonatomic, strong, nonnull) YYCache  *currentCache;    ///< 当前主题数据
@property (nonatomic, strong, nonnull) YYCache  *defaultCache;    ///< 默认主题数据
@property (nonatomic, copy  ) NSString *cacheFolder;              ///< 存放主题数据的目录
@property (nonatomic, strong) NSMutableSet<VOThemeMap *> *map;    ///< 主题对象及应用方法
@end

@implementation VOThemeManager

#pragma mark 单例
+ (void)load{
    [VOThemeManager shared];
}

+ (instancetype)shared{
    static VOThemeManager *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[[self class] alloc] init];
    });
    return _shared;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        cacheFolder = [cacheFolder stringByAppendingPathComponent:VOThemeDomain];
        BOOL isDirectory = NO;
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL folderExisted = [fm fileExistsAtPath:cacheFolder isDirectory:&isDirectory];
        if (!(folderExisted && isDirectory)) {
            [fm createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _cacheFolder = cacheFolder;
        NSString *path = [_cacheFolder stringByAppendingPathComponent:VODefaultTheme];
        _defaultCache = [YYCache cacheWithPath:path];
        self.currentTheme = [[NSUserDefaults standardUserDefaults] stringForKey:VOCurrentThemeKey];
        _map = @[].mutableCopy;
    }
    return self;
}

#pragma mark - 主题相关操作

- (void)setCurrentTheme:(NSString *)currentTheme{
    NSString *originTheme = _currentTheme;
    _currentCache = nil;
    /* 1. 保存当前主题名 */
    if (![originTheme isEqualToString:currentTheme]) {
        _currentTheme = currentTheme.length == 0 ? VODefaultTheme : currentTheme;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_currentTheme forKey:VOCurrentThemeKey];
        [defaults synchronize];
    }
    /* 2. 应用主题到各个对象 */
    for (VOThemeMap *m in _map) {
        if (m.object) {
            id<NSCoding> data = [self.currentCache objectForKey:m.key];
            if (!data) {
                data = [_defaultCache objectForKey:m.key];
            }
            m.applier(m.object, data);
        }
        else{
            [_map removeObject:m];
        }
    }
}

- (YYCache *)currentCache{
    if (!_currentCache) {
        NSString *filename  = _currentTheme.length == 0 ? VODefaultTheme : _currentTheme;
        NSString *path = [_cacheFolder stringByAppendingPathComponent:filename];
        _currentCache = [YYCache cacheWithPath:path];
    }
    return _currentCache;
}

- (BOOL)setData:(nonnull NSDictionary *)themeDic
       forTheme:(nonnull NSString *)themeName{
    NSString *name = themeName.length == 0 ? VODefaultTheme : themeName;
    NSString *path = [_cacheFolder stringByAppendingPathComponent:name];
    YYCache *cache = [YYCache cacheWithPath:path];
    [cache removeAllObjects];
    [themeDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(NSCoding)]) {
            [cache setObject:obj forKey:key];
        }
        else{
            NSLog(@"Invalid Object:%@\nforKey:%@", obj,key);
        }
    }];
    return YES;
}

- (void)setData:(id<NSCoding>)themeItem forKey:(NSString *)key theme:(NSString *)themeName{
    NSString *name = themeName.length == 0 ? VODefaultTheme : themeName;
    NSString *path = [_cacheFolder stringByAppendingPathComponent:name];
    YYCache *cache = [YYCache cacheWithPath:path];
    [cache setObject:themeItem forKey:key];
}

- (void)removeTheme:(NSString *)themeName{
    [self removeTheme:themeName progression:nil completion:nil];
}

- (void)removeTheme:(NSString *)themeName
        progression:(nullable VOThemeProgression)progression
         completion:(nullable VOThemeCompletion)completion{
    if (themeName.length == 0) {
        if (progression) { progression(1,1); }
        if (completion) { completion(nil,nil,YES); }
        return;
    }
    NSString *path = [_cacheFolder stringByAppendingPathComponent:themeName];
    YYCache *cache = [YYCache cacheWithPath:path];
    [cache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
        if(progression){
            progression(removedCount, totalCount);
        }
    } endBlock:^(BOOL error) {
        if (completion){
            NSError *err = error?VOThemeError(@"Remove cache error."): nil;
            completion(nil, err, !error);
        }
    }];
}

- (void)registerThemeObject:(nonnull id)themeObject
                        key:(nonnull NSString *)key
                    applier:(nullable VOThemeApplier)applier{
    if (!themeObject || !applier) { return; }
    VOThemeMap *m = [VOThemeMap new];
    m.object      = themeObject;
    m.key         = key;
    m.applier     = applier;
    [_map addObject:m];
    id<NSCoding> data = [self.currentCache objectForKey:m.key];
    m.applier(m.object, data);
}

@end
