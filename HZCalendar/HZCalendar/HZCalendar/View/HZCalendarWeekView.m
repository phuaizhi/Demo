//
//  HZCalendarWeekView.m
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import "HZCalendarWeekView.h"
#import "UIView+HZFrame.h"

@interface HZCalendarWeekView()

/**
 保存星期
 */
@property (strong, nonatomic) NSArray *weekArray;

@end

@implementation HZCalendarWeekView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    
    CGFloat itemWidth = self.hz_width / self.weekArray.count;
    
    for (NSInteger i = 0; i < self.weekArray.count; i++) {
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*itemWidth, 0, itemWidth, self.hz_height)];
        weekLabel.text = self.weekArray[i];
        weekLabel.textAlignment = NSTextAlignmentCenter;
        weekLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:weekLabel];
    }
}

- (NSArray *)weekArray {
    if (_weekArray == nil) {
        _weekArray = @[@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
    }
    return _weekArray;
}


@end
