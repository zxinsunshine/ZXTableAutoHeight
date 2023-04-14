//
//  ZXTableViewDiffSectionModel.h
//  Test
//
//  Created by Theo on 2023/4/12.
//

#import <Foundation/Foundation.h>
#import <IGListDiffKit/IGListDiffKit.h>
#import "ZXTableViewDiffModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZXTableViewDiffSectionModel : NSObject<IGListDiffable>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithSection:(NSInteger)section objects:(NSArray *)objects;

@property (nonatomic, strong, readonly) NSArray<ZXTableViewDiffModel *> * diffableObjects;

@end

NS_ASSUME_NONNULL_END
