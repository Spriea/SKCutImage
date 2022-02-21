//
//  SQTitleBtn.h
//  SQPuzzleClub
//
//  Created by Somer.King on 2020/7/3.
//  Copyright © 2020 Somer.King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKCutImage.h"
NS_ASSUME_NONNULL_BEGIN

@interface SQTitleBtn : UIButton

@property (assign, nonatomic) CGFloat imgY;
@property (assign, nonatomic) CGFloat titleTopMar;
@property (assign, nonatomic) CGSize imgSize;

@property (strong, nonatomic) UIView *tempV;

@end

NS_ASSUME_NONNULL_END
