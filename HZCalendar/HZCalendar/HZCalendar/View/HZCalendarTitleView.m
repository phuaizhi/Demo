//
//  HZCalendarTitleView.m
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import "HZCalendarTitleView.h"
#import "UIView+HZFrame.h"

@interface HZCalendarTitleView ()

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation HZCalendarTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    UIButton *previousButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, 50, 50)];
    [previousButton setImage:[UIImage imageNamed:@"previousButton"] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(handPreviousCalendarViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:previousButton];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, self.hz_width-200, 50)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.titleLabel];
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.hz_width-100, 0, 50, 50)];
    [nextButton setImage:[UIImage imageNamed:@"nextButton"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(handNextCalendarViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
}

- (void)setTitleString:(NSString *)titleString {
    _titleString = [titleString copy];
    self.titleLabel.text = titleString;
}


#pragma mark - 按钮的点击事件

- (void)handPreviousCalendarViewAction:(UIButton *)sender {
    if (self.handPreviousCalendarView) {
        self.handPreviousCalendarView();
    }
}

- (void)handNextCalendarViewAction:(UIButton *)sender {
    if (self.handNextCalendarView) {
        self.handNextCalendarView();
    }
}

@end
