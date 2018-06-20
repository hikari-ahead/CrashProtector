//
//  MTCrashProtectorCallStackUtil.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/8.
//

#import "MTCrashProtectorCallStackUtil.h"
#import "objc/runtime.h"
#import "dlfcn.h"

@implementation MTCrashProtectorCallStackUtil
+ (BOOL)isInTargetBundleWithClass:(Class)cls selector:(SEL)aSelector {
    Dl_info info;
    IMP imp = class_getMethodImplementation(cls, aSelector);
    dladdr(imp, &info);
    NSString *dli_fname = [NSString stringWithUTF8String:info.dli_fname];
    NSString *mainBundleName = @"CrashProtectorDemo"; //TODO: 改为非写死
    if ([dli_fname hasSuffix:mainBundleName]) {
        return YES;
    }
    return NO;
}
@end
