//
//  HZAdressPickerView.m
//  phz
//
//  Created by phuaizhi on 2019/6/25.
//  Copyright © 2019 phuaizhi. All rights reserved.
//

#import "HZAdressPickerView.h"

@interface HZAdressPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) UIView *contentView;

@property (strong, nonatomic) UIPickerView *adressPicker;

@property (strong, nonatomic) NSArray *provinceArr;

@property (strong, nonatomic) NSArray *cityArr;

@property (strong, nonatomic) NSArray *countyArr;

/**
 记录城市的下标
 */
@property (assign, nonatomic) NSInteger previousRow;

/**
 记录县城的下标
 */
@property (assign, nonatomic) NSInteger countyRow;

/**
 记录选中的地址
 */
@property (strong, nonatomic) NSMutableArray *adressArr;

@end


@implementation HZAdressPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgView];
        self.previousRow = 0;
        self.countyRow = 0;
        
    }
    return self;
}

#pragma mark - Method

- (void)sureBtnAction:(UIButton *)sender {
    [self hidePickerView];
    __block  NSString *adressStr = @"";
    [self.adressArr enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL * _Nonnull stop) {
        adressStr = [adressStr stringByAppendingString:[NSString stringWithFormat:@" %@",str]];
    }];
    NSLog(@"adressStr:%@",adressStr);
    if ([self.delegate respondsToSelector:@selector(selectAdressPickerWith:)]) {
        [self.delegate selectAdressPickerWith:adressStr];
    }
}

- (void)showPickerView {
    [self showPickerViewWithAdressStr:@""];
}

- (void)showPickerViewWithAdressStr:(NSString *)adressStr {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    // 弹出选择视图
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.frame = CGRectMake(0, self.height - 320, Wscreen, 320);
    }];
    if (![adressStr isEqualToString:@""]) {
        // 将地址用空格分解
        NSArray *array = [adressStr componentsSeparatedByString:@" "];
        // 先找到省的下标  然后依次找市  县
        [self.provinceArr enumerateObjectsUsingBlock:^(NSDictionary *provinceDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([provinceDic[@"text"] isEqualToString:[array firstObject]]) {
                [self.adressPicker selectRow:idx inComponent:0 animated:YES];
                self.cityArr = provinceDic[@"childrens"];
                return ;
            }
        }];
        [self.cityArr enumerateObjectsUsingBlock:^(NSDictionary *cityDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cityDic[@"text"] isEqualToString:[array objectAtIndex:1]]) {
                [self.adressPicker selectRow:idx inComponent:1 animated:YES];
                self.countyArr = cityDic[@"childrens"];
                return ;
            }
        }];
        [self.countyArr enumerateObjectsUsingBlock:^(NSDictionary *countyDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([countyDic[@"text"] isEqualToString:[array lastObject]]) {
                [self.adressPicker selectRow:idx inComponent:2 animated:YES];
                return ;
            }
        }];
    }
}

- (void)hidePickerView {
    // 隐藏选择视图
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.frame = CGRectMake(0, self.height, Wscreen, 320);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArr.count;
    } else if (component == 1) {
        return self.cityArr.count;
    }
    return self.countyArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArr[row][@"text"];
    } else if (component == 1) {
        return self.cityArr[row][@"text"];
    }
    return self.countyArr[row][@"text"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component != 2) {
        if (component == 0) {
            self.cityArr = self.provinceArr[row][@"childrens"];
            if (self.previousRow > self.cityArr.count - 1) {
                self.previousRow = self.cityArr.count - 1;
            }
            self.countyArr = self.cityArr[self.previousRow][@"childrens"];
            [self.adressPicker reloadComponent:component+2];
            [self.adressArr replaceObjectAtIndex:0 withObject:self.provinceArr[row][@"text"]];
        } else if (component == 1) {
            self.countyArr = self.cityArr[row][@"childrens"];
            self.previousRow = row;
        }
        if (self.countyRow > self.countyArr.count - 1) {
            self.countyRow = self.countyArr.count - 1;
        }
        [self.adressArr replaceObjectAtIndex:1 withObject:self.cityArr[self.previousRow][@"text"]];
        [self.adressArr replaceObjectAtIndex:2 withObject:self.countyArr[self.countyRow][@"text"]];
        [self.adressPicker reloadComponent:component+1];
    } else {
        self.countyRow = row;
        [self.adressArr replaceObjectAtIndex:2 withObject:self.countyArr[row][@"text"]];
    }
}

#pragma mark - getter

- (UIPickerView *)adressPicker {
    if (_adressPicker == nil) {
        _adressPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 50, self.width-30, self.contentView.height-50)];
        _adressPicker.delegate = self;
        _adressPicker.dataSource = self;
    }
    return _adressPicker;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 320)];
        _contentView.backgroundColor = [UIColor whiteColor];
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 50, 30)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(hidePickerView) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:cancelBtn];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, self.width-150, 30)];
        titleLabel.text = @"请选择地址";
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:titleLabel];
        UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width-75, 10, 50, 30)];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:sureBtn];
        [_contentView addSubview:self.adressPicker];
    }
    return _contentView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor colorWithRed:(100.f/255) green:(100.f/255) blue:(100.f/255) alpha:0.5];
        UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePickerView)];
        [_bgView addGestureRecognizer:hideTap];
        [_bgView addSubview:self.contentView];
    }
    return _bgView;
}

- (NSArray *)provinceArr {
    if (_provinceArr == nil) {
        _provinceArr = [NSArray array];
        NSString *localFilePath = [[NSBundle mainBundle] pathForResource:@"citys" ofType:@"json"];
        NSData *localData = [NSData dataWithContentsOfFile:localFilePath];
        NSError *error;
        _provinceArr = [NSJSONSerialization JSONObjectWithData:localData options:kNilOptions error:&error];
    }
    return _provinceArr;
}

- (NSArray *)cityArr {
    if (_cityArr == nil) {
        _cityArr = self.provinceArr[0][@"childrens"];
    }
    return _cityArr;
}

- (NSArray *)countyArr {
    if (_countyArr == nil) {
        _countyArr = self.cityArr[0][@"childrens"];
    }
    return _countyArr;
}

- (NSMutableArray *)adressArr {
    if (_adressArr == nil) {
        _adressArr = [NSMutableArray arrayWithObjects:self.provinceArr[0][@"text"],self.cityArr[0][@"text"],self.countyArr[0][@"text"], nil];
    }
    return _adressArr;
    
}

@end
