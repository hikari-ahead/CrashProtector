//
//  NSObject+MTCrashProtectorObserverDelegate.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/6.
//

#import "NSObject+MTCrashProtectorObserverDelegate.h"
#import "MTCrashProtector.h"
#import "MTCrashProtectorObserverStub.h"
#import "dlfcn.h"
#import "MTCrashProtectorCallStackUtil.h"

static const char *kMTCPObserverDelegateAssociateKey = "kMTCPObserverDelegateAssociateKey";
static const char *kMTCPObserverHasAddedObserverFlagAssociateKey = "kMTCPObserverHasAddedObserverFlagAssociateKey";
@implementation NSObject (MTCrashProtectorObserverDelegate)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleObserver]) {
            return;
        }
        Class cls = [self class];
        // - Add
        SEL oriSEL = @selector(addObserver:forKeyPath:options:context:);
        SEL newSEL = @selector(mtcpInstance_addObserver:forKeyPath:options:context:);
        NSString *oriStr = NSStringFromSelector(oriSEL);
        NSString *newStr = NSStringFromSelector(newSEL);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr, newStr);
        
        // - Remove
        SEL oriSEL1 = @selector(removeObserver:forKeyPath:);
        SEL newSEL1 = @selector(mtcpInstance_removeObserver:forKeyPath:);
        NSString *oriStr1 = NSStringFromSelector(oriSEL1);
        NSString *newStr1 = NSStringFromSelector(newSEL1);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr1, newStr1);
        
        SEL oriSEL2 = @selector(removeObserver:forKeyPath:context:);
        SEL newSEL2 = @selector(mtcpInstance_removeObserver:forKeyPath:context:);
        NSString *oriStr2 = NSStringFromSelector(oriSEL2);
        NSString *newStr2 = NSStringFromSelector(newSEL2);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr2, newStr2);
        
        // - Receive
        SEL oriSEL3 = @selector(observeValueForKeyPath:ofObject:change:context:);
        SEL newSEL3 = @selector(mtcpInstance_observeValueForKeyPath:ofObject:change:context:);
        NSString *oriStr3 = NSStringFromSelector(oriSEL3);
        NSString *newStr3 = NSStringFromSelector(newSEL3);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr3, newStr3);
        
        // - Dealloc
        SEL oriSEL4 = NSSelectorFromString(@"dealloc");
        SEL newSEL4 = @selector(mtcpInstanceObserver_dealloc);
        NSString *oriStr4 = NSStringFromSelector(oriSEL4);
        NSString *newStr4 = NSStringFromSelector(newSEL4);
        MTCrashProtectorInstanceMethodSwizzling(cls, oriStr4, newStr4);
    });
}

#pragma mark - Add
- (void)mtcpInstance_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if (!self.mtcp_observerDelegate) {
        MTCrashProtectorObserverStub *stub = [[MTCrashProtectorObserverStub alloc] initWithTarget:self];
        [self setMtcp_observerDelegate:stub];
    }
    if ([MTCrashProtectorCallStackUtil isCalledByMainBundle] && self.mtcp_observerDelegate) {
        [self.mtcp_observerDelegate stub_addObserver:observer forKeyPath:keyPath options:options context:context];
    }else {
        [self mtcpInstance_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
    self.mtcp_hasAddedObserver = YES;
}

#pragma mark - Remove
- (void)mtcpInstance_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if ([MTCrashProtectorCallStackUtil isCalledByMainBundle] && self.mtcp_observerDelegate) {
        [self.mtcp_observerDelegate stub_removeObserver:observer forKeyPath:keyPath];
    }else {
        [self mtcpInstance_removeObserver:observer forKeyPath:keyPath];
    }
}

- (void)mtcpInstance_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    if ([MTCrashProtectorCallStackUtil isCalledByMainBundle] && self.mtcp_observerDelegate) {
        [self.mtcp_observerDelegate stub_removeObserver:observer forKeyPath:keyPath context:context];
    }else {
        [self mtcpInstance_removeObserver:observer forKeyPath:keyPath context:context];
    }
}

#pragma mark - Receive
- (void)mtcpInstance_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([MTCrashProtectorCallStackUtil isCalledByMainBundle] && self.mtcp_observerDelegate) {
        [self.mtcp_observerDelegate stub_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }else {
        [self mtcpInstance_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, has not implemented %@.", [self class], NSStringFromSelector(@selector(observeValueForKeyPath:ofObject:change:context:))]];
    NSLog(@"走到这里说明某个类没有实现这个方法");
}

#pragma mark - Associated Object
- (MTCrashProtectorObserverStub *)mtcp_observerDelegate {
    MTCrashProtectorObserverStub *instance = objc_getAssociatedObject(self, &kMTCPObserverDelegateAssociateKey);
    return instance;
}

- (void)setMtcp_observerDelegate:(MTCrashProtectorObserverStub *)delegate {
    objc_setAssociatedObject(self, &kMTCPObserverDelegateAssociateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mtcp_hasAddedObserver {
    BOOL flag = [objc_getAssociatedObject(self, &kMTCPObserverHasAddedObserverFlagAssociateKey) boolValue];
    if (flag) {
        return flag;
    }else {
        return NO;
    }
}

- (void)setMtcp_hasAddedObserver:(BOOL)mtcp_hasAddedObserver {
    objc_setAssociatedObject(self, &kMTCPObserverHasAddedObserverFlagAssociateKey, @(mtcp_hasAddedObserver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Life Cycle
- (void)mtcpInstanceObserver_dealloc {
//    if ([MTCrashProtectorCallStackUtil isCalledByMainBundle] && self.mtcp_observerDelegate) {
//        // 这里根据flag判断是不是需要removeAllObserver
//        if (self.mtcp_hasAddedObserver) {
//            // stub提供删除所有observer的方法
//            [self.mtcp_observerDelegate stub_removeAllObservers];
//        }
//    }
    [self mtcpInstanceObserver_dealloc];
}
@end
