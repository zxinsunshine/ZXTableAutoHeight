//
//  NSObject+ZXTableViewAutoHeightMark.m
//  Test
//
//  Created by Theo on 2023/4/7.
//

#import "NSObject+ZXTableViewAutoHeightMark.h"
#import <objc/runtime.h>

static const char * kZXTableViewModelModifyKey = "zx_kZXTableViewModelModifyKey";

@implementation NSObject (ZXTableViewAutoHeightMark)


- (BOOL)zx_isModified {
    BOOL rs = [objc_getAssociatedObject(self, kZXTableViewModelModifyKey) boolValue];
    return rs;
}

- (void)zx_markModify {
    objc_setAssociatedObject(self, kZXTableViewModelModifyKey, @(YES), OBJC_ASSOCIATION_ASSIGN);
}

- (void)zx_unMarkModify {
    objc_setAssociatedObject(self, kZXTableViewModelModifyKey, @(NO), OBJC_ASSOCIATION_ASSIGN);
}

@end
