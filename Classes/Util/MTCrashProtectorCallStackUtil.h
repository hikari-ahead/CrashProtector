//
//  MTCrashProtectorCallStackUtil.h
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTCrashProtectorCallStackUtil : NSObject
+ (BOOL)isInTargetBundleWithClass:(Class)cls selector:(SEL)aSelector;
@end

NS_ASSUME_NONNULL_END
