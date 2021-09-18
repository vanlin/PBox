unit db.uCreateEXEForm;
{
  ���� EXE ����
}

interface

uses Winapi.Windows, Winapi.ShellAPI, System.Win.Registry, System.SysUtils, System.StrUtils, System.Classes, Vcl.Forms, Vcl.ComCtrls, db.uCommon;

{ ���� EXE �ļ� }
procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; ts: TTabSheet; OnPEProcessDestroyCallback: TNotifyEvent);

{ ���û��������������ǿ�ƹر� EXE ���� }
procedure FreeExeForm;

implementation

var
  FstrFileValue              : string;
  FstrEXEFormClassName       : string = '';
  FstrEXEFormTitleName       : string = '';
  FTabsheet                  : TTabSheet;
  FOnPEProcessDestroyCallback: TNotifyEvent;
  FExePID                    : Cardinal;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('YYYY-MM-DD hh:mm:ss', Now), strLog])));
end;

{ �û�����������˹رհ�ťʱ����ʱʱ��飬���̹رպ󣬱�����λ }
procedure EndExeForm(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FExePID = 0 then
    Exit;

  if CheckProcessExist(FExePID) then
    Exit;

  KillTimer(Application.MainForm.Handle, $2000);
  FExePID                  := 0;
  Application.MainForm.Tag := 0;
  FOnPEProcessDestroyCallback(nil);
end;

{ ���� EXE ���������Ƿ�ɹ����� }
procedure FindExeForm(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
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

  { ���ĵ�������������С����󻯣��������ı��ǲ�һ���� }
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
  DelayTime(200); // ��ʱ 500����
  GetWindowThreadProcessId(hEXEFormHandle, intPID);
  FExePID                  := intPID;
  Application.MainForm.Tag := intPID;

  FTabsheet.PageControl.ActivePage := FTabsheet;
  Winapi.Windows.SetParent(hEXEFormHandle, FTabsheet.Handle);                                                                                            // ���ø�����Ϊ TabSheet
  SetWindowPos(hEXEFormHandle, FTabsheet.Handle, 0, 0, FTabsheet.Width, FTabsheet.Height, SWP_NOZORDER OR SWP_NOACTIVATE);                               // ��� Dll �Ӵ���
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
  SetWindowLong(hEXEFormHandle, GWL_STYLE, Integer(WS_CAPTION OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR WS_SYSMENU));           // $96C80000);                                                                        // $96000000
  SetWindowLong(hEXEFormHandle, GWL_EXSTYLE, Integer(WS_EX_LEFT OR WS_EX_LTRREADING OR WS_EX_DLGMODALFRAME OR WS_EX_WINDOWEDGE OR WS_EX_CONTROLPARENT)); // $00010000);                                                                              // $00010101
  RemoveCaption(hEXEFormHandle);                                                                                                                         // ȥ��������
  ShowWindow(hEXEFormHandle, SW_SHOWNORMAL);                                                                                                             // ��ʾ����
  Application.MainForm.Height := Application.MainForm.Height + 1;
  Application.MainForm.Height := Application.MainForm.Height - 1;
  SetTimer(Application.MainForm.Handle, $2000, 200, @EndExeForm);
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

{ ��� Sysinternals ������ }
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

{ ���� EXE �ļ� }
procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; ts: TTabSheet; OnPEProcessDestroyCallback: TNotifyEvent);
begin
  if not FileExists(strEXEFileName) then
  begin
    MessageBox(0, '�ļ������ڣ������ļ�', c_strTitle, 64);
    Exit;
  end;

  FTabsheet                   := ts;
  FstrFileValue               := strFileValue;
  FOnPEProcessDestroyCallback := OnPEProcessDestroyCallback;
  FstrEXEFormClassName        := strFileValue.Split([';'])[2];
  FstrEXEFormTitleName        := strFileValue.Split([';'])[3];
  SetTimer(Application.MainForm.Handle, $1000, 200, @FindExeForm);

  { ɾ����������ļ��й��ڴ���λ�õ�������Ϣ }
  CheckPlugInConfigSize;

  { ��� Sysinternals ������ }
  CheckSysinternalsAllow(strEXEFileName);

  { ���� EXE ���̣������ش��� }
  ShellExecute(Application.MainForm.Handle, 'Open', PChar(strEXEFileName), nil, nil, SW_HIDE);
end;

{ ���û��������������ǿ�ƹر� EXE ���� }
procedure FreeExeForm;
var
  hProcess: Cardinal;
begin
  if FExePID = 0 then
    Exit;

  hProcess := OpenProcess(PROCESS_TERMINATE, False, FExePID);
  TerminateProcess(hProcess, 0);
  FExePID                  := 0;
  Application.MainForm.Tag := 0;
end;

end.
