#import "RNTEventEmitter.h"

@implementation RNTEventEmitter

RCT_EXPORT_MODULE();

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyRN:) name:@"NotifyRNNotification" object:nil];
    }
    return self;
}

- (void)notifyRN:(NSNotification *)notification{
    NSString *eventName = notification.object[@"name"];
    id params = notification.object[@"params"];
    [self sendEventWithName:eventName body:params];
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"UserDidTakeScreenshot",@"ScreenCapturedDidChange"];
}

@end
