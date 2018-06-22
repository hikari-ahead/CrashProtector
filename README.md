#  MTCrashProtector - runtime crash protector

## 0x1.前言
前段时间无意间看到网易前端技术博客中的[大白健康系统--iOS App运行时Crash自动修复系统](https://neyoufan.github.io/2017/01/13/ios/BayMax_HTSafetyGuard/)这篇文章，利用Objective-C动态的语言特性，在App将要崩溃（抛出异常）时捕获异常进行处理，消灭异常，进行信息上报，保证App继续正常的运行。其主要面向**8**个方面：

1. **Unrecognized Selector Crash**
2. **KVO Crash**
3. **NSNotification crash (below iOS8)**
4. **NSTimer Crash**
5. **Container Crash**
6. **NSString Crash**
7. **Bad Access Crash**
8. **UI Not On Main Thread Crash**

原文中有介绍这几种防护的大致思路，但是没有找到开源的项目，于是思索着并实现了自己一套运行时Crash保护组件：[MTCrashProtector](https://github.com/Nanfo1Fhzh/CrashProtector)。

目前组件实现了上述**8**个方面的前**5**部分。

## 0x2.准备

###### 创建SDK工程

既然我们是准备实现一个组件供他人接入使用，显然我们应该创建一个`xcworkspace`来管理多个`target`进行开发。在这里有两种可选的方式:

- 手动新建一个`xxDemo.xcworkspace`项目，然后依次添加两个`target`（体力活，不推荐）:
    
    1. 类型为`Single View Application`名为`xxDemo`
    2. 类型为`Cocoa Touch Framework`名为`xxSDK` （这里我们目标是生成动态库，如果不希望公开源代码，希望生成`.a`的话，请选择`Cocoa Touch Static Library`）
    
  通过这种方式进行SDK的开发，并且以`xxDemo`为入口编写测试代码，最终发布时单独提出`xxSDK`这个target进行发布即可。
  
- 使用`Cocoapods`的`pod lib`命令创建，进行`Development Pod`开发。

  切换到工作目录后执行以下命令，按照提示输入：
  
  ```ruby
 
    $ pod lib create MTCrashProtector    
    
    What platform do you want to use?? [ iOS / macOS ]
     > iOS
    
    What language do you want to use?? [ Swift / ObjC ]
     > ObjC
    
    Would you like to include a demo application with your library? [ Yes / No ]
     > Yes
    
    Which testing frameworks will you use? [ Specta / Kiwi / None ]
     > None
    
    Would you like to do view based testing? [ Yes / No ]
     > No
    
    What is your class prefix?
     > MT
    
    Running pod install on your new library.
    
    Ignoring unf_ext-0.0.7.4 because its extensions are not built.  Try: gem pristine unf_ext --version 0.0.7.4
    Analyzing dependencies
    Fetching podspec for `MTCrashProtector` from `../`
    Downloading dependencies
    Installing MTCrashProtector (0.1.0)
    Generating Pods project
    Integrating client project
    
    [!] Please close any current Xcode sessions and use `MTCrashProtector.xcworkspace` for this project from now on.
    Sending stats
    Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.

  ```

工程生成后自行按需修改`*.podspec`，这个后面会用到。注意`s.homepage`要确保可以访问，使用

```ruby
pod spec lint *.podspec --allow-warnings
```
验证podspec通过即可。

#### 目录结构

```c
=> Classes
   - MTCrashProtector.h //快速进行Method Swizzling的宏定义
   => Container         //NSArray类簇/NSCache/NSDictionary类簇/NSObject
   => Notification      //通知相关
   => NSTimer           //NSTimer相关
   => Observer          //Observer相关
   => Selector          //target forwaring
   => Setting           //开关配置
   => Util
```

## 0x3. 实现

#### Unrecognized Selector Crash

Runtime msgSend流程：

1. 当前对象`objc_cache * _Nonnull cache`中寻找调用的方法`method`，如果存在`method`则转到对应的实现`IMP`并执行。

2. 如果未找到，在当前对象的`objc_method_list * _Nullable * _Nullable methodLists`中去寻找调用的方法`method`，如果存在method则转到对应的实现IMP并执行。

3. 如果`objc_method_list * _Nullable * _Nullable methodLists`中也没有找到，则转向父类`Class _Nullable super_class`中递归的执行1和2两步，直到到根类。如果存在`method`则转到对应的实现`IMP`并执行。

4. 如果到根类都没有找到`method`，则转向拦截调用，如果你使用`resolveClassMethod:`或者`resolveInstanceMethod:`解析了`method`（return YES），消息被标记为已处理，不会触发崩溃。
    
5. 如果没有实现`resolvexxxxxMethod:`让类去解析添加实现，则转向`forwardingTargetForSelector:`让别的对象去执行。如果别的对象接收到信息后并且正常调用了实现，消息被标记为已处理，不会触发崩溃。

6. 如果没有实现`forwardingTargetForSelector:`交给其他对象处理，则转向`forwardInvocation:`处理，如果实现了此方法将消息处理，则不会出发崩溃，否则将会继续调用`doesNotRecognizeSelector:`抛出异常触发崩溃。

上面流程可以看出：4，5，6三步都可以进行防护，选择5:`forwardingTargetForSelector:`的原因是因为：`resolveInstanceMethod:`或者`resolveClassMethod:`会给当前类添加一些不必要的方法，而`forwardInvocation:`需要生成一个`invocation`对象会造成额外的内存开销。这个组件的实现是添加一个stub类，然后所有触发的（需要排除为了特殊目的而特意实现的）`forwardingTargetForSelector:`指向这个stub类的单例，因为这个stub类也不一定（大部分情况是没有）包含这个method实现，所以会继续调用stub类的`resolvexxxxMethod:`方法，在这个地方去动态的为stub类添加对应的实现，来保证程序不会crash并且也不会污染已有的类。


#### Notification Crash 

这个Module只针对iOS 9以下，见官方文档：

```
- addObserver:selector:name:object:
Adds an entry to the notification center's dispatch table with an observer and a notification selector, and an optional notification name and sender.

Declaration

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject;
Parameters

observer
Object registering as an observer.

aSelector
Selector that specifies the message the receiver sends observer to notify it of the notification posting. The method specified by aSelector must have one and only one argument (an instance of NSNotification).

aName
The name of the notification for which to register the observer; that is, only notifications with this name are delivered to the observer.

If you pass nil, the notification center doesn’t use a notification’s name to decide whether to deliver it to the observer.

anObject
The object whose notifications the observer wants to receive; that is, only notifications sent by this sender are delivered to the observer.

If you pass nil, the notification center doesn’t use a notification’s sender to decide whether to deliver it to the observer.

Discussion

If your app targets iOS 9.0 and later or macOS 10.11 and later, you don't need to unregister an observer in its dealloc method. Otherwise, you should call removeObserver:name:object: before observer or any object passed to this method is deallocated.
```

hook NSNotificationCenter以下几个方法：

```objC
// - Add
SEL oriSEL = @selector(addObserverForName:object:queue:usingBlock:);
// - Remove
SEL oriSEL2 = @selector(removeObserver:name:object:);
SEL oriSEL3 = @selector(removeObserver:);
// - Post
SEL oriSEL4 = @selector(postNotification:);
SEL oriSEL5 = @selector(postNotificationName:object:userInfo:);
SEL oriSEL6 = @selector(postNotificationName:object:);
```

重点在于维护一个`notificationInfos`,通过不同的Method添加或者删除能够正确的匹配到已有的通知，保证不会重复添加，不会重复移除。

#### KVO Crash 

KVO Crash防护的实现和Notification Crash防护相似，都是使用一个stub去代理检查是否已经注册过相同的观察者（通知），然后再进行真正的添加或删除操作。

hook NSObject以下几个方法：

```objC
// - Add
SEL oriSEL = @selector(addObserver:forKeyPath:options:context:);
    
// - Remove
SEL oriSEL1 = @selector(removeObserver:forKeyPath:);
SEL oriSEL2 = @selector(removeObserver:forKeyPath:context:);
    
// - Receive
SEL oriSEL3 = @selector(observeValueForKeyPath:ofObject:change:context:);
    
// - Dealloc
SEL oriSEL4 = NSSelectorFromString(@"dealloc");
```

在NSObject执行dealloc方法时，根据设置的关联对象`mtcp_hasAddedObserver`来判断是否需要移除全部的observer来防止crash发生。

#### Container Crash

以NSArray类簇为例：
    
| Class Name | Description  |
| --- | --- |
| NSArray | 不可变数组的工厂类 |  
| NSMutableArray | 可变数组的工厂类 |
| __NSPlaceholderArray | 占位类，真正初始化的时候都是使用这个类的`initWithObjects:count:`方法|
| __NSArray0 | 初始化0元素不可变数组时最终生成这个类的对象 |
| __NSArrayI | 非0元素不可变数组对应的类 |
| __NSArrayM | 可变数组对应的类 |
| __NSSingleObjectArrayI | 单一元素不可变数组对应的类 |
| __NSArrayReversed | 作为一个NSArray的代理并以相反的顺序呈现原Array的内容 |
| __NSCFArray| CFArrayRef或CFMutableArrayRef。现在大多数CFArrayRefs都是__NSArray*，通过CF创建 | 
    
以上信息可以通过自身实验得到，但是不同的iOS版本之间可能会有区别，比如说在iOS 8及以下的系统中不存在`__NSArray0`这个私有类。其他更多详细的类簇可以查看：[Class Clusters](https://gist.github.com/Catfish-Man/bc4a9987d4d7219043afdf8ee536beb2)

1. init
    
    由于所有的Array都是有`__NSPlaceholderArray`来进行初始化的，所以只需要hook
    
    ```objC
    - [__NSPlaceholderArray initWithObjects:count:]
    ```
即可，根据传入的cnt和C style数组检测[0...cnt-1]中是否存在空指针，避免崩溃。
    
2. objectAtIndex
    
    CF中使用到的`__NSCFArray`不做处理，针对下列类进行`objectAtIndex:`进行hook
    
    ```objC
    @"NSArray", @"__NSArray0", @"__NSArrayI", @"__NSArrayM", @"__NSPlaceholderArray", @"__NSArrayReversed", @"__NSSingleObjectArrayI"
    ```
    
    额外注意iOS 10以下不存在`__NSSingleObjectArrayI`，iOS 9以下不存在`__NSArray0`即可
    
3. objectAtIndexedSubscript
    
    这个SEL其实是重载了操作符`[]`，不要直接调用这个方法，通过实验测试得知，iOS 11开始 `__NSArrayI`，`__NSArrayM` 对`objectAtIndexedSubscript:`进行了重写，所以需要hook，其他版本只需要hook父类`NSArray`中的这个方法即可。
    
4. 可变部分的Methods

    针对`__NSArrayM`需要hook以下方法：
    
    ```objC
    @selector(addObject:);    
    @selector(insertObject:atIndex:)
    @selector(removeObjectAtIndex:))
    @selector(replaceObjectAtIndex:withObject:)
    ```
    
    针对`NSMutableArray`需要hook以下方法：
    
    ```objC
    @selector(insertObjects:atIndexes:)
    @selector(removeObjectsAtIndexes:)
    @selector(removeObject:inRange:)
    @selector(removeObjectIdenticalTo:inRange:)
    @selector(replaceObjectsAtIndexes:withObjects:)
    @selector(replaceObjectsInRange:withObjectsFromArray:range:)
    @selector(replaceObjectsInRange:withObjectsFromArray:)
    ```
    
    由于系统版本的差异，以下方法需要根据iOS版本号来区分需要hook的具体类：
    
    ```objC
    // iOS 10 以下系统，__NSArrayM没有重写NSMutableArray的Method:
    Class cls = [UIDevice currentDevice].systemVersion.floatValue < 10.0 ? NSClassFromString(@"NSMutableArray") : NSClassFromString(@"__NSArrayM");
    @selector(removeObjectsInRange:)
    @selector(setObject:atIndexedSubscript:)
    ```

`NSDictionary类簇`的实现与`NSArray类簇`相似，重点是搞清楚各iOS版本之间子类对父类方法重写的情况，hook正确的方法，否则可能会出现循环调用最终程序崩溃的情况。

额外的，组件还对`NSObject`类`valueForUndefinedKey:`和`valueForKey:`进行了hook处理。

#### NSTimer

主要为了解决`NSTimer`与`TureTarget`相互强引用导致不手动调用`invalidate`方法`TureTarget`无法自动释放的问题。加入中间类`TimerStub`作为`Timer`的`SubTarget`，并且储存真实的`TrueTarget`与`SEL`，其中`TimerStub`弱引用真实的`TrueTarget`，保证其可以自由的释放。每当目标函数触发时去检查`TrueTarget`是否还存在，存在的话去执行目标函数，不存在的话调用`- [Timer invalidate]`去释放。

![time](http://ocm1152jt.bkt.clouddn.com/timer.png)

