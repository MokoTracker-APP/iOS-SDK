//
//  MKLowPowerNoteConfigView.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLowPowerNoteConfigView : UIView

/// 设置低电量提醒
/// @param twentyValue Battery power less than 20%.
/// @param tenValue Battery power less than 10%.
/// @param fiveValue Battery power less than 5%.
/// @param block block
- (void)showViewWithValue:(NSInteger)twentyValue
                 tenValue:(NSInteger)tenValue
                fiveValue:(NSInteger)fiveValue
            completeBlock:(void (^)(NSInteger twentyResultValue,NSInteger tenResultValue,NSInteger fiveResultValue))block;

@end

NS_ASSUME_NONNULL_END
