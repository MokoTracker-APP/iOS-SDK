//
//  MKUpdatePageCell.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/12/2.
//

#import "MKUpdatePageCell.h"

@interface MKUpdatePageCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@end

@implementation MKUpdatePageCell

+ (MKUpdatePageCell *)initCellWithTableView:(UITableView *)tableView {
    MKUpdatePageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKUpdatePageCellIdenty"];
    if (!cell) {
        cell = [[MKUpdatePageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKUpdatePageCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _msgLabel;
}

@end
