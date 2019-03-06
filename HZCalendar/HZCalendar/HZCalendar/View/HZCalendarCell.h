//
//  HZCalendarCell.h
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZCalendarModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZCalendarCell : UICollectionViewCell

@property (strong, nonatomic) HZCalendarModel *calendarModel;

@end

NS_ASSUME_NONNULL_END
