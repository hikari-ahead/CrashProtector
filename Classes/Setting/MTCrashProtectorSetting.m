//
//  MTCrashProtectorSetting.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import "MTCrashProtectorSetting.h"

static MTCrashProtectorSetting *instance;
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
    return state && self.protectingEnable;
}

- (BOOL)protectingEnable {
    return [[self.settingDic valueForKey:@"enable"] boolValue];
}

- (void)setProtectingEnable:(BOOL)protectingEnable {
    self.settingDic[@"enable"] = [NSNumber numberWithBool:protectingEnable];
    NSString *path = [self plistPath];
    [NSFileManager.defaultManager removeItemAtPath:path error:nil];
    [self.settingDic writeToFile:path atomically:YES];
}

- (NSMutableDictionary *)settingDic {
    if (!_settingDic) {
        NSString *path = [self plistPath];
        BOOL plistExists = [NSFileManager.defaultManager fileExistsAtPath:path];
        if (!plistExists) {
            _settingDic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                          @"Module": @{
                                                                                  @"Container":@YES,
                                                                                  @"NSTimer":@YES,
                                                                                  @"Notification":@YES,
                                                                                  @"Observer":@YES,
                                                                                  @"Selector":@YES
                                                                                  },
                                                                          @"enable":@YES
                                                                          }];
            [_settingDic writeToFile:path atomically:YES];
            return _settingDic;
        }else {
            _settingDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
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
