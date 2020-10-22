library dbView;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$R *.dres}

uses
  System.SysUtils,
  System.Classes,
  uMainForm in 'uMainForm.pas' {frmdbView},
  uSQLForm in 'uSQLForm.pas' {frmSQL};

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin

end.
