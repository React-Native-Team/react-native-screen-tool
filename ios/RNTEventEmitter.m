//
//  RNTEventEmitter.m
//  sdfengApp
//
//  Created by 郭旭赞 on 2018/12/24.
//  Copyright © 2018 Facebook. All rights reserved.
//

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
  NSLog(@"分为非 %@",notification);
  NSString *eventName = notification.object[@"name"];
  NSDictionary *params = notification.object[@"params"];
  [self sendEventWithName:eventName body:params];
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"UserDidTakeScreenshot",@"ScreenCapturedDidChange"];
}

@end
