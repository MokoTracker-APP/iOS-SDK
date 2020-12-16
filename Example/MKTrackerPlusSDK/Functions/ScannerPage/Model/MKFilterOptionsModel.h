//
//  MKFilterOptionsModel.h
//  MKContactTracker
//
//  Created by aa on 2020/4/24.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKFilterOptionsModel : NSObject

@property (nonatomic, assign)NSInteger rssiValue;

@property (nonatomic, assign)BOOL advDataFilterIson;

@property (nonatomic, assign)BOOL macIson;

@property (nonatomic, assign)BOOL macWhiteListIson;

@property (nonatomic, copy)NSString *macValue;

@property (nonatomic, assign)BOOL advNameIson;

@property (nonatomic, assign)BOOL advNameWhiteListIson;

@property (nonatomic, copy)NSString *advNameValue;

@property (nonatomic, assign)BOOL uuidIson;

@property (nonatomic, assign)BOOL uuidWhiteListIson;

@property (nonatomic, copy)NSString *uuidValue;

@property (nonatomic, assign)BOOL majorIson;

@property (nonatomic, assign)BOOL majorWhiteListIson;

/// 过滤的Major可以是一个范围值
@property (nonatomic, copy)NSString *majorMaxValue;

/// 过滤的Major可以是一个范围值
@property (nonatomic, copy)NSString *majorMinValue;

@property (nonatomic, assign)BOOL minorIson;

@property (nonatomic, assign)BOOL minorWhiteListIson;

//过滤的Minor可以是一个范围值
@property (nonatomic, copy)NSString *minorMaxValue;

//过滤的Minor可以是一个范围值
@property (nonatomic, copy)NSString *minorMinValue;

@property (nonatomic, assign)BOOL rawDataIson;

@property (nonatomic, assign)BOOL rawDataWhiteListIson;

@property (nonatomic, copy)NSString *rawDataValue;

- (void)startReadDataWithSucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

- (void)startConfigDataWithSucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
