//
//  UIView+Frame.h
//  CateoryDefine
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Frame)
/**
 *  设置x坐标
 */
- (void)setX:(CGFloat)x;
/**
 *  获取x坐标
 */
- (CGFloat)x;

/**
 *  设置y坐标
 */
- (void)setY:(CGFloat)y;
/**
 *  获取y坐标
 */
- (CGFloat)y;

/**
 *  设置width
 */
- (void)setWidth:(CGFloat)width;
/**
 *  获取width
 */
- (CGFloat)width;

/**
 *  设置height
 */
- (void)setHeight:(CGFloat)height;
/**
 *  获取height
 */
- (CGFloat)height;

/**
 *  设置size
 */
- (void)setSize:(CGSize)size;
/**
 *  获取size
 */
- (CGSize)size;

/**
 *  设置origin
 */
- (void)setOrigin:(CGPoint)origin;
/**
 *  获取origin
 */
- (CGPoint)origin;

/**
 *  获取最大的x
 */
- (CGFloat)maxX;

/**
 *  获取最大的y
 */
- (CGFloat)maxY;
/**
 *  获取最小的x
 */
- (CGFloat)minX;
/**
 *  获取最小的y
 */
- (CGFloat)minY;
/**
 *  获取中间x值
 */
- (CGFloat)midX;
/**
 *  获取中间y值
 */
- (CGFloat)midY;

@end

NS_ASSUME_NONNULL_END
