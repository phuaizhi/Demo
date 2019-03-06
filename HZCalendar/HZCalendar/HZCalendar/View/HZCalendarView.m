//
//  HZCalendarView.m
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import "HZCalendarView.h"
#import "HZCalendarWeekView.h"
#import "HZCalendarTitleView.h"
#import "UIView+HZFrame.h"
#import "NSDate+HZCalendarMethod.h"
#import "HZCalendarCell.h"

@interface HZCalendarView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) HZCalendarWeekView  *calendarWeekView;
@property (strong, nonatomic) HZCalendarTitleView *calendarTitleView;
@property (strong, nonatomic) NSMutableArray      *dataArray;
/**
 当月的日期
 */
@property (strong, nonatomic) NSDate *currentDate;
/**
  左滑手势
 */
@property (strong, nonatomic) UISwipeGestureRecognizer *leftSwipe;
/**
 右滑手势
 */
@property (strong, nonatomic) UISwipeGestureRecognizer *rightSwipe;

/**
 日历视图
 */
@property (strong, nonatomic) UICollectionView *collectionView;

/**
 记录选择的那一天 一次只能选择一天
 */
@property (strong, nonatomic) HZCalendarModel *selectModel;

@end

@implementation HZCalendarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.currentDate = [NSDate date];
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    [self addSubview:self.calendarTitleView];
    [self addSubview:self.calendarWeekView];
    
    __weak typeof(self) weakSelf = self;
    self.calendarTitleView.handPreviousCalendarView = ^{
        NSLog(@"前一个月");
        [weakSelf rightSlide];
    };
    self.calendarTitleView.handNextCalendarView = ^{
        NSLog(@"下一个月");
        [weakSelf leftSlide];
    };
    
    [self addSubview:self.collectionView];
    
    self.hz_height = self.collectionView.hz_bottom;
    
    // 添加左滑右滑手势
    self.leftSwipe =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
    self.leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.collectionView addGestureRecognizer:self.leftSwipe];
    
    self.rightSwipe =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
    self.rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.collectionView addGestureRecognizer:self.rightSwipe];
    
    [self getData];
}

#pragma mark - 左滑手势

- (void)leftSwipe:(UISwipeGestureRecognizer *)swipe {
    
    [self leftSlide];
}
- (void)leftSlide{
    self.currentDate = [self.currentDate nextMonthDate];
    [self performAnimations:kCATransitionFromRight];
    
    [self getData];
}

#pragma mark - 右滑手势

- (void)rightSwipe:(UISwipeGestureRecognizer *)swipe {
    
    [self rightSlide];
}

- (void)rightSlide{
    
    self.currentDate = [self.currentDate previousMonthDate];
    [self performAnimations:kCATransitionFromLeft];
    
    [self getData];
}

#pragma mark - 动画处理

- (void)performAnimations:(NSString *)transition {
    CATransition *catransition = [CATransition animation];
    catransition.duration = 0.5;
    [catransition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    catransition.type = kCATransitionPush; //choose your animation
    catransition.subtype = transition;
    [self.collectionView.layer addAnimation:catransition forKey:nil];
}

#pragma mark - 数据加载

- (void)getData {
    // 刷新数据前清空数据
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    self.calendarTitleView.titleString = [NSString stringWithFormat:@"%ld年%02ld月",[self.currentDate dateYear],(long)[self.currentDate dateMonth]];
    // 上一个日期 获取上个月的总天数
    NSDate *previous = [self.currentDate previousMonthDate];
    NSInteger previousTotalDays = [previous totalDaysInMonth];
    
    // 整个方格为6x7 将model作为每天数据属性存起来
    for (NSInteger i=0; i<42; i++) {
        HZCalendarModel *model = [[HZCalendarModel alloc] init];
        model.totalDays = [self.currentDate totalDaysInMonth];
        model.firstWeekday = [self.currentDate firstWeekDayInMonth];
        model.year = [self.currentDate dateYear];
        model.month = [self.currentDate dateMonth];
        
        // 计算上个月的
        if (i < model.firstWeekday) {
            // 公历中周日为1 但是这里已做过处理周日为0 周一为1
            // model.firstWeekday - i 代表上月遗留下来的共有几天
            // 多加一是为了计算日期 最后一天跟第一天相差1 但是显示的时候要为最后一天(要把减的1加回来)
            model.day = previousTotalDays - (model.firstWeekday - i) + 1;
            model.isLastMonth = YES;
        } else if (i >= model.firstWeekday && i < model.firstWeekday+model.totalDays) {
            // 当月的日期
            model.day = i - model.firstWeekday + 1;
            model.isCurrentMonth = YES;
            // 判断是否是今天
            if (model.year == [NSDate date].dateYear && model.month == [NSDate date].dateMonth) {
                if ([NSDate date].dateDay == model.day) {
                    model.isToday = YES;
                }
            }
        } else {
            // 下个月
            model.day = i - model.firstWeekday + 1 - model.totalDays;
            model.isNextMonth = YES;
        }
        // 记录之前选中的那一天
        [self.dataArray enumerateObjectsUsingBlock:^(HZCalendarModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.selectModel.year == model.year && self.selectModel.month == model.month && self.selectModel.day == model.day) {
                model.isSelected = YES;
            }
        }];
        
        [self.dataArray addObject:model];
        [self.collectionView reloadData];
    }
}

#pragma mark - delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIndentifier = @"cell";
    HZCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIndentifier forIndexPath:indexPath];
    if (!cell) {
        cell =[[HZCalendarCell alloc]init];
    }
    cell.calendarModel = self.dataArray[indexPath.row];
    cell.backgroundColor =[UIColor whiteColor];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HZCalendarModel *model = self.dataArray[indexPath.row];
    model.isSelected = YES;
    self.selectModel = model;
    // 将之前的选择状态取消
    [self.dataArray enumerateObjectsUsingBlock:^(HZCalendarModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != model) {
            obj.isSelected = NO;
        }
    }];
    if (self.selectCalendarDay) {
        self.selectCalendarDay(model.year, model.month, model.day);
    }
    [collectionView reloadData];
}

#pragma mark - 懒加载

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flow =[[UICollectionViewFlowLayout alloc]init];
        //325*403
        flow.minimumInteritemSpacing = 0;
        flow.minimumLineSpacing = 0;
        flow.sectionInset = UIEdgeInsetsMake(0 , 0, 0, 0);
        
        flow.itemSize = CGSizeMake(self.hz_width/7, 50);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, self.calendarWeekView.hz_bottom, self.hz_width, 6 * 50) collectionViewLayout:flow];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollsToTop = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        UINib *nib = [UINib nibWithNibName:@"HZCalendarCell" bundle:[NSBundle mainBundle]];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (HZCalendarTitleView *)calendarTitleView {
    if (_calendarTitleView == nil) {
        _calendarTitleView = [[HZCalendarTitleView alloc] initWithFrame:CGRectMake(0, 0, self.hz_width, 50)];
    }
    return _calendarTitleView;
}

- (HZCalendarWeekView *)calendarWeekView {
    if (_calendarWeekView == nil) {
        _calendarWeekView = [[HZCalendarWeekView alloc] initWithFrame:CGRectMake(0, self.calendarTitleView.hz_bottom, self.hz_width, 50)];
    }
    return _calendarWeekView;
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
