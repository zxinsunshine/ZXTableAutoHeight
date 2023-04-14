//
//  ZXTableViewDiffModel.m
//  Test
//
//  Created by Theo on 2023/4/6.
//

#import "ZXTableViewDiffModel.h"
#import "NSObject+ZXTableViewAutoHeightMark.h"

@interface ZXTableViewDiffModel()

@property (nonatomic, assign, readwrite) NSInteger section;
@property (nonatomic, assign, readwrite) NSInteger row;
@property (nonatomic, strong, readwrite) id object;
@property (nonatomic, copy, readwrite) NSString * uniqueKey;
@end

@implementation ZXTableViewDiffModel

- (instancetype)initWithSection:(NSInteger)section row:(NSInteger)row object:(_Nonnull id)object
{
    self = [super init];
    if (self) {
        self.section = section;
        self.row = row;
        self.object = object;
        self.uniqueKey = [NSString stringWithFormat:@"%p", self.object];
    }
    return self;
}

- (void)unMardModeify {
    [self.object zx_unMarkModify];
}

#pragma mark - IGListDiffable

// 是否是同一个对象（唯一性）
- (id<NSObject>)diffIdentifier {
    return self.uniqueKey;
}

// 是否有更新
- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return ![self.object zx_isModified];
}

@end
