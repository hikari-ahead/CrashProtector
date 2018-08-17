//
//  MTCrashProtectorNotificationStubInfo.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/12.
//

#import "MTCrashProtectorNotificationStubInfo.h"

@interface MTCrashProtectorNotificationStubInfo() {
    __unsafe_unretained id _mObserver;
    __unsafe_unretained id _mObject;
}
@property (nonatomic, strong) id object;
@property (nonatomic, copy) NSNotificationName name;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, copy) MTCrashProtectorNotificationStubInfoBlock block;
@property (nonatomic, assign) SEL selector;
@end
@implementation MTCrashProtectorNotificationStubInfo
- (instancetype)initWithObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)name object:(id)object {
    self = [super init];
    if (self) {
        if (observer) {
            _mObserver = observer;
        }
        if (object) {
            _mObject = object;
        }
        self.selector = aSelector;
        self.name = name;
    }
    return self;
}

- (id)observer {
    return _mObserver;
}

- (id)object {
    return _mObject;
}

- (instancetype)initWithName:(NSNotificationName)name object:(id)object queue:(NSOperationQueue *)queue block:(MTCrashProtectorNotificationStubInfoBlock)block {
    self = [super init];
    if (self) {
        self.name = name;
        self.object = object;
        self.queue = queue;
        self.block = block;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MTCrashProtectorNotificationStubInfo class]]) {
        return NO;
    }
    MTCrashProtectorNotificationStubInfo *obj = ((MTCrashProtectorNotificationStubInfo *)object);
    return (self.observer == obj.observer
            && self.object == obj.object
            && self.name == obj.name
            && self.queue == obj.queue
            && self.block == obj.block
            && self.selector == obj.selector);
}

- (BOOL)isEqualOnlyCaseObserverNameAndObject:(id)object {
    if (![object isKindOfClass:[MTCrashProtectorNotificationStubInfo class]]) {
        return NO;
    }
    MTCrashProtectorNotificationStubInfo *obj = ((MTCrashProtectorNotificationStubInfo *)object);
    return ((self.observer == obj.observer || self.token == obj.observer || self.observer == obj.token)
            && self.name == obj.name
            && self.object == obj.object);
}

- (BOOL)isEqualOnlyCaseObserver:(id)object {
    if (![object isKindOfClass:[MTCrashProtectorNotificationStubInfo class]]) {
        return NO;
    }
    MTCrashProtectorNotificationStubInfo *obj = ((MTCrashProtectorNotificationStubInfo *)object);
    return (self.observer == obj.observer || self.token == obj.observer || self.observer == obj.token);
}

- (NSUInteger)hash {
    return [super hash];
}
@end
