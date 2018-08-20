//
//  MTCrashProtectorObserverStub.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/6.
//

#import "MTCrashProtectorObserverStub.h"
#import "MTCrashProtectorObserverStubInfo.h"
#import "NSObject+MTCrashProtectorObserverDelegate.h"
#import "MTCrashProtectorReporter.h"

@interface MTCrashProtectorObserverStub() {
    __unsafe_unretained NSObject *_mTarget;
}
@property (nonatomic, strong) NSMutableArray<MTCrashProtectorObserverStubInfo *> *obInfos;
/** a flag to indicate which info will be remove after calling `stub_removeObserver:forKeyPath:context:` */
@property (nonatomic, strong) MTCrashProtectorObserverStubInfo *lastRemovedInfoWithSpecificContext;
@end
@implementation MTCrashProtectorObserverStub
- (instancetype)initWithTarget:(NSObject *)target {
    self = [super init];
    if (self) {
        _mTarget = target;
        self.obInfos = [NSMutableArray new];
    }
    return self;
}

- (NSObject *)target {
    return _mTarget;
}
#pragma mark - Remove
- (void)stub_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    MTCrashProtectorObserverStubInfo *info = [[MTCrashProtectorObserverStubInfo alloc] initWithObserver:observer keyPath:keyPath];
    NSMutableArray<MTCrashProtectorObserverStubInfo *> *matchedInfos = [self obInfosContainsInfoOnlyCaseObserverAndKeyPath:info];
    if (matchedInfos.count > 0) {
        // has added at least one observer, and will guess which one to be remove, usually last one except specific context;
        [self.target mtcpInstance_removeObserver:observer forKeyPath:keyPath];
        if (self.lastRemovedInfoWithSpecificContext) {
            // indicate called from `stub_removeObserver:forKeyPath:context:`
            [self.obInfos removeObject:self.lastRemovedInfoWithSpecificContext];
            self.lastRemovedInfoWithSpecificContext = nil;
        }else {
            [self.obInfos removeObject:matchedInfos.lastObject];
            MTCrashProtectorObserverStubInfo *removedInfo = matchedInfos.lastObject;
            matchedInfos = nil;
            removedInfo = nil;
        }
    }else {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, %@ has not yet add one observer:%@ keyPath:%@, can not remove it", [self class], self.target, observer, keyPath]];
        NSLog(@"%@ has not yet add one observer:%@ keyPath:%@, can not remove it", self.target, observer, keyPath);
    }
}

- (void)stub_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    MTCrashProtectorObserverStubInfo *info = [[MTCrashProtectorObserverStubInfo alloc] initWithObserver:observer keyPath:keyPath option:0 context:context];
    MTCrashProtectorObserverStubInfo *matchedInfo = [self obInfosContainsInfoOnlyCaseObserverKeyPathAndContext:info];
    if (matchedInfo) {
        // system will truely call method `removeObserver:forKeyPath:` after push context in register.
        self.lastRemovedInfoWithSpecificContext = matchedInfo;
        [self.target mtcpInstance_removeObserver:observer forKeyPath:keyPath context:context];
    }else {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, %@ has not yet add one observer:%@ keyPath:%@ context:%p, can not remove it", [self class], self.target, observer, keyPath, context]];
        NSLog(@"%@ has not yet add one observer:%@ keyPath:%@ context:%p, can not remove it", self.target, observer, keyPath, context);
    }
}

- (void)stub_removeAllObservers {
    [self.obInfos enumerateObjectsUsingBlock:^(MTCrashProtectorObserverStubInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.target mtcpInstance_removeObserver:obj.observer forKeyPath:obj.keyPath context:obj.context];
    }];
    self.obInfos = nil;
}

#pragma mark - Add
- (void)stub_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    MTCrashProtectorObserverStubInfo *info = [[MTCrashProtectorObserverStubInfo alloc] initWithObserver:observer keyPath:keyPath option:options context:context];
    if ([self obInfosContainsInfo:info]) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, %@ has already add an observer:%@ keyPath:%@ options:%ld context:%p, do not add it again", [self class] ,self.target, observer, keyPath, options, context]];
        NSLog(@"%@ has already add an observer:%@ keyPath:%@ options:%ld context:%p, do not add it again", self.target, observer, keyPath, options, context);
    }else {
        [self.obInfos addObject:info];
        [self.target mtcpInstance_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

#pragma mark - Receive
- (void)stub_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    MTCrashProtectorObserverStubInfo *info = [[MTCrashProtectorObserverStubInfo alloc] initWithObserver:self.target keyPath:keyPath option:0 context:context];
    if ([self obInfosContainsInfoOnlyCaseObserverKeyPathAndContext:info] && [self.target respondsToSelector:@selector(mtcpInstance_observeValueForKeyPath:ofObject:change:context:)]) {
        [self.target mtcpInstance_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }else {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, no observer:%@ keyPath:%@ context:%p registered on %@, cannot send message", [self class], object, keyPath, context, self.target]];
        NSLog(@"no observer:%@ keyPath:%@ context:%p registered on %@, cannot send message", object, keyPath, context, self.target);
    }
}

#pragma mark - Private
- (MTCrashProtectorObserverStubInfo *)obInfosContainsInfo:(MTCrashProtectorObserverStubInfo *)info {
    if (!info) {
        return nil;
    }
    __block MTCrashProtectorObserverStubInfo *matchedInfo;
    [self.obInfos enumerateObjectsUsingBlock:^(MTCrashProtectorObserverStubInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:info]) {
            matchedInfo = obj;
            *stop = YES;
        }
    }];
    return matchedInfo;
}

- (NSMutableArray<MTCrashProtectorObserverStubInfo *> *)obInfosContainsInfoOnlyCaseObserverAndKeyPath:(MTCrashProtectorObserverStubInfo *)info {
    NSMutableArray<MTCrashProtectorObserverStubInfo *> *casedInfos = [NSMutableArray new];
    if (!info) {
        return casedInfos;
    }
    [self.obInfos enumerateObjectsUsingBlock:^(MTCrashProtectorObserverStubInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualOnlyCaseObserverAndKeyPath:info]) {
            [casedInfos addObject:obj];
        }
    }];
    return casedInfos;
}

- (MTCrashProtectorObserverStubInfo *)obInfosContainsInfoOnlyCaseObserverKeyPathAndContext:(MTCrashProtectorObserverStubInfo *)info {
    __block MTCrashProtectorObserverStubInfo *casedInfo;
    if (!info) {
        return nil;
    }
    [self.obInfos enumerateObjectsUsingBlock:^(MTCrashProtectorObserverStubInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualOnlyCaseObserverKeyPathAndContext:info]) {
            casedInfo = obj;
            *stop = YES;
        }
    }];
    return casedInfo;
}
@end
