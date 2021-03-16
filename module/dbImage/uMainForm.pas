unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ, System.SysUtils, System.Variants, System.Classes, System.IOUtils, System.Types, System.IniFiles,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.ToolWin, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.Imaging.GIFImg, db.uCommon,
  RzTreeVw, RzShellCtrls;

type
  TfrmImageView = class(TForm)
    scrlbxImage: TScrollBox;
    imgView: TImage;
    tmrImageMove: TTimer;
    pgcAll: TPageControl;
    tsBrowse: TTabSheet;
    tsView: TTabSheet;
    clbrBrowse: TCoolBar;
    tlbBrowse: TToolBar;
    mmBrowse: TMainMenu;
    mniBrowseFile: TMenuItem;
    mniTools: TMenuItem;
    mniBrowseFileOpen: TMenuItem;
    mniToolsConvert: TMenuItem;
    mmView: TMainMenu;
    mniViewFile: TMenuItem;
    mniViewFileOpen: TMenuItem;
    mniColor: TMenuItem;
    mniColorGray: TMenuItem;
    tlbView: TToolBar;
    mniViewFileLine01: TMenuItem;
    mniViewFileRestore: TMenuItem;
    mniColorInvert: TMenuItem;
    mniColorLine01: TMenuItem;
    mniColorBrightness: TMenuItem;
    mniColorContrast: TMenuItem;
    mniColorSaturation: TMenuItem;
    mniColorLine02: TMenuItem;
    mniColorTranslate: TMenuItem;
    mniColor03: TMenuItem;
    mniColorHSV: TMenuItem;
    mniColorYCbCr: TMenuItem;
    mniColorCMY: TMenuItem;
    mniColorCMYK: TMenuItem;
    mniColorYCoCg: TMenuItem;
    mniColorGamma: TMenuItem;
    mniGeometry: TMenuItem;
    mniGeometryHorizonMirror: TMenuItem;
    mniGeometryVerticalMirror: TMenuItem;
    mniGeometryHVMirror: TMenuItem;
    mniGeometry2DRotate: TMenuItem;
    mniEffect: TMenuItem;
    mniEffectExposure: TMenuItem;
    mniEffectBoss: TMenuItem;
    mniEffectCarve: TMenuItem;
    mniEffectBlur: TMenuItem;
    mniEffectSharp: TMenuItem;
    mniEffectOilPainting: TMenuItem;
    mniEffectFrosted: TMenuItem;
    mniEffectShake: TMenuItem;
    mniView: TMenuItem;
    mniViewActSize: TMenuItem;
    mniViewStrectch: TMenuItem;
    mniGeometry3DRotate: TMenuItem;
    mniEffectWater: TMenuItem;
    mniToolsSlide: TMenuItem;
    mniToolsSnapScreen: TMenuItem;
    scrlbxBrowse: TScrollBox;
    procedure imgViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure imgViewEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure imgViewStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure tmrImageMoveTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mniViewActSizeClick(Sender: TObject);
    procedure mniViewStrectchClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure imgViewDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPT           : TPoint;
    FrzshltrFolder: TRzShellTree;
    FbStretch     : Boolean;
    FlstImage     : TStringList;
    procedure CreateUI;
    procedure SaveConfig;
    procedure rzshltrFolderChange(Sender: TObject; Node: TTreeNode);
    procedure FreeThumbImageList;
    procedure CreateThumbImageList(const strFolder: string);
    procedure GetAllImage(const strFolder: String; var lstImage: TStringList);
    procedure CreateThumbImagePanel(pnl: TPanel; const strFolder: string); overload;
    procedure CreateThumbImagePanel(const ImageList: TStringList; const bDir: Boolean = False); overload;
    procedure imgDBLClick(Sender: TObject);
    function SetPanelTop: Integer;
    function SetPanelLeft: Integer;
    procedure StretchZoom(const bmp: TBitmap; const bStretch: Boolean = True);
    procedure FirstLoadImage(const strFileName: string);
  public
    { Public declarations }
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

const
  c_intXBetween      = 20;
  c_intYBetween      = 20;
  c_intThumbWidth    = 120;
  c_intThumbHeight   = 120;
  c_strimgSeeCaption = 'imgSee v2.0';

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmImageView;
  strParentModuleName     := '图形图像';
  strModuleName           := '图像查看器';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

{ DLL 中初始化 GDIPLUS DLL }
procedure InitGDIPlus;
begin
  StartupInput.DebugEventCallback       := nil;
  StartupInput.SuppressBackgroundThread := False;
  StartupInput.SuppressExternalCodecs   := False;
  StartupInput.GdiplusVersion           := 1;
  GdiplusStartup(gdiplusToken, @StartupInput, nil);
end;

{ DLL 中销毁 GDIPLUS DLL }
procedure FreeGDIPlus;
begin
  if Assigned(GenericSansSerifFontFamily) then
    GenericSansSerifFontFamily.Free;
  if Assigned(GenericSerifFontFamily) then
    GenericSerifFontFamily.Free;
  if Assigned(GenericMonospaceFontFamily) then
    GenericMonospaceFontFamily.Free;
  if Assigned(GenericTypographicStringFormatBuffer) then
    GenericTypographicStringFormatBuffer.Free;
  if Assigned(GenericDefaultStringFormatBuffer) then
    GenericDefaultStringFormatBuffer.Free;
  GdiplusShutdown(gdiplusToken);
end;

procedure TfrmImageView.CreateUI;
var
  strIniFileName: String;
  bBrowse       : Boolean;
  strFileName   : String;
begin
  strIniFileName := ChangeFileExt(ParamStr(0), '.ini');
  with TIniFile.Create(strIniFileName) do
  begin
    bBrowse     := ReadBool('Browse', 'type', False);
    strFileName := ReadString('Browse', 'Name', '');
    Free;
  end;

  if not bBrowse then
  begin
    FrzshltrFolder.SelectedPathName := strFileName;
    clbrBrowse.Bands[0].Visible     := True;
    clbrBrowse.Bands[1].Visible     := False;
    pgcAll.ActivePageIndex          := 0;
  end
  else
  begin
    FrzshltrFolder.SelectedFolder.PathName := ExtractFilePath(strFileName);
    clbrBrowse.Bands[1].Visible     := True;
    clbrBrowse.Bands[0].Visible     := False;
    pgcAll.ActivePageIndex          := 1;
  end;
end;

procedure TfrmImageView.FormCreate(Sender: TObject);
begin
  InitGDIPlus;

  FlstImage               := TStringList.Create;
  FrzshltrFolder          := TRzShellTree.Create(tsBrowse);
  FrzshltrFolder.Parent   := tsBrowse;
  FrzshltrFolder.Align    := alLeft;
  FrzshltrFolder.Width    := 300;
  FrzshltrFolder.OnChange := rzshltrFolderChange;

  pgcAll.Pages[0].TabVisible := False;
  pgcAll.Pages[1].TabVisible := False;
  pgcAll.ActivePageIndex     := 0;

  CreateUI;
end;

procedure TfrmImageView.SaveConfig;
var
  strIniFileName: String;
begin
  strIniFileName := ChangeFileExt(ParamStr(0), '.ini');
  with TIniFile.Create(strIniFileName) do
  begin
    WriteInteger('Browse', 'type', pgcAll.ActivePageIndex);
    if pgcAll.ActivePageIndex = 0 then
    begin
      WriteString('Browse', 'Name', FrzshltrFolder.SelectedPathName);
    end
    else
    begin
      WriteString('Browse', 'Name', imgView.Hint);
    end;
    Free;
  end;
end;

procedure TfrmImageView.FormDestroy(Sender: TObject);
begin
  SaveConfig;
  FlstImage.Free;
  FrzshltrFolder.Free;
  FreeGDIPlus;
end;

procedure TfrmImageView.FormResize(Sender: TObject);
var
  I, Count: Integer;
begin
  // StretchZoom(imgView.Picture.Bitmap, FbStretch);

  { 一行最多可以显示的缩略 Panel 数目 }
  Count := scrlbxBrowse.Width div (c_intThumbWidth + c_intXBetween);
  for I := 0 to scrlbxBrowse.ComponentCount - 1 do
  begin
    if scrlbxBrowse.Components[I] is TPanel then
    begin
      TPanel(scrlbxBrowse.Components[I]).Top  := c_intYBetween + (I div Count) * (c_intThumbHeight + c_intYBetween);
      TPanel(scrlbxBrowse.Components[I]).Left := c_intXBetween + (I mod Count) * (c_intThumbWidth + c_intXBetween);
    end;
  end;
end;

procedure LoadOriImage(const strImageFileName: String; var bmp: TBitmap);
var
  imgTemp: TGPImage;
begin
  imgTemp := TGPImage.Create(strImageFileName);
  try
    bmp.PixelFormat := pf32bit;
    bmp.Width       := imgTemp.GetWidth;
    bmp.Height      := imgTemp.GetHeight;
    TGPGraphics(TGPGraphics.Create(bmp.Canvas.Handle).DrawImage(imgTemp, 0, 0, bmp.Width, bmp.Height)).Free;
  finally
    imgTemp.Free;
  end;
end;

procedure TfrmImageView.FirstLoadImage(const strFileName: string);
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    if FileExists(strFileName) then
    begin
      LoadOriImage(strFileName, bmp);
      imgView.Hint     := strFileName;
      imgView.Stretch  := FbStretch;
      imgView.AutoSize := not FbStretch;
      StretchZoom(bmp, FbStretch);
      imgView.Picture.Bitmap.Assign(bmp);
    end;
  finally
    bmp.Free;
  end;
end;

procedure TfrmImageView.imgViewDblClick(Sender: TObject);
begin
  pgcAll.ActivePageIndex := 0;
end;

procedure TfrmImageView.imgViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if FbStretch then
    Exit;

  Accept := True;
end;

procedure TfrmImageView.imgViewEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  if FbStretch then
    Exit;

  tmrImageMove.Enabled := False;
end;

procedure TfrmImageView.imgViewStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  if FbStretch then
    Exit;

  tmrImageMove.Enabled := True;
  FPT                  := Mouse.CursorPos;
end;

procedure TfrmImageView.mniViewActSizeClick(Sender: TObject);
begin
  FbStretch := False;
end;

procedure TfrmImageView.mniViewStrectchClick(Sender: TObject);
begin
  FbStretch := True;
end;

procedure TfrmImageView.tmrImageMoveTimer(Sender: TObject);
var
  pt    : TPoint;
  dx, dy: Integer;
begin
  if FbStretch then
    Exit;

  pt := Mouse.CursorPos;
  dx := (FPT.X - pt.X) * 5 div 2; // 2.5 倍速
  dy := (FPT.Y - pt.Y) * 5 div 2; // 2.5 倍速

  if Abs(dx) >= 5 then
    scrlbxImage.HorzScrollBar.Position := scrlbxImage.HorzScrollBar.Position + Trunc(dx * 2.0);
  if Abs(dy) >= 5 then
    scrlbxImage.VertScrollBar.Position := scrlbxImage.VertScrollBar.Position + Trunc(dy * 2.0);

  FPT := pt; // 记录鼠标最后的位置
end;

procedure TfrmImageView.FreeThumbImageList;
var
  I: Integer;
begin
  if scrlbxBrowse.ComponentCount = 0 then
    Exit;

  for I := scrlbxBrowse.ComponentCount - 1 downto 0 do
  begin
    scrlbxBrowse.Components[I].Free;
  end;
end;

procedure TfrmImageView.GetAllImage(const strFolder: String; var lstImage: TStringList);
var
  jpgArr     : TStringDynArray;
  bmpArr     : TStringDynArray;
  pngArr     : TStringDynArray;
  strFileName: String;
begin
  try
    jpgArr := TDirectory.GetFiles(strFolder, '*.jpg', TSearchOption.soTopDirectoryOnly);
    bmpArr := TDirectory.GetFiles(strFolder, '*.bmp', TSearchOption.soTopDirectoryOnly);
    pngArr := TDirectory.GetFiles(strFolder, '*.png', TSearchOption.soTopDirectoryOnly);
    for strFileName in jpgArr do
      lstImage.Add(strFileName);
    for strFileName in bmpArr do
      lstImage.Add(strFileName);
    for strFileName in pngArr do
      lstImage.Add(strFileName);
  except

  end;
end;

procedure TfrmImageView.CreateThumbImageList(const strFolder: string);
var
  lstDir      : TStringDynArray;
  I           : Integer;
  strSubFolder: String;
  lstImage    : TStringList;
begin
  { 是否有子目录，子目录下如果有图片，则建立缩略图 }
  lstDir := TDirectory.GetDirectories(strFolder);
  for I  := Low(lstDir) to High(lstDir) do
  begin
    lstImage := TStringList.Create;
    try
      strSubFolder := lstDir[I];
      if DirectoryExists(strSubFolder) then
      begin
        GetAllImage(strSubFolder, lstImage);
        if lstImage.Count > 0 then
        begin
          lstImage.DelimitedText := strSubFolder;
          CreateThumbImagePanel(lstImage, True);
        end;
      end;
    finally
      lstImage.Free;
    end;
  end;

  { 目录下是否有图片文件，有则创建图片缩略图 }
  lstImage := TStringList.Create;
  try
    GetAllImage(strFolder, lstImage);
    if lstImage.Count > 0 then
      CreateThumbImagePanel(lstImage, False);
  finally
    lstImage.Free;
  end;
end;

procedure TfrmImageView.imgDBLClick(Sender: TObject);
var
  strPathName: String;
  strFileName: String;
begin
  if TWinControl(Sender).Tag = 0 then
  begin
    strPathName                     := TPanel(Sender).Hint;
    FrzshltrFolder.SelectedPathName := strPathName;
    FrzshltrFolder.OnChange(nil, nil);
    Caption := c_strimgSeeCaption + '    ' + strPathName;
  end
  else
  begin
    strFileName := TImage(Sender).Parent.Hint;
    FirstLoadImage(strFileName);
    pgcAll.ActivePageIndex      := 1;
    clbrBrowse.Bands[0].Visible := False;
    clbrBrowse.Bands[1].Visible := True;
    Caption                     := c_strimgSeeCaption + '    ' + strFileName;
  end;
end;

procedure LoadThumbImage(const strImageFileName: String; var bmp: TBitmap);
var
  imgTemp: TGPImage;
begin
  imgTemp := TGPImage.Create(strImageFileName);
  try
    bmp.PixelFormat := pf32bit;
    bmp.Width       := 45;
    bmp.Height      := 45;
    TGPGraphics(TGPGraphics.Create(bmp.Canvas.Handle).DrawImage(imgTemp, 0, 0, 45, 45)).Free;
  finally
    imgTemp.Free;
  end;
end;

function TfrmImageView.SetPanelLeft: Integer;
var
  I, J, Count: Integer;
  intIndex   : Integer;
begin
  { 已经存在的缩略 Panel }
  intIndex := 0;
  for I    := 0 to scrlbxBrowse.ComponentCount - 2 do
  begin
    if scrlbxBrowse.Components[I] is TPanel then
    begin
      inc(intIndex);
    end;
  end;

  { 一行最多可以显示的缩略 Panel 数目 }
  Count := scrlbxBrowse.Width div (c_intThumbWidth + c_intXBetween);

  J      := intIndex mod Count;
  Result := c_intXBetween + J * (c_intThumbWidth + c_intXBetween);
end;

function TfrmImageView.SetPanelTop: Integer;
var
  I, J, Count: Integer;
  intIndex   : Integer;
begin
  { 已经存在的缩略 Panel }
  intIndex := 0;
  for I    := 0 to scrlbxBrowse.ComponentCount - 2 do
  begin
    if scrlbxBrowse.Components[I] is TPanel then
    begin
      inc(intIndex);
    end;
  end;

  { 一行最多可以显示的缩略 Panel 数目 }
  Count := scrlbxBrowse.Width div (c_intThumbWidth + c_intXBetween);

  J      := intIndex div Count;
  Result := c_intYBetween + J * (c_intThumbHeight + c_intYBetween);
end;

procedure TfrmImageView.StretchZoom(const bmp: TBitmap; const bStretch: Boolean);
var
  wZoom, hZoom: Single;
begin
  if bStretch then
  begin
    imgView.Stretch  := True;
    imgView.AutoSize := False;
    wZoom            := (imgView.Parent.Width - 8) / bmp.Width;
    hZoom            := (imgView.Parent.Height - 12) / bmp.Height;
    if wZoom < hZoom then
    begin
      imgView.Width  := Round(bmp.Width * wZoom);
      imgView.Height := imgView.Width * Round(bmp.Height / bmp.Width);
    end
    else
    begin
      imgView.Height := Round(bmp.Height * hZoom);
      imgView.Width  := imgView.Height * Round(bmp.Width / bmp.Height);
    end;
    imgView.Left := (imgView.Parent.Width - imgView.Width) div 2;
    imgView.Top  := (imgView.Parent.Height - imgView.Height) div 2;
  end
  else
  begin
    imgView.Stretch  := False;
    imgView.AutoSize := True;
    if (bmp.Width > imgView.Parent.Width - 8) or (bmp.Height > imgView.Parent.Height - 8) then
    begin
      imgView.Top  := 0;
      imgView.Left := 0;
    end
    else
    begin
      imgView.Left := (imgView.Parent.Width - imgView.Width) div 2;
      imgView.Top  := (imgView.Parent.Height - imgView.Height) div 2;
    end;
  end;
end;

procedure LoadImage(const strImageFileName: String; var bmp: TBitmap);
var
  imgTemp: TGPImage;
begin
  imgTemp := TGPImage.Create(strImageFileName);
  try
    bmp.PixelFormat := pf32bit;
    bmp.Width       := c_intThumbWidth;
    bmp.Height      := c_intThumbHeight;
    TGPGraphics(TGPGraphics.Create(bmp.Canvas.Handle).DrawImage(imgTemp, 0, 0, c_intThumbWidth, c_intThumbHeight)).Free;
  finally
    imgTemp.Free;
  end;
end;

procedure TfrmImageView.CreateThumbImagePanel(const ImageList: TStringList; const bDir: Boolean);
var
  pnl    : TArray<TPanel>;
  I      : Integer;
  bmpTemp: TBitmap;
begin
  if bDir then
  begin
    SetLength(pnl, 1);
    pnl[0]             := TPanel.Create(scrlbxBrowse);
    pnl[0].Parent      := scrlbxBrowse;
    pnl[0].Color       := clWhite;
    pnl[0].Width       := c_intThumbWidth;
    pnl[0].Height      := c_intThumbHeight;
    pnl[0].Top         := SetPanelTop;
    pnl[0].Left        := SetPanelLeft;
    pnl[0].BorderStyle := bsSingle;
    pnl[0].ShowCaption := False;
    pnl[0].BevelOuter  := bvNone;
    pnl[0].Ctl3D       := False;
    pnl[0].Hint        := ImageList.DelimitedText;
    pnl[0].ShowHint    := True;
    pnl[0].Tag         := 0;
    pnl[0].OnDblClick  := imgDBLClick;
    CreateThumbImagePanel(pnl[0], ImageList.DelimitedText);
  end
  else
  begin
    SetLength(pnl, ImageList.Count);
    for I := 0 to ImageList.Count - 1 do
    begin
      pnl[I]             := TPanel.Create(scrlbxBrowse);
      pnl[I].Parent      := scrlbxBrowse;
      pnl[I].Color       := clWhite;
      pnl[I].Width       := c_intThumbWidth;
      pnl[I].Height      := c_intThumbHeight;
      pnl[I].Top         := SetPanelTop;
      pnl[I].Left        := SetPanelLeft;
      pnl[I].BorderStyle := bsNone;
      pnl[I].ShowCaption := False;
      pnl[I].BevelOuter  := bvNone;
      pnl[I].Ctl3D       := False;
      pnl[I].Hint        := ImageList.Strings[I];
      pnl[I].ShowHint    := True;
      with TImage.Create(pnl[I]) do
      begin
        Parent     := pnl[I];
        AutoSize   := True;
        Stretch    := False;
        Align      := alClient;
        Tag        := 1;
        OnDblClick := imgDBLClick;
        bmpTemp    := TBitmap.Create;
        try
          LoadImage(ImageList.Strings[I], bmpTemp);
          Picture.Bitmap.Assign(bmpTemp);
        finally
          bmpTemp.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmImageView.CreateThumbImagePanel(pnl: TPanel; const strFolder: string);
const
  c_imgpos: array [0 .. 3] of TPoint = ((X: 10; Y: 10), (X: 65; Y: 10), (X: 10; Y: 65), (X: 65; Y: 65));
var
  lstImage: TStringList;
  I, Count: Integer;
  bmpTemp : TBitmap;
  imgThumb: TArray<TImage>;
begin
  lstImage := TStringList.Create;
  try
    GetAllImage(strFolder, lstImage);
    if lstImage.Count > 0 then
    begin
      if lstImage.Count > 4 then
        Count := 4
      else
        Count := lstImage.Count;
      SetLength(imgThumb, Count);
      for I := 0 to Count - 1 do
      begin
        bmpTemp := TBitmap.Create;
        try
          LoadThumbImage(lstImage.Strings[I], bmpTemp);
          imgThumb[I]        := TImage.Create(pnl);
          imgThumb[I].Parent := pnl;
          imgThumb[I].Width  := 45;
          imgThumb[I].Height := 45;
          imgThumb[I].Left   := c_imgpos[I].X;
          imgThumb[I].Top    := c_imgpos[I].Y;
          imgThumb[I].Picture.Bitmap.Assign(bmpTemp);
          imgThumb[I].Tag        := 0;
          imgThumb[I].Hint       := strFolder;
          imgThumb[I].OnDblClick := imgDBLClick;
        finally
          bmpTemp.Free;
        end;
      end;
    end;
  finally
    lstImage.Free;
  end;
end;

procedure TfrmImageView.rzshltrFolderChange(Sender: TObject; Node: TTreeNode);
var
  strSelectedFolder: String;
begin
  FreeThumbImageList;

  strSelectedFolder := FrzshltrFolder.SelectedPathName;
  if not DirectoryExists(strSelectedFolder) then
    Exit;

  CreateThumbImageList(strSelectedFolder);
end;

end.
