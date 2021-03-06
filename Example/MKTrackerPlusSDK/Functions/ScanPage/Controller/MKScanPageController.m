//
//  MKScanPageController.m
//  MKContactTracker
//
//  Created by aa on 2020/4/22.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKScanPageController.h"

#import "MKScanPageCell.h"

#import "MKScanSearchButton.h"
#import "MKConnectDeviceProgressView.h"
#import "MKScanSearchView.h"

#import "MKAboutController.h"
#import "MKUpdateController.h"

#import "MKTrackerModel+MKScanAdd.h"

#import "MKTrackerDatabaseManager.h"

static CGFloat const offset_X = 15.f;
static CGFloat const searchButtonHeight = 40.f;

static NSTimeInterval const kRefreshInterval = .5f;

static NSString *const MKLeftButtonAnimationKey = @"MKLeftButtonAnimationKey";

@interface MKSortModel : NSObject

/**
 过滤条件，mac或者名字包含的搜索条件
 */
@property (nonatomic, copy)NSString *searchName;

/**
 过滤设备的rssi
 */
@property (nonatomic, assign)NSInteger sortRssi;

/**
 是否打开了搜索条件
 */
@property (nonatomic, assign)BOOL isOpen;

@end

@implementation MKSortModel

@end

@interface MKScanPageController ()<UITableViewDelegate,UITableViewDataSource,MKTrackerCentralManagerScanDelegate, MKScanPageCellDelegate>

@property (nonatomic, strong)UIImageView *circleIcon;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)MKScanSearchButton *searchButton;

@property (nonatomic, strong)MKSortModel *sortModel;

/**
 数据源
 */
@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)UITextField *passwordField;

/**
 当从配置页面返回的时候，需要扫描
 */
@property (nonatomic, assign)BOOL needScan;

@property (nonatomic, strong)dispatch_source_t scanTimer;

/// 当左侧按钮停止扫描的时候,currentScanStatus = NO,开始扫描的时候currentScanStatus=YES
@property (nonatomic, assign)BOOL currentScanStatus;

@property (nonatomic, assign)CFRunLoopObserverRef observerRef;

@property (nonatomic, assign)BOOL isNeedRefresh;

@end

@implementation MKScanPageController

- (void)dealloc {
    NSLog(@"MKScanPageController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //移除runloop的监听
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.needScan && [MKTrackerCentralManager shared].centralStatus == MKCentralManagerStateEnable) {
        self.needScan = NO;
        self.leftButton.selected = NO;
        self.currentScanStatus = NO;
        [self leftButtonMethod];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self runloopObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setCentralScanDelegate)
                                                 name:@"MKCentralDeallocNotification"
                                               object:nil];
    [self setCentralScanDelegate];
    [self performSelector:@selector(showCentralStatus) withObject:nil afterDelay:3.5f];
}

#pragma mark - super method

- (void)leftButtonMethod {
    if ([MKTrackerCentralManager shared].centralStatus != MKCentralManagerStateEnable) {
        [self.view showCentralToast:@"The current system of bluetooth is not available!"];
        return;
    }
    self.leftButton.selected = !self.leftButton.selected;
    self.currentScanStatus = self.leftButton.selected;
    if (!self.leftButton.isSelected) {
        //停止扫描
        [self.circleIcon.layer removeAnimationForKey:MKLeftButtonAnimationKey];
        [[MKTrackerCentralManager shared] stopScan];
        if (self.scanTimer) {
            dispatch_cancel(self.scanTimer);
        }
        return;
    }
    [self.dataList removeAllObjects];
    [self.tableView reloadData];
    //刷新顶部设备数量
    [self resetDevicesNum];
    [self addAnimationForLeftButton];
    [self scanTimerRun];
}

- (void)rightButtonMethod {
    MKAboutController *vc = [[MKAboutController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 代理方法

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKScanPageCell *cell = [MKScanPageCell initCellWithTableView:self.tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 175.f;
}

#pragma mark - MKTrackerCentralManagerScanDelegate
- (void)mk_trackerReceiveDevice:(MKTrackerModel *)trackerModel {
    [self updateDataWithTrackerModel:trackerModel];
}

- (void)mk_trackerStopScan {
    //如果是左上角在动画，则停止动画
    if (self.leftButton.isSelected) {
        [self.circleIcon.layer removeAnimationForKey:MKLeftButtonAnimationKey];
        [self.leftButton setSelected:NO];
    }
}

#pragma mark - MKScanPageCellDelegate
- (void)scanCellConnectButtonPressed:(NSInteger)index {
    if (index >= self.dataList.count) {
        return;
    }
    MKTrackerModel *trackerModel = self.dataList[index];
    [self connectDeviceWithModel:trackerModel];
}

#pragma mark - notice method
- (void)setCentralScanDelegate{
    [MKTrackerCentralManager shared].delegate = self;
}

#pragma mark - private method

- (void)showCentralStatus{
    if (kSystemVersion >= 11.0 && [MKTrackerCentralManager shared].centralStatus != MKCentralManagerStateEnable) {
        //对于iOS11以上的系统，打开app的时候，如果蓝牙未打开，弹窗提示，后面系统蓝牙状态再发生改变就不需要弹窗了
        NSString *msg = @"The current system of bluetooth is not available!";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Dismiss"
                                                                                 message:msg
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:moreAction];
        
        [kAppRootController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [self leftButtonMethod];
}

#pragma mark - 扫描部分
/**
 搜索设备
 */
- (void)serachButtonPressed{
    MKScanSearchView *searchView = [[MKScanSearchView alloc] init];
    WS(weakSelf);
    searchView.scanSearchViewDismisBlock = ^(BOOL update, NSString *text, CGFloat rssi) {
        if (!update) {
            return ;
        }
        weakSelf.sortModel.sortRssi = (NSInteger)rssi;
        weakSelf.sortModel.searchName = text;
        weakSelf.sortModel.isOpen = YES;
        weakSelf.searchButton.searchConditions = (ValidStr(weakSelf.sortModel.searchName) ?
                                                  [@[weakSelf.sortModel.searchName,[NSString stringWithFormat:@"%@dBm",[NSString stringWithFormat:@"%ld",(long)weakSelf.sortModel.sortRssi]]] mutableCopy] :
                                                  [@[[NSString stringWithFormat:@"%@dBm",[NSString stringWithFormat:@"%ld",(long)weakSelf.sortModel.sortRssi]]] mutableCopy]);
        weakSelf.leftButton.selected = NO;
        weakSelf.currentScanStatus = NO;
        [weakSelf leftButtonMethod];
    };
    [searchView showWithText:(self.sortModel.isOpen ? self.sortModel.searchName : @"")
                   rssiValue:(self.sortModel.isOpen ? [NSString stringWithFormat:@"%ld",(long)weakSelf.sortModel.sortRssi] : @"")];
}

- (void)updateDataWithTrackerModel:(MKTrackerModel *)trackerModel{
    if (self.sortModel.isOpen) {
        if (!ValidStr(self.sortModel.searchName)) {
            //打开了过滤，但是只过滤rssi
            [self filterTrackerDataWithRssi:trackerModel];
            return;
        }
        //如果打开了过滤，先看是否需要过滤设备名字和mac地址
        [self filterTrackerDataWithSearchName:trackerModel];
        return;
    }
    [self processTrackerData:trackerModel];
}

/**
 通过rssi过滤设备
 */
- (void)filterTrackerDataWithRssi:(MKTrackerModel *)trackerModel{
    if (trackerModel.rssi < self.sortModel.sortRssi) {
        return;
    }
    [self processTrackerData:trackerModel];
}

/**
 通过设备名称和mac地址过滤设备，这个时候肯定开启了rssi
 
 @param trackerModel 设备
 */
- (void)filterTrackerDataWithSearchName:(MKTrackerModel *)trackerModel{
    if (trackerModel.rssi < self.sortModel.sortRssi) {
        return;
    }
    if ([[trackerModel.deviceName uppercaseString] containsString:[self.sortModel.searchName uppercaseString]]
        || [[trackerModel.macAddress uppercaseString] containsString:[self.sortModel.searchName uppercaseString]]) {
        //如果mac地址和设备名称包含搜索条件，则加入
        [self processTrackerData:trackerModel];
    }
}

- (void)processTrackerData:(MKTrackerModel *)trackerModel{
    //查看数据源中是否已经存在相关设备
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macAddress == %@", trackerModel.macAddress];
    NSArray *array = [self.dataList filteredArrayUsingPredicate:predicate];
    BOOL contain = ValidArray(array);
    if (contain) {
        //如果是已经存在了，替换
        [self dataExistDataSource:trackerModel];
        return;
    }
    //不存在，则加入
    [self dataNoExistDataSource:trackerModel];
}

/**
 将扫描到的设备加入到数据源
 
 @param trackerModel 扫描到的设备
 */
- (void)dataNoExistDataSource:(MKTrackerModel *)trackerModel{
    [self.dataList addObject:trackerModel];
    trackerModel.index = (self.dataList.count - 1);
    trackerModel.scanTime = @"N/A";
    trackerModel.lastScanDate = kSystemTimeStamp;
    [self needRefreshList];
}

/**
 如果是已经存在了，直接替换
 
 @param trackerModel  新扫描到的数据帧
 */
- (void)dataExistDataSource:(MKTrackerModel *)trackerModel {
    NSInteger currentIndex = 0;
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKTrackerModel *dataModel = self.dataList[i];
        if ([dataModel.macAddress isEqualToString:trackerModel.macAddress]) {
            currentIndex = i;
            break;
        }
    }
    MKTrackerModel *dataModel = self.dataList[currentIndex];
    trackerModel.scanTime = [NSString stringWithFormat:@"%@%ld%@",@"<->",(long)([kSystemTimeStamp integerValue] - [dataModel.lastScanDate integerValue]) * 1000,@"ms"];
    trackerModel.lastScanDate = kSystemTimeStamp;
    trackerModel.index = currentIndex;
    [self.dataList replaceObjectAtIndex:currentIndex withObject:trackerModel];
    [self needRefreshList];
}

#pragma mark - 连接部分
- (void)connectDeviceWithModel:(MKTrackerModel *)trackerModel {
    //停止扫描
    [self.circleIcon.layer removeAnimationForKey:MKLeftButtonAnimationKey];
    [[MKTrackerCentralManager shared] stopScan];
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    NSString *msg = @"Please enter connection password.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter password"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        weakSelf.passwordField = nil;
        weakSelf.passwordField = textField;
        if (ValidStr([MKDeviceTypeManager shared].password)) {
            textField.text = [MKDeviceTypeManager shared].password;
        }
        weakSelf.passwordField.placeholder = @"The password is 8 characters.";
        [textField addTarget:self action:@selector(passwordInput) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.leftButton.selected = NO;
        weakSelf.currentScanStatus = NO;
        [weakSelf leftButtonMethod];
    }];
    [alertController addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf connectDeviceWithTrackerModel:trackerModel];
    }];
    [alertController addAction:moreAction];
    
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

- (void)connectDeviceWithTrackerModel:(MKTrackerModel *)trackerModel {
    NSString *password = self.passwordField.text;
    if (password.length != 8) {
        [self.view showCentralToast:@"The password should be 8 characters."];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Connecting..." inView:self.view isPenetration:NO];
    [[MKDeviceTypeManager shared] connectTracker:trackerModel password:password completeBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        self.needScan = YES;
        if (error) {
            [self.view showCentralToast:error.userInfo[@"errorInfo"]];
            [self connectFailed];
            return ;
        }
        if (trackerModel.isTrackerPlus) {
            //对于V2版本固件来说，进入通用设置页面
            [self.view showCentralToast:@"Time sync completed!"];
            [MKTrackerDatabaseManager clearDataTable];
            [MKTrackerDatabaseManager initStepDataBase];
            [self performSelector:@selector(pushTabBarPage) afterDelay:0.6f];
        }else {
            //对于V1版本固件来说，需要进入dfu升级页面
            MKUpdateController *vc = [[MKUpdateController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];
}

- (void)pushTabBarPage {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKNeedResetRootControllerToTabBar" object:nil userInfo:@{}];
}

- (void)connectFailed {
    self.leftButton.selected = NO;
    self.currentScanStatus = NO;
    [self leftButtonMethod];
}

/**
 监听输入的密码
 */
- (void)passwordInput{
    NSString *tempInputString = self.passwordField.text;
    if (!ValidStr(tempInputString)) {
        self.passwordField.text = @"";
        return;
    }
    self.passwordField.text = (tempInputString.length > 8 ? [tempInputString substringToIndex:8] : tempInputString);
}

- (void)resetDevicesNum{
    [self.titleLabel setText:[NSString stringWithFormat:@"DEVICE(%@)",[NSString stringWithFormat:@"%ld",(long)self.dataList.count]]];
}

- (void)addAnimationForLeftButton{
    [self.circleIcon.layer removeAnimationForKey:MKLeftButtonAnimationKey];
    [self.circleIcon.layer addAnimation:[self animation] forKey:MKLeftButtonAnimationKey];
}

- (CABasicAnimation *)animation{
    CABasicAnimation *transformAnima = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    transformAnima.duration = 2.f;
    transformAnima.fromValue = @(0);
    transformAnima.toValue = @(2 * M_PI);
    transformAnima.autoreverses = NO;
    transformAnima.repeatCount = MAXFLOAT;
    transformAnima.removedOnCompletion = NO;
    return transformAnima;
}

#pragma mark - 扫描监听
- (void)scanTimerRun{
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    [[MKTrackerCentralManager shared] startScan];
    self.scanTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 60 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.scanTimer, start, interval, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.scanTimer, ^{
        [[MKTrackerCentralManager shared] stopScan];
        [weakSelf needRefreshList];
    });
    dispatch_resume(self.scanTimer);
}

#pragma mark - 刷新
- (void)needRefreshList {
    //标记需要刷新
    self.isNeedRefresh = YES;
    //唤醒runloop
    CFRunLoopWakeUp(CFRunLoopGetMain());
}

- (void)runloopObserver {
    WS(weakSelf);
    __block NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    self.observerRef = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (activity == kCFRunLoopBeforeWaiting) {
            //runloop空闲的时候刷新需要处理的列表,但是需要控制刷新频率
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            if (currentInterval - timeInterval < kRefreshInterval) {
                return;;
            }
            timeInterval = currentInterval;
            if (weakSelf.isNeedRefresh) {
                [weakSelf.tableView reloadData];
                [weakSelf resetDevicesNum];
                weakSelf.isNeedRefresh = NO;
            }
        }
    });
    //添加监听，模式为kCFRunLoopCommonModes
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
}

#pragma mark - UI

- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x2F84D0);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    [self.leftButton setImage:nil forState:UIControlStateNormal];
    [self.leftButton addSubview:self.circleIcon];
    [self.circleIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.leftButton.mas_centerX);
        make.width.mas_equalTo(22.f);
        make.centerY.mas_equalTo(self.leftButton.mas_centerY);
        make.height.mas_equalTo(22.f);
    }];
    [self resetDevicesNum];
    [self.rightButton setImage:LOADIMAGE(@"scanRightAboutIcon", @"png") forState:UIControlStateNormal];
    [self.view setBackgroundColor:RGBCOLOR(237, 243, 250)];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  kScreenWidth - 2 * offset_X,
                                                                  searchButtonHeight + 2 * offset_X)];
    [headerView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(offset_X);
        make.height.mas_equalTo(searchButtonHeight);
    }];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(defaultTopInset);
        make.height.mas_equalTo(searchButtonHeight + 2 * offset_X);
    }];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.top.mas_equalTo(headerView.mas_bottom).mas_offset(0);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 5.f);
    }];
}

#pragma mark - getter
- (MKScanSearchButton *)searchButton{
    if (!_searchButton) {
        _searchButton = [[MKScanSearchButton alloc] init];
        [_searchButton setBackgroundColor:COLOR_WHITE_MACROS];
        [_searchButton.layer setMasksToBounds:YES];
        [_searchButton.layer setCornerRadius:4.f];
        _searchButton.searchConditions = [@[] mutableCopy];
        WS(weakSelf);
        _searchButton.clearSearchConditionsBlock = ^{
            weakSelf.sortModel.isOpen = NO;
            weakSelf.sortModel.searchName = @"";
            weakSelf.sortModel.sortRssi = -127;
            weakSelf.leftButton.selected = NO;
            weakSelf.currentScanStatus = NO;
            [weakSelf leftButtonMethod];
        };
        _searchButton.searchButtonPressedBlock = ^{
            [weakSelf serachButtonPressed];
        };
    }
    return _searchButton;
}

- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.layer.masksToBounds = YES;
        _tableView.layer.borderColor = COLOR_CLEAR_MACROS.CGColor;
        _tableView.layer.cornerRadius = 6.f;
    }
    return _tableView;
}

- (UIImageView *)circleIcon{
    if (!_circleIcon) {
        _circleIcon = [[UIImageView alloc] init];
        _circleIcon.image = LOADIMAGE(@"scanRefresh", @"png");
    }
    return _circleIcon;
}

- (MKSortModel *)sortModel{
    if (!_sortModel) {
        _sortModel = [[MKSortModel alloc] init];
    }
    return _sortModel;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
