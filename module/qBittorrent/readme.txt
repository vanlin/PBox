1、正常编译 qBittorrent，得到 LIB 文件、RES 文件、OBJ文件；
2、新建 Dll 导出函数 CPP 文件 qBittorrent.cpp，因为 QT 的入口点函数是 main，所以和 VC Dialog Dll 一样，直接调用 main 就可以了。
