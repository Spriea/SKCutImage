//
//  SQCutImgEditView.m
//  SQPuzzleClub
//
//  Created by Somer.King on 2020/12/22.
//  Copyright © 2020 Somer.King. All rights reserved.
//

#import "SKCutImgEditView.h"
#import "SKImageZoomView.h"
#import "SKCutImage.h"

#define KBottomMenuHeight 0  //底部菜单高度
#define KGridTopMargin (kSafeTop+20)  //顶部间距
#define KGridBottomMargin kSCALE_X(45)  //底部间距

@interface SKCutImgEditView ()<UIScrollViewDelegate, SKGridViewDelegate, SKImageZoomViewDelegate>

// 缩放视图
@property (nonatomic, strong) SKImageZoomView *zoomView;
//网格视图 裁剪框
@property (nonatomic, strong) SKGridView *gridView;

/// 原始位置区域
@property (nonatomic, assign) CGRect originalRect;
/// 最大裁剪区域
@property (nonatomic, assign) CGRect maxGridRect;

/// 裁剪区域
//@property (nonatomic, assign) CGRect clipRect;
@property (nonatomic, strong) UIButton *recoveryBtn;

/// 当前旋转角度
@property (nonatomic, assign) NSInteger rotateAngle;
/// 图像方向
@property (nonatomic, assign) UIImageOrientation imageOrientation;

@end

@implementation SKCutImgEditView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)showImageView{
    [self setupUI:self.frame];
    self.backgroundColor = Color(@"#1D1D1E");
    self.alpha = 0.001;
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)setupUI:(CGRect)frame{
    self.zoomView.image = self.image;
    self.maxGridRect = CGRectMake(KGridLRMargin, KGridTopMargin, CGRectGetWidth(frame) - KGridLRMargin * 2, CGRectGetHeight(frame) - KGridTopMargin - KGridBottomMargin- KBottomMenuHeight);
    CGSize newSize = CGSizeMake(CGRectGetWidth(frame) - 2 * KGridLRMargin, (CGRectGetWidth(frame) - 2 * KGridLRMargin)*self.image.size.height/self.image.size.width);
    
    if (newSize.height > CGRectGetHeight(self.maxGridRect)) {
        newSize = CGSizeMake(CGRectGetHeight(self.maxGridRect)*self.image.size.width/self.image.size.height, CGRectGetHeight(self.maxGridRect));
    }
    
    self.zoomView.frame = (CGRect){(CGRectGetWidth(frame)-newSize.width)/2,(CGRectGetHeight(frame)-newSize.height)/2.0,newSize};
    
    [self addSubview:self.zoomView];
    self.zoomView.imageView.frame = self.zoomView.bounds;
    self.originalRect = self.zoomView.frame;
    self.gridView.gridRect = self.zoomView.frame;
    self.gridView.maxGridRect = self.maxGridRect;
    self.gridView.originalGridRect = self.zoomView.frame;
    self.gridView.imgWHRatio = self.image.size.width/self.image.size.height;
    
    [self addSubview:self.gridView];
    
    UIButton *reset = [UIButton buttonWithType:UIButtonTypeCustom];
    [reset setTitle:@"还原" forState:UIControlStateNormal];
    [reset setTitleColor:alpColor(@"#FFFFFF", 0.7) forState:UIControlStateNormal];
    reset.titleLabel.font = kFontSize(11);
    reset.frame = CGRectMake(kSCALE_X(167), CGRectGetHeight(frame)-kSCALE_X(37), kSCALE_X(42), kSCALE_X(22));
    reset.layer.cornerRadius = kSCALE_X(11);
    reset.clipsToBounds = YES;
    reset.backgroundColor = alpColor(@"#FFFFFF", 0.15);
    [self addSubview:reset];
    [reset addTarget:self action:@selector(recoveryClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.recoveryBtn = reset;
    reset.alpha = 0.0;
    reset.hidden = YES;
}
/**
 SKCutLayoutTypeFree = 0,
 SKCutLayoutTypeOriginal,
 SKCutLayoutType1_1Ratio,
 SKCutLayoutTypeBackImg,
 SKCutLayoutType4_3Ratio,
 SKCutLayoutType3_4Ratio,
 */
- (void)setClipType:(SKCutLayoutType)clipType{
    _clipType = clipType;
    self.gridView.clipType = clipType;
}

#pragma mark - HelpMethods
- (NSBundle *)LBImageClipControllerBundle
{
    NSBundle *imageClipControllerBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"LBImageClipController" ofType:@"bundle"]];
    return imageClipControllerBundle;
}
- (void)zoomInToRect:(CGRect)gridRect{
    // 正在拖拽或减速
    if (self.zoomView.dragging || self.zoomView.decelerating) {
        return;
    }
    
    CGRect imageRect = [self.zoomView convertRect:self.zoomView.imageView.frame toView:self];
    //当网格往图片边缘(x/y轴方向)移动即将出图片边界时，调整self.zoomView.contentOffset和缩放zoomView大小，把网格外的图片区域逐步移到网格内
    if (!CGRectContainsRect(imageRect,gridRect)) {
        CGPoint contentOffset = self.zoomView.contentOffset;
        if (self.imageOrientation == UIImageOrientationRight) {
            if (CGRectGetMaxX(gridRect) > CGRectGetMaxX(imageRect)) contentOffset.y = 0;
            if (CGRectGetMinY(gridRect) < CGRectGetMinY(imageRect)) contentOffset.x = 0;
        }
        if (self.imageOrientation == UIImageOrientationLeft) {
            if (CGRectGetMinX(gridRect) < CGRectGetMinX(imageRect)) contentOffset.y = 0;
            if (CGRectGetMaxY(gridRect) > CGRectGetMaxY(imageRect)) contentOffset.x = 0;
        }
        if (self.imageOrientation == UIImageOrientationUp) {
            if (CGRectGetMinY(gridRect) < CGRectGetMinY(imageRect)) contentOffset.y = 0;
            if (CGRectGetMinX(gridRect) < CGRectGetMinX(imageRect)) contentOffset.x = 0;
        }
        if (self.imageOrientation == UIImageOrientationDown) {
            if (CGRectGetMaxY(gridRect) > CGRectGetMaxY(imageRect)) contentOffset.y = 0;
            if (CGRectGetMaxX(gridRect) > CGRectGetMaxX(imageRect)) contentOffset.x = 0;
        }
        self.zoomView.contentOffset = contentOffset;
        
        /** 取最大值缩放 */
        CGRect myFrame = self.zoomView.frame;
        myFrame.origin.x = MIN(myFrame.origin.x, gridRect.origin.x);
        myFrame.origin.y = MIN(myFrame.origin.y, gridRect.origin.y);
        myFrame.size.width = MAX(myFrame.size.width, gridRect.size.width);
        myFrame.size.height = MAX(myFrame.size.height, gridRect.size.height);
        self.zoomView.frame = myFrame;
        
//        [self resetMinimumZoomScale];
        [self.zoomView setZoomScale:self.zoomView.zoomScale];
    }
}
- (void)resetMinimumZoomScale:(BOOL)isHight {
    CGRect rotateoriginalRect = CGRectApplyAffineTransform(self.originalRect, self.zoomView.transform);
    if (CGSizeEqualToSize(rotateoriginalRect.size, CGSizeZero)) {
        /** size为0时候不能继续，否则minimumZoomScale=+Inf，会无法缩放 */
        return;
    }
    //设置最小缩放系数
    CGFloat zoomScale = MAX(CGRectGetWidth(self.zoomView.frame) / CGRectGetWidth(rotateoriginalRect), CGRectGetHeight(self.zoomView.frame) / CGRectGetHeight(rotateoriginalRect));
    self.zoomView.minimumZoomScale = zoomScale;
}
- (CGRect)rectOfGridOnImageByGridRect:(CGRect)cropRect {
    CGRect rect = [self convertRect:cropRect toView:self.zoomView.imageView];
    return rect;
}

- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存图片出错%@", error.localizedDescription);
    } else {
        NSLog(@"保存图片成功");
    }
}
- (UIImage *)comfirmCutBack{
    CGRect rect = self.zoomView.imageView.bounds;
    CGRect range = [self rectOfGridOnImageByGridRect:_gridView.gridRect];

    if (CGRectEqualToRect(rect, range)) {
        return nil;
    }
    
    CGImageRef imageRef = self.image.CGImage;
    CGFloat ratio = self.image.size.width/rect.size.width;
    range = CGRectMake(range.origin.x*ratio, range.origin.y*ratio, range.size.width*ratio, range.size.height*ratio);
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, range);
    UIImage *image =[[UIImage alloc] initWithCGImage:imageRefRect];
    CGImageRelease(imageRefRect);
    return image;
}
- (void)recoveryClicked:(UIButton *)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.zoomView.minimumZoomScale = 1;
        self.zoomView.zoomScale = 1;
        self.zoomView.transform = CGAffineTransformIdentity;
        self.zoomView.frame = self.originalRect;
        self.gridView.gridRect = self.zoomView.frame;
        self.rotateAngle = 0;
    }];
    [self setupRecoveryHidden:YES];
}
- (void)setupRecoveryHidden:(BOOL)hidden{
    if (hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            self.recoveryBtn.alpha = 0.0;
        }completion:^(BOOL finished) {
            self.recoveryBtn.hidden = hidden;
        }];
    }else{
        self.recoveryBtn.hidden = hidden;
        [UIView animateWithDuration:0.2 animations:^{
            self.recoveryBtn.alpha = 1.0;
        }];
    }
}

#pragma mark - SLGridViewDelegate
- (void)gridViewDidBeginResizing:(SKGridView *)gridView {
    [self setupRecoveryHidden:YES];
    CGPoint contentOffset = self.zoomView.contentOffset;
    if (self.zoomView.contentOffset.x < 0) contentOffset.x = 0;
    if (self.zoomView.contentOffset.y < 0) contentOffset.y = 0;
    [self.zoomView setContentOffset:contentOffset animated:NO];
}
- (void)gridViewDidResizing:(SKGridView *)gridView {
    //放大到 >= gridRect
//    [self zoomInToRect:gridView.gridRect];
}
- (void)gridViewDidEndResizing:(SKGridView *)gridView {
    [self setupRecoveryHidden:NO];
    CGRect gridRectOfImage = [self rectOfGridOnImageByGridRect:gridView.gridRect];
    //居中
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        CGSize newSize = CGSizeMake(CGRectGetWidth(self.frame) - 2 * KGridLRMargin, (CGRectGetWidth(self.frame) - 2 * KGridLRMargin)*gridView.gridRect.size.height/gridView.gridRect.size.width);
        CGFloat x;
        CGFloat y;
        if (newSize.height > self.gridView.maxGridRect.size.height) {
            newSize = CGSizeMake(self.gridView.maxGridRect.size.height*gridView.gridRect.size.width/gridView.gridRect.size.height, self.gridView.maxGridRect.size.height);
//            x = (CGRectGetWidth(self.frame)-newSize.width)/2;
//            y = KGridTopMargin;
        }
        x = (CGRectGetWidth(self.frame)-newSize.width)/2;
        y = (CGRectGetHeight(self.frame)-KBottomMenuHeight-newSize.height)/2.0;
        CGFloat oriRatio = MIN(self.zoomView.sk_heigth / newSize.height, self.zoomView.sk_width / newSize.width);
//        if (self.zoomView.sk_width > newSize.width) {
//            oriRatio = self.zoomView.sk_width / newSize.width;
//        }else if (self.zoomView.sk_width < newSize.width){
//            oriRatio = newSize.width/ self.zoomView.sk_width;
//        }else{
//            oriRatio = 1.0;
//        }
        
        self.zoomView.frame = (CGRect){x,y,newSize};
        //重置最小缩放系数
        [self resetMinimumZoomScale:NO];
        [self.zoomView setZoomScale:self.zoomView.zoomScale];
        // 调整contentOffset
        CGFloat zoomScale = CGRectGetWidth(self.zoomView.frame)/gridView.gridRect.size.width;
        gridView.gridRect = self.zoomView.frame;
        [self.zoomView setZoomScale:self.zoomView.zoomScale * zoomScale*oriRatio];
        
        CGFloat offSetX = gridRectOfImage.origin.x*self.zoomView.zoomScale;
        CGFloat maxOffX = self.zoomView.imageView.sk_width-self.zoomView.sk_width;
        if (offSetX < 0) {
            offSetX = 0;
        }else if (offSetX > maxOffX){
            offSetX = maxOffX;
        }
        
        CGFloat offSetY = gridRectOfImage.origin.y*self.zoomView.zoomScale;
        CGFloat maxOffY = self.zoomView.imageView.sk_heigth-self.zoomView.sk_heigth;
        if (offSetY < 0) {
            offSetY = 0;
        }else if (offSetY > maxOffY){
            offSetY = maxOffY;
        }
//        SKLog(@"offX: %f,   offY: %f",offSetX,offSetY);
        self.zoomView.contentOffset = CGPointMake(offSetX, offSetY);
    } completion:^(BOOL finished) {
        
    }];
}

// 调整布局
- (void)gridViewLayoutDidChanged:(SKGridView *)gridView widthChange:(BOOL)widthChange{
    if (!CGRectEqualToRect(gridView.gridRect, self.originalRect)) {
        [self setupRecoveryHidden:NO];
    }
    CGRect gridRectOfImage = [self rectOfGridOnImageByGridRect:gridView.gridRect];
    //居中
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        CGSize newSize = CGSizeMake(CGRectGetWidth(self.frame) - 2 * KGridLRMargin, (CGRectGetWidth(self.frame) - 2 * KGridLRMargin)*gridView.gridRect.size.height/gridView.gridRect.size.width);
        
        CGFloat x;
        CGFloat y;
        if (newSize.height > self.gridView.maxGridRect.size.height) {
            newSize = CGSizeMake(self.gridView.maxGridRect.size.height*gridView.gridRect.size.width/gridView.gridRect.size.height, self.gridView.maxGridRect.size.height);
        }
        x = (CGRectGetWidth(self.frame)-newSize.width)/2;
        y = (CGRectGetHeight(self.frame)-KBottomMenuHeight-newSize.height)/2.0;
        CGFloat oriRatio = MIN(self.zoomView.sk_heigth / newSize.height, self.zoomView.sk_width / newSize.width);
        if (!widthChange) {
            oriRatio = 1.0;
        }
        
        self.zoomView.frame = (CGRect){x,y,newSize};
        //重置最小缩放系数
        [self resetMinimumZoomScale:NO];
        [self.zoomView setZoomScale:self.zoomView.zoomScale];
        // 调整contentOffset
        CGFloat zoomScale = CGRectGetWidth(self.zoomView.frame)/gridView.gridRect.size.width;
        gridView.gridRect = self.zoomView.frame;
        [self.zoomView setZoomScale:self.zoomView.zoomScale * zoomScale*oriRatio];
        
        CGFloat offSetX = gridRectOfImage.origin.x*self.zoomView.zoomScale;
        CGFloat maxOffX = self.zoomView.imageView.sk_width-self.zoomView.sk_width;
        if (offSetX < 0) {
            offSetX = 0;
        }else if (offSetX > maxOffX){
            offSetX = maxOffX;
        }
        
        CGFloat offSetY = gridRectOfImage.origin.y*self.zoomView.zoomScale;
        CGFloat maxOffY = self.zoomView.imageView.sk_heigth-self.zoomView.sk_heigth;
        if (offSetY < 0) {
            offSetY = 0;
        }else if (offSetY > maxOffY){
            offSetY = maxOffY;
        }
//        SKLog(@"offX: %f,   offY: %f",offSetX,offSetY);
        self.zoomView.contentOffset = CGPointMake(offSetX, offSetY);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - SLZoomViewDelegate
- (void)zoomViewDidBeginMoveImage:(SKImageZoomView *)zoomView {
    [self setupRecoveryHidden:YES];
    self.gridView.showMaskLayer = NO;
}
- (void)zoomViewDidEndMoveImage:(SKImageZoomView *)zoomView {
    [self setupRecoveryHidden:NO];
    self.gridView.showMaskLayer = YES;
}


- (SKImageZoomView *)zoomView {
    if (!_zoomView) {
        CGFloat zoomHeight = (CGRectGetWidth(self.frame)-KGridLRMargin*2)*self.image.size.height/self.image.size.width;
        _zoomView = [[SKImageZoomView alloc] initWithFrame:CGRectMake(KGridLRMargin, (CGRectGetHeight(self.frame)-KBottomMenuHeight-zoomHeight)/2.0, CGRectGetWidth(self.frame)-KGridLRMargin*2, zoomHeight)];
        _zoomView.backgroundColor = Color(@"#1D1D1E");
        _zoomView.zoomViewDelegate = self;
    }
    return _zoomView;
}
- (SKGridView *)gridView {
    if (!_gridView) {
        _gridView = [[SKGridView alloc] initWithFrame:self.bounds];
        _gridView.delegate = self;
    }
    return _gridView;
}

@end
