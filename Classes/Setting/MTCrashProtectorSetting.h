//
//  MTCrashProtectorSetting.h
//  Pods-CrashProtectorDemo
//
//  Created by kuangjeon on 2018/6/20.
//

#import <Foundation/Foundation.h>

enum MTCrashProtectorModule: int {
    /** 解决timer强引用 */
    MTCrashProtectorModuleTimer = 0,
    /** 容器类crash防护 */
    MTCrashProtectorModuleContainer,
    /** 通知防护（iOS8以下才会开启） */
    MTCrashProtectorModuleNotification,
    /** KVO crash防护 */
    MTCrashProtectorModuleObserver,
    /** unrecognizedSelector防护 */
    MTCrashProtectorModuleSelector
};

@interface MTCrashProtectorSetting : NSObject
/** 总开关，所有模块默认开启，可以通过设置disabledModules部分关闭 */
@property (nonatomic, assign, readonly) BOOL protectingEnable;
//@property (nonatomic, strong) NSArray<NSNumber *> *disabledModules;
+ (instancetype)shared;
- (BOOL)enableStateForModule:(int)m;
@end
