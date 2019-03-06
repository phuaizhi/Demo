//
//  UIView+HZFrame.m
//  HZCalendar
//
//  Created by mac on 2019/3/5.
//  Copyright © 2019 mac. All rights reserved.
//

#import "UIView+HZFrame.h"

@implementation UIView (HZFrame)

- (CGFloat)hz_x {
    return self.frame.origin.x;
}

- (CGFloat)hz_y {
    return self.frame.origin.y;
}

- (CGFloat)hz_width {
    return self.frame.size.width;
}

- (CGFloat)hz_height {
    return self.frame.size.height;
}

- (void)setHz_x:(CGFloat)hz_x {
    CGRect hz_frame = self.frame;
    hz_frame.origin.x = hz_x;
    self.frame = hz_frame;
}

- (void)setHz_y:(CGFloat)hz_y {
    CGRect hz_frame = self.frame;
    hz_frame.origin.y = hz_y;
    self.frame = hz_frame;
}

- (void)setHz_width:(CGFloat)hz_width {
    CGRect hz_frame = self.frame;
    hz_frame.size.width = hz_width;
    self.frame = hz_frame;
}

- (void)setHz_height:(CGFloat)hz_height {
    CGRect hz_frame = self.frame;
    hz_frame.size.height = hz_height;
    self.frame = hz_frame;
}

- (CGSize)hz_size {
    return self.frame.size;
}

- (void)setHz_size:(CGSize)hz_size {
    CGRect hz_frame = self.frame;
    hz_frame.size = hz_size;
    self.frame = hz_frame;
}

- (CGFloat)hz_bottom {
    return self.frame.origin.y+self.frame.size.height;
}

- (CGFloat)hz_right {
    return self.frame.origin.x+self.frame.size.width;
}

@end
