//
//  HZAdressPickerView.h
//  DiYun
//
//  Created by mac on 2019/6/25.
//  Copyright © 2019 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HZAdressPickerViewDelegate <NSObject>

- (void)selectAdressPickerWith:(NSString *)adressStr;

@end


@interface HZAdressPickerView : UIView

@property (weak, nonatomic) id<HZAdressPickerViewDelegate>delegate;

/**
 显示地址选择器
 */
- (void)showPickerView ;

/**
 显示地址选择器并选中已有地址

 @param adressStr 已有地址字符串  需用空格隔开
 */
- (void)showPickerViewWithAdressStr:(NSString *)adressStr;

@end

NS_ASSUME_NONNULL_END
