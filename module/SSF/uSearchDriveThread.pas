unit uSearchDriveThread;

interface

uses Winapi.Windows, System.Classes, System.SysUtils, SynSQLite3, SynCommons, NtUtils, NTapi.ntioapi, NTapi.ntdef, NtUtils.Files, DelphiUtils.AutoObjects, db.uCommon;

type
  TSearchDrive = class(TThread)
  private
    FchrDrive      : AnsiChar;
    FMainFormHandle: THandle;
    FDataBase      : TSQLite3DB;
    FsrInsert      : TSQLRequest;
    procedure GetUSNFileInfo(UsnInfo: PUSN; hVol: THandle);
    function GetFullPathName(hVol: THandle; intFileID: UInt64): String; inline;
  protected
    procedure Execute; override;
  public
    constructor Create(const chrDrive: AnsiChar; const MainFormHandle: THandle; DataBase: TSQLite3DB); overload;
  end;

implementation

{ TSearchDrive }

const
  c_strInsertSQL = 'INSERT INTO %s_NTFS (ID, FullFileName) VALUES(NULL, ?)';

constructor TSearchDrive.Create(const chrDrive: AnsiChar; const MainFormHandle: THandle; DataBase: TSQLite3DB);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FchrDrive       := chrDrive;
  FMainFormHandle := MainFormHandle;
  FDataBase       := DataBase;
  FsrInsert.Prepare(FDataBase, RawUTF8(Format(c_strInsertSQL, [FchrDrive])));
end;

procedure MyMove(const Source; var Dest; Count: NativeInt); assembler;
asm
  FILD    QWORD PTR [EAX]
  FISTP   QWORD PTR [EDX]
end;

function TSearchDrive.GetFullPathName(hVol: THandle; intFileID: UInt64): String;
var
  hFile   : IHandle;
  ddd     : TNtxStatus;
  IoStatus: TIoStatusBlock;
  Buffer  : array [0 .. 255] of Char;
  status  : NTSTATUS;
begin
  Result := '';
  ddd    := NtxOpenFileById(hFile, $00000040, intFileID, hVol, FILE_SHARE_ALL, FILE_OPEN_BY_FILE_ID, 0);
  if ddd.IsSuccess then
  begin
    status := NtQueryInformationFile(hFile.Handle, @IoStatus, @Buffer[0], 256, FileNameInformation);
    if status = 0 then
    begin
      SetString(Result, PChar(@Buffer[2]), PDWORD(@Buffer[0])^ div SizeOf(WideChar));
      Result := FchrDrive + ':' + Result;
    end;
  end;
end;

procedure TSearchDrive.GetUSNFileInfo(UsnInfo: PUSN; hVol: THandle);
var
  strFullFileName: String;
begin
  strFullFileName := GetFullPathName(hVol, UsnInfo^.FileReferenceNumber);
  if strFullFileName <> '' then
  begin
    FsrInsert.Reset;
    FsrInsert.Bind(1, RawUTF8(strFullFileName));
    FsrInsert.Step;
  end;
end;

procedure TSearchDrive.Execute;
var
  cjd        : CREATE_USN_JOURNAL_DATA;
  ujd        : USN_JOURNAL_DATA;
  djd        : DELETE_USN_JOURNAL_DATA;
  dwRet      : DWORD;
  int64Size  : Integer;
  BufferOut  : array [0 .. BUF_LEN - 1] of Char;
  BufferIn   : MFT_ENUM_DATA;
  UsnInfo    : PUSN;
  hRootHandle: THandle;
begin
  hRootHandle := CreateFile(PChar('\\.\' + FchrDrive + ':'), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  if hRootHandle = ERROR_INVALID_HANDLE then
    Exit;

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
        GetUSNFileInfo(UsnInfo, hRootHandle);

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
    SendMessage(FMainFormHandle, WM_SEARCHDRIVEFILEFINISHED, 0, 0);
  end;
end;

end.
