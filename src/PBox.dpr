program PBox;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  Vcl.Forms,
  Winapi.Windows,
  Data.Win.ADODB,
  db.uCommon in 'db.uCommon.pas',
  db.uBaseForm in 'db.uBaseForm.pas',
  db.MainForm in 'db.MainForm.pas' {frmPBox} ,
  db.DonateForm in 'db.DonateForm.pas' {frmDonate} ,
  db.AboutForm in 'db.AboutForm.pas' {frmAbout} ,
  db.AddEXE in 'db.AddEXE.pas' {frmAddEXE} ,
  db.ConfigForm in 'db.ConfigForm.pas' {frmConfig} ,
  db.DBConfig in 'db.DBConfig.pas' {DBConfig} ,
  db.LoginForm in 'db.LoginForm.pas' {frmLogin} ,
  db.uCreateDelphiDllForm in 'db.uCreateDelphiDllForm.pas',
  db.uCreateEXEForm in 'db.uCreateEXEForm.pas',
  db.uCreateVCDllForm in 'db.uCreateVCDllForm.pas';

{$R *.res}

var
  strLoginName: String = '';

begin
  OnlyRunOneInstance;
  g_ADOCNN := TADOConnection.Create(nil);
  try
    CheckLoginForm(strLoginName);
    Application.Initialize;
    ReportMemoryLeaksOnShutdown   := True;
    Application.MainFormOnTaskbar := False;
    Application.Title             := GetTitleText;
    Application.CreateForm(TfrmPBox, frmPBox);
    frmPBox.lblLogin.Caption := strLoginName;
    Application.Run;
  finally
    g_ADOCNN.Free;
  end;

end.
