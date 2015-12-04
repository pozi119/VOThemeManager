//
//  NSObject+VOTheme.m
//  netCafe
//
//  Created by Valo on 15/11/26.
//  Copyright © 2015年 Sicent. All rights reserved.
//

#import "NSObject+VOTheme.h"
#import <objc/runtime.h>

static const void *VOAppliedThemesKey = &VOAppliedThemesKey;
static const void *VOAttachKey = &VOAttachKey;

@implementation NSObject (VOTheme)

- (NSMutableDictionary *)vo_appliedThemes{
    NSMutableDictionary *dic = objc_getAssociatedObject(self, VOAppliedThemesKey);
    if (!dic) {
        dic = @{}.mutableCopy;
        [self setVo_appliedThemes:dic];;
    }
    return dic;
}

- (void)setVo_appliedThemes:(NSMutableDictionary *)vo_appliedThemes{
    objc_setAssociatedObject(self, &VOAppliedThemesKey, vo_appliedThemes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)vo_attach{
    return objc_getAssociatedObject(self, VOAttachKey);
}

- (void)setVo_attach:(id)vo_attach{
    objc_setAssociatedObject(self, &VOAttachKey, vo_attach, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
