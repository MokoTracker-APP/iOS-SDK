//
//  MKSettingTextCell.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/30.
//

#import "MKSettingTextCell.h"

#import "MKSettingTextCellModel.h"

@interface MKSettingTextCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKSettingTextCell

+ (MKSettingTextCell *)initCellWithTableView:(UITableView *)tableView {
    MKSettingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKSettingTextCellIdenty"];
    if (!cell) {
        cell = [[MKSettingTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKSettingTextCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.rightIcon];
        [self.contentView addTapAction:self selector:@selector(didSelectedCell)];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(-1.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.rightIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(8.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(14.f);
    }];
}

#pragma mark - event method
- (void)didSelectedCell {
    if ([self.delegate respondsToSelector:@selector(settingTextCellSelected:indexPath:)]) {
        [self.delegate settingTextCellSelected:self.dataModel.tapSelector indexPath:self.indexPath];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKSettingTextCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = SafeStr(dataModel.msg);
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
    }
    return _msgLabel;
}

- (UIImageView *)rightIcon {
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
        _rightIcon.image = LOADIMAGE(@"goto_next_button", @"png");
    }
    return _rightIcon;
}

@end
