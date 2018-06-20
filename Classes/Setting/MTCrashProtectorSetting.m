//
//  MTCrashProtectorSetting.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import "MTCrashProtectorSetting.h"

static MTCrashProtectorSetting *instance;
@interface MTCrashProtectorSetting()
@property (nonatomic, strong) NSDictionary *settingDic;
@end
@implementation MTCrashProtectorSetting
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [MTCrashProtectorSetting new];
        }
    });
    return instance;
}
    
- (BOOL)enableStateForModule:(int)m {
    NSString *key = @"";
    switch (m) {
        case MTCrashProtectorModuleContainer:
            key = @"Container";
            break;
        case MTCrashProtectorModuleSelector:
            key = @"Selector";
            break;
        case MTCrashProtectorModuleObserver:
            key = @"Observer";
            break;
        case MTCrashProtectorModuleNotification:
            key = @"Notification";
            break;
        case MTCrashProtectorModuleTimer:
            key = @"NSTimer";
            break;
        default:
            break;
    }
    BOOL state = [[[self.settingDic valueForKey:@"Module"] valueForKey:key] boolValue];
    return state && self.protectingEnable;
}

- (BOOL)protectingEnable {
    return [[self.settingDic valueForKey:@"enable"] boolValue];
}

- (NSDictionary *)settingDic {
    if (!_settingDic) {
//        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"MTCrashProtectorSetting" ofType:@"plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
        _settingDic = dic;
    }
    return _settingDic;
}

@end
