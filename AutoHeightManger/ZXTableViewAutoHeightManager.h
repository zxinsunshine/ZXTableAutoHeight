//
//  ZXTableViewAutoHeightManager.h
//  AutoUITableView
//
//  Created by Theo on 2023/3/22.
//

#import <UIKit/UIKit.h>
#import "ZXTableViewAutoHeightDelegate.h"
#import "ZXTableViewAutoHeightDataSource.h"

@class ZXTableViewAutoHeightManager;

NS_ASSUME_NONNULL_BEGIN

@interface ZXTableViewAutoHeightManager : NSObject

@property (nonatomic, weak) id<ZXTableViewAutoHeightDelegate> delegate;
@property (nonatomic, weak) id<ZXTableViewAutoHeightDataSource> dataSource;

#pragma mark - Public Register Methods
- (void)registerTableView:(UITableView *)tableView;
- (void)removeTableView:(UITableView *)tableView;

#pragma mark - Public Update Methods
- (void)reloadTableView:(UITableView *)tableView;
- (void)updateTableView:(UITableView *)tableView animation:(UITableViewRowAnimation)animation completion:(void(^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
