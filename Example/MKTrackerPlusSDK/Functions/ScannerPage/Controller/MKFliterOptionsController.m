//
//  MKFliterOptionsController.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/29.
//

#import "MKFliterOptionsController.h"

#import "MKFliterRssiValueCell.h"
#import "MKAdvDataFliterCell.h"
#import "MKFilterMajorMinorCell.h"

#import "MKFilterOptionsModel.h"
#import "MKAdvDataFliterCellModel.h"
#import "MKFilterMajorMinorCellModel.h"

#import "MKSlider.h"

static NSInteger const statusOnHeight = 130.f;
static NSInteger const statusOffHeight = 44.f;

@interface MKFliterOptionsController ()<UITableViewDelegate,
UITableViewDataSource,
MKAdvDataFliterCellDelegate,
MKFliterRssiValueCellDelegate,
MKFilterMajorMinorCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)NSMutableArray *section3List;

@property (nonatomic, strong)MKFilterOptionsModel *optionsModel;

@property (nonatomic, strong)UISwitch *footerSwitch;

@end

@implementation MKFliterOptionsController

- (void)dealloc {
    NSLog(@"MKFliterOptionsController销毁");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self startReadDataFromDevice];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.optionsModel startConfigDataWithSucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:@"Saved Successfully!"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self loadCellHeightWithIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self loadCellWithIndexPath:indexPath];
}

#pragma mark - MKAdvDataFliterCellDelegate
- (void)advDataFliterCellSwitchStatusChanged:(BOOL)isOn index:(NSInteger)index {
    if (index == 0) {
        //mac address
        self.optionsModel.macIson = isOn;
    }else if (index == 1) {
        //adv name
        self.optionsModel.advNameIson = isOn;
    }else if (index == 2) {
        //uuid
        self.optionsModel.uuidIson = isOn;
    }else if (index == 3) {
        //raw data
        self.optionsModel.rawDataIson = isOn;
    }
    if (index < 3) {
        MKAdvDataFliterCellModel *dataModel = self.section1List[index];
        dataModel.isOn = isOn;
        [self.tableView reloadRow:index inSection:1 withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    MKAdvDataFliterCellModel *dataModel = self.section3List[0];
    dataModel.isOn = isOn;
    [self.tableView reloadRow:0 inSection:3 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)advDataFilterCellWhiteListState:(BOOL)isOpen index:(NSInteger)index {
    if (index == 0) {
        //mac address
        self.optionsModel.macWhiteListIson = isOpen;
    }else if (index == 1) {
        //adv name
        self.optionsModel.advNameWhiteListIson = isOpen;
    }else if (index == 2) {
        //uuid
        self.optionsModel.uuidWhiteListIson = isOpen;
    }else if (index == 3) {
        //raw data
        self.optionsModel.rawDataWhiteListIson = isOpen;
    }
    if (index < 3) {
        MKAdvDataFliterCellModel *dataModel = self.section1List[index];
        dataModel.whiteListIsOn = isOpen;
        return;
    }
    MKAdvDataFliterCellModel *dataModel = self.section3List[0];
    dataModel.whiteListIsOn = isOpen;
}

- (void)advertiserFilterContent:(NSString *)newValue index:(NSInteger)index {
    if (index == 0) {
        //mac address
        self.optionsModel.macValue = newValue;
    }else if (index == 1) {
        //adv name
        self.optionsModel.advNameValue = newValue;
    }else if (index == 2) {
        //uuid
        self.optionsModel.uuidValue = newValue;
    }else if (index == 3) {
        //raw data
        self.optionsModel.rawDataValue = newValue;
    }
    if (index < 3) {
        MKAdvDataFliterCellModel *dataModel = self.section1List[index];
        dataModel.textFieldValue = newValue;
    }else {
        MKAdvDataFliterCellModel *dataModel = self.section3List[0];
        dataModel.textFieldValue = newValue;
    }
}

#pragma mark - MKFliterRssiValueCellDelegate
- (void)mk_fliterRssiValueChanged:(NSInteger)rssi {
    self.optionsModel.rssiValue = rssi;
}

#pragma mark - MKFilterMajorMinorCellDelegate
- (void)majorMinorFliterSwitchStatusChanged:(BOOL)isOn index:(NSInteger)index {
    if (index == 0) {
        //Major
        self.optionsModel.majorIson = isOn;
    }else if (index == 1) {
        //Minor
        self.optionsModel.minorIson = isOn;
    }
    MKFilterMajorMinorCellModel *dataModel = self.section2List[index];
    dataModel.isOn = isOn;
    [self.tableView reloadRow:index inSection:2 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)majorMinorFliterWhiteListState:(BOOL)isOpen index:(NSInteger)index {
    if (index == 0) {
        //Major
        self.optionsModel.majorWhiteListIson = isOpen;
    }else if (index == 1) {
        //Minor
        self.optionsModel.minorWhiteListIson = isOpen;
    }
    MKFilterMajorMinorCellModel *dataModel = self.section2List[index];
    dataModel.whiteListIsOn = isOpen;
}

- (void)filterMaxValueContentChanged:(NSString *)newValue index:(NSInteger)index {
    if (index == 0) {
        self.optionsModel.majorMaxValue = newValue;
    }else if (index == 1) {
        self.optionsModel.minorMaxValue = newValue;
    }
    MKFilterMajorMinorCellModel * dataModel = self.section2List[index];
    dataModel.maxValue = newValue;
}

- (void)filterMinValueContentChanged:(NSString *)newValue index:(NSInteger)index {
    if (index == 0) {
        self.optionsModel.majorMinValue = newValue;
    }else if (index == 1) {
        self.optionsModel.minorMinValue = newValue;
    }
    MKFilterMajorMinorCellModel * dataModel = self.section2List[index];
    dataModel.minValue = newValue;
}

#pragma mark -

#pragma mark - event method
- (void)filterAdvStateValueChanged {
    self.optionsModel.advDataFilterIson = self.footerSwitch.isOn;
}

#pragma mark - private method
- (CGFloat)loadCellHeightWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 80.f;
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return (self.optionsModel.macIson ? statusOnHeight : statusOffHeight);
        }
        if (indexPath.row == 1) {
            return (self.optionsModel.advNameIson ? statusOnHeight : statusOffHeight);
        }
        if (indexPath.row == 2) {
            return (self.optionsModel.uuidIson ? statusOnHeight : statusOffHeight);
        }
        return 0.f;
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            return (self.optionsModel.majorIson ? statusOnHeight : statusOffHeight);
        }
        if (indexPath.row == 1) {
            return (self.optionsModel.minorIson ? statusOnHeight : statusOffHeight);
        }
        return 0.f;
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            return (self.optionsModel.rawDataIson ? statusOnHeight : statusOffHeight);
        }
    }
    return 0.f;
}

- (void)startReadDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.optionsModel startReadDataWithSucBlock:^{
        weakSelf.footerSwitch.on = weakSelf.optionsModel.advDataFilterIson;
        [weakSelf loadFilterOptionDatas];
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (UITableViewCell *)loadCellWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKFliterRssiValueCell *cell = [MKFliterRssiValueCell initCellWithTableView:self.tableView];
        cell.delegate = self;
        cell.rssi = self.optionsModel.rssiValue;
        return cell;
    }
    if (indexPath.section == 1) {
        MKAdvDataFliterCell *cell = [MKAdvDataFliterCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section1List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 2) {
        MKFilterMajorMinorCell *cell = [MKFilterMajorMinorCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section2List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    MKAdvDataFliterCell *cell = [MKAdvDataFliterCell initCellWithTableView:self.tableView];
    cell.dataModel = self.section3List[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)loadFilterOptionDatas {
    MKAdvDataFliterCellModel *macModel = [[MKAdvDataFliterCellModel alloc] init];
    macModel.msg = @"MAC Address Filtering";
    macModel.textPlaceholder = @"1 ~ 6 Bytes";
    macModel.textFieldType = hexCharOnly;
    macModel.maxLength = 12;
    macModel.index = 0;
    macModel.textFieldValue = self.optionsModel.macValue;
    macModel.isOn = self.optionsModel.macIson;
    macModel.whiteListIsOn = self.optionsModel.macWhiteListIson;
    [self.section1List addObject:macModel];
    
    MKAdvDataFliterCellModel *advNameModel = [[MKAdvDataFliterCellModel alloc] init];
    advNameModel.msg = @"BLE Name Filtering";
    advNameModel.textPlaceholder = @"1 ~ 10 Characters";
    advNameModel.textFieldType = normalInput;
    advNameModel.maxLength = 10;
    advNameModel.index = 1;
    advNameModel.textFieldValue = self.optionsModel.advNameValue;
    advNameModel.isOn = self.optionsModel.advNameIson;
    advNameModel.whiteListIsOn = self.optionsModel.advNameWhiteListIson;
    [self.section1List addObject:advNameModel];
    
    MKAdvDataFliterCellModel *uuidModel = [[MKAdvDataFliterCellModel alloc] init];
    uuidModel.msg = @"iBeacon UUID Filtering";
    uuidModel.textPlaceholder = @"16 Bytes";
    uuidModel.textFieldType = uuidMode;
    uuidModel.maxLength = 36;
    uuidModel.index = 2;
    uuidModel.textFieldValue = self.optionsModel.uuidValue;
    uuidModel.isOn = self.optionsModel.uuidIson;
    uuidModel.whiteListIsOn = self.optionsModel.uuidWhiteListIson;
    [self.section1List addObject:uuidModel];
    
    MKFilterMajorMinorCellModel *majorModel = [[MKFilterMajorMinorCellModel alloc] init];
    majorModel.msg = @"iBeacon Major Filtering";
    majorModel.minValue = self.optionsModel.majorMinValue;
    majorModel.maxValue = self.optionsModel.majorMaxValue;
    majorModel.index = 0;
    majorModel.isOn = self.optionsModel.majorIson;
    majorModel.whiteListIsOn = self.optionsModel.majorWhiteListIson;
    [self.section2List addObject:majorModel];
    
    MKFilterMajorMinorCellModel *minorModel = [[MKFilterMajorMinorCellModel alloc] init];
    minorModel.msg = @"iBeacon Minor Filtering";
    minorModel.minValue = self.optionsModel.minorMinValue;
    minorModel.maxValue = self.optionsModel.minorMaxValue;
    minorModel.index = 1;
    minorModel.isOn = self.optionsModel.minorIson;
    minorModel.whiteListIsOn = self.optionsModel.minorWhiteListIson;
    [self.section2List addObject:minorModel];
    
    MKAdvDataFliterCellModel *rawDataModel = [[MKAdvDataFliterCellModel alloc] init];
    rawDataModel.msg = @"BLE Advertising Data Filtering";
    rawDataModel.textPlaceholder = @"1 ~ 29 Bytes";
    rawDataModel.textFieldType = hexCharOnly;
    rawDataModel.maxLength = 58;
    rawDataModel.index = 3;
    rawDataModel.textFieldValue = self.optionsModel.rawDataValue;
    rawDataModel.isOn = self.optionsModel.rawDataIson;
    rawDataModel.whiteListIsOn = self.optionsModel.rawDataWhiteListIson;
    [self.section3List addObject:rawDataModel];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x2F84D0);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"FILTERING OPTIONS";
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self.rightButton setImage:LOADIMAGE(@"slotSaveIcon", @"png") forState:UIControlStateNormal];
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
        _tableView.tableFooterView = [self tableFooterView];
    }
    return _tableView;
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

- (MKFilterOptionsModel *)optionsModel {
    if (!_optionsModel) {
        _optionsModel = [[MKFilterOptionsModel alloc] init];
    }
    return _optionsModel;
}

- (UISwitch *)footerSwitch {
    if (!_footerSwitch) {
        _footerSwitch = [[UISwitch alloc] init];
        [_footerSwitch addTarget:self
                          action:@selector(filterAdvStateValueChanged)
                forControlEvents:UIControlEventValueChanged];
    }
    return _footerSwitch;
}

- (UIView *)tableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 110.f)];
    footerView.backgroundColor = COLOR_WHITE_MACROS;
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 5.f, 150.f, 45.f)];
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.font = MKFont(15.f);
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.text = @"All BLE Devices";
    [footerView addSubview:msgLabel];
    
    self.footerSwitch.frame = CGRectMake(kScreenWidth - 15.f - 50.f, 5.f, 50.f, 45.f);
    [footerView addSubview:self.footerSwitch];
    
    NSString *noteMsg = @"*Turn on All BLE Devices, the Tracker will store all types of BLE advertising data. Turn off this option, the Tracker will store the corresponding advertising data according to other filtering rules.";
    CGSize noteSize = [NSString sizeWithText:noteMsg
                                     andFont:MKFont(12.f)
                                  andMaxSize:CGSizeMake(kScreenWidth - 30.f, MAXFLOAT)];
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 55.f, kScreenWidth, noteSize.height)];
    noteLabel.textAlignment = NSTextAlignmentLeft;
    noteLabel.textColor = RGBCOLOR(193, 88, 38);
    noteLabel.text = noteMsg;
    noteLabel.numberOfLines = 0;
    noteLabel.font = MKFont(12.f);
    [footerView addSubview:noteLabel];
    
    return footerView;
}

@end
