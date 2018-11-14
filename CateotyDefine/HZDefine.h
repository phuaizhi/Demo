//
//  HZDefine.h
//  MicroProject
//
//  Created by mac on 2018/10/30.
//  Copyright © 2018 phz. All rights reserved.
//  常用宏定义 屏幕宽度、高度 状态栏高度 等等

#ifndef HZDefine_h
#define HZDefine_h

// 宽
#define Wscreen [UIScreen mainScreen].bounds.size.width
// 高
#define Hscreen [UIScreen mainScreen].bounds.size.height
// 状态栏的高度
#define Hstatusbar  CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
// 判断是不是刘海屏  xs 414 896  x 414 812  xr 414 896
#define IphoneX     (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) == 44)
// 导航栏的高度

//16进制颜色
#define kCOLOR_RGBValue(RGBValue)   [UIColor colorWithRed:((float)((RGBValue & 0xFF0000) >> 16))/255.0 \
green:((float)((RGBValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((RGBValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

//16进制颜色+透明度
#define kCOLOR_RGBAndAlpha(RGBValue,a)   [UIColor colorWithRed:((float)((RGBValue & 0xFF0000) >> 16))/255.0 \
green:((float)((RGBValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((RGBValue & 0x0000FF) >>  0))/255.0 \
alpha:a]

#define HZWeakSelf __weak typeof(self) weakSelf = self;//弱引用



#ifdef __OBJC__
#ifdef DEBUG
#   define NSLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define NSLog(...)
#endif
#endif

#import <UIKit/UIKit.h>
#endif /* HZDefine_h */
