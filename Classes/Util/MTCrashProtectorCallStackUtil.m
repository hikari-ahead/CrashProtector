//
//  MTCrashProtectorCallStackUtil.m
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/8.
//

#import "MTCrashProtectorCallStackUtil.h"
#import "objc/runtime.h"
#import "execinfo.h"
#include "unistd.h"

@implementation MTCrashProtectorCallStackUtil
+ (BOOL)isCalledByMainBundle {
//    const char *name = [[[NSProcessInfo processInfo] processName] cStringUsingEncoding:NSUTF8StringEncoding];
//    int nptrs;
//#define SIZE 3
//    void *buffer[3];
//    char **strings;
//    nptrs = backtrace(buffer, SIZE);
//    strings = backtrace_symbols(buffer, nptrs);
//    if (nptrs < 3) {
//        // rarely
//        free(strings);
//        return NO;
//    }else {
//        char *bt = strings[2];
//        const char *result = strstr(bt, name);
//        if (result == NULL) {
//            return NO;
//        }else {
//            return YES;
//        }
//    }
    return YES;
}
@end

