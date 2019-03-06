//
//  HZCalendarCell.m
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import "HZCalendarCell.h"
#import "UIView+HZFrame.h"

@interface  HZCalendarCell ()

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;


@end

@implementation HZCalendarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.dayLabel.layer.cornerRadius = self.dayLabel.hz_width / 2;
    self.dayLabel.clipsToBounds = YES;
}

- (void)setCalendarModel:(HZCalendarModel *)calendarModel {
    _calendarModel = calendarModel;
    self.dayLabel.text = [NSString stringWithFormat:@"%ld",calendarModel.day];
    // 显示上个月跟下个月的但是不能选择
    if (calendarModel.isLastMonth || calendarModel.isNextMonth) {
        self.userInteractionEnabled = NO;
        self.dayLabel.textColor = [UIColor lightGrayColor];
        self.dayLabel.backgroundColor = [UIColor clearColor];
    } else {
        self.userInteractionEnabled = YES;
        // 当前月的
        self.dayLabel.textColor = [UIColor blackColor];
        self.dayLabel.backgroundColor = [UIColor clearColor];
        if (calendarModel.isSelected) {
            self.dayLabel.textColor = [UIColor whiteColor];
            self.dayLabel.backgroundColor = [UIColor blueColor];
        }
        if (calendarModel.isToday) {
            self.dayLabel.textColor = [UIColor whiteColor];
            self.dayLabel.backgroundColor = [UIColor redColor];
        }
    }
}

@end
