1、从CPU加电后执行的第一条指令开始，单步跟踪BIOS的执行

2、在初始化位置0x7c00设置实地址断点,测试断点正常

更改gdbinit文件为：

```text
file obj/bootblock.o 
target remote:1234 
set architecture i8086
b *0x7c00    或者是 b start
continue
```

在命令行输入指令：

```
make qemu
make debug
```

得到如下界面：

![](G:\code\OS\lab1\pic练习2\1.png)

使用next进行单步调试

2、 **BIOS****启动：****gdb****查看启动后第一条执行的指令并查看****BIOS****代码**

