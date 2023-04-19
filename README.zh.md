# ZXTableAutoHeight

----------------

一款自动计算UITableViewCell大小的框架

#### 多语言翻译

[英文README](README.md)

#### 主要特性

* cell高度会根据其中的自动布局计算&缓存
* 数据使用Heckel Diff算法对比后局部刷新
* 实现cell协议后，不用再手动管理数据注入时机
* 可同时管理多个tableView

#### 要求

* iOS 11.0+

#### 安装教程

##### CocoaPods

推荐使用[CocoaPods](https://cocoapods.org)来进行安装，只需添加如下语句到你的Podfile文件中:

```ruby
pod 'ZXTableAutoHeight'
```

##### 手动安装

将AutoHeightManger文件夹拖入工程中直接使用


#### 入门指南

##### 第一步
* UITableViewCell实现数据注入协议
```objective-c
#import <ZXTableAutoHeight/ZXTableAutoHeight.h>

// .h
@interface FDCustomTableViewCell : UITableViewCell<ZXTableViewAutoHeightCellProtocol>
@end

// .m
@implementation FDCustomTableViewCell

- (void)zx_updateUIWithModel:(id)model {
    // update UI based on model
    ...
}
@end
```

##### 第二步
* 实现AutoManager代理
```objective-c
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
    
    ...
    // register tableView to manager
    [self.autoManager registerTableView:self.listView];
}

#pragma mark - ZXTableViewAutoHeightDataSource
// section number
- (NSInteger)zx_numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

// section items
- (NSArray *_Nullable)zx_tableView:(UITableView *_Nullable)tableView objectsInSection:(NSInteger)section {
    NSArray * list = self.dataList[section];
    return list;
}

// cell Class
- (Class)zx_tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath object:(id)object {
    return [FDCustomTableViewCell class];
}

#pragma mark - ZXTableViewAutoHeightDelegate
// cope cell after generate ( like event cope )
- (void)zx_tableView:(UITableView *)tableView didGenerateCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath object:(id)object {
    
    ...
}

@end
```

##### 第三步
* 局部更新（改变数据值需要 mark 一下）
```objective-c
#import <ZXTableAutoHeight/ZXTableAutoHeight.h>

- (void)modifyItem:(NSIndexPath *)indexPath {
    NSMutableArray * obj = self.dataList[indexPath.section];
    ZXCustomCellModel * m = obj[indexPath.row];
    m.index = 3;
    // Mark Previous Data as Modified
    [m zx_markModify]; 
    // update modified part only
    [self.autoManager updateTableView:tableView animation:UITableViewRowAnimationNone completion:nil];
}

- (void)insertItem:(NSIndexPath *)indexPath {
    NSMutableArray * obj = self.dataList[indexPath.section];
    ZXCustomCellModel * m1 = [ZXCustomCellModel new];
    // insert/delete/replace data without mark
    [obj insertObject:m1 atIndex:indexPath.row];
    // update changed part only
    [self.autoManager updateTableView:tableView animation:UITableViewRowAnimationNone completion:nil];
}
```

#### License

`ZXTableAutoHeight` 遵循[MIT-licensed](https://github.com/zxinsunshine/ZXTableAutoHeight/blob/master/LICENSE).

