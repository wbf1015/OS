### 实验指导书中一部分知识已经在必做题中应用到了，这里简单覆盖一下实验指导书中提及但是在必做题中应用不多的知识点：

一、操作系统启动时内存管理的流程

内存探测---》以固定页面大小分配物理内存空间----》设定每一个页的初始状态（free、used、reserved等）----》建立页表，启动分页机制（MMU建立TLB）-----》根据虚拟页和物理页帧的对应关系完成CPU对内存的读写等操作

二、对Page的理解：

计算机的每一个物理页的属性都用Page来表示，Page代表了每一个物理页

三、Page结构从内存的哪里开始？占多大空间？
