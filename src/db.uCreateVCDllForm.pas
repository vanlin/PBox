unit db.uCreateVCDllForm;
{
  ���� VC Dialog DLL / VC MFC DLL ����
}

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Forms, Vcl.ComCtrls, HookUtils, db.uCommon;

{ ���� VC DLL ���� }
procedure PBoxRun_VCDll(const strVCDllFileName, strFileValue: String; tsDll: TTabSheet; OnVCDllFormDestroyCallback: TNotifyEvent);

{ ���û��������������ǿ�ƹر� VC DLL ���� }
procedure FreeVCDllForm(const bExit: Boolean = False);

implementation

var
  FOld_CreateWindowExW       : function(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
  FstrVCDllClassName         : String = '';
  FstrVCDllWindowName        : String = '';
  FhVCDLLForm                : THandle;
  FTabDllForm                : TTabSheet;
  FOldWndProc                : Pointer = nil;
  FstrCreateDllFileName      : String  = '';
  FhVCDllModule              : HMODULE;
  FLangStyle                 : TLangStyle;
  FbExit                     : Boolean = False;
  FOnVCDllFormDestroyCallback: TNotifyEvent;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('YYYY-MM-DD hh:mm:ss', Now), strLog])));
end;

{ ��� Dll �У��� Dll �����ȡ���㣬�������ɷǼ���״̬ }
function NewDllFormProc(hWnd: THandle; msg: UINT; wParam: Cardinal; lParam: Cardinal): Integer; stdcall;
begin
  { ����Ӵ����ȡ����ʱ������������ }
  if msg = WM_ACTIVATE then
  begin
    if Application.MainForm <> nil then
    begin
      SendMessage(Application.MainForm.Handle, WM_NCACTIVATE, Integer(True), 0);
    end;
  end;

  { ��ֹ�����ƶ� }
  if msg = WM_SYSCOMMAND then
  begin
    if wParam = SC_MOVE + 2 then
    begin
      wParam := 0;
    end;
  end;

  { ����ԭ���Ļص����� }
  Result := CallWindowProc(FOldWndProc, hWnd, msg, wParam, lParam);
end;

{ ���� VC DLL ���� }
procedure CreateVCDllForm;
begin
  FTabDllForm.PageControl.ActivePage := FTabDllForm;                                                                          //
  Winapi.Windows.SetParent(FhVCDLLForm, FTabDllForm.Handle);                                                                  // ���ø�����Ϊ TabSheet
  RemoveMenu(GetSystemMenu(FhVCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveCaption(FhVCDLLForm);                                                                                                 // ȥ��������
  SetWindowPos(FhVCDLLForm, FTabDllForm.Handle, 0, 0, FTabDllForm.Width, FTabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // ��� DLL �Ӵ���
  FOldWndProc := Pointer(GetWindowlong(FhVCDLLForm, GWL_WNDPROC));                                                            // ��� DLL �����ȡ����ʱ�������嶪ʧ���������
  SetWindowLong(FhVCDLLForm, GWL_WNDPROC, LongInt(@NewDllFormProc));                                                          // ���� DLL ������Ϣ
  PostMessage(Application.MainForm.Handle, WM_NCACTIVATE, 1, 0);                                                              // ����������
  UnHook(@FOld_CreateWindowExW);                                                                                              // UNHOOK
  FOld_CreateWindowExW := nil;                                                                                                // UNHOOK
end;

function HookCreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { ��ָ���� VC ���� }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (SameText(lpClassName, FstrVCDllClassName)) and (SameText(lpWindowName, FstrVCDllWindowName)) then
  begin
    if (FLangStyle = lsVCDLGDll) or (FLangStyle = lsQTDll) then
    begin
      { ���� VC DLG DLL ���� }
      Result      := FOld_CreateWindowExW($00010101, lpClassName, lpWindowName, $96C80000, 0, 0, 0, 0, hWndParent, hMenu, hins, lpp); //
      FhVCDLLForm := Result;
      CreateVCDllForm;
    end
    else
    begin
      { ���� VC MFC DLL ���塣��Ϊ MFC ���������߳��д����ģ��������ﲻ�ܼ����κ� DELPHI �Ĵ��룬�谭 VC �̵߳�ִ�� }
      Result      := FOld_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle xor WS_MINIMIZEBOX xor WS_MAXIMIZEBOX, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
      FhVCDLLForm := Result;
    end;
  end
  else
  begin
    Result := FOld_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
  end;
end;

var
  FNewstrVCDllFileName          : String;
  FNewstrFileValue              : String;
  FNewtsDll                     : TTabSheet;
  FNewOnVCDllFormDestroyCallback: TNotifyEvent;

procedure FindVCDLGDLLFormEnd(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FhVCDllModule = 0 then
  begin
    KillTimer(Application.MainForm.Handle, $4000);
    PBoxRun_VCDll(FNewstrVCDllFileName, FNewstrFileValue, FNewtsDll, FNewOnVCDllFormDestroyCallback);
  end;
end;

{ ȫ�ֱ�����λ }
procedure FreeAndReset;
begin
  FreeLibrary(FhVCDllModule);
  FhVCDllModule         := 0;
  FhVCDLLForm           := 0;
  FstrVCDllClassName    := '';
  FstrVCDllWindowName   := '';
  FstrCreateDllFileName := '';
  FOnVCDllFormDestroyCallback(nil);

  { �Ƿ��˳����� }
  if FbExit then
  begin
    Application.MainForm.Close;
  end;
end;

{ ��ʱ�鿴��MFC DLL �����Ƿ񱻹ر� }
procedure FindMFCDllFormClose(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if not IsWindowVisible(FhVCDLLForm) then
  begin
    KillTimer(Application.MainForm.Handle, $2000);
    FreeAndReset;
  end;
end;

{ ���� EXE ���������Ƿ�ɹ����� }
procedure FindMFCDllFormCreate(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FhVCDLLForm = 0 then
    Exit;

  KillTimer(Application.MainForm.Handle, $1000);                            // ���ٶ�ʱ��
  CreateVCDllForm;                                                          // ���� VC DLL ����
  ShowWindow(FhVCDLLForm, SW_SHOW);                                         // ��ʾ MFC DLL ����
  SetTimer(Application.MainForm.Handle, $2000, 1000, @FindMFCDllFormClose); // ��ʱ�鿴��MFC DLL �����Ƿ񱻹ر�
end;

{ ���� VC DLL ���� }
procedure PBoxRun_VCDll(const strVCDllFileName, strFileValue: String; tsDll: TTabSheet; OnVCDllFormDestroyCallback: TNotifyEvent);
var
  hDll                             : HMODULE;
  ShowVCDllForm                    : Tdb_ShowDllForm_Plugins_VCForm;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
begin
  if not FileExists(strVCDllFileName) then
  begin
    MessageBox(0, '�ļ������ڣ������ļ�', c_strTitle, 64);
    Exit;
  end;

  { �ȴ���ǰ�� VC Dialog DLL Form ģ̬����������ɣ����ܽ����µ� DLL ���� }
  if FhVCDllModule <> 0 then
  begin
    FNewstrVCDllFileName           := strVCDllFileName;
    FNewstrFileValue               := strFileValue;
    FNewtsDll                      := tsDll;
    FNewOnVCDllFormDestroyCallback := OnVCDllFormDestroyCallback;
    SetTimer(Application.MainForm.Handle, $4000, 200, @FindVCDLGDLLFormEnd);
    Exit;
  end;

  if CompareText(FstrCreateDllFileName, strVCDllFileName) = 0 then
    Exit;

  FTabDllForm                 := tsDll;
  FstrCreateDllFileName       := strVCDllFileName;
  FbExit                      := False;
  FOnVCDllFormDestroyCallback := OnVCDllFormDestroyCallback;

  { ֻ��ȡ��������������ʾ���塣�� HOOK��HOOK ָ������ }
  hDll := LoadLibrary(PChar(strVCDllFileName));
  try
    ShowVCDllForm := GetProcAddress(hDll, c_strDllExportFuncName);
    ShowVCDllForm(FLangStyle, strParamModuleName, strModuleName, strClassName, strWindowName, False);
    FstrVCDllClassName  := String(strClassName);
    FstrVCDllWindowName := String(strWindowName);
    HookProcInModule(user32, 'CreateWindowExW', @HookCreateWindowExW, @FOld_CreateWindowExW);
  finally
    FreeLibrary(hDll);
  end;

  { ���� VC Dialog Dll ģ̬���壻�رռ��ͷ� }
  if (FLangStyle = lsVCDLGDll) or (FLangStyle = lsQTDll) then
  begin
    FhVCDllModule := LoadLibrary(PChar(strVCDllFileName));
    ShowVCDllForm := GetProcAddress(FhVCDllModule, c_strDllExportFuncName);
    ShowVCDllForm(FLangStyle, strParamModuleName, strModuleName, strClassName, strWindowName, True);

    { ȫ�ֱ�����λ }
    FreeAndReset;
  end
  else if FLangStyle = lsVCMFCDll then
  begin
    { ���� VC MFC Dll ��ģ̬���� }
    FhVCDLLForm   := 0;
    FhVCDllModule := LoadLibrary(PChar(strVCDllFileName));
    ShowVCDllForm := GetProcAddress(FhVCDllModule, c_strDllExportFuncName);
    ShowVCDllForm(FLangStyle, strParamModuleName, strModuleName, strClassName, strWindowName, True);
    SetTimer(Application.MainForm.Handle, $1000, 200, @FindMFCDllFormCreate);
  end;
end;

{ ���û��������������ǿ�ƹر� VC DLL ���� }
procedure FreeVCDllForm(const bExit: Boolean = False);
begin
  if FhVCDLLForm = 0 then
    Exit;

  FbExit := bExit;

  { ���͹رմ������� }
  PostMessage(FhVCDLLForm, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

end.
