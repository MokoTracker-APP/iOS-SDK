//
//  MKTrackerInterface+MKConfig.m
//  MKContactTracker
//
//  Created by aa on 2020/4/27.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKTrackerInterface+MKConfig.h"
#import "MKBLEBaseSDKDefines.h"
#import "MKBLEBaseSDKAdopter.h"
#import "MKTrackerCentralManager.h"

#import "MKTrackerOperation.h"
#import "MKTrackerAdopter.h"
#import "CBPeripheral+MKTracker.h"
#import "MKTrackerOperationID.h"

#define centralManager [MKTrackerCentralManager shared]

@implementation MKTrackerInterface (MKConfig)

+ (void)configDeviceTime:(id <MKDeviceTimeProtocol>)protocol
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock {
    if (![self validTimeProtocol:protocol]) {
        [MKBLEBaseSDKAdopter operationProtocolErrorBlock:failedBlock];
        return;
    }
    NSString *dateString = [self getTimeString:protocol];
    NSString *commandString = [@"ea350006" stringByAppendingString:dateString];
    [self addTaskWithOperationID:mk_taskConfigDateOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configDeviceName:(NSString *)deviceName
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(deviceName) || deviceName.length < 1 || deviceName.length > 10
        || ![MKBLEBaseSDKAdopter asciiString:deviceName]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < deviceName.length; i ++) {
        int asciiCode = [deviceName characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    [self addTaskWithOperationID:mk_taskConfigDeviceNameOperation
                  characteristic:centralManager.peripheral.deviceName
                     commandData:tempString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configProximityUUID:(NSString *)uuid
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    if (![MKBLEBaseSDKAdopter isUUIDString:uuid]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [self addTaskWithOperationID:mk_taskConfigProximityUUIDOperation
                  characteristic:centralManager.peripheral.uuid
                     commandData:uuid
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMajor:(NSInteger)major
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock {
    if (major < 0 || major > 65535) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *majorHex = [NSString stringWithFormat:@"%1lx",(unsigned long)major];
    if (majorHex.length == 1) {
        majorHex = [@"000" stringByAppendingString:majorHex];
    }else if (majorHex.length == 2){
        majorHex = [@"00" stringByAppendingString:majorHex];
    }else if (majorHex.length == 3){
        majorHex = [@"0" stringByAppendingString:majorHex];
    }
    [self addTaskWithOperationID:mk_taskConfigMajorOperation
                  characteristic:centralManager.peripheral.major
                     commandData:majorHex
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMinor:(NSInteger)minor
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock {
    if (minor < 0 || minor > 65535) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *minorHex = [NSString stringWithFormat:@"%1lx",(unsigned long)minor];
    if (minorHex.length == 1) {
        minorHex = [@"000" stringByAppendingString:minorHex];
    }else if (minorHex.length == 2){
        minorHex = [@"00" stringByAppendingString:minorHex];
    }else if (minorHex.length == 3){
        minorHex = [@"0" stringByAppendingString:minorHex];
    }
    [self addTaskWithOperationID:mk_taskConfigMinorOperation
                  characteristic:centralManager.peripheral.minor
                     commandData:minorHex
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAdvInterval:(NSInteger)interval
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    if (interval < 1 || interval > 100) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *advInterval = [NSString stringWithFormat:@"%1lx",(unsigned long)interval];
    if (advInterval.length == 1) {
        advInterval = [@"0" stringByAppendingString:advInterval];
    }
    [self addTaskWithOperationID:mk_taskConfigAdvIntervalOperation
                  characteristic:centralManager.peripheral.broadcastInterval
                     commandData:advInterval
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMeasuredPower:(NSInteger)measuredPower
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    if (measuredPower > 0 || measuredPower < -127) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *power = [MKBLEBaseSDKAdopter hexStringFromSignedNumber:measuredPower];
    [self addTaskWithOperationID:mk_taskConfigMeasuredPowerOperation
                  characteristic:centralManager.peripheral.measuredPower
                     commandData:power
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configTxPower:(mk_trackerTxPower)txPower
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *power = [self fetchTxPower:txPower];
    [self addTaskWithOperationID:mk_taskConfigTxPowerOperation
                  characteristic:centralManager.peripheral.txPower
                     commandData:power
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)closeAdvTriggerConditionsWithSucBlock:(void (^)(void))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithOperationID:mk_taskConfigAdvTriggerConditionsOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:@"ea31000100"
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAdvTrigger:(NSInteger)time
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock {
    if (time < 0 || time > 65535) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *timeString = [NSString stringWithFormat:@"%1lx",(unsigned long)time];
    if (timeString.length == 1) {
        timeString = [@"000" stringByAppendingString:timeString];
    }else if (timeString.length == 2) {
        timeString = [@"00" stringByAppendingString:timeString];
    }else if (timeString.length == 3) {
        timeString = [@"0" stringByAppendingString:timeString];
    }
    NSString *commandString = [@"ea310002" stringByAppendingString:timeString];
    [self addTaskWithOperationID:mk_taskConfigAdvTriggerConditionsOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configStorageInterval:(NSInteger)interval
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (interval < 0 || interval > 255) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *timeString = [NSString stringWithFormat:@"%1lx",(unsigned long)interval];
    if (timeString.length == 1) {
        timeString = [@"0" stringByAppendingString:timeString];
    }
    NSString *commandString = [@"ea340001" stringByAppendingString:timeString];
    [self addTaskWithOperationID:mk_taskConfigStorageIntervalOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configTrackingNotification:(mk_trackingNotification)note
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *noteString = [self fetchTrackingNotification:note];
    [self addTaskWithOperationID:mk_taskConfigStorageReminderOperation
                  characteristic:centralManager.peripheral.storageReminder
                     commandData:noteString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configScanningTrigger:(NSInteger)time
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (time < 0 || time > 65535) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = @"";
    if (time == 0) {
        commandString = @"ea32000100";
    }else {
        NSString *timeString = [NSString stringWithFormat:@"%1lx",(unsigned long)time];
        if (timeString.length == 1) {
            timeString = [@"000" stringByAppendingString:timeString];
        }else if (timeString.length == 2) {
            timeString = [@"00" stringByAppendingString:timeString];
        }else if (timeString.length == 3) {
            timeString = [@"0" stringByAppendingString:timeString];
        }
        commandString = [@"ea320002" stringByAppendingString:timeString];
    }
    [self addTaskWithOperationID:mk_taskConfigScanningTriggerConditionsOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configStorageRssi:(NSInteger)rssi
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    if (rssi > 0 || rssi < -127) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *rssiValue = [MKBLEBaseSDKAdopter hexStringFromSignedNumber:rssi];
    NSString *commandString = [@"ea330001" stringByAppendingString:rssiValue];
    [self addTaskWithOperationID:mk_taskConfigStorageRssiOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAdvDataFilterStatus:(BOOL)isOn
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = (isOn ? @"ea56000101" : @"ea56000100");
    [self addTaskWithOperationID:mk_taskConfigAdvDataFilterStatusOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMacFilterStatus:(BOOL)isOn
                    whiteList:(BOOL)isOpen
                          mac:(NSString *)mac
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        //关闭mac扫描
        [self addTaskWithOperationID:mk_taskConfigMacFilterStatusOperation
                      characteristic:centralManager.peripheral.custom
                         commandData:@"ea51000100"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    //需要校验macAddress
    mac = [mac stringByReplacingOccurrencesOfString:@" " withString:@""];
    mac = [mac stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
    if (mac.length % 2 != 0 || mac.length == 0 || mac.length > 12 || ![MKBLEBaseSDKAdopter checkHexCharacter:mac]) {
        //不是偶数报错
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSInteger len = (mac.length / 2) + 1;
    NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)len];
    if (lenString.length == 1) {
        lenString = [@"0" stringByAppendingString:lenString];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",@"ea5100",lenString,(isOpen ? @"02" : @"01"),mac];
    [self addTaskWithOperationID:mk_taskConfigMacFilterStatusOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAdvNameFilterStatus:(BOOL)isOn
                        whiteList:(BOOL)isOpen
                          advName:(NSString *)advName
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        [self addTaskWithOperationID:mk_taskConfigAdvNameFilterStatusOperation
                      characteristic:centralManager.peripheral.custom
                         commandData:@"ea52000100"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    if (!MKValidStr(advName) || advName.length > 10) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < advName.length; i ++) {
        int asciiCode = [advName characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSInteger len = advName.length + 1;
    NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)len];
    if (lenString.length == 1) {
        lenString = [@"0" stringByAppendingString:lenString];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",@"ea5200",lenString,(isOpen ? @"02" : @"01"),tempString];
    [self addTaskWithOperationID:mk_taskConfigAdvNameFilterStatusOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configProximityUUIDFilterStatus:(BOOL)isOn
                              whiteList:(BOOL)isOpen
                                   uuid:(NSString *)uuid
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        [self addTaskWithOperationID:mk_taskConfigProximityUUIDFilterStatusOperation
                      characteristic:centralManager.peripheral.custom
                         commandData:@"ea57000100"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    if (![MKBLEBaseSDKAdopter isUUIDString:uuid]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"ea570011",(isOpen ? @"02" : @"01"),uuid];
    [self addTaskWithOperationID:mk_taskConfigProximityUUIDFilterStatusOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMajorFilterStatus:(BOOL)isOn
                      whiteList:(BOOL)isOpen
                  majorMinValue:(NSInteger)majorMinValue
                  majorMaxValue:(NSInteger)majorMaxValue
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        [self addTaskWithOperationID:mk_taskConfigMajorFilterStateOperation
                      characteristic:centralManager.peripheral.custom
                         commandData:@"ea73000100"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    if (majorMinValue < 0 || majorMinValue > 65535
        || majorMaxValue < 0 || majorMaxValue > 65535
        || majorMinValue > majorMaxValue) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *majorMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)majorMinValue];
    if (majorMinHex.length == 1) {
        majorMinHex = [@"000" stringByAppendingString:majorMinHex];
    }else if (majorMinHex.length == 2){
        majorMinHex = [@"00" stringByAppendingString:majorMinHex];
    }else if (majorMinHex.length == 3){
        majorMinHex = [@"0" stringByAppendingString:majorMinHex];
    }
    NSString *majorMaxHex = [NSString stringWithFormat:@"%1lx",(unsigned long)majorMaxValue];
    if (majorMaxHex.length == 1) {
        majorMaxHex = [@"000" stringByAppendingString:majorMaxHex];
    }else if (majorMaxHex.length == 2){
        majorMaxHex = [@"00" stringByAppendingString:majorMaxHex];
    }else if (majorMaxHex.length == 3){
        majorMaxHex = [@"0" stringByAppendingString:majorMaxHex];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",@"ea730005",(isOpen ? @"02" : @"01"),majorMinHex,majorMaxHex];
    [self addTaskWithOperationID:mk_taskConfigMajorFilterStateOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMinorFilterStatus:(BOOL)isOn
                      whiteList:(BOOL)isOpen
                  minorMinValue:(NSInteger)minorMinValue
                  minorMaxValue:(NSInteger)minorMaxValue
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        [self addTaskWithOperationID:mk_taskConfigMinorFilterStateOperation
                      characteristic:centralManager.peripheral.custom
                         commandData:@"ea74000100"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    if (minorMinValue < 0 || minorMinValue > 65535
        || minorMaxValue < 0 || minorMaxValue > 65535
        || minorMinValue > minorMaxValue) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *minorMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)minorMinValue];
    if (minorMinHex.length == 1) {
        minorMinHex = [@"000" stringByAppendingString:minorMinHex];
    }else if (minorMinHex.length == 2){
        minorMinHex = [@"00" stringByAppendingString:minorMinHex];
    }else if (minorMinHex.length == 3){
        minorMinHex = [@"0" stringByAppendingString:minorMinHex];
    }
    NSString *minorMaxHex = [NSString stringWithFormat:@"%1lx",(unsigned long)minorMaxValue];
    if (minorMaxHex.length == 1) {
        minorMaxHex = [@"000" stringByAppendingString:minorMaxHex];
    }else if (minorMaxHex.length == 2){
        minorMaxHex = [@"00" stringByAppendingString:minorMaxHex];
    }else if (minorMaxHex.length == 3){
        minorMaxHex = [@"0" stringByAppendingString:minorMaxHex];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",@"ea740005",(isOpen ? @"02" : @"01"),minorMinHex,minorMaxHex];
    [self addTaskWithOperationID:mk_taskConfigMinorFilterStateOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configRawAdvDataFilterStatus:(BOOL)isOn
                           whiteList:(BOOL)isOpen
                          rawAdvData:(NSString *)rawAdvData
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        [self addTaskWithOperationID:mk_taskConfigRawAdvDataFilterStatusOperation
                      characteristic:centralManager.peripheral.custom
                         commandData:@"ea53000100"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    if (rawAdvData.length % 2 != 0 || rawAdvData.length == 0
        || rawAdvData.length > 58 || ![MKBLEBaseSDKAdopter checkHexCharacter:rawAdvData]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSInteger len = (rawAdvData.length / 2) + 1;
    NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)len];
    if (lenString.length == 1) {
        lenString = [@"0" stringByAppendingString:lenString];
    }
    
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",@"ea5300",lenString,(isOpen ? @"02" : @"01"),rawAdvData];
    [self addTaskWithOperationID:mk_taskConfigRawAdvDataFilterStatusOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configScanStatus:(BOOL)isOn
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithOperationID:mk_taskConfigScanStatusOperation
                  characteristic:centralManager.peripheral.scanStatus
                     commandData:(isOn ? @"01" : @"00")
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configConnectableStatus:(BOOL)isOn
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithOperationID:mk_taskConfigConnectableStatusOperation
                  characteristic:centralManager.peripheral.connectable
                     commandData:(isOn ? @"01" : @"00")
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configButtonPowerStatus:(BOOL)isOn
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = (isOn ? @"ea38000101" : @"ea38000100");
    [self addTaskWithOperationID:mk_taskConfigButtonPowerStatusOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)powerOffDeviceWithSucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithOperationID:mk_taskConfigPowerOffOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:@"ea260000"
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMovementSensitivity:(NSInteger)sensitivity
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    if (sensitivity < 7 || sensitivity > 255) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *string = [NSString stringWithFormat:@"%1lx",(unsigned long)sensitivity];
    if (string.length == 1) {
        string = [@"0" stringByAppendingString:string];
    }
    NSString *commandString = [@"ea500001" stringByAppendingString:string];
    [self addTaskWithOperationID:mk_taskConfigMovementSensitivityOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configScannWindowInterval:(NSInteger)scanWindowInterval
                     scanInterval:(NSInteger)scanInterval
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    if (scanWindowInterval < 4 || scanWindowInterval > 16384
        || scanInterval < 4 || scanInterval > 16384
        || scanWindowInterval > scanInterval) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *scanWindowHex = [NSString stringWithFormat:@"%1lx",(unsigned long)scanWindowInterval];
    if (scanWindowHex.length == 1) {
        scanWindowHex = [@"000" stringByAppendingString:scanWindowHex];
    }else if (scanWindowHex.length == 2){
        scanWindowHex = [@"00" stringByAppendingString:scanWindowHex];
    }else if (scanWindowHex.length == 3){
        scanWindowHex = [@"0" stringByAppendingString:scanWindowHex];
    }
    NSString *scanIntervalHex = [NSString stringWithFormat:@"%1lx",(unsigned long)scanInterval];
    if (scanIntervalHex.length == 1) {
        scanIntervalHex = [@"000" stringByAppendingString:scanIntervalHex];
    }else if (scanIntervalHex.length == 2){
        scanIntervalHex = [@"00" stringByAppendingString:scanIntervalHex];
    }else if (scanIntervalHex.length == 3){
        scanIntervalHex = [@"0" stringByAppendingString:scanIntervalHex];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"ea700004",scanWindowHex,scanIntervalHex];
    [self addTaskWithOperationID:mk_taskConfigScannWindowOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)factoryDataResetWithPassword:(NSString *)password
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(password) || password.length != 8) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandData = @"";
    for (NSInteger i = 0; i < password.length; i ++) {
        int asciiCode = [password characterAtIndex:i];
        commandData = [commandData stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    [self addTaskWithOperationID:mk_taskConfigFactoryDataResetOperation
                  characteristic:centralManager.peripheral.reset
                     commandData:commandData
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configPassword:(NSString *)password
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(password) || password.length != 8) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandData = @"";
    for (NSInteger i = 0; i < password.length; i ++) {
        int asciiCode = [password characterAtIndex:i];
        commandData = [commandData stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    
    [centralManager addTaskWithTaskID:mk_taskConfigPasswordOperation
                       characteristic:centralManager.peripheral.password
                             resetNum:NO
                          commandData:commandData
                         successBlock:^(id  _Nonnull returnData) {
        NSString *state = returnData[@"result"][@"state"];
        if ([state isEqualToString:@"01"]) {
            [self operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        if (sucBlock) {
            sucBlock();
        }
    }
                         failureBlock:failedBlock];
}

+ (void)clearAllDatasWithSucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithOperationID:mk_taskClearAllDatasOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:@"ea290000"
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)sendVibrationCommandsToDeviceWithSucBlock:(void (^)(void))sucBlock
                                      failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithOperationID:mk_taskSendVibrationCommandsOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:@"ea610000"
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configNumberOfVibrations:(NSInteger)numbers
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    if (numbers < 1 || numbers > 10) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *string = [NSString stringWithFormat:@"%1lx",(unsigned long)numbers];
    if (string.length == 1) {
        string = [@"0" stringByAppendingString:string];
    }
    NSString *commandString = [@"ea720001" stringByAppendingString:string];
    [self addTaskWithOperationID:mk_taskConfigNumberOfVibrationsOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configButtonResetStatus:(BOOL)isOn
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = (isOn ? @"ea75000101" : @"ea75000100");
    [self addTaskWithOperationID:mk_taskConfigButtonResetStatusOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configTrackingDataFormat:(NSInteger)format
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    if (format != 0 && format != 1) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = (format == 0 ? @"ea79000100" : @"ea79000101");
    [self addTaskWithOperationID:mk_taskConfigTrackingDataFormatOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configConnectionNotificationStatus:(BOOL)isOn
                                  sucBlock:(void (^)(void))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock; {
    NSString *commandString = (isOn ? @"ea7a000101" : @"ea7a000100");
    [self addTaskWithOperationID:mk_taskConfigConnectionNotificationStatusOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configLowBatteryReminderRules:(NSInteger)lTwentyInterval
                       lowTenInterval:(NSInteger)lTenInterval
                      lowFiveInterval:(NSInteger)lFiveInterval
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock {
    if (lTwentyInterval < 0 || lTwentyInterval > 120
        || lTenInterval < 0 || lTenInterval > 120
        || lFiveInterval < 0 || lFiveInterval > 120) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *twentyString = [NSString stringWithFormat:@"%1lx",(unsigned long)lTwentyInterval];
    if (twentyString.length == 1) {
        twentyString = [@"0" stringByAppendingString:twentyString];
    }
    NSString *tenString = [NSString stringWithFormat:@"%1lx",(unsigned long)lTenInterval];
    if (tenString.length == 1) {
        tenString = [@"0" stringByAppendingString:tenString];
    }
    NSString *fiveString = [NSString stringWithFormat:@"%1lx",(unsigned long)lFiveInterval];
    if (fiveString.length == 1) {
        fiveString = [@"0" stringByAppendingString:fiveString];
    }
    NSString *commandString = [NSString stringWithFormat:@"ea780003%@%@%@",twentyString,tenString,fiveString];
    [self addTaskWithOperationID:mk_taskConfigLowBatteryReminderRulesOperation
                  characteristic:centralManager.peripheral.custom
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

#pragma mark - task method
+ (void)addTaskWithOperationID:(mk_taskOperationID)operationID
                characteristic:(CBCharacteristic *)characteristic
                   commandData:(NSString *)commandData
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:operationID
                       characteristic:characteristic
                             resetNum:NO
                          commandData:commandData
                         successBlock:^(id  _Nonnull returnData) {
        BOOL success = [returnData[@"result"][@"result"] boolValue];
        if (!success) {
            [self operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        if (sucBlock) {
            sucBlock();
        }
    }
                         failureBlock:failedBlock];
}

#pragma mark - private method
+ (BOOL)validTimeProtocol:(id <MKDeviceTimeProtocol>)protocol{
    if (![protocol conformsToProtocol:@protocol(MKDeviceTimeProtocol)]) {
        return NO;
    }
    if (protocol.year < 2000 || protocol.year > 2099) {
        return NO;
    }
    if (protocol.month < 1 || protocol.month > 12) {
        return NO;
    }
    if (protocol.day < 1 || protocol.day > 31) {
        return NO;
    }
    if (protocol.hour < 0 || protocol.hour > 23) {
        return NO;
    }
    if (protocol.minutes < 0 || protocol.minutes > 59) {
        return NO;
    }
    return YES;
}

+ (NSString *)getTimeString:(id <MKDeviceTimeProtocol>)protocol{
    
    unsigned long yearValue = protocol.year - 2000;
    NSString *yearString = [NSString stringWithFormat:@"%1lx",yearValue];
    if (yearString.length == 1) {
        yearString = [@"0" stringByAppendingString:yearString];
    }
    NSString *monthString = [NSString stringWithFormat:@"%1lx",(long)protocol.month];
    if (monthString.length == 1) {
        monthString = [@"0" stringByAppendingString:monthString];
    }
    NSString *dayString = [NSString stringWithFormat:@"%1lx",(long)protocol.day];
    if (dayString.length == 1) {
        dayString = [@"0" stringByAppendingString:dayString];
    }
    NSString *hourString = [NSString stringWithFormat:@"%1lx",(long)protocol.hour];
    if (hourString.length == 1) {
        hourString = [@"0" stringByAppendingString:hourString];
    }
    NSString *minString = [NSString stringWithFormat:@"%1lx",(long)protocol.minutes];
    if (minString.length == 1) {
        minString = [@"0" stringByAppendingString:minString];
    }
    NSString *secString = [NSString stringWithFormat:@"%1lx",(long)protocol.second];
    if (secString.length == 1) {
        secString = [@"0" stringByAppendingString:secString];
    }
    return [NSString stringWithFormat:@"%@%@%@%@%@%@",yearString,monthString,dayString,hourString,minString,secString];
}

+ (NSString *)fetchTxPower:(mk_trackerTxPower)txPower{
    switch (txPower) {
        case mk_trackerTxPower4dBm:
            return @"04";
            
        case mk_trackerTxPower3dBm:
            return @"03";
            
        case mk_trackerTxPower0dBm:
            return @"00";
            
        case mk_trackerTxPowerNeg4dBm:
            return @"fc";
            
        case mk_trackerTxPowerNeg8dBm:
            return @"f8";
            
        case mk_trackerTxPowerNeg12dBm:
            return @"f4";
            
        case mk_trackerTxPowerNeg16dBm:
            return @"f0";
            
        case mk_trackerTxPowerNeg20dBm:
            return @"ec";
            
        case mk_trackerTxPowerNeg40dBm:
            return @"d8";
    }
}

+ (NSString *)fetchTrackingNotification:(mk_trackingNotification)note {
    switch (note) {
        case mk_closeTrackingNotification:
            return @"00";
        case mk_ledTrackingNotification:
            return @"01";
        case mk_motorTrackingNotification:
            return @"02";
        case mk_ledMotorTrackingNotification:
            return @"03";
    }
}

+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block {
    MKBLEBase_main_safe(^{
        if (block) {
            NSError *error = [MKBLEBaseSDKAdopter getErrorWithCode:-999 message:@"Params error"];
            block(error);
        }
    });
}

+ (void)operationSetParamsErrorBlock:(void (^)(NSError *error))block{
    MKBLEBase_main_safe(^{
        if (block) {
            NSError *error = [MKBLEBaseSDKAdopter getErrorWithCode:-10001 message:@"Set parameter error"];
            block(error);
        }
    });
}

@end
