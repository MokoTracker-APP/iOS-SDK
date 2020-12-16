//
//  MKLowPowerNoteConfigView.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/30.
//

#import "MKLowPowerNoteConfigView.h"

#import "MKLowPowerNoteSlider.h"

static NSString *const titleMsg = @"Low Power Notification";
static NSString *const alertMsg = @"LED reminder interval for low power notification.";

static CGFloat const sliderHeight = 20.f;
static CGFloat const buttonHeight = 55.f;
static CGFloat const offset_Y = 15.f;
static CGFloat const offset_X = 15.f;

@interface MKLowPowerNoteConfigView ()

@property (nonatomic, strong)UIView *alertView;

@property (nonatomic, strong)UILabel *titleMsgLabel;

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *batteryMsgLabel1;

@property (nonatomic, strong)UILabel *batteryValueLabel1;

@property (nonatomic, strong)MKLowPowerNoteSlider *batterySlider1;

@property (nonatomic, strong)UILabel *batteryMsgLabel2;

@property (nonatomic, strong)UILabel *batteryValueLabel2;

@property (nonatomic, strong)MKLowPowerNoteSlider *batterySlider2;

@property (nonatomic, strong)UILabel *batteryMsgLabel3;

@property (nonatomic, strong)UILabel *batteryValueLabel3;

@property (nonatomic, strong)MKLowPowerNoteSlider *batterySlider3;

@property (nonatomic, strong)UIButton *cancelButton;

@property (nonatomic, strong)UIButton *confirmButton;

@property (nonatomic, strong)UIView *lineView1;

@property (nonatomic, strong)UIView *lineView2;

@property (nonatomic, copy)void (^valueConfirmBlock)(NSInteger batteryValue1,NSInteger batteryValue2,NSInteger batteryValue3);

@end

@implementation MKLowPowerNoteConfigView

- (void)dealloc {
    NSLog(@"MKLowPowerNoteConfigView销毁");
}

- (instancetype)init {
    if (self = [super init]) {
        self.frame = kAppWindow.bounds;
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
        [self addSubview:self.alertView];
        [self.alertView addSubview:self.titleMsgLabel];
        [self.alertView addSubview:self.msgLabel];
        [self.alertView addSubview:self.batteryMsgLabel1];
        [self.alertView addSubview:self.batteryValueLabel1];
        [self.alertView addSubview:self.batterySlider1];
        [self.alertView addSubview:self.batteryMsgLabel2];
        [self.alertView addSubview:self.batteryValueLabel2];
        [self.alertView addSubview:self.batterySlider2];
        [self.alertView addSubview:self.batteryMsgLabel3];
        [self.alertView addSubview:self.batteryValueLabel3];
        [self.alertView addSubview:self.batterySlider3];
        [self.alertView addSubview:self.lineView1];
        [self.alertView addSubview:self.lineView2];
        [self.alertView addSubview:self.cancelButton];
        [self.alertView addSubview:self.confirmButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize titleSize = [NSString sizeWithText:self.titleMsgLabel.text
                                      andFont:self.titleMsgLabel.font
                                   andMaxSize:CGSizeMake(kScreenWidth - 4 * offset_X, MAXFLOAT)];
    CGSize msgSize = [NSString sizeWithText:self.msgLabel.text
                                    andFont:self.msgLabel.font
                                 andMaxSize:CGSizeMake(kScreenWidth - 4 * offset_X, MAXFLOAT)];
    CGFloat alertHeight = 9 * offset_Y + titleSize.height + msgSize.height + 3 * sliderHeight + 3 * MKFont(13.f).lineHeight + CUTTING_LINE_HEIGHT + buttonHeight;
    [self.alertView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(alertHeight);
    }];
    [self.titleMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(offset_Y);
        make.height.mas_equalTo(titleSize.height);
    }];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.titleMsgLabel.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(msgSize.height);
    }];
    [self.batteryMsgLabel1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.batterySlider1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(self.batteryValueLabel1.mas_left).mas_offset(-offset_X);
        make.top.mas_equalTo(self.batteryMsgLabel1.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(sliderHeight);
    }];
    [self.batteryValueLabel1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-offset_X);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.batterySlider1.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    
    [self.batteryMsgLabel2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.batterySlider1.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.batterySlider2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(self.batteryValueLabel2.mas_left).mas_offset(-offset_X);
        make.top.mas_equalTo(self.batteryMsgLabel2.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(sliderHeight);
    }];
    [self.batteryValueLabel2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-offset_X);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.batterySlider2.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    
    [self.batteryMsgLabel3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.batterySlider2.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.batterySlider3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(self.batteryValueLabel3.mas_left).mas_offset(-offset_X);
        make.top.mas_equalTo(self.batteryMsgLabel3.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(sliderHeight);
    }];
    [self.batteryValueLabel3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-offset_X);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.batterySlider3.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    
    [self.lineView1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.batterySlider3.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
    }];
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(self.lineView2.mas_left);
        make.top.mas_equalTo(self.lineView1.mas_bottom);
        make.height.mas_equalTo(buttonHeight);
    }];
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(self.lineView2.mas_right);
        make.top.mas_equalTo(self.lineView1.mas_bottom);
        make.height.mas_equalTo(buttonHeight);
    }];
    [self.lineView2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.alertView.mas_centerX);
        make.width.mas_equalTo(CUTTING_LINE_HEIGHT);
        make.top.mas_equalTo(self.lineView1.mas_bottom);
        make.height.mas_equalTo(buttonHeight);
    }];
}

#pragma mark - event Method

/**
 取消选择
 */
- (void)cancelButtonPressed {
    [self dismiss];
}

/**
 确认选择
 */
- (void)confirmButtonPressed {
    if (self.valueConfirmBlock) {
        NSString *value1 = [NSString stringWithFormat:@"%.f",self.batterySlider1.value];
        NSString *value2 = [NSString stringWithFormat:@"%.f",self.batterySlider2.value];
        NSString *value3 = [NSString stringWithFormat:@"%.f",self.batterySlider3.value];
        self.valueConfirmBlock([value1 integerValue],[value2 integerValue],[value3 integerValue]);
    }
    [self dismiss];
}

- (void)dismiss {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)sliderValueChanged:(MKLowPowerNoteSlider *)slider {
    NSString *valueMsg = [NSString stringWithFormat:@"%.f",slider.value];
    if (slider == self.batterySlider1) {
        self.batteryValueLabel1.text = valueMsg;
        return;
    }
    if (slider == self.batterySlider2) {
        self.batteryValueLabel2.text = valueMsg;
        return;
    }
    if (slider == self.batterySlider3) {
        self.batteryValueLabel3.text = valueMsg;
        return;
    }
}

#pragma mark - public method
- (void)showViewWithValue:(NSInteger)twentyValue
                 tenValue:(NSInteger)tenValue
                fiveValue:(NSInteger)fiveValue
            completeBlock:(void (^)(NSInteger twentyResultValue,NSInteger tenResultValue,NSInteger fiveResultValue))block {
    [kAppWindow addSubview:self];
    self.valueConfirmBlock = block;
    self.batterySlider1.value = twentyValue;
    self.batterySlider2.value = tenValue;
    self.batterySlider3.value = fiveValue;
    self.batteryValueLabel1.text = [NSString stringWithFormat:@"%.f",self.batterySlider1.value];
    self.batteryValueLabel2.text = [NSString stringWithFormat:@"%.f",self.batterySlider2.value];
    self.batteryValueLabel3.text = [NSString stringWithFormat:@"%.f",self.batterySlider3.value];
}

#pragma mark - private method

#pragma mark - getter
- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        _alertView.backgroundColor = RGBCOLOR(239, 239, 239);
        _alertView.layer.masksToBounds = YES;
        _alertView.layer.borderColor = RGBCOLOR(167, 166, 167).CGColor;
        _alertView.layer.borderWidth = 0.5f;
        _alertView.layer.cornerRadius = 8.f;
    }
    return _alertView;
}

- (UILabel *)titleMsgLabel {
    if (!_titleMsgLabel) {
        _titleMsgLabel = [[UILabel alloc] init];
        _titleMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _titleMsgLabel.textAlignment = NSTextAlignmentCenter;
        _titleMsgLabel.font = MKFont(17.f);
        _titleMsgLabel.numberOfLines = 0;
        _titleMsgLabel.text = titleMsg;
    }
    return _titleMsgLabel;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = MKFont(14.f);
        _msgLabel.numberOfLines = 0;
        _msgLabel.text = alertMsg;
    }
    return _msgLabel;
}

- (UILabel *)batteryMsgLabel1 {
    if (!_batteryMsgLabel1) {
        _batteryMsgLabel1 = [self currentMsgLabel:@"Battery power less than 20%"];
    }
    return _batteryMsgLabel1;
}

- (MKLowPowerNoteSlider *)batterySlider1 {
    if (!_batterySlider1) {
        _batterySlider1 = [[MKLowPowerNoteSlider alloc] init];
        _batterySlider1.maximumValue = 120;
        _batterySlider1.minimumValue = 0;
        _batterySlider1.value = 0.f;
        [_batterySlider1 addTarget:self
                            action:@selector(sliderValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
    }
    return _batterySlider1;
}

- (UILabel *)batteryValueLabel1 {
    if (!_batteryValueLabel1) {
        _batteryValueLabel1 = [self currentMsgLabel:@"0 s"];
    }
    return _batteryValueLabel1;
}

- (UILabel *)batteryMsgLabel2 {
    if (!_batteryMsgLabel2) {
        _batteryMsgLabel2 = [self currentMsgLabel:@"Battery power less than 10%"];
    }
    return _batteryMsgLabel2;
}

- (MKLowPowerNoteSlider *)batterySlider2 {
    if (!_batterySlider2) {
        _batterySlider2 = [[MKLowPowerNoteSlider alloc] init];
        _batterySlider2.maximumValue = 120;
        _batterySlider2.minimumValue = 0;
        _batterySlider2.value = 0.f;
        [_batterySlider2 addTarget:self
                            action:@selector(sliderValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
    }
    return _batterySlider2;
}

- (UILabel *)batteryValueLabel2 {
    if (!_batteryValueLabel2) {
        _batteryValueLabel2 = [self currentMsgLabel:@"0 s"];
    }
    return _batteryValueLabel2;
}

- (UILabel *)batteryMsgLabel3 {
    if (!_batteryMsgLabel3) {
        _batteryMsgLabel3 = [self currentMsgLabel:@"Battery power less than 5%"];
    }
    return _batteryMsgLabel3;
}

- (MKLowPowerNoteSlider *)batterySlider3 {
    if (!_batterySlider3) {
        _batterySlider3 = [[MKLowPowerNoteSlider alloc] init];
        _batterySlider3.maximumValue = 120;
        _batterySlider3.minimumValue = 0;
        _batterySlider3.value = 0.f;
        [_batterySlider3 addTarget:self
                            action:@selector(sliderValueChanged:)
                  forControlEvents:UIControlEventValueChanged];
    }
    return _batterySlider3;
}

- (UILabel *)batteryValueLabel3 {
    if (!_batteryValueLabel3) {
        _batteryValueLabel3 = [self currentMsgLabel:@"0 s"];
    }
    return _batteryValueLabel3;
}

- (UIView *)lineView1 {
    if (!_lineView1) {
        _lineView1 = [[UIView alloc] init];
        _lineView1.backgroundColor = RGBCOLOR(167, 166, 167);
    }
    return _lineView1;
}

- (UIView *)lineView2 {
    if (!_lineView2) {
        _lineView2 = [[UIView alloc] init];
        _lineView2.backgroundColor = RGBCOLOR(167, 166, 167);
    }
    return _lineView2;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:UIColorFromRGB(0x2F84D0) forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:MKFont(15.f)];
        [_cancelButton addTapAction:self selector:@selector(cancelButtonPressed)];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"OK" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorFromRGB(0x2F84D0) forState:UIControlStateNormal];
        [_confirmButton.titleLabel setFont:MKFont(15.f)];
        [_confirmButton addTapAction:self selector:@selector(confirmButtonPressed)];
    }
    return _confirmButton;
}

- (UILabel *)currentMsgLabel:(NSString *)msg {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = RGBCOLOR(171, 174, 181);
    label.textAlignment = NSTextAlignmentLeft;
    label.font = MKFont(13.f);
    label.text = msg;
    return label;
}

@end
