//
//  ZXTableViewAutoHeightManager.m
//  AutoUITableView
//
//  Created by Theo on 2023/3/22.
//

#import "ZXTableViewAutoHeightManager.h"
#import "NSObject+ZXTableViewAutoHeightInfo.h"
#import "NSObject+ZXTableViewAutoHeightMark.h"
#import <IGListDiffKit/IGListDiffKit.h>
#import "ZXTableViewDataInfoModel.h"
#import "ZXTableViewDiffModel.h"

#import "ZXTableViewAutoHeightManagerInternal.h"
#import "ZXTableViewAutoHeightManager+DataSource.h"
#import "ZXTableViewAutoHeightManager+Observer.h"

@implementation ZXTableViewAutoHeightManager

#pragma mark - Public Register Methods
- (void)removeTableView:(UITableView *)tableView {
    if (tableView) {
        [self.registerTable removeObjectForKey:tableView];
        [tableView removeObserver:self forKeyPath:zx_kEstimateHeightKey context:nil];
        [tableView removeObserver:self forKeyPath:zx_kDelegateKey context:nil];
        [tableView removeObserver:self forKeyPath:zx_kDataSourceKey context:nil];
    }
}

- (void)registerTableView:(UITableView *)tableView {
    if (tableView) {
        [self.registerTable setObject:[self getDataInfoForTableView:tableView] forKey:tableView];
        tableView.estimatedRowHeight = 0; // close system auto size
        tableView.dataSource = self;
        tableView.delegate = self;
        [tableView addObserver:self forKeyPath:zx_kEstimateHeightKey options:NSKeyValueObservingOptionNew context:nil];
        [tableView addObserver:self forKeyPath:zx_kDelegateKey options:NSKeyValueObservingOptionNew context:nil];
        [tableView addObserver:self forKeyPath:zx_kDataSourceKey options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - Public Update Methods
- (void)reloadTableView:(UITableView *)tableView {
    if (![self hasRegisterTableView:tableView]) {
        return;
    }
    [[self getDataInfoForTableView:tableView].sectionModels enumerateObjectsUsingBlock:^(ZXTableViewDiffSectionModel * _Nonnull sectionModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [sectionModel.diffableObjects enumerateObjectsUsingBlock:^(ZXTableViewDiffModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self clearHeightForTable:tableView model:obj]; // 清除缓存高度
        }];
    }];
    [tableView reloadData];
}

- (void)updateTableView:(UITableView *)tableView animation:(UITableViewRowAnimation)animation completion:(void(^ __nullable)(void))completion {
    if (![self hasRegisterTableView:tableView]) {
        return;
    }
    ZXTableViewDataInfoModel * oldInfo = [self.registerTable objectForKey:tableView];
    ZXTableViewDataInfoModel * newInfo = [self getDataInfoForTableView:tableView];
    IGListIndexSetResult * result = [self getDiffResultWithNewObjects:newInfo.sectionModels oldObjects:oldInfo.sectionModels];
    if (result.hasChanges) {
        [self.registerTable setObject:newInfo forKey:tableView];
        [self copeSectionResult:result oldInfo:oldInfo newInfo:newInfo tableView:tableView animation:animation completion:completion];
    } else if (completion) {
        completion();
    }
}

- (void)copeSectionResult:(IGListIndexSetResult *)sectionResult oldInfo:(ZXTableViewDataInfoModel *)oldInfo newInfo:(ZXTableViewDataInfoModel *)newInfo tableView:(UITableView *)tableView animation:(UITableViewRowAnimation)animation completion:(void(^)(void))completion {
    
    // Section处理（其中，Section中Row的增减会造成Inserts和Deletes，所以整理一下）
    NSMutableIndexSet * mSectionUpdates = [NSMutableIndexSet indexSet];
    [mSectionUpdates addIndexes:sectionResult.updates];
    
    NSMutableIndexSet * mSectionInserts = [NSMutableIndexSet indexSet];
    [mSectionInserts addIndexes:sectionResult.inserts];
    
    NSMutableIndexSet * mSectionDeletes = [NSMutableIndexSet indexSet];
    [mSectionDeletes addIndexes:sectionResult.deletes];
   
    // 若Section发生移动，则视为删除+添加，这样可以刷新header，触发headerForSection
    [sectionResult.moves enumerateObjectsUsingBlock:^(IGListMoveIndex * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mSectionUpdates addIndex:obj.from];
        [mSectionUpdates addIndex:obj.to];
    }];
    // 将刷新的Section从Inserts和Deletes中剔除
    [mSectionInserts removeIndexes:mSectionUpdates];
    [mSectionDeletes removeIndexes:mSectionUpdates];
    
    // 细化需要更新的Section为Row的增加、删除、移动
    NSMutableArray<NSIndexPath *> * mRowsDelete = [NSMutableArray array];
    NSMutableArray<NSIndexPath *> * mRowsInsert = [NSMutableArray array];
    NSMutableArray<NSIndexPath *> * mRowsUpdate = [NSMutableArray array];
    NSMutableDictionary<NSIndexPath *, NSIndexPath *> * mRowsMove = [NSMutableDictionary dictionary];
    [mSectionUpdates enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
        NSArray<ZXTableViewDiffModel *> * oldRowModels = oldInfo.sectionModels[section].diffableObjects;
        NSArray<ZXTableViewDiffModel *> * newRowModels = newInfo.sectionModels[section].diffableObjects;
        IGListIndexSetResult * rowResults = [self getDiffResultWithNewObjects:newRowModels oldObjects:oldRowModels];
        [rowResults.deletes enumerateIndexesUsingBlock:^(NSUInteger row, BOOL * _Nonnull stop) {
            ZXTableViewDiffModel * oldModel = oldRowModels[row];
            NSIndexPath * path = [NSIndexPath indexPathForRow:oldModel.row inSection:oldModel.section];
            [mRowsDelete addObject:path];
        }];
        [rowResults.inserts enumerateIndexesUsingBlock:^(NSUInteger row, BOOL * _Nonnull stop) {
            ZXTableViewDiffModel * newModel = newRowModels[row];
            NSIndexPath * path = [NSIndexPath indexPathForRow:newModel.row inSection:newModel.section];
            [newModel.object zx_clearModelHeight]; // 清除高度缓存
            [newModel.object zx_unMarkModify]; // 重置修改标识
            [mRowsInsert addObject:path];
        }];
        [rowResults.updates enumerateIndexesUsingBlock:^(NSUInteger row, BOOL * _Nonnull stop) {
            ZXTableViewDiffModel * oldModel = oldRowModels[row];
            [oldModel.object zx_clearModelHeight]; // 清除高度缓存
            [oldModel.object zx_unMarkModify]; // 重置修改标识
            NSIndexPath * path = [NSIndexPath indexPathForRow:oldModel.row inSection:oldModel.section];
            [mRowsUpdate addObject:path];
        }];
        [rowResults.moves enumerateObjectsUsingBlock:^(IGListMoveIndex * _Nonnull move, NSUInteger idx, BOOL * _Nonnull stop) {
            ZXTableViewDiffModel * oldModel = oldRowModels[move.from];
            ZXTableViewDiffModel * newModel = newRowModels[move.to];
            [newModel.object zx_clearModelHeight]; // 清除高度缓存
            [newModel.object zx_unMarkModify]; // 重置修改标识
            NSIndexPath * key = [NSIndexPath indexPathForRow:oldModel.row inSection:oldModel.section];
            NSIndexPath * value = [NSIndexPath indexPathForRow:newModel.row inSection:newModel.section];
            mRowsMove[key] = value;
        }];
    }];
    BOOL hideAnimation = (animation == UITableViewRowAnimationNone);
    if (hideAnimation) {
        [UIView setAnimationsEnabled:NO];
    }
    [tableView performBatchUpdates:^{
        // section change
        [tableView deleteSections:mSectionDeletes withRowAnimation:animation];
        [tableView insertSections:mSectionInserts withRowAnimation:animation];
        // row change
        [tableView reloadRowsAtIndexPaths:mRowsUpdate withRowAnimation:animation];
        [tableView deleteRowsAtIndexPaths:mRowsDelete withRowAnimation:animation];
        [tableView insertRowsAtIndexPaths:mRowsInsert withRowAnimation:animation];
        [mRowsMove enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * _Nonnull key, NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            [tableView moveRowAtIndexPath:key toIndexPath:obj];
        }];
    } completion:^(BOOL finished) {
        if (hideAnimation) {
            [UIView setAnimationsEnabled:YES];
        }
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Private Methods
// 生成Cell
- (UITableViewCell<ZXTableViewAutoHeightCellProtocol> *)getCellWithTableView:(UITableView *)tableView class:(Class)cls indexPath:(NSIndexPath *)indexPath dequeue:(BOOL)dequeue {
    if (![self hasRegisterTableView:tableView]) {
        return nil;
    }
    NSString * reuseIdentifier = NSStringFromClass(cls);
    UITableViewCellStyle style = [self getCellStyleForTableView:tableView section:indexPath.section row:indexPath.row];
    UITableViewCell * cell = nil;
    if (dequeue) {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [[cls alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
        }
    } else {
        cell = [[cls alloc] initWithStyle:style reuseIdentifier:nil];
    }
    NSAssert([self isAutoHeightCell:cell], @"%@ 没有实现 zx_updateUIWithModel: 方法", NSStringFromClass(cls));
    UITableViewCell<ZXTableViewAutoHeightCellProtocol> * targetCell = (UITableViewCell<ZXTableViewAutoHeightCellProtocol> *)cell;
    id object = [self getObjectForRow:indexPath.row section:indexPath.section tableView:tableView];
    [targetCell zx_updateUIWithModel:object];
    return targetCell;
}

// 获取CellHeight
- (CGFloat)getCellHeightForTableView:(UITableView *)tableView model:(id)model cellClass:(Class<ZXTableViewAutoHeightCellProtocol>)cellClass indexPath:(NSIndexPath *)indexPath {
    if (!tableView || !model) {
        return 0;
    }
    if ([model zx_hasModelHeight]) {
//        NSLog(@"cal:cache %@", indexPath);
        return [model zx_modelHeight];
    }
    return [self updateHeightForTable:tableView model:model cellClass:cellClass indexPath:indexPath];
}

// 是否注册过tableView
- (BOOL)hasRegisterTableView:(UITableView *)tableView {
    if (tableView) {
        return [self.registerTable.keyEnumerator.allObjects containsObject:tableView];
    }
    return NO;
}

// 是否是遵循自动计算协议的cell
- (BOOL)isAutoHeightCell:(UITableViewCell *)cell {
    return [cell respondsToSelector:@selector(zx_updateUIWithModel:)];
}

// 按顺序获取所有数据源
- (ZXTableViewDataInfoModel *)getDataInfoForTableView:(UITableView *)tableView {
    ZXTableViewDataInfoModel * dataInfo = [ZXTableViewDataInfoModel new];
    NSMutableArray<ZXTableViewDiffSectionModel *> * list = [NSMutableArray array];
    NSInteger sectionNum = [self getSectionNumForTableView:tableView];
    for (int i = 0; i < sectionNum; ++i) {
        NSArray * sectionObjects = [self getObjectsForTableView:tableView section:i];
        [list addObject:[[ZXTableViewDiffSectionModel alloc] initWithSection:i objects:sectionObjects]];
    }
    dataInfo.sectionModels = list;
    return dataInfo;
}

// 获取CellStyle
- (UITableViewCellStyle)getCellStyleForTableView:(UITableView *)tableView section:(NSInteger)section row:(NSInteger)row {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(zx_tableView:cellStyleForRowAtIndexPath:object:)]) {
        return [self.dataSource zx_tableView:tableView cellStyleForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] object:[self getObjectForRow:row section:section tableView:tableView]];
    }
    return UITableViewCellStyleDefault;
}

// 获取CellClass
- (Class)getCellClassForTableView:(UITableView *)tableView section:(NSInteger)section row:(NSInteger)row {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(zx_tableView:cellClassForRowAtIndexPath:object:)]) {
        return [self.dataSource zx_tableView:tableView cellClassForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] object:[self getObjectForRow:row section:section tableView:tableView]];
    }
    return nil;
}

// 获取section数量
- (NSInteger)getSectionNumForTableView:(UITableView *)tableView {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(zx_numberOfSectionsInTableView:)]) {
        return [self.dataSource zx_numberOfSectionsInTableView:tableView];
    }
    return 1;
}

- (NSArray *)getObjectsForTableView:(UITableView *)tableView section:(NSInteger)section {
    NSInteger sectionNum = [self getSectionNumForTableView:tableView];
    if (section < sectionNum) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(zx_tableView:objectsInSection:)]) {
            return [self.dataSource zx_tableView:tableView objectsInSection:section];
        }
    }
    return nil;
}

// 获取指定section的数据列表
- (id)getObjectForRow:(NSInteger)row section:(NSInteger)section tableView:(UITableView *)tableView {
    NSArray * objects = [self getObjectsForTableView:tableView section:section];
    if (row < objects.count) {
        return objects[row];
    }
    return nil;
}

// 更新计算cell高度
- (CGFloat)updateHeightForTable:(UITableView *)tableView model:(id)model cellClass:(Class<ZXTableViewAutoHeightCellProtocol>)cellClass indexPath:(NSIndexPath *)indexPath {
    if (!tableView || !model) {
        return 0;
    }
    
    /*
     若用 dequeue 取 cell，会产生调用循环：
     系统机制：
        当 dequeue cell时，
            若 cell 存在，会调用 heightForRow 为cell设置frame
            若 cell 不存在，返回为 nil
        cell alloc initWithStyle:reuseIdentifier: 会加入到复用池子
        cell 复用池只增不减
     调用循环：
        ->1 刷新 A 位置
        ->2 dequeue 找到复用的cell
        ->3 调用 heightForRow 设置 cell 的frame
        ->4 A 位置height需要计算，所以 dequeue 找另一个复用的cell
        ->5 (若cell 存在，->3；)最终cell会不存在，->6
        ->6 cell不存在，alloc initWithStyle:reuseIdentifier: 一个新的cell加入到复用池
        ->7 通过新alloc的 cell 计算并返回了高度
     结论：
        当一个位置A需要刷新、重新计算高度、有复用的cell时，会产生一个新的cell加入到复用池
     **/
    
    id cell = [self getCellWithTableView:tableView class:cellClass indexPath:indexPath dequeue:NO];
    UITableViewCell * tableViewCell = (UITableViewCell *)cell;
//    NSLog(@"cal:cal %@", indexPath);
    CGSize size = [tableViewCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    // record height
    [model zx_updateModelHeight:size.height];
    return size.height;
}

// 清除高度缓存
- (void)clearHeightForTable:(UITableView *)tableView model:(ZXTableViewDiffModel *)model {
    if (!model.object || ![self hasRegisterTableView:tableView]) {
        return;
    }
    [model.object zx_clearModelHeight];
}

// 差异计算
- (IGListIndexSetResult *)getDiffResultWithNewObjects:(NSArray<id<IGListDiffable>> *)newObjects oldObjects:(NSArray<id<IGListDiffable>> *)oldObjects {
    return IGListDiff(oldObjects, newObjects, IGListDiffEquality);
}

#pragma mark - Getter
- (NSMapTable<UITableView *,ZXTableViewDataInfoModel *> *)registerTable {
    if (!_registerTable) {
        _registerTable = [NSMapTable weakToStrongObjectsMapTable];
    }
    return _registerTable;
}

@end
