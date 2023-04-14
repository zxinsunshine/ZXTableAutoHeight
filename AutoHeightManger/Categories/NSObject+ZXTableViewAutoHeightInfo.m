//
//  NSObject+ZXTableViewAutoHeightInfo.m
//  AutoUITableView
//
//  Created by Theo on 2023/3/22.
//

#import "NSObject+ZXTableViewAutoHeightInfo.h"
#import <objc/runtime.h>

static const char * kZXTableViewCellHeightKey = "kZXTableViewCellHeightKey";
static const CGFloat kDefaultCellHeight = -1;

@implementation NSObject (ZXTableViewAutoHeightInfo)

- (BOOL)zx_hasModelHeight {
    return [self zx_modelHeight] != kDefaultCellHeight;
}

- (CGFloat)zx_modelHeight {
    id obj = objc_getAssociatedObject(self, kZXTableViewCellHeightKey);
    if (obj && [obj isKindOfClass:[NSNumber class]]) {
        return [obj floatValue];
    }
    return kDefaultCellHeight;
}

- (void)zx_clearModelHeight {
    [self zx_updateModelHeight:kDefaultCellHeight];
}

- (void)zx_updateModelHeight:(CGFloat)height {
    objc_setAssociatedObject(self, kZXTableViewCellHeightKey, @(height), OBJC_ASSOCIATION_RETAIN);
}

@end
