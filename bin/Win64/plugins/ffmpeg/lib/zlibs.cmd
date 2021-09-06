@echo off

call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

cd ..
cd bin

lib /def:"..\lib\avcodec-59.def"   /machine:amd64 /out:"..\lib\avcodec-59.lib"
lib /def:"..\lib\avdevice-59.def"  /machine:amd64 /out:"..\lib\avdevice-59.lib"
lib /def:"..\lib\avformat-59.def"  /machine:amd64 /out:"..\lib\avformat-59.lib"
lib /def:"..\lib\avutil-57.def"    /machine:amd64 /out:"..\lib\avutil-57.lib"
lib /def:"..\lib\avfilter-8.def"   /machine:amd64 /out:"..\lib\avfilter-8.lib"
lib /def:"..\lib\postproc-56.def"  /machine:amd64 /out:"..\lib\postproc-56.lib"
lib /def:"..\lib\swresample-4.def" /machine:amd64 /out:"..\lib\swresample-4.lib"
lib /def:"..\lib\swscale-6.def "   /machine:amd64 /out:"..\lib\swscale-6.lib"
