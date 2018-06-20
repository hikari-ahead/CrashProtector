//
//  MTCrashProtectorNotificationStub.h
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/12.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MTCrashProtectorNotificationStubDelegate
@required
- (id<NSObject>)stub_addObserverForName:(NSNotificationName)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block;
- (void)stub_addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject;
- (void)stub_removeObserver:(id)observer name:(NSNotificationName)aName object:(id)anObject;
- (void)stub_removeObserver:(id)observer;
- (void)stub_postNotification:(NSNotification *)notification;
- (void)stub_postNotificationName:(NSNotificationName)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;
- (void)stub_postNotificationName:(NSNotificationName)aName object:(id)anObject;
@end

@interface MTCrashProtectorNotificationStub: NSObject<MTCrashProtectorNotificationStubDelegate>
@property (nonatomic, weak, readonly) NSNotificationCenter *target;
- (instancetype)initWithTarget:(NSNotificationCenter *)target;
@end

NS_ASSUME_NONNULL_END
