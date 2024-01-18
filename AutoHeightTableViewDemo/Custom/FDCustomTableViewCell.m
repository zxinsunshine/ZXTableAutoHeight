//
//  FDCustomTableViewCell.m
//  Test
//
//  Created by Theo on 2023/4/3.
//

#import "FDCustomTableViewCell.h"
#import "ZXCustomCellModel.h"

@interface FDCustomTableViewCell()

@property (nonatomic, copy) NSString * text;
@property (nonatomic, strong) UILabel * label;

@end

@implementation FDCustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIView * superView = self.contentView;
    [superView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
}

- (void)setText:(NSString *)text {
    _text = text;
    self.label.text = text;
}

- (void)setNumber:(NSNumber *)number {
    _number = number;
    NSInteger n = [number integerValue];
    NSMutableString * mStr = [NSMutableString string];
    for (int i = 0; i < n * 10 + 1; ++i) {
        [mStr appendString:@(n).stringValue];
    }
    self.text = mStr;
}

- (void)zx_updateUIWithModel:(id)model tableView:(UITableView *)tableView {
    if (![model isKindOfClass:[ZXCustomCellModel class]]) {
        return;
    }
    // label的最大宽度根据 tableView size 设置
    // 若是YYLabel， 需要设置 preferredMaxLayoutWidth 是为了能自动计算 size
//    self.label.preferredMaxLayoutWidth = tableView.bounds.size.width;
    ZXCustomCellModel * m = (ZXCustomCellModel *)model;
    self.number = @(m.index);
}

zx_getter(UILabel *, label, ({
    UILabel * label = [[UILabel alloc] init];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label;
}))


@end
