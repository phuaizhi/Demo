//
//  ViewController.m
//  VideoTransferProtocol
//
//  Created by mac on 2018/11/15.
//  Copyright © 2018 mac. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD+LoadingView.h"
#import "KcpOnUdpHelper.h"
#import <VideoToolbox/VideoToolbox.h>
#import "LYOpenGLView.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
/**
 IP地址
 */
@property (weak, nonatomic) IBOutlet UITextField *IPText;
/**
 端口
 */
@property (weak, nonatomic) IBOutlet UITextField *PortText;
@property (strong, nonatomic) KcpOnUdpHelper  *kcp_udp;
@property (nonatomic , strong) LYOpenGLView *mOpenGLView;

@end
const uint8_t lyStartCode[4] = {0, 0, 0, 1};
@implementation ViewController {
    dispatch_queue_t mDecodeQueue;
    VTDecompressionSessionRef mDecodeSession;
    CMFormatDescriptionRef  mFormatDescription;
    uint8_t *mSPS;
    long mSPSSize;
    uint8_t *mPPS;
    long mPPSSize;
    
    // 输入
    NSInputStream *inputStream;
    uint8_t*       packetBuffer;
    long           packetSize;
    uint8_t*       inputBuffer;
    long         inputSize;
    long         inputMaxSize;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//     self.mOpenGLView = [[LYOpenGLView alloc] initWithFrame:self.view.frame];
//    [self.view addSubview:self.mOpenGLView];
    self.mOpenGLView = (LYOpenGLView *)self.view;
    [self.mOpenGLView setupGL];
    
    mDecodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

}
/**
 根据ip和port连接对应服务器

 @param sender 按钮
 */
- (IBAction)startConnactServer:(UIButton *)sender {
    
    if (![self.IPText.text isEqualToString:@""] && ![self.PortText.text isEqualToString:@""]) {
        // 初始化
        self.kcp_udp = [[KcpOnUdpHelper alloc] initWithIP:self.IPText.text withPort:[self.PortText.text integerValue]];
        __weak typeof(self) weakSelf = self;
        self.kcp_udp.dataListener = ^(NSData * _Nonnull data) {
//            NSLog(@"收到的数据%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            NSLog(@"收到数据: %@,length：%d",data,(int)[data length]);
            packetBuffer = [data bytes];
            packetSize = (int)[data length];
            // 解码
            [weakSelf updateFrame];
        };
    } else {
        [MBProgressHUD showLoadingWithText:@"请填写IP和Port" toView:self.view type:LoadingTypeText];
    }
}
-(void)updateFrame {
    if (inputStream || 1){
        dispatch_sync(mDecodeQueue, ^{
//            [self readPacket];
            if(packetBuffer == NULL || packetSize == 0) {
//                [self onInputEnd];
                return ;
            }
            uint32_t nalSize = (uint32_t)(packetSize - 4);
            uint32_t *pNalSize = (uint32_t *)packetBuffer;
            *pNalSize = CFSwapInt32HostToBig(nalSize);
            
            // 在buffer的前面填入代表长度的int
            CVPixelBufferRef pixelBuffer = NULL;
            int nalType = packetBuffer[4] & 0x1F;
            
            switch (nalType) {
                case 0x05:
                    NSLog(@"Nal type is IDR frame");
                    [self initVideoToolBox];
                    pixelBuffer = [self decode];
                    break;
                case 0x07:
                    NSLog(@"Nal type is SPS");
                    mSPSSize = packetSize - 4;
                    mSPS = malloc(mSPSSize);
                    memcpy(mSPS, packetBuffer + 4, mSPSSize);
                    
                    break;
                case 0x08:
                    NSLog(@"Nal type is PPS");
                    mPPSSize = packetSize - 4;
                    mPPS = malloc(mPPSSize);
                    memcpy(mPPS, packetBuffer + 4, mPPSSize);
                    break;
                default:
                    NSLog(@"Nal type is B/P frame");
                    pixelBuffer = [self decode];
                    break;
            }
            if(pixelBuffer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mOpenGLView displayPixelBuffer:pixelBuffer];
                    CVPixelBufferRelease(pixelBuffer);
                });
            }
            NSLog(@"Read Nalu size %ld", packetSize);
        });
    }
}


-(CVPixelBufferRef)decode {
    
    CVPixelBufferRef outputPixelBuffer = NULL;
    if (mDecodeSession) {
        CMBlockBufferRef blockBuffer = NULL;
        OSStatus status  = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                              (void*)packetBuffer, packetSize,
                                                              kCFAllocatorNull,
                                                              NULL, 0, packetSize,
                                                              0, &blockBuffer);
        if(status == kCMBlockBufferNoErr) {
            CMSampleBufferRef sampleBuffer = NULL;
            const size_t sampleSizeArray[] = {packetSize};
            status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                               blockBuffer,
                                               mFormatDescription,
                                               1, 0, NULL, 1, sampleSizeArray,
                                               &sampleBuffer);
            if (status == kCMBlockBufferNoErr && sampleBuffer) {
                VTDecodeFrameFlags flags = 0;
                VTDecodeInfoFlags flagOut = 0;
                // 默认是同步操作。
                // 调用didDecompress，返回后再回调
                OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(mDecodeSession,
                                                                          sampleBuffer,
                                                                          flags,
                                                                          &outputPixelBuffer,
                                                                          &flagOut);
                
                if(decodeStatus == kVTInvalidSessionErr) {
                    NSLog(@"IOS8VT: Invalid session, reset decoder session");
                } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                    NSLog(@"IOS8VT: decode failed status=%d(Bad data)", decodeStatus);
                } else if(decodeStatus != noErr) {
                    NSLog(@"IOS8VT: decode failed status=%d", decodeStatus);
                }
                
                CFRelease(sampleBuffer);
            }
            CFRelease(blockBuffer);
        }
    }
    
    return outputPixelBuffer;
}



- (void)initVideoToolBox {
    if (!mDecodeSession) {
        const uint8_t* parameterSetPointers[2] = {mSPS, mPPS};
        const size_t parameterSetSizes[2] = {mSPSSize, mPPSSize};
        OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                              2, //param count
                                                                              parameterSetPointers,
                                                                              parameterSetSizes,
                                                                              4, //nal start code size
                                                                              &mFormatDescription);
        
        if(status == noErr) {
            CFDictionaryRef attrs = NULL;
            const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
            //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
            //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
            uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
            const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
            attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
            
            VTDecompressionOutputCallbackRecord callBackRecord;
            callBackRecord.decompressionOutputCallback = didDecompress;
            callBackRecord.decompressionOutputRefCon = NULL;
            
            status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                                  mFormatDescription,
                                                  NULL, attrs,
                                                  &callBackRecord,
                                                  &mDecodeSession);
            CFRelease(attrs);
        } else {
            NSLog(@"IOS8VT: reset decoder session failed status=%d", status);
        }
        
        
    }
}
void didDecompress(void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}
- (void)EndVideoToolBox
{
    if(mDecodeSession) {
        VTDecompressionSessionInvalidate(mDecodeSession);
        CFRelease(mDecodeSession);
        mDecodeSession = NULL;
    }
    
    if(mFormatDescription) {
        CFRelease(mFormatDescription);
        mFormatDescription = NULL;
    }
    
    free(mSPS);
    free(mPPS);
    mSPSSize = mPPSSize = 0;
}
#pragma mark - 懒加载


@end
