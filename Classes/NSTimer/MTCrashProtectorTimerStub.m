//
//  MTCrashProtectorTimerStub.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import "MTCrashProtectorTimerStub.h"

@interface MTCrashProtectorTimerStub()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL sel;
@end
@implementation MTCrashProtectorTimerStub
- (instancetype)initWithTarget:(id)target selector:(SEL)sel {
    self = [super init];
    if (self) {
        self.sel = sel;
        self.target = target;
    }
    return self;
}

- (void)stubTargetTimerFired:(NSTimer *)t {
    if (self.target && [self.target respondsToSelector:self.sel]) {
        [self.target performSelector:self.sel withObject:t];
    }else {
        // 卸载timer，错误报告
        NSLog(@"target已经释放，自动invalidate timer: %@", t);
        [t invalidate];
    }
}
@end
