unit db.DBConfig;

interface

uses
  Winapi.Windows, System.SysUtils, System.StrUtils, System.Classes, System.IniFiles, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.WinXCtrls, Vcl.ComCtrls, Data.Win.ADOConEd, Data.Win.ADODB, db.uCommon;

type
  TDBConfig = class(TForm)
    btnSave: TButton;
    btnCancel: TButton;
    pgcAll: TPageControl;
    tsCreateDBLink: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    ts4: TTabSheet;
    ts5: TTabSheet;
    ts6: TTabSheet;
    ts7: TTabSheet;
    ts8: TTabSheet;
    ts9: TTabSheet;
    btnCreateDBLink: TButton;
    btnCreateDB: TButton;
    btnZoomOut: TButton;
    btnSelectUpdataDB: TButton;
    btnBackupDatabase: TButton;
    lblLoginName: TLabel;
    lblLoginPass: TLabel;
    edtLoginPass1: TEdit;
    edtLoginName1: TEdit;
    lblTip: TLabel;
    btnRestoreDatabase: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edtLoginPass2: TEdit;
    edtLoginName2: TEdit;
    chkAutoUpdateDB: TCheckBox;
    lblAutoUpdateDBSQLScriptFileNameDelete: TLabel;
    edtUpdateDBSqlScriptFileName: TEdit;
    lblAutoUpdateDBSQLScriptFileName: TLabel;
    grpEffectLogin: TGroupBox;
    lblLoginTable: TLabel;
    lbl1: TLabel;
    lbl2: TLabel;
    cbbLoginTable: TComboBox;
    cbbLoginName: TComboBox;
    cbbLoginPass: TComboBox;
    chkPassword: TCheckBox;
    pnlPassword: TPanel;
    grpPassword: TGroupBox;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    cbbDllFunc: TComboBox;
    srchbxDecFuncFile: TSearchBox;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCreateDBLinkClick(Sender: TObject);
    procedure btnCreateDBClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure btnSelectUpdataDBClick(Sender: TObject);
    procedure btnBackupDatabaseClick(Sender: TObject);
    procedure btnRestoreDatabaseClick(Sender: TObject);
    procedure chkAutoUpdateDBClick(Sender: TObject);
    procedure chkPasswordClick(Sender: TObject);
    procedure srchbxDecFuncFileInvokeSearch(Sender: TObject);
    procedure cbbLoginTableChange(Sender: TObject);
  private
    FmemIni: TMemIniFile;
    procedure ReadConfigFillUI;
    procedure CreateDataBase(ADOCNN: TADOConnection);
    { 填充登录设置 }
    procedure FillLoginConfig;
  public
    { Public declarations }
  end;

function ShowDBConfigForm(var memIni: TMemIniFile): Boolean;

implementation

{$R *.dfm}

function ShowDBConfigForm(var memIni: TMemIniFile): Boolean;
begin
  Result := True;
  with TDBConfig.Create(nil) do
  begin
    FmemIni := memIni;
    ReadConfigFillUI;
    ShowModal;
    Free;
  end;
end;

{ 连接数据库 }
procedure TDBConfig.btnCreateDBLinkClick(Sender: TObject);
begin
  { 数据库连接已经存在，断开数据库连接 }
  if g_ADOCNN.Connected then
  begin
    g_ADOCNN.Connected := False;

    if EditConnectionString(g_ADOCNN) then
    begin
      { 创建进行数据库连接 }
      TryLinkDataBase(g_ADOCNN.ConnectionString, g_ADOCNN);
    end;
  end
  else
  begin
    if EditConnectionString(g_ADOCNN) then
    begin
      { 创建进行数据库连接 }
      TryLinkDataBase(g_ADOCNN.ConnectionString, g_ADOCNN);
    end;
  end;

  FillLoginConfig;
end;

{ 还原数据库 }
procedure TDBConfig.btnRestoreDatabaseClick(Sender: TObject);
var
  strErr: String;
begin
  if not g_ADOCNN.Connected then
  begin
    MessageBox(Application.MainForm.Handle, '先创建数据库连接，才能进行创建数据库', c_strTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  if Trim(edtLoginPass2.Text) = '' then
  begin
    edtLoginPass2.SetFocus;
    MessageBox(Handle, '登录密码本能为空！', c_strTitle, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  with TOpenDialog.Create(nil) do
  begin
    Filter := 'BACKUP(*.bak)|*.bak';
    if not Execute(Handle) then
    begin
      Free;
      Exit;
    end;

    { 还原数据库 }
    if RestoreDataBase(g_ADOCNN, edtLoginName2.Text, edtLoginPass2.Text, FileName, strErr) then
      MessageBox(Handle, '数据库还原成功！', c_strTitle, MB_OK or MB_ICONINFORMATION)
    else
      MessageBox(Handle, PChar('数据库还原失败，' + strErr + '！'), c_strTitle, MB_OK or MB_ICONERROR);
    Free;
  end;
end;

{ 创建数据库 }
procedure TDBConfig.btnCreateDBClick(Sender: TObject);
begin
  CreateDataBase(g_ADOCNN);
end;

{ 选择升级脚本 }
procedure TDBConfig.btnSelectUpdataDBClick(Sender: TObject);
begin
  CreateDataBase(g_ADOCNN);
end;

{ 备份数据库 }
procedure TDBConfig.btnBackupDatabaseClick(Sender: TObject);
var
  strSaveFileName: String;
begin
  if not g_ADOCNN.Connected then
  begin
    MessageBox(Application.MainForm.Handle, '先创建数据库连接，才能进行创建数据库', c_strTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  if Trim(edtLoginPass1.Text) = '' then
  begin
    edtLoginPass1.SetFocus;
    MessageBox(Handle, '登录密码本能为空！', c_strTitle, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  with TSaveDialog.Create(nil) do
  begin
    if not Execute(Handle) then
    begin
      Free;
      Exit;
    end;

    strSaveFileName := FileName;
    if LowerCase(ExtractFileExt(strSaveFileName)) <> '.bak' then
    begin
      strSaveFileName := strSaveFileName + '.bak';
    end;

    Free;
  end;

  { 备份数据库 }
  if BackupDataBase(g_ADOCNN, edtLoginName1.Text, edtLoginPass1.Text, strSaveFileName) then
    MessageBox(Handle, '数据库备份成功！', c_strTitle, MB_OK or MB_ICONINFORMATION)
  else
    MessageBox(Handle, '数据库备份失败，请联系管理员！', c_strTitle, MB_OK or MB_ICONERROR);
end;

procedure TDBConfig.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TDBConfig.btnSaveClick(Sender: TObject);
begin
  { 自动升级设置 }
  if (chkAutoUpdateDB.Checked) and (Trim(edtUpdateDBSqlScriptFileName.Text) = '') then
  begin
    MessageBox(Handle, '升级脚本文件名不能为空', c_strTitle, MB_OK or MB_ICONINFORMATION);
    edtUpdateDBSqlScriptFileName.SetFocus;
    Exit;
  end;
  FmemIni.WriteBool(c_strIniDBSection, 'AutoUpdate', chkAutoUpdateDB.Checked);
  FmemIni.WriteString(c_strIniDBSection, 'AutoUpdateFile', Ifthen(not chkAutoUpdateDB.Checked, '', edtUpdateDBSqlScriptFileName.Text));

  { 登录密码设置 }
  if not chkPassword.Checked then
  begin
    if (cbbLoginTable.Text <> '') and (cbbLoginName.Text <> '') and (cbbLoginPass.Text <> '') then
    begin
      FmemIni.WriteString(c_strIniDBSection, 'LoginTable', cbbLoginTable.Text);
      FmemIni.WriteString(c_strIniDBSection, 'LoginNameField', cbbLoginName.Text);
      FmemIni.WriteString(c_strIniDBSection, 'LoginPassField', cbbLoginPass.Text);
      FmemIni.WriteBool(c_strIniDBSection, 'PasswordEnc', False);
      FmemIni.WriteString(c_strIniDBSection, 'PasswordEncDllFileName', '');
      FmemIni.WriteString(c_strIniDBSection, 'PasswordEncDllFuncName', '');
    end
    else
    begin
      MessageBox(Handle, '登录信息不完整，请选择登录表，以及登录名称和登录密码字段', c_strTitle, MB_OK or MB_ICONINFORMATION);
      cbbLoginTable.SetFocus;
      Exit;
    end;
  end
  else
  begin
    if (cbbLoginTable.Text <> '') and (cbbLoginName.Text <> '') and (cbbLoginPass.Text <> '') and (srchbxDecFuncFile.Text <> '') and (cbbDllFunc.Text <> '') then
    begin
      FmemIni.WriteString(c_strIniDBSection, 'LoginTable', cbbLoginTable.Text);
      FmemIni.WriteString(c_strIniDBSection, 'LoginNameField', cbbLoginName.Text);
      FmemIni.WriteString(c_strIniDBSection, 'LoginPassField', cbbLoginPass.Text);
      FmemIni.WriteBool(c_strIniDBSection, 'PasswordEnc', True);
      FmemIni.WriteString(c_strIniDBSection, 'PasswordEncDllFileName', srchbxDecFuncFile.Text);
      FmemIni.WriteString(c_strIniDBSection, 'PasswordEncDllFuncName', cbbDllFunc.Text);
    end
    else
    begin
      MessageBox(Handle, '登录信息不完整，请选择登录表，以及登录名称、登录密码字段，和加密文件、加密函数', c_strTitle, MB_OK or MB_ICONINFORMATION);
      cbbLoginTable.SetFocus;
      Exit;
    end;
  end;

  FmemIni.WriteInteger(c_strIniDBSection, 'ActivePageIndex', pgcAll.ActivePageIndex);
  if g_ADOCNN.Connected then
    FmemIni.WriteString(c_strIniDBSection, 'Name', EncryptString(g_ADOCNN.ConnectionString, c_strAESKey));

  Close;
end;

{ 收缩/压缩数据库 }
procedure TDBConfig.btnZoomOutClick(Sender: TObject);
var
  strDBLibraryName: String;
begin
  if not g_ADOCNN.Connected then
  begin
    MessageBox(Application.MainForm.Handle, '先创建数据库连接，才能进行创建数据库', c_strTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  strDBLibraryName := GetDBLibraryName(g_ADOCNN.ConnectionString);
  if Trim(strDBLibraryName) <> '' then
  begin
    with TADOQuery.Create(nil) do
    begin
      Connection := g_ADOCNN;
      sql.Add('DBCC SHRINKDATABASE (' + strDBLibraryName + ')');
      sql.Add('DBCC SHRINKFILE (' + strDBLibraryName + ',0,TRUNCATEONLY)');
      try
        ExecSQL;
        MessageBox(Handle, '数据库收缩成功！', c_strTitle, MB_OK or MB_ICONINFORMATION);
      except
        MessageBox(Handle, '数据库收缩失败！', c_strTitle, MB_OK or MB_ICONERROR);
      end;
      Free;
    end;
  end;
end;

procedure TDBConfig.cbbLoginTableChange(Sender: TObject);
var
  lstFields: TStringList;
begin
  if not g_ADOCNN.Connected then
    Exit;

  cbbLoginName.Clear;
  cbbLoginPass.Clear;
  lstFields := TStringList.Create;
  try
    g_ADOCNN.GetFieldNames(cbbLoginTable.Text, lstFields);
    cbbLoginName.Items.AddStrings(lstFields);
    cbbLoginPass.Items.AddStrings(lstFields);
  finally
    lstFields.Free;
  end;
end;

procedure TDBConfig.chkPasswordClick(Sender: TObject);
begin
  pnlPassword.Visible := chkPassword.Checked;
end;

procedure TDBConfig.chkAutoUpdateDBClick(Sender: TObject);
begin
  edtUpdateDBSqlScriptFileName.Visible           := chkAutoUpdateDB.Checked;
  lblAutoUpdateDBSQLScriptFileName.Visible       := chkAutoUpdateDB.Checked;
  lblAutoUpdateDBSQLScriptFileNameDelete.Visible := chkAutoUpdateDB.Checked;
end;

procedure TDBConfig.CreateDataBase(ADOCNN: TADOConnection);
begin
  if not ADOCNN.Connected then
  begin
    MessageBox(Application.MainForm.Handle, '先创建数据库连接，才能进行创建数据库', c_strTitle, MB_OK or MB_ICONERROR);
    Exit;
  end;

  with TOpenDialog.Create(nil) do
  begin
    Filter := 'SQL脚本(*.sql)|*.sql';
    if Execute(Application.MainForm.Handle) then
    begin
      if ExeSql(FileName, ADOCNN) then
        MessageBox(Application.MainForm.Handle, '创建数据库成功', c_strTitle, MB_OK or MB_ICONINFORMATION)
      else
        MessageBox(Application.MainForm.Handle, '创建数据库失败', c_strTitle, MB_OK or MB_ICONERROR);
    end;
    Free;
  end;
end;

procedure TDBConfig.FillLoginConfig;
var
  lstTables                 : TStringList;
  lstFields                 : TStringList;
  strLoginTable             : string;
  strLoginName, strLoginPass: String;
  lstFunc                   : TStringList;
begin
  if not g_ADOCNN.Connected then
  begin
    btnCreateDBLink.Caption := '建立数据库连接';
    cbbLoginTable.Items.Clear;
    cbbLoginName.Items.Clear;
    cbbLoginPass.Items.Clear;
    Exit;
  end;

  btnCreateDBLink.Caption := '断开数据库连接';
  cbbLoginTable.Items.Clear;
  cbbLoginName.Items.Clear;
  cbbLoginPass.Items.Clear;
  lstTables := TStringList.Create;
  try
    g_ADOCNN.GetTableNames(lstTables);
    cbbLoginTable.Items.AddStrings(lstTables);
  finally
    lstTables.Free;
  end;

  strLoginTable := FmemIni.ReadString(c_strIniDBSection, 'LoginTable', '');
  strLoginName  := FmemIni.ReadString(c_strIniDBSection, 'LoginNameField', '');
  strLoginPass  := FmemIni.ReadString(c_strIniDBSection, 'LoginPassField', '');
  if strLoginTable <> '' then
  begin
    cbbLoginTable.ItemIndex := cbbLoginTable.Items.IndexOf(strLoginTable);

    lstFields := TStringList.Create;
    try
      g_ADOCNN.GetFieldNames(cbbLoginTable.Text, lstFields);
      cbbLoginName.Items.AddStrings(lstFields);
      cbbLoginPass.Items.AddStrings(lstFields);

      if strLoginName <> '' then
        cbbLoginName.ItemIndex := cbbLoginName.Items.IndexOf(strLoginName);

      if strLoginPass <> '' then
        cbbLoginPass.ItemIndex := cbbLoginPass.Items.IndexOf(strLoginPass);
    finally
      lstFields.Free;
    end;
  end;

  chkPassword.Checked := FmemIni.ReadBool(c_strIniDBSection, 'PasswordEnc', False);
  if chkPassword.Checked then
  begin
    if FileExists(FmemIni.ReadString(c_strIniDBSection, 'PasswordEncDllFileName', '')) then
    begin
      srchbxDecFuncFile.Text := FmemIni.ReadString(c_strIniDBSection, 'PasswordEncDllFileName', '');
      lstFunc                := TStringList.Create;
      try
        GetPEExport(srchbxDecFuncFile.Text, lstFunc);
        cbbDllFunc.Items.AddStrings(lstFunc);
        cbbDllFunc.ItemIndex := cbbDllFunc.Items.IndexOf(FmemIni.ReadString(c_strIniDBSection, 'PasswordEncDllFuncName', ''));
      finally
        lstFunc.Free;
      end;
    end;
  end;
end;

procedure TDBConfig.ReadConfigFillUI;
var
  strAutoUpdateDBSQLFileName: String;
begin
  pgcAll.ActivePageIndex     := FmemIni.ReadInteger(c_strIniDBSection, 'ActivePageIndex', 0);
  chkAutoUpdateDB.Checked    := FmemIni.ReadBool(c_strIniDBSection, 'AutoUpdate', False);
  strAutoUpdateDBSQLFileName := FmemIni.ReadString(c_strIniDBSection, 'AutoUpdateFile', '');

  { 自动升级脚本 }
  if Trim(strAutoUpdateDBSQLFileName) <> '' then
  begin
    chkAutoUpdateDB.Checked           := True;
    edtUpdateDBSqlScriptFileName.Text := strAutoUpdateDBSQLFileName;
  end;

  { 本机登录用户名 }
  edtLoginName1.Text := GetCurrentLoginUserName;
  edtLoginName2.Text := GetCurrentLoginUserName;

  { 数据库登录信息 }
  FillLoginConfig;
end;

procedure TDBConfig.srchbxDecFuncFileInvokeSearch(Sender: TObject);
var
  lstFunc: TStringList;
begin
  with TOpenDialog.Create(nil) do
  begin
    Filter := 'Dll(*.Dll)|*.Dll';
    if not Execute(Application.MainForm.Handle) then
    begin
      Free;
      Exit;
    end;

    srchbxDecFuncFile.Text := FileName;
    lstFunc                := TStringList.Create;
    try
      if GetPEExport(FileName, lstFunc) then
      begin
        cbbDllFunc.Clear;
        cbbDllFunc.Items.AddStrings(lstFunc);
        cbbDllFunc.ItemIndex := 0;
      end;
    finally
      lstFunc.Free;
    end;
    Free;
  end;
end;

end.
