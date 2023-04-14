//
//  ZXTableViewDiffSectionModel.m
//  Test
//
//  Created by Theo on 2023/4/12.
//

#import "ZXTableViewDiffSectionModel.h"
#import "ZXTableViewDiffModel.h"
#import "NSObject+ZXTableViewAutoHeightMark.h"

@interface ZXTableViewDiffSectionModel()

@property (nonatomic, assign, readwrite) NSInteger section;
@property (nonatomic, strong, readwrite) NSArray<ZXTableViewDiffModel *> * diffableObjects;
@property (nonatomic, copy, readwrite) NSString * uniqueKey;
@property (nonatomic, strong) NSArray * objects;

@end

@implementation ZXTableViewDiffSectionModel

- (instancetype)initWithSection:(NSInteger)section objects:(NSArray *)objects {
    self = [super init];
    if (self) {
        self.section = section;
        NSMutableArray * list = [NSMutableArray array];
        self.uniqueKey = [NSString stringWithFormat:@"%p", objects];
        self.objects = [NSArray arrayWithArray:objects]; // 新建一个Array，复制指针
        [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZXTableViewDiffModel * diffModel = [[ZXTableViewDiffModel alloc] initWithSection:section row:idx object:obj];
            [list addObject:diffModel];
        }];
        self.diffableObjects = list;
    }
    return self;
}

#pragma mark - IGListDiffable

// 是否是同一个对象（唯一性）
- (id<NSObject>)diffIdentifier {
    return self.uniqueKey; // 原Section中Row队列的地址作为Section的唯一标识符
}

// 是否有更新
- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    __block BOOL isEqual = YES;
    ZXTableViewDiffSectionModel * otherObject = (ZXTableViewDiffSectionModel *)object;
    if (![otherObject isKindOfClass:[ZXTableViewDiffSectionModel class]]) { // 类型不一样
        isEqual = NO;
    } else if (self.diffableObjects.count != otherObject.diffableObjects.count) { // 数量不一样
        isEqual = NO;
    } else { // 数量一致，比较objects是否全部一样
        NSMutableArray * leftSectionObjects = [NSMutableArray arrayWithArray:self.objects];
        [leftSectionObjects removeObjectsInArray:otherObject.objects];
        if (leftSectionObjects.count > 0) { // objects地址不一致
            isEqual = NO;
        } else {
            [self.objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj zx_isModified]) { // objects中有数据被修改过
                    isEqual = NO;
                    *stop = YES;
                }
            }];
        }
    }
    return isEqual;
}


@end
