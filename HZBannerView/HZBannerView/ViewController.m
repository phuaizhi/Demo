//
//  ViewController.m
//  HZBannerView
//
//  Created by mac on 2018/12/7.
//  Copyright © 2018 mac. All rights reserved.
//

#import "ViewController.h"
#import "HZBannerView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    NSArray *contentArr = [NSArray arrayWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg", nil];
    HZBannerView *bannerView = [[HZBannerView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 200) withContentArr:contentArr];
    [self.view addSubview:bannerView];
}


@end
