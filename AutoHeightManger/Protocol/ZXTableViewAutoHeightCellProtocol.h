//
//  ZXTableViewAutoHeightCellProtocol.h
//  Test
//
//  Created by Theo on 2023/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 自动计算高度的Cell赋值协议
@protocol ZXTableViewAutoHeightCellProtocol <NSObject>

/// 更新UI数据
/// - Parameter model: 数据
- (void)zx_updateUIWithModel:(id _Nullable )model;

@end

NS_ASSUME_NONNULL_END
