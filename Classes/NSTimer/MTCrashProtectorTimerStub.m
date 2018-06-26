//
//  MTCrashProtectorTimerStub.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import "MTCrashProtectorTimerStub.h"
#import "MTCrashProtectorReporter.h"

@interface MTCrashProtectorTimerStub()
@property (nonatomic, copy) NSString *targetName;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL sel;
@end
@implementation MTCrashProtectorTimerStub
- (instancetype)initWithTarget:(id)target selector:(SEL)sel {
    self = [super init];
    if (self) {
        self.sel = sel;
        self.target = target;
        self.targetName = NSStringFromClass([target class]);
    }
    return self;
}

- (void)stubTargetTimerFired:(NSTimer *)t {
    if (self.target && [self.target respondsToSelector:self.sel]) {
        if ([self.target respondsToSelector:self.sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:self.sel withObject:t];
#pragma clang diagnostic pop
        }else {
            NSLog(@"error, target:%@ cannot perform the sel:%@", self.target, NSStringFromSelector(self.sel));
        }
    }else {
        // 卸载timer，错误报告
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, target (cls:%@) has already been released，automaticlly invalidate timer: %@", [self class], self.targetName, t]];
        NSLog(@"target has already been released，automaticlly invalidate timer: %@", t);
        [t invalidate];
    }
}
@end
