#import "MTCrashProtectorSetting.h"
#import <objc/runtime.h>

#define MTCrashProtectorInstanceMethodSwizzling(cls, oriStr, newStr) {\
SEL originalSEL = NSSelectorFromString(oriStr);\
SEL newSEL = NSSelectorFromString(newStr);\
Method originalMethod = class_getInstanceMethod(cls, originalSEL);\
Method newMethod = class_getInstanceMethod(cls, newSEL);\
BOOL didAddMethod = class_addMethod(cls, originalSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));\
if (didAddMethod) {\
    class_replaceMethod(cls, originalSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));\
}else {\
    method_exchangeImplementations(originalMethod, newMethod);\
}\
NSLog(@"MTCrashProtector Instance Method Swizzling\n-> cls:%@, ori:%@, new:%@ didAddMethod:%@", cls, NSStringFromSelector(originalSEL), NSStringFromSelector(newSEL), didAddMethod ? @"YES" : @"NO");\
}

#define MTCrashProtectorClassMethodSwizzling(cls, oriStr, newStr) {\
SEL originalSEL = NSSelectorFromString(oriStr);\
SEL newSEL = NSSelectorFromString(newStr);\
Method originalMethod = class_getClassMethod(cls, originalSEL);\
Method newMethod = class_getClassMethod(cls, newSEL);\
Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);\
BOOL didAddMethod = class_addMethod(metacls, originalSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));\
if (didAddMethod) {\
class_replaceMethod(metacls, originalSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));\
}else {\
method_exchangeImplementations(originalMethod, newMethod);\
}\
NSLog(@"MTCrashProtector Class Method Swizzling\n-> metacls:%@, ori:%@, new:%@ didAddMethod:%@", metacls, NSStringFromSelector(originalSEL), NSStringFromSelector(newSEL), didAddMethod ? @"YES" : @"NO");\
}
