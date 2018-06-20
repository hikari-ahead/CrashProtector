//
//  MTCrashProtectorStubProxy.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/5.
//

#import "MTCrashProtectorStubProxy.h"
#import <objc/runtime.h>

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
    BOOL add = class_addMethod(cls, sel, method_getImplementation(method), method_getTypeEncoding(method));
    // TODO: fabric事件的上报+错误提醒
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
    // TODO: fabric事件的上报+错误提醒
    return YES;
}

- (int)stubInstanceMethod {
    return 0;
}

@end
