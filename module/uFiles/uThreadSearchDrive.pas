unit uThreadSearchDrive;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, SynSQLite3, SynCommons, DB.uCommon;

type
  TSearchThread = class(TThread)
  private
    FchrDrive      : AnsiChar;
    FMainFormHandle: THandle;
    FDataBase      : TSQLite3DB;
    FsrInsert      : TSQLRequest;
    procedure GetUSNFileInfo(UsnInfo: PUSN);
  protected
    procedure Execute; override;
  public
    constructor Create(const chrDrive: AnsiChar; const MainFormHandle: THandle; DataBase: TSQLite3DB); overload;
  end;

implementation

{ TSearchThread }

const
  c_strInsertSQL: RawUTF8 = 'INSERT INTO NTFS (ID, Drive, FileID_HI, FileID_LO, FilePID_HI, FilePID_LO, FileName) VALUES(NULL,?,?,?,?,?,?)';

constructor TSearchThread.Create(const chrDrive: AnsiChar; const MainFormHandle: THandle; DataBase: TSQLite3DB);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FchrDrive       := chrDrive;
  FMainFormHandle := MainFormHandle;
  FDataBase       := DataBase;
  FsrInsert.Prepare(FDataBase, c_strInsertSQL);
end;

procedure TSearchThread.GetUSNFileInfo(UsnInfo: PUSN);
var
  intFileID  : Int64Rec;
  intFilePID : Int64Rec;
  strFileName: String;
begin
  { 因为 sqlite3 不支持 UINT64，所以只好将 UINT64 拆分为俩个 UINT32，即两个 Cardinal；多了两个字段，效率小有影响 }
  intFileID   := UsnInfo^.FileReferenceNumber;
  intFilePID  := UsnInfo^.ParentFileReferenceNumber;
  strFileName := PWideChar(Integer(UsnInfo) + UsnInfo^.FileNameOffset);
  strFileName := Copy(strFileName, 1, UsnInfo^.FileNameLength div 2);
  FsrInsert.Reset;
  FsrInsert.Bind(1, FchrDrive);
  FsrInsert.Bind(2, intFileID.Hi);
  FsrInsert.Bind(3, intFileID.Lo);
  FsrInsert.Bind(4, intFilePID.Hi);
  FsrInsert.Bind(5, intFilePID.Lo);
  FsrInsert.Bind(6, RawUTF8(strFileName));
  FsrInsert.Step;
end;

procedure TSearchThread.Execute;
var
  cjd         : CREATE_USN_JOURNAL_DATA;
  ujd         : USN_JOURNAL_DATA;
  djd         : DELETE_USN_JOURNAL_DATA;
  dwRet       : DWORD;
  int64Size   : Integer;
  BufferOut   : array [0 .. BUF_LEN - 1] of Char;
  BufferIn    : MFT_ENUM_DATA;
  UsnInfo     : PUSN;
  hRootHandle : THandle;
  intST, intET: Cardinal;
  strTip      : String;
  intCount    : Integer;
begin
  hRootHandle := CreateFile(PChar('\\.\' + FchrDrive + ':'), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  if hRootHandle = ERROR_INVALID_HANDLE then
    Exit;

  intST    := GetTickCount;
  intCount := 0;
  try
    { 初始化USN日志文件 }
    if not DeviceIoControl(hRootHandle, FSCTL_CREATE_USN_JOURNAL, @cjd, SizeOf(cjd), nil, 0, dwRet, nil) then
      Exit;

    { 获取USN日志基本信息 }
    if not DeviceIoControl(hRootHandle, FSCTL_QUERY_USN_JOURNAL, nil, 0, @ujd, SizeOf(ujd), dwRet, nil) then
      Exit;

    { 枚举USN日志文件中的所有记录 }
    int64Size                         := SizeOf(Int64);
    BufferIn.StartFileReferenceNumber := 0;
    BufferIn.LowUsn                   := 0;
    BufferIn.HighUsn                  := ujd.NextUsn;
    while DeviceIoControl(hRootHandle, FSCTL_ENUM_USN_DATA, @BufferIn, SizeOf(BufferIn), @BufferOut, BUF_LEN, dwRet, nil) do
    begin
      { 找到第一个 USN 记录 }
      dwRet   := dwRet - Cardinal(int64Size);
      UsnInfo := PUSN(Integer(@(BufferOut)) + int64Size);
      while dwRet > 0 do
      begin
        { 获取文件信息 }
        GetUSNFileInfo(UsnInfo);
        Inc(intCount);

        { 获取下一个 USN 记录 }
        Dec(dwRet, UsnInfo.RecordLength);
        UsnInfo := PUSN(Cardinal(UsnInfo) + UsnInfo.RecordLength);
      end;
      Move(BufferOut, BufferIn, int64Size);
    end;

    { 删除USN日志文件信息 }
    djd.UsnJournalID := ujd.UsnJournalID;
    djd.DeleteFlags  := USN_DELETE_FLAG_DELETE;
    DeviceIoControl(hRootHandle, FSCTL_DELETE_USN_JOURNAL, @djd, SizeOf(djd), nil, 0, dwRet, nil);
  finally
    CloseHandle(hRootHandle);
    intET  := GetTickCount;
    strTip := FchrDrive + ':\，文件总数：' + IntToStr(intCount) + '，搜索用时：' + IntToStr((intET - intST) div 1000) + '秒';
    SendMessage(FMainFormHandle, WM_SEARCHDRIVEFILEFINISHED, intCount, Integer(PChar(strTip)));
  end;
end;

end.
