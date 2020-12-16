//
//  MKTrackingConfigCell.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/28.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MKTrackingConfigCellModel;

@protocol MKTrackingConfigCellDelegate <NSObject>

- (void)trackerParamsValueChanged:(NSString *)value index:(NSInteger)index;

@end

@interface MKTrackingConfigCell : MKBaseCell

@property (nonatomic, strong)MKTrackingConfigCellModel *dataModel;

@property (nonatomic, weak)id <MKTrackingConfigCellDelegate>delegate;

+ (MKTrackingConfigCell *)initCellWithTableView:(UITableView *)tableView;

+ (CGFloat)getCellHeight:(NSString *)noteMsg;

@end

NS_ASSUME_NONNULL_END
