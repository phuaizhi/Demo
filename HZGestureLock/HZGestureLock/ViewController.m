//
//  ViewController.m
//  HZGestureLock
//
//  Created by mac on 2018/10/16.
//  Copyright © 2018 mac. All rights reserved.
//

#import "ViewController.h"
#import "HZGestureLockView.h"
// 屏幕的宽。高
#define Wscreen  [UIScreen mainScreen].bounds.size.width
#define Hscreen  [UIScreen mainScreen].bounds.size.height
@interface ViewController ()

@end
/*
    解锁视图默认为九宫格布局 最少三行 最少两列
 */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // 采用自定义视图 来展示解锁界面
    HZGestureLockView *lockView = [[HZGestureLockView alloc]initWithFrame:CGRectMake(50, 100, Wscreen-100, Wscreen-50)];
    [self.view addSubview:lockView];
}


@end
