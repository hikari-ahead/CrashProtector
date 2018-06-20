//
//  NSObject+MTCrashProtectorObserverDelegate.h
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class MTCrashProtectorObserverStub;
@interface NSObject (MTCrashProtectorObserverDelegate)
/** observer stub */
@property (nonatomic, strong) MTCrashProtectorObserverStub *mtcp_observerDelegate;
/** flag that indicate if `self` has added any observer */
@property (nonatomic, assign) BOOL mtcp_hasAddedObserver;

- (void)mtcpInstance_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)mtcpInstance_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void)mtcpInstance_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)mtcpInstance_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;
@end

NS_ASSUME_NONNULL_END
