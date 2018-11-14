//
//  HZGestureLockView.m
//  HZGestureLock
//
//  Created by mac on 2018/10/16.
//  Copyright © 2018 mac. All rights reserved.
//

#import "HZGestureLockView.h"


// 屏幕的宽。高
#define Wscreen  [UIScreen mainScreen].bounds.size.width
#define Hscreen  [UIScreen mainScreen].bounds.size.height
// 按钮的背景图
#define item     @"item"
#define select_item  @"select_item"
// 列
NSInteger const lockCol = 3;
// 点的数量
NSInteger const itemCount = 3 * lockCol;
// 按钮之间的间距 上下左右间距相同
CGFloat  const  btnMargin = 50;

@interface HZGestureLockView()
{
    BOOL _isFirstPoint;// 记录第一个点
}
/**
 存储每个item
 */
@property (strong, nonatomic) NSMutableArray *itemArr;
/**
 存储选中item
 */
@property (strong, nonatomic) NSMutableArray *selectItemArr;
/**
 配合贝塞尔曲线连接划线
 */
@property (strong, nonatomic) CAShapeLayer   *lineLayer;
@property (strong, nonatomic) UIBezierPath   *linePath;
@property (assign, nonatomic) CGPoint movePoint;

@end

@implementation HZGestureLockView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame])
    {
        // 初始化布局
        [self initLockView];
        _isFirstPoint = NO;
    }
    return self;
}
- (void)initLockView {
    
    // 按钮的宽高  两者相同
    CGFloat btnW = (self.frame.size.width - (lockCol-1)*btnMargin)/lockCol;
    // 根据列来计算按钮的布局 创建item
    for (NSInteger i=0; i<itemCount; i++) {
        UIButton *itemBtn = [[UIButton alloc]initWithFrame:CGRectMake((i%lockCol)*(btnW+btnMargin), (i/lockCol)*(btnW+btnMargin), btnW, btnW)];
        [itemBtn setImage:[UIImage imageNamed:item] forState:UIControlStateNormal];
        [itemBtn setTag:i+100];
        [itemBtn setUserInteractionEnabled:NO];
        [itemBtn.layer setCornerRadius:btnW*0.5];
        [self.itemArr addObject:itemBtn];
        [self addSubview:itemBtn];
    }
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 有点时更新线的路径
    UIBezierPath *path = [[UIBezierPath alloc]init];
    if(self.selectItemArr.count > 0)
    {
        UIButton *firstBtn = self.selectItemArr[0];
        [path moveToPoint:firstBtn.center];
        [self.selectItemArr enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
            if(idx > 0)
            {
                [path addLineToPoint:btn.center];
            }
        }];
        if(!CGPointEqualToPoint(self.movePoint, CGPointZero))
        {
            [path addLineToPoint:self.movePoint];
        }
        [self.lineLayer setPath:path.CGPath];
    }
    else
    {
        [self.lineLayer removeFromSuperlayer];
        self.lineLayer = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point =  [touch locationInView:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.itemArr enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
            // 遍历所有的item 看触发的点是否在按钮上如果在就改变按钮的图片并记录这个点
            dispatch_async(dispatch_get_main_queue(), ^{
                if (CGRectContainsPoint(btn.frame, point))
                {
                    [btn setImage:[UIImage imageNamed:select_item] forState:UIControlStateNormal];
                    // 记录按钮的中心点 进行划线
                    if(![self.selectItemArr containsObject:btn])
                    {
                        [self.selectItemArr addObject:btn];
                    }
                }
                self.movePoint = point;
                [self setNeedsDisplay];
            });
        }];
    });
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    NSLog(@"%@",self.selectItemArr);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.itemArr enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
            // 遍历所有的item
            [btn setImage:[UIImage imageNamed:item] forState:UIControlStateNormal];
        }];
        [self.selectItemArr removeAllObjects];
        self.movePoint = CGPointZero;
        [self setNeedsDisplay];
    });
    
}
#pragma mark - getter
- (NSMutableArray *)selectItemArr {
    if(_selectItemArr == nil)
    {
        _selectItemArr = [NSMutableArray array];
    }
    return _selectItemArr;
}
- (NSMutableArray *)itemArr {
    if(_itemArr == nil)
    {
        _itemArr = [NSMutableArray array];
    }
    return _itemArr;
}
- (CAShapeLayer *)lineLayer {
    if(_lineLayer == nil)
    {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.fillColor = [UIColor clearColor].CGColor;
        _lineLayer.lineWidth = 5;
        _lineLayer.lineJoin = @"round";
        _lineLayer.strokeColor = [UIColor blueColor].CGColor;
        [self.layer addSublayer:_lineLayer];
    }
    return _lineLayer;
}
- (UIBezierPath *)linePath {
    if(_linePath == nil)
    {
        _linePath = [[UIBezierPath alloc]init];
    }
    return _linePath;
}
@end
