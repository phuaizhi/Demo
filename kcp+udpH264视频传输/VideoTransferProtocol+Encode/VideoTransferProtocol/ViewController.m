//
//  ViewController.m
//  VideoTransferProtocol
//
//  Created by mac on 2018/11/15.
//  Copyright © 2018 mac. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD+LoadingView.h"
#import "H264Encode.h"
#import "KcpOnUdpHelper.h"
@interface ViewController ()
/**
 IP地址
 */
@property (weak, nonatomic) IBOutlet UITextField *IPText;
/**
 端口
 */
@property (weak, nonatomic) IBOutlet UITextField *PortText;
@property (weak, nonatomic) IBOutlet UITextField *msgText;
@property (strong, nonatomic) H264Encode  *encode;
@property (strong, nonatomic) KcpOnUdpHelper  *kcp_udp;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
   self.encode = [[H264Encode alloc] initParemesWithFps:30 withBitRate:640*480 withResolution:ResolutionRate720 withDirection:AVCaptureVideoOrientationPortrait withCamera:AVCaptureDevicePositionFront];
    __weak typeof(self)weakSelf = self;
    [self.encode setDataListener:^(NSData * _Nonnull data) {
        NSLog(@"编码的数据：%@",data);
        [weakSelf.kcp_udp sendData:data];
    }];
    

}
/**
 根据ip和port连接对应服务器

 @param sender 按钮
 */
- (IBAction)startConnactServer:(UIButton *)sender {
    
    if (![self.IPText.text isEqualToString:@""] && ![self.PortText.text isEqualToString:@""]) {
        // 初始化
        self.kcp_udp = [[KcpOnUdpHelper alloc] initWithIP:self.IPText.text withPort:[self.PortText.text integerValue]];
        self.kcp_udp.dataListener = ^(NSData * _Nonnull data) {
            NSLog(@"收到的数据%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        };
    } else {
        [MBProgressHUD showLoadingWithText:@"请填写IP和Port" toView:self.view type:LoadingTypeText];
    }
}
- (IBAction)startCaptureVideoData:(UIButton *)sender {
    if (self.encode.isSupported) {
        NSLog(@"支持采集视频数据");
        sender.selected = !sender.isSelected;
        if (sender.selected) {
            [sender setTitle:@"停止采集" forState:UIControlStateNormal];
            [self.encode start];
            [self.encode fixPreview:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height-50)];
            [self.encode setPreviewVisible:YES toView:self.view];
        } else {
            [sender setTitle:@"开始采集" forState:UIControlStateNormal];
            [self.encode stop];
        }
    } else {
        NSLog(@"不支持");
    }
}
- (IBAction)sendDataAction:(UIButton *)sender {
    if ([self.msgText.text isEqualToString:@""]) {
        [MBProgressHUD showLoadingWithText:@"发送信息不能为空" toView:self.view type:LoadingTypeText];
    } else {
        NSData *data = [self.msgText.text dataUsingEncoding:NSUTF8StringEncoding];
        [self.kcp_udp sendData:data];
    }
}


@end
