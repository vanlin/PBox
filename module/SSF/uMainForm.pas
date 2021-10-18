unit uMainForm;
{$WARN UNIT_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.IOUtils, System.Types, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.WinXCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  db.uCommon, SynSQLite3, SynSQLite3Static, SynCommons, uSearchDriveThread;

type
  TfrmSuperSearch = class(TForm)
    lvFiles: TListView;
    tmrStart: TTimer;
    procedure tmrStartTimer(Sender: TObject);
  private
    FintCount     : Integer;
    FDatabase     : TSQLDataBase;
    FintST, FintET: Cardinal;
    { 开始全盘文件搜索 }
    procedure StartSearchFiles;
    { 创建 Sqlite3 数据库 }
    procedure CreateSqliteDB;
    { 列表显示所有文件 }
    procedure ShowFilesList;
  protected
    { 单个磁盘文件搜索结束 }
    procedure SearchDriveFileFinished(var msg: TMessage); message WM_SearchDriveFileFinished;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmSuperSearch;
  strParentModuleName     := '系统管理';
  strModuleName           := '超级文件搜索';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

procedure TfrmSuperSearch.tmrStartTimer(Sender: TObject);
begin
  tmrStart.Enabled := False;
  StartSearchFiles;
end;

{ 创建 Sqlite3 数据库 }
procedure TfrmSuperSearch.CreateSqliteDB;
var
  // bExistDB            : Boolean;
  strSqlite3DBFileName: String;
begin
  strSqlite3DBFileName := ChangeFileExt(GetDllFullFileName, '.dat'); // 数据库保存文件
  // bExistDB             := FileExists(strSqlite3DBFileName);          // 数据库文件是否存在
  FDatabase := TSQLDataBase.Create(strSqlite3DBFileName);   // 创建 Sqlite3 数据库
  FDatabase.ExecuteNoException('PRAGMA synchronous = OFF'); // 关闭写同步，加快写入速度
  // if bExistDB then                                                   // 如果数据库已经存在
  // begin                                                              //
  // FDatabase.ExecuteNoException('DROP TABLE NTFS');                 // 删除表
  // end;                                                               //
  // FDatabase.ExecuteNoException(c_strCreateDriveTable);               // 创建表结构
  FDatabase.TransactionBegin(); // 开启事务，加快写入速度
end;

const
  c_strCreateDriveTable = 'CREATE TABLE %s_NTFS ([ID] INTEGER PRIMARY KEY, [FullFileName] VARCHAR (256));';

  { 开始全盘文件搜索 }
procedure TfrmSuperSearch.StartSearchFiles;
var
  lstDrives: System.Types.TStringDynArray;
  strDrive : String;
  sysFlags : DWORD;
  strNTFS  : array [0 .. 255] of Char;
  intLen   : DWORD;
begin
  FintCount := 0;
  CreateSqliteDB;
  Caption := '正在搜索，请稍候(预计5---10分钟)······';
  FintST  := GetTickCount;

  lstDrives := TDirectory.GetLogicalDrives;
  for strDrive in lstDrives do
  begin
    if not GetVolumeInformation(PChar(strDrive), nil, 0, nil, intLen, sysFlags, strNTFS, 256) then
      Continue;

    if not SameText(strNTFS, 'NTFS') then
      Continue;

    Inc(FintCount);
    FDatabase.ExecuteNoException(RawUTF8(Format(c_strCreateDriveTable, [strDrive[1]])));
    TSearchDrive.Create(AnsiChar(strDrive[1]), Handle, FDatabase.db);
  end;
end;

procedure TfrmSuperSearch.SearchDriveFileFinished(var msg: TMessage);
begin
  Dec(FintCount);

  { 所有搜索线程执行结束 }
  if FintCount = 0 then
  begin
    FDatabase.Commit;
    FintET  := GetTickCount;
    Caption := Format('搜索完毕，共计用时：%d 秒', [(FintET - FintST) div 1000]);
    ShowFilesList;
  end;
end;

{ 列表显示所有文件 }
procedure TfrmSuperSearch.ShowFilesList;
begin
  //
end;

end.
