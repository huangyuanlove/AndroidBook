Android系统的系统，从流程上来讲，来PC的启动没有多大的区别；差异之处在于流程之中的细节
PC的启动细节可以看这个：<br/>
计算机是如何启动的？从未上电到操作系统启动： https://zhuanlan.zhihu.com/p/166522447  <br/>
按下开机键后，电脑都干了些什么？： https://www.zhihu.com/question/22364502 <br/>

对于Android手机来说，简化版如下：
1. 当电源按下时引导芯片代码从预定义的地方(固化在 ROM)开始执行。加载引导程序BootLoader到RAM中，然后执行。
2. BootLoader主要完成硬件检查、初始化硬件参数等功能
3. 引导程序之后进入Android内核层，先启动swapper进程(idle进程)，该进程用来初始化进程管理、内存管理、加载Display、Camera Driver、Binder Driver等相关工作
4. swapper进程之后再启动kthreadd进程，该进程会创建内核工作线程kworker、软终端线程ksoftirqd、thernal等内核守护进程；kthreadd进程是所有**内核进程**的祖先
5. 在内核完成系统设置后，它首先在系统文件中寻找 init.rc文件，井启动 init进程。
6. init进程是所有**用户进程**的祖先，主要用来初始化和启动属性服务，它会孵化出ueventd、logd、healthd、installd、adbd、lmkd等用户守护进程，启动ServiceManager来管理系统服务，启动Bootnaim开机动画；也用来启动 Zygote 进程：init进程通过解析init.rc文件fork生成Zygote进程，该进程是Android系统的第一个Java进程，它是所有Java进程的父进程，该进程主要完成加载ZygotInit类，注册Zygote Socket服务套接字、加载虚拟机、预加载Class；预加载Resource。
7. init进程接着fork生成Media Service进程，该进程负责启动和管理整个C++ Fragmwork(包含AudiFlinger、Camera Service等服务)。
8. Zygote进程接着会fork生成System Server进程，该进程负责启动整个Java Framwork(包含ActivityManagerService、WindoManagerService等服务)。
9. Zygote进程孵化出的第一个**应用进程**是Launcher进程(桌面),它还会孵化出Browser进程、Phone进程等。我们每个创建的应用都是一个单独的进程。

