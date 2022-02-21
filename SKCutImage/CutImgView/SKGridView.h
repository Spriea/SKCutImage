//
//  SKGridView.h
//  SKCutImage
//
//  Created by Link on 2022/2/11.
//

#import <UIKit/UIKit.h>
#define KGridLRMargin kSCALE_X(13.5)   //左右边距

/** 图片剪切比例类型*/
typedef NS_ENUM(NSInteger, SKCutLayoutType) {
    SKCutLayoutTypeFree = 0,
    SKCutLayoutTypeOriginal,
    SKCutLayoutType1_1Ratio,
    SKCutLayoutTypeBackImg,
    SKCutLayoutType3_4Ratio,
    SKCutLayoutType4_3Ratio,
};
NS_ASSUME_NONNULL_BEGIN
@class SKGridView;
/// 网格调整大小代理
@protocol SKGridViewDelegate <NSObject>
@optional
/// 开始调整大小
- (void)gridViewDidBeginResizing:(SKGridView *)gridView;
/// 正在调整大小
- (void)gridViewDidResizing:(SKGridView *)gridView;
/// 结束调整大小
- (void)gridViewDidEndResizing:(SKGridView *)gridView;
- (void)gridViewLayoutDidChanged:(SKGridView *)gridView widthChange:(BOOL)widthChange;
@end

/// 网格视图
@interface SKGridView : UIView
/// 网格区域   默认CGRectInset(self.bounds, 20, 20)
@property (nonatomic, assign) CGRect gridRect;
@property (assign, nonatomic) SKCutLayoutType clipType;
@property (assign, nonatomic) CGFloat imgWHRatio;

/// 网格 最小尺寸   默认 CGSizeMake(60, 60);
@property (nonatomic, assign) CGSize minGridSize;
/// 网格最大区域   默认 CGRectInset(self.bounds, 20, 20)
@property (nonatomic, assign) CGRect maxGridRect;
/// 原来尺寸 默认CGRectInset(self.bounds, 20, 20).size
@property (nonatomic, assign) CGRect originalGridRect;
/// 网格代理
@property (nonatomic, weak) id<SKGridViewDelegate> delegate;
/// 显示遮罩层  半透明黑色  默认 YES
@property (nonatomic, assign) BOOL showMaskLayer;
/// 是否正在拖动
@property(nonatomic,assign,readonly) BOOL dragging;

@end

NS_ASSUME_NONNULL_END
