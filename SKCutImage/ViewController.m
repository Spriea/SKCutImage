//
//  ViewController.m
//  SKCutImage
//
//  Created by Link on 2022/2/11.
//

#import "ViewController.h"
#import <Photos/Photos.h>

#import "SKCutImgEditView.h"
#import "SKCutLayoutView.h"
#import "SKCutImage.h"


#define kLayoutHeight (kSCALE_X(207)-34+kSafeBottom)

@interface ViewController ()<UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *clipImageView; // 存放剪切图片（或者剪切结果）

@property (strong, nonatomic) SKCutImgEditView *cutView; // 剪切编辑View
@property (strong, nonatomic) SKCutLayoutView *layoutView; // 控制剪切比例View

@property (strong, nonatomic) UIImagePickerController *pickerVc;

@end

@implementation ViewController
/// 剪切图片
- (IBAction)clipImageAction {
    [self.view addSubview:self.cutView];
    self.cutView.image = self.clipImageView.image;
    self.cutView.clipType = SKCutLayoutTypeFree;
    [self.cutView showImageView];
    
    [self.view addSubview:self.layoutView];
    [self.layoutView showFilter];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/// 切换图片
- (IBAction)replaceImage {
    kWEAK_SELF(weakSelf)
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        [PHPhotoLibrary authorizationStatusForAccessLevel:level];
        [PHPhotoLibrary requestAuthorizationForAccessLevel:level handler:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
                    [weakSelf choseImage];
                }else{
                    NSLog(@"需要打开相册权限");
                }
            });
        }];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [weakSelf choseImage];
                }else{
                    NSLog(@"需要打开相册权限");
                }
            });
        }];
    }
}

- (void)choseImage{
    [self presentViewController:self.pickerVc animated:YES completion:nil];
}

#pragma -mark 选择照片完毕后调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *images = [info objectForKey:UIImagePickerControllerOriginalImage];

    UIImage *image = [self imageWithImageSimple:images];
    self.clipImageView.image = image;
}

//  压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image {
    CGSize size = CGSizeMake(1024, (1024/image.size.width)*image.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.8);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    NSData *imgData = UIImageJPEGRepresentation(newImage, 1.0);
//    NSInteger len = [imgData length] / 1024.0;
//    SKLog(@"图片大小：%zdKB",len);
    
    return newImage;
}

- (SKCutImgEditView *)cutView{
    if (!_cutView) {
        _cutView =  [[SKCutImgEditView alloc] initWithFrame:CGRectMake(0, 0, self.view.sk_width, self.view.sk_heigth-kLayoutHeight)];
    }
    return _cutView;
}

- (SKCutLayoutView *)layoutView{
    if (!_layoutView) {
        _layoutView = [[SKCutLayoutView alloc] initWithFrame:CGRectMake(0, self.view.sk_heigth, self.view.sk_width, kLayoutHeight)];
        kWEAK_SELF(weakSelf)
        _layoutView.dismissBlock = ^{
            [weakSelf.cutView removeFromSuperview];
        };
        
        _layoutView.comfirmBlock = ^{
            weakSelf.clipImageView.image = [weakSelf.cutView comfirmCutBack];
            [weakSelf.cutView removeFromSuperview];
        };
        
        _layoutView.choseTypeBlock = ^(NSInteger type) {
            weakSelf.cutView.clipType = type;
        };
    }
    return _layoutView;
}

- (UIImagePickerController *)pickerVc{
    if (!_pickerVc) {
        _pickerVc = [[UIImagePickerController alloc] init];
        _pickerVc.delegate = self;
        _pickerVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _pickerVc;
}
@end
