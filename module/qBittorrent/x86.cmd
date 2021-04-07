@echo off
color A

call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

:: 编译 qBittorrent.cpp 文件
cl /c  /Zi /nologo /W3 /WX- /diagnostics:classic /O2 /Oy- /GL /D WIN32 /D STATIC_BUILD /D BOOKMARK_EDITION /D NDEBUG /D _CRT_SECURE_NO_WARNINGS /D _UNICODE /D UNICODE /Gm- /EHsc /MT /GS /arch:SSE2 /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /analyze- /FC  %CurrentCD%qBittorrent.cpp

:: 连接得到 DLL 文件
link /dll /OUT:qBittorrent.dll ^
  /INCREMENTAL:NO ^
  /NOLOGO ^
  /MANIFEST /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /manifest:embed ^
  /SUBSYSTEM:WINDOWS ^
  /OPT:REF ^
  /OPT:ICF ^
  /TLBID:1 ^
  /DYNAMICBASE ^
  /NXCOMPAT ^
  /MACHINE:X86 /SAFESEH /guard:cf  /machine:X86 ^
  qBittorrent.obj ^
  x86\*.* ^
  /SAFESEH  ^
 dbghelp.lib winmm.lib advapi32.lib comdlg32.lib crypt32.lib d2d1.lib d3d11.lib dwmapi.lib dwrite.lib dxgi.lib dxguid.lib gdi32.lib glu32.lib imm32.lib iphlpapi.lib kernel32.lib mpr.lib POWRPROF.LIB ^
 netapi32.lib ole32.lib oleaut32.lib opengl32.lib psapi.lib rpcrt4.lib shell32.lib shlwapi.lib user32.lib  userenv.lib uuid.lib uxtheme.lib version.lib winmm.lib winspool.lib ws2_32.lib wtsapi32.lib ^
 dnsapi.LIB imm32.lib BCRYPT.lib MSWSOCK.lib

:: 复制文件到插件目录
copy /Y qBittorrent.dll ..\..\bin\Win32\plugins\qBittorrent.dll

:: 删除临时文件
del qBittorrent.dll
del qBittorrent.exp
del qBittorrent.lib
del qBittorrent.obj
del vc140.pdb

pause
