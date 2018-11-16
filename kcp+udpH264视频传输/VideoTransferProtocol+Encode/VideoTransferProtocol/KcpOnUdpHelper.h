//
//  KcpOnUdpHelper.h
//  VideoTransferProtocol
//
//  Created by mac on 2018/11/15.
//  Copyright © 2018 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 ***判断通讯质量，主要用于判断是否开启麦克风功能***
 WifiQualityTypeBeingTested,正在检测，相当于没有实现wifi通讯.未检测
 WifiQualityFast,网速较快，心跳回调时间<10ms
 WifiQualityGeneral,网速一般，心跳回调时间<20ms
 WifiQualityPoor,网速差，心跳回调时间>20ms
 WifiQualityNotNetwork,没有网络，没有实现wifi通讯
 */
typedef NS_ENUM(NSUInteger,WifiQualityType){
    WifiQualityTypeBeingTested,
    WifiQualityFast,
    WifiQualityGeneral,
    WifiQualityPoor,
    WifiQualityNotNetwork,
};

typedef void(^QualityListener)(WifiQualityType type);//通信质量的监听
typedef void(^ConnectListener)(BOOL isConnect);//连接状态的监听
typedef void(^DataListener)(NSData *data);//数据回调的监听

@interface KcpOnUdpHelper : NSObject

/**
 连接状态 默认 no 未连接
 */
@property (assign, nonatomic)BOOL isConnected;
@property (strong, nonatomic)QualityListener qualityListener;
@property (strong, nonatomic)ConnectListener connectListener;
@property (strong, nonatomic)DataListener    dataListener;
/**
 初始化

 @param ip IP地址
 @param port 端口号
 @return self
 */
- (instancetype)initWithIP:(NSString *)ip withPort:(NSInteger)port;
/**
 开始连接
 */
- (void)connect;
/**
 断开连接
 */
- (void)disconnect;
/**
 发送数据

 @param data 发送数据
 */
- (void)sendData:(NSData *)data;
/**
 发送数据

 @param data 数据
 @param DataHandler 发送完的回调
 */
- (void)sendData:(NSData *)data dataHandle:(void(^)(void)) DataHandler;

/**
 开启关闭通信质量检测

 @param isQuality yes 开启 no关闭 默认开启
 */
- (void)setQuality:(BOOL)isQuality;
/**
 设置发送数据的大小

 @param sendSize 大小
 */
- (void)setSendBufferSize:(NSInteger)sendSize;
/**
 设置接收数据的大小

 @param receiveSize 大小
 */
- (void)setRecevieBufferSize:(NSInteger)receiveSize;
@end

NS_ASSUME_NONNULL_END
