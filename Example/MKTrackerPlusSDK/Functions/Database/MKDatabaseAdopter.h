//
//  MKDatabaseAdopter.h
//  MKHomePage
//
//  Created by aa on 2018/9/26.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKDatabaseAdopter : NSObject

+ (void)operationFailedBlock:(void (^)(NSError *error))block msg:(NSString *)msg;
+ (void)operationInsertFailedBlock:(void (^)(NSError *error))block;
+ (void)operationUpdateFailedBlock:(void (^)(NSError *error))block;
+ (void)operationDeleteFailedBlock:(void (^)(NSError *error))block;
+ (void)operationGetDataFailedBlock:(void (^)(NSError *error))block;

@end
