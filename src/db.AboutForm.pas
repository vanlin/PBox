unit db.AboutForm;

interface

uses
  Winapi.ShellAPI, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmAbout = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lnklblWebAddress: TLinkLabel;
    lnklbl1: TLinkLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    lbl10: TLabel;
    lbl11: TLabel;
    lnklbl2: TLinkLabel;
    procedure lnklblWebAddressLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
    procedure lnklbl1LinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowAboutForm;

implementation

{$R *.dfm}

procedure ShowAboutForm;
begin
  with TfrmAbout.Create(nil) do
  begin
    Position := poScreenCenter;
    ShowModal;
    Free;
  end;
end;

procedure TfrmAbout.lnklbl1LinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
begin
  ShellExecute(0, 'open', PChar(Link), nil, nil, 1);
end;

procedure TfrmAbout.lnklblWebAddressLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
begin
  ShellExecute(0, 'open', PChar(Link), nil, nil, 1);
end;

end.
