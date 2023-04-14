//
//  ZXTableViewAutoHeightDataSource.h
//  Test
//
//  Created by Theo on 2023/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 自动计算高度的TableView数据协议
@protocol ZXTableViewAutoHeightDataSource <NSObject>

#pragma mark - 自定义代理
@required
/// section对应的数据列表
/// - Parameters:
///   - tableView: tableView
///   - section: section
- (NSArray *_Nullable)zx_tableView:(UITableView *_Nullable)tableView objectsInSection:(NSInteger)section;

/// 坐标对应的Cell类型
/// - Parameters:
///   - tableView: tableView
///   - indexPath: 坐标
///   - object: 数据
- (Class _Nonnull)zx_tableView:(UITableView *_Nullable)tableView cellClassForRowAtIndexPath:(NSIndexPath *_Nullable)indexPath object:(id _Nullable)object;


@optional
/// section数量
/// - Parameter tableView: tableView
- (NSInteger)zx_numberOfSectionsInTableView:(UITableView *_Nullable)tableView;

/// 坐标对应的CellType
/// - Parameters:
///   - tableView: tableView
///   - indexPath: 坐标
///   - object: 数据
- (UITableViewCellStyle)zx_tableView:(UITableView *_Nullable)tableView cellStyleForRowAtIndexPath:(NSIndexPath *_Nullable)indexPath object:(id _Nullable)object;

@end

NS_ASSUME_NONNULL_END
