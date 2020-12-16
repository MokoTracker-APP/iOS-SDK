//
//  MKTrackerConfigDataModel.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/28.
//

#import "MKTrackerConfigDataModel.h"

@interface MKTrackerConfigDataModel ()

@property (nonatomic, strong)dispatch_queue_t configQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKTrackerConfigDataModel

- (void)startReadDataWithSucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![self readScanStatus]) {
            [self operationFailedBlockWithMsg:@"Read scan status error" block:failedBlock];
            return ;
        }
        if (![self readScanIntervalParams]) {
            [self operationFailedBlockWithMsg:@"Read scan interval error" block:failedBlock];
            return ;
        }
        if (![self readStorageInterval]) {
            [self operationFailedBlockWithMsg:@"Read interval error" block:failedBlock];
            return ;
        }
        if (![self readTrackingNote]) {
            [self operationFailedBlockWithMsg:@"Read tracking notification error" block:failedBlock];
            return;
        }
        if ([MKDeviceTypeManager shared].supportAdvTrigger) {
            if (![self readConditions]) {
                [self operationFailedBlockWithMsg:@"Read scanning trigger error" block:failedBlock];
                return;
            }
        }
        if (![self readNumbersOfVibration]) {
            [self operationFailedBlockWithMsg:@"Read number of vibrations error" block:failedBlock];
            return;
        }
        if (![self readTrackingDataFormat]) {
            [self operationFailedBlockWithMsg:@"Read tracking data format error" block:failedBlock];
            return ;
        }
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

- (void)startConfigDataWithSucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![self configScanStatus]) {
            [self operationFailedBlockWithMsg:@"Config scan status params error" block:failedBlock];
            return;
        }
        if (self.scanStatus) {
            if (![self configScanIntervalParams]) {
                [self operationFailedBlockWithMsg:@"Config scan interval params error" block:failedBlock];
                return;
            }
            if ([MKDeviceTypeManager shared].supportAdvTrigger) {
                if (![self configConditions]) {
                    [self operationFailedBlockWithMsg:@"Config tracking trigger error" block:failedBlock];
                    return;
                }
            }
        }
        if (![self configStorageInterval]) {
            [self operationFailedBlockWithMsg:@"Config tracking interval error" block:failedBlock];
            return;
        }
        if (![self configTrackingNote]) {
            [self operationFailedBlockWithMsg:@"Config tracking note error" block:failedBlock];
            return;
        }
        if (![self configNumbersOfVibration]) {
            [self operationFailedBlockWithMsg:@"Config number of vibrations error" block:failedBlock];
            return ;
        }
        if (![self configTrackingDataFormat]) {
            [self operationFailedBlockWithMsg:@"Config tracking data format error" block:failedBlock];
            return;
        }
        moko_dispatch_main_safe(^{
            sucBlock();
        });
    });
}

#pragma mark - interface
- (BOOL)readScanStatus {
    __block BOOL success = NO;
    [MKTrackerInterface readScanStatusWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.scanStatus = [returnData[@"result"][@"isOn"] boolValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configScanStatus {
    __block BOOL success = NO;
    [MKTrackerInterface configScanStatus:self.scanStatus sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readScanIntervalParams {
    __block BOOL success = NO;
    [MKTrackerInterface readScanIntervalParamsWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.scanWindow = returnData[@"result"][@"scanWindow"];
        self.scanInterval = returnData[@"result"][@"scanInterval"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configScanIntervalParams {
    __block BOOL success = NO;
    [MKTrackerInterface configScannWindowInterval:[self.scanWindow integerValue] scanInterval:[self.scanInterval integerValue] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readConditions {
    __block BOOL success = NO;
    [MKTrackerInterface readScanningTriggerConditionsWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        if ([returnData[@"result"][@"conditions"][@"isOn"] boolValue]) {
            self.trackingTrigger = returnData[@"result"][@"conditions"][@"time"];
        }else {
            self.trackingTrigger = @"0";
        }
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configConditions {
    __block BOOL success = NO;
    [MKTrackerInterface configScanningTrigger:[self.trackingTrigger integerValue] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readStorageInterval {
    __block BOOL success = NO;
    [MKTrackerInterface readStorageIntervalWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.trackingInterval = returnData[@"result"][@"interval"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configStorageInterval {
    __block BOOL success = NO;
    [MKTrackerInterface configStorageInterval:[self.trackingInterval integerValue] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readTrackingNote {
    __block BOOL success = NO;
    [MKTrackerInterface readTrackingNotificationWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.trackingNote = [returnData[@"result"][@"reminder"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configTrackingNote {
    __block BOOL success = NO;
    [MKTrackerInterface configTrackingNotification:self.trackingNote sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readNumbersOfVibration {
    __block BOOL success = NO;
    [MKTrackerInterface readNumberOfVibrationsWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.vibNubmer = [returnData[@"result"][@"number"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configNumbersOfVibration {
    __block BOOL success = NO;
    [MKTrackerInterface configNumberOfVibrations:self.vibNubmer sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readTrackingDataFormat {
    __block BOOL success = NO;
    [MKTrackerInterface readTrackingDataFormatWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.format = [returnData[@"result"][@"state"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configTrackingDataFormat {
    __block BOOL success = NO;
    [MKTrackerInterface configTrackingDataFormat:self.format sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"trackerParams"
                                                    code:-999
                                                userInfo:@{@"errorInfo":SafeStr(msg)}];
        block(error);
    })
}

#pragma mark - getter
- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)configQueue {
    if (!_configQueue) {
        _configQueue = dispatch_queue_create("trackerParamsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _configQueue;
}

@end
