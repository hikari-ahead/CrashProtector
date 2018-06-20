//
//  NSMutableDictionary+MTCrashProtector.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/15.
//

#import "NSMutableDictionary+MTCrashProtector.h"
#import "MTCrashProtector.h"
#import <UIKit/UIKit.h>

@implementation NSMutableDictionary (MTCrashProtector)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleContainer]) {
            return;
        }
        /**
         iOS 12
         -> cls:__NSDictionaryM, ori:removeObjectsForKeys:, new:mtcpInstance_removeObjectsForKeys: didAddMethod:YES
         iOS 10
         -> cls:__NSDictionaryM, ori:setObject:forKeyedSubscript:, new:mtcpInstance_setObject:forKeyedSubscript: didAddMethod:YES
         */
        float sysVer = [[UIDevice currentDevice] systemVersion].floatValue;
        // Set
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(@"__NSDictionaryM"), NSStringFromSelector(@selector(setObject:forKey:)), NSStringFromSelector(@selector(mtcpInstance_setObject:forKey:)));
        MTCrashProtectorInstanceMethodSwizzling(sysVer < 11.0 ? [self class] : NSClassFromString(@"__NSDictionaryM"), NSStringFromSelector(@selector(setObject:forKeyedSubscript:)), NSStringFromSelector(@selector(mtcpInstance_setObject:forKeyedSubscript:)));
        // Remove
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(@"__NSDictionaryM"), NSStringFromSelector(@selector(removeObjectForKey:)), NSStringFromSelector(@selector(mtcpInstance_removeObjectForKey:)));
    });
}

#pragma mark - Set
- (void)mtcpInstance_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!anObject) {
        NSLog(@"cannot set nil object");
        return;
    }
    if (!aKey) {
        NSLog(@"key can not be nil");
        return;
    }
    [self mtcpInstance_setObject:anObject forKey:aKey];
}

- (void)mtcpInstance_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (!key) {
        NSLog(@"key can not be nil");
        return;
    }
    [self mtcpInstance_setObject:obj forKeyedSubscript:key];
}

#pragma mark - Remove
- (void)mtcpInstance_removeObjectForKey:(id)aKey {
    if (!aKey) {
        NSLog(@"key can not be nil");
        return;
    }
    [self mtcpInstance_removeObjectForKey:aKey];
}

@end
