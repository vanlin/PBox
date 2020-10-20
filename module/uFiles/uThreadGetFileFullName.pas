unit uThreadGetFileFullName;

interface

uses
  Winapi.Windows, System.SysUtils, System.StrUtils, System.Classes, SynCommons, SynSQLite3, db.uCommon;

type
  TGetFileFullNameThread = class(TThread)
  private
    FlstDrive      : TStringList;
    FMainFormHandle: THandle;
    FSQLDataBase   : TSQLDataBase;
  protected
    procedure Execute; override;
  public
    constructor Create(const lstDrive: TStringList; const MainFormHandle: THandle; SqlDataBase: TSQLDataBase); overload;
  end;

implementation

{ TGetFileFullThread }

const
  { 获取文件全路径名称 <单个盘符> }
  c_strGetFullFileName =                                                                                                                                                                                                              //
    'select * from ' +                                                                                                                                                                                                                //
    ' ( ' +                                                                                                                                                                                                                           //
    '   with recursive TempTable(ID, FileID_HI, FileID_LO, FilePID_HI, FilePID_LO, FILENAME) AS ' +                                                                                                                                   //
    '   ( ' +                                                                                                                                                                                                                         //
    '     select ID, FileID_HI, FileID_LO, FilePID_HI, FilePID_LO, FileName from NTFS where FILEPID_HI = 0x50000 and FilePID_LO=5 and Drive=%s ' +                                                                                    //
    '     union all ' +                                                                                                                                                                                                               //
    '     select a.ID, a.FileID_HI, a.FileID_LO, a.FilePID_HI, a.FilePID_LO, b.FileName || ''\'' || a.FileName from NTFS a inner join TempTable b on (a.FilePID_HI = b.FileID_HI and a.FilePID_LO = b.FileID_LO) where a.Drive=%s ' + //
    '   ) select ID, %s || FileName as FullName from TempTable order by FullName ' +                                                                                                                                                  // //
    ' ) ';

constructor TGetFileFullNameThread.Create(const lstDrive: TStringList; const MainFormHandle: THandle; SqlDataBase: TSQLDataBase);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FlstDrive       := lstDrive;
  FMainFormHandle := MainFormHandle;
  FSQLDataBase    := SqlDataBase;
end;

{ 获取文件的全路径名称 <全部盘符> }
procedure TGetFileFullNameThread.Execute;
var
  I       : Integer;
  chrDrive: Char;
  strSQL  : string;
begin
  strSQL := '';
  for I  := 0 to FlstDrive.Count - 1 do
  begin
    chrDrive := FlstDrive.Strings[I][1];
    strSQL   := strSQL + Format(c_strGetFullFileName, [QuotedStr(chrDrive), QuotedStr(chrDrive), QuotedStr(chrDrive + ':\')]) + ' union all ';
  end;
  strSQL := LeftStr(strSQL, Length(strSQL) - 11);
  strSQL := 'create table ' + c_strResultTableName + ' as select * from (' + strSQL + ' )';
  FSQLDataBase.ExecuteNoException(RawUTF8(strSQL));
  FSQLDataBase.ExecuteNoException('DROP TABLE NTFS');
  SendMessage(FMainFormHandle, WM_GETFILEFULLNAMEFINISHED, 0, 0);
end;

end.
