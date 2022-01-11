#include <windows.h>

HINSTANCE hinst = NULL;

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
      case DLL_PROCESS_ATTACH:
        hinst = (HINSTANCE)hModule;
      case DLL_THREAD_ATTACH:
      case DLL_THREAD_DETACH:
      case DLL_PROCESS_DETACH:
          break;
    }
    return TRUE;
}

enum TLangStyle {lsDelphiDll, lsVCDLGDll, lsVCMFCDll, lsQTDll, lsEXE};

//extern int WINAPI wWinMain(HINSTANCE hInstance,HINSTANCE hPrevInst,LPSTR lpCmdLine,int nCmdShow);
extern int WINAPI wWinMain(_In_ HINSTANCE hInstance, _In_opt_ HINSTANCE hPrevInstance, _In_ LPWSTR lpCmdLine, _In_ int nShowCmd);

extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TLangStyle* lsFileType, char** strParentName, char** strSubModuleName, char** strClassName, char** strWindowName, const bool show = false)
{
    * lsFileType       = lsVCDLGDll;      // TLangStyle
    * strParentName    = "文本编辑";      // 父模块名称
    * strSubModuleName = "Notepad3(DLL)"; // 子模块名称
    * strClassName     = "Notepad3U";     // 窗体类名
    * strWindowName    = "Notepad3";      // 窗体名
    
    if (show) 
    {
      wWinMain(hinst, 0, (LPWSTR)"", (int)show);
    }
}

