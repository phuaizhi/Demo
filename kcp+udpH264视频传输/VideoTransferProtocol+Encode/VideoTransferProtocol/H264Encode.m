//
//  H264Encode.m
//  VideoTransferProtocol
//
//  Created by mac on 2018/11/15.
//  Copyright © 2018 mac. All rights reserved.
//

#import "H264Encode.h"
#import <VideoToolbox/VideoToolbox.h>

@interface H264Encode ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    int _frameID;
    dispatch_queue_t _mCaptureQueue;          //采集队列
    dispatch_queue_t _mEncodeQueue;           // 编码队列
    VTCompressionSessionRef _EncodingSession; // 编码会话
    CMFormatDescriptionRef  _format;
    int _fps;                                 //设置期望帧率（每秒多少帧,如果帧率过低,会造成画面卡顿）
    int _bitRate;                             //设置码率，均值，单位是byte
    int _rate;                                //设置视频的分辨率
    AVCaptureVideoOrientation _direction;     //视频预览的d方向
    AVCaptureDevicePosition   _position;      //摄像头的选择（前，后）
    uint32_t  _spsIndex;                      //数据index 判断数据的顺序
}

@property (nonatomic , strong) AVCaptureSession *mCaptureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic , strong) AVCaptureDeviceInput *mCaptureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureVideoDataOutput *mCaptureDeviceOutput; //输出
@property (nonatomic , strong) AVCaptureVideoPreviewLayer *mPreviewLayer; // 预览层
@end

@implementation H264Encode

/**
 初始化类

 @return   H264Encode
 */
- (instancetype)initParemesWithFps:(int)fpsValue withBitRate:(int)bitRate withResolution:(ResolutionRate)rate withDirection:(AVCaptureVideoOrientation)direction withCamera:(AVCaptureDevicePosition)position {
    if (self == [super init]) {
        _fps = fpsValue?fpsValue:30;//默认30
        _bitRate = bitRate?bitRate:640*480;
        _rate = rate?rate:ResolutionRate480; //默认分辨率640*480
        _direction = direction?direction:AVCaptureVideoOrientationPortrait; //默认正常竖屏预览
        _position = position?position:AVCaptureDevicePositionFront; //默认前置摄像头
        _spsIndex = 0;
    }
    return self;
}
#pragma mark -- method
/**
 开始采集
 */
- (void) start {
    self.mCaptureSession = [[AVCaptureSession alloc] init];
    self.mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    _mCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _mEncodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    AVCaptureDevice *inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == _position)
        {
            inputCamera = device;
        }
    }
    self.mCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    
    if ([self.mCaptureSession canAddInput:self.mCaptureDeviceInput]) {
        [self.mCaptureSession addInput:self.mCaptureDeviceInput];
    }
    
    self.mCaptureDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.mCaptureDeviceOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    [self.mCaptureDeviceOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.mCaptureDeviceOutput setSampleBufferDelegate:self queue:_mCaptureQueue];
    if ([self.mCaptureSession canAddOutput:self.mCaptureDeviceOutput]) {
        [self.mCaptureSession addOutput:self.mCaptureDeviceOutput];
    }
    AVCaptureConnection *connection = [self.mCaptureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:_direction];
    
    self.mPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.mCaptureSession];
    [self.mPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self initVideoToolBox];
    [self.mCaptureSession startRunning];
}
- (void)initVideoToolBox {
    dispatch_sync(_mEncodeQueue  , ^{
        self->_frameID = 0;
        int width = 480, height = 640;
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self),  &self->_EncodingSession);
        NSLog(@"H264: VTCompressionSessionCreate %d", (int)status);
        if (status != 0)
        {
            NSLog(@"H264: Unable to create a H264 session");
            return ;
        }
        
        // 设置实时编码输出（避免延迟）
        VTSessionSetProperty(self->_EncodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(self->_EncodingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
        
        // 设置关键帧（GOPsize)间隔
        int frameInterval = 150;
        CFNumberRef  frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
        VTSessionSetProperty(self->_EncodingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
        
        // 设置期望帧率（每秒多少帧,如果帧率过低,会造成画面卡顿）
        int fps = self->_fps;
        CFNumberRef  fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
        VTSessionSetProperty(self->_EncodingSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
        
        //设置码率，均值，单位是byte
        int bitRate = self->_bitRate * 3 * 4 * 8;
        CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
        VTSessionSetProperty(self->_EncodingSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
        
        //设置码率，上限，单位是bps
        int bitRateLimit = self->_bitRate * 3 * 4;
        CFNumberRef bitRateLimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRateLimit);
        VTSessionSetProperty(self->_EncodingSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLimitRef);
        
        // Tell the encoder to start encoding
        VTCompressionSessionPrepareToEncodeFrames(self->_EncodingSession);
    });
}


- (void) encode:(CMSampleBufferRef )sampleBuffer
{
    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    // 帧时间，如果不设置会导致时间轴过长。
    CMTime presentationTimeStamp = CMTimeMake(_frameID++, 1000);
    VTEncodeInfoFlags flags;
    OSStatus statusCode = VTCompressionSessionEncodeFrame(_EncodingSession,
                                                          imageBuffer,
                                                          presentationTimeStamp,
                                                          kCMTimeInvalid,
                                                          NULL, NULL, &flags);
    if (statusCode != noErr) {
        NSLog(@"H264: VTCompressionSessionEncodeFrame failed with %d", (int)statusCode);
        if (self.errorListener){
            self.errorListener ([NSString stringWithFormat:@"H264: VTCompressionSessionEncodeFrame failed with %d", (int)statusCode]);
        }
        VTCompressionSessionInvalidate(_EncodingSession);
        CFRelease(_EncodingSession);
        _EncodingSession = NULL;
        return;
    }
    NSLog(@"H264: VTCompressionSessionEncodeFrame Success");
}

// 编码完成回调
void didCompressH264(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer) {
    NSLog(@"didCompressH264 called with status %d infoFlags %d", (int)status, (int)infoFlags);
    if (status != 0) {

        return;
    }
    
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"didCompressH264 data is not ready ");
        return;
    }
    H264Encode* encoder = (__bridge H264Encode*)outputCallbackRefCon;
    
    bool keyframe = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    // 判断当前帧是否为关键帧
    // 获取sps & pps数据
    if (keyframe)
    {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
        if (statusCode == noErr)
        {
            // Found sps and now check for pps
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
            if (statusCode == noErr)
            {
                // Found pps
                NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                if (encoder)
                {
                    [encoder gotSpsPps:sps pps:pps];
                }
            } else {
                if (encoder.errorListener) {
                    encoder.errorListener([NSString stringWithFormat:@"sps & pps is failed %d",statusCode]);
                }
            }
        }
    }
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4; // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
        
        // 循环获取nalu数据
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            uint32_t NALUnitLength = 0;
            // Read the NAL unit length
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            
            // 从大端转系统端
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            NSData* data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
            [encoder gotEncodedData:data isKeyFrame:keyframe];
            
            // Move to the next NAL unit in the block buffer
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
    } else {
        if (encoder.errorListener) {
            encoder.errorListener([NSString stringWithFormat:@"nalu is failed %d",statusCodeRet]);
        }
    }
}

- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps
{
    NSLog(@"gotSpsPps %d %d", (int)[sps length], (int)[pps length]);
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];

    NSLog(@"sps_index:%u",_spsIndex);
    uint8_t dataByte[4];
    //        memcpy(dataByte, &_spsIndex, sizeof(uint32_t));
//    dataByte[0] = (_spsIndex >>24)&0xff;
//    dataByte[1] = (_spsIndex >>16)&0xff;
//    dataByte[2] = (_spsIndex >> 8)&0xff;
//    dataByte[3] = _spsIndex &0xff;
//    NSMutableData *combineData = [NSMutableData dataWithBytes:&dataByte length:sizeof(dataByte)];
    NSMutableData *combineData = [NSMutableData data];
    [combineData appendData:ByteHeader];
    [combineData appendData:sps];
    NSMutableData *combineData2 = [NSMutableData data];
    [combineData2 appendData:ByteHeader];
    [combineData2 appendData:pps];
    // 发送数据
    if (self.dataListener) {
        self.dataListener(combineData);
        self.dataListener(combineData2);
    }
    _spsIndex++;
    
}
- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame
{
    NSLog(@"gotEncodedData %d", (int)[data length]);
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    
    // 组合数据发送到服务端
    NSLog(@"sps_index:%u",_spsIndex);
    uint8_t indexByte[4];
    //            memcpy(indexByte, &_spsIndex, sizeof(uint32_t));
//    indexByte[0] = (_spsIndex >>24)&0xff;
//    indexByte[1] = (_spsIndex >>16)&0xff;
//    indexByte[2] = (_spsIndex >> 8)&0xff;
//    indexByte[3] = _spsIndex &0xff;
//    NSMutableData *combineData = [NSMutableData dataWithBytes:&indexByte length:sizeof(indexByte)];
    NSMutableData *combineData = [NSMutableData data];
    [combineData appendData:ByteHeader];
    [combineData appendData:data];
    // 发送数据
    if (self.dataListener) {
        self.dataListener(combineData);
    }
    _spsIndex++;
}
/**
 设置是否显示预览
 
 @param isVisible yes显示  no 不显示
 */
- (void)setPreviewVisible:(BOOL)isVisible toView:(nonnull UIView *)view{
    if (isVisible) {
        //显示
        [view.layer addSublayer:self.mPreviewLayer];

    } else {
        //不显示
        [self.mPreviewLayer removeFromSuperlayer];
    }
}
/**
 设置预览的位置
 
 @param frame CGRect
 */
- (void)fixPreview:(CGRect)frame {
    [self.mPreviewLayer setFrame:frame];
}
/**
 停止采集
 */
- (void)stop {
    [self.mCaptureSession stopRunning];
    [self.mPreviewLayer removeFromSuperlayer];
    [self EndVideoToolBox];
}
- (void)EndVideoToolBox
{
    VTCompressionSessionCompleteFrames(_EncodingSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(_EncodingSession);
    CFRelease(_EncodingSession);
    _EncodingSession = NULL;
}
#pragma mark -- AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    dispatch_sync(_mEncodeQueue, ^{
        [self encode:sampleBuffer];
    });
}
#pragma mark -- getter
/**
 判断当前设备是都支持使用摄像头

 @return YES 可用  NO 不可用
 */
- (BOOL)isSupported {
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
}

@end
