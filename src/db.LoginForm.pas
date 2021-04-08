unit db.LoginForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.ImageList, System.IniFiles, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ImgList, Data.db, Data.Win.ADODB, db.uCommon;

type
  TfrmLogin = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    edtUserName: TEdit;
    edtUserPass: TEdit;
    btnSave: TButton;
    btnCancel: TButton;
    imgLogo: TImage;
    chkUserName: TCheckBox;
    chkAutoLogin: TCheckBox;
    ilButton: TImageList;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edtUserPassKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtUserNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure chkAutoLoginClick(Sender: TObject);
    procedure chkUserNameClick(Sender: TObject);
  private
    FbResult: Boolean;
    procedure LoadLoginInfo(var ini: TIniFile);
    procedure SaveLoginInfo(var ini: TIniFile);
  public
    { Public declarations }
  end;

procedure CheckLoginForm(var strLoginName: String);

implementation

{$R *.dfm}

var
  FstrLoginTable: string = '';
  FstrLoginName : string = '';
  FstrLoginPass : String = '';

procedure CheckLoginForm(var strLoginName: String);
var
  IniFile       : TIniFile;
  strUDLFileName: String;
  strLinkDB     : String;
begin
  strLoginName   := '';
  strUDLFileName := ChangeFileExt(ParamStr(0), '.udl');

  IniFile := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    if FileExists(strUDLFileName) then
      strLinkDB := strUDLFileName
    else
      strLinkDB := DecryptString(IniFile.ReadString(c_strIniDBSection, 'Name', ''), c_strAESKey);

    if Trim(strLinkDB) = '' then
      Exit;

    FstrLoginTable := IniFile.ReadString(c_strIniDBSection, 'LoginTable', '');
    FstrLoginName  := IniFile.ReadString(c_strIniDBSection, 'LoginNameField', '');
    FstrLoginPass  := IniFile.ReadString(c_strIniDBSection, 'LoginPassField', '');
    if (FstrLoginTable = '') or (FstrLoginName = '') or (FstrLoginPass = '') then
      Exit;

    if not TryLinkDataBase(strLinkDB, g_ADOCNN) then
    begin
      MessageBox(0, '�������ݿ�ʧ�ܣ��������ݿ�����', c_strMsgTitle, MB_OK OR MB_ICONERROR);
      Exit;
    end;

    with TfrmLogin.Create(nil) do
    begin
      FbResult             := False;
      imgLogo.Picture.Icon := Application.Icon;
      Position             := poScreenCenter;
      LoadLoginInfo(IniFile);
      ShowModal;
      if not FbResult then
      begin
        { ��¼ʧ�ܻ�ȡ����¼ }
        Halt(0);
      end
      else
      begin
        { ��¼�ɹ� }
        SaveLoginInfo(IniFile);
        strLoginName := '��¼�û���' + edtUserName.Text;
        try
          { �������ݿ� }
          UpdateDataBaseScript(IniFile, g_ADOCNN, True);
        except
          strLoginName := '';
        end;
      end;
      Free;
    end;
  finally
    IniFile.Free;
  end;
end;

procedure TfrmLogin.LoadLoginInfo(var ini: TIniFile);
begin
  if ini.ReadBool(c_strIniDBSection, 'CheckLoginAuto', False) then
  begin
    edtUserName.Text     := ini.ReadString(c_strIniDBSection, 'LoginUserName', '');
    edtUserPass.Text     := DecryptString(ini.ReadString(c_strIniUISection, 'LoginUserPass', ''), c_strAESKey);
    chkUserName.Checked  := True;
    chkAutoLogin.Checked := True;
  end
  else
  begin
    if ini.ReadBool(c_strIniDBSection, 'CheckLoginUserName', False) then
    begin
      edtUserName.Text     := ini.ReadString(c_strIniDBSection, 'LoginUserName', '');
      edtUserPass.Text     := '';
      chkUserName.Checked  := True;
      chkAutoLogin.Checked := False;
      Winapi.Windows.SetFocus(edtUserPass.Handle);
    end;
  end;
end;

procedure TfrmLogin.SaveLoginInfo(var ini: TIniFile);
begin
  ini.WriteBool(c_strIniDBSection, 'CheckLoginUserName', chkUserName.Checked);
  ini.WriteBool(c_strIniDBSection, 'CheckLoginAuto', chkAutoLogin.Checked);

  if chkAutoLogin.Checked then
  begin
    ini.WriteString(c_strIniDBSection, 'LoginUserName', edtUserName.Text);
    ini.WriteString(c_strIniUISection, 'LoginUserPass', EncryptString(edtUserPass.Text, c_strAESKey));
  end
  else
  begin
    if chkUserName.Checked then
    begin
      ini.WriteString(c_strIniDBSection, 'LoginUserName', edtUserName.Text);
      ini.WriteString(c_strIniUISection, 'LoginUserPass', '');
    end
    else
    begin
      ini.WriteString(c_strIniDBSection, 'LoginUserName', '');
      ini.WriteString(c_strIniUISection, 'LoginUserPass', '');
    end;
  end;
end;

procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  FbResult := False;
  Close;
end;

procedure TfrmLogin.btnSaveClick(Sender: TObject);
var
  strSQL: String;
  qry   : TADOQuery;
begin
  if Trim(edtUserName.Text) = '' then
  begin
    MessageBox(Handle, '�û����Ʋ���Ϊ�գ�������', c_strMsgTitle, MB_OK OR MB_ICONERROR);
    edtUserName.SetFocus;
    Exit;
  end;

  if Trim(edtUserPass.Text) = '' then
  begin
    MessageBox(Handle, '�û����벻��Ϊ�գ�������', c_strMsgTitle, MB_OK OR MB_ICONERROR);
    edtUserPass.SetFocus;
    Exit;
  end;

  if (g_ADOCNN.Connected) and (FstrLoginTable <> '') and (FstrLoginName <> '') and (FstrLoginPass <> '') then
  begin
    strSQL         := Format('select * from %s where %s=%s and %s=%s', [FstrLoginTable, FstrLoginName, QuotedStr(edtUserName.Text), FstrLoginPass, QuotedStr(EncDatabasePassword(edtUserPass.Text))]);
    qry            := TADOQuery.Create(nil);
    qry.Connection := g_ADOCNN;
    qry.SQL.Text   := strSQL;
    qry.Open;
    if qry.RecordCount > 0 then
    begin
      { ��¼�ɹ� }
      FbResult := True;
      Close;
    end
    else
    begin
      MessageBox(Handle, '�û������ڻ������������������', c_strMsgTitle, MB_OK OR MB_ICONERROR);
    end;
    qry.Free;
  end;
end;

procedure TfrmLogin.chkAutoLoginClick(Sender: TObject);
begin
  if chkAutoLogin.Checked then
    chkUserName.Checked := True;
end;

procedure TfrmLogin.chkUserNameClick(Sender: TObject);
begin
  if not chkUserName.Checked then
    chkAutoLogin.Checked := False;
end;

procedure TfrmLogin.edtUserNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    edtUserPass.SetFocus;
end;

procedure TfrmLogin.edtUserPassKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnSave.click;
end;

end.

