unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.Math, System.IniFiles, System.SysUtils, System.StrUtils, System.Classes, System.IOUtils, System.Types, System.Diagnostics, System.Generics.Collections,
  Vcl.Controls, Vcl.WinXCtrls, Vcl.Forms, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.FileCtrl, Vcl.Menus,
  SynSQLite3, SynSQLite3Static, SynCommons, db.uTSDFS, db.uCommon;

type
  TfrmSuperSearch = class(TForm)
    tmrStart: TTimer;
    mmoLog: TMemo;
    btnClose: TBitBtn;
    lbl1: TLabel;
    srchbxFileName: TSearchBox;
    btnReSearch: TButton;
    lvFiles: TListView;
    lblTip: TLabel;
    pmFile: TPopupMenu;
    mnuFileOpen: TMenuItem;
    mniFilePos: TMenuItem;
    mniFileReName: TMenuItem;
    mniFileCopyTo: TMenuItem;
    mniFileMoveTo: TMenuItem;
    mniFileLine01: TMenuItem;
    mniFileAttr: TMenuItem;
    mnuFileCopyTo: TMenuItem;
    procedure tmrStartTimer(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure lvFilesData(Sender: TObject; Item: TListItem);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnReSearchClick(Sender: TObject);
    procedure srchbxFileNameInvokeSearch(Sender: TObject);
    procedure mnuFileOpenClick(Sender: TObject);
    procedure mniFilePosClick(Sender: TObject);
    procedure mniFileReNameClick(Sender: TObject);
    procedure mniFileCopyToClick(Sender: TObject);
    procedure mniFileMoveToClick(Sender: TObject);
    procedure mniFileAttrClick(Sender: TObject);
    procedure mnuFileCopyToClick(Sender: TObject);
    procedure srchbxFileNameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FDatabase          : TSQLDataBase;
    FintDrivesCount    : Integer;
    FlstFilesCount     : THashedStringList;
    FbSearchFile       : Boolean;
    FstrArrSearchResult: TRawUTF8DynArray;
    { 开始全盘搜索文件 }
    procedure StartSearchFiles;
    { 创建搜索文件线程，多个磁盘一起搜索 }
    procedure CreateGetFilesThread(const lstDrives: TStringList);
    { 创建 Sqlite3 数据库 }
    procedure CreateSQLite3DB;
    { 创建表 }
    procedure CreateSQLite3Table(const strDriveName: Char);
    { 创建索引，加快查询速度 }
    procedure CreateSQLite3Index(const strDriveName: Char);
    { 获取文件总数 }
    function GetFilesCount: Integer;
    { 获取文件全路径名称 }
    function GetFullFileName(const intIndex: Integer; const bSearchFile: Boolean = False): String; overload;
    function GetFullFileName(const strTabelName: String; const intIndex, intID: Integer; const bSearchFile: Boolean = False): string; overload;
    { 加载原有的数据库文件 }
    procedure LoadFilesDB(const strFileName: String);
  protected
    { 单个磁盘文件搜索完毕 }
    procedure WMSEARCHDRIVEFILEFINISHED(var msg: TMessage); message WM_SEARCHDRIVEFILEFINISHED;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmSuperSearch;
  strParentModuleName     := '系统管理';
  strSubModuleName        := '超级文件搜索 v2.0';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetDllModuleIconHandle(String(strParentModuleName), string(strSubModuleName));
end;

{ 加载原有的数据库文件 }
procedure TfrmSuperSearch.LoadFilesDB(const strFileName: String);
var
  I, Count    : Integer;
  arrTableName: TRawUTF8DynArray;
begin
  FDatabase             := TSQLDataBase.Create(strFileName);
  FlstFilesCount        := THashedStringList.Create;
  FlstFilesCount.Sorted := True;
  FDatabase.Execute('SELECT name FROM sqlite_master WHERE type=''table'' ORDER BY name', arrTableName);
  for I := 0 to Length(arrTableName) - 1 do
  begin
    Count := FDatabase.ExecuteNoExceptionInt64(RawUTF8(Format('select count(id) from %s', [arrTableName[I]])));
    FlstFilesCount.Add(Format('%s=%d', [arrTableName[I][1], Count]));
  end;

  lvFiles.Items.Count    := GetFilesCount;
  btnClose.Visible       := False;
  mmoLog.Visible         := False;
  btnReSearch.Enabled    := True;
  srchbxFileName.Enabled := True;
  lvFiles.Height         := lvFiles.Height + mmoLog.Height + 6;
end;

procedure TfrmSuperSearch.tmrStartTimer(Sender: TObject);
var
  strFileName: String;
begin
  tmrStart.Enabled       := False;
  btnClose.Enabled       := False;
  btnReSearch.Enabled    := False;
  srchbxFileName.Enabled := False;
  FbSearchFile           := False;

  { 数据库文件是否存在，存在则加载 }
  strFileName := ChangeFileExt(GetDllFullFileName, '.db');
  if FileExists(strFileName) then
  begin
    mmoLog.Lines.Add('数据库文件存在，加载中，请稍等••••••');
    LoadFilesDB(strFileName);
    Exit;
  end;

  { 开始全盘搜索文件 }
  StartSearchFiles;
end;

{ 再次全盘搜索文件 }
procedure TfrmSuperSearch.btnReSearchClick(Sender: TObject);
var
  strFileName: String;
begin
  strFileName            := ChangeFileExt(GetDllFullFileName, '.db');
  btnClose.Visible       := True;
  btnClose.Enabled       := False;
  btnReSearch.Enabled    := False;
  srchbxFileName.Enabled := False;
  FbSearchFile           := False;
  lvFiles.Items.Count    := 0;
  FintDrivesCount        := 0;
  if not mmoLog.Visible then
  begin
    lvFiles.Height := lvFiles.Height - mmoLog.Height - 6;
    mmoLog.Visible := True;
  end;
  FDatabase.DBClose;
  FDatabase.free;
  DeleteFile(strFileName);
  FlstFilesCount.Clear;
  FlstFilesCount.free;
  mmoLog.Clear;

  tmrStart.Enabled := True;
end;

{ 单个磁盘文件搜索完毕 }
procedure TfrmSuperSearch.WMSEARCHDRIVEFILEFINISHED(var msg: TMessage);
begin
  Dec(FintDrivesCount);
  FlstFilesCount.Add(string(PChar(msg.WParam)));
  mmoLog.Lines.Add(string(PChar(msg.LParam)));

  if FintDrivesCount = 0 then
  begin
    FDatabase.Commit;
    btnClose.Enabled       := True;
    btnReSearch.Enabled    := True;
    srchbxFileName.Enabled := True;
    lvFiles.Items.Count    := GetFilesCount;
  end;
end;

{ 获取文件总数 }
function TfrmSuperSearch.GetFilesCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I  := 0 to FlstFilesCount.Count - 1 do
  begin
    Result := Result + StrToInt(FlstFilesCount.ValueFromIndex[I]);
  end;
end;

procedure TfrmSuperSearch.btnCloseClick(Sender: TObject);
begin
  btnClose.Visible := False;
  mmoLog.Visible   := False;
  lvFiles.Height   := lvFiles.Height + mmoLog.Height + 6;
end;

{ 创建 Sqlite3 数据库 }
procedure TfrmSuperSearch.CreateSQLite3DB;
var
  strFileName: String;
begin
  strFileName := ChangeFileExt(GetDllFullFileName, '.db');
  if FileExists(strFileName) then
    DeleteFile(strFileName);

  FDatabase := TSQLDataBase.Create(strFileName);            // 创建 Sqlite3 数据库
  FDatabase.ExecuteNoException('PRAGMA synchronous = OFF'); // 关闭写同步，加快写入速度
  FDatabase.TransactionBegin();                             // 开启事务，加快写入速度
end;

{ 开始全盘搜索文件 }
procedure TfrmSuperSearch.StartSearchFiles;
var
  strDrives: System.Types.TStringDynArray;
  strDrive : String;
  sysFlags : DWORD;
  strNTFS  : array [0 .. 255] of Char;
  intlen   : DWORD;
  lstDrives: TStringList;
begin
  FintDrivesCount       := 0;
  FlstFilesCount        := THashedStringList.Create;
  FlstFilesCount.Sorted := True;
  CreateSQLite3DB;

  { 检查逻辑磁盘是否是 NTFS 格式 }
  lstDrives := TStringList.Create;
  try
    strDrives := TDirectory.GetLogicalDrives;
    for strDrive in strDrives do
    begin
      if not GetVolumeInformation(PChar(strDrive), nil, 0, nil, intlen, sysFlags, strNTFS, 256) then
        Continue;

      if not SameText(strNTFS, 'NTFS') then
        Continue;

      lstDrives.Add(strDrive[1]);
    end;

    FintDrivesCount := lstDrives.Count;
    CreateGetFilesThread(lstDrives);
  finally
    lstDrives.free;
  end;
end;

{ 创建表 }
procedure TfrmSuperSearch.CreateSQLite3Table(const strDriveName: Char);
begin
  FDatabase.ExecuteNoException(RawUTF8(Format(c_strCreateDriveTable, [strDriveName])));
end;

{ 创建索引，加快查询速度 }
procedure TfrmSuperSearch.CreateSQLite3Index(const strDriveName: Char);
begin
  FDatabase.ExecuteNoException(RawUTF8(Format(c_strCreateDriveIndex01, [strDriveName, strDriveName])));
  FDatabase.ExecuteNoException(RawUTF8(Format(c_strCreateDriveIndex02, [strDriveName, strDriveName])));
  FDatabase.ExecuteNoException(RawUTF8(Format(c_strCreateDriveIndex03, [strDriveName, strDriveName])));
end;

procedure TfrmSuperSearch.FormDestroy(Sender: TObject);
begin
  if FDatabase <> nil then
    FDatabase.free;
  if FlstFilesCount <> nil then
    FlstFilesCount.free;
end;

procedure TfrmSuperSearch.FormResize(Sender: TObject);
begin
  lvFiles.Columns[1].Width := Width - 160;
end;

{ 创建搜索文件线程，多个磁盘一起搜索 }
procedure TfrmSuperSearch.CreateGetFilesThread(const lstDrives: TStringList);
var
  I: Integer;
begin
  mmoLog.Lines.Add(Format('开始全盘搜索(%s)', [lstDrives.DelimitedText]));
  for I := 0 to lstDrives.Count - 1 do
  begin
    CreateSQLite3Table(lstDrives.Strings[I][1]);
    CreateSQLite3Index(lstDrives.Strings[I][1]);
    TThreadGetFiles.Create(Handle, lstDrives.Strings[I][1], FDatabase);
  end;
end;

{ 获取文件全路径名称 }
function TfrmSuperSearch.GetFullFileName(const intIndex: Integer; const bSearchFile: Boolean = False): String;
var
  I, J, intID: Integer;
  ttt        : Integer;
  strDrive   : String;
  strValue   : string;
begin
  Result := '';
  intID  := intIndex;
  J      := 0;
  ttt    := 0;

  if bSearchFile then
  begin
    strValue := string(FstrArrSearchResult[intIndex - 1]);
    strDrive := strValue.Split([';'])[1];
    intID    := StrToInt(strValue.Split([';'])[0]);
  end
  else
  begin
    { 获取对应的盘符 }
    for I := 0 to FlstFilesCount.Count - 1 do
    begin
      ttt := ttt + StrToInt(FlstFilesCount.ValueFromIndex[I]);
      if intIndex <= ttt then
      begin
        J := I;
        Break;
      end;
    end;

    { 获取记录 ID 号 }
    for I := 0 to J - 1 do
    begin
      intID := intID - StrToInt(FlstFilesCount.ValueFromIndex[I]);
    end;
    strDrive := FlstFilesCount.Names[J];
  end;

  { 获取文件全路径名称 }
  Result := GetFullFileName(strDrive + '_ntfs', intIndex, intID);
end;

{ 获取文件全路径名称 }
function TfrmSuperSearch.GetFullFileName(const strTabelName: String; const intIndex, intID: Integer; const bSearchFile: Boolean = False): string;
var
  I, Count   : Integer;
  strArrValue: TRawUTF8DynArray;
begin
  Count := FDatabase.Execute(RawUTF8(Format(c_strGetFullFileName, [strTabelName[1], intID, strTabelName[1], strTabelName[1], strTabelName[1], strTabelName[1]])), strArrValue);
  for I := 0 to Count - 1 do
  begin
    Result := UTF8ToString(strArrValue[I]) + '\' + Result;
  end;
  Result := strTabelName[1] + ':\' + LeftStr(Result, Length(Result) - 1);
end;

procedure TfrmSuperSearch.lvFilesData(Sender: TObject; Item: TListItem);
begin
  Item.Caption := Format('%0.8d', [Item.Index + 1]);
  Item.SubItems.Add(GetFullFileName(Item.Index + 1, FbSearchFile));
end;

procedure TfrmSuperSearch.srchbxFileNameInvokeSearch(Sender: TObject);
var
  I           : Integer;
  strTemp     : String;
  strDriveName: String;
  strSearch   : String;
begin
  { 还原到全部文件 }
  if Length(srchbxFileName.Text) = 0 then
  begin
    lvFiles.Items.Count := 0;
    DelayTime(500);
    lvFiles.Items.Count   := GetFilesCount;
    FbSearchFile          := False;
    mniFileCopyTo.Enabled := False;
    mniFileMoveTo.Enabled := False;
    Exit;
  end;

  if Length(srchbxFileName.Text) < 2 then
  begin
    MessageBox(Handle, '长度不得低于两位', '系统提示：', 64);
    Exit;
  end;

  { 将搜索结果保存到列表 }
  lblTip.Visible         := True;
  FbSearchFile           := True;
  strSearch              := '';
  lvFiles.Items.Count    := 0;
  srchbxFileName.Enabled := False;
  btnReSearch.Enabled    := False;
  DelayTime(500);
  try
    for I := 0 to FlstFilesCount.Count - 1 do
    begin
      strDriveName := FlstFilesCount.Names[I];
      strTemp      := Format('select id, id ||'';''|| %s as DriveValue from %s where filename like %s', [QuotedStr(strDriveName), strDriveName + '_ntfs', QuotedStr('%' + srchbxFileName.Text)]);
      strSearch    := strTemp + ' union ' + strSearch;
    end;
    strSearch           := System.SysUtils.Trim(strSearch);
    strSearch           := LeftStr(strSearch, Length(strSearch) - 5);
    strSearch           := 'select DriveValue, ROW_NUMBER() over(order by ID) as RowNum from (' + strSearch + ')';
    lvFiles.Items.Count := FDatabase.Execute(RawUTF8(strSearch), FstrArrSearchResult);
  finally
    srchbxFileName.Enabled := True;
    btnReSearch.Enabled    := True;
    lblTip.Visible         := False;
    mniFileCopyTo.Enabled  := True;
    mniFileMoveTo.Enabled  := True;
  end;
end;

procedure TfrmSuperSearch.srchbxFileNameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    srchbxFileName.OnInvokeSearch(nil);
end;

procedure TfrmSuperSearch.mnuFileOpenClick(Sender: TObject);
var
  strFileName: string;
begin
  if lvFiles.ItemIndex = -1 then
    Exit;

  strFileName := lvFiles.Selected.SubItems[0];
  ShellExecute(Handle, 'open', PChar(strFileName), nil, nil, SW_SHOW);
end;

{ --------------------------------------------------------------------------------------------------------------------------------------- }
{ ----------------------------------------------------------------- 文件操作 ------------------------------------------------------------ }
{ --------------------------------------------------------------------------------------------------------------------------------------- }

procedure TfrmSuperSearch.mniFilePosClick(Sender: TObject);
var
  strFileName: string;
begin
  if lvFiles.ItemIndex = -1 then
    Exit;

  strFileName := lvFiles.Selected.SubItems[0];
  OpenFolderAndSelectFile(strFileName);
end;

procedure TfrmSuperSearch.mniFileReNameClick(Sender: TObject);
var
  strFileName: string;
begin
  if lvFiles.ItemIndex = -1 then
    Exit;

  strFileName := lvFiles.Selected.SubItems[0];
  OpenFolderAndSelectFile(strFileName, True);
end;

procedure TfrmSuperSearch.mniFileAttrClick(Sender: TObject);
var
  strFileName: string;
begin
  if lvFiles.ItemIndex = -1 then
    Exit;

  strFileName := lvFiles.Selected.SubItems[0];
  ShowFileProperties(strFileName, GetMainFormHandle);
end;

procedure TfrmSuperSearch.mnuFileCopyToClick(Sender: TObject);
var
  strSavePath: String;
  strFileName: string;
  bOK        : Boolean;
begin
  if lvFiles.Items.Count = 0 then
    Exit;

  if not SelectDirectory('选择一个文件夹：', '', strSavePath, [], GetInstanceFromhWnd(GetMainFormHandle)) then
    Exit;

  strFileName := lvFiles.Selected.SubItems[0];
  bOK         := CopyFile(PChar(strFileName), PChar(strSavePath + '\' + ExtractFileName(strFileName)), False);
  MessageBox(GetMainFormHandle, PChar(Format('文件复制%s', [IfThen(bOK, '成功', '失败')])), c_strMsgTitle, 64);
end;

procedure TfrmSuperSearch.mniFileCopyToClick(Sender: TObject);
var
  I          : Integer;
  strSavePath: String;
  strFileName: string;
begin
  if lvFiles.Items.Count = 0 then
    Exit;

  if not SelectDirectory('选择一个文件夹：', '', strSavePath, [], GetInstanceFromhWnd(GetMainFormHandle)) then
    Exit;

  for I := 0 to lvFiles.Items.Count - 1 do
  begin
    strFileName := lvFiles.Items.Item[I].SubItems[0];
    CopyFile(PChar(strFileName), PChar(strSavePath + '\' + ExtractFileName(strFileName)), False);
  end;
  MessageBox(GetMainFormHandle, '所有文件复制完毕', c_strMsgTitle, 64);
end;

procedure TfrmSuperSearch.mniFileMoveToClick(Sender: TObject);
var
  I          : Integer;
  strSavePath: String;
  strFileName: string;
begin
  if lvFiles.Items.Count = 0 then
    Exit;

  if not SelectDirectory('选择一个文件夹：', '', strSavePath, [], GetInstanceFromhWnd(GetMainFormHandle)) then
    Exit;

  for I := 0 to lvFiles.Items.Count - 1 do
  begin
    strFileName := lvFiles.Items.Item[I].SubItems[0];
    MoveFile(PChar(strFileName), PChar(strSavePath + '\' + ExtractFileName(strFileName)));
  end;
  MessageBox(GetMainFormHandle, '所有文件移动完毕', c_strMsgTitle, 64);
end;

end.
