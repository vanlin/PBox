@echo off
color A

call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

:: 编译 cmake-gui.cpp 文件
cl /c  /Zi /nologo /W3 /WX- /diagnostics:classic /O2 /Oy- /GL /D WIN32 /D STATIC_BUILD /D BOOKMARK_EDITION /D NDEBUG /D _CRT_SECURE_NO_WARNINGS /D _UNICODE /D UNICODE /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /analyze- /FC  %CurrentCD%cmake-gui.cpp

:: 连接得到 DLL 文件
link /dll /OUT:cmake-gui.dll ^
  /INCREMENTAL:NO ^
  /NOLOGO ^
  /MANIFEST ^
  /MANIFESTUAC:"level='asInvoker' uiAccess='false'" ^
  /manifest:embed ^
  /SUBSYSTEM:WINDOWS ^
  /TLBID:1 ^
  /DYNAMICBASE ^
  /NXCOMPAT ^
  /MACHINE:X64 ^
  /machine:x64 -stack:10000000 ^
  cmake-gui.obj ^
  x64\*.* ^
 dbghelp.lib winmm.lib advapi32.lib comdlg32.lib crypt32.lib d2d1.lib d3d11.lib dwmapi.lib dwrite.lib dxgi.lib dxguid.lib gdi32.lib glu32.lib imm32.lib iphlpapi.lib kernel32.lib mpr.lib ^
 netapi32.lib ole32.lib oleaut32.lib opengl32.lib psapi.lib rpcrt4.lib shell32.lib shlwapi.lib user32.lib  userenv.lib uuid.lib uxtheme.lib version.lib winmm.lib winspool.lib ws2_32.lib wtsapi32.lib

:: 复制文件到插件目录
copy /Y cmake-gui.dll ..\..\bin\Win64\plugins\cmake.dll

:: 删除临时文件
del cmake-gui.dll
del cmake-gui.exp
del cmake-gui.lib
del cmake-gui.obj
del vc140.pdb

pause
