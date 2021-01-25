init 的主要操作是加载它的配置文件,并执行配置文件中的相关指令.传统上使用的配置文件有两个,主配置文件/init.rc 和与设备相关的配置文件/init.*hardwate*.rc ,这里的hardwate是从内核参数androidboot.hardwate或是从/proc/cpuinfo伪文件那里获取的字符串.
.rc文件是由triggger语句块和servicie语句块构成的.trigger语句块中的命令会在触发条件被满足时执;而service语句块中定义的是各个守护进程,init会根据命令启动相关守护进程,也可以根据相关参数修改服务的状态;
但是Android中的init和传统Linux中的init相似之处也就在名字上了。具体区别可以参考《最强Android书 架构大剖析》中的第4章。
![Android的init与传统UNIX的sbin->init的对比](/image/Android的init与传统UNIX的sbin->init的对比.png)
因为 init 是系统中所有进程的祖先，所以只有它才天生适合实现系统属性的初始化。具体代码是在system/core/init/init.cpp 文件中。总的来讲，作为大多数守护进程的样板，init代码的指令流程完全遵循建立服务的经典模式:初始化，然后陷入一个循环中，而且永远不想从中退出来。
##### 初始化流程
检查自身这个二进制司执行文件是不是被当成 ueventd 或者 CKitKat 及之后版本中的) watchdogd 调用的。如果是的话，余下的执行流程就会转到相应的守护进程的主循环那里去。
* 创建/dev、/proc和/sys等目录，并且mount它们。
* 添加文件/dev/.booting (通过打开这个文件，然后再关闭它的方式)，在启动完毕之后，这个文件会被(check_startup)清空。
* 调用open_devnull_stdio()函数完成"守护进程化"操作(把/stdin/stdout/stderr 链接到/dev/null上去) 。
* 调用klog_init()函数创建/dev/__kmsg__，然后立即删除它。
* 调用property_init()函数，在内存中创建__system_property_area区域。
* 调用get_hardware_name()函数，读取/proc/cpuinfo伪文件中的内容，并提取出"Hardware"一行的内容作为硬件名(hardware name)。
* 调用process_kernel_cmdline()函数，读取/proc/cmdline伪文件中的内容，并把所有androidboot.XXX 的属性都复制一份出来，变成ro.boot.XXX。
* 在JellyBean及以后的版本中，这里要初始化SELinux。 在JellyBean版本中，如果没有用#ifdef定义HAVE SELINUX还不会启用SELinux，而到了KitKat版，SELinux就是默认启用的了。 SELinux的context 是放在/dev和/sys里的。
* 接着还要专门检查一下设备是否处于"充电模式"(根据一个名为"androidboot"的内核参数进行判断)。如果设备处于“充电模式”的话，会使init跳过大部分初始化阶段，井且只加载各个服务中的“ charger”类(当前也只有“ charger”守护进程有这个类) 。如果设备并没有处于“充电模式”， 那么init将会去加载/default.prop， 正常执行启动过程。
* 调用init_parse_config_file()函数去解析/init.rc脚本文件。
* init会把init.rc 文件中各个 on 语句块里规定的 action (用 action_for_each_trigger()函数)以及内置的 action (用 queue_builtin action()函数)添加到一个名为 action_queue 的队列里去
 
##### 主循环(run-loop)
* execute_ ne一command()一一从队3iiJ action_queue 的旦、剖l取l且一个 action (如果有的i古), 并执行之。
* restart_processes()一一逐个检查所有已经注册过的服务，井在必要时重启之 。
* 安装并轮询(监视)如下三个 socket描述衍。
    * property_set_fd
    * keychord_fd
    * signal_recv_fd

