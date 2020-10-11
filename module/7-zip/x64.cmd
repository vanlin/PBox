@echo off
Color A

set CurrentCD=%~dp0

call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

:: 删除临时文件
del 7zFM.dll
del 7zFM.exp
del 7zFM.lib
del 7zFM.obj
del vc140.pdb
 
:: 编译原有的 7zip 源码
CD /D %CurrentCD%CPP\7zip
nmake

:: 编译 7zFM.CPP
CD /D %CurrentCD%
cl /c  /Zi /nologo /W3 /WX- /diagnostics:classic /O2 /Oy- /GL /D WIN32 /D STATIC_BUILD /D BOOKMARK_EDITION /D NDEBUG /D _CRT_SECURE_NO_WARNINGS /D _UNICODE /D UNICODE /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /analyze- /FC  %CurrentCD%7zFM.cpp

:: 与原来编译 EXE 产生出的 OBJ/LIB/RES 一起，连接为动态库
link /dll -out:7zFM.dll /DELAYLOAD:mpr.dll -nologo -RELEASE -OPT:REF -OPT:ICF -LTCG /LARGEADDRESSAWARE /FIXED:NO 7zFM.obj %CurrentCD%CPP\7zip\Bundles\FM\x64\*.obj %CurrentCD%CPP\7zip\Bundles\FM\x64\resource.res comctl32.lib htmlhelp.lib comdlg32.lib Mpr.lib Gdi32.lib delayimp.lib oleaut32.lib ole32.lib user32.lib advapi32.lib shell32.lib

:: 复制到 PBox plugins 目录下
copy /Y 7zFM.dll ..\..\bin\Win64\plugins\7-zip.dll

:: 删除临时文件
del 7zFM.dll
del 7zFM.exp
del 7zFM.lib
del 7zFM.obj
del vc140.pdb

pause
