//
//  MTCrashProtectorReporter.m
//  MTCrashProtector
//
//  Created by kuangjeon on 2018/6/25.
//

#import "MTCrashProtectorReporter.h"
#import "MTCrashProtector.h"

static MTCrashProtectorReporter *instance = nil;
@implementation MTCrashProtectorReporter
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [MTCrashProtectorReporter new];
        }
    });
    return instance;
}

- (void)reportNonFatalEventWithError:(NSError *)error {
    if (!self.reporterExecutionBlock || !error) {
        return;
    }
    __block NSString *callStack = @"";
    [[NSThread callStackSymbols] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        callStack = [[callStack stringByAppendingString:obj] stringByAppendingFormat:@"\n"];
    }];
    NSMutableDictionary *ui = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    if (ui) {
        ui[MTCrashProtectorReporterStackKey] = callStack;
    }
    NSError *anError = [NSError errorWithDomain:error.domain code:error.code userInfo:ui];
    self.reporterExecutionBlock(anError);
}

- (void)reportErrorWithReason:(NSString * _Nonnull )reason {
    if (!reason) {
        return;
    }
    NSError *error = [NSError errorWithDomain:MTCrashProtectorErrorDomain code:0 userInfo:@{MTCrashProtectorReporterReasonKey : reason}];
    [[MTCrashProtectorReporter shareInstance] reportNonFatalEventWithError:error];
}
@end
