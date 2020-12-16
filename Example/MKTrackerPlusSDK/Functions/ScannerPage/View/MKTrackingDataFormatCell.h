//
//  MKTrackingDataFormatCell.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/28.
//

#import "MKBaseCell.h"
#import "MKScannerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKTrackingDataFormatCell : MKBaseCell

@property (nonatomic, assign)NSInteger formatType;

@property (nonatomic, weak)id <MKScannerDelegate>delegate;

+ (MKTrackingDataFormatCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
