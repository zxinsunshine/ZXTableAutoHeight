//
//  ZXTableViewAutoHeightManager+Observer.m
//  Test
//
//  Created by Theo on 2023/4/7.
//

#import "ZXTableViewAutoHeightManager+Observer.h"
#import "ZXTableViewAutoHeightManagerInternal.h"
#import "ZXTableViewAutoHeightManager+DataSource.h"

@implementation ZXTableViewAutoHeightManager (Observer)

#pragma mark - Observer Noti
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSString *contextString = (__bridge NSString *)(context);
    if (![contextString isEqualToString:ZXTableViewObserverContext]) {
        return;
    }
    if (![self hasRegisterTableView:object]) {
        return;
    }
    if ([keyPath isEqualToString:zx_kEstimateHeightKey]) {
        CGFloat newEstimateHeight = [change[NSKeyValueChangeNewKey] floatValue];
        if (newEstimateHeight != 0) { // disable system auto layout
            UITableView * tableView = (UITableView *)object;
            tableView.estimatedRowHeight = 0;
        }
    } else if ([keyPath isEqualToString:zx_kDelegateKey]) {
        id newDelegate = change[NSKeyValueChangeNewKey];
        if (![newDelegate isEqual:self]) {
            UITableView * tableView = (UITableView *)object;
            tableView.delegate = self;
        }
    } else if ([keyPath isEqualToString:zx_kDataSourceKey]) {
        id newDataSource= change[NSKeyValueChangeNewKey];
        if (![newDataSource isEqual:self]) {
            UITableView * tableView = (UITableView *)object;
            tableView.dataSource = self;
        }
    } else if ([keyPath isEqualToString:zx_kBoundsKey]) {
        CGRect oldBounds = [change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newBounds = [change[NSKeyValueChangeNewKey] CGRectValue];
        if (!CGSizeEqualToSize(oldBounds.size, newBounds.size) && [object isKindOfClass:[UITableView class]]) {
            UITableView * tableView = (UITableView *)object;
            [self reloadTableView:tableView]; // tableView size 改变，重新计算所有高度
        }
    }
}


@end
