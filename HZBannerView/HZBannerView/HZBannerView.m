//
//  HZBannerView.m
//  HZBannerView
//
//  Created by mac on 2018/12/7.
//  Copyright © 2018 mac. All rights reserved.
//

#import "HZBannerView.h"

#define WBanner   self.frame.size.width
#define HBanner   self.frame.size.height
@interface HZBannerView ()<UIScrollViewDelegate>
{
    
}

@property (strong,nonatomic) NSArray *imgArr;// banner图上的图片
@property (strong,nonatomic) NSTimer *timer; // 定时器
@property (strong,nonatomic) UIPageControl *pageControl; // 分页指示器
@property (strong,nonatomic) UIScrollView  *scrollView; // 滑动视图
@end

@implementation HZBannerView

- (instancetype)initWithFrame:(CGRect)frame  withContentArr:(NSArray *)contentArr {
    if (self = [super initWithFrame:frame]) {
        self.imgArr = [NSArray arrayWithArray:contentArr];
        // 初始化view
        [self initView];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

    }
    return self;
}
- (void)initView {
    // 创建滚动图
   self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    if (@available (iOS 11,*)) {
        [self.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    [self.scrollView setContentSize:CGSizeMake((self.imgArr.count+2)*WBanner, HBanner)];
    [self.scrollView setContentOffset:CGPointMake(WBanner, 0)];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setBounces:NO];
    // 分页效果 if YES, stop on multiples of view bounds
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setDelegate:self];
    for (NSInteger i=0; i < self.imgArr.count+2; i++) {
        
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(i*WBanner, 0, WBanner, HBanner)];
        if (i == 0) {
            imgView.tag = self.imgArr.count;
            [imgView setImage:[UIImage imageNamed:[self.imgArr lastObject]]];
        } else if (i == self.imgArr.count + 1) {
            imgView.tag = 1;
             [imgView setImage:[UIImage imageNamed:[self.imgArr firstObject]]];
        } else {
             imgView.tag = i;
             [imgView setImage:[UIImage imageNamed:self.imgArr[i-1]]];
        }
        imgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBannerIndex:)];
        [imgView addGestureRecognizer:tap];
        [self.scrollView addSubview:imgView];
    }
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
}

- (void)updateScrollViewOffset {
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x+WBanner, 0)];
}
- (void)selectBannerIndex:(UITapGestureRecognizer *)tap {
//    NSLog(@"%ld",tap.view.tag);
    if (self.selectBannerIndex){
        self.selectBannerIndex(tap.view.tag);
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.timer invalidate];
    self.timer = nil;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 第一个
    if(scrollView.contentOffset.x == 0) {
        [scrollView setContentOffset:CGPointMake(self.imgArr.count*WBanner, 0)];
    }
    // 最后一个
    if (scrollView.contentOffset.x == (self.imgArr.count+1) *WBanner) {
        [scrollView setContentOffset:CGPointMake(WBanner, 0)];
    }
    self.pageControl.currentPage = self.scrollView.contentOffset.x/WBanner-1;
}

#pragma mark -- getter

- (UIPageControl *)pageControl {
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((WBanner-80)*0.5, self.frame.origin.y+HBanner-30, 80, 30)];
        _pageControl.numberOfPages = self.imgArr.count;
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    }
    return _pageControl;
}

- (NSTimer *)timer {
    if (_timer == nil){
        _timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(updateScrollViewOffset) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end
