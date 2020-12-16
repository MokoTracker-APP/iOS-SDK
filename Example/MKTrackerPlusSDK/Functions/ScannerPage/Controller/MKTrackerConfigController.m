//
//  MKTrackerConfigController.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/28.
//

#import "MKTrackerConfigController.h"

#import "MKTrackingConfigCell.h"
#import "MKContactTrackerTextCell.h"
#import "MKTrackingIntervalCell.h"
#import "MKTrackingNotifiCell.h"
#import "MKNumberOfVibCell.h"
#import "MKScannerTriggerCell.h"
#import "MKTrackingDataFormatCell.h"

#import "MKTrackingConfigCellModel.h"
#import "MKTrackerConfigDataModel.h"

#import "MKFliterOptionsController.h"
#import "MKTrackedDataController.h"

#import "MKScannerProtocol.h"

static NSString *const triggerNoteMsg = @"*The Tracker will stop tracking after static period of  0 seconds.Set to 0 seconds to turn off Tracking Trigger.";

@interface MKTrackerConfigController ()<UITableViewDelegate, UITableViewDataSource, MKScannerDelegate, MKTrackingConfigCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

/// Tracking设置部分
@property (nonatomic, strong)NSMutableArray *section0List;

/// Filtering Options、Tracking Interval
@property (nonatomic, strong)NSMutableArray *section1List;

/// Tracking Notification部分
@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)NSMutableArray *section3List;

@property (nonatomic, strong)UISwitch *trackingSwitch;

@property (nonatomic, strong)MKTrackerConfigDataModel *dataModel;

@property (nonatomic, strong)UIAlertController *currentAlert;

@end

@implementation MKTrackerConfigController

- (void)dealloc {
    NSLog(@"MKTrackerConfigController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
    [self readDatasFromDevice];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needDismissAlert)
                                                 name:@"MKSettingPageNeedDismissAlert"
                                               object:nil];
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKPopToRootViewControllerNotification" object:nil];
}

- (void)rightButtonMethod {
    MKTrackingConfigCellModel *scanWindowModel = self.section0List[0];
    MKTrackingConfigCellModel *intervalModel = self.section0List[1];
    if ([MKDeviceTypeManager shared].supportAdvTrigger) {
        MKTrackingConfigCellModel *triggerModel = self.section0List[2];
        self.dataModel.trackingTrigger = triggerModel.textValue;
    }
    self.dataModel.scanWindow = scanWindowModel.textValue;
    self.dataModel.scanInterval = intervalModel.textValue;
    
    if (self.dataModel.scanStatus) {
        //扫描设置打开了，则扫描窗口时间不能大于扫描间隔
        if ([self.dataModel.scanWindow integerValue] > [self.dataModel.scanInterval integerValue]) {
            [self.view makeToast:@"Save failed!The scan window value cannot be greater than the scan interval."
                        duration:2
                        position:CSToastPositionCenter style:nil];
            return;
        }
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.dataModel startConfigDataWithSucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:@"Saved Successfully!"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [MKTrackingConfigCell getCellHeight:(indexPath.row == 2 ? triggerNoteMsg : @"")];
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            //Tracking Interval
            return 90.f;
        }
    }
    return 44.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        MKFliterOptionsController *vc = [[MKFliterOptionsController alloc] init];
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        return;
    }
    if (indexPath.section == 3 && indexPath.row == 1) {
        MKTrackedDataController *vc = [[MKTrackedDataController alloc] init];
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return (self.trackingSwitch.isOn ? self.section0List.count : 0);
    }
    if (section == 1) {
        return self.section1List.count;
    }
    if (section == 2) {
        return self.section2List.count;
    }
    return self.section3List.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKTrackingConfigCell *cell = [MKTrackingConfigCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section0List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 1) {
        return self.section1List[indexPath.row];
    }
    if (indexPath.section == 2) {
        return self.section2List[indexPath.row];
    }
    return self.section3List[indexPath.row];
}

#pragma mark - MKScannerDelegate
- (void)advertiserParamsChanged:(id)newValue index:(NSInteger)index {
    if (index == 0) {
        //Tracking Interval
        self.dataModel.trackingInterval = (NSString *)newValue;
        return;
    }
    if (index == 1) {
        //tracking note
        self.dataModel.trackingNote = [newValue integerValue];
        [self loadSection2Datas:YES];
        return;
    }
    if (index == 3) {
        //马达震动次数
        self.dataModel.vibNubmer = [newValue integerValue];
        return;
    }
    if (index == 4) {
        //Tracking Data Format
        self.dataModel.format = [newValue integerValue];
        return;
    }
}

#pragma mark - MKTrackingConfigCellDelegate
- (void)trackerParamsValueChanged:(NSString *)value index:(NSInteger)index {
    MKTrackingConfigCellModel *dataModel = self.section0List[index];
    dataModel.textValue = value;
}

#pragma mark - note
- (void)needDismissAlert {
    if (self.currentAlert && (kAppRootController.presentedViewController == self.currentAlert)) {
        [self.currentAlert dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - event method
- (void)switchViewValueChanged {
    self.dataModel.scanStatus = self.trackingSwitch.isOn;
    [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - interface
- (void)readDatasFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.dataModel startReadDataWithSucBlock:^{
        [[MKHudManager share] hide];
        weakSelf.trackingSwitch.on = weakSelf.dataModel.scanStatus;
        [weakSelf loadSecionDatas];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark = private method
- (void)loadSecionDatas {
    [self loadSection0Datas];
    [self loadSection1Datas];
    [self loadSection2Datas:NO];
    [self loadSection3Datas];
    [self.tableView reloadData];
}

- (void)loadSection0Datas {
    [self.section0List removeAllObjects];
    MKTrackingConfigCellModel *scanWindowModel = [[MKTrackingConfigCellModel alloc] init];
    scanWindowModel.msg = @"Scan Window";
    scanWindowModel.placeHolder = @"4 ~ 16384";
    scanWindowModel.textValue = self.dataModel.scanWindow;
    scanWindowModel.detailMsg = @"x 0.625ms";
    scanWindowModel.index = 0;
    [self.section0List addObject:scanWindowModel];
    
    MKTrackingConfigCellModel *intervalModel = [[MKTrackingConfigCellModel alloc] init];
    intervalModel.msg = @"Scan Interval";
    intervalModel.placeHolder = @"4 ~ 16384";
    intervalModel.textValue = self.dataModel.scanInterval;
    intervalModel.detailMsg = @"x 0.625ms";
    intervalModel.index = 1;
    [self.section0List addObject:intervalModel];
    
    if ([MKDeviceTypeManager shared].supportAdvTrigger) {
        MKTrackingConfigCellModel *triggerModel = [[MKTrackingConfigCellModel alloc] init];
        triggerModel.msg = @"Tracking Trigger";
        triggerModel.placeHolder = @"0~65535";
        triggerModel.textValue = self.dataModel.trackingTrigger;
        triggerModel.detailMsg = @"seconds";
        triggerModel.isNoteMsgCell = YES;
        triggerModel.index = 2;
        [self.section0List addObject:triggerModel];
    }
}

- (void)loadSection1Datas {
    [self.section1List removeAllObjects];
    MKContactTrackerTextCell *optionsCell = [MKContactTrackerTextCell initCellWithTableView:self.tableView];
    MKContactTrackerTextCellModel *optionsDataModel = [[MKContactTrackerTextCellModel alloc] init];
    optionsDataModel.leftMsg = @"Filter Options";
    optionsDataModel.showRightIcon = YES;
    optionsCell.dataModel = optionsDataModel;
    [self.section1List addObject:optionsCell];
    
    MKTrackingIntervalCell *intervalCell = [self.tableView dequeueReusableCellWithIdentifier:@"MKTrackingIntervalCellIdenty"];
    if (!intervalCell) {
        intervalCell = [[MKTrackingIntervalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKTrackingIntervalCellIdenty"];
    }
    intervalCell.delegate = self;
    intervalCell.interval = self.dataModel.trackingInterval;
    [self.section1List addObject:intervalCell];
}

- (void)loadSection2Datas:(BOOL)reload {
    [self.section2List removeAllObjects];
    MKTrackingNotifiCell *noteCell = [MKTrackingNotifiCell initCellWithTableView:self.tableView];
    noteCell.trackingNote = 0;
    noteCell.delegate = self;
    noteCell.trackingNote = self.dataModel.trackingNote;
    [self.section2List addObject:noteCell];
    
    if (self.dataModel.trackingNote == 2 || self.dataModel.trackingNote == 3) {
        MKNumberOfVibCell *vibCell = [MKNumberOfVibCell initCellWithTableView:self.tableView];
        vibCell.number = self.dataModel.vibNubmer;
        vibCell.delegate = self;
        [self.section2List addObject:vibCell];
    }
    if (reload) {
        [self.tableView reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)loadSection3Datas {
    [self.section3List removeAllObjects];
    
    MKTrackingDataFormatCell *formatCell = [MKTrackingDataFormatCell initCellWithTableView:self.tableView];
    formatCell.delegate = self;
    formatCell.formatType = self.dataModel.format;
    [self.section3List addObject:formatCell];
    
    MKContactTrackerTextCell *trackerCell = [MKContactTrackerTextCell initCellWithTableView:self.tableView];
    MKContactTrackerTextCellModel *trackerDataModel = [[MKContactTrackerTextCellModel alloc] init];
    trackerDataModel.leftMsg = @"Tracked Data";
    trackerDataModel.showRightIcon = YES;
    trackerCell.dataModel = trackerDataModel;
    [self.section3List addObject:trackerCell];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x2F84D0);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"TRACKER";
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self.rightButton setImage:LOADIMAGE(@"slotSaveIcon", @"png") forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 49.f);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [self tableHeaderView];
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

- (UISwitch *)trackingSwitch {
    if (!_trackingSwitch) {
        _trackingSwitch = [[UISwitch alloc] init];
        [_trackingSwitch addTarget:self
                            action:@selector(switchViewValueChanged)
                  forControlEvents:UIControlEventValueChanged];
    }
    return _trackingSwitch;
}

- (MKTrackerConfigDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKTrackerConfigDataModel alloc] init];
    }
    return _dataModel;
}

- (UIView *)tableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 70.f)];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 25.f, 120.f, 40.f)];
    msgLabel.backgroundColor = COLOR_WHITE_MACROS;
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.font = MKFont(15.f);
    msgLabel.text = @"Tracking";
    [headerView addSubview:msgLabel];
    
    self.trackingSwitch.frame = CGRectMake(kScreenWidth - 15.f - 45.f, 25.f, 45.f, 50.f);
    [headerView addSubview:self.trackingSwitch];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15.f, 70 - CUTTING_LINE_HEIGHT, kScreenWidth - 30.f, CUTTING_LINE_HEIGHT)];
    lineView.backgroundColor = CUTTING_LINE_COLOR;
    [headerView addSubview:lineView];
    
    return headerView;
}

@end
