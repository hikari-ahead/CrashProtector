//
//  MTCrashProtectorObserverStubInfo.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/6.
//

#import "MTCrashProtectorObserverStubInfo.h"

@interface MTCrashProtectorObserverStubInfo() {
    __unsafe_unretained NSObject *_observer;
}
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, assign) NSKeyValueObservingOptions option;
@property (nonatomic, assign) void* context;
@end

@implementation MTCrashProtectorObserverStubInfo
- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath option:(NSKeyValueObservingOptions)option context:(nullable void *)context {
    self = [super init];
    if (self) {
        if (observer) {
            _observer = observer;
        }
        self.keyPath = keyPath;
        self.option = option;
        self.context = context;
    }
    return self;
}

- (NSObject *)observer {
    return _observer;
}

- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath option:(NSKeyValueObservingOptions)option {
    return [self initWithObserver:observer keyPath:keyPath option:option context:NULL];
}

- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    return [self initWithObserver:observer keyPath:keyPath option:0 context:NULL];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MTCrashProtectorObserverStubInfo class]]) {
        return NO;
    }
    MTCrashProtectorObserverStubInfo *obj = ((MTCrashProtectorObserverStubInfo *)object);
    return obj.observer == self.observer && [obj.keyPath isEqualToString:self.keyPath] && obj.option == self.option && obj.context == self.context;
}

- (BOOL)isEqualOnlyCaseObserverAndKeyPath:(id)object {
    if (![object isKindOfClass:[MTCrashProtectorObserverStubInfo class]]) {
        return NO;
    }
    MTCrashProtectorObserverStubInfo *obj = ((MTCrashProtectorObserverStubInfo *)object);
    return obj.observer == self.observer && [obj.keyPath isEqualToString:self.keyPath];
}

- (BOOL)isEqualOnlyCaseObserverKeyPathAndContext:(id)object {
    if (![object isKindOfClass:[MTCrashProtectorObserverStubInfo class]]) {
        return NO;
    }
    MTCrashProtectorObserverStubInfo *obj = ((MTCrashProtectorObserverStubInfo *)object);
    return obj.observer == self.observer && [obj.keyPath isEqualToString:self.keyPath] && obj.context == self.context;
}

- (BOOL)isEqualOnlyCaseKeyPathAndContext:(id)object {
    if (![object isKindOfClass:[MTCrashProtectorObserverStubInfo class]]) {
        return NO;
    }
    MTCrashProtectorObserverStubInfo *obj = ((MTCrashProtectorObserverStubInfo *)object);
    return [obj.keyPath isEqualToString:self.keyPath] && obj.context == self.context;
}

- (NSUInteger)hash {
    NSUInteger newHash = (self.observer.hash + 1) * self.keyPath.hash + (self.option + 1);
    return newHash;
}


@end
