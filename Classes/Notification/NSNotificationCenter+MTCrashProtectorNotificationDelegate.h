//
//  NSNotificationCenter+MTCrashProtectorNotificationDelegate.h
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class MTCrashProtectorNotificationStub;
@interface NSNotificationCenter (MTCrashProtectorNotificationDelegate)
@property (nonatomic, strong) MTCrashProtectorNotificationStub *mtcp_notificationDelegate;
- (id<NSObject>)mtcpInstance_addObserverForName:(NSNotificationName)name
                                         object:(id)obj
                                          queue:(NSOperationQueue *)queue
                                     usingBlock:(void (^)(NSNotification *note))block;
- (void)mtcpInstance_addObserver:(id)observer
                        selector:(SEL)aSelector
                            name:(NSNotificationName)aName
                          object:(id)anObject;
- (void)mtcpInstance_removeObserver:(id)observer
                               name:(NSNotificationName)aName
                             object:(id)anObject;
- (void)mtcpInstance_removeObserver:(id)observer;
- (void)mtcpInstance_postNotification:(NSNotification *)notification;
- (void)mtcpInstance_postNotificationName:(NSNotificationName)aName
                                   object:(id)anObject
                                 userInfo:(NSDictionary *)aUserInfo;
- (void)mtcpInstance_postNotificationName:(NSNotificationName)aName
                                   object:(id)anObject;
@end

NS_ASSUME_NONNULL_END
