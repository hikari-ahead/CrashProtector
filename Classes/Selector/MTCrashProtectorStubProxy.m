//
//  MTCrashProtectorStubProxy.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/5.
//

#import "MTCrashProtectorStubProxy.h"
#import "MTCrashProtectorReporter.h"
#import <objc/runtime.h>
#import "execinfo.h"
#include "unistd.h"

static MTCrashProtectorStubProxy *sharedProxy;
@implementation MTCrashProtectorStubProxy
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProxy = [[MTCrashProtectorStubProxy alloc] init];
    });
    return sharedProxy;
}

#pragma mark - Class Method
+ (BOOL)resolveClassMethod:(SEL)sel {
    Class cls = [self class];
    Method method = class_getClassMethod(cls, @selector(stubClassMethod));
    class_addMethod(cls, sel, method_getImplementation(method), method_getTypeEncoding(method));
    NSError *error = [NSError errorWithDomain:MTCrashProtectorErrorDomain code:0 userInfo:@{MTCrashProtectorReporterReasonKey : [NSString stringWithFormat:@"unrecognized selector: %@", NSStringFromSelector(sel)]}];
    [[MTCrashProtectorReporter shareInstance] reportNonFatalEventWithError:error];
    return YES;
}

+ (int)stubClassMethod {
    return 0;
}

#pragma mark - Instance Method
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    Class cls = [self class];
    // 这里不需要判断signature了，如果存在method，则不会调用resolve
    Method method = class_getInstanceMethod(cls, @selector(stubInstanceMethod));
    class_addMethod(cls, sel, method_getImplementation(method), method_getTypeEncoding(method));
    NSError *error = [NSError errorWithDomain:MTCrashProtectorErrorDomain code:0 userInfo:@{MTCrashProtectorReporterReasonKey : [NSString stringWithFormat:@"unrecognized selector: %@", NSStringFromSelector(sel)]}];
    [[MTCrashProtectorReporter shareInstance] reportNonFatalEventWithError:error];
    return YES;
}

- (int)stubInstanceMethod {
    return 0;
}

@end
