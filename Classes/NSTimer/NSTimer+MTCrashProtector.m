
//
//  NSTimer+MTCrashProtector.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import "NSTimer+MTCrashProtector.h"
#import "MTCrashProtector.h"
#import "MTCrashProtectorTimerStub.h"

static const char *kMTCrashProtectorTimerStubAssociateKey = "kMTCrashProtectorTimerStubAssociateKey";
@interface NSTimer ()
@property (nonatomic, strong) MTCrashProtectorTimerStub *mtcp_timerStub;
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
    return [self innerInitWithFireDate:date interval:ti target:t selector:s userInfo:ui repeats:rep];
}

- (instancetype)mtcpInstance_initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep {
    return [self innerInitWithFireDate:date interval:ti target:t selector:s userInfo:ui repeats:rep];
}

- (instancetype)NSCFTimer_mtcpInstance_initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep {
    return [self innerInitWithFireDate:date interval:ti target:t selector:s userInfo:ui repeats:rep];
}

- (instancetype)innerInitWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep {
    self.mtcp_timerStub = [[MTCrashProtectorTimerStub alloc] initWithTarget:t selector:s];
    return [self NSCFTimer_mtcpInstance_initWithFireDate:date interval:ti target:self.mtcp_timerStub selector:@selector(stubTargetTimerFired:) userInfo:ui repeats:rep];
}

#pragma mark - Associated Object
- (MTCrashProtectorTimerStub *)mtcp_timerStub {
    MTCrashProtectorTimerStub *instance = objc_getAssociatedObject(self, &kMTCrashProtectorTimerStubAssociateKey);
    return instance;
}

- (void)setMtcp_timerStub:(MTCrashProtectorTimerStub *)mtcp_timerStub {
    objc_setAssociatedObject(self, &kMTCrashProtectorTimerStubAssociateKey, mtcp_timerStub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
