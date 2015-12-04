//
//  NSObject+VOTheme.h
//  netCafe
//
//  Created by Valo on 15/11/26.
//  Copyright © 2015年 Sicent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (VOTheme)
@property (nonatomic, strong) NSMutableDictionary *vo_appliedThemes;   /**< 已经应用过的主题项 */
@property (nonatomic, strong) id vo_attach; /**< 附加属性,通常用于传递图片大小 */
@end
