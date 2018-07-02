//
//  NSCache+MTCrashProtector.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import "NSCache+MTCrashProtector.h"
#import "MTCrashProtector.h"

@implementation NSCache (MTCrashProtector)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleContainer]) {
            return;
        }
        MTCrashProtectorInstanceMethodSwizzling([self class],
                                                NSStringFromSelector(@selector(setObject:forKey:cost:)),
                                                NSStringFromSelector(@selector(mtcpInstance_setObject:forKey:cost:)));
    });
}

- (void)mtcpInstance_setObject:(id)obj forKey:(id)key cost:(NSUInteger)g {
    if (!obj) {
        NSError *error = [NSError errorWithDomain:MTCrashProtectorErrorDomain
                                             code:0
                                         userInfo:@{MTCrashProtectorReporterReasonKey:[NSString stringWithFormat:@"cls: %@, can not insert nil value (key:%@) cost:%lu", [self class], key, g]}];
        [[MTCrashProtectorReporter shareInstance] reportNonFatalEventWithError:error];
        return;
    }
    [self mtcpInstance_setObject:obj forKey:key cost:g];
}
@end
