//
//  MKSettingTextCellModel.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKSettingTextCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

/// 点击产生的方法名字
@property (nonatomic, copy)NSString *tapSelector;

@end

NS_ASSUME_NONNULL_END
