//
//  MKTrackerDatabaseManager.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/12/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKTrackerDatabaseManager : NSObject

+ (BOOL)initStepDataBase;

+ (void)insertDataList:(NSArray <NSDictionary *>*)dataList
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock;

+ (void)readDataListWithSucBlock:(void (^)(NSArray <NSDictionary *>*dataList))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

+ (BOOL)clearDataTable;

@end

NS_ASSUME_NONNULL_END
