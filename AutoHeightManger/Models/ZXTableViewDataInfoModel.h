//
//  ZXTableViewDataInfoModel.h
//  Test
//
//  Created by Theo on 2023/4/7.
//

#import <Foundation/Foundation.h>
#import "ZXTableViewDiffSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZXTableViewDataInfoModel : NSObject

@property (nonatomic, strong) NSArray<ZXTableViewDiffSectionModel *> * sectionModels;

@end

NS_ASSUME_NONNULL_END
