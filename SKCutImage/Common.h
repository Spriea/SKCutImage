
// 屏幕适配
#ifndef __OBJC__
#define __OBJC__
#endif

/** 一些常用的颜色，减少开发时间*/
#define kMainColor      Color(@"#2A2E2F")
#define kMainHightColor Color(@"#fd9d44")
#define k3Color         Color(@"#333333")
#define kBackColor      Color(@"#f4f4f5")
#define kLineColor      Color(@"#e9e9e9")
#define kAColor         Color(@"#aaaaaa")

#define kSCALE_X(x) ((kScreenW/375.f)*x)
//#define NTWidthRatio(x) ((kScreenW/375.f)*x)

#define kString(a)  NSLocalizedString((a), nil)

// 弱化控制器指针
#define kWEAK_SELF(X) __weak typeof(self) X = self;

// 当前屏幕尺寸
#define kScreenH [UIScreen mainScreen].bounds.size.height
#define kScreenW [UIScreen mainScreen].bounds.size.width

// 快捷颜色设置
#define Color(hexString) [UIColor colorWithHexString:hexString alpha:1.0]
#define alpColor(hexString, alp) [UIColor colorWithHexString:hexString alpha:alp]
#define RGB(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.00f green:g/255.00f blue:b/255.00f alpha:a]

// 快速生成图片
#define kImageInstance(nameString) [UIImage imageNamed:nameString]

// 快捷获取系统控件高度
#define kTabH self.tabBarController.tabBar.frame.size.height
#define kNavH ([[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height)
#define kStatusH [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarH self.navigationController.navigationBar.frame.size.height
#define kSafeTop    [UIApplication sharedApplication].windows.firstObject.windowScene.windows.firstObject.safeAreaInsets.top
#define kSafeBottom [UIApplication sharedApplication].windows.firstObject.windowScene.windows.firstObject.safeAreaInsets.bottom

// 根据不同屏幕设置不同字体大小
#define FONT_SIZE(size) kSCALE_X(size)
//#define kFontWithSize(size) [UIFont systemFontOfSize:kSCALE_X(size)]

#define FONT_S(size) kSCALE_X(size)

#define kFontSize(size) [UIFont systemFontOfSize:kSCALE_X(size)]
#define kMedFontSize(size) [UIFont systemFontOfSize:kSCALE_X(size) weight:UIFontWeightMedium]
#define kSemBFontSize(size) [UIFont systemFontOfSize:kSCALE_X(size) weight:UIFontWeightSemibold]
#define kBlodFontSize(size) [UIFont systemFontOfSize:kSCALE_X(size) weight:UIFontWeightBold]

#define KEY_WINDOW  [UIApplication sharedApplication].keyWindow

#define kDocumentPath(x) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:x]

/**不选中cell*/
#define kDeSelectedCell [tableView deselectRowAtIndexPath:indexPath animated:NO];

/**判断系统版本大于某个版本*/
#define IOS_Later(version) [[UIDevice currentDevice].systemVersion doubleValue] >= (version) ? YES : NO

#define kIS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)

// string
#define NIL2EMPTY(t) _nilToEmpty(t)
static inline NSString* _nilToEmpty(NSString *text){
    if(nil == text || [text class]==[NSNull class] || [@"<NULL>" isEqualToString:text]){
        text = @"";
    }
    return text;
}

// 后台返回的json路径
#define fileName_path_documents(fileName) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/zipDownload/%@",fileName]]
#define DownloadFontsPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"zipDownload"]
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
