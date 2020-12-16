//
//  MKSettingTextCell.h
//  MKEnhancedTracker
//
//  Created by aa on 2020/11/30.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKSettingTextCellDelegate <NSObject>

/// cell点击事件
/// @param method 点击之后触发的方法名称
- (void)settingTextCellSelected:(NSString *)method indexPath:(NSIndexPath *)indexPath;

@end

@class MKSettingTextCellModel;
@interface MKSettingTextCell : MKBaseCell

@property (nonatomic, strong)MKSettingTextCellModel *dataModel;

@property (nonatomic, weak)id <MKSettingTextCellDelegate>delegate;

+ (MKSettingTextCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
