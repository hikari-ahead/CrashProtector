//
//  MTCrashProtectorSetting.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import "MTCrashProtectorSetting.h"

static MTCrashProtectorSetting *instance;
NSString *kSettingVersion = @"0052";
@interface MTCrashProtectorSetting()
@property (nonatomic, strong) NSMutableDictionary *settingDic;
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
    return state && self.isEnablingProtecting && [self validSystemVersion];
}

- (BOOL)validSystemVersion {
    NSString *max = [self.settingDic valueForKey:@"maxOSVersion"];
    NSString *min = [self.settingDic valueForKey:@"minOSVersion"];
    float current = UIDevice.currentDevice.systemVersion.floatValue;
    if (!max && !min) {
        return YES;
    }
    float fmax = max ? [max floatValue] : 0;
    float fmin = min ? [min floatValue] : 0;
    if (fmin <= current && fmax >= current) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)isEnablingProtecting {
    return [[self.settingDic valueForKey:@"enable"] boolValue];
}

- (void)setIsEnablingProtecting:(BOOL)protectingEnable {
    self.settingDic[@"enable"] = [NSNumber numberWithBool:protectingEnable];
    NSString *path = [self plistPath];
    [NSFileManager.defaultManager removeItemAtPath:path error:nil];
    [self.settingDic writeToFile:path atomically:YES];
}

- (NSMutableDictionary *)settingDic {
    if (!_settingDic) {
        // Document目录
        NSString *path = [self plistPath];
        BOOL plistExists = [NSFileManager.defaultManager fileExistsAtPath:path];
        if (plistExists) {
            // 判断版本号
            _settingDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            if ([_settingDic valueForKey:@"settingVersion"] && [[_settingDic valueForKey:@"settingVersion"] integerValue] == [kSettingVersion integerValue]) {
                return _settingDic;
            }else {
                [NSFileManager.defaultManager removeItemAtPath:path error:nil];
                plistExists = NO;
            }
        }
        if (!plistExists) {
            // mainBundle是否存在手动配置的
            NSString *bPath = [[NSBundle mainBundle] pathForResource:@"MTCrashProtectorSetting" ofType:@"plist"];
            NSError *copyError = nil;
            if (bPath) {
                // copy到document中
                [NSFileManager.defaultManager copyItemAtPath:bPath toPath:path error:&copyError];
                if (!copyError) {
                    _settingDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
                    if ([_settingDic valueForKey:@"settingVersion"] && [[_settingDic valueForKey:@"settingVersion"] integerValue] == [kSettingVersion integerValue]) {
                        return _settingDic;
                    }
                }
            }
            // copy失败，并且bundle中不存在
            if (copyError || !bPath) {
                _settingDic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                              @"Module": @{
                                                                                      @"Container":@YES,
                                                                                      @"NSTimer":@YES,
                                                                                      @"Notification":@YES,
                                                                                      @"Observer":@YES,
                                                                                      @"Selector":@YES
                                                                                      },
                                                                              @"enable": @NO,
                                                                              @"maxOSVersion": @"11.99",
                                                                              @"minOSVersion": @"9.0",
                                                                              @"settingVersion": kSettingVersion
                                                                              }];
                [_settingDic writeToFile:path atomically:YES];
            }
            return _settingDic;
        }
    }
    return _settingDic;
}

- (NSString *)plistPath {
    NSURL *documentURL = [NSFileManager.defaultManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSString *path = [documentURL.path stringByAppendingPathComponent:@"MTCrashProtectorSetting.plist"];
    return path;
}

@end
