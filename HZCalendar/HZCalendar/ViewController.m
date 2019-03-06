//
//  ViewController.m
//  HZCalendar
//
//  Created by mac on 2019/3/4.
//  Copyright © 2019 mac. All rights reserved.
//  本demo旨在设计一个选择查看的日历  支持自定义功能
//

#import "ViewController.h"
#import "HZCalendarView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat Wscreen = [UIScreen mainScreen].bounds.size.width;
    
    HZCalendarView *calendarView = [[HZCalendarView alloc] initWithFrame:CGRectMake(20, 80, Wscreen-40, 0)];
    [self.view addSubview:calendarView];
    calendarView.selectCalendarDay = ^(NSInteger year, NSInteger month, NSInteger day) {
        NSLog(@"选择:%ld年%ld月%ld日",year,month,day);
    };
}


@end
