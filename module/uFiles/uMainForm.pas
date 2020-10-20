unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Classes, System.IOUtils, System.Types, Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.WinXCtrls,
  Data.Win.ADODB, Data.db, SynSQLite3, SynSQLite3Static, SynCommons, db.uCommon;

type
  TfrmNTFSFiles = class(TForm)
    tmrSearchStart: TTimer;
    lvData: TListView;
    lblTip: TLabel;
    tmrSearchStop: TTimer;
    tmrGetFileFullNameStart: TTimer;
    srchbxFile: TSearchBox;
    ADOCNN: TADOConnection;
    btnReSearch: TButton;
    procedure tmrSearchStartTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvDataData(Sender: TObject; Item: TListItem);
    procedure tmrSearchStopTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure tmrGetFileFullNameStartTimer(Sender: TObject);
    procedure btnReSearchClick(Sender: TObject);
    procedure srchbxFileInvokeSearch(Sender: TObject);
  private
    FintStartTime             : Cardinal;
    FlstAllDrives             : TStringList;
    FintCount                 : Cardinal;
    FintSearchDriveThreadCount: Integer;
    FstrSqlite3DBFileName     : String;
    FstrSqlWhere              : String;
    FDatabase                 : TSQLDataBase;
    { 创建 Sqlite3 数据库 }
    procedure CreateSqlite3DB;
    { 开始搜索整个磁盘文件 }
    procedure SearchDrivesFiles;
    { 开始绘制数据列表 }
    procedure DrawDataItem;
  protected
    { 单个磁盘文件搜索结束 }
    procedure SearchDriveFileFinished(var msg: TMessage); message WM_SearchDriveFileFinished;
    { 获取文件全路径结束 }
    procedure GetFileFullNameFinished(var msg: TMessage); message WM_GetFileFullNameFinished;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

uses uThreadSearchDrive, uThreadGetFileFullName;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmNTFSFiles;
  strParentModuleName     := '系统管理';
  strModuleName           := 'NTFS 文件搜索';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

{ 开始绘制数据列表 }
procedure TfrmNTFSFiles.DrawDataItem;
begin
  if FstrSqlWhere = '' then
  begin
    lvData.Items.Count := FDatabase.ExecuteNoExceptionInt64(RawUTF8('select count(*) from ' + c_strResultTableName));
  end
  else
  begin
    { 创建查询临时表 }
    FDatabase.ExecuteNoException(RawUTF8('create table ' + c_strSearchTempTableName + ' as select * from ' + c_strResultTableName + ' where ' + FstrSqlWhere));
    lvData.Items.Count := FDatabase.ExecuteNoExceptionInt64(RawUTF8('select count(*) from ' + c_strSearchTempTableName));
  end;

  srchbxFile.Enabled  := True;
  btnReSearch.Enabled := True;
  lblTip.Visible      := False;
  Screen.Cursor       := crArrow;
end;

{ 开始获取文件全路径名称 }
procedure TfrmNTFSFiles.tmrGetFileFullNameStartTimer(Sender: TObject);
begin
  tmrGetFileFullNameStart.Enabled := False;
  lblTip.Caption                  := '正在获取文件全路径，请稍候······';
  lblTip.Left                     := (lblTip.Parent.Width - lblTip.Width) div 2;
end;

procedure TfrmNTFSFiles.tmrSearchStartTimer(Sender: TObject);
begin
  tmrSearchStart.Enabled := False;

  { 如果数据库文件存在，直接使用，就不在进行全盘扫描了 }
  FstrSqlite3DBFileName := ChangeFileExt(GetDllFullFileName, '.db');
  if FileExists(FstrSqlite3DBFileName) then
  begin
    FDatabase           := TSQLDataBase.Create(FstrSqlite3DBFileName);
    srchbxFile.Visible  := True;
    btnReSearch.Visible := True;
    DrawDataItem;
    Exit;
  end;

  { 开始搜索整个磁盘文件 }
  SearchDrivesFiles;
end;

procedure TfrmNTFSFiles.FormDestroy(Sender: TObject);
begin
  if FDatabase <> nil then
  begin
    FDatabase.DBClose;
    FDatabase.Free;
    FDatabase := nil;
  end;

  if FlstAllDrives <> nil then
    FlstAllDrives.Free;
end;

procedure TfrmNTFSFiles.btnReSearchClick(Sender: TObject);
begin
  btnReSearch.Visible := False;
  srchbxFile.Visible  := False;
  lvData.Items.Count  := 0;
  lblTip.Caption      := '正在搜索，请稍候······';
  lblTip.Visible      := True;

  { 开始搜索整个磁盘文件 }
  SearchDrivesFiles;
end;

{ 创建 Sqlite3 数据库 }
procedure TfrmNTFSFiles.CreateSqlite3DB;
const
  c_strCreateDriveTable = 'CREATE TABLE NTFS ([ID] INTEGER PRIMARY KEY, [Drive] VARCHAR(1), [FileID_HI] INTEGER NULL, [FileID_LO] INTEGER NULL, [FilePID_HI] INTEGER NULL, [FilePID_LO] INTEGER NULL, [FileName] VARCHAR (255), [FullName] VARCHAR (255));';
var
  bExistDB: Boolean;
begin
  FstrSqlWhere := '';
  bExistDB     := FileExists(FstrSqlite3DBFileName);
  FDatabase    := TSQLDataBase.Create(FstrSqlite3DBFileName);
  FDatabase.ExecuteNoException('PRAGMA synchronous = OFF');             // 关闭写同步，加快写入速度
  if bExistDB then                                                      // 如果数据库已经存在
  begin                                                                 //
    FDatabase.ExecuteNoException('DROP TABLE NTFS');                    // 删除表
    FDatabase.ExecuteNoException('DROP TABLE ' + c_strResultTableName); // 删除表
  end;                                                                  //
  FDatabase.ExecuteNoException(c_strCreateDriveTable);                  // 创建表结构

  { 开启事务，加快写入速度 }
  FDatabase.TransactionBegin();
end;

{ 开始搜索整个磁盘文件 }
procedure TfrmNTFSFiles.SearchDrivesFiles;
var
  strDrive: String;
  lstDrive: System.Types.TStringDynArray;
  sysFlags: DWORD;
  strNTFS : array [0 .. 255] of Char;
  intLen  : DWORD;
  I       : Integer;
begin
  { 创建数据库 }
  CreateSqlite3DB;

  { 初始化成员变量 }
  FintCount                  := 0;
  FintSearchDriveThreadCount := 0;
  FlstAllDrives              := TStringList.Create;
  lblTip.Visible             := True;

  { 将所有 NTFS 类型盘符加入到待搜索列表 }
  lstDrive := TDirectory.GetLogicalDrives;
  for strDrive in lstDrive do
  begin
    if not GetVolumeInformation(PChar(strDrive), nil, 0, nil, intLen, sysFlags, strNTFS, 256) then
      Continue;

    if not SameText(strNTFS, 'NTFS') then
      Continue;

    FlstAllDrives.Add(strDrive[1]);
  end;

  if FlstAllDrives.Count = 0 then
    Exit;

  FintSearchDriveThreadCount := FlstAllDrives.Count;
  FintStartTime              := GetTickCount;

  { 多线程搜索所有 NTFS 磁盘所有文件 }
  for I := 0 to FlstAllDrives.Count - 1 do
  begin
    TSearchThread.Create(AnsiChar(FlstAllDrives.Strings[I][1]), Handle, FDatabase.db);
  end;

  { 检查所有搜索线程是否结束 }
  tmrSearchStop.Enabled := True;
end;

{ 检查所有搜索线程是否结束 }
procedure TfrmNTFSFiles.tmrSearchStopTimer(Sender: TObject);
begin
  if FintSearchDriveThreadCount <> 0 then
    Exit;

  { 所有搜索线程执行结束 }
  tmrSearchStop.Enabled := False;
  FDatabase.Commit;
  lblTip.Caption                  := Format('合计文件(%s)：%d，合计用时：%d秒', [FlstAllDrives.DelimitedText, FintCount, (GetTickCount - FintStartTime) div 1000 - 1]);
  tmrGetFileFullNameStart.Enabled := True;

  { 所有搜索线程结束后，再获取磁盘文件的全路径文件名称 }
  TGetFileFullNameThread.Create(FlstAllDrives, Handle, FDatabase);
end;

{ 获取文件全路径结束 }
procedure TfrmNTFSFiles.GetFileFullNameFinished(var msg: TMessage);
begin
  srchbxFile.Visible  := True;
  btnReSearch.Visible := True;
  lblTip.Visible      := False;
  DrawDataItem;
end;

{ 单个磁盘文件搜索结束 }
procedure TfrmNTFSFiles.SearchDriveFileFinished(var msg: TMessage);
begin
  Dec(FintSearchDriveThreadCount);

  FintCount      := FintCount + msg.WParam;
  lblTip.Caption := string(PChar(msg.LParam));
  lblTip.Left    := (lblTip.Parent.Width - lblTip.Width) div 2;
end;

procedure TfrmNTFSFiles.FormResize(Sender: TObject);
begin
  lblTip.Left := (lblTip.Parent.Width - lblTip.Width) div 2;
end;

{ 绘制数据 }
procedure TfrmNTFSFiles.lvDataData(Sender: TObject; Item: TListItem);
var
  strSQL      : String;
  strValue    : String;
  strTableName: String;
begin
  strTableName := IfThen(FstrSqlWhere = '', c_strResultTableName, c_strSearchTempTableName);
  strSQL       := 'select FullName from ' + strTableName + ' where RowID=' + IntToStr(Item.Index + 1);
  strValue     := UTF8ToString(FDatabase.ExecuteNoExceptionUTF8(RawUTF8(strSQL)));
  Item.Caption := Format('%.10u', [Item.Index + 1]);
  Item.SubItems.Add(strValue);
end;

procedure TfrmNTFSFiles.srchbxFileInvokeSearch(Sender: TObject);
begin
  lvData.Items.Count  := 0;
  srchbxFile.Enabled  := False;
  btnReSearch.Enabled := False;
  FDatabase.ExecuteNoException('DROP TABLE ' + c_strSearchTempTableName);
  Screen.Cursor  := crSQLWait;
  lblTip.Caption := '正在搜索，请稍候······';
  lblTip.Visible := True;
  DelayTime(500);

  if (System.SysUtils.Trim(srchbxFile.Text) = '') or (Length(srchbxFile.Text) < 2) then
    FstrSqlWhere := ''
  else
    FstrSqlWhere := 'FullName like ' + QuotedStr('%' + srchbxFile.Text + '%');

  DrawDataItem;
end;

end.
