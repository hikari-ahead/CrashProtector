
//
//  NSTimer+MTCrashProtector.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import "NSTimer+MTCrashProtector.h"
#import "MTCrashProtector.h"
#import "MTCrashProtectorTimerStub.h"
#import "MTCrashProtectorCallStackUtil.h"

static const char *kMTCrashProtectorTimerStubAssociateKey = "kMTCrashProtectorTimerStubAssociateKey";
static const char *kMTCrashProtectorTargetAssociateKey = "kMTCrashProtectorTargetAssociateKey";
static const char *kMTCrashProtectorSELAssociateKey = "kMTCrashProtectorSELAssociateKey";
@interface NSTimer ()
@property (nonatomic, strong) MTCrashProtectorTimerStub *mtcp_timerStub;
@property (nonatomic, strong) id mtcp_target;
@property (nonatomic, assign) SEL mtcp_sel;
@end

@implementation NSTimer (MTCrashProtector)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleTimer]) {
            return;
        }
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(@"__NSCFTimer"),
                                                NSStringFromSelector(@selector(initWithFireDate:interval:target:selector:userInfo:repeats:)),
                                                NSStringFromSelector(@selector(__NSCFTimer_mtcpInstance_initWithFireDate:interval:target:selector:userInfo:repeats:)));
        
        MTCrashProtectorInstanceMethodSwizzling([self class],
                                                NSStringFromSelector(@selector(initWithFireDate:interval:target:selector:userInfo:repeats:)),
                                                NSStringFromSelector(@selector(mtcpInstance_initWithFireDate:interval:target:selector:userInfo:repeats:)));
        
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(@"NSCFTimer"),
                                                NSStringFromSelector(@selector(initWithFireDate:interval:target:selector:userInfo:repeats:)),
                                                NSStringFromSelector(@selector(NSCFTimer_mtcpInstance_initWithFireDate:interval:target:selector:userInfo:repeats:)));


    });
}

- (instancetype)__NSCFTimer_mtcpInstance_initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep {
    [self mtcp_prepareInitializationWithTarget:t Selector:s];
    return [self __NSCFTimer_mtcpInstance_initWithFireDate:date interval:ti target:([self useOriParams] ? t : self.mtcp_target) selector:([self useOriParams] ? s : self.mtcp_sel) userInfo:ui repeats:rep];
}

- (instancetype)mtcpInstance_initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep {
    [self mtcp_prepareInitializationWithTarget:t Selector:s];
    return [self mtcpInstance_initWithFireDate:date interval:ti target:([self useOriParams] ? t : self.mtcp_target) selector:([self useOriParams] ? s : self.mtcp_sel) userInfo:ui repeats:rep];
}

- (instancetype)NSCFTimer_mtcpInstance_initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep {
    [self mtcp_prepareInitializationWithTarget:t Selector:s];
    return [self NSCFTimer_mtcpInstance_initWithFireDate:date interval:ti target:([self useOriParams] ? t : self.mtcp_target) selector:([self useOriParams] ? s : self.mtcp_sel) userInfo:ui repeats:rep];
}

- (BOOL)useOriParams {
    return (self.mtcp_target && self.mtcp_sel);
}

/**
 根据是否由mainBundle调用进行初始化
 */
- (void)mtcp_prepareInitializationWithTarget:(id)t Selector:(SEL)s {
    BOOL isPrivateSysTargetOrSEL = [NSStringFromClass([t class]) hasPrefix:@"_"] || [NSStringFromSelector(s) hasPrefix:@"_"];
    if ([MTCrashProtectorCallStackUtil isCalledByMainBundle] && !isPrivateSysTargetOrSEL) {
        self.mtcp_timerStub = [[MTCrashProtectorTimerStub alloc] initWithTarget:t selector:s];
        self.mtcp_target = self.mtcp_timerStub;
        self.mtcp_sel = @selector(stubTargetTimerFired:);
    }
}

#pragma mark - Associated Object
- (MTCrashProtectorTimerStub *)mtcp_timerStub {
    MTCrashProtectorTimerStub *instance = objc_getAssociatedObject(self, &kMTCrashProtectorTimerStubAssociateKey);
    return instance;
}

- (void)setMtcp_timerStub:(MTCrashProtectorTimerStub *)mtcp_timerStub {
    objc_setAssociatedObject(self, &kMTCrashProtectorTimerStubAssociateKey, mtcp_timerStub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)mtcp_target {
    id target = objc_getAssociatedObject(self, &kMTCrashProtectorTargetAssociateKey);
    return target;
}

- (void)setMtcp_target:(id)mtcp_target {
    objc_setAssociatedObject(self, &kMTCrashProtectorTargetAssociateKey, mtcp_target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SEL)mtcp_sel {
    SEL sel = NSSelectorFromString(objc_getAssociatedObject(self, &kMTCrashProtectorSELAssociateKey));
    return sel;
}

- (void)setMtcp_sel:(SEL)mtcp_sel {
    objc_setAssociatedObject(self, &kMTCrashProtectorSELAssociateKey, NSStringFromSelector(mtcp_sel), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
