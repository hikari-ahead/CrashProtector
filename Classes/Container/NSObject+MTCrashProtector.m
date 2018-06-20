//
//  NSObject+MTCrashProtector.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import "NSObject+MTCrashProtector.h"
#import "MTCrashProtector.h"

@implementation NSObject (MTCrashProtector)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleContainer]) {
            return;
        }
        MTCrashProtectorInstanceMethodSwizzling([self class],
                                                NSStringFromSelector(@selector(valueForUndefinedKey:)),
                                                NSStringFromSelector(@selector(mtcpInstance_valueForUndefinedKey:)));
        MTCrashProtectorInstanceMethodSwizzling([self class],
                                                NSStringFromSelector(@selector(valueForKey:)),
                                                NSStringFromSelector(@selector(mtcpInstance_valueForKey:)));
    });
}

- (id)mtcpInstance_valueForUndefinedKey:(NSString *)key {
    NSLog(@"this class (%@) is not key value coding-compliant for the key %@.", NSStringFromClass([self class]), key);
    return nil;
}

- (id)mtcpInstance_valueForKey:(NSString *)key {
    if (!key) {
        NSLog(@"attempt to retrieve a value for a nil key");
        return nil;
    }
    return [self mtcpInstance_valueForKey:key];
}
@end
