//
//  HZBannerView.h
//  HZBannerView
//
//  Created by mac on 2018/12/7.
//  Copyright © 2018 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^selectBannerIndexBlcok)(NSInteger index);

@interface HZBannerView : UIView

@property (copy,nonatomic) selectBannerIndexBlcok selectBannerIndex;

- (instancetype)initWithFrame:(CGRect)frame  withContentArr:(NSArray *)contentArr;
@end

NS_ASSUME_NONNULL_END
