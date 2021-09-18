unit db.uCreateDelphiDllForm;
{
  ���� Delphi DLL ����
}

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, Vcl.Forms, Vcl.Graphics, Vcl.ComCtrls, Vcl.Controls, Data.Win.ADODB, db.uCommon;

{ ���� DELPHI DLL ���� }
procedure PBoxRun_DelphiDll(const strPEFileName, strFileValue: String; tsDllForm: TTabSheet; OnDelphiDllFormClose: TCloseEvent);

{ ���û��������������ǿ�ƹر� DELPHI DLL ����ʱ }
procedure FreeDelphiDllForm;

implementation

var
  FhDelphiDllModule: HMODULE = 0;
  FhDelphiDllHandle: THandle;
  FstrFileValue    : String;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('YYYY-MM-DD hh:mm:ss', Now), strLog])));
end;

{ DLL �����ͷ���ϣ��ͷ���Դ��������λ }
function FreeAndRest: Boolean;
begin
  Result := False;
  if not IsWindowVisible(FhDelphiDllHandle) then
  begin
    KillTimer(Application.MainForm.Handle, $3000);
    FreeLibrary(FhDelphiDllModule);
    FhDelphiDllHandle := 0;
    FstrFileValue     := '';
    Result            := True;
  end;
end;

{ �û�����������˹رհ�ťʱ����ʱʱ��飬Delphi DLL �����Ƿ�ر��ˣ�����ر��ˣ�������λ }
procedure tmrCheckDelphiFormDllDestory(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  FreeAndRest;
end;

{ ���û��������������ǿ�ƹر� DELPHI DLL ����ʱ }
procedure FreeDelphiDllForm;
begin
  if FhDelphiDllHandle = 0 then
    Exit;

  { ���͹ر� Delphi DLL ������Ϣ }
  PostMessage(FhDelphiDllHandle, WM_SYSCOMMAND, SC_CLOSE, 0);

  { �ȴ�����ر� }
  while True do
  begin
    Application.ProcessMessages;
    if FreeAndRest then
      Break;
  end;
end;

{ �ҽ� ADOCNN }
procedure CheckDllFormDatabase(DllForm: TForm);
var
  I: Integer;
begin
  if not g_ADOCNN.Connected then
    Exit;

  for I := 0 to DllForm.ComponentCount - 1 do
  begin
    if DllForm.Components[I] is TADOQuery then
    begin
      TADOQuery(DllForm.Components[I]).Connection := g_ADOCNN;
    end;
  end;
end;

{ ���� DELPHI DLL ���� }
procedure PBoxRun_DelphiDll(const strPEFileName, strFileValue: String; tsDllForm: TTabSheet; OnDelphiDllFormClose: TCloseEvent);
var
  ShowDllForm       : Tdb_ShowDllForm_Plugins_Delphi;
  frm               : TFormClass;
  strParamModuleName: PAnsiChar;
  strModuleName     : PAnsiChar;
  frmDelphiDll      : TForm;
begin
  if not FileExists(strPEFileName) then
  begin
    MessageBox(0, '�ļ������ڣ������ļ�', c_strTitle, 64);
    Exit;
  end;

  if SameText(FstrFileValue, strFileValue) then
    Exit;

  FstrFileValue     := strFileValue;
  FhDelphiDllModule := LoadLibrary(PChar(strPEFileName));
  ShowDllForm       := GetProcAddress(FhDelphiDllModule, c_strDllExportFuncName);
  ShowDllForm(frm, strParamModuleName, strModuleName);
  frmDelphiDll             := frm.Create(nil);
  frmDelphiDll.BorderIcons := [biSystemMenu];
  frmDelphiDll.Position    := poDesigned;
  frmDelphiDll.BorderStyle := bsSingle;
  frmDelphiDll.Color       := clWhite;
  frmDelphiDll.Anchors     := [akLeft, akTop, akRight, akBottom];
  FhDelphiDllHandle        := frmDelphiDll.Handle;                                                                              // �����´�����
  frmDelphiDll.OnClose     := OnDelphiDllFormClose;                                                                             // Dll ��������ʱ���ص��������¼�����Ϊ OnClose �¼��� PBox �ӹܣ����� DLL �У���Դ�ͷ�Ӧ�ŵ� OnDestory �¼��У�
  CheckDllFormDatabase(frmDelphiDll);                                                                                           // ���ݿ���
  RemoveMenu(GetSystemMenu(frmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(frmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ����С�˵�
  RemoveMenu(GetSystemMenu(frmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ����С���˵�
  RemoveMenu(GetSystemMenu(frmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ����󻯲˵�
  RemoveMenu(GetSystemMenu(frmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ���ָ��߲˵�
  RemoveMenu(GetSystemMenu(frmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ���ƶ��˵�
  RemoveCaption(frmDelphiDll.Handle);                                                                                           // ȥ��������
  SetWindowPos(frmDelphiDll.Handle, tsDllForm.Handle, 0, 0, tsDllForm.Width, tsDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // ��� Dll �Ӵ���
  Winapi.Windows.SetParent(frmDelphiDll.Handle, tsDllForm.Handle);                                                              // ���ø�����Ϊ TabSheet
  frmDelphiDll.Show;                                                                                                            // ��ʾ Dll �Ӵ���
  tsDllForm.PageControl.ActivePage := tsDllForm;                                                                                // �����
  SetTimer(Application.MainForm.Handle, $3000, 100, @tmrCheckDelphiFormDllDestory);                                             // ��ʱ��� Delphi DLL �����Ƿ�������
end;

end.
