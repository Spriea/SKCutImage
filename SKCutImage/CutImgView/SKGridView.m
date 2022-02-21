//
//  SKGridView.m
//  SKCutImage
//
//  Created by Link on 2022/2/11.
//

#import "SKGridView.h"
#import "SKCutImage.h"

#define kLineCount 3
/// 网格遮罩层  网格透明层
@interface SQGridMaskLayer : CAShapeLayer
/// 遮罩颜色
@property (nonatomic, assign) CGColorRef maskColor;
/// 遮罩区域的非交集区域
@property (nonatomic, setter=setMaskRect:) CGRect maskRect;

@property (nonatomic, strong) SQGridMaskLayer *gridMaskLayer; // 半透明遮罩层
@end
@implementation SQGridMaskLayer
//@synthesize maskColor = _maskColor;
#pragma mark - Override
- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentsScale = [[UIScreen mainScreen] scale];
    }
    return self;
}
- (void)setMaskColor:(CGColorRef)maskColor {
    self.fillColor = maskColor;
    // 填充规则  maskRect和bounds的非交集
    self.fillRule = kCAFillRuleEvenOdd;
}
- (void)setMaskRect:(CGRect)maskRect {
    [self setMaskRect:maskRect animated:NO];
}
- (CGColorRef)maskColor {
    return self.fillColor;
}
- (void)setMaskRect:(CGRect)maskRect animated:(BOOL)animated {
    CGMutablePathRef mPath = CGPathCreateMutable();
    CGPathAddRect(mPath, NULL, self.bounds);
    CGPathAddRect(mPath, NULL, maskRect);
    [self removeAnimationForKey:@"SK_maskLayer_opacityAnimate"];
    if (animated) {
        CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animate.duration = 0.25f;
        animate.fromValue = @(0.0);
        animate.toValue = @(1.0);
        self.path = mPath;
        [self addAnimation:animate forKey:@"SK_maskLayer_opacityAnimate"];
    } else {
        self.path = mPath;
    }
}
@end

/// 网格层
@interface SQGridLayer : CAShapeLayer
///网格区域 默认CGRectZero
@property (nonatomic, assign) CGRect gridRect;
///网格颜色  默认黑色
@property (nonatomic, strong) UIColor *gridColor;
/// 背景  默认透明
@property (nonatomic, strong) UIColor *bgColor;

@property (strong, nonatomic) CAShapeLayer *cornorShape;
@property (strong, nonatomic) CAShapeLayer *lineShape;


@end
@implementation SQGridLayer
- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentsScale = [[UIScreen mainScreen] scale];
        self.shadowColor = [UIColor blackColor].CGColor;
        self.shadowRadius = 3.f;
        self.shadowOffset = CGSizeZero;
        self.shadowOpacity = .4f;
        _bgColor = [UIColor clearColor];
        _gridColor = [UIColor blackColor];
    }
    return self;
}
- (void)setGridRect:(CGRect)gridRect {
    [self setGridRect:gridRect animated:NO];
}
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated {
    if (!CGRectEqualToRect(_gridRect, gridRect)) {
        _gridRect = gridRect;
        CGPathRef path = [self drawGrid];
        if (animated) {
            CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"path"];
            animate.duration = 0.25f;
            animate.fromValue = (__bridge id _Nullable)(self.path);
            animate.toValue = (__bridge id _Nullable)(path);
            //            animate.fillMode=kCAFillModeForwards;
            [self addAnimation:animate forKey:@"lf_gridLayer_contentsRectAnimate"];
        }
        self.path = path;
    }
}

- (void)setLineLayerHidden:(BOOL)hidden {
//    [self.lineShape removeAnimationForKey:@"opacityAnimate_line"];
    if (hidden) {
//        CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        animate.duration = 0.25f;
//        animate.fromValue = @(1.0);
//        animate.toValue = @(0.0);
//        [self.lineShape addAnimation:animate forKey:@"opacityAnimate_line"];
        self.lineShape.opacity = 1.0;
    }else{
        self.lineShape.opacity = 0;
    }
}
- (CGPathRef)drawGrid {
    self.fillColor = self.bgColor.CGColor;
    self.strokeColor = self.gridColor.CGColor;
    
    CGRect rct = self.gridRect;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rct];
    
    UIBezierPath *linePath = [UIBezierPath new];
    
    CGFloat dW = _gridRect.size.width/(kLineCount+1);
    for(int i = 0;i <= kLineCount;++ i){ /** 竖线 */
        [linePath moveToPoint:CGPointMake(rct.origin.x+dW, rct.origin.y)];
        [linePath addLineToPoint:CGPointMake(rct.origin.x+dW, rct.origin.y+rct.size.height)];
        dW += _gridRect.size.width/(kLineCount+1);
    }
    dW = rct.size.height/(kLineCount+1);
    for(int i=0;i <= kLineCount;++i){ /** 横线 */
        [linePath moveToPoint:CGPointMake(rct.origin.x, rct.origin.y+dW)];
        [linePath addLineToPoint:CGPointMake(rct.origin.x+rct.size.width, rct.origin.y+dW)];
        dW += rct.size.height/(kLineCount+1);
    }
    self.lineShape.path = linePath.CGPath;
    /** 偏移量 */
//    CGFloat offset = 1;
    /** 长度 */
    CGFloat cornerlength = 15.f;
//    CGRect newRct = CGRectInset(rct, -offset, -offset);
    CGRect newRct = rct;
    UIBezierPath *conorPath = [[UIBezierPath alloc] init];
    
    /** 左上角 */
    [conorPath moveToPoint:CGPointMake(CGRectGetMinX(newRct) , CGRectGetMinY(newRct)+cornerlength)];
    [conorPath addLineToPoint:CGPointMake(CGRectGetMinX(newRct) , CGRectGetMinY(newRct))];
    [conorPath addLineToPoint:CGPointMake(CGRectGetMinX(newRct)+cornerlength , CGRectGetMinY(newRct))];
    /** 右上角 */
    [conorPath moveToPoint:CGPointMake(CGRectGetMaxX(newRct)-cornerlength , CGRectGetMinY(newRct))];
    [conorPath addLineToPoint:CGPointMake(CGRectGetMaxX(newRct) , CGRectGetMinY(newRct))];
    [conorPath addLineToPoint:CGPointMake(CGRectGetMaxX(newRct) , CGRectGetMinY(newRct)+cornerlength)];
    /** 右下角 */
    [conorPath moveToPoint:CGPointMake(CGRectGetMaxX(newRct) , CGRectGetMaxY(newRct)-cornerlength)];
    [conorPath addLineToPoint:CGPointMake(CGRectGetMaxX(newRct) , CGRectGetMaxY(newRct))];
    [conorPath addLineToPoint:CGPointMake(CGRectGetMaxX(newRct)-cornerlength , CGRectGetMaxY(newRct))];
    /** 左下角 */
    [conorPath moveToPoint:CGPointMake(CGRectGetMinX(newRct)+cornerlength , CGRectGetMaxY(newRct))];
    [conorPath addLineToPoint:CGPointMake(CGRectGetMinX(newRct) , CGRectGetMaxY(newRct))];
    [conorPath addLineToPoint:CGPointMake(CGRectGetMinX(newRct) , CGRectGetMaxY(newRct)-cornerlength)];
    
    self.cornorShape.path = conorPath.CGPath;
    
    return path.CGPath;
}

- (CAShapeLayer *)cornorShape{
    if (!_cornorShape) {
        _cornorShape = [CAShapeLayer new];
        _cornorShape.shadowColor = [UIColor blackColor].CGColor;
        _cornorShape.shadowRadius = 3.f;
        _cornorShape.shadowOffset = CGSizeZero;
        _cornorShape.shadowOpacity = .4f;
        _cornorShape.contentsScale = [[UIScreen mainScreen] scale];
        _cornorShape.lineWidth = 3.f;
        _cornorShape.fillColor = [UIColor clearColor].CGColor;
        _cornorShape.strokeColor = [UIColor whiteColor].CGColor;
    }
    return _cornorShape;
}
- (CAShapeLayer *)lineShape{
    if (!_lineShape) {
        _lineShape = [CAShapeLayer new];
        _lineShape.shadowColor = [UIColor blackColor].CGColor;
        _lineShape.shadowRadius = 3.f;
        _lineShape.shadowOffset = CGSizeZero;
        _lineShape.shadowOpacity = .4f;
        _lineShape.contentsScale = [[UIScreen mainScreen] scale];
        _lineShape.lineWidth = 1.f;
        _lineShape.fillColor = [UIColor clearColor].CGColor;
        _lineShape.strokeColor = alpColor(@"#FFFFFF", 0.2).CGColor;
    }
    return _lineShape;
}
@end

@class SQResizeControl;
@protocol SQResizeControlDelegate <NSObject>
/// 开始
- (void)resizeConrolDidBeginResizing:(SQResizeControl *)resizeConrol;
- (void)resizeConrolDidResizing:(SQResizeControl *)resizeConrol;
- (void)resizeConrolDidEndResizing:(SQResizeControl *)resizeConrol;
@end
/// 网格四边和四角控制大小的透明视图
@interface SQResizeControl : UIView
@property (weak, nonatomic) id<SQResizeControlDelegate> delegate;
@property (nonatomic, readwrite) CGPoint translation;
@property (nonatomic) CGPoint startPoint; 
@property (nonatomic, getter=isEnabled) BOOL enabled; //手势是否可用
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizer;
@end
@implementation SQResizeControl
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:gestureRecognizer];
        _gestureRecognizer = gestureRecognizer;
    }
    return self;
}
- (BOOL)isEnabled {
    return _gestureRecognizer.isEnabled;
}
- (void)setEnabled:(BOOL)enabled {
    _gestureRecognizer.enabled = enabled;
}
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint translationInView = [gestureRecognizer translationInView:self.superview];
        self.startPoint = CGPointMake(roundf(translationInView.x), translationInView.y);
        if ([self.delegate respondsToSelector:@selector(resizeConrolDidBeginResizing:)]) {
            [self.delegate resizeConrolDidBeginResizing:self];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        self.translation = CGPointMake(roundf(self.startPoint.x + translation.x),
                                       roundf(self.startPoint.y + translation.y));
        
        if ([self.delegate respondsToSelector:@selector(resizeConrolDidResizing:)]) {
            [self.delegate resizeConrolDidResizing:self];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if ([self.delegate respondsToSelector:@selector(resizeConrolDidEndResizing:)]) {
            [self.delegate resizeConrolDidEndResizing:self];
        }
    }
}
@end

// 网格四角和边的 可控范围
const CGFloat kSQControlWidth = 30;
//网格视图
@interface SKGridView ()<SQResizeControlDelegate>
@property (nonatomic, strong) SQGridLayer *gridLayer; //网格层

@property (nonatomic, strong) SQGridMaskLayer *opicayCLayer; // 半透明遮罩层
@property (nonatomic, strong) SQGridMaskLayer *gridMaskLayer; // 半透明遮罩层
@property (nonatomic, strong) UIVisualEffectView *coverView; //
@property (nonatomic, strong) CAShapeLayer *cornorLayer; // 4个角
@property (nonatomic, strong) CAShapeLayer *linLayer;  // 线段
@property (nonatomic, assign) CGRect initialRect; //高亮网格框的初始区域
//四个角
@property (nonatomic, strong) SQResizeControl *topLeftCornerView;
@property (nonatomic, strong) SQResizeControl *topRightCornerView;
@property (nonatomic, strong) SQResizeControl *bottomLeftCornerView;
@property (nonatomic, strong) SQResizeControl *bottomRightCornerView;
//四条边
@property (nonatomic, strong) SQResizeControl *topEdgeView;
@property (nonatomic, strong) SQResizeControl *leftEdgeView;
@property (nonatomic, strong) SQResizeControl *bottomEdgeView;
@property (nonatomic, strong) SQResizeControl *rightEdgeView;

@property (assign, nonatomic) CGFloat wRatio;
@property (assign, nonatomic) CGFloat ratio;
@end

@implementation SKGridView
#pragma mark - Override
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.wRatio = 0.5;
        self.ratio = 1.0;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.gridLayer.frame = self.bounds;
    self.gridMaskLayer.frame = self.bounds;
    [self updateResizeControlFrame];
}
// 事件传给下层的缩放视图SQZoomView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (self == view) {
        return nil;
    }
    [self enableCornerViewUserInteraction:view];
    return view;
}
// 设置控制网格大小视图的用户交互 防止手指同时控制多个按钮
- (void)enableCornerViewUserInteraction:(UIView *)view {
    for (UIView *control in self.subviews) {
        if ([control isKindOfClass:[SQResizeControl class]]) {
            if (view) {
                if (control == view) {
                    control.userInteractionEnabled = YES;
                } else {
                    control.userInteractionEnabled = NO;
                }
            } else {
                control.userInteractionEnabled = YES;
            }
        }
    }
}
#pragma mark - UI
- (void)setupUI {
    self.minGridSize = CGSizeMake(60, 60);
    self.maxGridRect = self.bounds;

//    self.minGridSize = CGSizeMake(60, 60);
//    self.maxGridRect = CGRectInset(self.bounds, 20, 20);
//    self.originalGridSize = self.gridRect.size;
    self.showMaskLayer = YES;
    
    [self.layer addSublayer:self.opicayCLayer];
    [self.layer addSublayer:self.gridLayer];
    [self.layer addSublayer:self.cornorLayer];
    [self.layer addSublayer:self.linLayer];
    [self addSubview:self.coverView];
    
    self.topLeftCornerView = [self createResizeControl];
    self.topRightCornerView = [self createResizeControl];
    self.bottomLeftCornerView = [self createResizeControl];
    self.bottomRightCornerView = [self createResizeControl];
    
    self.topEdgeView = [self createResizeControl];
    self.leftEdgeView = [self createResizeControl];
    self.bottomEdgeView = [self createResizeControl];
    self.rightEdgeView = [self createResizeControl];
}

- (void)setClipType:(SKCutLayoutType)clipType{
    _clipType = clipType;
    CGFloat ratio;
    switch (clipType) {
        case SKCutLayoutTypeFree:{
            ratio = 1.0;
            self.wRatio = 0.5;
        }break;
        case SKCutLayoutTypeOriginal:{
            ratio = CGRectGetWidth(self.originalGridRect)/CGRectGetHeight(self.originalGridRect);
            self.wRatio = CGRectGetWidth(self.originalGridRect)/(CGRectGetWidth(self.originalGridRect)+CGRectGetHeight(self.originalGridRect));
            self.gridRect = self.originalGridRect;
            if ([self.delegate respondsToSelector:@selector(gridViewLayoutDidChanged:widthChange:)]) {
                [self.delegate gridViewLayoutDidChanged:self widthChange:NO];
            }
        }break;
        case SKCutLayoutType1_1Ratio:{
            ratio = 1.0;
            self.wRatio = 0.5;
            [self layoutClipType:1.0];
        }break;
        case SKCutLayoutTypeBackImg:{
            ratio = kScreenW/kScreenH;
            self.wRatio = kScreenW/(kScreenW+kScreenH);
            CGFloat x,y,W,H;
            H = CGRectGetHeight(self.maxGridRect);
            W = H*ratio;
            CGFloat offy = (CGRectGetHeight(self.gridRect)-
                            H)*0.5;
            y = offy +CGRectGetMinY(self.gridRect);
            x = (kScreenW-W)*0.5;
            self.gridRect = CGRectMake(x, y, W, H);
            if ([self.delegate respondsToSelector:@selector(gridViewLayoutDidChanged:widthChange:)]) {
                [self.delegate gridViewLayoutDidChanged:self widthChange:NO];
            }
        }break;
        case SKCutLayoutType3_4Ratio:{
            ratio = 3.0/4;
            self.wRatio = 3.0/7;
            [self layoutClipType:4.0/3];
        }break;
        case SKCutLayoutType4_3Ratio:{
            ratio = 4.0/3;
            self.wRatio = 4.0/7;
            [self layoutClipType:3.0/4];
        }break;
        default:
            self.wRatio = 0.5;
            ratio = 1.0;
            break;
    }
    
    CGFloat minW,minH;
    if (ratio > 1.0) {
        minH = 60;
        minW = minH*ratio;
    }else{
        minW = 60;
        minH = minW/ratio;
    }
    self.ratio = ratio;
    self.minGridSize = CGSizeMake(minW, minH);
}

- (void)layoutClipType:(CGFloat)ratio{
    CGFloat x,y,W,H;
    W = CGRectGetWidth(self.maxGridRect);
    H = W*ratio;
    CGFloat offy = (CGRectGetHeight(self.gridRect)-
                    H)*0.5;
    x = CGRectGetMinX(self.maxGridRect);
    y = offy +CGRectGetMinY(self.gridRect);
    self.gridRect = CGRectMake(x, y, W, H);
    if ([self.delegate respondsToSelector:@selector(gridViewLayoutDidChanged:widthChange:)]) {
        [self.delegate gridViewLayoutDidChanged:self widthChange:NO];
    }
}

- (SQResizeControl *)createResizeControl {
    SQResizeControl *control = [[SQResizeControl alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(kSQControlWidth, kSQControlWidth)}];
    control.delegate = self;
    //    control.backgroundColor = [UIColor redColor];
    [self addSubview:control];
    control.userInteractionEnabled = YES;
    return control;
}

#pragma mark - Getter
- (SQGridMaskLayer *)gridMaskLayer {
    if (!_gridMaskLayer) {
        _gridMaskLayer = [[SQGridMaskLayer alloc] init];
        _gridMaskLayer.frame = self.bounds;
        _gridMaskLayer.maskColor = [UIColor colorWithWhite:.0f alpha:1.0].CGColor;
    }
    return _gridMaskLayer;
}
- (SQGridMaskLayer *)opicayCLayer {
    if (!_opicayCLayer) {
        _opicayCLayer = [[SQGridMaskLayer alloc] init];
        _opicayCLayer.frame = self.bounds;
        _opicayCLayer.maskColor = [UIColor colorWithWhite:.0f alpha:0.5].CGColor;
    }
    return _opicayCLayer;
}

- (SQGridLayer *)gridLayer {
    if (!_gridLayer) {
        _gridLayer = [[SQGridLayer alloc] init];
        _gridLayer.frame = self.bounds;
        _gridLayer.lineWidth = 1.f;
        _gridLayer.gridColor = [UIColor whiteColor];
        _gridLayer.gridRect = CGRectInset(self.bounds, 20, 20);
        _gridLayer.cornorShape.frame = self.bounds;
        _gridLayer.lineShape.frame = self.bounds;
        self.cornorLayer = _gridLayer.cornorShape;
        self.linLayer = _gridLayer.lineShape;
    }
    return _gridLayer;
}
- (UIVisualEffectView *)coverView{
    if (!_coverView) {
//        _coverView = [[UIView alloc] initWithFrame:self.bounds];
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.userInteractionEnabled = NO;
        effectView.layer.mask = self.gridMaskLayer;
        effectView.frame = self.bounds;
        _coverView = effectView;
    }
    return _coverView;
}
#pragma mark - Setter
- (void)setGridRect:(CGRect)gridRect {
    [self setGridRect:gridRect maskLayer:YES];
}
- (void)setShowMaskLayer:(BOOL)showMaskLayer {
    if (_showMaskLayer != showMaskLayer) {
        _showMaskLayer = showMaskLayer;
        if (showMaskLayer) {
            /** 还原遮罩 */
            [self.gridMaskLayer setMaskRect:self.gridRect animated:NO];
//            [self.opicayCLayer setMaskRect:self.gridRect animated:NO];
            [self.opicayCLayer setMaskRect:self.opicayCLayer.bounds animated:NO];
//            kWEAK_SELF(weakS)
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakS.opicayCLayer setMaskRect:weakS.opicayCLayer.bounds animated:NO];
//            });
        } else {
            /** 扩大遮罩范围 */
            [self.gridMaskLayer setMaskRect:self.gridMaskLayer.bounds animated:YES];
            [self.opicayCLayer setMaskRect:self.gridRect animated:NO];
        }
        [self.gridLayer setLineLayerHidden:!showMaskLayer];
    }
    /** 简单粗暴的禁用拖动事件 */
    self.userInteractionEnabled = showMaskLayer;
}

#pragma mark - HelpMethods
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer {
    [self setGridRect:gridRect maskLayer:isMaskLayer animated:NO];
}
//- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated {
//    [self setGridRect:gridRect maskLayer:NO animated:animated];
//}
// 更新网格区域和遮罩状态
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer  animated:(BOOL)animated {
    if (!CGRectEqualToRect(_gridRect, gridRect)) {
        _gridRect = gridRect;
        [self setNeedsLayout];
        [self.gridLayer setGridRect:gridRect animated:animated];
        if (isMaskLayer) {
            [self.gridMaskLayer setMaskRect:gridRect animated:YES];
        }
    }
}
// 更新控制调整网格大小的四个角和边的frame
- (void)updateResizeControlFrame {
    CGRect rect = self.gridRect;
    self.topLeftCornerView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.topLeftCornerView.bounds) / 2, CGRectGetMinY(rect) - CGRectGetHeight(self.topLeftCornerView.bounds) / 2, self.topLeftCornerView.bounds.size};
    self.topRightCornerView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.topRightCornerView.bounds) / 2, CGRectGetMinY(rect) - CGRectGetHeight(self.topRightCornerView.bounds) / 2, self.topRightCornerView.bounds.size};
    self.bottomLeftCornerView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.bottomLeftCornerView.bounds) / 2, CGRectGetMaxY(rect) - CGRectGetHeight(self.bottomLeftCornerView.bounds) / 2, self.bottomLeftCornerView.bounds.size};
    self.bottomRightCornerView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.bottomRightCornerView.bounds) / 2, CGRectGetMaxY(rect) - CGRectGetHeight(self.bottomRightCornerView.bounds) / 2, self.bottomRightCornerView.bounds.size};
    
    self.topEdgeView.frame = (CGRect){CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetMinY(rect) - CGRectGetHeight(self.topEdgeView.frame) / 2, CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetHeight(self.topEdgeView.bounds)};
    self.leftEdgeView.frame = (CGRect){CGRectGetMinX(rect) - CGRectGetWidth(self.leftEdgeView.frame) / 2, CGRectGetMaxY(self.topLeftCornerView.frame), CGRectGetWidth(self.leftEdgeView.bounds), CGRectGetMinY(self.bottomLeftCornerView.frame) - CGRectGetMaxY(self.topLeftCornerView.frame)};
    self.bottomEdgeView.frame = (CGRect){CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetMinY(self.bottomLeftCornerView.frame), CGRectGetMinX(self.bottomRightCornerView.frame) - CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetHeight(self.bottomEdgeView.bounds)};
    self.rightEdgeView.frame = (CGRect){CGRectGetMaxX(rect) - CGRectGetWidth(self.rightEdgeView.bounds) / 2, CGRectGetMaxY(self.topRightCornerView.frame), CGRectGetWidth(self.rightEdgeView.bounds), CGRectGetMinY(self.bottomRightCornerView.frame) - CGRectGetMaxY(self.topRightCornerView.frame)};
}

//返回正在调整网格大小时的网格区域
- (CGRect)cropRectMakeWithResizeControlView:(SQResizeControl *)resizeControlView {
    CGRect rect = self.gridRect;
    CGFloat initX = CGRectGetMinX(self.initialRect);
    CGFloat initY = CGRectGetMinY(self.initialRect);
    CGFloat initW = CGRectGetWidth(self.initialRect);
    CGFloat initH = CGRectGetHeight(self.initialRect);
    CGFloat offsetX = resizeControlView.translation.x;
    CGFloat offsetY = resizeControlView.translation.y;
    if (resizeControlView == self.topEdgeView) {
        if (self.clipType != SKCutLayoutTypeFree) {
            CGFloat transx =  offsetY*initW/initH;
            initX = initX+transx*0.5;
            initY = initY + offsetY;
            initW = initW-transx;
            initH = initH - offsetY;
        }else{
            initY = initY + offsetY;
            initH = initH - offsetY;;
        }
    } else if (resizeControlView == self.leftEdgeView) {
        if (self.clipType != SKCutLayoutTypeFree) {
            CGFloat transy =  offsetX*initH/initW;
            initY = initY + transy*0.5;
            initH = initH - transy;
            initX = initX + offsetX;
            initW = initW - offsetX;
        }else{
            initX = initX + offsetX;
            initW = initW - offsetX;
        }
    } else if (resizeControlView == self.bottomEdgeView) {
        if (self.clipType != SKCutLayoutTypeFree) {
            CGFloat transx =  offsetY*initW/initH;
            initX = initX-transx*0.5;
            initW = initW+transx;
            initH = initH + offsetY;
        }else{
            initH = initH + offsetY;
        }
    } else if (resizeControlView == self.rightEdgeView) {
        if (self.clipType != SKCutLayoutTypeFree) {
            CGFloat transy =  offsetX*initH/initW;
            initY = initY - transy*0.5;
            initH = initH + transy;
            initW = initW + offsetX;
        }else{
            initW = initW + offsetX;
        }
    }
    
    
    
    
    else if (resizeControlView == self.topLeftCornerView) {
        if (self.clipType != SKCutLayoutTypeFree) {
            CGFloat transM =  (offsetX+offsetY);
            CGFloat wRx = transM * self.wRatio;
            CGFloat wRy = transM - wRx;
            initX = initX + wRx;
            initY = initY + wRy;
            initW = initW - wRx;
            initH = initH - wRy;
        }else{
            initX = initX + offsetX;
            initY = initY + offsetY;
            initW = initW - offsetX;
            initH = initH - offsetY;
        }
    } else if (resizeControlView == self.topRightCornerView) {
        if (self.clipType != SKCutLayoutTypeFree) {
            CGFloat transM =  (offsetY-offsetX);
            CGFloat wRx = transM * self.wRatio;
            CGFloat wRy = transM - wRx;
            initY = initY + wRy;
            initW = initW - wRx;
            initH = initH - wRy;
        }else{
            initY = initY + offsetY;
            initW = initW + offsetX;
            initH = initH - offsetY;
        }
    } else if (resizeControlView == self.bottomLeftCornerView) {
        if (self.clipType != SKCutLayoutTypeFree) {
            CGFloat transM =  (offsetX-offsetY);
            CGFloat wRx = transM * self.wRatio;
            CGFloat wRy = transM - wRx;
            initX = initX + wRx;
            initW = initW - wRx;
            initH = initH - wRy;
        }else{
            initX = initX + offsetX;
            initW = initW - offsetX;
            initH = initH + offsetY;
        }
    } else if (resizeControlView == self.bottomRightCornerView) {
        if (self.clipType != SKCutLayoutTypeFree) {
            CGFloat transM =  (offsetX+offsetY);
            CGFloat wRx = transM * self.wRatio;
            CGFloat wRy = transM - wRx;
            initW = initW + wRx;
            initH = initH + wRy;
        }else{
            initW = initW + offsetX;
            initH = initH + offsetY;
        }
    }
    rect = CGRectMake(initX,initY,initW,initH);
    /** 限制x/y 超出左上角 最大限度 */
    if (ceil(rect.origin.x) < ceil(CGRectGetMinX(_maxGridRect))) {
        rect.origin.x = _maxGridRect.origin.x;
        rect.size.width = CGRectGetMaxX(self.initialRect)-rect.origin.x;
    }
//    if (ceil(rect.origin.y) < ceil(CGRectGetMinY(_maxGridRect))) {
//        rect.origin.y = _maxGridRect.origin.y;
//        rect.size.height = CGRectGetMaxY(self.initialRect)-rect.origin.y;
//    }
    /** 限制宽度／高度 超出 最大限度 */
    if (ceil(rect.origin.x+rect.size.width) >= ceil(CGRectGetMaxX(_maxGridRect))) {
        rect.size.width = CGRectGetMaxX(_maxGridRect) - CGRectGetMinX(rect);
        if (self.clipType != SKCutLayoutTypeFree) {
            rect.size.height = rect.size.width/self.ratio;
        }
    }
    if (ceil(rect.origin.y+rect.size.height) >= ceil(CGRectGetMaxY(_maxGridRect))) {
        rect.size.height = CGRectGetMaxY(_maxGridRect) - CGRectGetMinY(rect);
        if (self.clipType != SKCutLayoutTypeFree) {
            rect.size.width = rect.size.height*self.ratio;
        }
    }
   
    /** 限制宽度／高度 小于 最小限度 */
    if (ceil(rect.size.width) <= ceil(_minGridSize.width)) {
        /** 左上、左、左下 处理x最小值 */
        if (resizeControlView == self.topLeftCornerView || resizeControlView == self.leftEdgeView || resizeControlView == self.bottomLeftCornerView) {
            rect.origin.x = CGRectGetMaxX(self.initialRect) - _minGridSize.width;
        }
        if (self.clipType != SKCutLayoutTypeFree) {
            if (resizeControlView == self.leftEdgeView || resizeControlView == self.rightEdgeView) {
                rect.origin.y = CGRectGetMinY(self.initialRect) + (CGRectGetHeight(self.initialRect) - _minGridSize.height)*0.5;
            }
        }
        rect.size.width = _minGridSize.width;
    }
    if (ceil(rect.size.height) <= ceil(_minGridSize.height)) {
        /** 左上、上、右上 处理y最小值底部 */
        if (resizeControlView == self.topLeftCornerView || resizeControlView == self.topEdgeView || resizeControlView == self.topRightCornerView) {
            rect.origin.y = CGRectGetMaxY(self.initialRect) - _minGridSize.height;
        }
        if (self.clipType != SKCutLayoutTypeFree) {
            if (resizeControlView == self.topEdgeView || resizeControlView == self.bottomEdgeView) {
                rect.origin.x = CGRectGetMinX(self.initialRect) + (CGRectGetWidth(self.initialRect) - _minGridSize.width)*0.5;
            }
        }
        rect.size.height = _minGridSize.height;
    }
    [self.opicayCLayer setMaskRect:rect animated:NO];
    return rect;
}

#pragma mark - SQResizeControlDelegate
- (void)resizeConrolDidBeginResizing:(SQResizeControl *)resizeConrol {
    self.initialRect = self.gridRect;
    _dragging = YES;
    self.showMaskLayer = NO;
    if ([self.delegate respondsToSelector:@selector(gridViewDidBeginResizing:)]) {
        [self.delegate gridViewDidBeginResizing:self];
    }
}
- (void)resizeConrolDidResizing:(SQResizeControl *)resizeConrol {
    CGRect gridRect = [self cropRectMakeWithResizeControlView:resizeConrol];
    [self setGridRect:gridRect maskLayer:NO];
    if ([self.delegate respondsToSelector:@selector(gridViewDidResizing:)]) {
        [self.delegate gridViewDidResizing:self];
    }
}
- (void)resizeConrolDidEndResizing:(SQResizeControl *)resizeConrol {
    [self enableCornerViewUserInteraction:nil];
    _dragging = NO;
    self.showMaskLayer = YES;
    if ([self.delegate respondsToSelector:@selector(gridViewDidEndResizing:)]) {
        [self.delegate gridViewDidEndResizing:self];
    }
}

@end
