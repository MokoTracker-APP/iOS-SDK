//
//  MKTrackedDataController.m
//  MKContactTracker
//
//  Created by aa on 2020/4/24.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKTrackedDataController.h"
#import <MessageUI/MessageUI.h>
#import <sys/utsname.h>

#import "MKTrackedDataCell.h"

#import "MKTrackerDatabaseManager.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

static NSTimeInterval const parseDataInterval = 0.10;

static NSString *synIconAnimationKey = @"synIconAnimationKey";

@interface MKTrackedDataController ()<MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UIButton *syncButton;

@property (nonatomic, strong)UIImageView *synIcon;

@property (nonatomic, strong)UILabel *syncLabel;

@property (nonatomic, strong)UILabel *sumLabel;

@property (nonatomic, strong)UILabel *countLabel;

@property (nonatomic, strong)UIView *topView;

@property (nonatomic, strong)UIButton *deleteButton;

@property (nonatomic, strong)UILabel *deleteLabel;

@property (nonatomic, strong)UIButton *exportButton;

@property (nonatomic, strong)UILabel *exportLabel;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)NSMutableArray *contentList;

@property (nonatomic, strong)dispatch_source_t parseTimer;

@end

@implementation MKTrackedDataController

- (void)dealloc {
    NSLog(@"MKTrackedDataController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:mk_receiveScannerTrackedDataNotification
                                                  object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTrackerDatas:)
                                                 name:mk_receiveScannerTrackedDataNotification
                                               object:nil];
    [self readStorageDataNumber];
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[MKHudManager share] showHUDWithTitle:@"Saving..." inView:self.view isPenetration:NO];
    TICK;
    [[MKTrackerCentralManager shared] notifyScannerTrackedData:NO];
    if (self.parseTimer) {
        dispatch_cancel(self.parseTimer);
    }
    [self.synIcon.layer removeAnimationForKey:synIconAnimationKey];
    self.syncLabel.text = @"SYNC";
    TOCK;
    [self performSelector:@selector(saveDataToLocal) afterDelay:0.5f];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *pageModel = self.dataList[indexPath.row];
    return [MKTrackedDataCell fetchCellHeight:pageModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKTrackedDataCell *cell = [MKTrackedDataCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:  //取消
            break;
        case MFMailComposeResultSaved:      //用户保存
            break;
        case MFMailComposeResultSent:       //用户点击发送
            [self.view showCentralToast:@"send success"];
            break;
        case MFMailComposeResultFailed: //用户尝试保存或发送邮件失败
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - event method
- (void)syncButtonPressed {
    self.syncButton.selected = !self.syncButton.selected;
    [self.synIcon.layer removeAnimationForKey:synIconAnimationKey];
    //如果监听数据，则删除按钮不可用
    [self.deleteButton setEnabled:!self.syncButton.selected];
    if (self.syncButton.selected) {
        //开始旋转
//        [self.dataList removeAllObjects];
        [self.synIcon.layer addAnimation:[self animation] forKey:synIconAnimationKey];
        self.syncLabel.text = @"STOP";
        [self addTimerForRefresh];
    }else {
        self.syncLabel.text = @"SYNC";
        if (self.parseTimer) {
            dispatch_cancel(self.parseTimer);
            self.parseTimer = nil;
        }
    }
    [[MKTrackerCentralManager shared] notifyScannerTrackedData:self.syncButton.selected];
}

- (void)deleteButtonPressed {
    NSString *msg = @"Are you sure to empty the saved tracked datas？";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteRecordDatas];
    }];
    [alertController addAction:moreAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)exportButtonPressed {
    if (![MFMailComposeViewController canSendMail]) {
        //如果是未绑定有效的邮箱，则跳转到系统自带的邮箱去处理
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"MESSAGE://"]
                                          options:@{}
                                completionHandler:nil];
        return;
    }
    if (!ValidArray(self.dataList)) {
        [self.view showCentralToast:@"No data to send"];
        return;
    }
    NSArray *list = [self.dataList mutableCopy];
    NSMutableData *emailData = [NSMutableData data];
    for (NSDictionary *dic in list) {
        NSString *timeString = @"Time: N/A";
        NSString *macString = @"MAC: N/A";
        NSString *rssi = @"RSSI: N/A";
        NSString *rawData = @"Raw Data: N/A";
        if (ValidDict(dic[@"dateDic"])) {
            NSString *time = [NSString stringWithFormat:@"%@/%@/%@ %@:%@:%@",dic[@"dateDic"][@"year"],dic[@"dateDic"][@"month"],dic[@"dateDic"][@"day"],dic[@"dateDic"][@"hour"],dic[@"dateDic"][@"minute"],dic[@"dateDic"][@"second"]];
            timeString = [@"Time: " stringByAppendingString:time];
        }
        if (ValidStr(dic[@"macAddress"])) {
            macString = [@"MAC: " stringByAppendingString:dic[@"macAddress"]];
        }
        if (ValidNum(dic[@"rssi"])) {
            NSString *tempRssi = [NSString stringWithFormat:@"%ld",(long)[dic[@"rssi"] integerValue]];
            rssi = [NSString stringWithFormat:@"%@%@%@",@"RSSI: ",tempRssi,@"dBm"];
        }
        if (ValidStr(dic[@"rawData"])) {
            rawData = [@"Raw Data: " stringByAppendingString:dic[@"rawData"]];
        }
        NSString *stringToWrite = [NSString stringWithFormat:@"\n%@\n%@\n%@\n%@",timeString,macString,rssi,rawData];
        NSData *stringData = [stringToWrite dataUsingEncoding:NSUTF8StringEncoding];
        [emailData appendData:stringData];
    }
    if (!ValidData(emailData)) {
        [self.view showCentralToast:@"Log data error"];
        return;
    }
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *bodyMsg = [NSString stringWithFormat:@"APP Version: %@ + + OS: %@",
                         version,
                         kSystemVersionString];
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    //收件人
    [mailComposer setToRecipients:@[@"Development@mokotechnology.com"]];
    //邮件主题
    [mailComposer setSubject:@"Feedback of mail"];
    [mailComposer addAttachmentData:emailData
                           mimeType:@"application/txt"
                           fileName:@"Tracked Data.txt"];
    [mailComposer setMessageBody:bodyMsg isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

#pragma mark - note
- (void)receiveTrackerDatas:(NSNotification *)note {
    NSDictionary *dic = note.userInfo;
    if (!ValidDict(dic)) {
        return;
    }
    NSString *content = dic[@"content"];
    if (!ValidStr(content)) {
        return;
    }
    [self.contentList addObject:content];
}

#pragma mark - interface
- (void)readStorageDataNumber {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKTrackerInterface readStorageDataNumberWithSucBlock:^(id  _Nonnull returnData) {
        [[MKHudManager share] hide];
        NSInteger totalNumber = [returnData[@"result"][@"storeNumber"] integerValue] + [returnData[@"result"][@"remainingNumber"] integerValue];
        self.sumLabel.text =  [NSString stringWithFormat:@"%@%@/%ld",@"Sum: ",returnData[@"result"][@"storeNumber"],(long)totalNumber];
        [self readDataFromDatabase];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)deleteRecordDatas {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKTrackerInterface clearAllDatasWithSucBlock:^{
        [[MKHudManager share] hide];
        [self.dataList removeAllObjects];
        [MKTrackerDatabaseManager clearDataTable];
        [self performSelector:@selector(readStorageDataNumber) afterDelay:1.f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
    
}

#pragma mark - database
- (void)readDataFromDatabase {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKTrackerDatabaseManager readDataListWithSucBlock:^(NSArray<NSDictionary *> * _Nonnull dataList) {
        [[MKHudManager share] hide];
        [self.dataList addObjectsFromArray:dataList];
        self.countLabel.text = [NSString stringWithFormat:@"%@ %ld",@"Count:",(long)self.dataList.count];
        [self.tableView reloadData];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 刷新
- (void)addTimerForRefresh {
    self.parseTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.parseTimer, dispatch_time(DISPATCH_TIME_NOW, parseDataInterval * NSEC_PER_SEC),  parseDataInterval * NSEC_PER_SEC, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.parseTimer, ^{
        __strong typeof(self) sself = weakSelf;
        moko_dispatch_main_safe(^{
            [sself parseContentDatas];
        });
    });
    dispatch_resume(self.parseTimer);
}

- (void)parseContentDatas {
    if (self.contentList.count == 0) {
        return;
    }
    NSString *firstContent = self.contentList[0];
    NSArray *tempList = [MKTrackerAdopter parseScannerTrackedData:firstContent];
    [self.contentList removeObjectAtIndex:0];
    if (self.dataList.count == 0) {
        [self.dataList addObjectsFromArray:tempList];
    }else {
        for (NSDictionary *dic in tempList) {
            [self.dataList insertObject:dic atIndex:0];
        }
    }
    self.countLabel.text = [NSString stringWithFormat:@"Count: %ld",(long)self.dataList.count];
    [self.tableView reloadData];
}

#pragma mark - 返回操作
- (void)saveDataToLocal {
    [MKTrackerDatabaseManager clearDataTable];
    [MKTrackerDatabaseManager insertDataList:self.dataList sucBlock:^{
        [[MKHudManager share] hide];
        [super leftButtonMethod];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UI
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

- (void)loadSubViews {
    self.defaultTitle = @"TRACKED DATA";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x2F84D0);
    [self.view setBackgroundColor:RGBCOLOR(242, 242, 242)];
    [self.view addSubview:self.tableView];
    [self.topView addSubview:self.syncButton];
    [self.syncButton addSubview:self.synIcon];
    [self.topView addSubview:self.syncLabel];
    [self.topView addSubview:self.sumLabel];
    [self.topView addSubview:self.countLabel];
    [self.topView addSubview:self.deleteButton];
    [self.topView addSubview:self.deleteLabel];
    [self.topView addSubview:self.exportButton];
    [self.topView addSubview:self.exportLabel];
    [self.syncButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(30.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.synIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.syncButton.mas_centerX);
        make.centerY.mas_equalTo(self.syncButton.mas_centerY);
        make.width.mas_equalTo(25.f);
        make.height.mas_equalTo(25.f);
    }];
    [self.syncLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.syncButton.mas_centerX);
        make.width.mas_equalTo(30.f);
        make.top.mas_equalTo(self.syncButton.mas_bottom).mas_offset(2.f);
        make.height.mas_equalTo(MKFont(10.f).lineHeight);
    }];
    [self.sumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.syncButton.mas_right).mas_offset(5.f);
        make.width.mas_equalTo(145.f);
        make.top.mas_equalTo(self.syncButton.mas_top);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.syncButton.mas_right).mas_offset(5.f);
        make.width.mas_equalTo(145.f);
        make.bottom.mas_equalTo(self.syncLabel.mas_bottom);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.exportButton.mas_left).mas_offset(-15.f);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.syncButton.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deleteButton.mas_left);
        make.right.mas_equalTo(self.deleteButton.mas_right);
        make.top.mas_equalTo(self.deleteButton.mas_bottom).mas_offset(2.f);
        make.height.mas_equalTo(MKFont(10.f).lineHeight);
    }];
    [self.exportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.syncButton.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.exportLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.exportButton.mas_left);
        make.right.mas_equalTo(self.exportButton.mas_right);
        make.top.mas_equalTo(self.exportButton.mas_bottom).mas_offset(2.f);
        make.height.mas_equalTo(MKFont(10.f).lineHeight);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5.f);
        make.right.mas_equalTo(5.f);
        make.top.mas_equalTo(defaultTopInset + 15.f);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - setter & getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 2 * 15, 50.f)];
        _topView.backgroundColor = COLOR_WHITE_MACROS;
    }
    return _topView;
}

- (UIButton *)syncButton {
    if (!_syncButton) {
        _syncButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_syncButton addTapAction:self selector:@selector(syncButtonPressed)];
    }
    return _syncButton;
}

- (UIImageView *)synIcon {
    if (!_synIcon) {
        _synIcon = [[UIImageView alloc] init];
        _synIcon.image = LOADIMAGE(@"threeAxisAcceLoadingIcon", @"png");
        _synIcon.userInteractionEnabled = YES;
    }
    return _synIcon;
}

- (UILabel *)syncLabel {
    if (!_syncLabel) {
        _syncLabel = [[UILabel alloc] init];
        _syncLabel.textColor = DEFAULT_TEXT_COLOR;
        _syncLabel.textAlignment = NSTextAlignmentCenter;
        _syncLabel.font = MKFont(10.f);
        _syncLabel.text = @"SYNC";
    }
    return _syncLabel;
}

- (UILabel *)sumLabel {
    if (!_sumLabel) {
        _sumLabel = [[UILabel alloc] init];
        _sumLabel.textColor = DEFAULT_TEXT_COLOR;
        _sumLabel.textAlignment = NSTextAlignmentLeft;
        _sumLabel.font = MKFont(13.f);
        _sumLabel.text = @"Sum: 0/0";
    }
    return _sumLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = DEFAULT_TEXT_COLOR;
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.font = MKFont(13.f);
        _countLabel.text = @"Count: N/A";
    }
    return _countLabel;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:LOADIMAGE(@"slot_export_deleteIcon", @"png") forState:UIControlStateNormal];
        [_deleteButton addTapAction:self selector:@selector(deleteButtonPressed)];
    }
    return _deleteButton;
}

- (UILabel *)deleteLabel {
    if (!_deleteLabel) {
        _deleteLabel = [[UILabel alloc] init];
        _deleteLabel.textColor = DEFAULT_TEXT_COLOR;
        _deleteLabel.textAlignment = NSTextAlignmentCenter;
        _deleteLabel.font = MKFont(10.f);
        _deleteLabel.text = @"Empty";
    }
    return _deleteLabel;
}

- (UIButton *)exportButton {
    if (!_exportButton) {
        _exportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exportButton setImage:LOADIMAGE(@"slot_export_enableIcon", @"png") forState:UIControlStateNormal];
        [_exportButton addTapAction:self selector:@selector(exportButtonPressed)];
    }
    return _exportButton;
}

- (UILabel *)exportLabel {
    if (!_exportLabel) {
        _exportLabel = [[UILabel alloc] init];
        _exportLabel.textColor = DEFAULT_TEXT_COLOR;
        _exportLabel.textAlignment = NSTextAlignmentCenter;
        _exportLabel.font = MKFont(10.f);
        _exportLabel.text = @"Export";
    }
    return _exportLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.topView;
        _tableView.layer.masksToBounds = YES;
        _tableView.layer.cornerRadius = 8.f;
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray *)contentList {
    if (!_contentList) {
        _contentList = [NSMutableArray array];
    }
    return _contentList;
}

@end
