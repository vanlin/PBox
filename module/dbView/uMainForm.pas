unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Variants, System.Classes, System.Win.Registry, System.IniFiles, System.Types, System.IOUtils, System.JSON, System.Generics.Collections,
  Data.Win.ADODB, Data.db, Data.Win.ADOConEd, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.FileCtrl, Vcl.Clipbrd, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.CheckLst,
  XLSReadWriteII5, Xc12Utils5, XLSUtils5, Xc12DataStyleSheet5, SynSQLite3Static, mORMotSQLite3, SynSQLite3, SynCommons, SynTable, mORMot, db.uCommon,
  Vcl.Menus;

type
  TfrmdbView = class(TForm)
    btnConnect: TButton;
    grpTables: TGroupBox;
    grpFields: TGroupBox;
    grpView: TGroupBox;
    btnSQL: TButton;
    btnExportExcel: TButton;
    lvData: TListView;
    lstTables: TListBox;
    lvFields: TListView;
    ADOCNN: TADOConnection;
    qryTemp: TADOQuery;
    qryFieldChineseName: TADOQuery;
    btnSearch: TButton;
    qryData: TADOQuery;
    dlgSaveExcel: TSaveDialog;
    pmDatabaseType: TPopupMenu;
    mniODBC: TMenuItem;
    mniSqlite: TMenuItem;
    dlgOpenSqliteDB: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure lstTablesClick(Sender: TObject);
    procedure lvDataData(Sender: TObject; Item: TListItem);
    procedure lvFieldsDrawItem(Sender: TCustomListView; Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure lvFieldsClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnExportExcelClick(Sender: TObject);
    procedure btnSQLClick(Sender: TObject);
    procedure mniSqliteClick(Sender: TObject);
  private
    FbAutoField: Boolean;
    FbSearch   : Boolean;
    FbSqlite3  : Boolean;
    FSqlite3DB : TSQLDatabase;
    { 保存数据库连接字符串 }
    procedure SaveDBLINK;
    { 读取数据库连接字符串 }
    function ReadDBLINK: String;
    { 获取 ODBC 数据库中所有表 }
    procedure GetAllTables_ODBC;
    { 获取 SQLITE3 数据库中所有表名 }
    procedure GetAllTables_Sqlite3;
    { 获取 ODBC 表结构信息 }
    procedure GetTableFieldsInfo_ODBC(const strTableName: string);
    { 获取 Sqlite3 表结构信息 }
    procedure GetTableFieldsInfo_Sqlite3(const strTableName: string);
    { 获取 ODBC 表所有数据 }
    procedure GetTableDataInfo_ODBC(const strTableName: string);
    { 获取 Sqlite3 表所有数据 }
    procedure GetTableDataInfo_Sqlite3(const strTableName: string);
    { 获取字段类型 }
    function GetFieldType(const strTableName, strFieldName: string): String;
    { 获取字段中文名称 }
    function GetFieldChineseName(const strFieldName: string): String;
    { 获取自动增长字段 }
    function GetAutoFieldName(const strTableName: String; var strAutoField: string): Boolean;
    { 获取显示字段 }
    function GetDispFieldsList: String;
    { 创建数据显示列 }
    procedure CreateColumnDispField;
    { 显示搜索结果 }
    procedure ShowSearchResult;
    function GetSqliteFieldDataType(const strFieldType: string): string;
  protected
    { 执行 SQL 查询 }
    procedure WMEXECSQL(var msg: TMessage); message WM_EXECSQL;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

uses uSQLForm;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmdbView;
  strParentModuleName     := '数据库工具';
  strModuleName           := 'dbView';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

procedure TfrmdbView.lvFieldsDrawItem(Sender: TCustomListView; Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  bDisplay: Boolean;
  bmpCheck: TBitmap;
  rct     : TRect;
  strTmp  : String;
  I       : Integer;
begin
  bDisplay := Item.Caption = '1';
  rct      := Item.DisplayRect(drBounds);

  bmpCheck := TBitmap.Create;
  try
    bmpCheck.PixelFormat := pf24bit;
    bmpCheck.Width       := 15;
    bmpCheck.Height      := 15;
    bmpCheck.LoadFromResourceName(HInstance, IfThen(bDisplay, 'CHECK', 'UNCHECK'));
    TListView(Sender).Canvas.Draw(rct.Left + 4, rct.Top + 2, bmpCheck);
  finally
    bmpCheck.Free;
  end;

  for I := 0 to Item.SubItems.Count - 1 do
  begin
    strTmp    := Item.SubItems.Strings[I];
    rct.Left  := rct.Left + lvFields.Column[I + 0].Width + 2;
    rct.Right := rct.Left + lvFields.Column[I + 1].Width;
    TListView(Sender).Canvas.TextRect(rct, strTmp, [tfLeft, tfSingleLine, tfVerticalCenter]);
  end;
end;

procedure TfrmdbView.lvFieldsClick(Sender: TObject);
begin
  if lvFields.ItemIndex = -1 then
    Exit;

  if (lvFields.Items[lvFields.ItemIndex].SubItems[1] = '二进制') or (lvFields.Items[lvFields.ItemIndex].SubItems[1] = '未知') then
    Exit;

  if lvFields.Items[lvFields.ItemIndex].Caption = '1' then
    lvFields.Items[lvFields.ItemIndex].Caption := '0'
  else
    lvFields.Items[lvFields.ItemIndex].Caption := '1';
end;

{ 读取数据库连接字符串 }
function TfrmdbView.ReadDBLINK: String;
var
  strFileName: String;
begin
  strFileName := ChangeFileExt(GetDllFullFileName, '.ini');
  with TIniFile.Create(strFileName) do
  begin
    Result := ReadString('DB', ' LINK ', ADOCNN.ConnectionString);
    Free;
  end;
end;

{ 保存数据库连接字符串 }
procedure TfrmdbView.SaveDBLINK;
var
  strFileName: String;
begin
  strFileName := ChangeFileExt(GetDllFullFileName, '.ini');
  with TIniFile.Create(strFileName) do
  begin
    if not FbSqlite3 then
      WriteString('DB', 'LINK', ADOCNN.ConnectionString)
    else
      WriteString('DB', 'LINK', FSqlite3DB.FileName);
    Free;
  end;
end;

procedure TfrmdbView.btnConnectClick(Sender: TObject);
begin
  if not EditConnectionString(ADOCNN) then
    Exit;

  if not TryLinkDataBase(ADOCNN.ConnectionString, ADOCNN) then
    Exit;

  FbSqlite3 := False;

  { 保存数据库连接字符串 }
  SaveDBLINK;

  { 获取所有表 }
  GetAllTables_ODBC;
end;

procedure TfrmdbView.FormCreate(Sender: TObject);
begin
  FbSearch := False;
  if g_ADOCNN <> nil then
  begin
    if g_ADOCNN.Connected then
    begin
      ADOCNN             := g_ADOCNN;
      btnConnect.Caption := '重新创建数据库连接';
      GetAllTables_ODBC;
    end;
  end
  else
  begin
    { 从配置文件中，读取数据库连接字符串 }
    if ReadDBLINK <> '' then
    begin
      if ExtractFileExt(ReadDBLINK) = '.db' then
      begin

      end
      else
      begin
        if not TryLinkDataBase(ReadDBLINK, ADOCNN) then
          Exit;

        btnConnect.Caption := '重新创建数据库连接';
        GetAllTables_ODBC;
      end;
    end;
  end;
end;

{ 获取 ODBC 数据库中所有表 }
procedure TfrmdbView.GetAllTables_ODBC;
begin
  lstTables.Clear;
  lvFields.Clear;
  lvData.Items.Count := 0;
  lvData.Columns.Clear;
  ADOCNN.GetTableNames(lstTables.Items);
end;

function TfrmdbView.GetSqliteFieldDataType(const strFieldType: string): string;
var
  strUpper: String;
begin
  strUpper := System.SysUtils.UpperCase(strFieldType);
  if Pos('VARCHAR', strUpper) > 0 then
    Result := '字符串'
  else if Pos('TEXT', strUpper) > 0 then
    Result := '字符串'
  else if Pos('CHAR(', strUpper) > 0 then
    Result := '字符串'
  else if Pos('INTEGER', strUpper) > 0 then
    Result := '整数'
  else if Pos('INT', strUpper) > 0 then
    Result := '整数'
  else if Pos('BIGINT', strUpper) > 0 then
    Result := '整数'
  else
    Result := '二进制';
end;

{ 获取 Sqlite3 表结构信息 }
procedure TfrmdbView.GetTableFieldsInfo_Sqlite3(const strTableName: string);
var
  strFieldName: String;
  strFieldType: String;
  I           : Integer;
  strJson     : RawUTF8;
  jsn         : TJSONArray;
begin
  strJson := FSqlite3DB.ExecuteJSON(RawUTF8('PRAGMA table_info(' + QuotedStr(strTableName) + ')'), True);
  lvFields.Clear;
  jsn := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(string(strJson)), 0) as TJSONArray;
  try
    if jsn.Count > 0 then
    begin
      for I := 0 to jsn.Count - 1 do
      begin
        strFieldName := jsn.Items[I].GetValue<String>('name');
        strFieldType := jsn.Items[I].GetValue<String>('type');
        with lvFields.Items.Add do
        begin
          Caption := '1';
          SubItems.Add(strFieldName);
          SubItems.Add(GetSqliteFieldDataType(strFieldType));
          SubItems.Add('');
        end;
      end;
    end;
  finally
    jsn.Free;
  end;
end;

{ 获取 Sqlite3 表所有数据 }
procedure TfrmdbView.GetTableDataInfo_Sqlite3(const strTableName: string);
begin
  CreateColumnDispField;
  lvData.Items.Count := FSqlite3DB.ExecuteNoExceptionInt64(RawUTF8('select count(*) from ' + strTableName));
end;

procedure TfrmdbView.lstTablesClick(Sender: TObject);
begin
  if lstTables.ItemIndex < 0 then
    Exit;

  if NOT FbSqlite3 then
  begin
    { 获取 ODBC 表结构信息 }
    GetTableFieldsInfo_ODBC(lstTables.Items[lstTables.ItemIndex]);

    { 获取 ODBC 表所有数据 }
    GetTableDataInfo_ODBC(lstTables.Items[lstTables.ItemIndex]);
  end
  else
  begin
    { 获取 Sqlite3 表结构信息 }
    GetTableFieldsInfo_Sqlite3(lstTables.Items[lstTables.ItemIndex]);

    { 获取 Sqlite3 表所有数据 }
    GetTableDataInfo_Sqlite3(lstTables.Items[lstTables.ItemIndex]);
  end;
end;

{ 获取字段类型 }
function TfrmdbView.GetFieldType(const strTableName, strFieldName: string): String;
var
  ft: TFieldType;
begin
  ft := qryTemp.FieldByName(strFieldName).DataType;
  if ft in [ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftADT, ftLongWord, ftShortint, ftByte] then
    Result := '整数'
  else if ft in [ftString, ftFixedChar, ftWideString, ftFixedWideChar] then
    Result := '字符串'
  else if ft = ftBoolean then
    Result := '布尔'
  else if ft in [Data.db.ftFloat, Data.db.ftCurrency, Data.db.ftBCD, Data.db.ftExtended, Data.db.ftSingle] then
    Result := '浮点数'
  else if ft in [Data.db.ftDate, Data.db.ftTime, Data.db.ftDateTime] then
    Result := '日期'
  else if ft in [ftBytes, ftVarBytes, ftArray] then
    Result := '整数数组'
  else if ft = ftBoolean then
    Result := '布尔'
  else if ft in [Data.db.ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftWideMemo, ftObject] then
    Result := '二进制'
  else
    Result := '未知'
end;

{ 获取字段中文名称 }
function TfrmdbView.GetFieldChineseName(const strFieldName: string): String;
begin
  if qryFieldChineseName.Locate('字段名', strFieldName, []) then
  begin
    Result := qryFieldChineseName.Fields[1].AsString;
  end
  else
  begin
    Result := '';
  end;
end;

{ 获取 ODBC 表结构信息 }
procedure TfrmdbView.GetTableFieldsInfo_ODBC(const strTableName: string);
const
  c_strFieldChineseName =                                                                                   //
    ' SELECT c.[name] AS 字段名, cast(ep.[value] as varchar(100)) AS [字段说明] FROM sys.tables AS t' +            //
    ' INNER JOIN sys.columns AS c ON t.object_id = c.object_id' +                                           //
    ' LEFT JOIN sys.extended_properties AS ep ON ep.major_id = c.object_id AND ep.minor_id = c.column_id' + //
    ' WHERE ep.class = 1 AND t.name=%s';
var
  lstFields          : TStringList;
  I                  : Integer;
  strFieldName       : String;
  strFieldType       : String;
  strFieldChineseName: String;
begin
  qryTemp.Close;
  qryTemp.SQL.Clear;
  qryTemp.SQL.Text := 'select * from ' + strTableName + ' where 0=1';
  qryTemp.Open;

  qryFieldChineseName.Close;
  qryFieldChineseName.SQL.Clear;
  qryFieldChineseName.SQL.Text := Format(c_strFieldChineseName, [QuotedStr(strTableName)]);
  qryFieldChineseName.Open;

  lvFields.Clear;
  lvFields.Items.BeginUpdate;
  lstFields := TStringList.Create;
  try
    ADOCNN.GetFieldNames(strTableName, lstFields);
    for I := 0 to lstFields.Count - 1 do
    begin
      strFieldName        := lstFields.Strings[I];
      strFieldType        := GetFieldType(strTableName, strFieldName);
      strFieldChineseName := GetFieldChineseName(strFieldName);
      with lvFields.Items.Add do
      begin
        Caption := IfThen((strFieldType = '二进制') or (strFieldType = '未知'), '0', '1');
        SubItems.Add(strFieldName);
        SubItems.Add(strFieldType);
        SubItems.Add(strFieldChineseName);
      end;
    end;
  finally
    lvFields.Items.EndUpdate;
    lstFields.Free;
  end;
end;

{ 获取显示字段 }
function TfrmdbView.GetDispFieldsList: String;
var
  I: Integer;
begin
  Result := '';
  for I  := 0 to lvFields.Items.Count - 1 do
  begin
    if lvFields.Items[I].Caption = '1' then
    begin
      Result := Result + ',' + lvFields.Items[I].SubItems[0];
    end;
  end;
  Result := RightStr(Result, Length(Result) - 1);
end;

{ 获取自动增长字段 }
function TfrmdbView.GetAutoFieldName(const strTableName: String; var strAutoField: string): Boolean;
begin
  qryTemp.SQL.Clear;
  qryTemp.Close;
  qryTemp.SQL.Text := Format('select colstat, name from syscolumns where id=object_id(%s) and colstat = 1', [QuotedStr(strTableName)]);
  qryTemp.Open;
  if qryTemp.RecordCount > 0 then
    strAutoField := qryTemp.Fields[1].AsString
  else
    strAutoField := '';
  Result         := strAutoField <> '';
end;

{ 创建数据显示列 }
procedure TfrmdbView.CreateColumnDispField;
var
  I: Integer;
begin
  lvData.Visible := False;
  lvData.Columns.BeginUpdate;
  try
    lvData.Columns.Clear;
    with lvData.Columns.Add do
    begin
      Caption := '序列';
      Width   := 100;
    end;

    for I := 0 to lvFields.Items.Count - 1 do
    begin
      if lvFields.Items[I].Caption = '1' then
      begin
        with lvData.Columns.Add do
        begin
          Caption := IfThen(lvFields.Items[I].SubItems[2] <> '', lvFields.Items[I].SubItems[2], lvFields.Items[I].SubItems[0]);
          Width   := 140;
        end;
      end;
    end;
  finally
    lvData.Columns.EndUpdate;
    lvData.Visible := True;
  end;
end;

{ 获取 ODBC 表所有数据 }
procedure TfrmdbView.GetTableDataInfo_ODBC(const strTableName: string);
var
  strAutoID: String;
  strFields: String;
begin
  btnConnect.Enabled     := False;
  btnSearch.Enabled      := False;
  btnSQL.Enabled         := False;
  btnExportExcel.Enabled := False;
  lstTables.Enabled      := False;
  try
    { 获取自动增长字段 }
    FbAutoField := GetAutoFieldName(strTableName, strAutoID);

    { 获取显示字段 }
    strFields := GetDispFieldsList;
    if System.SysUtils.Trim(strFields) = '' then
    begin
      lvFields.SetFocus;
      ShowMessage('必须至少选择一下字段来进行显示');
      Exit;
    end;

    lvData.Items.Count := 0;
    qryData.SQL.Clear;
    qryData.Close;
    if strAutoID <> '' then
      qryData.SQL.Text := Format('select ROW_NUMBER() over(order by %s) as RowNum, %s from %s', [strAutoID, strFields, strTableName])
    else
      qryData.SQL.Text := Format('select Top 1000 %s from %s', [strFields, strTableName]);
    qryData.Open;

    { 创建数据显示列 }
    CreateColumnDispField;

    { 触发数据列表绘制 }
    lvData.Items.Count := qryData.RecordCount;
  finally
    btnConnect.Enabled     := True;
    btnSearch.Enabled      := True;
    btnSQL.Enabled         := True;
    btnExportExcel.Enabled := True;
    lstTables.Enabled      := True;
  end;
end;

procedure TfrmdbView.btnSearchClick(Sender: TObject);
begin
  if not FbSqlite3 then
    GetTableDataInfo_ODBC(lstTables.Items[lstTables.ItemIndex])
  else
    GetTableDataInfo_Sqlite3(lstTables.Items[lstTables.ItemIndex])
end;

procedure TfrmdbView.btnSQLClick(Sender: TObject);
begin
  ShowSQLForm(Handle);
end;

procedure TfrmdbView.lvDataData(Sender: TObject; Item: TListItem);
var
  I, J        : Integer;
  qry         : TADOQuery;
  strSQL      : String;
  strTableName: String;
  strResult   : String;
  jsn         : TJSONObject;
  jsnValue    : TJSONArray;
  intCount    : Integer;
  intRowResult: Integer;
begin
  if not FbSqlite3 then
  begin
    if FbSearch then
      qry := qryTemp
    else
      qry := qryData;

    qry.RecNo    := Item.Index + 1;
    Item.Caption := Format('%.10u', [Item.Index + 1]);

    J     := Integer(FbAutoField);
    for I := J to qry.Fields.Count - 1 do
    begin
      Item.SubItems.Add(qry.Fields[I].AsString);
    end;
  end
  else
  begin
    Item.Caption := Format('%.10u', [Item.Index + 1]);

    strTableName := lstTables.Items.Strings[lstTables.ItemIndex];
    strSQL       := Format('select %s from %s  where RowID=%d', [GetDispFieldsList, strTableName, Item.Index + 1]);
    strResult    := UTF8ToString(FSqlite3DB.ExecuteJSON(RawUTF8(strSQL)));
    jsn          := TJSONObject.ParseJSONValue(strResult) as TJSONObject;
    intCount     := TJSONNumber(jsn.P['fieldCount'] as TJSONNumber).AsInt;
    intRowResult := TJSONNumber(jsn.P['rowCount'] as TJSONNumber).AsInt;
    if intRowResult > 0 then
    begin
      jsnValue := jsn.P['values'] as TJSONArray;
      for I    := 0 to jsnValue.Count div 2 - 1 do
      begin
        Item.SubItems.Add(TJSONString(jsnValue.A[I + intCount]).Value);
      end;
    end;
  end;
end;

procedure TfrmdbView.btnExportExcelClick(Sender: TObject);
var
  strFileName: String;
  XLS        : TXLSReadWriteII5;
  I, J       : Integer;
begin
  if not dlgSaveExcel.Execute then
    Exit;

  strFileName := dlgSaveExcel.FileName;
  if System.SysUtils.LowerCase(ExtractFileExt(strFileName)) <> '.xlsx' then
    strFileName := strFileName + '.xlsx';

  btnConnect.Enabled     := False;
  btnSearch.Enabled      := False;
  btnSQL.Enabled         := False;
  btnExportExcel.Enabled := False;
  lstTables.Enabled      := False;
  XLS                    := TXLSReadWriteII5.Create(nil);
  try
    XLS.FileName := strFileName;
    for I        := 1 to lvData.Columns.Count do
    begin
      for J := 1 to lvData.Items.Count + 1 do
      begin
        XLS.Sheets[0].Range.Items[I, J, I, J].BorderOutlineStyle := cbsThin;
        XLS.Sheets[0].Range.Items[I, J, I, J].BorderOutlineColor := 0;
      end;
    end;

    for I := 1 to lvData.Columns.Count do
    begin
      Application.ProcessMessages;
      XLS.Sheets[0].AsString[I, 1]                  := lvData.Column[I - 1].Caption;
      XLS.Sheets[0].Columns[I].Width                := 4000;
      XLS.Sheets[0].Cell[I, 1].FontColor            := clWhite;
      XLS.Sheets[0].Cell[I, 1].FontStyle            := XLS.Sheets[0].Cell[I, 1].FontStyle + [xfsBold];
      XLS.Sheets[0].Cell[I, 1].FillPatternForeColor := xcBlue;
      XLS.Sheets[0].Cell[I, 1].HorizAlignment       := chaCenter;
      XLS.Sheets[0].Cell[I, 1].VertAlignment        := cvaCenter;
    end;

    for J := 0 to lvData.Items.Count - 1 do
    begin
      for I := 0 to lvData.Columns.Count - 1 do
      begin
        if I = 0 then
          XLS.Sheets[0].AsString[I + 1, J + 2] := lvData.Items[J].Caption
        else
          XLS.Sheets[0].AsString[I + 1, J + 2] := lvData.Items[J].SubItems[I - 1];

        XLS.Sheets[0].Cell[I + 1, J + 2].HorizAlignment := chaCenter;
        XLS.Sheets[0].Cell[I + 1, J + 2].VertAlignment  := cvaCenter;
      end;
    end;

    XLS.Write;
  finally
    XLS.Free;
    btnExportExcel.Caption := '导出到 EXCEL';
    btnConnect.Enabled     := True;
    btnSearch.Enabled      := True;
    btnSQL.Enabled         := True;
    btnExportExcel.Enabled := True;
    lstTables.Enabled      := True;
  end;
end;

{ 执行 SQL 查询 }
procedure TfrmdbView.WMEXECSQL(var msg: TMessage);
var
  strSQL  : String;
  bSuccess: Boolean;
begin
  strSQL := PChar(msg.WParam);
  qryTemp.Close;
  qryTemp.SQL.Clear;
  qryTemp.SQL.Text := strSQL;
  try
    qryTemp.Open;
    strSQL   := '';
    bSuccess := True;
  except
    on E: Exception do
    begin
      bSuccess := False;
      strSQL   := E.Message;
    end;
  end;

  PostMessage(msg.LParam, WM_EXECSQLSUCCESS, Integer(bSuccess), Integer(PChar(strSQL)));

  if bSuccess and (qryTemp.RecordCount > 0) then
    ShowSearchResult;
end;

{ 显示搜索结果 }
procedure TfrmdbView.ShowSearchResult;
var
  I: Integer;
begin
  FbAutoField    := False;
  FbSearch       := True;
  lvData.Visible := False;
  try
    lvData.Items.Count := 0;
    lvData.Columns.Clear;
    lvData.Items.Clear;
    lvData.Columns.BeginUpdate;
    for I := 0 to qryTemp.FieldCount - 1 do
    begin
      with lvData.Columns.Add do
      begin
        Caption := qryTemp.Fields[I].FieldName;
        Width   := 140;
      end;
    end;
    lvData.Columns.EndUpdate;
    lvData.Items.Count := qryTemp.RecordCount;
  finally
    lvData.Visible := True;
  end;
end;

{ 获取 SQLITE3 数据库中所有表名 }
procedure TfrmdbView.GetAllTables_Sqlite3;
var
  arrAllTables: TRawUTF8DynArray;
  I           : Integer;
begin
  FSqlite3DB.GetTableNames(arrAllTables);
  lstTables.Clear;
  lvFields.Clear;
  lvData.Items.Count := 0;
  lvData.Columns.Clear;
  for I := Low(arrAllTables) to High(arrAllTables) do
  begin
    lstTables.Items.Add(string(arrAllTables[I]));
  end;
end;

procedure TfrmdbView.mniSqliteClick(Sender: TObject);
var
  strdb3FileName: String;
begin
  if not dlgOpenSqliteDB.Execute then
    Exit;

  FbSqlite3      := True;
  strdb3FileName := dlgOpenSqliteDB.FileName;
  FSqlite3DB     := TSQLDatabase.Create(strdb3FileName, '', SQLITE_OPEN_READONLY);

  { 获取 SQLITE3 数据库中所有表名 }
  GetAllTables_Sqlite3;
end;

end.
