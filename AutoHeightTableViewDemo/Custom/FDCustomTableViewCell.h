//
//  FDCustomTableViewCell.h
//  Test
//
//  Created by Theo on 2023/4/3.
//

#import <UIKit/UIKit.h>
#import <ZXTableAutoHeight/ZXTableAutoHeight.h>

NS_ASSUME_NONNULL_BEGIN

@interface FDCustomTableViewCell : UITableViewCell<ZXTableViewAutoHeightCellProtocol>

@property (nonatomic, strong) NSNumber * number;

@end

NS_ASSUME_NONNULL_END
