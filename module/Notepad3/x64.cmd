@echo off
Color A

set CurrentCD=%~dp0

call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

:: 删除临时文件
del NP3.dll
del NP3.exp
del NP3.lib
del NP3.obj
del vc140.pdb

:: 更新版本
CD /D "%CurrentCD%GIT"
call Version.cmd"

:: 修改源码
git apply ..\NP3.patch 

:: 编译原有的 NOTEPAD3 源码
MSBuild %CurrentCD%GIT\Notepad3.sln /nologo /consoleloggerparameters:Verbosity=minimal /maxcpucount /nodeReuse:true^
  /target:Build /property:Configuration=Release;Platform=x64^
  /flp1:LogFile=zerror.log;errorsonly;Verbosity=diagnostic^
  /flp2:LogFile=zwarns.log;warningsonly;Verbosity=diagnostic

:: 编译 NP3.CPP
CD /D %CurrentCD%
cl /c  /Zi /nologo /W3 /WX- /diagnostics:classic /O2 /Oy- /GL /D WIN64 /D STATIC_BUILD /D BOOKMARK_EDITION /D NDEBUG /D _CRT_SECURE_NO_WARNINGS /D _UNICODE /D UNICODE /Gm- /EHsc /MT /GS /arch:SSE2 /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /analyze- /FC  %CurrentCD%NP3.cpp

:: 与原来编译 EXE 产生出的 OBJ/LIB/RES 一起，连接为动态库
link /dll -out:NP3.dll /DELAYLOAD:UXTHEME.dll -nologo -RELEASE -OPT:REF -OPT:ICF -LTCG NP3.obj %CurrentCD%GIT\Bin\Release_x64_v142\obj\Notepad3\*.obj ^
  %CurrentCD%GIT\Bin\Release_x64_v142\obj\Notepad3\notepad3.res ^
  %CurrentCD%GIT\Bin\Release_x64_v142\obj\Scintilla.lib ^
  %CurrentCD%GIT\Bin\Release_x64_v142\obj\LEXILLA.lib ^
  %CurrentCD%GIT\Bin\Release_x64_v142\obj\USER32-STUB.lib ^
  %CurrentCD%GIT\Bin\Release_x64_v142\obj\UXTHEME-STUB.lib ^
  ntdll.lib imm32.lib Shlwapi.lib Comctl32.lib MUILOAD.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib DELAYIMP.Lib

:: 复制到 PBox plugins 目录下
copy /Y NP3.dll ..\..\bin\WIN64\plugins\NP3.dll

:: 复制语言列表到  PBox plugins 目录下
xcopy /e /y /c /i "%CurrentCD%GIT\Bin\Release_x64_v142\lng\*.*"   "..\..\bin\WIN64\plugins\lng\" 

:: 还原源码
CD /D %CurrentCD%GIT
git clean -d  -fx -f 
git checkout .

:: 删除临时文件
del NP3.dll
del NP3.exp
del NP3.lib
del NP3.obj
del vc140.pdb
