//
//  HZCalendarView.h
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectCalendarDayBlock)(NSInteger year,NSInteger month,NSInteger day);

@interface HZCalendarView : UIView

@property (copy, nonatomic) SelectCalendarDayBlock selectCalendarDay;

@end

NS_ASSUME_NONNULL_END
