//
//  MKTrackerConfigDataModel.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKTrackerConfigDataModel : NSObject

@property (nonatomic, assign)BOOL scanStatus;

@property (nonatomic, copy)NSString *scanWindow;

@property (nonatomic, copy)NSString *scanInterval;

@property (nonatomic, copy)NSString *trackingTrigger;

@property (nonatomic, copy)NSString *trackingInterval;

/// 0:储存提醒关闭,1:打开LED提醒；2:打开马达提醒；3:LED和马达提醒都打开；
@property (nonatomic, assign)NSInteger trackingNote;

/// 震动次数
@property (nonatomic, assign)NSInteger vibNubmer;

/// 0:short,1:long
@property (nonatomic, assign)NSInteger format;

- (void)startReadDataWithSucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

- (void)startConfigDataWithSucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
