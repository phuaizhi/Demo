//
//  UIView+FirstViewController.m
//  CateoryDefine
//
//  Created by mac on 2018/11/6.
//  Copyright © 2018 mac. All rights reserved.
//

#import "UIView+FirstViewController.h"

@implementation UIView (FirstViewController)

- (UIViewController *)handleFirstViewController {
    return [self traverseResponderChainForUIViewController];
}
- (id)traverseResponderChainForUIViewController {
   id next = [self nextResponder];
    if ([next isKindOfClass:[UIViewController class]]) {
        return next;
    } else if ([next isKindOfClass:[UIView class]]) {
        return [next traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}
@end
