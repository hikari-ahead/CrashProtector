//
//  MTCrashProtectorTimerStub.h
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTCrashProtectorTimerStub : NSObject
@property (nonatomic, assign, readonly) SEL sel;
- (instancetype)initWithTarget:(id)target selector:(SEL)sel;
- (void)stubTargetTimerFired:(NSTimer *)t;
@end

NS_ASSUME_NONNULL_END
