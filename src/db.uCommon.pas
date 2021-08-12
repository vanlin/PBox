unit db.uCommon;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, Winapi.IpRtrMib, Winapi.TlHelp32, Winapi.ShlObj, Winapi.IpTypes, Winapi.ActiveX, Winapi.IpHlpApi, Winapi.ImageHlp,
  System.IOUtils, System.Types, System.Math, System.SysUtils, System.StrUtils, System.Classes, System.IniFiles, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Data.Win.ADODB, Data.db,
  IdIPWatch, FlyUtils.CnXXX.Common, FlyUtils.AES, db.uNetworkManager, db.ImageListEx;

type
  { ������ʾ��ʽ���˵�����ť���б� }
  TShowStyle = (ssMenu, ssButton, ssList, ssTree);

  { ������ʾģʽ�����ĵ������ĵ� }
  TViewStyle = (dsSingle, dsMulti);

  { DLL ���ͣ�Delphi Dll��VC Dialog Dll��VC MFC Dll��QT Dll��EXE }
  TLangStyle = (lsDelphiDll, lsVCDLGDll, lsVCMFCDll, lsQTDll, lsEXE);

  { DLL ������������ }
  Tdb_ShowDllForm_Plugins_Delphi = procedure(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;                                                                           // Delphi
  Tdb_ShowDllForm_Plugins_VCForm = procedure(var vct: TLangStyle; var strParentModuleName, strModuleName: PAnsiChar; var strClassName, strWindowName: PAnsiChar; const bShow: Boolean = False); stdcall; // VC
  Tdb_ShowDllForm_Plugins_QTForm = procedure(var vct: TLangStyle; var strParentModuleName, strModuleName: PAnsiChar; var strClassName, strWindowName: PAnsiChar; const bShow: Boolean = False); stdcall; // QT

  CREATE_USN_JOURNAL_DATA = record
    MaximumSize: UInt64;
    AllocationDelta: UInt64;
  end;

  USN_JOURNAL_DATA = record
    UsnJournalID: UInt64;
    FirstUsn: Int64;
    NextUsn: Int64;
    LowestValidUsn: Int64;
    MaxUsn: Int64;
    MaximumSize: UInt64;
    AllocationDelta: UInt64;
  end;

  MFT_ENUM_DATA = record
    StartFileReferenceNumber: UInt64;
    LowUsn: Int64;
    HighUsn: Int64;
  end;

  PUSN = ^USN;

  USN = record
    RecordLength: Cardinal;
    MajorVersion: Word;
    MinorVersion: Word;
    FileReferenceNumber: Int64Rec;
    ParentFileReferenceNumber: Int64Rec;
    USN: Int64;
    TimeStamp: LARGE_INTEGER;
    Reason: Cardinal;
    SourceInfo: Cardinal;
    SecurityId: Cardinal;
    FileAttributes: Cardinal;
    FileNameLength: Word;
    FileNameOffset: Word;
    FileName: PWideChar;
  end;

  DELETE_USN_JOURNAL_DATA = record
    UsnJournalID: UInt64;
    DeleteFlags: Cardinal;
  end;

const
  c_strTitle                   = 'PBox ���� Dll ���ڵ�ģ�黯����ƽ̨ v4.0';
  c_strMsgTitle: PChar         = 'ϵͳ��ʾ��';
  c_intButtonWidth             = 30;
  c_strDllExportFuncName       = 'db_ShowDllForm_Plugins';
  c_strIniDBSection            = 'DB';
  c_strIniUISection            = 'UI';
  c_strIniModuleSection        = 'Module';
  c_strAESKey                  = 'dbyoung@sina.com';
  c_intBetweenVerticalDistance = 5;
  c_intDelayTime               = 200;
  c_strResultTableName         = 'NTFS2';
  c_strSearchTempTableName     = 'TempSearchTable';
  BUF_LEN                      = 500 * 1024;
  USN_DELETE_FLAG_DELETE       = $00000001;
  c_UInt64Root                 = 1407374883553285;
  WM_SEARCHDRIVEFILEFINISHED   = WM_USER + $1000;
  WM_GETFILEFULLNAMEFINISHED   = WM_USER + $1001;
  WM_EXECSQL                   = WM_USER + $1002;
  WM_EXECSQLSUCCESS            = WM_USER + $1003;

  { ȫ�ֱ��� }
var
  g_ADOCNN: TADOConnection = nil;

function GetTitleText: String;

{ ֻ��������һ��ʵ�� }
procedure OnlyRunOneInstance;

{ ������ݿ����� }
procedure CheckDataBaseLink;

{ ���ݴ�������ȡ����ʵ�� }
function GetInstanceFromhWnd(const hWnd: Cardinal): TWinControl;

{ ��ȡ Delphi ����� TApplication }
function GetMainFormApplication: TApplication;

{ ��ȡ PBox �������� <�� Dll ����> }
function GetMainFormHandle: hWnd;

{ �������ݿ����� }
function TryLinkDataBase(const strLinkDB: string; var ADOCNN: TADOConnection): Boolean;

{ �������ݿ⣬֧��Զ�̱��� }
function BackupDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strSaveFileName: String): Boolean;

{ �ָ����ݿ⣬֧��Զ�ָ̻� }
function RestoreDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strDBFileName: String; var strErr: String): Boolean;

{ ִ�� Sql �ű���ִ�гɹ����Ƿ�ɾ���ļ� }
function ExeSql(const strFileName: string; ADOCNN: TADOConnection; const bDeleteFileOnSuccess: Boolean = False): Boolean;

{ ��ȡ���ݿ���� }
function GetDBLibraryName(const strLinkDB: string): String;

{ ��ȡ������������� }
function GetNativePCName: string;

{ ��ȡ������ǰ��¼�û����� }
function GetCurrentLoginUserName: String;

{ �� Dll �л�ȡ���������б� }
function GetPEExport(const strDllFieName: String; var lstFunc: TStringList): Boolean;

{ ����ģ�� }
procedure SortModuleList(var lstModuleList: THashedStringList);

function GetSystemPath: String;

{ �� .msc �ļ��л�ȡͼ�� }
procedure LoadIconFromMSCFile(const strMSCFileName: string; var IcoMSC: TIcon);

procedure GetWebSpeed(var strDnSpeed, strUpSpeed: string);

function GetCurrentAdapterIP: String;

{ ��ȡ���������б���Ϣ }
function GetAdapterInfo(var lst: TList): Boolean;

{ ����Ȩ�� }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;

{ �����ַ��� }
function EncryptString(const strTemp, strKey: string): String;

{ �����ַ��� }
function DecryptString(const strTemp, strKey: string): String;

{ ���ݿ�������� }
function EncDatabasePassword(const strPassword: string): String;

{ �������ݿ�---ִ�нű� }
function UpdateDataBaseScript(const iniFile: TIniFile; const ADOCNN: TADOConnection; const bDeleteFile: Boolean = False): Boolean;

{ ɨ�� Dll �ļ�����ȡ Plugins Ŀ¼ }
procedure LoadAllPlugins_Dll(var lstDll: THashedStringList; var ilMainMenu: TImageList);

{ ɨ�� EXE �ļ�����ȡ�����ļ� }
procedure LoadAllPlugins_EXE(var lstDll: THashedStringList; var ilMainMenu: TImageList);

{ ������ʾ��ʽ }
function GetShowStyle: Integer;

{ ��ȡ�ؼ��߶� }
function GetLabelHeight(const strFontName: string; const intFontSize: Integer): Integer;

{ ��ʱ���� }
procedure DelayTime(const intTime: Cardinal);

{ �����Ƿ�ر� }
function CheckProcessExist(const intPID: DWORD): Boolean;

{ ɾ����������ļ��й��ڴ���λ�õ�������Ϣ }
procedure CheckPlugInConfigSize;

function ShowFileProperties(FileName: String; Wnd: hWnd): Boolean;

function OpenFolderAndSelectFile(const strFileName: string; const bEditMode: Boolean = False): Boolean;

{ ȡ�õ�ǰ���̵��߳��� }
function GetProcessThreadCount: Integer;

{ ȥ�������� }
procedure RemoveCaption(hWnd: THandle);

{ ��ȡ DLL ģ���ļ���������·�� }
function GetDllFullFileName: String;

{ ��ȡ DLL ����·�� }
function GetDllFilePath: String;

{ ��ȡ��������ȫ�� C++ ���ͺ��� }
function GetFullFuncNameCpp(const strFuncName: string): String;

{ ���ټ��������ļ����� }
function GetLoadSpeedFileName_Config: String;

{ ���ټ���ͼ���ļ����� }
function GetLoadSpeedFileName_Icolst: String;

{ �Ƿ����˼��ټ�����ģ�� }
function CheckLoadSpeed: Boolean;

{ ���ټ���ʱ��ÿ���˵����ͼ�� }
procedure LoadAllMenuIconSpeed(const ilMainMenu: TImageList);

{ �����ַ��������̶����� }
function AlignStringWidth(const strValue: string; const Font: TFont; const intMaxLen: Integer = 200): String;

implementation

{ ֻ��������һ��ʵ�� }
procedure OnlyRunOneInstance;
var
  hMainForm       : THandle;
  strTitle        : String;
  bOnlyOneInstance: Boolean;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    strTitle         := ReadString(c_strIniUISection, 'Title', c_strTitle);
    bOnlyOneInstance := ReadBool(c_strIniUISection, 'OnlyOneInstance', False);
    Free;
  end;

  if not bOnlyOneInstance then
    Exit;

  hMainForm := FindWindow('TfrmPBox', PChar(strTitle));
  if hMainForm <> 0 then
  begin
    MessageBox(0, '�����Ѿ����У������ظ�����', 'ϵͳ��ʾ��', MB_OK OR MB_ICONERROR);
    if IsIconic(hMainForm) then
      PostMessage(hMainForm, WM_SYSCOMMAND, SC_RESTORE, 0);
    BringWindowToTop(hMainForm);
    SetForegroundWindow(hMainForm);
    Halt;
    Exit;
  end;
end;

{ ������ݿ����� }
procedure CheckDataBaseLink;
begin

end;

{ ���ݴ�������ȡ����ʵ�� }
function GetInstanceFromhWnd(const hWnd: Cardinal): TWinControl;
type
  PObjectInstance = ^TObjectInstance;

  TObjectInstance = packed record
    Code: Byte;            { ����ת $E8 }
    Offset: Integer;       { CalcJmpOffset(Instance, @Block^.Code); }
    Next: PObjectInstance; { MainWndProc ��ַ }
    Self: Pointer;         { �ؼ������ַ }
  end;
var
  wc: PObjectInstance;
begin
  Result := nil;
  wc     := Pointer(GetWindowLong(hWnd, GWL_WNDPROC));
  if wc <> nil then
  begin
    Result := wc.Self;
  end;
end;

function _EnumApplicationProc(P_HWND: Cardinal; LParam: Cardinal): Boolean; stdcall;
var
  PID         : DWORD;
  chrClassName: array [0 .. 255] of Char;
  strClassName: String;
begin
  Result := True;

  GetWindowThreadProcessId(P_HWND, @PID);
  if PCardinal(LParam)^ <> PID then
  begin
    Result := True;
  end
  else
  begin
    GetClassName(P_HWND, chrClassName, 256);
    strClassName := chrClassName;
    if SameText(strClassName, 'TApplication') then
    begin
      Result                 := False;
      PCardinal(LParam + 4)^ := P_HWND;
    end;
  end;
end;

{ ��ȡ Delphi ����� TApplication }
function GetMainFormApplication: TApplication;
var
  Buffer   : array [0 .. 1] of Cardinal;
  appHandle: THandle;
begin
  Result    := nil;
  Buffer[0] := GetCurrentProcessId;
  Buffer[1] := 0;
  EnumWindows(@_EnumApplicationProc, Integer(@Buffer));
  if Buffer[1] > 0 then
  begin
    appHandle := Buffer[1];
    Result    := TApplication(GetInstanceFromhWnd(appHandle));
  end;
end;

function _EnumWindowsProc(P_HWND: Cardinal; LParam: Cardinal): Boolean; stdcall;
var
  PID         : DWORD;
  chrClassName: array [0 .. 255] of Char;
  strClassName: String;
begin
  Result := True;

  GetWindowThreadProcessId(P_HWND, @PID);
  if PCardinal(LParam)^ <> PID then
  begin
    Result := True;
  end
  else
  begin
    GetClassName(P_HWND, chrClassName, 256);
    strClassName := chrClassName;
    if                                                                  //
      (CompareText(strClassName, 'TApplication') <> 0) and              //
      (CompareText(strClassName, 'TPUtilWindow') <> 0) and              //
      (CompareText(strClassName, 'IME') <> 0) and                       //
      (CompareText(strClassName, 'MSCTFIME UI') <> 0) and               //
      (CompareText(strClassName, 'tooltips_class32') <> 0) and          //
      (CompareText(strClassName, 'ADODB.AsyncEventMessenger') <> 0) and //
      (CompareText(strClassName, 'TfrmSQL') <> 0)                       //
    then
    begin
      Result                 := False;
      PCardinal(LParam + 4)^ := P_HWND;
    end;
  end;
end;

{ ��ȡ PBox �������� <�� Dll ����> }
function GetMainFormHandle: hWnd;
var
  Buffer: array [0 .. 1] of Cardinal;
begin
  Result    := 0;
  Buffer[0] := GetCurrentProcessId;
  Buffer[1] := 0;
  EnumWindows(@_EnumWindowsProc, Integer(@Buffer));
  if Buffer[1] > 0 then
    Result := Buffer[1];
end;

function GetTitleText: String;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    Result := ReadString(c_strIniUISection, 'Title', c_strTitle);
    Free;
  end;
end;

procedure FindTableFilePos(const sts: array of TImageSectionHeader; const intVA: Cardinal; var intRA: Cardinal);
var
  III, Count: Integer;
begin
  intRA := 0;

  Count   := Length(sts);
  for III := 0 to Count - 2 do
  begin
    if (intVA >= sts[III + 0].VirtualAddress) and (intVA < sts[III + 1].VirtualAddress) then
    begin
      intRA := (intVA - sts[III].VirtualAddress) + sts[III].PointerToRawData;
      Break;
    end;
  end;
end;

{ �Ƿ����ָ���������� }
function CheckDllExportFunc(const strDllFileName, strDllExportFuncName: string): Boolean;
var
  fHandle    : Integer;
  peHead     : TImageDosHeader;
  intOffset  : Integer;
  peNTHead32 : TImageNtHeaders32;
  peNTHead64 : TImageNtHeaders64;
  sts        : TArray<TImageSectionHeader>;
  intVA      : Cardinal;
  intRA      : Cardinal;
  I, Count   : Integer;
  intLen     : Integer;
  eft        : TImageExportDirectory;
  intFuncRA  : Cardinal;
  chrFuncName: array [0 .. 255] of AnsiChar;
  strFuncName: String;
begin
  Result  := False;
  fHandle := FileOpen(strDllFileName, fmShareDenyNone or fmOpenRead);
  if fHandle <= 0 then
    Exit;

  try
    FileRead(fHandle, peHead, SizeOf(TImageDosHeader));
    if peHead.e_magic <> IMAGE_DOS_SIGNATURE then
      Exit;

    intOffset := peHead._lfanew;
    FileSeek(fHandle, intOffset, 0);
    FileRead(fHandle, peNTHead32, SizeOf(TImageNtHeaders));
    if peNTHead32.Signature <> IMAGE_NT_SIGNATURE then
      Exit;

    { ��ȡ���������� }
    if peNTHead32.FileHeader.Machine = IMAGE_FILE_MACHINE_AMD64 then
    begin
      { X64 Dll }
      FileSeek(fHandle, 0, 0);
      FileRead(fHandle, peHead, SizeOf(TImageDosHeader));
      intOffset := peHead._lfanew;
      FileSeek(fHandle, intOffset, 0);
      FileRead(fHandle, peNTHead64, SizeOf(TImageNtHeaders64));
      if peNTHead64.Signature <> IMAGE_NT_SIGNATURE then
        Exit;

      Count := peNTHead64.FileHeader.NumberOfSections;
      SetLength(sts, Count);
      intLen := Count * SizeOf(TImageSectionHeader);
      FileSeek(fHandle, intOffset + SizeOf(TImageNtHeaders64), 0);
      FileRead(fHandle, sts[0], intLen);
      intVA := peNTHead64.OptionalHeader.DataDirectory[0].VirtualAddress;
      if intVA = 0 then
        Exit;
    end
    else
    begin
      { X86 Dll }
      Count := peNTHead32.FileHeader.NumberOfSections;
      SetLength(sts, Count);
      intLen := Count * SizeOf(TImageSectionHeader);
      FileSeek(fHandle, intOffset + SizeOf(TImageNtHeaders32), 0);
      FileRead(fHandle, sts[0], intLen);
      intVA := peNTHead32.OptionalHeader.DataDirectory[0].VirtualAddress;
      if intVA = 0 then
        Exit;
    end;

    FindTableFilePos(sts, intVA, intRA);
    FileSeek(fHandle, intRA, 0);
    FileRead(fHandle, eft, SizeOf(TImageExportDirectory));
    if eft.NumberOfNames = 0 then
      Exit;

    { �������� }
    for I := 0 to eft.NumberOfNames - 1 do
    begin
      FileSeek(fHandle, eft.AddressOfNames - intVA + intRA + DWORD(4 * I), 0);
      FileRead(fHandle, intFuncRA, 4);
      FileSeek(fHandle, intFuncRA - intVA + intRA, 0);
      FileRead(fHandle, chrFuncName, 256);
      strFuncName := string(chrFuncName);
      if SameText(strFuncName, strDllExportFuncName) then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    FileClose(fHandle);
  end;
end;

{ ��ȡ������������� }
function GetNativePCName: string;
var
  chrPCName: array [0 .. 255] of Char;
  intLen   : Cardinal;
begin
  intLen := 256;
  GetComputerName(@chrPCName[0], intLen);
  Result := chrPCName;
end;

{ ��ȡ������ǰ��¼�û����� }
function GetCurrentLoginUserName: String;
var
  Buffer: array [0 .. 255] of Char;
  Count : Cardinal;
begin
  Result := '';
  Count  := 256;
  if GetUserName(Buffer, Count) then
  begin
    Result := Buffer;
  end;
end;

{ ������ʾ��ʽ }
function GetShowStyle: Integer;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    Result := ReadInteger(c_strIniUISection, 'ShowStyle', 0) mod 4;
    Free;
  end;
end;

{ �������ݿ����� }
function TryLinkDataBase(const strLinkDB: string; var ADOCNN: TADOConnection): Boolean;
begin
  Result := False;

  if strLinkDB = '' then
    Exit;

  if not Assigned(ADOCNN) then
    Exit;

  ADOCNN.KeepConnection := True;
  ADOCNN.LoginPrompt    := False;
  ADOCNN.Connected      := False;

  if Pos('.udl', LowerCase(strLinkDB)) > 0 then
  begin
    if Pos('FILE NAME=', strLinkDB) > 0 then
    begin
      ADOCNN.ConnectionString := strLinkDB;
      ADOCNN.Provider         := RightStr(strLinkDB, Length(strLinkDB) - 10);
    end
    else
    begin
      ADOCNN.ConnectionString := 'FILE NAME=' + strLinkDB;
      ADOCNN.Provider         := strLinkDB;
    end;
  end
  else
  begin
    ADOCNN.ConnectionString := strLinkDB;
  end;

  try
    ADOCNN.Connected := True;
    Result           := True;
  except
    Result := False;
  end;
end;

{ �������ݿ⣬֧��Զ�̱��ݣ����ݿ���뿪�� xpshell }
function BackupDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strSaveFileName: String): Boolean;
const
  c_strbackupDataBase =                                                    //
    ' exec master..xp_cmdshell ''net use z: \\%s\c$ "%s" /user:%s\%s'' ' + //
    ' backup database %s to disk = ''z:\temp.bak''' +                      //
    ' exec master..xp_cmdshell ''net use z: /delete''';
var
  strDBLibraryName: string;
  strNativePCName : string;
begin
  Result := False;
  if not ADOCNN.Connected then
    Exit;

  strDBLibraryName := GetDBLibraryName(ADOCNN.ConnectionString);
  strNativePCName  := GetNativePCName;

  with TADOQuery.Create(nil) do
  begin
    Connection := ADOCNN;
    SQL.Text   := Format(c_strbackupDataBase, [strNativePCName, strNativePCLoginPassword, strNativePCName, strNativePCLoginName, strDBLibraryName]);
    try
      DeleteFile('c:\temp.bak');
      ExecSQL;
      { �ƶ������ļ���ָ��λ�� }
      Result := MoveFile(PChar('c:\temp.bak'), PChar(strSaveFileName));
    except
      Result := False;
    end;
    Free;
  end;
end;

{ �ָ����ݿ⣬֧��Զ�ָ̻������ݿ���뿪�� xpshell }
function RestoreDataBase(ADOCNN: TADOConnection; const strNativePCLoginName, strNativePCLoginPassword: String; const strDBFileName: String; var strErr: String): Boolean;
const
  c_strbackupDataBase =                                                    //
    ' exec master..xp_cmdshell ''net use z: \\%s\c$ "%s" /user:%s\%s'' ' + //
    ' restore database %s from disk = ''z:\temp.bak''' +                   //
    ' exec master..xp_cmdshell ''net use z: /delete''';
var
  strDBLibraryName: String;
  strNativePCName : String;
begin
  Result := False;

  if not ADOCNN.Connected then
    Exit;

  { ɾ����ʱ�ļ� }
  DeleteFile('c:\temp.bak');
  strDBLibraryName := GetDBLibraryName(ADOCNN.ConnectionString);
  strNativePCName  := GetNativePCName;

  if Trim(strDBLibraryName) = '' then
    strDBLibraryName := 'RestoreTemp';

  { �����ļ��������ھ�Ŀ¼�� }
  if CopyFile(PChar(strDBFileName), PChar('c:\temp.bak'), True) then
  begin
    with TADOQuery.Create(nil) do
    begin
      Connection := ADOCNN;
      SQL.Text   := Format(c_strbackupDataBase, [strNativePCName, strNativePCLoginPassword, strNativePCName, strNativePCLoginName, strDBLibraryName]);
      try
        ExecSQL;
        Result := True;
      except
        on E: Exception do
        begin
          strErr := E.Message;
          Result := False;
        end;
      end;
      DeleteFile('c:\temp.bak');
      Free;
    end;
  end;
end;

{ ��ȡ���ݿ���� }
function GetDBLibraryName(const strLinkDB: string): String;
var
  I, J   : Integer;
  strTemp: String;
begin
  Result := '';
  I      := Pos('initial catalog=', LowerCase(strLinkDB));
  if I > 0 then
  begin
    strTemp := RightStr(strLinkDB, Length(strLinkDB) - I - Length('Initial Catalog=') + 1);
    J       := Pos(';', strTemp);
    Result  := LeftStr(strTemp, J - 1);
  end;
end;

{ ִ�� Sql �ű���ִ�гɹ����Ƿ�ɾ���ļ� }
function ExeSql(const strFileName: string; ADOCNN: TADOConnection; const bDeleteFileOnSuccess: Boolean = False): Boolean;
var
  strTemp: String;
  I      : Integer;
  qry    : TADOQuery;
begin
  Result := False;

  if not FileExists(strFileName) then
    Exit;

  try
    with TStringList.Create do
    begin
      qry := TADOQuery.Create(nil);
      try
        qry.Connection := ADOCNN;
        LoadFromFile(strFileName);
        strTemp := '';
        for I   := 0 to Count - 1 do
        begin
          if SameText(Trim(Strings[I]), 'GO') then
          begin
            qry.Close;
            qry.SQL.Clear;
            qry.SQL.Text := strTemp;
            qry.ExecSQL;
            strTemp := '';
          end
          else
          begin
            strTemp := strTemp + Strings[I] + #13#10;
          end;
        end;

        if strTemp <> '' then
        begin
          qry.Close;
          qry.SQL.Clear;
          qry.SQL.Text := strTemp;
          qry.ExecSQL;
        end;
      finally
        Result := True;
        if bDeleteFileOnSuccess then
          DeleteFile(strFileName);
        qry.Free;
        Free;
      end;
    end;
  except
    Result := False;
  end;
end;

{ �� Dll �л�ȡ���������б� }
function GetPEExport(const strDllFieName: String; var lstFunc: TStringList): Boolean;
var
  idh            : TImageDosHeader;
  bX64           : Boolean;
  hPEFile        : Cardinal;
  intVA          : Cardinal;
  intRA          : Cardinal;
  inhX86         : TImageNtHeaders32;
  inhX64         : TImageNtHeaders64;
  stsArr         : array of TImageSectionHeader;
  eft            : TImageExportDirectory;
  I              : Integer;
  intFuncRA      : Cardinal;
  strFunctionName: array [0 .. 255] of AnsiChar;
begin
  Result  := False;
  hPEFile := FileOpen(strDllFieName, fmOpenRead);
  if hPEFile = INVALID_HANDLE_VALUE then
  begin
    MessageBox(Application.MainForm.Handle, '�ļ��޷��򿪣����һ���ļ��Ƿ�ռ��', 'ϵͳ��ʾ��', MB_OK or MB_ICONERROR);
    Exit;
  end;

  try
    FileRead(hPEFile, idh, SizeOf(idh));
    if idh.e_magic <> IMAGE_DOS_SIGNATURE then
    begin
      MessageBox(Application.MainForm.Handle, '����PE�ļ��������ļ�', 'ϵͳ��ʾ��', MB_OK or MB_ICONERROR);
      Exit;
    end;

    FileSeek(hPEFile, idh._lfanew, 0);
    FileSeek(hPEFile, idh._lfanew, 0);
    FileRead(hPEFile, inhX86, SizeOf(TImageNtHeaders32));
    bX64 := inhX86.FileHeader.Machine = IMAGE_FILE_MACHINE_AMD64;

    if bX64 then
    begin
      FileSeek(hPEFile, idh._lfanew, 0);
      FileRead(hPEFile, inhX64, SizeOf(TImageNtHeaders64));
      intVA := inhX64.OptionalHeader.DataDirectory[0].VirtualAddress;
      SetLength(stsArr, inhX64.FileHeader.NumberOfSections);
      FileRead(hPEFile, stsArr[0], inhX64.FileHeader.NumberOfSections * SizeOf(TImageSectionHeader));
    end
    else
    begin
      intVA := inhX86.OptionalHeader.DataDirectory[0].VirtualAddress;
      SetLength(stsArr, inhX86.FileHeader.NumberOfSections);
      FileRead(hPEFile, stsArr[0], inhX86.FileHeader.NumberOfSections * SizeOf(TImageSectionHeader));
    end;

    { ��ȡ�������ڴ����ļ��е�λ�� }
    FindTableFilePos(stsArr, intVA, intRA);

    { ��ȡ���������б� }
    FileSeek(hPEFile, intRA, 0);
    FileRead(hPEFile, eft, SizeOf(TImageExportDirectory));
    for I := 0 to eft.NumberOfNames - 1 do
    begin
      FileSeek(hPEFile, (eft.AddressOfNames - intVA) + intRA + DWORD(4 * I), 0);
      FileRead(hPEFile, intFuncRA, 4);
      FileSeek(hPEFile, (intFuncRA - intVA) + intRA, 0);
      FileRead(hPEFile, strFunctionName, 256);
      lstFunc.Add(string(strFunctionName));
    end;

    Result := True;
  finally
    FileClose(hPEFile);
  end;
end;

{ ����ģ�� }
procedure SortModuleParent(var lstModuleList: THashedStringList; const strPModuleList: String);
var
  lstTemp           : THashedStringList;
  I, J              : Integer;
  strPModuleName    : String;
  strOrderModuleName: String;
begin
  lstTemp := THashedStringList.Create;
  try
    for J := 0 to Length(strPModuleList.Split([';'])) - 1 do
    begin
      for I := lstModuleList.Count - 1 downto 0 do
      begin
        strPModuleName     := lstModuleList.ValueFromIndex[I].Split([';'])[0];
        strOrderModuleName := strPModuleList.Split([';'])[J];
        if CompareText(strOrderModuleName, strPModuleName) = 0 then
        begin
          lstTemp.Add(lstModuleList.Strings[I]);
          lstModuleList.Delete(I);
        end;
      end;
    end;

    { �п��ܻ���ʣ�µģ�����ӵ���ģ��(��ģ��)����δ����֮ǰ���ǲ��������б��е� }
    if lstModuleList.Count > 0 then
    begin
      for I := 0 to lstModuleList.Count - 1 do
      begin
        lstTemp.Add(lstModuleList.Strings[I]);
      end;
    end;

    lstModuleList.Clear;
    lstModuleList.Assign(lstTemp);
  finally
    lstTemp.Free;
  end;
end;

{ ����λ�� }
procedure SwapPosHashStringList(var lstModuleList: THashedStringList; const I, J: Integer);
var
  strTemp: String;
begin
  strTemp                  := lstModuleList.Strings[I];
  lstModuleList.Strings[I] := lstModuleList.Strings[J];
  lstModuleList.Strings[J] := strTemp;
end;

{ ��ѯָ��ģ���λ�� }
function FindSubModuleIndex(const lstModuleList: THashedStringList; const strPModuleName, strSModuleName: String): Integer;
var
  I                  : Integer;
  strParentModuleName: String;
  strSubModuleName   : String;
begin
  Result := -1;
  for I  := 0 to lstModuleList.Count - 1 do
  begin
    strParentModuleName := lstModuleList.ValueFromIndex[I].Split([';'])[0];
    strSubModuleName    := lstModuleList.ValueFromIndex[I].Split([';'])[1];
    if (CompareText(strParentModuleName, strPModuleName) = 0) and (CompareText(strSubModuleName, strSModuleName) = 0) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ ��ѯָ����ģ���ָ��λ�õ������� }
function FindSubModulePos(const lstModuleList: THashedStringList; const strPModuleName: String; const intIndex: Integer): Integer;
var
  I, K               : Integer;
  strParentModuleName: String;
begin
  Result := -1;
  K      := -1;
  for I  := 0 to lstModuleList.Count - 1 do
  begin
    strParentModuleName := lstModuleList.ValueFromIndex[I].Split([';'])[0];
    if CompareText(strParentModuleName, strPModuleName) = 0 then
    begin
      Inc(K);
      if K = intIndex then
      begin
        Result := I;
        Break;
      end;
    end;
  end;
end;

{ ������ģ�� }
procedure SortSubModule_Proc(var lstModuleList: THashedStringList; const strPModuleName: String; const strSModuleOrder: string);
var
  I               : Integer;
  intNewIndex     : Integer;
  intOldIndex     : Integer;
  strSubModuleName: String;
begin
  for I := 0 to Length(strSModuleOrder.Split([';'])) - 1 do
  begin
    strSubModuleName := strSModuleOrder.Split([';'])[I];
    intNewIndex      := FindSubModuleIndex(lstModuleList, strPModuleName, strSubModuleName);
    intOldIndex      := FindSubModulePos(lstModuleList, strPModuleName, I);
    if (intNewIndex <> intOldIndex) and (intNewIndex > -1) and (intOldIndex > -1) then
    begin
      SwapPosHashStringList(lstModuleList, intNewIndex, intOldIndex);
    end;
  end;
end;

{ ������ģ�� }
procedure SortSubModule(var lstModuleList: THashedStringList; const strPModuleOrder: String; const iniModule: TIniFile);
var
  I, Count       : Integer;
  strPModuleName : String;
  strSModuleOrder: String;
begin
  Count := Length(strPModuleOrder.Split([';']));
  for I := 0 to Count - 1 do
  begin
    strPModuleName  := strPModuleOrder.Split([';'])[I];
    strSModuleOrder := iniModule.ReadString(c_strIniModuleSection, strPModuleName, '');
    if Trim(strSModuleOrder) <> '' then
    begin
      SortSubModule_Proc(lstModuleList, strPModuleName, strSModuleOrder);
    end;
  end;
end;

{ ����ģ�� }
procedure SortModuleList(var lstModuleList: THashedStringList);
var
  strPModuleOrder: String;
  iniModule      : TIniFile;
begin
  iniModule := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    { ����ģ�� }
    strPModuleOrder := iniModule.ReadString(c_strIniModuleSection, 'Order', '');
    if Trim(strPModuleOrder) <> '' then
      SortModuleParent(lstModuleList, strPModuleOrder);

    { ������ģ�� }
    SortSubModule(lstModuleList, strPModuleOrder, iniModule);
  finally
    iniModule.Free;
  end;
end;

function GetSystemPath: String;
var
  Buffer: array [0 .. 255] of Char;
begin
  GetSystemDirectory(Buffer, 256);
  Result := Buffer;
end;

{ �� .msc �ļ��л�ȡͼ�� }
procedure LoadIconFromMSCFile(const strMSCFileName: string; var IcoMSC: TIcon);
var
  strLine       : String;
  strSystemPath : String;
  I, J, intIndex: Integer;
  intIconIndex  : Integer;
  strDllFileName: String;
  strTemp       : String;
begin
  with TStringList.Create do
  begin
    intIndex      := -1;
    strSystemPath := GetSystemPath;
    LoadFromFile(strSystemPath + '\' + strMSCFileName, TEncoding.ASCII);

    for I := 0 to Count - 1 do
    begin
      strLine := Strings[I];
      if strLine <> '' then
      begin
        if Pos('<Icon Index="', strLine) > 0 then
        begin
          intIndex := I;
          Break;
        end;
      end;
    end;

    if intIndex <> -1 then
    begin
      strLine      := Strings[intIndex];
      I            := Pos('"', strLine);
      strTemp      := RightStr(strLine, Length(strLine) - I);
      J            := Pos('"', strTemp);
      intIconIndex := StrToIntDef(MidStr(strLine, I + 1, J - 1), 0);

      I              := Pos('File="', strLine);
      strTemp        := RightStr(strLine, Length(strLine) - I - 5);
      J              := Pos('"', strTemp);
      strDllFileName := MidStr(strTemp, 1, J - 1);

      IcoMSC.Handle := ExtractIcon(HInstance, PChar(strDllFileName), intIconIndex);
    end;

    Free;
  end;
end;

{ ��ȡ���������ϴ��ٶ� }
var
  FintDnBytes: UInt64 = 0;
  FintUpBytes: UInt64 = 0;

procedure GetWebSpeed(var strDnSpeed, strUpSpeed: string);
var
  NetworkManager        : TNetworkManager;
  lsNetworkTraffic      : TList;
  I                     : Integer;
  intDnSpeed, intUpSpeed: Cardinal;
  strNetworkDesc        : String;
  intDnBytes            : UInt64;
  intUpBytes            : UInt64;
begin
  NetworkManager   := TNetworkManager.Create(0);
  lsNetworkTraffic := TList.Create;
  try
    NetworkManager.GetNetworkTraffic(lsNetworkTraffic);
    if lsNetworkTraffic.Count > 0 then
    begin
      intDnBytes := 0;
      intUpBytes := 0;

      for I := 0 to lsNetworkTraffic.Count - 1 do
      begin
        strNetworkDesc := NetworkManager.GetDescrString(PMibIfRow(lsNetworkTraffic.Items[I])^.bDescr);
        if Pos('-0000', strNetworkDesc) = 0 then
        begin
          intDnBytes := intDnBytes + PMibIfRow(lsNetworkTraffic.Items[I])^.dwInOctets;
          intUpBytes := intUpBytes + PMibIfRow(lsNetworkTraffic.Items[I])^.dwOutOctets;
        end;
      end;

      { ��һ�� }
      if (FintDnBytes = 0) and (FintUpBytes = 0) then
      begin
        strDnSpeed := Format('%0.2f K/S', [0.0]);
        strUpSpeed := Format('%0.2f K/S', [0.0]);

        FintDnBytes := intDnBytes;
        FintUpBytes := intUpBytes;
        Exit;
      end;

      { �����ٶ� }
      intDnSpeed := intDnBytes - FintDnBytes;
      if intDnSpeed > 1024 * 1024 then
        strDnSpeed := Format('%0.2f M/S', [intDnSpeed / 1024 / 1024])
      else
        strDnSpeed := Format('%0.2f K/S', [intDnSpeed / 1024]);

      { �ϴ��ٶ� }
      intUpSpeed := intUpBytes - FintUpBytes;
      if intUpSpeed > 1024 * 1024 then
        strUpSpeed := Format('%0.2f M/S', [intUpSpeed / 1024 / 1024])
      else
        strUpSpeed := Format('%0.2f K/S', [intUpSpeed / 1024]);

      FintDnBytes := intDnBytes;
      FintUpBytes := intUpBytes;
    end;
  finally
    lsNetworkTraffic.Free;
    NetworkManager.Free;
  end;
end;

{ ��ȡ���������б���Ϣ }
function GetAdapterInfo(var lst: TList): Boolean;
var
  Adapters, Work: PIP_ADAPTER_INFO;
  BufLen        : ULONG;
  Ret           : DWORD;
begin
  Result := False;

  BufLen := 1024 * 15;
  GetMem(Adapters, BufLen);
  try
    repeat
      Ret := GetAdaptersInfo(Adapters, BufLen);
      case Ret of
        ERROR_SUCCESS:
          begin
            if BufLen = 0 then
              Exit;
            Break;
          end;

        ERROR_NOT_SUPPORTED, ERROR_NO_DATA:
          Exit;

        ERROR_BUFFER_OVERFLOW:
          ReallocMem(Adapters, BufLen);
      else
        SetLastError(Ret);
        RaiseLastOSError;
      end;
    until False;

    if Ret = ERROR_SUCCESS then
    begin
      Work := Adapters;
      repeat
        lst.Add(Work);
        Work := Work^.Next;
      until (Work = nil);
      Result := True;
    end;
  finally
    FreeMem(Adapters);
  end;
end;

{ ��ȡ����IP }
function GetNativeIP: String;
var
  lstAdapter  : TList;
  I           : Integer;
  AdapterInfo : PIP_ADAPTER_INFO;
  strGatewayIP: String;
begin
  Result     := '';
  lstAdapter := TList.Create;
  try
    GetAdapterInfo(lstAdapter);
    if lstAdapter.Count <= 0 then
      Exit;

    for I := 0 to lstAdapter.Count - 1 do
    begin
      AdapterInfo  := PIP_ADAPTER_INFO(lstAdapter.Items[I]);
      strGatewayIP := string(AdapterInfo.GatewayList.IpAddress.S);
      if not SameText(strGatewayIP, '0.0.0.0') then
      begin
        Result := string(AdapterInfo^.IpAddressList.IpAddress.S);
        Break;
      end;
    end;
  finally
    lstAdapter.Free;
  end;
end;

function GetCurrentAdapterIP: String;
var
  strName       : String;
  strIniFileName: String;
  I             : Integer;
  lstAdapter    : TList;
  AdapterInfo   : PIP_ADAPTER_INFO;
begin
  strIniFileName := ChangeFileExt(ParamStr(0), '.ini');
  with TIniFile.Create(strIniFileName) do
  begin
    strName := ReadString('Network', 'AdapterName', strName);
    Free;
  end;

  if Trim(strName) = '' then
  begin
    Result := GetNativeIP;
    Exit;
  end;

  lstAdapter := TList.Create;
  try
    GetAdapterInfo(lstAdapter);
    if lstAdapter.Count > 0 then
    begin
      for I := 0 to lstAdapter.Count - 1 do
      begin
        AdapterInfo := PIP_ADAPTER_INFO(lstAdapter.Items[I]);
        if SameText(string(AdapterInfo^.Description), strName) then
        begin
          Result := string(AdapterInfo^.IpAddressList.IpAddress.S);
          Break;
        end;
      end;
    end;
  finally
    lstAdapter.Free;
  end;
end;

{ ����Ȩ�� }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;
var
  TP    : Winapi.Windows.TOKEN_PRIVILEGES;
  Dummy : Cardinal;
  hToken: THandle;
begin
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, hToken);
  TP.PrivilegeCount := 1;
  LookupPrivilegeValue(nil, PChar(PrivName), TP.Privileges[0].Luid);
  TP.Privileges[0].Attributes := Ifthen(CanDebug, SE_PRIVILEGE_ENABLED, 0);
  Result                      := AdjustTokenPrivileges(hToken, False, TP, SizeOf(TP), nil, Dummy);
  hToken                      := 0;
end;

{ �����ַ��� }
function EncryptString(const strTemp, strKey: string): String;
begin
  Result := AESEncryptStrToHex(strTemp, strKey, TEncoding.Unicode, TEncoding.UTF8, TKeyBit.kb256, '1234567890123456', TPaddingMode.pmPKCS5or7RandomPadding, True, rlCRLF, rlCRLF, nil);
end;

{ �����ַ��� }
function DecryptString(const strTemp, strKey: string): String;
begin
  Result := AESDecryptStrFromHex(strTemp, strKey, TEncoding.Unicode, TEncoding.UTF8, TKeyBit.kb256, '1234567890123456', TPaddingMode.pmPKCS5or7RandomPadding, True, rlCRLF, rlCRLF, nil);
end;

{ �������ݿ�---ִ�нű� }
function UpdateDataBaseScript(const iniFile: TIniFile; const ADOCNN: TADOConnection; const bDeleteFile: Boolean = False): Boolean;
var
  strSQLFileName: String;
begin
  Result := False;
  if iniFile.ReadBool(c_strIniDBSection, 'AutoUpdate', False) then
  begin
    strSQLFileName := iniFile.ReadString(c_strIniDBSection, 'AutoUpdateFile', '');
    if (Trim(strSQLFileName) <> '') and (FileExists(strSQLFileName)) then
    begin
      Result := ExeSql(ExtractFilePath(ParamStr(0)) + strSQLFileName, ADOCNN, bDeleteFile);
    end;
  end;
end;

{ ���ݿ�������� }
function EncDatabasePassword(const strPassword: string): String;
var
  strDllFileName: String;
  strDllFuncName: String;
  hDll          : HMODULE;
  EncFunc       : function(const strPassword: PAnsiChar): PAnsiChar; stdcall;
begin
  Result := strPassword;
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    if ReadBool(c_strIniDBSection, 'PasswordEnc', False) then
    begin
      strDllFileName := ReadString(c_strIniDBSection, 'PasswordEncDllFileName', '');
      strDllFuncName := ReadString(c_strIniDBSection, 'PasswordEncDllFuncName', '');
      if FileExists(strDllFileName) then
      begin
        hDll := LoadLibrary(PChar(strDllFileName));
        if hDll <> INVALID_HANDLE_VALUE then
        begin
          try
            EncFunc := GetProcaddress(hDll, PChar(strDllFuncName));
            if Assigned(EncFunc) = True then
            begin
              Result := string(PChar(EncFunc(PAnsiChar(PChar(strPassword)))));
            end;
          finally
            FreeLibrary(hDll);
          end;
        end;
      end;
    end;
    Free;
  end;
end;

function GetDllFileIcon(const strPModuleName, strSModuleName: string; var ilMainMenu: TImageList): Integer;
var
  strIconFilePath: String;
  strIconFileName: String;
  IcoExe         : TIcon;
begin
  Result := -1;
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    strIconFilePath := ReadString(c_strIniModuleSection, Format('%s_%s_ICON', [strPModuleName, strSModuleName]), '');
    strIconFileName := ExtractFilePath(ParamStr(0)) + 'Plugins\Icon\' + strIconFilePath;
    if FileExists(strIconFileName) then
    begin
      IcoExe := TIcon.Create;
      try
        IcoExe.LoadFromFile(strIconFileName);
        Result := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end;
    Free;
  end;
end;

function GetExeFileIcon(const strFileName: String; var ilMainMenu: TImageList): Integer;
var
  IcoExe: TIcon;
begin
  Result := -1;
  if CompareText(ExtractFileExt(strFileName), '.msc') = 0 then
  begin
    IcoExe := TIcon.Create;
    try
      { �� .msc �ļ��л�ȡͼ�� }
      LoadIconFromMSCFile(strFileName, IcoExe);
      Result := ilMainMenu.AddIcon(IcoExe);
    finally
      IcoExe.Free;
    end;
  end
  else
  begin
    if ExtractIcon(HInstance, PChar(strFileName), $FFFFFFFF) > 0 then
    begin
      IcoExe := TIcon.Create;
      try
        IcoExe.Handle := ExtractIcon(HInstance, PChar(strFileName), 0);
        Result        := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end;
  end;
end;

{ ɨ�� EXE �ļ�����ȡ�����ļ� }
procedure LoadAllPlugins_EXE(var lstDll: THashedStringList; var ilMainMenu: TImageList);
var
  lstEXE      : TStringList;
  I, J        : Integer;
  strEXEInfo  : String;
  strFileName : String;
  intIconIndex: Integer;

begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    lstEXE := TStringList.Create;
    try
      ReadSection('EXE', lstEXE);
      for I := 0 to lstEXE.Count - 1 do
      begin
        strFileName  := lstEXE.Strings[I];
        strEXEInfo   := ReadString('EXE', strFileName, '');
        intIconIndex := GetExeFileIcon(strFileName, ilMainMenu);
        J            := strEXEInfo.CountChar(';');
        if J = 4 then
          strEXEInfo := strEXEInfo + IntToStr(intIconIndex)
        else
          strEXEInfo := strEXEInfo + ';' + IntToStr(intIconIndex);
        strEXEInfo   := strEXEInfo + ';' + IntToStr(Integer(TLangStyle(lsEXE)));
        lstDll.Add(Format('%s=%s', [strFileName, strEXEInfo]));
      end;
    finally
      lstEXE.Free;
    end;
    Free;
  end;
end;

{ ��ȡ Dll ����������ӵ��б� }
procedure AddDllInfoToList(var lstDll: THashedStringList; var ilMainMenu: TImageList; const strDllFileName: string; pFunc: Pointer);
var
  strPModuleName : PAnsiChar;
  strSModuleName : PAnsiChar;
  strVCClassName : PAnsiChar;
  strVCWindowName: PAnsiChar;
  ltDll          : TLangStyle;
  frm            : TFormClass;
  intIconIndex   : Integer;
  strInfo        : string;
begin

  strPModuleName  := '';
  strSModuleName  := '';
  strVCClassName  := '';
  strVCWindowName := '';
  Tdb_ShowDllForm_Plugins_VCForm(pFunc)(ltDll, strPModuleName, strSModuleName, strVCClassName, strVCWindowName);
  if strVCClassName = '' then
  begin
    Tdb_ShowDllForm_Plugins_Delphi(pFunc)(frm, strPModuleName, strSModuleName);
    strVCClassName  := '';
    strVCWindowName := '';
    ltDll           := lsDelphiDll;
  end;
  intIconIndex := GetDllFileIcon(string(strPModuleName), string(strSModuleName), ilMainMenu);
  strInfo      := strDllFileName + '=' + string(strPModuleName) + ';' + string(strSModuleName) + ';' + string(strVCClassName) + ';' + string(strVCWindowName) + ';' + IntToStr(intIconIndex) + ';' + IntToStr(Integer(ltDll));
  lstDll.Add(strInfo);
end;

{ ɨ�� Dll �ļ�����ȡ Plugins Ŀ¼ }
procedure LoadAllPlugins_Dll(var lstDll: THashedStringList; var ilMainMenu: TImageList);
var
  strPath  : String;
  lstFile  : TStringDynArray;
  sFileName: String;
  hDll     : HMODULE;
  pFunc    : Pointer;
begin
  if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'plugins') then
    Exit;

  strPath := ExtractFilePath(ParamStr(0)) + 'plugins';
  lstFile := TDirectory.GetFiles(strPath, '*.dll');
  if Length(lstFile) = 0 then
    Exit;

  for sFileName in lstFile do
  begin
    { �Ƿ����ָ���������� }
    if not CheckDllExportFunc(sFileName, c_strDllExportFuncName) then
      Continue;

    { ���� Dll����ȡ���� }
    hDll := LoadLibrary(PChar(sFileName));
    if hDll <= 0 then
      Continue;

    try
      pFunc := GetProcaddress(hDll, c_strDllExportFuncName);
      if not Assigned(pFunc) then
      begin
        FreeLibrary(hDll);
        Continue;
      end;

      { ��ȡ Dll ��������ӵ��б� }
      AddDllInfoToList(lstDll, ilMainMenu, sFileName, pFunc);
    finally
      FreeLibrary(hDll);
    end;
  end;
end;

{ ��ȡ�ؼ��߶� }
function GetLabelHeight(const strFontName: string; const intFontSize: Integer): Integer;
const
  c_strName = '���±�';
var
  DC      : HDC;
  Font    : TFont;
  hSavFont: HFont;
  Size    : TSize;
begin
  DC   := GetDC(0);
  Font := TFont.Create;
  try
    Font.Name := strFontName;
    Font.Size := intFontSize;
    hSavFont  := SelectObject(DC, Font.Handle);
    GetTextExtentPoint32(DC, PChar(c_strName), Length(c_strName), Size);
    SelectObject(DC, hSavFont);
    Result := Size.cy;
  finally
    ReleaseDC(0, DC);
    Font.Free;
  end;
end;

{ ��ʱ���� }
procedure DelayTime(const intTime: Cardinal);
var
  intST, intET: Cardinal;
begin
  intST := GetTickCount;
  while True do
  begin
    Application.ProcessMessages;
    intET := GetTickCount;
    if intET - intST >= intTime then
      Break;
  end;
end;

{ �����Ƿ�ر� }
function CheckProcessExist(const intPID: DWORD): Boolean;
var
  hSnap: THandle;
  vPE  : TProcessEntry32;
begin
  Result     := False;
  hSnap      := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  vPE.dwSize := SizeOf(TProcessEntry32);
  if Process32First(hSnap, vPE) then
  begin
    while Process32Next(hSnap, vPE) do
    begin
      if vPE.th32ProcessID = intPID then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
  CloseHandle(hSnap);
end;

{ ɾ����������ļ��й��ڴ���λ�õ�������Ϣ }
procedure CheckPlugInConfigSize;
var
  strPlugInsPath: String;
  lstFiles      : TStringDynArray;
  strFileNameCFG: string;
begin
  strPlugInsPath := ExtractFilePath(ParamStr(0)) + 'plugins';
  if not DirectoryExists(strPlugInsPath) then
    Exit;

  lstFiles := TDirectory.GetFiles(strPlugInsPath, '*.cfg', TSearchOption.soAllDirectories);
  for strFileNameCFG in lstFiles do
  begin
    with TIniFile.Create(strFileNameCFG) do
    begin
      DeleteKey('General', 'WinPos');
      Free;
    end;
  end;
end;

function ShowFileProperties(FileName: String; Wnd: hWnd): Boolean;
var
  sfi: TSHELLEXECUTEINFOW;
begin
  with sfi do
  begin
    cbSize       := SizeOf(sfi);
    lpFile       := PChar(FileName);
    Wnd          := Wnd;
    fMask        := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_INVOKEIDLIST or SEE_MASK_FLAG_NO_UI;
    lpVerb       := PChar('properties');
    lpIDList     := nil;
    lpDirectory  := nil;
    nShow        := 0;
    hInstApp     := 0;
    lpParameters := nil;
    dwHotKey     := 0;
    hIcon        := 0;
    hkeyClass    := 0;
    hProcess     := 0;
    lpClass      := nil;
  end;
  Result := ShellExecuteEX(@sfi);
end;

function SHOpenFolderAndSelectItems(pidlFolder: pItemIDList; cidl: Cardinal; apidl: Pointer; dwFlags: DWORD): HRESULT; stdcall; external shell32;

function OpenFolderAndSelectFile(const strFileName: string; const bEditMode: Boolean = False): Boolean;
var
  IIDL      : pItemIDList;
  pShellLink: IShellLink;
  hr        : Integer;
begin
  Result := False;

  hr := CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IID_IShellLink, &pShellLink);
  if hr = S_OK then
  begin
    pShellLink.SetPath(PChar(strFileName));
    pShellLink.GetIDList(&IIDL);
    Result := SHOpenFolderAndSelectItems(IIDL, 0, nil, Cardinal(bEditMode)) = S_OK;
  end;
end;

{ ȡ�õ�ǰ���̵��߳��� }
function GetProcessThreadCount: Integer;
var
  SnapProcHandle: THandle;
  ThreadEntry   : TThreadEntry32;
  Next          : Boolean;
begin
  Result         := 0;
  SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if SnapProcHandle <> THandle(-1) then
  begin
    ThreadEntry.dwSize := SizeOf(ThreadEntry);
    Next               := Thread32First(SnapProcHandle, ThreadEntry);
    while Next do
    begin
      if (ThreadEntry.th32OwnerProcessID = GetCurrentProcessId) then
        Result := Result + 1;
      Next     := Thread32Next(SnapProcHandle, ThreadEntry);
    end;
    CloseHandle(SnapProcHandle);
  end;
end;

{ ȥ�������� }
procedure RemoveCaption(hWnd: THandle);
var
  bShowCloseButton: Boolean;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    bShowCloseButton := ReadBool(c_strIniUISection, 'ShowCloseButton', True);
    Free;
  end;

  if not bShowCloseButton then
    SetWindowLong(hWnd, GWL_STYLE, GetWindowLong(hWnd, GWL_STYLE) xor WS_CAPTION);
end;

{ ��ȡ DLL ģ���ļ���������·�� }
function GetDllFullFileName: String;
var
  strFileName: array [0 .. 255] of Char;
begin
  GetModuleFileName(HInstance, strFileName, 256);
  Result := strFileName;
end;

{ ��ȡ DLL ����·�� }
function GetDllFilePath: String;
begin
  Result := ExtractFilePath(GetDllFullFileName);
end;

{ ��ȡ��������ȫ�� C++ ���ͺ��� }
function GetFullFuncNameCpp(const strFuncName: string): String;
var
  strFuncFullName: array [0 .. 255] of AnsiChar;
begin
  UnDecorateSymbolName(PAnsiChar(AnsiString(strFuncName)), strFuncFullName, 256, 0);
  Result := string(strFuncFullName);
end;

{ ���ټ��������ļ����� }
function GetLoadSpeedFileName_Config: String;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'plugins\' + ChangeFileExt(ExtractFileName(ParamStr(0)), '.lsc');
end;

{ ���ټ���ͼ���ļ����� }
function GetLoadSpeedFileName_Icolst: String;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'plugins\' + ChangeFileExt(ExtractFileName(ParamStr(0)), '.lsi');
end;

{ �Ƿ����˼��ټ�����ģ�� }
function CheckLoadSpeed: Boolean;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    Result := ReadBool(c_strIniUISection, 'LoadSpeed', False) and FileExists(GetLoadSpeedFileName_Config) and FileExists(GetLoadSpeedFileName_Icolst);
    Free;
  end;
end;

{ ���ټ���ʱ��ÿ���˵����ͼ�� }
procedure LoadAllMenuIconSpeed(const ilMainMenu: TImageList);
begin
  TImageListEx(ilMainMenu).LoadFromFile(GetLoadSpeedFileName_Icolst);
end;

{ ��ȡ�ַ�����ȣ�������Ӣ�ġ����ֵ� }
function GetStringWidth(const strValue: string; const Font: TFont): Integer;
var
  DC      : HDC;
  hSavFont: HFont;
  Size    : TSize;
begin
  DC       := GetDC(0);
  hSavFont := SelectObject(DC, Font.Handle);
  GetTextExtentPoint32(DC, PChar(strValue), Length(strValue), Size);
  SelectObject(DC, hSavFont);
  ReleaseDC(0, DC);
  Result := Size.cx;
end;

{ �����ַ��������̶����� }
function AlignStringWidth(const strValue: string; const Font: TFont; const intMaxLen: Integer = 200): String;
var
  intLen: Integer;
begin
  Result := strValue;
  intLen := GetStringWidth(strValue, Font);
  if intLen >= intMaxLen then
    Exit;

  while True do
  begin
    Result := Result + ' ';
    if GetStringWidth(Result, Font) >= intMaxLen then
      Break;
  end;
end;

end.
