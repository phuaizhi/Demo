//
//  MBProgressHUD+LoadingView.h
//  LearnVideoToolBox
//
//  Created by mac on 2018/11/12.
//  Copyright © 2018 loyinglin. All rights reserved.
//

#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,LoadingType){
    LoadingTypeIndicator,//指示
     LoadingTypeCustom,//自定义 图片(名字需改为：load_custom)加文字 
     LoadingTypeText,//文本
};

@interface MBProgressHUD (LoadingView)


/**
 自定义带标题的提示框

 @param text 内容
 @param view 父视图
 type 提示框类型
 */
+ (void)showLoadingWithText:(NSString *)text  toView:(UIView *)view  type:(LoadingType)loadType;
/**
 提示框消失
 */
+ (void)hideLoadingView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
