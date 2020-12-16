//
//  MKTrackingIntervalCell.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/28.
//

#import "MKBaseCell.h"
#import "MKScannerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKTrackingIntervalCell : MKBaseCell

@property (nonatomic, copy)NSString *interval;

@property (nonatomic, weak)id <MKScannerDelegate>delegate;

+ (MKTrackingIntervalCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
