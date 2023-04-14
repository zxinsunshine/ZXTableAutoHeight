//
//  ZXTableViewAutoHeightDelegate.h
//  Test
//
//  Created by Theo on 2023/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 自动计算高度的TableView代理协议
@protocol ZXTableViewAutoHeightDelegate <UITableViewDelegate>

#pragma mark - 自定义代理
@optional
/// 生成Cell
/// - Parameters:
///   - tableView: tableView
///   - cell: cell
///   - indexPath: 坐标
///   - object: 对应的数据
- (void)zx_tableView:(UITableView *_Nullable)tableView didGenerateCell:(UITableViewCell *_Nullable)cell forRowAtIndexPath:(NSIndexPath *_Nullable)indexPath object:(id _Nullable)object;

@end

NS_ASSUME_NONNULL_END
