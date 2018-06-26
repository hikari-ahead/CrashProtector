//
//  MTCrashProtectorNotificationStub.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/12.
//
#import "MTCrashProtectorNotificationStub.h"
#import "MTCrashProtectorNotificationStubInfo.h"
#import "NSNotificationCenter+MTCrashProtectorNotificationDelegate.h"
#import "MTCrashProtectorReporter.h"

@interface MTCrashProtectorNotificationStub()
@property (nonatomic, weak) NSNotificationCenter *target;
@property (nonatomic, strong) NSMutableArray<MTCrashProtectorNotificationStubInfo *> *notificationInfos;
@end

@implementation MTCrashProtectorNotificationStub
- (instancetype)initWithTarget:(NSNotificationCenter *)target {
    self = [super init];
    if (self) {
        self.target = target;
        self.notificationInfos = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Add
- (id<NSObject>)stub_addObserverForName:(NSNotificationName)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block {
    MTCrashProtectorNotificationStubInfo *info = [[MTCrashProtectorNotificationStubInfo alloc] initWithName:name object:obj queue:queue block:block];
    if ([self isInfoAlreadyExists:info]) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, could add an duplicate observer name:%@, obj:%p, queue:%@, block:%@ on defaultCenter", [self class],name, obj, queue, block]];
        NSLog(@"could add an duplicate observer name:%@, obj:%p, queue:%@, block:%@ on defaultCenter", name, obj, queue, block);
        return nil;
    }else {
        id token = [self.target mtcpInstance_addObserverForName:name object:obj queue:queue usingBlock:block];
        info.token = token;
        [self.notificationInfos addObject:info];
        return token;
    }
}
- (void)stub_addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject {
    MTCrashProtectorNotificationStubInfo *info = [[MTCrashProtectorNotificationStubInfo alloc] initWithObserver:observer selector:aSelector name:aName object:anObject];
    if ([self isInfoAlreadyExists:info]) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, could add an duplicate observer:%@, SEL:%p, name:%@, object:%@ on defaultCenter", [self class],observer, aSelector, aName, anObject]];
        NSLog(@"could add an duplicate observer:%@, SEL:%p, name:%@, object:%@ on defaultCenter", observer, aSelector, aName, anObject);
    }else {
        [self.target mtcpInstance_addObserver:observer selector:aSelector name:aName object:anObject];
        [self.notificationInfos addObject:info];
    }
}

#pragma mark - Remove
- (void)stub_removeObserver:(id)observer name:(NSNotificationName)aName object:(id)anObject {
    MTCrashProtectorNotificationStubInfo *info = [[MTCrashProtectorNotificationStubInfo alloc] initWithObserver:observer selector:nil name:aName object:anObject];
    NSArray *matchedInfos = [self notificationInfosContainsOnlyCaseObserverNameAndObject:info];
    if (matchedInfos.count > 0) {
        [self.target mtcpInstance_removeObserver:observer name:aName object:anObject];
        [self.notificationInfos removeObjectsInArray:matchedInfos];
    }else {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, has not register any notification for observer:%@, name:%@, object:%@ cannot remove", [self class], observer, aName, anObject]];
        NSLog(@"has not register any notification for observer:%@, name:%@, object:%@ cannot remove", observer, aName, anObject);
    }
}
- (void)stub_removeObserver:(id)observer {
    MTCrashProtectorNotificationStubInfo *info = [[MTCrashProtectorNotificationStubInfo alloc] initWithObserver:observer selector:nil name:nil object:nil];
    NSArray *matchedInfos = [self notificationInfosContainsOnlyCaseObserver:info];
    if (matchedInfos.count > 0) {
        [self.target mtcpInstance_removeObserver:observer];
        [self.notificationInfos removeObjectsInArray:matchedInfos];
    }else {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, has not register any notification on observer:%@, cannot remove", [self class], observer]];
        NSLog(@"has not register any notification on observer:%@, cannot remove", observer);
    }
}

#pragma mark - Post
- (void)stub_postNotification:(NSNotification *)notification {
    [self.target mtcpInstance_postNotification:notification];
}

- (void)stub_postNotificationName:(NSNotificationName)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    [self.target mtcpInstance_postNotificationName:aName object:anObject userInfo:aUserInfo];
}

- (void)stub_postNotificationName:(NSNotificationName)aName object:(id)anObject {
    [self.target mtcpInstance_postNotificationName:aName object:anObject];
}

#pragma mark - Private
- (BOOL)isInfoAlreadyExists:(MTCrashProtectorNotificationStubInfo *)info {
    __block BOOL exists = NO;
    [self.notificationInfos enumerateObjectsUsingBlock:^(MTCrashProtectorNotificationStubInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:info]) {
            exists = YES;
            *stop = YES;
        }
    }];
    return exists;
}

- (NSArray<MTCrashProtectorNotificationStubInfo *> *)notificationInfosContainsOnlyCaseObserverNameAndObject:(MTCrashProtectorNotificationStubInfo *)info {
    __block NSMutableArray *matchedInfos = [NSMutableArray new];
    [self.notificationInfos enumerateObjectsUsingBlock:^(MTCrashProtectorNotificationStubInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualOnlyCaseObserverNameAndObject:info]) {
            [matchedInfos addObject:obj];
        }
    }];
    return matchedInfos;
}

- (NSArray<MTCrashProtectorNotificationStubInfo *> *)notificationInfosContainsOnlyCaseObserver:(MTCrashProtectorNotificationStubInfo *)info {
    __block NSMutableArray *matchedInfos = [NSMutableArray new];
    [self.notificationInfos enumerateObjectsUsingBlock:^(MTCrashProtectorNotificationStubInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualOnlyCaseObserver:info]) {
            [matchedInfos addObject:obj];
        }
    }];
    return matchedInfos;
}
@end
