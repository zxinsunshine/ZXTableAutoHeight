//
//  MainViewController.m
//  AutoHeightTableViewDemo
//
//  Created by Theo on 2023/4/13.
//

#import "MainViewController.h"
#import "FDCustomTableViewCell.h"
#import "ZXCustomCellModel.h"
#import <ZXTableAutoHeight/ZXTableAutoHeight.h>

@interface MainViewController ()<ZXTableViewAutoHeightDelegate,ZXTableViewAutoHeightDataSource>

@property (nonatomic, strong) UITableView * listView;
@property (nonatomic, strong) NSMutableArray * dataList;
@property (nonatomic, strong) ZXTableViewAutoHeightManager * autoManager;

@end

@implementation MainViewController

#pragma mark - Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupData];
    [self.autoManager registerTableView:self.listView];
}

#pragma mark - Private Methods
- (void)setupData {
    self.dataList = [NSMutableArray array];
    for (int i = 0; i < 3; ++i) {
        NSMutableArray * arr = [NSMutableArray array];
        for (int j = 0; j < 10; ++j) {
            ZXCustomCellModel * m = [ZXCustomCellModel new];
            m.index = 10 + j;
            [arr addObject:m];
        }
        [self.dataList addObject:arr];
    }
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - ZXTableViewAutoHeightDataSource
- (NSInteger)zx_numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSArray *_Nullable)zx_tableView:(UITableView *_Nullable)tableView objectsInSection:(NSInteger)section {
    NSArray * list = self.dataList[section];
    return list;
}

- (Class)zx_tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath object:(id)object {
    return [FDCustomTableViewCell class];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%zd", section];
}

#pragma mark - ZXTableViewAutoHeightDelegate
- (void)zx_tableView:(UITableView *)tableView didGenerateCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath object:(id)object {
    cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // test
    [self modifyItem:indexPath];
    [self deleteItem:indexPath];
    [self insertItem:indexPath];
//    [self moveSection:indexPath.section];
    [self.autoManager updateTableView:tableView animation:UITableViewRowAnimationNone completion:nil];
//    [self.autoManager reloadTableView:tableView];
}

- (void)modifyItem:(NSIndexPath *)indexPath {
    NSMutableArray * obj = self.dataList[indexPath.section];
    ZXCustomCellModel * m = obj[indexPath.row];
    m.index = 3;
    [m zx_markModify];
}

- (void)deleteItem:(NSIndexPath *)indexPath {
    NSMutableArray * obj = self.dataList[indexPath.section];
    ZXCustomCellModel * m = obj[indexPath.row];
    [obj removeObject:m];
}

- (void)insertItem:(NSIndexPath *)indexPath {
    NSMutableArray * obj = self.dataList[indexPath.section];
    ZXCustomCellModel * m1 = [ZXCustomCellModel new];
    m1.index = 5;
    [obj insertObject:m1 atIndex:indexPath.row];
}

- (void)moveSection:(NSInteger)section {
    NSMutableArray * obj = self.dataList[section];
    [self.dataList removeObject:obj];
    [self.dataList insertObject:obj atIndex:(section + 1)%self.dataList.count];
}

#pragma mark - Getter
zx_getter(UITableView *, listView, ({
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView;
}))

zx_getter(ZXTableViewAutoHeightManager *, autoManager, ({
    ZXTableViewAutoHeightManager * manager = [ZXTableViewAutoHeightManager new];
    manager.dataSource = self;
    manager.delegate = self;
    manager;
}))

@end
