
#import "RNScreenTool.h"

@interface RNScreenTool()

@end

@implementation RNScreenTool

+ (instancetype)sharedScreenTool {
    static RNScreenTool *_screenTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _screenTool = [RNScreenTool new];
    });
    return _screenTool;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(startListeningScreenshot){
    [[NSNotificationCenter defaultCenter] addObserver:[RNScreenTool sharedScreenTool]
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

RCT_EXPORT_METHOD(startMonitoringScreenRecording:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    [[NSNotificationCenter defaultCenter]addObserver:[RNScreenTool sharedScreenTool] selector:@selector(screenCapturedDidChange) name:UIScreenCapturedDidChangeNotification  object:nil];
}

RCT_EXPORT_METHOD(setImageText:(NSString *)text){
    NSLog(@"fdsfowefwefew%@",text);
    //人为截屏, 模拟用户截屏行为, 获取所截图片
    UIImage *tmpImage = [self imageWithScreenshot];
    UIImage *image_ = [self DrawText:text forImage:tmpImage];
    UIImageWriteToSavedPhotosAlbum(image_, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)screenCapturedDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyRNNotification" object:@{
    @"name":@"ScreenCapturedDidChange",
    @"params":[NSString stringWithFormat:@"%d",[UIScreen mainScreen].isCaptured]
    }];
}

- (void)userDidTakeScreenshot:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyRNNotification" object:@{
    @"name":@"UserDidTakeScreenshot",
    @"params":@"getText"
    }];
}

- (UIImage *)imageWithScreenshot
{
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}

- (NSData *)dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

- (UIImage *)DrawText:(NSString *)text forImage:(UIImage *)image{
    
    CGSize size = CGSizeMake(image.size.width,image.size.height ); // 画布大小
    
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    
    [image drawAtPoint:CGPointMake(0,0)];
    
    // 获得一个位图图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawPath(context,kCGPathStroke);
    
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:30.f], NSForegroundColorAttributeName:[UIColor redColor]};
    
    //计算出文字的宽度 设置控件限制的最大size为图片的size
    CGSize textSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    // 画文字 让文字处于居中模式
    [text drawAtPoint:CGPointMake((size.width - textSize.width)/2,image.size.height - 40) withAttributes:attributes];
    
    // 返回绘制的新图形
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error){
        NSLog(@"save success");
    }else{
        NSLog(@"save failed");
    }
}

@end

