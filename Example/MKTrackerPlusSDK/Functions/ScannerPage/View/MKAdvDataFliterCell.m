//
//  MKAdvDataFliterCell.m
//  MKContactTracker
//
//  Created by aa on 2020/4/24.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKAdvDataFliterCell.h"
#import "MKAdvDataFliterCellModel.h"

@interface MKAdvDataFliterCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UISwitch *switchView;

@property (nonatomic, strong)UIImageView *selectedIcon;

@property (nonatomic, strong)UILabel *whiteListMsgLabel;

@property (nonatomic, strong)UIControl *whiteListButton;

@property (nonatomic, strong)UIView *textView;

@property (nonatomic, strong)UITextField *textField;

@end

@implementation MKAdvDataFliterCell

+ (MKAdvDataFliterCell *)initCellWithTableView:(UITableView *)tableView {
    MKAdvDataFliterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKAdvDataFliterCellIdenty"];
    if (!cell) {
        cell = [[MKAdvDataFliterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKAdvDataFliterCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.switchView];
        [self.contentView addSubview:self.whiteListButton];
        [self.whiteListButton addSubview:self.selectedIcon];
        [self.whiteListButton addSubview:self.whiteListMsgLabel];
        [self.contentView addSubview:self.textView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.switchView.mas_left).mas_offset(-10.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.msgLabel.mas_centerY);
        make.width.mas_equalTo(45.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.whiteListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(10.f);
        make.width.mas_equalTo(120.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.selectedIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(2.f);
        make.width.mas_equalTo(15.f);
        make.centerY.mas_equalTo(self.whiteListButton.mas_centerY);
        make.height.mas_equalTo(15.f);
    }];
    [self.whiteListMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectedIcon.mas_right).mas_offset(3.f);
        make.right.mas_equalTo(-5.f);
        make.centerY.mas_equalTo(self.whiteListButton.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.whiteListButton.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(35.f);
    }];
}

#pragma mark - event method
- (void)switchViewValueChanged {
    self.textView.hidden = !self.switchView.isOn;
    self.whiteListButton.hidden = !self.switchView.isOn;
    if ([self.delegate respondsToSelector:@selector(advDataFliterCellSwitchStatusChanged:index:)]) {
        [self.delegate advDataFliterCellSwitchStatusChanged:self.switchView.isOn index:self.dataModel.index];
    }
}

- (void)textFieldValueChanged {
    if (self.dataModel.maxLength > 0 && self.textField.text.length > self.dataModel.maxLength) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(advertiserFilterContent:index:)]) {
        [self.delegate advertiserFilterContent:self.textField.text index:self.dataModel.index];
    }
}

- (void)whiteListButtonPressed {
    self.whiteListButton.selected = !self.whiteListButton.selected;
    NSString *iconName = (self.whiteListButton.isSelected ? @"rightIconSelectedCircle" : @"rightIconUnselectedCircle");
    self.selectedIcon.image = LOADIMAGE(iconName, @"png");
    if ([self.delegate respondsToSelector:@selector(advDataFilterCellWhiteListState:index:)]) {
        [self.delegate advDataFilterCellWhiteListState:self.whiteListButton.isSelected index:self.dataModel.index];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKAdvDataFliterCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = _dataModel.msg;
    if (self.textField.superview) {
        [self.textField removeFromSuperview];
    }
    self.textField = nil;
    self.textField = [self textFieldWithPlaceholder:_dataModel.textPlaceholder
                                              value:_dataModel.textFieldValue
                                          maxLength:_dataModel.maxLength
                                               type:_dataModel.textFieldType];
    [self.textView addSubview:self.textField];
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(2.f);
        make.bottom.mas_equalTo(0);
    }];
    [self.switchView setOn:_dataModel.isOn];
    [self.textView setHidden:!_dataModel.isOn];
    [self.whiteListButton setHidden:!_dataModel.isOn];
    self.whiteListButton.selected = _dataModel.whiteListIsOn;
    NSString *iconName = (self.whiteListButton.isSelected ? @"rightIconSelectedCircle" : @"rightIconUnselectedCircle");
    self.selectedIcon.image = LOADIMAGE(iconName, @"png");
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

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        [_switchView addTarget:self
                        action:@selector(switchViewValueChanged)
              forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (UIImageView *)selectedIcon {
    if (!_selectedIcon) {
        _selectedIcon = [[UIImageView alloc] init];
        _selectedIcon.image = LOADIMAGE(@"rightIconUnselectedCircle", @"png");
    }
    return _selectedIcon;
}

- (UILabel *)whiteListMsgLabel {
    if (!_whiteListMsgLabel) {
        _whiteListMsgLabel = [[UILabel alloc] init];
        _whiteListMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _whiteListMsgLabel.font = MKFont(13.f);
        _whiteListMsgLabel.textAlignment = NSTextAlignmentLeft;
        _whiteListMsgLabel.text = @"Whitelist";
    }
    return _whiteListMsgLabel;
}

- (UIControl *)whiteListButton {
    if (!_whiteListButton) {
        _whiteListButton = [[UIControl alloc] init];
        [_whiteListButton addTapAction:self selector:@selector(whiteListButtonPressed)];
    }
    return _whiteListButton;
}

- (UIView *)textView {
    if (!_textView) {
        _textView = [[UIView alloc] init];
        _textView.backgroundColor = COLOR_WHITE_MACROS;
        _textView.layer.masksToBounds = YES;
        _textView.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textView.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        
        UIView *topLine = [[UIView alloc] init];
        topLine.backgroundColor = CUTTING_LINE_COLOR;
        [_textView addSubview:topLine];
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(2.f);
        }];
    }
    return _textView;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder
                                    value:(NSString *)value
                                maxLength:(NSInteger)maxLength
                                     type:(mk_CustomTextFieldType)type {
    UITextField *textField = [[UITextField alloc] initWithTextFieldType:type];
    textField.maxLength = maxLength;
    textField.placeholder = placeholder;
    textField.text = value;
    textField.font = MKFont(13.f);
    textField.textColor = DEFAULT_TEXT_COLOR;
    textField.textAlignment = NSTextAlignmentLeft;
    [textField addTarget:self
                  action:@selector(textFieldValueChanged)
        forControlEvents:UIControlEventEditingChanged];
    return textField;
}

@end
