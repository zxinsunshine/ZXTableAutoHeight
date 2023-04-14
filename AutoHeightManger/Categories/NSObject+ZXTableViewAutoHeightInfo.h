//
//  NSObject+ZXTableViewAutoHeightInfo.h
//  AutoUITableView
//
//  Created by Theo on 2023/3/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZXTableViewAutoHeightInfo)

- (BOOL)zx_hasModelHeight;

- (CGFloat)zx_modelHeight;

- (void)zx_clearModelHeight;

- (void)zx_updateModelHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
