//
//  KcpOnUdpHelper.m
//  VideoTransferProtocol
//
//  Created by mac on 2018/11/15.
//  Copyright © 2018 mac. All rights reserved.
//

#import "KcpOnUdpHelper.h"
#import "GCDAsyncUdpSocket.h"
#import <arpa/inet.h>
#import <netdb.h>
#import "ikcp.h"

@interface KcpOnUdpHelper()<GCDAsyncUdpSocketDelegate>{
    ikcpcb *_kcp; // kcpd对象
    GCDAsyncUdpSocket *_udpSocket;// udp对象
    //心跳发起时间
    NSTimeInterval _startMillisecond;
    //心跳返回时间
    NSTimeInterval _receiveMillisecond;
    //是否连接成功
    BOOL _isconnect;
    //是否l开启质量通道检测
    BOOL _isQuality;
    //多少个心跳包没有收到反馈信息,用于判断超时
    NSInteger _notCallBackCount;
}
@property (nonatomic, assign) WifiQualityType wifiQuality;//wifi质量，默认正在检测
@property (strong, nonatomic) NSTimer *timer;//定时器，用来定时发送心跳包
//@property (copy, nonatomic) NSString *ip;//ip地址
//@property (assign, nonatomic) NSInteger port;//端口地址
@end

//常量 type
NSString * const KEY_TYPE = @"type";
//常量 search
NSString * const KEY_TYPE_SEARCH = @"search";
//常量 connect
NSString * const KEY_TYPE_CONNECT = @"connect";
//常量 连接的心跳包
NSInteger const VALUE_CONNECT_HEARTBEAT = 1201;
//常量 连接成功状态值
NSInteger const VALUE_CONNECT_CONNECT = 1202;
//常量 连接断开状态值
NSInteger const VALUE_CONNECT_CLOSE = 1203;
//常量 连接错误状态值
NSInteger const VALUE_CONNECT_ERROR = 1204;
//常量 message
NSString * const KEY_TYPE_MESSAGE = @"message";
//常量 点对点消息标识值
NSInteger const VALUE_MESSAGE_SINGLE = 1301;
//常量 房间消息标识值
NSInteger const VALUE_MESSAGE_ROUTE = 1302;
//常量 is_confirm_message （是否为AC确认消息）
NSString * const KEY_IS_CONFIRM_MESSAGE = @"is_confirm_message";
//常量 确认消息的标识
NSInteger const VALUE_IS_CONFIRM_MESSAGE = 1303;
//常量 buffer_size标识
NSString * const KEY_BUFFER_SIZE = @"buffer_size";
//常量 心跳秒数
NSInteger const VALUE_HEARTBEAT_SECONDS = 3;
//常量 超时秒数 = VALUE_HEARTBEAT_SECONDS * n（便于监测）
NSInteger const VALUE_TIMEOUT_SECONDS = 6;
static NSString * c_host = @"0.0.0.0";
static NSInteger c_port = 10099;
static GCDAsyncUdpSocket * _udp;

@implementation KcpOnUdpHelper

- (instancetype)initWithIP:(NSString *)ip withPort:(NSInteger)port {
    if (self = [super init]) {
        // 设置KCP参数，同服务端或者对点端参数保持一致
        int32_t conv = 121106;
        _kcp = ikcp_create(conv, NULL);
        _kcp->output = c_udp_output;
        ikcp_nodelay(_kcp, 1, 10, 2, 1);
        _kcp->rx_minrto = 10;
        ikcp_wndsize(_kcp, 128, 128);
        ikcp_setmtu(_kcp, 512);
        NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.0001f
                                                           target:self
                                                         selector:@selector(timerFire:)
                                                         userInfo:nil
                                                          repeats:YES];
        // 立马执行定时器
        [timer fire];
        // udp初始化
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        _udp = _udpSocket;
        c_host = ip;
        c_port = port;
        _isQuality = YES;
        //开启端口
        NSError *error = nil;
        [_udp bindToPort:port error:&error];
        if (error) {
            //打印日志,toast
            NSLog(@"绑定端口失败！！！ error = %@",error);
        }
        else
        {
            //监听成功开始接收消息
            [_udp beginReceiving:&error];
            if (error) {
                //打印日志,toast
                NSLog(@"监听失败！！！ error = %@",error);
            } else {
                NSLog(@"监听成功");
            }
        }
    }
    return self;
}
-(void)timerFire:(id)userinfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        ikcp_update(self->_kcp, clock());
    });
}
/**
 开始连接
 */
- (void)connect {
    //第一次发起请求
    //添加参数
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:KEY_TYPE_CONNECT forKey:KEY_TYPE];
    [dictionary setObject:[NSString stringWithFormat:@"%ld",VALUE_CONNECT_CONNECT] forKey:KEY_TYPE_CONNECT];
    [dictionary setObject:[NSString stringWithFormat:@"%d",640*480*3/10] forKey:KEY_BUFFER_SIZE];
    
    //发送心跳请求，记录当前时间，用于判断wifi质量
    NSDate *date = [NSDate date];
    _startMillisecond = [date timeIntervalSince1970];
    //设置正在检测
    self.wifiQuality = WifiQualityTypeBeingTested;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    [self sendData:data];
}
/**
 断开连接
 */
- (void)disconnect {
    //前端状态连接，发起断开
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:KEY_TYPE_CONNECT forKey:KEY_TYPE];
    [dictionary setObject:[NSString stringWithFormat:@"%ld",VALUE_CONNECT_CLOSE] forKey:KEY_TYPE_CONNECT];
    [self sendData:[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil]];
    
    //延后执行
    [self performSelector:@selector(closeUdpClient) withObject:nil afterDelay:.1f];
}
- (void)closeUdpClient {
    //关闭心跳连接，置nil
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    //断开连接
    [_udp close];
    _udp = nil;

    _startMillisecond = 0.f;
    _receiveMillisecond = 0.f;
    _wifiQuality = WifiQualityNotNetwork;
}
/**
 发送数据
 
 @param data 发送数据
 */
- (void)sendData:(NSData *)data {
    int a = ikcp_send(_kcp, data.bytes, (int)data.length);
    NSLog(@" -- ikcp_send => %d  size => %ld %@",a,(unsigned long)data.length, data);
}
/**
 发送数据
 
 @param data 数据
 @param DataHandler 发送完的回调
 */
- (void)sendData:(NSData *)data dataHandle:(void(^)(void)) DataHandler {

}

/**
 开启关闭通信质量检测
 
 @param isQuality yes 开启 no关闭
 */
- (void)setQuality:(BOOL)isQuality {
    _isQuality = isQuality;
    if (!isQuality) {
        // 关闭心跳包
        if ([self.timer isValid]) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.wifiQuality = WifiQualityTypeBeingTested;
    }
}
/**
 设置发送数据的大小
 
 @param sendSize 大小
 */
- (void)setSendBufferSize:(NSInteger)sendSize {
    
}
/**
 设置接收数据的大小
 
 @param receiveSize 大小
 */
- (void)setRecevieBufferSize:(NSInteger)receiveSize {
    
}
#pragma mark -- GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
//    NSLog(@" --- sock didReceive ---%lu --- %hu",(unsigned long)data.length,[GCDAsyncUdpSocket portFromAddress:address]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!data || !address) {
            return;
        }
        if (data.length == 0) {
            return;
        }
        int input = ikcp_input(self->_kcp, data.bytes, data.length);
//        NSLog(@" --- input - %d len ---%lu",input,(unsigned long)data.length);
        if (input != 0) {
            return;
        }
        
//        NSLog(@" --- len ---%lu",(unsigned long)data.length);
        char buffer[1000000];
        int recv = ikcp_recv(self->_kcp, buffer, sizeof(buffer));
//        NSLog(@" --- recv -- %d",recv);
        if (recv > 0) {
            c_host = [GCDAsyncUdpSocket hostFromAddress:address];
            c_port = [GCDAsyncUdpSocket portFromAddress:address];
            NSData * receiveData = [NSData dataWithBytes:buffer length:recv];
            NSString *receiveStr = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
//            NSLog(@"服务器ip地址--->%@,port---%u,内容--->%@",
//                  [GCDAsyncUdpSocket hostFromAddress:address],
//                  [GCDAsyncUdpSocket portFromAddress:address],
//                  receiveStr);
            if (self.dataListener) {
                self.dataListener(receiveData);
            }
        }
    });
#if 0
    //将json数据转为对象
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        //数据解析错误
        NSLog(@"数据错误！");
        return;
    }
    else
    {
        //返回的是字典类型
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = object;
            if ([dictionary[KEY_TYPE] isEqualToString:KEY_TYPE_CONNECT])//连接
            {
                switch ([dictionary[KEY_TYPE_CONNECT] integerValue]) {
                    case 1201://心跳连接
                    {
                        if (_isQuality) {
                            //记录心跳返回时间,给出检测状态
                            NSDate *date = [NSDate date];
                            _receiveMillisecond = [date timeIntervalSince1970];
                            [self judgeWifiQuality];
                        }
                       
                    }
                        break;
                    case 1202://第一次确认连接，获取pc流传输端口
                    {
                        //记录连接状态
                        _isconnect = YES;
                        if (_isQuality) {
                            //第一次记录心跳返回时间,给出检测状态
                            NSDate *date = [NSDate date];
                            _receiveMillisecond = [date timeIntervalSince1970];
                            [self judgeWifiQuality];
                            //开启心跳
                            [self initHeartBeat];
                        }
                        //记录麦克风通道信息
//                        [[UdpPCMFlowObject sharePCMFlowObject] connectToHost:self.ip AndPort:dictionary[@"port"]];
                    }
                        break;
                    case 1203://连接断开
                    {
                        //断开
                        [self disconnect];
                    }
                        break;
                    default://连接错误状态，1204
                    {
                        //打印日志
                    }
                        break;
                }
            }
            else if ([dictionary[KEY_TYPE] isEqualToString:KEY_TYPE_MESSAGE])//消息体
            {
                switch ([dictionary[KEY_TYPE_CONNECT] integerValue]) {
                    case 1301://点对点消息标识值
                    {
                        //pcm包体大小
                        //                        [UserInfoModel share].bufferSize = [dictionary[KEY_BUFFER_SIZE] doubleValue];
                    }
                        break;
                    case 1302://房间消息标识值
                    {
                        
                    }
                        break;
                    case 1305://确认消息的标识
                    {
                        
                    }
                        break;
                    default:
                        break;
                }
            }
        }
    }
#endif
}
int c_udp_output(const char * buf, int len, ikcpcb * kcp, void * user)
{
    NSData * data = [NSData dataWithBytes:buf length:len];
//    NSLog(@"\n host == %@ port == %ld conv = %d",c_host,
//          (long)c_port,kcp->conv);
//    NSLog(@"\n data == %@",data);
    [_udp sendData:data toHost:c_host port:c_port withTimeout:-1 tag:0];
    return 0;
}
#pragma mark- 初始化心跳包发生器
-(void)initHeartBeat
{
    //是否已经存在定时器，存在则关闭
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    //添加定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:VALUE_HEARTBEAT_SECONDS target:self selector:@selector(sendHeartBeatData) userInfo:nil repeats:YES];
    // 定时器立马启动
    [self.timer fire];
}

/**
 发送心跳包
 */
-(void)sendHeartBeatData
{
    //判断上一个心跳包有没有返回信息，没有返回则判断wifi连接断开
    if (_receiveMillisecond<_startMillisecond)
        _notCallBackCount++;
    else
        _notCallBackCount = 0;
    
    //超时，设置为wifi通讯中断
    if (_notCallBackCount>=VALUE_TIMEOUT_SECONDS/VALUE_TIMEOUT_SECONDS) {
        self.wifiQuality = WifiQualityNotNetwork;//wifi通讯断开
    }
    //前端状态是未连接，发起连接
    //添加参数
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:KEY_TYPE_CONNECT forKey:KEY_TYPE];
    [dictionary setObject:[NSString stringWithFormat:@"%ld",VALUE_CONNECT_HEARTBEAT] forKey:KEY_TYPE_CONNECT];
    
    //发送心跳请求，记录当前时间，用于判断wifi质量
    NSDate *date = [NSDate date];
    _startMillisecond = [date timeIntervalSince1970];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    [self sendData:data];
}

/**
 判断wifi质量
 */
-(void)judgeWifiQuality {
    
    //    NSLog(@"心跳发送时间=%f，接收心跳时间=%f，网络延迟时间=%f",_startMillisecond,_receiveMillisecond,_receiveMillisecond*1000.0-_startMillisecond*1000.0);
    
    if (_receiveMillisecond>_startMillisecond) {
        NSTimeInterval millisecond = (_receiveMillisecond-_startMillisecond)*1000;
        //给出质量值
        self.wifiQuality = millisecond<50.0?WifiQualityFast:(millisecond<80.0?WifiQualityGeneral:WifiQualityPoor);
    }
    else {
        self.wifiQuality = WifiQualityPoor;//差
    }
}
@end
