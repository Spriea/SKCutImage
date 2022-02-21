//
//  SKClipLayoutView.m
//  SKCutImage
//
//  Created by Link on 2022/2/11.
//

#import "SKCutLayoutView.h"
#import "SQTitleBtn.h"

@interface SKCutLayoutView ()

@property (weak, nonatomic) UIButton *selBtn;
@property (weak, nonatomic) UIButton *oneBtn;

@end

@implementation SKCutLayoutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI:frame];
    }
    return self;
}

- (void)ratioClick:(UIButton *)sender{
    if (self.selBtn == sender) {
        return;
    }
    self.selBtn.selected = NO;
    sender.selected = YES;
    self.selBtn = sender;
    if (self.choseTypeBlock) {
        self.choseTypeBlock(sender.tag);
    }
}

- (void)comfirmClick{
    if (self.comfirmBlock) {
        self.comfirmBlock();
    }
    [self dismisFilter];
}

- (void)setupUI:(CGRect)frame{
    self.backgroundColor = [UIColor whiteColor];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:kImageInstance(@"selConfirm") forState:UIControlStateNormal];
    closeBtn.contentEdgeInsets = UIEdgeInsetsMake(kSCALE_X(15), kSCALE_X(15), kSCALE_X(15), kSCALE_X(15));
    closeBtn.frame = CGRectMake(kSCALE_X(319), 0, kSCALE_X(47), kSCALE_X(43));
    [self addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(comfirmClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setImage:kImageInstance(@"filter_slider_cancel") forState:UIControlStateNormal];
    cancleBtn.contentEdgeInsets = UIEdgeInsetsMake(kSCALE_X(15), kSCALE_X(15), kSCALE_X(15), kSCALE_X(15));
    cancleBtn.frame = CGRectMake(kSCALE_X(10), 0, kSCALE_X(43), kSCALE_X(43));
    [self addSubview:cancleBtn];
    [cancleBtn addTarget:self action:@selector(dismisFilter) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.font = kFontSize(16);
    titleL.text = @"剪切比例";
    titleL.textColor = [UIColor blackColor];
    [self addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(closeBtn);
    }];
   
    NSArray *titleArr = @[@"自由尺寸",@"原始比例",@"1:1",@"壁纸",@"3:4",@"4:3"];
    for (int i = 0; i < titleArr.count; i ++) {
        NSString *imgNor = [NSString stringWithFormat:@"imgbeatuti_ratio_nor%d",i];
        NSString *imgSel = [NSString stringWithFormat:@"imgbeatuti_ratio_sel%d",i];
        SQTitleBtn *cellB = [SQTitleBtn buttonWithType:UIButtonTypeCustom];
        cellB.titleLabel.font = kFontSize(13);
        [cellB setTitle:titleArr[i] forState:UIControlStateNormal];
        [cellB setTitleColor:Color(@"#CDCFD3") forState:UIControlStateNormal];
        [cellB setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [cellB setImage:kImageInstance(imgNor) forState:UIControlStateNormal];
        [cellB setImage:kImageInstance(imgSel) forState:UIControlStateSelected];
        [self addSubview:cellB];
        CGRect frameRect;
        CGSize imgSize;
        CGFloat imgY;
        switch (i) {
            case 3:
                imgSize = CGSizeMake(kSCALE_X(13), kSCALE_X(30));
                imgY = kSCALE_X(5);
                frameRect = CGRectMake(kSCALE_X(202), kSCALE_X(72), kSCALE_X(45), kSCALE_X(64));
                break;
            case 4:
                imgSize = CGSizeMake(kSCALE_X(16), kSCALE_X(25));
                imgY = kSCALE_X(10);
                frameRect = CGRectMake(kSCALE_X(255.5), kSCALE_X(72), kSCALE_X(45), kSCALE_X(64));
                break;
            case 5:
                imgSize = CGSizeMake(kSCALE_X(25), kSCALE_X(16));
                imgY = kSCALE_X(14);
                frameRect = CGRectMake(kSCALE_X(316), kSCALE_X(72), kSCALE_X(45), kSCALE_X(64));
                break;
            default:
                imgSize = CGSizeMake(kSCALE_X(25), kSCALE_X(25));
                imgY = kSCALE_X(10);
                frameRect = CGRectMake(kSCALE_X(14)+kSCALE_X(65)*i, kSCALE_X(72), kSCALE_X(45), kSCALE_X(64));
                break;
        }
        cellB.frame = frameRect;
        cellB.titleTopMar = kSCALE_X(8);
        cellB.imgY = imgY;
        cellB.imgSize = imgSize;
        cellB.tag = i;
        [cellB addTarget:self action:@selector(ratioClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            cellB.selected = YES;
            self.selBtn = cellB;
            self.oneBtn = cellB;
        }
    }
}

- (void)showFilter{
    [self ratioClick:self.oneBtn];
    [UIView animateWithDuration:0.25 animations:^{
        self.sk_y = [self superview].sk_heigth-self.sk_heigth;
    }];
}
- (void)dismisFilter{
    if (self.sk_y == [self superview].sk_heigth || [self superview] == nil) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.sk_y = [self superview].sk_heigth;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}
@end
