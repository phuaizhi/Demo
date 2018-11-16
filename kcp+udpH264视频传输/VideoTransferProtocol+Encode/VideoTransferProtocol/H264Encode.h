//
//  H264Encode.h
//  VideoTransferProtocol
//
//  Created by mac on 2018/11/15.
//  Copyright © 2018 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger,ResolutionRate){
    ResolutionRate288,//352*288
    ResolutionRate480,//640*480
    ResolutionRate720,//1280*720
    ResolutionRate1080,//1920*1080
};

typedef void(^DataListenerBlock)(NSData *data);
typedef void(^ErrorListenerBlock)(NSString *errorStr);
@interface H264Encode : NSObject

/**
判断当前设备是否支持摄像头数据采集(要开启摄像头权限)
 */
@property (nonatomic,assign) BOOL isSupported;

/**
 数据回调
 */
@property (nonatomic,strong) DataListenerBlock dataListener;

/**
 数据异常的回调
 */
@property (nonatomic,strong) ErrorListenerBlock errorListener;
/**
 初始化

 @param fpsValue 帧率
 @param bitRate  码率 跟分辨率大小有关 分辨率的宽*高
 @param rate     分辨率
 @param direction 预览方向
 @param position  前后摄像头选择
 @return self
 */
- (instancetype)initParemesWithFps:(int)fpsValue withBitRate:(int)bitRate withResolution:(ResolutionRate)rate withDirection:(AVCaptureVideoOrientation)direction withCamera:(AVCaptureDevicePosition)position;
/**
 开始采集
 */
- (void)start;
/**
 停止采集
 */
- (void)stop;

/**
 设置是否显示预览

 @param isVisible yes显示  no 不显示
 @param view 父视图
 */
- (void)setPreviewVisible:(BOOL)isVisible toView:(UIView *)view;
/**
 设置预览的位置

 @param frame CGRect
 */
- (void)fixPreview:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
