//
//  MKTrackingConfigCellModel.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKTrackingConfigCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *textValue;

@property (nonatomic, copy)NSString *placeHolder;

@property (nonatomic, copy)NSString *detailMsg;

@property (nonatomic, assign)BOOL isNoteMsgCell;

@property (nonatomic, assign)NSInteger index;

@end

NS_ASSUME_NONNULL_END
