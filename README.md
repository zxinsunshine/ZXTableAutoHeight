# ZXTableAutoHeight

----------------

A more effictive UITableViewCell Self-Sizing framework based on cell's auto layout.

#### Multilingual translation

[Chinese README](README.zh.md)

#### Main Features

* Automatically calculate height and cache the result based on cell's auto layout
* Update only the changed part of data analyed by Heckel Diff algorithm
* Automatically pass data to cell after cell has conformed the specifical protocol 
* Available to manage a lot of tableView

#### Requirements

* iOS 11.0+

#### Installation

##### CocoaPods

The preferred installation method is with [CocoaPods](https://cocoapods.org). Add the following to your `Podfile`:

```ruby
pod 'ZXTableAutoHeight'
```

##### Manual

Copy AutoHeightManger directory in your project


#### Getting Started

##### Step 1
* UITableViewCell conform protocol
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

##### Step 2
* implement delegate and datasource
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

##### Step 3
* update modified part（should mark the data when only change the data's value）
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

`ZXTableAutoHeight` is [MIT-licensed](https://github.com/zxinsunshine/ZXTableAutoHeight/blob/master/LICENSE).
