//
//  MKDeviceTypeManager.h
//  MKContactTracker
//
//  Created by aa on 2020/6/30.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceTypeManager : NSObject

/// 设备类型,04:不带3轴和Flash,05:只带3轴,06:只带Flash,07:同时带3轴和Flash
@property (nonatomic, copy, readonly)NSString *deviceType;

/// deviceType为05和07的支持3轴传感器触发设置
@property (nonatomic, assign, readonly)BOOL supportAdvTrigger;

/// 当前连接密码
@property (nonatomic, copy, readonly)NSString *password;

/// 电池电量百分比
@property (nonatomic, copy, readonly)NSString *batteryPercent;

+ (MKDeviceTypeManager *)shared;

- (void)connectTracker:(MKTrackerModel *)trackerModel
              password:(NSString *)password
         completeBlock:(void (^)(NSError *error))completeBlock;

@end

NS_ASSUME_NONNULL_END
