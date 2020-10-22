unit uSQLForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, SynEdit, SynHighlighterSQL, db.uCommon;

type
  TfrmSQL = class(TForm)
    btnCancel: TButton;
    btnOK: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FSynEdit  : TSynEdit;
    FSynSQLSyn: TSynSQLSyn;
    FhWnd     : THandle;
  protected
    procedure WMEXECSQLSUCCESS(var msg: TMessage); message WM_EXECSQLSUCCESS;
  end;

procedure ShowSQLForm(const hWnd: THandle);

implementation

{$R *.dfm}

procedure ShowSQLForm(const hWnd: THandle);
var
  rct: TRect;
begin
  with TfrmSQL.Create(nil) do
  begin
    FhWnd := hWnd;
    GetWindowRect(GetMainFormHandle, rct);
    Top  := rct.Top + 250;
    Left := rct.Left + 250;
    ShowModal;
    Free;
  end;
end;

procedure TfrmSQL.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSQL.btnOKClick(Sender: TObject);
var
  strSQL: String;
begin
  strSQL := FSynEdit.Text;
  PostMessage(FhWnd, WM_EXECSQL, Integer(PChar(strSQL)), Handle);
end;

procedure TfrmSQL.FormCreate(Sender: TObject);
begin
  FSynSQLSyn           := TSynSQLSyn.Create(Self);
  FSynEdit             := TSynEdit.Create(Self);
  FSynEdit.Parent      := Self;
  FSynEdit.RightEdge   := 8000;
  FSynEdit.Left        := 4;
  FSynEdit.Top         := 4;
  FSynEdit.Width       := Width - 24;
  FSynEdit.Height      := Height - 50 - 8 - btnOK.Height;
  FSynEdit.Highlighter := FSynSQLSyn;
  FSynEdit.Anchors     := [akTop, akLeft, akRight, akBottom];
end;

procedure TfrmSQL.WMEXECSQLSUCCESS(var msg: TMessage);
begin
  if msg.WParam = 0 then
  begin
    ShowMessage(string(PChar(msg.LParam)));
  end
  else
  begin
    Close;
  end;
end;

end.
