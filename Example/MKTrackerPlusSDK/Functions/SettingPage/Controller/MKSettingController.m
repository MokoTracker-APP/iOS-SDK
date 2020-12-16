//
//  MKSettingController.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/30.
//

#import "MKSettingController.h"

#import "MKSwitchStatusCell.h"
#import "MKSettingTextCell.h"
#import "MKTriggerSensitivityView.h"
#import "MKLowPowerNoteConfigView.h"

#import "MKSwitchStatusCellModel.h"
#import "MKSettingTextCellModel.h"
#import "MKSettingDataModel.h"

#import "MKUpdateController.h"

@interface MKSettingController ()<
UITableViewDelegate,
UITableViewDataSource,
MKSwitchStatusCellDelegate,
MKSettingTextCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)NSMutableArray *section3List;

@property (nonatomic, strong)NSMutableArray *section4List;

@property (nonatomic, strong)UITextField *passwordField;

@property (nonatomic, strong)UITextField *passwordTextField;

@property (nonatomic, strong)UITextField *confirmTextField;

@property (nonatomic, strong)MKSettingDataModel *dataModel;

/// 当前present的alert
@property (nonatomic, strong)UIAlertController *currentAlert;

@end

@implementation MKSettingController

- (void)dealloc {
    NSLog(@"MKSettingController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needDismissAlert)
                                                 name:@"MKSettingPageNeedDismissAlert"
                                               object:nil];
    [self startReadDatas];
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKPopToRootViewControllerNotification" object:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    if (section == 1) {
        return self.section1List.count;
    }
    if (section == 2) {
        return self.section2List.count;
    }
    if (section == 3) {
        return self.section3List.count;
    }
    if (section == 4) {
        return self.section4List.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self loadCellWithIndexPath:indexPath];
}

#pragma mark - MKSwitchStatusCellDelegate
- (void)needChangedCellSwitchStatus:(BOOL)isOn indexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //按键开关机
            [self configButtonOff:isOn];
            return;
        }
        if (indexPath.row == 1) {
            //可连接状态
            [self configConnectEnable:isOn];
            return;
        }
        if (indexPath.row == 2) {
            //设置连接提醒
            [self configConnectionNotificationStatus:isOn];
            return;
        }
        return;
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            //按键复位
            [self setButtonResetStatusEnable:isOn];
            return;
        }
        if (indexPath.row == 1) {
            //app关机
            [self powerOff];
            return;
        }
    }
}

#pragma mark - MKSettingTextCellDelegate
- (void)settingTextCellSelected:(NSString *)method indexPath:(NSIndexPath *)indexPath {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:NSSelectorFromString(method)]) {
        [self performSelector:NSSelectorFromString(method) withObject:nil];
    }
#pragma clang diagnostic pop
}

#pragma mark - note
- (void)needDismissAlert {
    if (self.currentAlert && (kAppRootController.presentedViewController == self.currentAlert)) {
        [self.currentAlert dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - 读取状态数据
- (void)startReadDatas {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [self.dataModel startReadDataWithSucBlock:^{
        [[MKHudManager share] hide];
        [self processSwitchStatus];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)processSwitchStatus {
    MKSwitchStatusCellModel *buttonModel = self.section1List[0];
    buttonModel.isOn = self.dataModel.buttonOffIsOn;
    buttonModel.msg = (self.dataModel.buttonOffIsOn ? @"Enable Button Off" : @"Disable Button Off");
    
    MKSwitchStatusCellModel *connectModel = self.section1List[1];
    connectModel.isOn = self.dataModel.connectable;
    connectModel.msg = (self.dataModel.connectable ? @"Connectable" : @"Non-connectable");
    
    MKSwitchStatusCellModel *connectNoteModel = self.section1List[2];
    connectNoteModel.isOn = self.dataModel.connectableNoteIsOn;
    
    MKSwitchStatusCellModel *buttonResetModel = self.section3List[0];
    buttonResetModel.isOn = self.dataModel.buttonResetIsOn;
    buttonResetModel.msg = (self.dataModel.buttonResetIsOn ? @"Enable Button Reset" : @"Disable Button Reset");
    [self.tableView reloadData];
}

#pragma mark - section0
- (void)loadSection0Datas {
    [self.section0List removeAllObjects];
    MKSettingTextCellModel *passwordModel = [[MKSettingTextCellModel alloc] init];
    passwordModel.msg = @"Change Password";
    passwordModel.tapSelector = @"configPassword";
    [self.section0List addObject:passwordModel];
}

#pragma mark - 设置密码
- (void)configPassword{
    WS(weakSelf);
    self.currentAlert = nil;
    NSString *msg = @"Note:The password should be 8 characters.";
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Change Password"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    [self.currentAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        weakSelf.passwordTextField = nil;
        weakSelf.passwordTextField = textField;
        [weakSelf.passwordTextField setPlaceholder:@"Enter new password"];
        [weakSelf.passwordTextField addTarget:weakSelf
                                       action:@selector(passwordTextFieldValueChanged:)
                             forControlEvents:UIControlEventEditingChanged];
    }];
    [self.currentAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        weakSelf.confirmTextField = nil;
        weakSelf.confirmTextField = textField;
        [weakSelf.confirmTextField setPlaceholder:@"Enter new password again"];
        [weakSelf.confirmTextField addTarget:weakSelf
                                      action:@selector(passwordTextFieldValueChanged:)
                            forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [self.currentAlert addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setPasswordToDevice];
    }];
    [self.currentAlert addAction:moreAction];
    
    [kAppRootController presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)passwordTextFieldValueChanged:(UITextField *)textField{
    NSString *tempInputString = textField.text;
    if (!ValidStr(tempInputString)) {
        textField.text = @"";
        return;
    }
    textField.text = (tempInputString.length > 8 ? [tempInputString substringToIndex:8] : tempInputString);
}

- (void)setPasswordToDevice{
    NSString *password = self.passwordTextField.text;
    NSString *confirmpassword = self.confirmTextField.text;
    if (!ValidStr(password) || !ValidStr(confirmpassword) || password.length != 8 || confirmpassword.length != 8) {
        [self.view showCentralToast:@"The password should be 8 characters.Please try again."];
        return;
    }
    if (![password isEqualToString:confirmpassword]) {
        [self.view showCentralToast:@"Password do not match! Please try again."];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    [MKTrackerInterface configPassword:password sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - section1
- (void)loadSection1Datas {
    [self.section1List removeAllObjects];
    MKSwitchStatusCellModel *buttonModel = [[MKSwitchStatusCellModel alloc] init];
    buttonModel.msg = @"Enable Button Off";
    [self.section1List addObject:buttonModel];
    
    MKSwitchStatusCellModel *connectModel = [[MKSwitchStatusCellModel alloc] init];
    connectModel.msg = @"Connectable";
    [self.section1List addObject:connectModel];
    
    MKSwitchStatusCellModel *connectNoteModel = [[MKSwitchStatusCellModel alloc] init];
    connectNoteModel.msg = @"Connection Notification";
    [self.section1List addObject:connectNoteModel];
}

#pragma mark - 设置按键关机功能
- (void)configButtonOff:(BOOL)enable {
    NSString *contentMsg = @"If you Disable Button Off function, you cannot turn off the beacon power with the button.";
    if (enable) {
        contentMsg = @"If you Enable Button Off function, you can turn off the beacon power with the button.";
    }
    self.currentAlert = nil;
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                            message:contentMsg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        MKSwitchStatusCellModel *model = weakSelf.section1List[0];
        model.isOn = !enable;
        [weakSelf.tableView reloadRow:0 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.currentAlert addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf sendButtonOffStateToDevice:enable];
    }];
    [self.currentAlert addAction:moreAction];
    
    [kAppRootController presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)sendButtonOffStateToDevice:(BOOL)isOn {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKTrackerInterface configButtonPowerStatus:isOn sucBlock:^{
        [[MKHudManager share] hide];
        MKSwitchStatusCellModel *model = self.section1List[0];
        model.isOn = isOn;
        model.msg = (isOn ? @"Enable Button Off" : @"Disable Button Off");
        [self.tableView reloadRow:0 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        MKSwitchStatusCellModel *model = self.section1List[0];
        model.isOn = !isOn;
        [self.tableView reloadRow:0 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - 设置可连接性
- (void)configConnectEnable:(BOOL)connect{
    NSString *msg = (connect ? @"Are you sure to make the device connectable?" : @"Are you sure to make the device Unconnectable?");
    self.currentAlert = nil;
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        MKSwitchStatusCellModel *model = weakSelf.section1List[1];
        model.isOn = !connect;
        [weakSelf.tableView reloadRow:1 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.currentAlert addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setConnectStatusToDevice:connect];
    }];
    [self.currentAlert addAction:moreAction];
    
    [kAppRootController presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)setConnectStatusToDevice:(BOOL)connect{
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    [MKTrackerInterface configConnectableStatus:connect sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success!"];
        MKSwitchStatusCellModel *model = self.section1List[1];
        model.isOn = connect;
        model.msg = (connect ? @"Connectable" : @"Non-connectable");
        [self.tableView reloadRow:1 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        MKSwitchStatusCellModel *model = self.section1List[1];
        model.isOn = !connect;
        [self.tableView reloadRow:1 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - 设置连接提醒状态
- (void)configConnectionNotificationStatus:(BOOL)isOn {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKTrackerInterface configConnectionNotificationStatus:isOn sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success!"];
        MKSwitchStatusCellModel *model = self.section1List[2];
        model.isOn = isOn;
        [self.tableView reloadRow:2 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        MKSwitchStatusCellModel *model = self.section1List[2];
        model.isOn = !isOn;
        [self.tableView reloadRow:2 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - section2
- (void)loadSection2Datas {
    [self.section2List removeAllObjects];
    MKSettingTextCellModel *lpnModel = [[MKSettingTextCellModel alloc] init];
    lpnModel.msg = @"Low Power Notification";
    lpnModel.tapSelector = @"configLowPowerNote";
    [self.section2List addObject:lpnModel];
    
    MKSettingTextCellModel *triggerSenModel = [[MKSettingTextCellModel alloc] init];
    triggerSenModel.msg = @"Trigger Sensitivity";
    triggerSenModel.tapSelector = @"triggerSensitivityMethod";
    [self.section2List addObject:triggerSenModel]; 
}

#pragma mark - 设置低电量报警
- (void)configLowPowerNote {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKTrackerInterface readLowBatteryReminderRulesWithSucBlock:^(id  _Nonnull returnData) {
        [[MKHudManager share] hide];
        [self showLowPowerNoteConfigView:[returnData[@"result"][@"lTwentyInterval"] integerValue] tenValue:[returnData[@"result"][@"lTenInterval"] integerValue] fiveValue:[returnData[@"result"][@"lFiveInterval"] integerValue]];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];

}

- (void)showLowPowerNoteConfigView:(NSInteger)twentyValue
                          tenValue:(NSInteger)tenValue
                         fiveValue:(NSInteger)fiveValue {
    MKLowPowerNoteConfigView *view = [[MKLowPowerNoteConfigView alloc] init];
    [view showViewWithValue:twentyValue tenValue:tenValue fiveValue:fiveValue completeBlock:^(NSInteger twentyResultValue, NSInteger tenResultValue, NSInteger fiveResultValue) {
        [self sendLowPowerValueToDevice:twentyResultValue tenValue:tenResultValue fiveValue:fiveResultValue];
    }];
}

- (void)sendLowPowerValueToDevice:(NSInteger)twentyValue
                         tenValue:(NSInteger)tenValue
                        fiveValue:(NSInteger)fiveValue {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKTrackerInterface configLowBatteryReminderRules:twentyValue lowTenInterval:tenValue lowFiveInterval:fiveValue sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 设置灵敏度
- (void)triggerSensitivityMethod {
    [[MKHudManager share] showHUDWithTitle:@"Reading..."
                                    inView:self.view
                             isPenetration:NO];
    [MKTrackerInterface readMovementSensitivityWithSucBlock:^(id  _Nonnull returnData) {
        [[MKHudManager share] hide];
        NSInteger triggerSen = [returnData[@"result"][@"sensitivity"] integerValue];
        [self showViewWithTriggerSensitivityValue:(triggerSen - 7)];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)showViewWithTriggerSensitivityValue:(NSInteger)value {
    WS(weakSelf);
    MKTriggerSensitivityView *view = [[MKTriggerSensitivityView alloc] init];
    [view showViewWithValue:value completeBlock:^(NSInteger resultValue) {
        __strong typeof(self) sself = weakSelf;
        [sself configTriggerSensitivity:resultValue];
    }];
}

- (void)configTriggerSensitivity:(NSInteger)sensitivity {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKTrackerInterface configMovementSensitivity:(sensitivity + 7) sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success!"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - section3
- (void)loadSection3Datas {
    [self.section3List removeAllObjects];
    MKSwitchStatusCellModel *buttonResetModel = [[MKSwitchStatusCellModel alloc] init];
    buttonResetModel.msg = @"Disable Button Reset";
    [self.section3List addObject:buttonResetModel];
    
    MKSwitchStatusCellModel *powerOffModel = [[MKSwitchStatusCellModel alloc] init];
    powerOffModel.msg = @"APP Power Off";
    [self.section3List addObject:powerOffModel];
}

#pragma mark - 设置按键复位状态
- (void)setButtonResetStatusEnable:(BOOL)isOn{
    NSString *msg = (isOn ? @"If you Enable Button Reset function, you can Reset the beacon power with the button." : @"If you Disable Button Reset function, you cannot Reset the beacon power with the button.");
    self.currentAlert = nil;
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        MKSwitchStatusCellModel *model = weakSelf.section3List[0];
        model.isOn = !isOn;
        [weakSelf.tableView reloadRow:0 inSection:3 withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.currentAlert addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setButtonResetStatusToDevice:isOn];
    }];
    [self.currentAlert addAction:moreAction];
    
    [kAppRootController presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)setButtonResetStatusToDevice:(BOOL)isOn{
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    WS(weakSelf);
    [MKTrackerInterface configButtonResetStatus:isOn sucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:@"Success!"];
        MKSwitchStatusCellModel *model = weakSelf.section3List[0];
        model.isOn = isOn;
        model.msg = (isOn ? @"Enable Button Reset" : @"Disable Button Reset");
        [weakSelf.tableView reloadRow:0 inSection:3 withRowAnimation:UITableViewRowAnimationNone];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
        MKSwitchStatusCellModel *model = weakSelf.section3List[0];
        model.isOn = !isOn;
        [weakSelf.tableView reloadRow:0 inSection:3 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - 开关机
- (void)powerOff{
    NSString *msg = @"Are you sure to turn off the device? Please make sure the device has a button to turn on!";
    self.currentAlert = nil;
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        MKSwitchStatusCellModel *model = weakSelf.section3List[1];
        model.isOn = NO;
        [weakSelf.tableView reloadRow:1 inSection:3 withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.currentAlert addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf commandPowerOff];
    }];
    [self.currentAlert addAction:moreAction];
    
    [kAppRootController presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)commandPowerOff{
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    WS(weakSelf);
    [MKTrackerInterface powerOffDeviceWithSucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
        MKSwitchStatusCellModel *model = weakSelf.section3List[1];
        model.isOn = YES;
        [weakSelf.tableView reloadRow:1 inSection:3 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - section4
- (void)loadSection4Datas {
    [self.section4List removeAllObjects];
    MKSettingTextCellModel *resetModel = [[MKSettingTextCellModel alloc] init];
    resetModel.msg = @"Reset";
    resetModel.tapSelector = @"factoryReset";
    [self.section4List addObject:resetModel];
    
    MKSettingTextCellModel *dfuModel = [[MKSettingTextCellModel alloc] init];
    dfuModel.msg = @"OTA DFU";
    dfuModel.tapSelector = @"pushDfuPage";
    [self.section4List addObject:dfuModel];
}

#pragma mark - 恢复出厂设置

- (void)factoryReset{
    NSString *msg = @"Please enter the password to reset the device.";
    self.currentAlert = nil;
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Factory Reset"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    [self.currentAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        weakSelf.passwordField = nil;
        weakSelf.passwordField = textField;
        weakSelf.passwordField.placeholder = @"Enter the password.";
        [textField addTarget:weakSelf action:@selector(passwordInput) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [self.currentAlert addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf sendResetCommandToDevice];
    }];
    [self.currentAlert addAction:moreAction];
    
    [self presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)passwordInput {
    NSString *tempInputString = self.passwordField.text;
    if (!ValidStr(tempInputString)) {
        self.passwordField.text = @"";
        return;
    }
    self.passwordField.text = (tempInputString.length > 8 ? [tempInputString substringToIndex:8] : tempInputString);
}

- (void)sendResetCommandToDevice{
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    WS(weakSelf);
    [MKTrackerInterface factoryDataResetWithPassword:self.passwordField.text sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - push dfu
- (void)pushDfuPage {
    MKUpdateController *vc = [[MKUpdateController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - private method
- (void)loadSectionDatas {
    [self loadSection0Datas];
    [self loadSection1Datas];
    [self loadSection2Datas];
    [self loadSection3Datas];
    [self loadSection4Datas];
    [self.tableView reloadData];
}

- (UITableViewCell *)loadCellWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKSettingTextCell *cell = [MKSettingTextCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section0List[indexPath.row];
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell;
    }
    if (indexPath.section == 1) {
        MKSwitchStatusCell *cell = [MKSwitchStatusCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section1List[indexPath.row];
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell;
    }
    if (indexPath.section == 2) {
        MKSettingTextCell *cell = [MKSettingTextCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section2List[indexPath.row];
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell;
    }
    if (indexPath.section == 3) {
        MKSwitchStatusCell *cell = [MKSwitchStatusCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section3List[indexPath.row];
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell;
    }
    MKSettingTextCell *cell = [MKSettingTextCell initCellWithTableView:self.tableView];
    cell.dataModel = self.section4List[indexPath.row];
    cell.delegate = self;
    cell.indexPath = indexPath;
    return cell;
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x2F84D0);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"SETTINGS";
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self.rightButton setHidden:YES];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)section0List {
    if (!_section0List) {
        _section0List = [NSMutableArray array];
    }
    return _section0List;
}

- (NSMutableArray *)section1List {
    if (!_section1List) {
        _section1List = [NSMutableArray array];
    }
    return _section1List;
}

- (NSMutableArray *)section2List {
    if (!_section2List) {
        _section2List = [NSMutableArray array];
    }
    return _section2List;
}

- (NSMutableArray *)section3List {
    if (!_section3List) {
        _section3List = [NSMutableArray array];
    }
    return _section3List;
}

- (NSMutableArray *)section4List {
    if (!_section4List) {
        _section4List = [NSMutableArray array];
    }
    return _section4List;
}

- (MKSettingDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKSettingDataModel alloc] init];
    }
    return _dataModel;
}

@end
