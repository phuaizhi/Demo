//
//  UIView+HZFrame.h
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (HZFrame)

@property (assign, nonatomic) CGFloat hz_x;
@property (assign, nonatomic) CGFloat hz_y;
@property (assign, nonatomic) CGFloat hz_width;
@property (assign, nonatomic) CGFloat hz_height;

/**
 视图的下方 只读属性
 */
@property (assign, nonatomic,readonly) CGFloat hz_bottom;
/**
 视图的右方 只读属性
 */
@property (assign, nonatomic,readonly) CGFloat hz_right;

@property (assign, nonatomic) CGSize hz_size;

@end

NS_ASSUME_NONNULL_END
