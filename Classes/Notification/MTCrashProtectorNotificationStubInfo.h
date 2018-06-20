//
//  MTCrashProtectorNotificationStubInfo.h
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/12.
//

#import <Foundation/Foundation.h>

typedef void(^MTCrashProtectorNotificationStubInfoBlock)(NSNotification *note);
@interface MTCrashProtectorNotificationStubInfo : NSObject
@property (nonatomic, strong) id observer;
@property (nonatomic, strong, readonly) id object;
@property (nonatomic, copy, readonly) NSNotificationName name;
@property (nonatomic, strong, readonly) NSOperationQueue *queue;
@property (nonatomic, copy, readonly) MTCrashProtectorNotificationStubInfoBlock block;
@property (nonatomic, assign, readonly) SEL selector;
/** if addObserver using `- addObserverForName:object:queue:usingBlock:` , will assign the return value (observer) to the below property */
@property (nonatomic, strong) id token;
- (instancetype)initWithName:(NSNotificationName)name object:(id)object queue:(NSOperationQueue *)queue block:(MTCrashProtectorNotificationStubInfoBlock)block;
- (instancetype)initWithObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)name object:(id)object;
- (BOOL)isEqualOnlyCaseObserverNameAndObject:(id)object;
- (BOOL)isEqualOnlyCaseObserver:(id)object;
@end
