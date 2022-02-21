//
//  SKClipLayoutView.h
//  SKCutImage
//
//  Created by Link on 2022/2/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKCutLayoutView : UIView

@property (copy, nonatomic) void(^dismissBlock)(void);
@property (copy, nonatomic) void(^comfirmBlock)(void);
@property (copy, nonatomic) void(^choseTypeBlock)(NSInteger type);

- (void)showFilter;
- (void)dismisFilter;

@end

NS_ASSUME_NONNULL_END
