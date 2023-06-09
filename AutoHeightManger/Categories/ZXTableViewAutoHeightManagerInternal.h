//
//  ZXTableViewAutoHeightManagerInternal.h
//  Test
//
//  Created by Theo on 2023/4/7.
//

#import "ZXTableViewAutoHeightCellProtocol.h"
#import "ZXTableViewDataInfoModel.h"

static void * _Nullable ZXTableViewObserverContext = &ZXTableViewObserverContext;

NS_ASSUME_NONNULL_BEGIN

@interface ZXTableViewAutoHeightManager ()

#pragma mark - Property
// 注册列表 <tableView, 所有数据源>
@property (nonatomic, strong) NSMapTable<UITableView *, ZXTableViewDataInfoModel *> * registerTable;

#pragma mark - DataSource
// 获取section数量
- (NSInteger)getSectionNumForTableView:(UITableView *)tableView;

// 获取指定section的数据列表
- (NSArray *)getObjectsForTableView:(UITableView *)tableView section:(NSInteger)section;

// 获取指定位置数据
- (id)getObjectForRow:(NSInteger)row section:(NSInteger)section tableView:(UITableView *)tableView;

// 按顺序获取所有数据源
- (ZXTableViewDataInfoModel *)getDataInfoForTableView:(UITableView *)tableView;

#pragma mark - Cell Methods
// 获取CellHeight
- (CGFloat)getCellHeightForTableView:(UITableView *)tableView model:(id)model cellClass:(Class<ZXTableViewAutoHeightCellProtocol>)cellClass indexPath:(NSIndexPath *)indexPath;

// 获取CellStyle
- (UITableViewCellStyle)getCellStyleForTableView:(UITableView *)tableView section:(NSInteger)section row:(NSInteger)row;

// 获取CellClass
- (Class)getCellClassForTableView:(UITableView *)tableView section:(NSInteger)section row:(NSInteger)row;

// 生成Cell
- (UITableViewCell<ZXTableViewAutoHeightCellProtocol> *)getCellWithTableView:(UITableView *)tableView class:(Class)cls indexPath:(NSIndexPath *)indexPath dequeue:(BOOL)dequeue;

#pragma mark - Register Mehods
// 是否注册过tableView
- (BOOL)hasRegisterTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
