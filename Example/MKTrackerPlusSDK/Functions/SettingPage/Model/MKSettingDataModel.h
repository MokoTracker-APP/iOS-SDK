//
//  MKSettingDataModel.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/12/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKSettingDataModel : NSObject

@property (nonatomic, assign)BOOL buttonOffIsOn;

@property (nonatomic, assign)BOOL connectable;

@property (nonatomic, assign)BOOL connectableNoteIsOn;

@property (nonatomic, assign)BOOL buttonResetIsOn;

- (void)startReadDataWithSucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
