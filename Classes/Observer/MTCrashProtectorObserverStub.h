//
//  MTCrashProtectorObserverStub.h
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MTCrashProtectorObserverStubDelegate
@required
- (void)stub_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
- (void)stub_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void)stub_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;
- (void)stub_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context;
@optional
- (void)stub_removeAllObservers;
@end

@interface MTCrashProtectorObserverStub : NSObject <MTCrashProtectorObserverStubDelegate>
@property (nonatomic, weak) NSObject *target;
- (instancetype)initWithTarget:(NSObject *)target;
@end

NS_ASSUME_NONNULL_END
