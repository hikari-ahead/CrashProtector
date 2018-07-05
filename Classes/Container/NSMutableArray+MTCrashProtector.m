//
//  NSMutableArray+MTCrashProtector.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/14.
//

#import "NSMutableArray+MTCrashProtector.h"
#import <UIKit/UIKit.h>
#import "MTCrashProtector.h"

@implementation NSMutableArray (MTCrashProtector)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![MTCrashProtectorSetting.shared enableStateForModule:MTCrashProtectorModuleContainer]) {
            return;
        }
        float sysVer = [UIDevice currentDevice].systemVersion.floatValue;
        // Add
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(@"__NSArrayM"), NSStringFromSelector(@selector(addObject:)), NSStringFromSelector(@selector(mtcpInstance_addObject:)));
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(@"__NSArrayM"), NSStringFromSelector(@selector(insertObject:atIndex:)), NSStringFromSelector(@selector(mtcpInstance_insertObject:atIndex:)));
        MTCrashProtectorInstanceMethodSwizzling([self class], NSStringFromSelector(@selector(insertObjects:atIndexes:)), NSStringFromSelector(@selector(mtcpInstance_insertObjects:atIndexes:)));
        // Remove
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(@"__NSArrayM"), NSStringFromSelector(@selector(removeObjectAtIndex:)), NSStringFromSelector(@selector(mtcpInstance_removeObjectAtIndex:)));
        MTCrashProtectorInstanceMethodSwizzling([self class], NSStringFromSelector(@selector(removeObjectsAtIndexes:)), NSStringFromSelector(@selector(mtcpInstance_removeObjectsAtIndexes:)));
        MTCrashProtectorInstanceMethodSwizzling([self class], NSStringFromSelector(@selector(removeObject:inRange:)), NSStringFromSelector(@selector(mtcpInstance_removeObject:inRange:)));
        MTCrashProtectorInstanceMethodSwizzling([self class], NSStringFromSelector(@selector(removeObjectIdenticalTo:inRange:)), NSStringFromSelector(@selector(mtcpInstance_removeObjectIdenticalTo:inRange:)));
        Class cls = NSClassFromString(@"__NSArrayM");
        if (sysVer < 10.0) {
            // iOS 10 以下系统，__NSArrayM没有重写NSMutableArray的Method:
            // - removeObjectsInRange:
            // - setObject:atIndexedSubscript:
            cls = [self class];
        }
        MTCrashProtectorInstanceMethodSwizzling(cls, NSStringFromSelector(@selector(removeObjectsInRange:)), NSStringFromSelector(@selector(mtcpInstance_removeObjectsInRange:)));
        // Modif
        MTCrashProtectorInstanceMethodSwizzling(NSClassFromString(@"__NSArrayM"), NSStringFromSelector(@selector(replaceObjectAtIndex:withObject:)), NSStringFromSelector(@selector(mtcpInstance_replaceObjectAtIndex:withObject:)));
        MTCrashProtectorInstanceMethodSwizzling(cls, NSStringFromSelector(@selector(setObject:atIndexedSubscript:)), NSStringFromSelector(@selector(mtcpInstance_setObject:atIndexedSubscript:)));
        MTCrashProtectorInstanceMethodSwizzling([self class], NSStringFromSelector(@selector(replaceObjectsAtIndexes:withObjects:)), NSStringFromSelector(@selector(mtcpInstance_replaceObjectsAtIndexes:withObjects:)));
        MTCrashProtectorInstanceMethodSwizzling([self class], NSStringFromSelector(@selector(replaceObjectsInRange:withObjectsFromArray:range:)), NSStringFromSelector(@selector(mtcpInstance_replaceObjectsInRange:withObjectsFromArray:range:)));
        MTCrashProtectorInstanceMethodSwizzling([self class], NSStringFromSelector(@selector(replaceObjectsInRange:withObjectsFromArray:)), NSStringFromSelector(@selector(mtcpInstance_replaceObjectsInRange:withObjectsFromArray:)));
    });
}

#pragma mark - Add
- (void)mtcpInstance_addObject:(id)anObject {
    if (anObject) {
        [self mtcpInstance_addObject:anObject];
    }else {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, can not add nil in an Array", [self class]]];
        NSLog(@"can not add nil in an Array");
    }
}

- (void)mtcpInstance_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, object cannot be nil", [self class]]];
        NSLog(@"object cannot be nil");
        return;
    }
    if (index > self.count) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, index out of bounds", [self class]]];
        NSLog(@"index out of bounds");
        return;
    }
    [self mtcpInstance_insertObject:anObject atIndex:index];
}

- (void)mtcpInstance_insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    if (!indexes) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, indexes cannot be nil", [self class]]];
        NSLog(@"indexes cannot be nil");
        return;
    }
    if (objects.count != indexes.count) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, count of array (%lu) differs from count of index set (%lu)", [self class], (unsigned long)objects.count, (unsigned long)indexes.count]];
        NSLog(@"count of array (%lu) differs from count of index set (%lu)", (unsigned long)objects.count, (unsigned long)indexes.count);
        return;
    }
    __block BOOL ofb = NO;
    __block NSUInteger cnt = objects.count;
    __block NSUInteger ofbIdx = 0;
    // 判断insert之后是否会出现越界的情况
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > objects.count) {
            ofb = YES;
            ofbIdx = idx;
            *stop = YES;
        }else {
            ++cnt;
        }
    }];
    if (ofb) {
        if (self.count == 0) {
            [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, index %lu in index set beyond empty array bounds", [self class], (unsigned long)ofbIdx]];
            NSLog(@"index %lu in index set beyond empty array bounds", (unsigned long)ofbIdx);
        }else {
            [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, index %lu in index set beyond bounds [0 .. %lu]", [self class], (unsigned long)ofbIdx, (unsigned long)cnt]];
            NSLog(@"index %lu in index set beyond bounds [0 .. %lu]", (unsigned long)ofbIdx, (unsigned long)cnt);
        }
        return;
    }
    [self mtcpInstance_insertObjects:objects atIndexes:indexes];
}

#pragma mark - Remove
- (void)mtcpInstance_removeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, removeObjectAtIndex:,index %lu in index set beyond bounds [0 .. %lu]", [self class], (unsigned long)index, self.count - 1]];
        NSLog(@"removeObjectAtIndex:,index %lu in index set beyond bounds [0 .. %lu]", (unsigned long)index, self.count - 1);
        return;
    }
    [self mtcpInstance_removeObjectAtIndex:index];
}

- (void)mtcpInstance_removeObjectsAtIndexes:(NSIndexSet *)indexes {
    __block BOOL ofb = NO;
    __block NSUInteger ofbIdx = 0;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= self.count) {
            ofb = YES;
            ofbIdx = idx;
            *stop = YES;
        }
    }];
    if (ofb) {
        if (self.count == 0) {
            [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, index %lu in index set beyond empty array bounds", [self class], (unsigned long)ofbIdx]];
            NSLog(@"index %lu in index set beyond empty array bounds", (unsigned long)ofbIdx);
        }else {
            [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, index %lu in index set beyond bounds [0 .. %lu]", [self class], (unsigned long)ofbIdx, self.count - 1]];
            NSLog(@"index %lu in index set beyond bounds [0 .. %lu]", (unsigned long)ofbIdx, self.count - 1);
        }
        return;
    }
    [self mtcpInstance_removeObjectsAtIndexes:indexes];
}

- (void)mtcpInstance_removeObject:(id)anObject inRange:(NSRange)range {
    if ((NSMaxRange(range) - 1) < self.count) {
        [self mtcpInstance_removeObject:anObject inRange:range];
    }else {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, range {%lu .. %lu} exceeds array bounds", [self class], (unsigned long)range.location, NSMaxRange(range) - 1]];
        NSLog(@"range {%lu .. %lu} exceeds array bounds", (unsigned long)range.location, NSMaxRange(range) - 1);
    }
}

- (void)mtcpInstance_removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    if ((NSMaxRange(range) - 1) < self.count) {
        [self mtcpInstance_removeObjectIdenticalTo:anObject inRange:range];
    }else {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, range {%lu .. %lu} exceeds array bounds", [self class], (unsigned long)range.location, NSMaxRange(range) - 1]];
        NSLog(@"range {%lu .. %lu} exceeds array bounds", (unsigned long)range.location, NSMaxRange(range) - 1);
    }
}

- (void)mtcpInstance_removeObjectsInRange:(NSRange)range {
    if ((NSMaxRange(range) - 1) < self.count) {
        [self mtcpInstance_removeObjectsInRange:range];
    }else {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, range {%lu .. %lu} exceeds array bounds", [self class], (unsigned long)range.location, NSMaxRange(range) - 1]];
        NSLog(@"range {%lu .. %lu} exceeds array bounds", (unsigned long)range.location, NSMaxRange(range) - 1);
    }
}

#pragma mark - Modify
- (void)mtcpInstance_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (!anObject) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, object cannot be nil", [self class]]];
        NSLog(@"object cannot be nil");
        return;
    }
    if (index > self.count - 1) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, index out of bounds, can not replace", [self class]]];
        NSLog(@"index out of bounds, can not replace");
        return;
    }
    [self mtcpInstance_replaceObjectAtIndex:index withObject:anObject];
}

- (void)mtcpInstance_setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    if (!obj) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, object cannot be nil", [self class]]];
        NSLog(@"object cannot be nil");
        return;
    }
    if (idx > self.count) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, index out of bounds, can not set object", [self class]]];
        NSLog(@"index out of bounds, can not set object");
        return;
    }
    [self mtcpInstance_setObject:obj atIndexedSubscript:idx];
}

- (void)mtcpInstance_replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    if (!objects) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, objects can not be nil, can not replace", [self class]]];
        NSLog(@"objects can not be nil, can not replace");
        return;
    }
    if (!indexes) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, indexes can not be nil, can not replace", [self class]]];
        NSLog(@"indexes can not be nil, can not replace");
        return;
    }
    __block BOOL ofb = NO;
    __block NSUInteger ofbIdx = 0;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > self.count - 1) {
            ofb = YES;
            ofbIdx = idx;
            *stop = YES;
        }
    }];
    if (ofb) {
        if (self.count == 0) {
            [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, index %lu in indexes set beyond empty array bounds", [self class], (unsigned long)ofbIdx]];
            NSLog(@"index %lu in indexes set beyond empty array bounds", (unsigned long)ofbIdx);
        }else {
            [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, index %lu in indexes set beyond bounds [0 .. %lu]", [self class], (unsigned long)ofbIdx, self.count - 1]];
            NSLog(@"index %lu in indexes set beyond bounds [0 .. %lu]", (unsigned long)ofbIdx, self.count - 1);
        }
        return;
    }
    [self mtcpInstance_replaceObjectsAtIndexes:indexes withObjects:objects];
}

- (void)mtcpInstance_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
    if (MIN(NSMaxRange(range) - 1, NSMaxRange(range)) > self.count) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, range {%lu .. %lu} exceeds array bounds", [self class], (unsigned long)range.location, NSMaxRange(range) - 1]];
        NSLog(@"range {%lu .. %lu} exceeds array bounds", (unsigned long)range.location, NSMaxRange(range) - 1);
        return;
    }
    if (MIN(NSMaxRange(otherRange) - 1, NSMaxRange(range)) > otherArray.count || !otherArray) {
        if (!otherArray) {
            [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, otherRange {%lu .. %lu} exceeds otherArray bounds, cause otherArray is nil", [self class], (unsigned long)otherRange.location, NSMaxRange(otherRange) - 1]];
            NSLog(@"otherRange {%lu .. %lu} exceeds otherArray bounds, cause otherArray is nil", (unsigned long)otherRange.location, NSMaxRange(otherRange) - 1);
        }else {
            [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, otherRange {%lu .. %lu} exceeds otherArray bounds", [self class], (unsigned long)otherRange.location, NSMaxRange(otherRange) - 1]];
            NSLog(@"otherRange {%lu .. %lu} exceeds otherArray bounds", (unsigned long)otherRange.location, NSMaxRange(otherRange) - 1);
        }
        return;
    }
    [self mtcpInstance_replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];
}

- (void)mtcpInstance_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    if (MIN(NSMaxRange(range) - 1, NSMaxRange(range)) > self.count) {
        [MTCrashProtectorReporter.shareInstance reportErrorWithReason:[NSString stringWithFormat:@"cls:%@, range {%lu .. %lu} exceeds array bounds", [self class], (unsigned long)range.location, NSMaxRange(range) - 1]];
        NSLog(@"range {%lu .. %lu} exceeds array bounds", (unsigned long)range.location, NSMaxRange(range) - 1);
        return;
    }
    [self mtcpInstance_replaceObjectsInRange:range withObjectsFromArray:otherArray];
    // 会继续调用mtcpInstance_replaceObjectAtIndex
}
@end
