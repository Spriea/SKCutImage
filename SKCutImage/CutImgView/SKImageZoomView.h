//
//  SKImageZoomView.h
//  SKCutImage
//
//  Created by Link on 2022/2/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SKImageZoomViewDelegate;
/// 缩放视图 用于图片编辑
@interface SKImageZoomView : UIScrollView
@property (nonatomic, strong) UIImage *image;
//
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) id<SKImageZoomViewDelegate> zoomViewDelegate;

@end

/// 缩放视图代理
@protocol SKImageZoomViewDelegate <NSObject>
@optional
/// 开始移动图像位置
- (void)zoomViewDidBeginMoveImage:(SKImageZoomView *)zoomView;
/// 结束移动图像
- (void)zoomViewDidEndMoveImage:(SKImageZoomView *)zoomView;
@end

NS_ASSUME_NONNULL_END
