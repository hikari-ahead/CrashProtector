//
//  NSObject+MTCrashForwarding.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/5.
//

#import "NSObject+MTCrashProtectorForwarding.h"
#import "dlfcn.h"
#import "MTCrashProtector.h"
#import "MTCrashProtectorStubProxy.h"
#import "MTCrashProtectorCallStackUtil.h"
@implementation NSObject (MTCrashProtectorForwarding)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleSelector]) {
            return;
        }
        Class cls = [self class];
        SEL oriSEL = @selector(forwardingTargetForSelector:);
        SEL newSEL = @selector(mtcpInstance_forwardingTargetForSelector:);
        NSString *oriStr = NSStringFromSelector(oriSEL);
        NSString *newStr = NSStringFromSelector(newSEL);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr, newStr);
        
        SEL oriSEL1 = @selector(forwardingTargetForSelector:);
        SEL newSEL1 = @selector(mtcpClass_forwardingTargetForSelector:);
        NSString *oriStr1 = NSStringFromSelector(oriSEL1);
        NSString *newStr1 = NSStringFromSelector(newSEL1);
        MTCrashProtectorClassMethodSwizzling(cls, oriStr1, newStr1);
    });
}

- (id)mtcpInstance_forwardingTargetForSelector:(SEL)aSelector {
    return [self handleForwardingTargetForSelector:aSelector withInvokeSEL:_cmd];
}

+ (id)mtcpClass_forwardingTargetForSelector:(SEL)aSelector {
    // 这个地方写instance method invoke没有问题，self = *NSObject实例
    return [self handleForwardingTargetForSelector:aSelector withInvokeSEL:_cmd];
}

- (id)handleForwardingTargetForSelector:(SEL)aSelector withInvokeSEL:(SEL)invokeSEL {
    // TODO: 有些类实现了自己的forwarding，添加一个白名单不做处理走ori
    // 注意如果对象的类本事如果重写了forwardInvocation方法的话，就不应该对forwardingTargetForSelector进行重写了，否则会影响到该类型的对象原本的消息转发流程。
    //    id ori = [self mtcrash_forwardingTargetForSelector:aSelector];
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
//    [MTCrashProtectorCallStackUtil isInTargetBundleWithClass:[self class] selector:_cmd];
    if (!signature) {
        return [MTCrashProtectorStubProxy shared];
    }else {
        return [self mtcpInstance_forwardingTargetForSelector:aSelector];
    }
}

@end
