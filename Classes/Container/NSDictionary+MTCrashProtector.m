//
//  NSDictionary+MTCrashProtector.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/15.
//

#import "NSDictionary+MTCrashProtector.h"
#import "MTCrashProtector.h"
#import <UIKit/UIKit.h>

@implementation NSDictionary (MTCrashProtector)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleContainer]) {
            return;
        }
        MTCrashProtectorInstanceMethodSwizzling([self class], NSStringFromSelector(@selector(initWithObjects:forKeys:count:)), NSStringFromSelector(@selector(mtcpInstance_initWithObjects:forKeys:count:)));
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(@"__NSPlaceholderDictionary"), NSStringFromSelector(@selector(initWithObjects:forKeys:count:)), NSStringFromSelector(@selector(__NSPlaceholderDictionary_mtcpInstance_initWithObjects:forKeys:count:)));
    });
}

- (instancetype)mtcpInstance_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    return [self __NSPlaceholderDictionary_mtcpInstance_initWithObjects:objects forKeys:keys count:cnt];
}

- (instancetype)__NSPlaceholderDictionary_mtcpInstance_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    for (int i = 0; i < cnt; i++) {
        id const obj = objects[i];
        id<NSCopying> const key = keys[i];
        if (!obj) {
            NSLog(@"obj cannot be nil in a dic");
            return nil;
        }
        if (!key) {
            NSLog(@"key cannot be nil in a dic");
            return nil;
        }
    }
    return [self __NSPlaceholderDictionary_mtcpInstance_initWithObjects:objects forKeys:keys count:cnt];
}


@end
