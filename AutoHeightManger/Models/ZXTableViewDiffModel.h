//
//  ZXTableViewDiffModel.h
//  Test
//
//  Created by Theo on 2023/4/6.
//

#import <Foundation/Foundation.h>
#import <IGListDiffKit/IGListDiffKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZXTableViewDiffModel : NSObject<IGListDiffable>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithSection:(NSInteger)section row:(NSInteger)row object:(_Nonnull id)object;

@property (nonatomic, assign, readonly) NSInteger section;
@property (nonatomic, assign, readonly) NSInteger row;
@property (nonatomic, strong, readonly) id object;
@property (nonatomic, copy, readonly) NSString * uniqueKey;

- (void)unMardModeify;

@end

NS_ASSUME_NONNULL_END
