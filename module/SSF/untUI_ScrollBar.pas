unit untUI_ScrollBar;

interface

uses Windows, Classes, Graphics, Controls, Messages, ExtCtrls, PngImage;

type
  TWScrollBar = class(TCustomPanel)
  private
    procedure WMLButtonDown(var aMsg: TMessage);
    message WM_LButtonDown;
    procedure WMMouseMove(var aMsg: TMessage);
    message WM_MouseMove;
    procedure WMMouseLeave(var aMsg: TMessage);
    message WM_MouseLeave;
    procedure WMLButtonDBClick(var aMsg: TMessage);
    message WM_LBUTTONDBLCLK;
    procedure WMLButtonUp(var aMsg: TMessage);
    message WM_LButtonUp;
    procedure WMERASEBKGND(var Msg: TMessage);
    message WM_ERASEBKGND;
  protected
    Len: Integer;
    thumbTop, thumbbottom: Integer;
    OffsetSC, trackp: tpoint;
    trackthumb: Integer;
    LButtonDown: Boolean;
    sbDir: Integer;
    ScrollPos: Integer;
    procedure Paint; override;
    procedure GetThumb(rc: TRect);
    function GetScrollPos(p: tpoint): Integer;
  public
    FCW: Integer;
    FhWnd: THandle;
    FControl: TWincontrol;
    sbType: byte;
    sbRect: TRect;
    sbVisible: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Attach(aControl: TWincontrol; aType: byte);
    procedure AttachhWnd(ahWnd: THandle; aType: byte);
    procedure SetPosition(ahWnd: THandle);
    procedure ButtonUp;
    procedure HideScrollbar;
  end;

  TScrollBarPos = record
    Btn: Integer;
    ScrollArea: Integer;
    Thumb: Integer;
    ThumbPos: Integer;
    MsgID: Integer;
  end;

  TSkinControl = class(TComponent)
  protected
    procedure Default(var Msg: TMessage);
    procedure Invalidate;
  public
    hWnd: hWnd;
    OldWndProc: TWndMethod;
    Control: TWincontrol;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure NewWndProc(var Message: TMessage);
    procedure AfterProc(var Message: TMessage); virtual;
    procedure PaintControl(aDC: HDC = 0); virtual;
    procedure DrawControl(aDC: HDC; rc: TRect); virtual;
  end;

  TScrollBarState = (ssNormal, ssHover, ssClick);

  TSkinScrollBar = class(TSkinControl)
  protected
    procedure SetScrollbarPos(Message: TMessage);
  public
    vb: TWScrollBar;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitScrollbar(aControl: TWincontrol);
    procedure DrawControl(dc: HDC; rc: TRect); override;
    procedure AfterProc(var Message: TMessage); override;
  end;
{$R *.res}

implementation

const
  iResHeight = 16;

var
  PngSB: TPngImage;

function Point(AX, AY: Integer): tpoint;
begin
  Result.X := AX;
  Result.Y := AY;
end;

function MakeRect(Left, Top, Width, Height: Integer): TRect;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Left + Width;
  Result.Bottom := Top + Height;
end;

procedure DrawRect(DestDC: HDC; DestRect: TRect; SrcDC: HDC; SrcX: Integer; SrcY: Integer);
begin
  BitBlt(DestDC, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left, DestRect.Bottom - DestRect.Top, SrcDC, SrcX, SrcY, SRCCOPY);
end;

procedure StretchRect(DestDC: HDC; DestRect: TRect; SrcDC: HDC; SrcRect: TRect);
begin
  StretchBlt(DestDC, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left, DestRect.Bottom - DestRect.Top, SrcDC, SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, SRCCOPY);
end;

{ 上箭头 }
procedure DrawArrowUp(Canvas: TCanvas; sRect: TRect; sbState: TScrollBarState);
begin
  case sbState of
    ssNormal:
      Canvas.CopyRect(Rect(5, 0, iResHeight + 5, iResHeight), PngSB.Canvas, Rect(0, 0, iResHeight, iResHeight));
    ssHover:
      Canvas.CopyRect(Rect(5, 0, iResHeight + 5, iResHeight), PngSB.Canvas, Rect(iResHeight * 4 + 4, 0, iResHeight + iResHeight * 4 + 4, iResHeight));
    ssClick:
      Canvas.CopyRect(Rect(5, 0, iResHeight + 5, iResHeight), PngSB.Canvas, Rect(iResHeight * 8 + 8, 0, iResHeight + iResHeight * 8 + 8, iResHeight));
  end;
end;

{ 下箭头 }
procedure DrawArrowDown(Canvas: TCanvas; sRect: TRect; sbState: TScrollBarState);
begin
  case sbState of
    ssNormal:
      Canvas.CopyRect(Rect(4, sRect.Bottom - iResHeight, iResHeight + 4, sRect.Bottom), PngSB.Canvas, Rect(16, 0, iResHeight + 16, iResHeight));
    ssHover:
      Canvas.CopyRect(Rect(4, sRect.Bottom - iResHeight, iResHeight + 4, sRect.Bottom), PngSB.Canvas, Rect(iResHeight * 5 + 4, 0, iResHeight + iResHeight * 5 + 4, iResHeight));
    ssClick:
      Canvas.CopyRect(Rect(4, sRect.Bottom - iResHeight, iResHeight + 4, sRect.Bottom), PngSB.Canvas, Rect(iResHeight * 9 + 8, 0, iResHeight + iResHeight * 9 + 8, iResHeight));
  end;
end;

{ 滚动条 }
procedure DrawThumb(Canvas: TCanvas; sRect: TRect; sbState: TScrollBarState);
begin
  case sbState of
    ssNormal:
      begin
        Canvas.Pen.Color := RGB(169, 169, 169);
        Canvas.Brush.Color := RGB(169, 169, 169);
        Canvas.Brush.Style := bsSolid;
        Canvas.RoundRect(sRect.Left + 6, sRect.Top, sRect.Right - 4, sRect.Bottom, 4, 4);
      end;
    ssHover:
      begin
        Canvas.Pen.Color := RGB(139, 139, 139);
        Canvas.Brush.Color := RGB(139, 139, 139);
        Canvas.Brush.Style := bsSolid;
        Canvas.RoundRect(sRect.Left + 6, sRect.Top, sRect.Right - 4, sRect.Bottom, 4, 4);
      end;
    ssClick:
      begin
        Canvas.Pen.Color := RGB(107, 109, 108);
        Canvas.Brush.Color := RGB(107, 109, 108);
        Canvas.Brush.Style := bsSolid;
        Canvas.RoundRect(sRect.Left + 6, sRect.Top, sRect.Right - 4, sRect.Bottom, 4, 4);
      end;
  end;
end;

{ 滚动条背景 }
procedure DrawTrack(Canvas: TCanvas; sRect: TRect);
begin
  Canvas.Pen.Color := RGB(216, 215, 213);
  Canvas.Brush.Color := RGB(216, 215, 213);
  Canvas.Brush.Style := bsSolid;
  Canvas.RoundRect(6, iResHeight, 6 + 7, sRect.Bottom, 4, 4);
end;

{ TSkinControl }

procedure TSkinControl.AfterProc(var Message: TMessage);
begin
  case message.Msg of
    WM_Paint:
      PaintControl(message.WParam);
    WM_KILLFOCUS, WM_SETFOCUS:
      Invalidate;
    WM_SETTEXT:
      Invalidate;
    WM_ENABLE, CM_ENABLEDCHANGED:
      Invalidate;
  end;
end;

constructor TSkinControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  hWnd := 0;
  Control := nil;
end;

procedure TSkinControl.Default(var Msg: TMessage);
begin
  if Assigned(OldWndProc) then
    OldWndProc(Msg);
end;

destructor TSkinControl.Destroy;
begin
  if Assigned(OldWndProc) then
  begin
    if Control <> nil then
      Control.WindowProc := OldWndProc;

    OldWndProc := nil;
  end;

  inherited Destroy;
end;

procedure TSkinControl.DrawControl(aDC: HDC; rc: TRect);
begin

end;

procedure TSkinControl.Invalidate;
begin
  if (hWnd > 0) then
  begin
    InvalidateRect(hWnd, nil, True);
    UpdateWindow(hWnd);
  end;
end;

procedure TSkinControl.NewWndProc(var Message: TMessage);
begin
  Default(Message);
  AfterProc(message);
end;

procedure TSkinControl.PaintControl(aDC: HDC = 0);
var
  dc: HDC;
  Rect: TRect;
begin
  if GetWindowRect(hWnd, Rect) then
  begin
    try
      OffsetRect(Rect, -Rect.Left, -Rect.Top);
      if (aDC = 0) then
      begin
        dc := GetWindowDC(hWnd);
        try
          DrawControl(dc, Rect);
        finally
          ReleaseDC(hWnd, dc);
        end;
      end
      else
        DrawControl(aDC, Rect);
    except
    end;
  end;
end;

{ TWScrollbar }

procedure TWScrollBar.Attach(aControl: TWincontrol; aType: byte);
begin
  FhWnd := aControl.Handle;
  FControl := aControl;
  sbType := aType;
  sbDir := sbType;
  ParentWindow := GetParent(FhWnd);
  SetPosition(FhWnd);
end;

procedure TWScrollBar.AttachhWnd(ahWnd: THandle; aType: byte);
begin
  FhWnd := ahWnd;
  FControl := nil;
  sbType := aType;
  sbDir := sbType;

  ParentWindow := GetParent(FhWnd);
  SetPosition(FhWnd);
end;

procedure TWScrollBar.ButtonUp;
begin
  LButtonDown := False;
  ReleaseCapture;
  if sbType = SB_CTL then
    Invalidate;
end;

constructor TWScrollBar.Create(AOwner: TComponent);
begin
  FControl := nil;
  FCW := GetSystemMetrics(SM_CXHSCROLL);
  FhWnd := 0;
  inherited Create(AOwner);
  ScrollPos := -1;
end;

destructor TWScrollBar.Destroy;
begin
  inherited Destroy;
end;

{ 获取滚动条状态 }
function TWScrollBar.GetScrollPos(p: tpoint): Integer;
var
  X: Integer;
begin
  if sbDir = SB_Horz then
    X := p.X
  else
    X := p.Y;

  if X < FCW then
    Result := SB_LINEUP
  else if X < thumbTop then
    Result := SB_PAGEUP
  else if X < thumbbottom then
    Result := SB_THUMBTRACK
  else if X < Len - FCW then
    Result := SB_PAGEDOWN
  else
    Result := SB_LINEDOWN;
end;

{ 获取滚动条滚动的位置 }
procedure TWScrollBar.GetThumb(rc: TRect);
var
  p: tpoint;
  size: Integer;
begin
  GetCursorPos(p);
  size := thumbbottom - thumbTop;
  thumbTop := trackthumb;
  if (sbDir = sb_Vert) then
    inc(thumbTop, p.Y - trackp.Y)
  else
    inc(thumbTop, p.X - trackp.X);

  if thumbTop < FCW then
    thumbTop := FCW;
  if thumbTop > Len - FCW - size then
    thumbTop := Len - FCW - size;
  thumbbottom := thumbTop + size;
end;

{ 隐藏滚动条 }
procedure TWScrollBar.HideScrollbar;
begin
  ShowWindow(Handle, SW_HIDE);
  sbVisible := False;
  visible := False;
end;

{ 重绘 }
procedure TWScrollBar.Paint;
var
  rc, rc1, rc2: TRect;
  BarInfo: tagScrollBarInfo;
  sbEnable: Boolean;
  Temp: TBitmap;
  bw, sWidth: Integer;
begin
  sWidth := 0;

  { 获取滚动条信息 }
  FillChar(BarInfo, sizeof(BarInfo), #0);
  BarInfo.cbSize := sizeof(BarInfo);
  if not GetScrollBarInfo(FhWnd, Integer(OBJID_VSCROLL), BarInfo) then
    Exit;

  { 滚动条是否可见 }
  if (BarInfo.rgstate[0] and STATE_SYSTEM_INVISIBLE) > 0 then
    Exit;

  rc := BarInfo.rcScrollBar;
  OffsetRect(rc, -rc.Left, -rc.Top);
  if (rc.Bottom < 0) or (rc.Right < 0) then
    Exit;

  if (rc.Bottom > Height) or (rc.Right > Width) then
    Exit;

  if sbType = sb_Vert then
    Len := rc.Bottom
  else
    Len := rc.Right;

  if abs(sWidth - FCW) > 2 then
    sWidth := FCW;

  Temp := TBitmap.Create;

  try
    Temp.Width := rc.Right;
    Temp.Height := rc.Bottom;
  except
    Temp.Free;
    Exit;
  end;

  SetStretchBltMode(Temp.Canvas.Handle, STRETCH_DELETESCANS);
  Temp.Canvas.Brush.Color := clWhite;
  Temp.Canvas.Fillrect(rc);

  if sbType <> SB_CTL then
  begin
    if sbDir = SB_Horz then
      rc.Bottom := sWidth
    else
      rc.Right := sWidth;
  end;

  rc1 := rc;
  bw := FCW;
  if sbDir = SB_Horz then
  begin
    rc1.Left := rc1.Left + bw;
    rc1.Right := rc1.Right - bw;
  end
  else
  begin
    rc1.Top := rc1.Top + bw;
    rc1.Bottom := rc1.Bottom - bw;
    DrawTrack(Temp.Canvas, rc1);
  end;

  rc1 := rc;
  rc2 := rc;

  if rc.Bottom < 2 * bw then
    bw := rc.Bottom div 2;
  rc1.Bottom := rc1.Top + bw;
  rc2.Top := rc2.Bottom - bw;

  if (ScrollPos = SB_LINEUP) then
  begin
    if LButtonDown then
      DrawArrowUp(Temp.Canvas, rc1, ssClick)
    else
      DrawArrowUp(Temp.Canvas, rc1, ssHover);
  end
  else
    DrawArrowUp(Temp.Canvas, rc1, ssNormal);

  if (ScrollPos = SB_LINEDOWN) then
  begin
    if LButtonDown then
      DrawArrowDown(Temp.Canvas, rc2, ssClick)
    else
      DrawArrowDown(Temp.Canvas, rc2, ssHover);
  end
  else
    DrawArrowDown(Temp.Canvas, rc2, ssNormal);

  thumbTop := BarInfo.xyThumbTop;
  thumbbottom := BarInfo.xyThumbBottom;
  sbEnable := (BarInfo.rgstate[0] and STATE_SYSTEM_UNAVAILABLE) = 0;
  if sbEnable then
  begin
    if (sbDir = sb_Vert) then
    begin
      rc1 := Rect(0, thumbTop, sWidth, thumbbottom);
      if (thumbTop < Height) and (thumbbottom < Height) then
      begin
        if (ScrollPos = SB_THUMBTRACK) then
        begin
          if LButtonDown then
            DrawThumb(Temp.Canvas, rc1, ssClick)
          else
          begin
            if (rc1.Top = FCW - 1) and (rc1.Bottom = Height - FCW - 1) then
            begin

            end
            else
            begin
              DrawThumb(Temp.Canvas, rc1, ssHover);
            end;
          end;
        end
        else
        begin
          if (rc1.Top = FCW - 1) and (rc1.Bottom = Height - FCW - 1) then
          begin

          end
          else
          begin
            if (rc1.Bottom <> 2 * FCW - 1) then
              DrawThumb(Temp.Canvas, rc1, ssNormal);
          end;
        end;
      end;
    end;
  end;
  rc := ClientRect;

  StretchBlt(Canvas.Handle, 0, 0, Temp.Width, Temp.Height, Temp.Canvas.Handle, 0, 0, Temp.Width, Temp.Height, SRCCOPY);

  Temp.Free;
end;

procedure TWScrollBar.SetPosition(ahWnd: THandle);
var
  parenthWnd, prehWnd: THandle;
  r1: TRect;
  p: tpoint;
  BarInfo: tagScrollBarInfo;
  b: Boolean;
  dw: dword;
begin
  FhWnd := ahWnd;
  parenthWnd := GetParent(FhWnd);
  FillChar(BarInfo, sizeof(BarInfo), #0);
  BarInfo.cbSize := sizeof(BarInfo);
  sbVisible := True;

  if sbType = sb_Vert then
  begin
    b := GetScrollBarInfo(FhWnd, Integer(OBJID_VSCROLL), BarInfo);

    sbVisible := b;

    if not b then
      Exit;

    dw := GetWindowLong(FhWnd, GWL_STYLE);
    if (dw and ws_visible) = 0 then
    begin
      sbVisible := False;
      ShowWindow(Handle, SW_HIDE);
      Exit;
    end;

    if ((BarInfo.rgstate[0] and STATE_SYSTEM_INVISIBLE) > 0) then
    begin
      if sbDir = sb_Vert then
        ShowWindow(Handle, SW_HIDE)
      else
        ShowWindow(Handle, SW_HIDE);

      sbVisible := False;
    end
    else
    begin
      r1 := BarInfo.rcScrollBar;

      p := r1.TopLeft;
      Windows.screentoclient(FhWnd, p);
      sbRect.TopLeft := p;
      p := r1.BottomRight;
      Windows.screentoclient(FhWnd, p);
      sbRect.BottomRight := p;

      OffsetRect(r1, -r1.Left, -r1.Top);
      if sbDir = sb_Vert then
        Len := r1.Bottom
      else
        Len := r1.Right;

      p := Point(BarInfo.rcScrollBar.Left, BarInfo.rcScrollBar.Top);
      OffsetSC := p;
      Windows.screentoclient(parenthWnd, p);

      prehWnd := GetNextWindow(FhWnd, GW_hWndPREV);
      if prehWnd = 0 then
        prehWnd := hWnd_TOP;
      ShowWindow(Handle, SW_Show);
      sbVisible := True;

      SetWindowPos(Handle, prehWnd, p.X, p.Y, r1.Right, r1.Bottom, 0); // SWP_NOREDRAW);
      MoveWindow(Handle, p.X, p.Y, r1.Right, r1.Bottom, True);
    end;
  end;
end;

procedure TWScrollBar.WMERASEBKGND(var Msg: TMessage);
begin
  Msg.Result := 1;
end;

procedure TWScrollBar.WMLButtonDBClick(var aMsg: TMessage);
begin
  WMLButtonDown(aMsg);
end;

procedure TWScrollBar.WMLButtonDown(var aMsg: TMessage);
var
  pt: tpoint;
  BarInfo: tagScrollBarInfo;
begin
  inherited;
  pt := Point(aMsg.LParamLo, aMsg.LParamhi);
  GetCursorPos(trackp);
  FillChar(BarInfo, sizeof(BarInfo), #0);
  BarInfo.cbSize := sizeof(BarInfo);
  if sbType = sb_Vert then
  begin
    if GetScrollBarInfo(FhWnd, Integer(OBJID_VSCROLL), BarInfo) then
    begin
      trackthumb := BarInfo.xyThumbTop;
    end;

    ScrollPos := GetScrollPos(pt);

    OffsetSC := Point(BarInfo.rcScrollBar.Left, BarInfo.rcScrollBar.Top);
    aMsg.LParamLo := aMsg.LParamLo + OffsetSC.X; // inc(amsg.LParamLo,offsetSc.x);
    aMsg.LParamhi := aMsg.LParamhi + OffsetSC.Y; // inc(amsg.LParamHi,offsetSc.y);

    LButtonDown := True;
    Invalidate;
    ScrollPos := GetScrollPos(pt);
    ReleaseCapture;

    if sbType = sb_Vert then
    begin
      PostMessage(FhWnd, WM_NCLBUTTONDOWN, HTVSCROLL, aMsg.lparam);
      LButtonDown := False;
      ReleaseCapture;
    end;
  end;
end;

procedure TWScrollBar.WMLButtonUp(var aMsg: TMessage);
begin
  inherited;

  LButtonDown := False;
  ReleaseCapture;

  PostMessage(FhWnd, WM_NCLBUTTONUP, HTVSCROLL, aMsg.lparam)
end;

procedure TWScrollBar.WMMouseLeave(var aMsg: TMessage);
begin
  if not LButtonDown then
  begin
    ScrollPos := -1;
    Invalidate;
  end;
end;

procedure TWScrollBar.WMMouseMove(var aMsg: TMessage);
var
  ptMouse: tpoint;
  iPos: Integer;
begin
  inherited;
  PostMessage(FhWnd, WM_NCMOUSEMOVE, HTVSCROLL, aMsg.lparam);
  ptMouse := Point(aMsg.LParamLo, aMsg.LParamhi);
  iPos := GetScrollPos(ptMouse);
  if iPos <> ScrollPos then
  begin
    ScrollPos := iPos;
    Invalidate;
  end;
end;

{ TSkinScrollBar }

procedure TSkinScrollBar.AfterProc(var Message: TMessage);
begin
  case message.Msg of
    CM_VISIBLECHANGED:
      begin
        if message.WParam = 0 then
          vb.HideScrollbar
        else
          SetScrollbarPos(message);
      end;
    CM_ENABLEDCHANGED:
      begin
        vb.Enabled := Control.Enabled;
      end;
    CM_RECREATEWND:
      begin
      end;
    WM_Size, WM_WINDOWPOSCHANGED:
      begin
        SetScrollbarPos(message);
      end;
    WM_VSCROLL:
      begin
        vb.ScrollPos := message.WParamLo;
        vb.Invalidate;
      end;
    WM_MOUSEWHEEL:
      begin
        if (vb <> nil) and vb.sbVisible then
        begin
          vb.Invalidate;
        end;
      end;
  else
    inherited AfterProc(message);
  end;
end;

constructor TSkinScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  vb := nil;
end;

destructor TSkinScrollBar.Destroy;
begin
  if vb <> nil then
    vb.Free;

  vb := nil;

  inherited;
end;

procedure TSkinScrollBar.DrawControl(dc: HDC; rc: TRect);
var
  Style: dword;
begin
  Style := GetWindowLong(hWnd, GWL_STYLE);
  if (vb <> nil) then
  begin
    if vb.sbVisible then
      vb.Invalidate
    else if (Style and WS_VSCROLL) > 0 then
      vb.SetPosition(hWnd);
  end;
end;

procedure TSkinScrollBar.InitScrollbar(aControl: TWincontrol);
begin
  Control := aControl;
  hWnd := Control.Handle;

  vb := TWScrollBar.Create(Self);
  vb.Attach(Control, sb_Vert);
  vb.Enabled := Control.Enabled;

  if not Control.visible then
    vb.HideScrollbar;

  OldWndProc := Control.WindowProc;
  Control.WindowProc := NewWndProc;
end;

procedure TSkinScrollBar.SetScrollbarPos(Message: TMessage);
begin
  if vb <> nil then
    vb.SetPosition(hWnd);
end;

initialization

PngSB := TPngImage.Create;
PngSB.LoadFromResourceName(HInstance, 'RES_SCROLLBAR');

finalization

PngSB.Free;

end.
