unit db.uTSDFS;
{
  功能：以 USN 的方式获取单个逻辑磁盘的全部文件
  时间：202-10-01
  作者：dbyuong@sina.com
  QQ群：101611228
}

interface

uses Winapi.Windows, System.Math, System.Classes, System.SysUtils, SynSQLite3, SynCommons, db.uCommon;

type
  TThreadGetFiles = class(TThread)
  private
    FchrDrive : Char;
    FhMainForm: THandle;
    FDataBase : TSQLDataBase;
    FsrInsert : TSQLRequest;
    procedure GetUSNFileInfo(UsnInfo: PUSN);
  protected
    procedure Execute; override;
  public
    constructor Create(const hMainForm: THandle; const chrDrive: Char; DataBase: TSQLDataBase); overload;
  end;

implementation

{ TThreadGetFiles }

constructor TThreadGetFiles.Create(const hMainForm: THandle; const chrDrive: Char; DataBase: TSQLDataBase);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  Priority        := tpTimeCritical;
  FhMainForm      := hMainForm;
  FchrDrive       := chrDrive;
  FDataBase       := DataBase;
  FsrInsert.Prepare(FDataBase.db, RawUTF8(Format(c_strInsertFiles, [FchrDrive])));
end;

procedure TThreadGetFiles.GetUSNFileInfo(UsnInfo: PUSN);
var
  intFileID  : Int64Rec;
  intFilePID : Int64Rec;
  strFileName: String;
begin
  intFileID   := UsnInfo^.FileReferenceNumber;
  intFilePID  := UsnInfo^.ParentFileReferenceNumber;
  strFileName := PWideChar(Integer(UsnInfo) + UsnInfo^.FileNameOffset);
  strFileName := Copy(strFileName, 1, UsnInfo^.FileNameLength div 2);

  FsrInsert.Reset;
  FsrInsert.Bind(1, intFileID.Hi);
  FsrInsert.Bind(2, intFileID.Lo);
  FsrInsert.Bind(3, intFilePID.Hi);
  FsrInsert.Bind(4, intFilePID.Lo);
  FsrInsert.Bind(5, RawUTF8(strFileName));
  FsrInsert.Step;
end;

procedure TThreadGetFiles.Execute;
  procedure MyMove(const Source; var Dest; Count: NativeInt); assembler;
  asm
    FILD    QWORD PTR [EAX]
    FISTP   QWORD PTR [EDX]
  end;
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
  intCount    : Integer;
  strTip      : String;
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
        Inc(intCount);
        GetUSNFileInfo(UsnInfo);

        { 获取下一个 USN 记录 }
        Dec(dwRet, UsnInfo.RecordLength);
        UsnInfo := PUSN(Cardinal(UsnInfo) + UsnInfo.RecordLength);
      end;
      MyMove(BufferOut, BufferIn, int64Size);
    end;

    { 删除USN日志文件信息 }
    djd.UsnJournalID := ujd.UsnJournalID;
    djd.DeleteFlags  := USN_DELETE_FLAG_DELETE;
    DeviceIoControl(hRootHandle, FSCTL_DELETE_USN_JOURNAL, @djd, SizeOf(djd), nil, 0, dwRet, nil);
  finally
    CloseHandle(hRootHandle);
    intET  := GetTickCount;
    strTip := Format('%s:\ 盘符，文件总数：%0.8d，搜索用时：%0.3d 秒。', [FchrDrive, intCount, (intET - intST) div 1000]);
    SendMessage(FhMainForm, WM_SEARCHDRIVEFILEFINISHED, Integer(PChar(FchrDrive + '=' + IntToStr(intCount))), Integer(PChar(strTip)));
  end;
end;

end.
