//
//  VOThemeManager.m
//  netCafe
//
//  Created by Valo on 15/11/20.
//  Copyright © 2015年 Sicent. All rights reserved.
//

#import "VOThemeManager.h"
#import "NSObject+VOTheme.h"
#import "NSObject+WebCacheOperation.h"

NSString *const VOThemeColorKey = @"color";
NSString *const VOThemeBackgroundColorKey = @"backgroundColor";
NSString *const VOThemeImageKey = @"image";
NSString *const VOThemeBackgroundImageKey = @"backgroundImage";

NSString *const VOThemeStoreKey = @"VOThemeStoreKey";
NSString *const VOCurrentThemeKey = @"VOCurrentThemeKey";

NSString *const VOThemeNullValue = @"VOThemeNullValue";

@interface VOThemeManager ()
/**
 *  themes格式 key(键+状态+属性名):value(属性值)
 *  示例:
 *  {
 *      test = {
 *          "nav|0|image" = "tmp_nav_bg";
 *          "sample|0|color" = "#FFF000";
 *          "sample|0|image" = "tmp_nav_bg";
 *      };
 *   }
 *   其中test是主题名, "nav|0|image"中nav为对象的key,0表示某个状态,image表示这个对象在状态0下的color属性
 */
@property (nonatomic, strong) NSMutableDictionary *themes;

/**
 *  当前主题
 */
@property (nonatomic, strong) NSDictionary *currentTheme;

/**
 *  未应用主题之前的状态值
 */
@property (nonatomic, strong) NSMutableDictionary *originalTheme;

/**
 *  themeAppliers格式 key(类名<单例对象为地址>+状态+属性名):value(themeApplier,block对象,指定类应用主题的操作)
 *  示例:
 *  {
 *      UIBarButtonItem|0|color = "<__NSMallocBlock__: 0x12d8ae980>";
 *      UINavigationBar|0|image = "<__NSMallocBlock__: 0x12d8ae9f0>";
 *      "0x12d8af660|0|color" = "<__NSMallocBlock__: 0x12d8af720>";
 *  }
 *  此示例是预置各种类应用主题的方式,__NSMallocBlock__ 是block对象
 */
@property (nonatomic, strong) NSMutableDictionary *themeAppliers;

/**
 *  themeGetters格式 key(类名<单例对象为地址>+状态+属性名):value(themeApplier,block对象,指定类应用主题的操作)
 *  示例:
 *  {
 *      UIBarButtonItem|0|color = "<__NSMallocBlock__: 0x12d8af180>";
 *      UINavigationBar|0|image = "<__NSMallocBlock__: 0x12d8af1f0>";
 *      "0x12d8af660|0|color" = "<__NSMallocBlock__: 0x12d8af920>";
 *  }
 *  此示例是预置各种类获取主题属性值的方式,__NSMallocBlock__ 是block对象
 */
@property (nonatomic, strong) NSMutableDictionary *themeGetters;

/**
 *  themeObjs格式 key(键+状态+属性名):value(要应用主题的对象)
 *  示例:
 *  {
 *  "nav|0|image" = "<UINavigationBar: 0x12d98f1d0; .....>";
 *  }
 *  "nav|0|image"和themes中每个主题的key对应
 *  "<UINavigationBar: 0x12d98f1d0; .....>"为某个UINavigationBar,拼接成appliers的key为:UINavigationBar|0|image ,用于在themeAppliers中查找应用属性的方法
 */
@property (nonatomic, strong) NSMutableDictionary *themeObjs;

/**
 *  当前主题的名字
 */
@property (nonatomic, copy) NSString *currentThemeName;

@end

@implementation VOThemeManager

#pragma mark - 公共方法
#pragma mark 单例
+ (instancetype)sharedManager{
    static VOThemeManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[[self class] alloc] init];
    });
    return _sharedManager;
}

#pragma mark 应用主题
- (void)applyThemeWithName:(NSString *)themeName{
    BOOL isExist = NO;
    if (themeName.length <= 0) {
        isExist = YES;
    }
    else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(themeManager:isExistThemeName:)]) {
            isExist = [self.delegate themeManager:self isExistThemeName:themeName];
        }
        else{
            isExist = self.themes[themeName] != nil;
        }
    }
    if (!isExist) {
        return;
    }
    
    // 整体读取主题
    if (isExist) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(themeManager:readthemeWithName:cacheHandler:)]) {
            [self.delegate themeManager:self readthemeWithName:themeName cacheHandler:^(NSDictionary *theme) {
                self.currentTheme = theme;
            }];
        }
        else{
            self.currentTheme = self.themes[themeName];
        }
    }
    else{
        self.currentTheme = nil;
    }
    self.currentThemeName = isExist ? themeName :nil;
    
    void (^applyBlock)() = ^() {
        // 应用主题到当前需要使用主题的对象
        [self.themeObjs enumerateKeysAndObjectsUsingBlock:^(NSString *realKey, NSObject *obj, BOOL *stop) {
            [self applyThemeWithName:themeName forRealKeyKey:realKey];
        }];
    };
    
    if (self.currentTheme) {
        dispatch_queue_t queue = dispatch_queue_create("votheme_download_image", DISPATCH_QUEUE_SERIAL);
        dispatch_group_t group = dispatch_group_create();
        [self.currentTheme enumerateKeysAndObjectsUsingBlock:^(NSString *realKey, NSString  *value, BOOL *stop) {
            VOThemeImagePathType type = [VOThemeUtils imagePathType:value];
            NSString *fullPath = nil;
            switch (type) {
                case VOThemeImagePathAbsoluteURL: {
                    fullPath = value;
                    break;
                }
                case VOThemeImagePathRelativeURL: {
                    fullPath = [self.baseImagePath stringByAppendingString:value];
                    break;
                }
                default: {
                    break;
                }
            }
            if (fullPath) {
                dispatch_group_async(group, queue, ^{
                    [self sd_setImageWithURL:[NSURL URLWithString:fullPath] loadkey:realKey loadImageBlock:nil];
                });
            }
        }];
        dispatch_group_async(group, queue, ^{
            applyBlock();
        });
    }
    else{
        applyBlock();
    }
}

#pragma mark 添加/删除某个主题
- (void)setTheme:(id)theme withName:(NSString *)themeName themeConverter:(VOThemeCoverter)themeConverter{
    if(self.delegate && [self.delegate respondsToSelector:@selector(themeManager:storeTheme:withName:)]){
        [self.delegate themeManager:self storeTheme:theme withName:themeName];
    }
    else{
        if (theme && themeConverter && themeName) {
            NSDictionary *themeDic = themeConverter(theme);
            if (themeDic) {
                self.themes[themeName]= themeDic;
                [[NSUserDefaults standardUserDefaults] setObject:self.themes forKey:VOThemeStoreKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

- (void)removeThemeWithName:(NSString *)themeName{
    if (themeName.length > 0) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(themeManager:removeThemeWithName:)]){
            [self.delegate themeManager:self removeThemeWithName:themeName];
        }
        else{
            self.themes[themeName] = nil;
            [[NSUserDefaults standardUserDefaults] setObject:self.themes forKey:VOThemeStoreKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark 读取/添加/删除某个要使用主题的对象
- (void)applyThemeWithName:(NSString *)themeName forRealKeyKey:(NSString *)realKey{
    if (!(realKey && realKey.length > 0)) {
        return;
    }
    NSString *primaryKey = nil;
    NSInteger tag = 0;
    NSString *themeKey = nil;
    BOOL flag = [VOThemeUtils convertRealKey:realKey toPrimaryKey:&primaryKey tag:&tag themeKey:&themeKey];
    if (!flag) {
        return;
    }
    NSObject *themeObj = self.themeObjs[realKey];
    if (!themeObj) {
        return;
    }
    //FIXME 暂时屏蔽,规避错误
    //        if ([themeName isEqualToString:themeObj.vo_appliedThemes[realKey]]) {
    //            return;
    //        }
    NSString *className  = NSStringFromClass([themeObj class]);
    NSString *applierRealKey = nil;
    VOThemeApplier themeApplier = nil;
    VOThemeGetter themeGetter = nil;
    BOOL isSingleton = NO;
    
    flag = [VOThemeUtils convertPrimaryKey:className tag:tag themeKey:themeKey toRealKey:&applierRealKey];
    if (flag) {
        themeApplier = self.themeAppliers[applierRealKey];
        themeGetter = self.themeGetters[applierRealKey];
        if (!themeApplier) {
            NSString *objMemAddr = [NSString stringWithFormat:@"%p",themeObj];
            flag = [VOThemeUtils convertPrimaryKey:objMemAddr tag:tag themeKey:themeKey toRealKey:&applierRealKey];
            themeApplier = self.themeAppliers[applierRealKey];
            if (themeApplier) {
                themeGetter = self.themeGetters[applierRealKey];
                isSingleton = YES;
            }
            else{
                return;
            }
        }
    }
    if (!themeApplier) {
        return;
    }
    
    NSDictionary *themeDic = nil;
    if (themeName && themeName.length > 0) {
        if ([themeName isEqualToString:self.currentThemeName]) {
            themeDic = self.currentTheme;
        }
        else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(themeManager:applyThemeWithName:forRealKey:themeApplier:themeGetter:)]) {
                [self.delegate themeManager:self applyThemeWithName:themeName forRealKey:realKey themeApplier:themeApplier themeGetter:themeGetter];
                themeObj.vo_appliedThemes[realKey] = themeName;
                return;
            }
            else{
                themeDic = self.themes[themeName];
            }
        }
    }
    else{
        themeDic = self.originalTheme;
    }
    
    if (themeDic && [themeDic isKindOfClass:[NSDictionary class]]) {
        NSString *currentTheme = themeObj.vo_appliedThemes[realKey];
        if (!currentTheme && themeGetter) {
            id originValue = themeGetter(themeObj,primaryKey,tag,themeKey);
            if (!originValue) {
                originValue = VOThemeNullValue;
            }
            self.originalTheme[realKey] = originValue;
        }
        id value = themeDic[realKey];
        if (!value) {
            value = self.originalTheme[realKey];
        }
        if ([value isEqual:VOThemeNullValue]) {
            value = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            themeApplier(themeObj,primaryKey,tag,themeKey,value);
        });
        themeObj.vo_appliedThemes[realKey] = themeName;
    }
    themeObj.vo_appliedThemes[realKey] = themeName;
}

- (void)setThemeObject:(NSObject *)themeObj primaryKey:(NSString *)primaryKey tag:(NSInteger)tag themeKey:(NSString *)themeKey{
    return [self setThemeObject:themeObj primaryKey:primaryKey tag:tag themeKey:themeKey attach:nil];
}

- (void)setThemeObject:(NSObject *)themeObj primaryKey:(NSString *)primaryKey tag:(NSInteger)tag themeKey:(NSString *)themeKey attach:(id)attach{
    if (!themeObj) {
        return;
    }
    NSString *realKey = nil;
    BOOL flag = [VOThemeUtils convertPrimaryKey:primaryKey tag:tag themeKey:themeKey toRealKey:&realKey];
    if (flag) {
        themeObj.vo_attach = attach;
        self.themeObjs[realKey] = themeObj;
        if (self.currentThemeName) {
            [self applyThemeWithName:self.currentThemeName forRealKeyKey:realKey];
        }
    }
}

- (void)removeThemeObjectWithPrimaryKeys:(NSArray *)primaryKeys{
    [primaryKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        if (key.length > 0) {
            [self removeThemeObjectWithPrimaryKey:key];
        }
    }];
}

- (void)removeThemeObjectWithPrimaryKey:(NSString *)primaryKey{
    if (primaryKey.length > 0) {
        NSString *removeKey = [NSString stringWithFormat:@"%@|",primaryKey];
        [self.themeObjs enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSObject *obj, BOOL * stop) {
            NSRange range = [key rangeOfString:removeKey options:NSLiteralSearch];
            if (range.location != NSNotFound && range.length > 0) {
                NSString *primaryKey = nil;
                NSInteger tag = 0;
                NSString *themeKey = nil;
                BOOL flag = [VOThemeUtils convertRealKey:key toPrimaryKey:&primaryKey tag:&tag themeKey:&themeKey];
                if (flag) {
                    [self removeThemeObjectWithPrimaryKey:primaryKey tag:tag themeKey:themeKey];
                }
            }
        }];
    }
}

- (void)removeThemeObjectWithPrimaryKey:(NSString *)primaryKey tag:(NSInteger)tag themeKey:(NSString *)themeKey{
    NSString *realKey = nil;
    BOOL flag = [VOThemeUtils convertPrimaryKey:primaryKey tag:tag themeKey:themeKey toRealKey:&realKey];
    if (flag) {
        [self applyThemeWithName:nil forRealKeyKey:realKey];
        NSObject *obj = self.themeObjs[realKey];
        obj.vo_appliedThemes = nil;
        self.themeObjs[realKey] = nil;
        self.originalTheme[realKey] = nil;
    }
}

#pragma mark 设置使用主题的方法
- (void)themeApplierAndGetterForClass:(NSString *)className
                                  tag:(NSInteger)tag
                             themeKey:(NSString *)themeKey
                              applier:(VOThemeApplier)applier
                               getter:(VOThemeGetter)getter{
    NSString *realKey = nil;
    BOOL flag = [VOThemeUtils convertPrimaryKey:className tag:tag themeKey:themeKey toRealKey:&realKey];
    if (flag) {
        self.themeAppliers[realKey] = applier;
        self.themeGetters[realKey] = getter;
    }
}

- (void)themeApplierAndGetterForSingleton:(id)singleton
                             tag:(NSInteger)tag
                        themeKey:(NSString *)themeKey
                         applier:(VOThemeApplier)applier
                                   getter:(VOThemeGetter)getter{
    NSString *realKey = nil;
    BOOL flag = [VOThemeUtils convertPrimaryKey:singleton tag:tag themeKey:themeKey toRealKey:&realKey];
    if (flag) {
        self.themeAppliers[realKey] = applier;
        self.themeGetters[realKey] = getter;
    }
}

#pragma mark - 私有方法
#pragma mark 属性初始化
-(NSMutableDictionary *)themes{
    if (!_themes) {
        NSDictionary *themes = [[NSUserDefaults standardUserDefaults] objectForKey:VOThemeStoreKey];
        if (themes && [themes isKindOfClass:[NSDictionary class]]) {
            _themes = themes.mutableCopy;
        }
        else{
            _themes = @{}.mutableCopy;
        }
    }
    return _themes;
}

- (NSMutableDictionary *)originalTheme{
    if (!_originalTheme) {
        _originalTheme = @{}.mutableCopy;
    }
    return _originalTheme;
}

- (NSMutableDictionary *)themeObjs{
    if (!_themeObjs) {
        _themeObjs = @{}.mutableCopy;
    }
    return _themeObjs;
}

- (NSMutableDictionary *)themeAppliers{
    if (!_themeAppliers) {
        _themeAppliers = @{}.mutableCopy;
    }
    return _themeAppliers;
}

- (NSMutableDictionary *)themeGetters{
    if (!_themeGetters) {
        _themeGetters = @{}.mutableCopy;
    }
    return _themeGetters;
}

@end
