//
//  MKTrackerAdopter.m
//  MKContactTracker
//
//  Created by aa on 2020/4/27.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKTrackerAdopter.h"

#import <MKBLEBaseModule/MKBLEBaseSDKAdopter.h>

@implementation MKTrackerAdopter

+ (NSDictionary *)parseDateString:(NSString *)date {
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([MKBLEBaseSDKAdopter getDecimalWithHex:date range:NSMakeRange(0, 2)] + 2000)];
    NSString *month = [MKBLEBaseSDKAdopter getDecimalStringWithHex:date range:NSMakeRange(2, 2)];
    if (month.length == 1) {
        month = [@"0" stringByAppendingString:month];
    }
    NSString *day = [MKBLEBaseSDKAdopter getDecimalStringWithHex:date range:NSMakeRange(4, 2)];
    if (day.length == 1) {
        day = [@"0" stringByAppendingString:day];
    }
    NSString *hour = [MKBLEBaseSDKAdopter getDecimalStringWithHex:date range:NSMakeRange(6, 2)];
    if (hour.length == 1) {
        hour = [@"0" stringByAppendingString:hour];
    }
    NSString *min = [MKBLEBaseSDKAdopter getDecimalStringWithHex:date range:NSMakeRange(8, 2)];
    if (min.length == 1) {
        min = [@"0" stringByAppendingString:min];
    }
    NSString *second = [MKBLEBaseSDKAdopter getDecimalStringWithHex:date range:NSMakeRange(10, 2)];
    if (second.length == 1) {
        second = [@"0" stringByAppendingString:second];
    }
    return @{
        @"year":year,
        @"month":month,
        @"day":day,
        @"hour":hour,
        @"minute":min,
        @"second":second,
    };
}

+ (NSArray *)parseScannerTrackedData:(NSString *)content {
    
    NSInteger index = 0;
    NSMutableArray *dataList = [NSMutableArray array];
    for (NSInteger i = 0; i < content.length; i ++) {
        if (index >= content.length) {
            break;
        }
        NSInteger subLen = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(index, 2)];
        index += 2;
        NSString *subContent = [content substringWithRange:NSMakeRange(index, subLen * 2)];
        NSDictionary *dateDic = [self parseDateString:[subContent substringWithRange:NSMakeRange(0, 12)]];
        NSString *tempMac = [[subContent substringWithRange:NSMakeRange(12, 12)] uppercaseString];
        NSString *macAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",
                                [tempMac substringWithRange:NSMakeRange(10, 2)],
                                [tempMac substringWithRange:NSMakeRange(8, 2)],
                                [tempMac substringWithRange:NSMakeRange(6, 2)],
                                [tempMac substringWithRange:NSMakeRange(4, 2)],
                                [tempMac substringWithRange:NSMakeRange(2, 2)],
                                [tempMac substringWithRange:NSMakeRange(0, 2)]];
        NSNumber *rssi = [MKBLEBaseSDKAdopter signedHexTurnString:[subContent substringWithRange:NSMakeRange(24, 2)]];
        NSString *rawData = [subContent substringFromIndex:26];
        index += subLen * 2;
        NSDictionary *dic = @{
            @"dateDic":dateDic,
            @"macAddress":macAddress,
            @"rssi":rssi,
            @"rawData":rawData,
        };
        [dataList addObject:dic];
    }
    return dataList;
}

@end
