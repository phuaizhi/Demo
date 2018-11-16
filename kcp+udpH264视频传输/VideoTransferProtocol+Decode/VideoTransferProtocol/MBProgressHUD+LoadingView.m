//
//  MBProgressHUD+LoadingView.m
//  LearnVideoToolBox
//
//  Created by mac on 2018/11/12.
//  Copyright © 2018 loyinglin. All rights reserved.
//

#import "MBProgressHUD+LoadingView.h"
#import "MBProgressHUD.h"
@implementation MBProgressHUD (LoadingView)

+ (void)showLoadingWithText:(NSString *)text  toView:(UIView *)view  type:(LoadingType)loadType{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    hud.label.text = text;
    hud.removeFromSuperViewOnHide = YES;
    if (loadType == LoadingTypeIndicator) {
        hud.mode =  MBProgressHUDModeIndeterminate;
    } else if (loadType == LoadingTypeCustom) {
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"load_custom"]]];
    } else {
        hud.mode = MBProgressHUDModeText;
        //文本提示 默认1秒消失
        [hud hideAnimated:YES afterDelay:1.0f];
    }
   
}
+ (void)hideLoadingView:(UIView *)view;
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}
@end
