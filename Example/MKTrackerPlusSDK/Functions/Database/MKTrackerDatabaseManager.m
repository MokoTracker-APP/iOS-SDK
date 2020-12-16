//
//  MKTrackerDatabaseManager.m
//  MKEnhancedTracker
//
//  Created by aa on 2020/12/1.
//

#import "MKTrackerDatabaseManager.h"
#import <FMDB/FMDB.h>
#import "MKDatabaseAdopter.h"

@implementation MKTrackerDatabaseManager

+ (BOOL)initStepDataBase {
    FMDatabase* db = [FMDatabase databaseWithPath:kFilePath(@"trackerDB")];
    if (![db open]) {
        return NO;
    }
    NSString *sqlCreateTable = [NSString stringWithFormat:@"create table if not exists trackerTable (year text,month text,day integer,hour text,minute text,second text,macAddress text,rawData text,rssi text)"];
    BOOL resCreate = [db executeUpdate:sqlCreateTable];
    if (!resCreate) {
        [db close];
        return NO;
    }
    return YES;
}

+ (void)insertDataList:(NSArray <NSDictionary *>*)dataList
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock {
    if (!dataList) {
        [MKDatabaseAdopter operationInsertFailedBlock:failedBlock];
        return ;
    }
    FMDatabase* db = [FMDatabase databaseWithPath:kFilePath(@"trackerDB")];
    if (![db open]) {
        [MKDatabaseAdopter operationInsertFailedBlock:failedBlock];
        return;
    }
    NSString *sqlCreateTable = [NSString stringWithFormat:@"create table if not exists trackerTable (year text,month text,day integer,hour text,minute text,second text,macAddress text,rawData text,rssi text)"];
    BOOL resCreate = [db executeUpdate:sqlCreateTable];
    if (!resCreate) {
        [db close];
        [MKDatabaseAdopter operationInsertFailedBlock:failedBlock];
        return;
    }
    [[FMDatabaseQueue databaseQueueWithPath:kFilePath(@"trackerDB")] inDatabase:^(FMDatabase *db) {
        for (NSDictionary *dic in dataList) {
            [db executeUpdate:@"INSERT INTO trackerTable (year, month, day, hour, minute, second, macAddress, rawData, rssi) VALUES (?,?,?,?,?,?,?,?,?)",SafeStr(dic[@"dateDic"][@"year"]),SafeStr(dic[@"dateDic"][@"month"]),SafeStr(dic[@"dateDic"][@"day"]),SafeStr(dic[@"dateDic"][@"hour"]),SafeStr(dic[@"dateDic"][@"minute"]),SafeStr(dic[@"dateDic"][@"second"]),SafeStr(dic[@"macAddress"]),SafeStr(dic[@"rawData"]),SafeStr(dic[@"rssi"])];
        }
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock();
            });
        }
        [db close];
    }];
}

+ (void)readDataListWithSucBlock:(void (^)(NSArray <NSDictionary *>*dataList))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    FMDatabase* db = [FMDatabase databaseWithPath:kFilePath(@"trackerDB")];
    if (![db open]) {
        [MKDatabaseAdopter operationGetDataFailedBlock:failedBlock];
        return;
    }
    [[FMDatabaseQueue databaseQueueWithPath:kFilePath(@"trackerDB")] inDatabase:^(FMDatabase *db) {
        NSMutableArray *tempDataList = [NSMutableArray array];
        FMResultSet * result = [db executeQuery:@"SELECT * FROM trackerTable"];
        while ([result next]) {
            NSDictionary *dateDic = @{
                                  @"year":[result stringForColumn:@"year"],
                                  @"month":[result stringForColumn:@"month"],
                                  @"day":[result stringForColumn:@"day"],
                                  @"hour":[result stringForColumn:@"hour"],
                                  @"minute":[result stringForColumn:@"minute"],
                                  @"second":[result stringForColumn:@"second"],
                                  };
            NSDictionary *resultDic = @{
                @"dateDic":dateDic,
                @"macAddress":[result stringForColumn:@"macAddress"],
                @"rawData":[result stringForColumn:@"rawData"],
                @"rssi":[result stringForColumn:@"rssi"],
            };
            [tempDataList addObject:resultDic];
        }
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock(tempDataList);
            });
        }
        [db close];
    }];
}

+ (BOOL)clearDataTable {
    FMDatabase* db = [FMDatabase databaseWithPath:kFilePath(@"trackerDB")];
    if ([db open]) {
        BOOL success = [db executeUpdate:@"DELETE FROM trackerTable"];
        [db close];
        return success;
    }
    return NO;
}

@end
