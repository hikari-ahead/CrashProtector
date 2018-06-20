//
//  MTCrashProtectorObserverStubInfo.h
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTCrashProtectorObserverStubInfo : NSObject
@property (nonatomic, strong, readonly) NSObject *observer;
@property (nonatomic, strong, readonly) NSString *keyPath;
@property (nonatomic, assign, readonly) NSKeyValueObservingOptions option;
@property (nonatomic, assign, readonly) void* context;

- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath;
- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath option:(NSKeyValueObservingOptions)option;
- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath option:(NSKeyValueObservingOptions)option context:(nullable void *)context;
- (BOOL)isEqualOnlyCaseObserverAndKeyPath:(id)object;
- (BOOL)isEqualOnlyCaseObserverKeyPathAndContext:(id)object;
- (BOOL)isEqualOnlyCaseKeyPathAndContext:(id)object;
@end

NS_ASSUME_NONNULL_END
