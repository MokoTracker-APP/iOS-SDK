//
//  MKTrackingConfigCell.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/28.
//

#import "MKTrackingConfigCell.h"

#import "MKTrackingConfigCellModel.h"

@interface MKTrackingConfigCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UILabel *detailMsgLabel;

@property (nonatomic, strong)UILabel *noteLabel;

@end

@implementation MKTrackingConfigCell

+ (MKTrackingConfigCell *)initCellWithTableView:(UITableView *)tableView {
    MKTrackingConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKTrackingConfigCellIdenty"];
    if (!cell) {
        cell = [[MKTrackingConfigCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKTrackingConfigCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.detailMsgLabel];
        [self.contentView addSubview:self.noteLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(120.f);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(15.f);
        make.width.mas_equalTo(80.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(25.f);
    }];
    [self.detailMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.textField.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
    if (!self.dataModel.isNoteMsgCell) {
        return;
    }
    CGSize size = [NSString sizeWithText:self.noteLabel.text
                                 andFont:self.noteLabel.font
                              andMaxSize:CGSizeMake(kScreenWidth - 30.f, MAXFLOAT)];
    [self.noteLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.textField.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(size.height);
    }];
}

#pragma mark - event method
- (void)textFieldValueChanged {
    if ([self.delegate respondsToSelector:@selector(trackerParamsValueChanged:index:)]) {
        [self.delegate trackerParamsValueChanged:self.textField.text index:self.dataModel.index];
    }
    if (!self.dataModel.isNoteMsgCell) {
        return;
    }
    self.noteLabel.text = [NSString stringWithFormat:@"*The Tracker will stop tracking after static period of %@ seconds.Set to 0 seconds to turn off Tracking Trigger.",self.textField.text];
}

#pragma mark - public method
+ (CGFloat)getCellHeight:(NSString *)noteMsg {
    if (ValidStr(noteMsg)) {
        CGSize size = [NSString sizeWithText:noteMsg
                                     andFont:MKFont(11.f)
                                  andMaxSize:CGSizeMake(kScreenWidth - 30.f, MAXFLOAT)];
        return 35.f + size.height + 10.f;
    }
    return 35.f;
}

#pragma mark - setter
- (void)setDataModel:(MKTrackingConfigCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.textField.placeholder = SafeStr(_dataModel.placeHolder);
    self.textField.text = SafeStr(_dataModel.textValue);
    self.detailMsgLabel.text = SafeStr(_dataModel.detailMsg);
    self.noteLabel.hidden = !_dataModel.isNoteMsgCell;
    if (_dataModel.isNoteMsgCell) {
        self.noteLabel.text = [NSString stringWithFormat:@"*The Tracker will stop tracking after static period of %@ seconds.Set to 0 seconds to turn off Tracking Trigger.",_dataModel.textValue];
    }
    [self setNeedsLayout];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(13.f);
    }
    return _msgLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithTextFieldType:realNumberOnly];
        _textField.maxLength = 5;
        _textField.font = MKFont(13.f);
        _textField.textColor = DEFAULT_TEXT_COLOR;
        _textField.textAlignment = NSTextAlignmentLeft;
        
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderColor = DEFAULT_TEXT_COLOR.CGColor;
        _textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textField.layer.cornerRadius = 3.f;
        
        [_textField addTarget:self
                       action:@selector(textFieldValueChanged)
             forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (UILabel *)detailMsgLabel {
    if (!_detailMsgLabel) {
        _detailMsgLabel = [[UILabel alloc] init];
        _detailMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _detailMsgLabel.font = MKFont(12.f);
        _detailMsgLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _detailMsgLabel;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] init];
        _noteLabel.textColor = RGBCOLOR(193, 88, 38);
        _noteLabel.font = MKFont(11.f);
        _noteLabel.textAlignment  =NSTextAlignmentLeft;
        _noteLabel.numberOfLines = 0;
    }
    return _noteLabel;
}

@end
