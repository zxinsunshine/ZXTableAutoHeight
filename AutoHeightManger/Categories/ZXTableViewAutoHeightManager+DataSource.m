//
//  ZXTableViewAutoHeightManager+DataSource.m
//  Test
//
//  Created by Theo on 2023/4/7.
//

#import "ZXTableViewAutoHeightManager+DataSource.h"
#import "ZXTableViewAutoHeightManagerInternal.h"
#import <objc/runtime.h>

#define kTableViewDataSourceName "UITableViewDataSource"
#define kTableViewDelegateName "UITableViewDelegate"

@interface ZXTableViewAutoHeightManager()

@end

@implementation ZXTableViewAutoHeightManager (DataSource)

#pragma mark - 实现原生的数据源和代理
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self getSectionNumForTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getObjectsForTableView:tableView section:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"cellForRow: %@", indexPath);
    Class cls = [self getCellClassForTableView:tableView section:indexPath.section row:indexPath.row];
    UITableViewCell<ZXTableViewAutoHeightCellProtocol> * cell = [self getCellWithTableView:tableView class:cls indexPath:indexPath dequeue:YES];
    id object = [self getObjectForRow:indexPath.row section:indexPath.section tableView:tableView];
    [cell zx_updateUIWithModel:object];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(zx_tableView:didGenerateCell:forRowAtIndexPath:object:)]) {
        [self.delegate zx_tableView:tableView didGenerateCell:cell forRowAtIndexPath:indexPath object:object];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self getCellHeightForTableView:tableView model:[self getObjectForRow:indexPath.row section:indexPath.section tableView:tableView] cellClass:[self getCellClassForTableView:tableView section:indexPath.section row:indexPath.row] indexPath:indexPath];
}

#pragma mark - 其它数据源和代理映射
#pragma mark - Methods Forward
// 优先manager的DataSource或Delegate响应
- (BOOL)respondsToSelector:(SEL)aSelector {
    id responseObj = [self targetResponseForSel:aSelector];
    if (responseObj) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

// 优先manager的DataSource或Delegate响应
- (id)forwardingTargetForSelector:(SEL)aSelector {
    id responseObj = [self targetResponseForSel:aSelector];
    if (responseObj) {
        return responseObj;
    }
    return [super forwardingTargetForSelector:aSelector];
}

// 找到实现DataSource或Delegate的对象
- (id)targetResponseForSel:(SEL)aSelector {
    Protocol * tableViewDataSource = objc_getProtocol(kTableViewDataSourceName);
    struct objc_method_description requiredDataSourceMethodDesc = protocol_getMethodDescription(tableViewDataSource, aSelector, YES, YES);
    struct objc_method_description optionalDataSourceMethodDesc = protocol_getMethodDescription(tableViewDataSource, aSelector, NO, YES);
    if (requiredDataSourceMethodDesc.name || optionalDataSourceMethodDesc.name) {
        if ([self.dataSource respondsToSelector:aSelector]) {
            return self.dataSource;
        }
    }
    Protocol * tableViewDelegate = objc_getProtocol(kTableViewDelegateName);
    struct objc_method_description requiredDataDelegateMethodDesc = protocol_getMethodDescription(tableViewDelegate, aSelector, YES, YES);
    struct objc_method_description optionalDataDelegateMethodDesc = protocol_getMethodDescription(tableViewDelegate, aSelector, NO, YES);
    if (requiredDataDelegateMethodDesc.name || optionalDataDelegateMethodDesc.name) {
        if ([self.delegate respondsToSelector:aSelector]) {
            return self.delegate;
        }
    }
    return nil;
}


@end
