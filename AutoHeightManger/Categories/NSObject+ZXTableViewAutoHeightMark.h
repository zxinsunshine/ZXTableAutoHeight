//
//  NSObject+ZXTableViewAutoHeightMark.h
//  Test
//
//  Created by Theo on 2023/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZXTableViewAutoHeightMark)

- (void)zx_markModify;

- (void)zx_unMarkModify;

- (BOOL)zx_isModified;

@end

NS_ASSUME_NONNULL_END
