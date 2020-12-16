//
//  MKUpdatePageCell.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/12/2.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKUpdatePageCell : MKBaseCell

@property (nonatomic, strong, readonly)UILabel *msgLabel;

+ (MKUpdatePageCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
