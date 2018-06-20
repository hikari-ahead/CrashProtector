//
//  NSNotificationCenter+MTCrashProtectorNotificationDelegate.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/12.
//

#import "NSNotificationCenter+MTCrashProtectorNotificationDelegate.h"
#import "MTCrashProtector.h"
#import <Foundation/Foundation.h>
#import "MTCrashProtectorNotificationStub.h"
#import <UIKit/UIKit.h>

static const char *kMTCrashProtectorNotificationDelegateAssociateKey = "kMTCrashProtectorNotificationDelegateAssociateKey";

@implementation NSNotificationCenter (MTCrashProtectorNotificationDelegate)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleNotification]) {
            return;
        }
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            // iOS 8+ 系统自行做了处理，即使多次add/remove不平衡也不会崩溃
            return;
        }
        Class cls = [self class];
        // - Add
        SEL oriSEL = @selector(addObserverForName:object:queue:usingBlock:);
        SEL newSEL = @selector(mtcpInstance_addObserverForName:object:queue:usingBlock:);
        NSString *oriStr = NSStringFromSelector(oriSEL);
        NSString *newStr = NSStringFromSelector(newSEL);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr, newStr);
        
        SEL oriSEL1 = @selector(addObserver:selector:name:object:);
        SEL newSEL1 = @selector(mtcpInstance_addObserver:selector:name:object:);
        NSString *oriStr1 = NSStringFromSelector(oriSEL1);
        NSString *newStr1 = NSStringFromSelector(newSEL1);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr1, newStr1);
        
        // - Remove
        SEL oriSEL2 = @selector(removeObserver:name:object:);
        SEL newSEL2 = @selector(mtcpInstance_removeObserver:name:object:);
        NSString *oriStr2 = NSStringFromSelector(oriSEL2);
        NSString *newStr2 = NSStringFromSelector(newSEL2);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr2, newStr2);
        
        SEL oriSEL3 = @selector(removeObserver:);
        SEL newSEL3 = @selector(mtcpInstance_removeObserver:);
        NSString *oriStr3 = NSStringFromSelector(oriSEL3);
        NSString *newStr3 = NSStringFromSelector(newSEL3);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr3, newStr3);
        
        // - Post
        SEL oriSEL4 = @selector(postNotification:);
        SEL newSEL4 = @selector(mtcpInstance_postNotification:);
        NSString *oriStr4 = NSStringFromSelector(oriSEL4);
        NSString *newStr4 = NSStringFromSelector(newSEL4);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr4, newStr4);
        
        SEL oriSEL5 = @selector(postNotificationName:object:userInfo:);
        SEL newSEL5 = @selector(mtcpInstance_postNotificationName:object:userInfo:);
        NSString *oriStr5 = NSStringFromSelector(oriSEL5);
        NSString *newStr5 = NSStringFromSelector(newSEL5);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr5, newStr5);
        
        SEL oriSEL6 = @selector(postNotificationName:object:);
        SEL newSEL6 = @selector(mtcpInstance_postNotificationName:object:);
        NSString *oriStr6 = NSStringFromSelector(oriSEL6);
        NSString *newStr6 = NSStringFromSelector(newSEL6);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr6, newStr6);
    });
}

#pragma mark - Add
- (id<NSObject>)mtcpInstance_addObserverForName:(NSNotificationName)name
                                         object:(id)obj queue:(NSOperationQueue *)queue
                                     usingBlock:(void (^)(NSNotification *note))block {
//    return [self mtcpInstance_addObserverForName:name object:obj queue:queue usingBlock:block];
    return [self.mtcp_notificationDelegate stub_addObserverForName:name object:obj queue:queue usingBlock:block];
}

- (void)mtcpInstance_addObserver:(id)observer
                        selector:(SEL)aSelector
                            name:(NSNotificationName)aName
                          object:(id)anObject {
//    [self mtcpInstance_addObserver:observer selector:aSelector name:aName object:anObject];
    [self.mtcp_notificationDelegate stub_addObserver:observer selector:aSelector name:aName object:anObject];
}

#pragma mark - Remove
- (void)mtcpInstance_removeObserver:(id)observer
                               name:(NSNotificationName)aName
                             object:(id)anObject {
//    [self mtcpInstance_removeObserver:observer name:aName object:anObject];
    [self.mtcp_notificationDelegate stub_removeObserver:observer name:aName object:anObject];
}

- (void)mtcpInstance_removeObserver:(id)observer {
//    [self mtcpInstance_removeObserver:observer];
    [self.mtcp_notificationDelegate stub_removeObserver:observer];
}

#pragma mark - Post
- (void)mtcpInstance_postNotification:(NSNotification *)notification {
//    [self mtcpInstance_postNotification:notification];
    [self.mtcp_notificationDelegate stub_postNotification:notification];
}

- (void)mtcpInstance_postNotificationName:(NSNotificationName)aName
                                   object:(id)anObject
                                 userInfo:(NSDictionary *)aUserInfo {
//    [self mtcpInstance_postNotificationName:aName object:anObject userInfo:aUserInfo];
    [self.mtcp_notificationDelegate stub_postNotificationName:aName object:anObject userInfo:aUserInfo];
}

- (void)mtcpInstance_postNotificationName:(NSNotificationName)aName
                                   object:(id)anObject {
//    [self mtcpInstance_postNotificationName:aName object:anObject];
    [self.mtcp_notificationDelegate stub_postNotificationName:aName object:anObject];
}

#pragma mark - Associated Object
- (MTCrashProtectorNotificationStub *)mtcp_notificationDelegate {
    MTCrashProtectorNotificationStub *instance = objc_getAssociatedObject(self, &kMTCrashProtectorNotificationDelegateAssociateKey);
    if (instance) {
        return instance;
    }else {
        MTCrashProtectorNotificationStub *delegate = [[MTCrashProtectorNotificationStub alloc] initWithTarget:self];
        [self setMtcp_notificationDelegate:delegate];
        return delegate;
    }
}

- (void)setMtcp_notificationDelegate:(MTCrashProtectorNotificationStub *)mtcp_notificationDelegate {
    objc_setAssociatedObject(self, &kMTCrashProtectorNotificationDelegateAssociateKey, mtcp_notificationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
