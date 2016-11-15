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

@interface VOThemeManager ()
@property (nonatomic, strong, nonnull) YYCache  *currentCache;    /**< 当前主题数据 */
@property (nonatomic, strong, nonnull) YYCache  *defaultCache;    /**< 默认主题数据 */
@property (nonatomic, copy  ) NSString *cacheFolder;              /**< 存放主题数据的目录 */
@property (nonatomic, strong) NSMapTable *themeObjs;     /**< 要应用主题的对象 */
@property (nonatomic, strong) NSMapTable *themeAppliers; /**< 应用主题的方式 */
@end

@implementation VOThemeManager

#pragma mark - 公共方法

#pragma mark - 主题相关操作
+ (NSString *)currentTheme{
    return [VOThemeManager sharedManager].currentTheme;
}

+ (void)setCurrentTheme:(NSString *)currentTheme{
    [[VOThemeManager sharedManager] setCurrentTheme:currentTheme];
}

+ (BOOL)setData:(nonnull NSDictionary *)themeDic
       forTheme:(nonnull NSString *)themeName{
    return [[VOThemeManager sharedManager] setData:themeDic forTheme:themeName];
}

+ (void)removeTheme:(nonnull NSString *)themeName{
    
}

+ (void)removeTheme:(nonnull NSString *)themeName
        progression:(nullable VOThemeProgression)progression
         completion:(nullable VOThemeCompletion)completion{
    [[VOThemeManager sharedManager] removeTheme:themeName progression:progression completion:completion];
}

+ (void)removeAllThemes{
    [[VOThemeManager sharedManager] removeAllThemes];
}

+ (void)removeAllThemes:(nullable VOThemeProgression)progression
             completion:(nullable VOThemeCompletion)completion{
    [[VOThemeManager sharedManager] removeAllThemes:progression completion:completion];
}

+ (void)removeThemes:(nullable NSArray *)themeNames{
    [[VOThemeManager sharedManager] removeThemes:themeNames];
}

+ (void)removeThemes:(nullable NSArray *)themeNames
         progression:(nullable VOThemeProgression)progression
          completion:(nullable VOThemeCompletion)completion{
    [[VOThemeManager sharedManager] removeThemes:themeNames progression:progression completion:completion];
}

+ (void)setThemeObject:(nullable id)themeObject
                forKey:(nonnull NSString *)key
          defaultBlock:(nullable VOThemeDefaultBlock)defaultBlock
               applier:(nullable VOThemeApplier)applier{
    [[VOThemeManager sharedManager] setThemeObject:themeObject forKey:key defaultBlock:defaultBlock applier:applier];
}

#pragma mark 单例
+ (void)load{
    [VOThemeManager sharedManager];
}

+ (instancetype)sharedManager{
    static VOThemeManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[[self class] alloc] init];
    });
    return _sharedManager;
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
        _themeObjs = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
        _themeAppliers = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

#pragma mark - 主题相关操作

- (void)setCurrentTheme:(NSString *)currentTheme{
    NSString *originTheme = _currentTheme;
    /* 1. 保存当前主题名 */
    if (![originTheme isEqualToString:currentTheme]) {
        _currentTheme = currentTheme;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (currentTheme.length > 0) {
            [defaults setObject:currentTheme forKey:VOCurrentThemeKey];
            NSString *path = [_cacheFolder stringByAppendingPathComponent:currentTheme];
            _currentCache = [YYCache cacheWithPath:path];
        }
        else{
            [defaults removeObjectForKey:VOCurrentThemeKey];
            _currentCache = _defaultCache;
        }
        [defaults synchronize];
    }
    /* 2. 应用主题到各个对象 */
    NSEnumerator *e = [_themeObjs keyEnumerator];
    NSString *key = nil;
    while (key = [e nextObject]) {
        id themeData = [_currentCache objectForKey:key];
        __weak id obj = [_themeObjs objectForKey:key];
        __weak VOThemeApplier applier = [_themeAppliers objectForKey:key];
        if (obj && applier) {
            applier(obj,themeData);
        }
    }
}

- (BOOL)setData:(nonnull NSDictionary *)themeDic
       forTheme:(nonnull NSString *)themeName{
    if (themeName.length == 0) { return NO;}
    NSString *path = [_cacheFolder stringByAppendingPathComponent:themeName];
    YYCache *cache = [YYCache cacheWithPath:path];
    if (themeDic.count == 0) {
        [self removeTheme:themeName];
        return YES;
    }
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

- (void)removeTheme:(NSString *)themeName{
    [self removeTheme:themeName progression:nil completion:nil];
}

- (void)removeTheme:(NSString *)themeName
        progression:(nullable VOThemeProgression)progression
         completion:(nullable VOThemeCompletion)completion{
    if ([themeName isEqualToString:self.currentTheme]) {
        self.currentTheme = nil;
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

- (void)removeAllThemes{
    [self removeAllThemes:nil completion:nil];
}

- (void)removeAllThemes:(VOThemeProgression)progression
             completion:(VOThemeCompletion)completion{
    [self removeThemes:nil progression:progression completion:completion];
}

- (void)removeThemes:(NSArray *)themeNames{
    [self removeThemes:themeNames progression:nil completion:nil];
}

- (void)removeThemes:(NSArray *)themeNames
         progression:(VOThemeProgression)progression
          completion:(VOThemeCompletion)completion{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *allContents = [fm contentsOfDirectoryAtPath:_cacheFolder error:nil];
    NSMutableArray *contents = @[].mutableCopy;
    for (NSString *path in allContents) {
        BOOL flag = NO;
        if (themeNames.count == 0) {
            flag = YES;
        }
        else{
            NSString *folder = [path lastPathComponent];
            for (NSString *theme in themeNames) {
                if ([folder isEqualToString:theme]) {
                    flag = YES;
                    break;
                }
            }
        }
        if (flag){
            [fm fileExistsAtPath:path isDirectory:&flag];
            if (flag) {
                [contents addObject:path];
            }
        }
    }
    NSInteger count = contents.count;
    [contents enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        if ([[path lastPathComponent] isEqualToString:self.currentTheme]) {
            self.currentTheme = nil;
        }
        YYCache *cache = [YYCache cacheWithPath:path];
        [cache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
            if(progression){
                progression(idx + removedCount * 1.0 / totalCount, count);
            }
        } endBlock:nil];
    }];
    if (completion) {
        completion(nil, nil, YES);
    }
}

- (void)setThemeObject:(id)themeObject
                forKey:(NSString *)key
          defaultBlock:(nullable VOThemeDefaultBlock)defaultBlock
               applier:(nullable VOThemeApplier)applier{
    [_themeObjs setObject:themeObject forKey:key];
    [_themeAppliers setObject:applier forKey:key];
    [self.defaultCache setObject:defaultBlock?defaultBlock(themeObject):nil forKey:key];
    id data = [self.currentCache objectForKey:key];
    if (themeObject && applier) {
        applier(themeObject, data);
    }
}

@end
