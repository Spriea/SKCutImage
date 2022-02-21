//
//  SQCutImgEditView.h
//  SQPuzzleClub
//
//  Created by Somer.King on 2020/12/22.
//  Copyright © 2020 Somer.King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKGridView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKCutImgEditView : UIView

@property (strong, nonatomic) UIImage * _Nonnull image; // 需要剪切的图片
@property (assign, nonatomic) SKCutLayoutType clipType; // 剪切比例限制

/// 获取剪切结果
- (UIImage *)comfirmCutBack;

/// 展示编辑View
- (void)showImageView;


@end

NS_ASSUME_NONNULL_END
