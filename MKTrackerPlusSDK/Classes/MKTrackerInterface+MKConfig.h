//
//  MKTrackerInterface+MKConfig.h
//  MKContactTracker
//
//  Created by aa on 2020/4/27.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKTrackerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKDeviceTimeProtocol <NSObject>

@property (nonatomic, assign)NSInteger year;

@property (nonatomic, assign)NSInteger month;

@property (nonatomic, assign)NSInteger day;

@property (nonatomic, assign)NSInteger hour;

@property (nonatomic, assign)NSInteger minutes;

@property (nonatomic, assign)NSInteger second;

@end

typedef NS_ENUM(NSInteger, mk_trackerTxPower) {
    mk_trackerTxPower4dBm,       //RadioTxPower:4dBm
    mk_trackerTxPower3dBm,       //3dBm
    mk_trackerTxPower0dBm,       //0dBm
    mk_trackerTxPowerNeg4dBm,    //-4dBm
    mk_trackerTxPowerNeg8dBm,    //-8dBm
    mk_trackerTxPowerNeg12dBm,   //-12dBm
    mk_trackerTxPowerNeg16dBm,   //-16dBm
    mk_trackerTxPowerNeg20dBm,   //-20dBm
    mk_trackerTxPowerNeg40dBm,   //-40dBm
};

typedef NS_ENUM(NSInteger, mk_trackingNotification) {
    mk_closeTrackingNotification,
    mk_ledTrackingNotification,
    mk_motorTrackingNotification,
    mk_ledMotorTrackingNotification,
};

@interface MKTrackerInterface (MKConfig)

/// Configure device time
/// @param protocol protocol
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configDeviceTime:(id <MKDeviceTimeProtocol>)protocol
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the broadcast name of the device
/// @param deviceName 1 ~ 10 length ASCII code characters
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configDeviceName:(NSString *)deviceName
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure iBeacon UUID
/// @param uuid uuid
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configProximityUUID:(NSString *)uuid
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure iBeacon Major
/// @param major 0~65535
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMajor:(NSInteger)major
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure iBeacon Minor
/// @param minor 0~65535
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMinor:(NSInteger)minor
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock;

/// Advertising interval
/// @param interval Advertising interval, unit: 100ms, range: 1~100
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configAdvInterval:(NSInteger)interval
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure Measured Power
/// @param measuredPower (RSSI@1M),-127~0
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMeasuredPower:(NSInteger)measuredPower
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure Tx Power
/// @param txPower Tx Power
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configTxPower:(mk_trackerTxPower)txPower
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock;

/// Close the current broadcast trigger state
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)closeAdvTriggerConditionsWithSucBlock:(void (^)(void))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Set how long Beacon will stop broadcasting after stopping, and start broadcasting when Beacon moves again.
/// @param time 0 ~ 65535 ,units:S
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configAdvTrigger:(NSInteger)time
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure device data storage interval
/// @param interval 0 mins ~ 255 mins
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configStorageInterval:(NSInteger)interval
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure Tracking Notification
/// @param note Tracking Notification
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configTrackingNotification:(mk_trackingNotification)note
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

/// Set how long Beacon will stop scanning after stopping, and start scanning when Beacon moves again.
/// @param time 0 ~ 65535 ,units:S.if time's value is 0,close the current scanning trigger state.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configScanningTrigger:(NSInteger)time
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the current stored RSSI condition, and store it once when the master scans to the slave signal strength is greater than or equal to this value.
/// @param rssi -127 ~ 0
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configStorageRssi:(NSInteger)rssi
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

/// Turn off this option, the Beacon will store all types of BLE ADV data.Turn on this option, the Beacon will store the corresponding ADV data according to the filtering rules.
/// @param isOn isOn
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configAdvDataFilterStatus:(BOOL)isOn
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current MAC address filtering conditions
/// @param isOn Whether to enable mac address filtering
/// @param isOpen Whether to enable reverse filtering. The mac scanned after the reverse filter is turned on is not saved.
/// @param mac The mac address to be filtered. If isOn = NO, the item can be omitted. If isOn = YES, the mac address with a maximum length of 12 characters must be filled in.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMacFilterStatus:(BOOL)isOn
                    whiteList:(BOOL)isOpen
                          mac:(NSString *)mac
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current advertising name filtering conditions
/// @param isOn Whether to enable advertising name filtering
/// @param isOpen Whether to enable reverse filtering. The advertising name scanned after the reverse filter is turned on is not saved.
/// @param advName The advertising name to be filtered. If isOn = NO, the item can be omitted. If isOn = YES, the advertising name with a maximum length of 10 characters must be filled in.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configAdvNameFilterStatus:(BOOL)isOn
                        whiteList:(BOOL)isOpen
                          advName:(NSString *)advName
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current proximity UUID filtering conditions
/// @param isOn Whether to enable proximity UUID filtering
/// @param isOpen Whether to enable reverse filtering. The proximity UUID scanned after the reverse filter is turned on is not saved.
/// @param uuid The proximity UUID to be filtered. If isOn = NO, the item can be omitted. 
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configProximityUUIDFilterStatus:(BOOL)isOn
                              whiteList:(BOOL)isOpen
                                   uuid:(NSString *)uuid
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current major filtering conditions.
/// @param isOn Whether to enable major filtering
/// @param isOpen Whether to enable reverse filtering. The major scanned after the reverse filter is turned on is not saved.
/// @param majorMinValue Major minimum value to be filtered. This value is invalid when isOn = NO.0~65535 && majorMinValue<=majorMaxValue
/// @param majorMaxValue The maximum value of Major to be filtered. This value is invalid when isOn = NO.0~65535 && majorMinValue<=majorMaxValue
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMajorFilterStatus:(BOOL)isOn
                      whiteList:(BOOL)isOpen
                  majorMinValue:(NSInteger)majorMinValue
                  majorMaxValue:(NSInteger)majorMaxValue
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current minor filtering conditions.
/// @param isOn Whether to enable minor filtering
/// @param isOpen Whether to enable reverse filtering. The minor scanned after the reverse filter is turned on is not saved.
/// @param minorMinValue Minor minimum value to be filtered. This value is invalid when isOn = NO.0~65535 && minorMinValue<=minorMaxValue
/// @param minorMaxValue The maximum value of Minor to be filtered. This value is invalid when isOn = NO.0~65535 && minorMinValue<=minorMaxValue
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMinorFilterStatus:(BOOL)isOn
                      whiteList:(BOOL)isOpen
                  minorMinValue:(NSInteger)minorMinValue
                  minorMaxValue:(NSInteger)minorMaxValue
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current raw advertising data filtering conditions.
/// @param isOn Whether to enable raw advertising data filtering
/// @param isOpen Whether to enable reverse filtering. The raw advertising data scanned after the reverse filter is turned on is not saved.
/// @param rawAdvData The raw advertising data to be filtered. If isOn = NO, the item can be omitted. If isOn = YES, the raw advertising data with a maximum length of 29 bytes must be filled in.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configRawAdvDataFilterStatus:(BOOL)isOn
                           whiteList:(BOOL)isOpen
                          rawAdvData:(NSString *)rawAdvData
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the scan status of the device.
/// @param isOn isOn
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configScanStatus:(BOOL)isOn
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the connectable status of the device.
/// @param isOn isOn
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configConnectableStatus:(BOOL)isOn
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the current key switch status.
/// @param isOn isOn
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configButtonPowerStatus:(BOOL)isOn
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// power off.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)powerOffDeviceWithSucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the device to determine the mobile sensitivity.The larger the value, the more sensitive Beacon judges the movement.
/// @param sensitivity 7~255
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMovementSensitivity:(NSInteger)sensitivity
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// The scan duration of every 1000ms
/// @param scanWindowInterval scan window interval ,4~16384,unit:0.625ms
/// @param scanInterval scan interval,4~16384,unit:0.625ms.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configScannWindowInterval:(NSInteger)scanWindowInterval
                     scanInterval:(NSInteger)scanInterval
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// Resetting to factory state (RESET).NOTE:When resetting the device, the connection password will not be restored which shall remain set to its current value.
/// @param password 8-character ascii code characters
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)factoryDataResetWithPassword:(NSString *)password
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the device's connection password.
/// @param password 8-character ascii code characters
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configPassword:(NSString *)password
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock;

/// Clear historical data stored on the device.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)clearAllDatasWithSucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// Send vibration commands to the device.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)sendVibrationCommandsToDeviceWithSucBlock:(void (^)(void))sucBlock
                                      failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the current motor vibration times.
/// @param numbers 1~10
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configNumberOfVibrations:(NSInteger)numbers
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;
 
+ (void)configButtonResetStatus:(BOOL)isOn
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure whether the device saves the Raw Data state.
/// @param format 0:Not Save.1:Save
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configTrackingDataFormat:(NSInteger)format
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

/// Config connection reminder status.Config whether the LED and motor reminders are turned on when the current device is connected by the app.
/// @param isOn YES:Turn on the LED and motor reminder when the current device is connected by the app.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configConnectionNotificationStatus:(BOOL)isOn
                                  sucBlock:(void (^)(void))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure low battery reminder rules.
/// @param lTwentyInterval The time interval indicated by the LED when the power of the device is less than 20%. If it is 0, it means there is no reminder if the battery is below this level.Range:0~120
/// @param lTenInterval The time interval indicated by the LED when the power of the device is less than 10%. If it is 0, it means there is no reminder if the battery is below this level.Range:0~120
/// @param lFiveInterval The time interval indicated by the LED when the power of the device is less than 5%. If it is 0, it means there is no reminder if the battery is below this level.Range:0~120
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configLowBatteryReminderRules:(NSInteger)lTwentyInterval
                       lowTenInterval:(NSInteger)lTenInterval
                      lowFiveInterval:(NSInteger)lFiveInterval
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
