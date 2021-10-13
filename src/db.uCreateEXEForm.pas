unit db.uCreateEXEForm;
{
  创建 EXE 窗体
}

interface

uses Winapi.Windows, Winapi.ShellAPI, System.Win.Registry, System.SysUtils, System.StrUtils, System.Classes, Vcl.Forms, Vcl.ComCtrls, db.uCommon;

{ 运行 EXE 文件 }
procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; ts: TTabSheet; OnPEProcessDestroyCallback: TNotifyEvent);

{ 非用户触发，程序调用强制关闭 EXE 窗体 }
procedure FreeExeForm;

function EnumNewMainForm(hWnd: THandle; lParam1: LPARAM): Boolean; stdcall;

implementation

var
  FstrFileValue              : string;
  FstrEXEFormClassName       : string = '';
  FstrEXEFormTitleName       : string = '';
  FTabsheet                  : TTabSheet;
  FOnPEProcessDestroyCallback: TNotifyEvent;
  FExePID                    : Cardinal;
  FhEXEFormHandle            : THandle;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('YYYY-MM-DD hh:mm:ss', Now), strLog])));
end;

{ 用户触发，点击了关闭按钮时，需时时检查，进程关闭后，变量复位 }
procedure EndExeForm(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FExePID = 0 then
    Exit;

  if CheckProcessExist(FExePID) then
    Exit;

  KillTimer(Application.MainForm.Handle, $2000);
  KillTimer(Application.MainForm.Handle, $3000);
  FExePID                  := 0;
  Application.MainForm.Tag := 0;
  FOnPEProcessDestroyCallback(nil);
end;

{ 将 EXE 主窗体放置到 Tab Dll 窗口中 }
procedure SetParentForm(const hWnd: THandle);
var
  intST, intET: Cardinal;
  bOK         : Boolean;
begin
  FTabsheet.PageControl.ActivePage := FTabsheet;

  { 设置父窗体为 TabSheet }
  bOK := True;
  if Winapi.Windows.SetParent(hWnd, FTabsheet.Handle) = 0 then
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 10 * 1000 then
        Break;

      if Winapi.Windows.SetParent(hWnd, FTabsheet.Handle) <> 0 then
      begin
        bOK := True;
        Break;
      end;
    end;
  end;

  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, 0);
    Exit;
  end;

  { 最大化 Dll 子窗体 }
  bOK := True;
  if not SetWindowPos(hWnd, FTabsheet.Handle, 0, 0, FTabsheet.width, FTabsheet.Height, SWP_NOZORDER OR SWP_NOACTIVATE) then
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 10 * 1000 then
        Break;

      if SetWindowPos(hWnd, FTabsheet.Handle, 0, 0, FTabsheet.width, FTabsheet.Height, SWP_NOZORDER OR SWP_NOACTIVATE) then
      begin
        bOK := True;
        Break;
      end;
    end;
  end;
  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, 0);
    Exit;
  end;

  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单

  { 设置窗体风格 }
  bOK := True;
  if SetWindowLong(hWnd, GWL_STYLE, Integer(WS_CAPTION OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR WS_SYSMENU)) = 0 then
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 3000 then
        Break;

      if SetWindowLong(hWnd, GWL_STYLE, Integer(WS_CAPTION OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR WS_SYSMENU)) <> 0 then
      begin
        bOK := True;
        Break;
      end;
    end;
  end;
  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, 0);
    Exit;
  end;

  { 设置窗体扩展风格 }
  bOK := True;
  if SetWindowLong(hWnd, GWL_EXSTYLE, Integer(WS_EX_LEFT OR WS_EX_LTRREADING OR WS_EX_DLGMODALFRAME OR WS_EX_WINDOWEDGE OR WS_EX_CONTROLPARENT)) = 0 then // $00010000);                                                                              // $00010101
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 3000 then
        Break;

      if SetWindowLong(hWnd, GWL_EXSTYLE, Integer(WS_EX_LEFT OR WS_EX_LTRREADING OR WS_EX_DLGMODALFRAME OR WS_EX_WINDOWEDGE OR WS_EX_CONTROLPARENT)) <> 0 then // $00010000);                                                                              // $00010101
      begin
        bOK := True;
        Break;
      end;
    end;
  end;
  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, 0);
    Exit;
  end;

  { 去除标题栏 }
  RemoveCaption(hWnd);

  { 显示窗体 }
  bOK := True;
  if not ShowWindow(hWnd, SW_SHOWNORMAL) then
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 3000 then
        Break;

      if ShowWindow(hWnd, SW_SHOWNORMAL) then
      begin
        bOK := True;
        Break;
      end;
    end;
  end;
  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, 0);
    Exit;
  end;

  Application.MainForm.Height := Application.MainForm.Height + 1;
  Application.MainForm.Height := Application.MainForm.Height - 1;
end;

function EnumNewMainForm(hWnd: THandle; lParam1: LPARAM): Boolean; stdcall;
var
  intPID: DWORD;
  rct   : TRect;
begin
  GetWindowThreadProcessId(hWnd, intPID);
  if (FExePID = intPID) and (GetParent(hWnd) = 0) then
  begin
    GetWindowRect(hWnd, rct);
    if (rct.width > 100) and (rct.Height > 100) then
    begin
      KillTimer(Application.MainForm.Handle, $3000);
      SetParentForm(hWnd);
    end;
  end;
  Result := True;
end;

procedure FindOtherNewForm(hWnd: THandle; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if not IsWindowVisible(FhEXEFormHandle) then
  begin
    EnumWindows(@EnumNewMainForm, 0);
  end;
end;

{ 查找 EXE 的主窗体是否成功创建 }
procedure FindExeForm(hWnd: THandle; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
var
  hEXEFormHandle: THandle;
  intPID        : DWORD;
  strTitleName  : String;
  intIndex      : Integer;
begin
  if (Trim(FstrEXEFormClassName) = '') and (Trim(FstrEXEFormTitleName) <> '') then
    hEXEFormHandle := FindWindow(nil, PChar(FstrEXEFormTitleName))
  else if (Trim(FstrEXEFormClassName) <> '') and (Trim(FstrEXEFormTitleName) = '') then
    hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), nil)
  else
    hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), PChar(FstrEXEFormTitleName));

  { 多文档，窗体正常大小和最大化，标题栏文本是不一样的 }
  if hEXEFormHandle = 0 then
  begin
    intIndex := Pos('windows', LowerCase(FstrEXEFormTitleName));
    if intIndex > 0 then
    begin
      strTitleName := Leftstr(FstrEXEFormTitleName, intIndex - 1) + '[' + 'Windows' + RightStr(FstrEXEFormTitleName, Length(FstrEXEFormTitleName) - intIndex - 6) + ']';
      if Trim(FstrEXEFormClassName) = '' then
        hEXEFormHandle := FindWindow(nil, PChar(strTitleName))
      else
        hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), PChar(strTitleName));
    end;
  end;

  if hEXEFormHandle = 0 then
  begin
    intIndex := Pos('[windows', LowerCase(FstrEXEFormTitleName));
    if intIndex > 0 then
    begin
      strTitleName := Leftstr(FstrEXEFormTitleName, intIndex - 1) + 'Windows ' + MidStr(FstrEXEFormTitleName, intIndex + 9, 1);
      if Trim(FstrEXEFormClassName) = '' then
        hEXEFormHandle := FindWindow(nil, PChar(strTitleName))
      else
        hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), PChar(strTitleName));
    end;
  end;

  if hEXEFormHandle = 0 then
    Exit;

  KillTimer(Application.MainForm.Handle, $1000);
  DelayTime(200);
  GetWindowThreadProcessId(hEXEFormHandle, intPID);
  FExePID                  := intPID;
  Application.MainForm.Tag := intPID;
  FhEXEFormHandle          := hEXEFormHandle;

  SetParentForm(hEXEFormHandle);
  SetTimer(Application.MainForm.Handle, $2000, 200, @EndExeForm);
  SetTimer(Application.MainForm.Handle, $3000, 200, @FindOtherNewForm);
end;

procedure CheckSysinternalsREG(const strProgramName: String);
begin
  with TRegistry.Create do
  begin
    RootKey := HKEY_CURRENT_USER;
    if not OpenKey('Software\Sysinternals\' + strProgramName, False) then
    begin
      OpenKey('Software\Sysinternals\' + strProgramName, True);
      WriteInteger('EulaAccepted', 1);
    end;
    Free;
  end;
end;

{ 检查 Sysinternals 软件许可 }
procedure CheckSysinternalsAllow(const strEXEFileName: String);
const
  c_strSysinternalsSoft: array [0 .. 6] of string = ('AutoRuns.exe', 'AutoRuns64.exe', 'DbgView.exe', 'procexp.exe', 'procexp64.exe', 'Procmon.exe', 'Procmon64.exe');
var
  strFileName: String;
begin
  strFileName := ExtractFileName(strEXEFileName);
  if (SameText(strFileName, c_strSysinternalsSoft[0])) or (SameText(strFileName, c_strSysinternalsSoft[1])) then
    CheckSysinternalsREG('AutoRuns')
  else if SameText(strFileName, c_strSysinternalsSoft[2]) then
    CheckSysinternalsREG('DbgView')
  else if (SameText(strFileName, c_strSysinternalsSoft[3])) or (SameText(strFileName, c_strSysinternalsSoft[4])) then
    CheckSysinternalsREG('Process Explorer')
  else if (SameText(strFileName, c_strSysinternalsSoft[5])) or (SameText(strFileName, c_strSysinternalsSoft[6])) then
    CheckSysinternalsREG('Process Monitor');
end;

{ 运行 EXE 文件 }
procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; ts: TTabSheet; OnPEProcessDestroyCallback: TNotifyEvent);
var
  strFullFileName: String;
begin
  if not FileExists(strEXEFileName) then
  begin
    if not CheckFileExistsFromSysSearchPath(strEXEFileName, strFullFileName) then
    begin
      MessageBox(0, '文件不存在，请检查文件', c_strTitle, 64);
      Exit;
    end;
  end;

  FTabsheet                   := ts;
  FstrFileValue               := strFileValue;
  FOnPEProcessDestroyCallback := OnPEProcessDestroyCallback;
  FstrEXEFormClassName        := strFileValue.Split([';'])[2];
  FstrEXEFormTitleName        := strFileValue.Split([';'])[3];
  SetTimer(Application.MainForm.Handle, $1000, 200, @FindExeForm);

  { 删除插件配置文件中关于窗体位置的配置信息 }
  CheckPlugInConfigSize;

  { 检查 Sysinternals 软件许可 }
  CheckSysinternalsAllow(strEXEFileName);

  { 创建 EXE 进程，并隐藏窗体 }
  ShellExecute(Application.MainForm.Handle, 'Open', PChar(strEXEFileName), nil, nil, SW_HIDE);
end;

{ 非用户触发，程序调用强制关闭 EXE 窗体 }
procedure FreeExeForm;
var
  hProcess: Cardinal;
begin
  if FExePID = 0 then
    Exit;

  KillTimer(Application.MainForm.Handle, $3000);
  hProcess := OpenProcess(PROCESS_TERMINATE, False, FExePID);
  TerminateProcess(hProcess, 0);
  FExePID                  := 0;
  Application.MainForm.Tag := 0;
end;

end.
