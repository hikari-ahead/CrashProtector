//
//  NSArray+MTCrashProtector.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/13.
//

#import "NSArray+MTCrashProtector.h"
#import "MTCrashProtector.h"
#import "dlfcn.h"
#import <UIKit/UIKit.h>

@implementation NSArray (MTCrashProtector)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleContainer]) {
            return;
        }
        [self swizzleInitWithObjectWithCountMethod];
        [self swizzleObjectAtIndex];
        [self swizzleObjectAtIndexedSubscript];
    });
}

/** NSArray, NSMutableArray, __NSPlaceholderArray, __NSArray0, __NSArrayI, __NSArrayM, __NSSingleObjectArrayI, __NSArrayReversed, __NSCFArray */
+ (void)swizzleObjectAtIndexedSubscript {
    // 对于操作符重载[]， iOS 11开始 __NSArrayI，__NSArrayM 对`objectAtIndexedSubscriptc`进行了重写，所以需要hook
    NSMutableArray *clsArray = [[NSMutableArray alloc] initWithArray:@[@"NSArray"]];
    float sysVer = [UIDevice currentDevice].systemVersion.floatValue;
    if (sysVer >= 11.0) {
        [clsArray addObject:@"__NSArrayI"];
        [clsArray addObject:@"__NSArrayM"];
    }

    [clsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *newStr = [NSString stringWithFormat:@"%@_mtcpInstance_objectAtIndexedSubscript:",obj];
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(obj),
                                                NSStringFromSelector(@selector(objectAtIndexedSubscript:)),
                                                newStr);
    }];
}

+ (void)swizzleObjectAtIndex {
    // TODO: @"__NSCFArray"
    NSMutableArray *clsArray = [[NSMutableArray alloc] initWithArray:@[@"NSArray", @"__NSArray0", @"__NSArrayI", @"__NSArrayM", @"__NSPlaceholderArray", @"__NSArrayReversed", @"__NSSingleObjectArrayI"]];

    float sysVer = [UIDevice currentDevice].systemVersion.floatValue;
    if (sysVer < 10.0) {
        // iOS 10以下不存在 __NSSingleObjectArrayI
        [clsArray removeObject:@"__NSSingleObjectArrayI"];
    }
    if (sysVer < 9.0) {
        // iOS 9以下不存在 __NSArray0，
        [clsArray removeObject:@"__NSArray0"];
    }
    [clsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *newStr = [NSString stringWithFormat:@"%@_mtcpInstance_objectAtIndex:",obj];
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(obj),
                                                NSStringFromSelector(@selector(objectAtIndex:)),
                                                newStr);
    }];
}

+ (void)swizzleInitWithObjectWithCountMethod {
    Class cls = NSClassFromString(@"__NSPlaceholderArray");
    NSString *oriStr = NSStringFromSelector(@selector(initWithObjects:count:));
    NSString *newStr = NSStringFromSelector(@selector(mtcpInstance_initWithObjects:count:));
    MTCrashProtectorInstanceMethodSwizzling(cls, oriStr, newStr);
}

- (BOOL)isSubscriptOutOfBounds:(NSUInteger)idx {
    BOOL ofb = (idx >= self.count);
    if (ofb) {
        // 记录堆栈信息
        NSLog(@"##### cls: %@ idx: %ld is out of bounds", [self class], idx);
    }
    return ofb;
}

#pragma mark - __NSArray0
- (id)__NSArray0_mtcpInstance_objectAtIndex:(NSUInteger)index {
    return ([self isSubscriptOutOfBounds:index] ? nil : [self __NSArray0_mtcpInstance_objectAtIndex:index]);
}

- (id)__NSArray0_mtcpInstance_objectAtIndexedSubscript:(NSUInteger)index {
    return ([self isSubscriptOutOfBounds:index] ? nil : [self __NSArray0_mtcpInstance_objectAtIndexedSubscript:index]);
}

#pragma mark - __NSArrayI
- (id)__NSArrayI_mtcpInstance_objectAtIndex:(NSUInteger)idx {
    return ([self isSubscriptOutOfBounds:idx] ? nil : [self __NSArrayI_mtcpInstance_objectAtIndex:idx]);
}

- (id)__NSArrayI_mtcpInstance_objectAtIndexedSubscript:(NSUInteger)index {
    return ([self isSubscriptOutOfBounds:index] ? nil : [self __NSArrayI_mtcpInstance_objectAtIndexedSubscript:index]);
}

#pragma mark - __NSArrayM
- (id)__NSArrayM_mtcpInstance_objectAtIndex:(NSUInteger)idx {
    return ([self isSubscriptOutOfBounds:idx] ? nil : [self __NSArrayM_mtcpInstance_objectAtIndex:idx]);
}

- (id)__NSArrayM_mtcpInstance_objectAtIndexedSubscript:(NSUInteger)index {
    return ([self isSubscriptOutOfBounds:index] ? nil : [self __NSArrayM_mtcpInstance_objectAtIndexedSubscript:index]);
}

#pragma mark - __NSPlaceholderArray
- (id)__NSPlaceholderArray_mtcpInstance_objectAtIndex:(NSUInteger)idx {
    return ([self isSubscriptOutOfBounds:idx] ? nil : [self __NSPlaceholderArray_mtcpInstance_objectAtIndex:idx]);
}

- (id)__NSPlaceholderArray_mtcpInstance_objectAtIndexedSubscript:(NSUInteger)index {
    return ([self isSubscriptOutOfBounds:index] ? nil : [self __NSPlaceholderArray_mtcpInstance_objectAtIndexedSubscript:index]);
}

#pragma mark - __NSArrayReversed 
- (id)__NSArrayReversed_mtcpInstance_objectAtIndex:(NSUInteger)idx {
    return ([self isSubscriptOutOfBounds:idx] ? nil : [self __NSArrayReversed_mtcpInstance_objectAtIndex:idx]);
}

- (id)__NSArrayReversed_mtcpInstance_objectAtIndexedSubscript:(NSUInteger)index {
    return ([self isSubscriptOutOfBounds:index] ? nil : [self __NSArrayReversed_mtcpInstance_objectAtIndexedSubscript:index]);
}

#pragma mark - __NSSingleObjectArrayI
- (id)__NSSingleObjectArrayI_mtcpInstance_objectAtIndex:(NSUInteger)idx {
    return ([self isSubscriptOutOfBounds:idx] ? nil : [self __NSSingleObjectArrayI_mtcpInstance_objectAtIndex:idx]);
}

- (id)__NSSingleObjectArrayI_mtcpInstance_objectAtIndexedSubscript:(NSUInteger)index {
    return ([self isSubscriptOutOfBounds:index] ? nil : [self __NSSingleObjectArrayI_mtcpInstance_objectAtIndexedSubscript:index]);
}

#pragma mark - __NSCFArray nonSubscript
//- (id)__NSCFArray_mtcpInstance_objectAtIndex:(NSUInteger)idx {
//    Dl_info info;
//    IMP imp = class_getMethodImplementation([self class], _cmd);
//    dladdr(imp, &info);
////    CFArrayGetValueAtIndex
//    return idx < self.count ? [self __NSCFArray_mtcpInstance_objectAtIndex:idx] : nil;
//    BOOL flag = [self isSubscriptOutOfBounds:idx];
//    if (flag) {
//        id ori = [self __NSCFArray_mtcpInstance_objectAtIndex:idx];
//        return nil;
//    }else {
//        id ori = [self __NSCFArray_mtcpInstance_objectAtIndex:idx];
//        return ori;
//    }
//    return ([self isSubscriptOutOfBounds:idx] ? nil : [self __NSCFArray_mtcpInstance_objectAtIndex:idx]);
//}

#pragma mark - NSArray
- (id)NSArray_mtcpInstance_objectAtIndex:(NSUInteger)index {
    return ([self isSubscriptOutOfBounds:index] ? nil : [self NSArray_mtcpInstance_objectAtIndex:index]);
}

- (id)NSArray_mtcpInstance_objectAtIndexedSubscript:(NSUInteger)idx {
    return ([self isSubscriptOutOfBounds:idx] ? nil : [self NSArray_mtcpInstance_objectAtIndexedSubscript:idx]);
}

- (instancetype)mtcpInstance_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    __block BOOL hasNil = NO;
    for (int i = 0; i < cnt; i++) {
        if (objects[i] == nil) {
            hasNil = YES;
            break;
        }
    }
    if (!hasNil) {
        id ori = [self mtcpInstance_initWithObjects:objects count:cnt];
        return ori;
    }else {
        NSLog(@"调用initWithObjects时数据包含nil");
        return nil;
    }
}
@end
