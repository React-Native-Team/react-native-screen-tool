#import "RNScreenTool.h"

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

RCT_EXPORT_METHOD(startMonitoringScreenRecording){
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter]addObserver:[RNScreenTool sharedScreenTool] selector:@selector(screenCapturedDidChange) name:UIScreenCapturedDidChangeNotification  object:nil];
    } else {
        NSLog(@"####### RNScreenTool @available(iOS 11.0, *)");
    }
}

RCT_EXPORT_METHOD(setImageText:(NSString *)text){
    UIImage *tmpImage = [self imageWithScreenshot];
    UIImage *image_ = [self drawText:text forImage:tmpImage];
    UIImageWriteToSavedPhotosAlbum(image_, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)screenCapturedDidChange
{
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyRNNotification" object:@{
            @"name":@"ScreenCapturedDidChange",
            @"params":[NSString stringWithFormat:@"%d",[UIScreen mainScreen].isCaptured]
        }];
    } else {
    }
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

- (UIImage *)drawText:(NSString *)text forImage:(UIImage *)image{
    CGSize imageSize = CGSizeMake(image.size.width,image.size.height);
    
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:30.f], NSForegroundColorAttributeName:[UIColor redColor]};
    CGSize textSize = [text boundingRectWithSize:imageSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    CGFloat textBackgroundHight = textSize.height+10;
    
    CGSize canvasSize = CGSizeMake(imageSize.width,imageSize.height+textBackgroundHight);
    UIGraphicsBeginImageContextWithOptions(canvasSize,NO,0.0);
    [image drawInRect:CGRectMake(0, textBackgroundHight, imageSize.width, imageSize.height)];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawPath(context,kCGPathStroke);
    [text drawAtPoint:CGPointMake((imageSize.width - textSize.width)/2,0) withAttributes:attributes];

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
