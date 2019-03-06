//
//  HZCalendarModel.h
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZCalendarModel : NSObject

@property (assign, nonatomic) NSInteger totalDays; // 当前月的天数
@property (assign, nonatomic) NSInteger firstWeekday; // 标示第一天是星期几（0代表周日，1代表周一，以此类推）
@property (assign, nonatomic) NSInteger year;  // 所属年份
@property (assign, nonatomic) NSInteger month; // 当前月份
@property (assign, nonatomic) NSInteger day;   // 每天所在的位置

@property (assign, nonatomic) BOOL isLastMonth; // 属于上个月的
@property (assign, nonatomic) BOOL isNextMonth; // 属于下个月的
@property (assign, nonatomic) BOOL isCurrentMonth; // 属于当月
@property (assign, nonatomic) BOOL isToday; // 今天
@property (assign, nonatomic) BOOL isSelected; // 是否被选中


@end

NS_ASSUME_NONNULL_END
