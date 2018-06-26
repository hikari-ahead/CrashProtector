//
//  MTCrashProtectorReporter.h
//  MTCrashProtector
//
//  Created by kuangjeon on 2018/6/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MTCrashProtectorReporterExecutionBlock)(NSError *error);
static NSString *MTCrashProtectorReporterReasonKey = @"reason";
static NSString *MTCrashProtectorReporterStackKey = @"stack";
static NSErrorDomain MTCrashProtectorErrorDomain = @"MTCrashProtectorErrorDomain";
@interface MTCrashProtectorReporter : NSObject
/** 内部上报错误信息时，会调用这个block并传递一个NSError对象，具体需要怎么上报需要宿主自行实现block */
@property (nonatomic, copy) MTCrashProtectorReporterExecutionBlock reporterExecutionBlock;
+ (instancetype)shareInstance;
- (void)reportErrorWithReason:(NSString * _Nonnull )reason;
- (void)reportNonFatalEventWithError:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
