//
//  HZCalendarTitleView.h
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HandlePreviousCalendarViewBlock)(void);

typedef void(^HandleNextCalendarViewBlock)(void);

@interface HZCalendarTitleView : UIView

@property (copy, nonatomic) HandlePreviousCalendarViewBlock handPreviousCalendarView;

@property (copy, nonatomic) HandleNextCalendarViewBlock handNextCalendarView;

@property (copy, nonatomic) NSString *titleString;

@end

NS_ASSUME_NONNULL_END
