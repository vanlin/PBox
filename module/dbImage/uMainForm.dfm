object frmImageView: TfrmImageView
  Left = 0
  Top = 0
  Caption = #22270#20687#26597#30475#22120' v2.0'
  ClientHeight = 659
  ClientWidth = 1089
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pgcAll: TPageControl
    Left = 0
    Top = 56
    Width = 1089
    Height = 603
    ActivePage = tsView
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    Style = tsButtons
    TabOrder = 0
    object tsBrowse: TTabSheet
      Caption = 'tsBrowse'
      object scrlbxBrowse: TScrollBox
        Left = 0
        Top = 0
        Width = 1081
        Height = 572
        VertScrollBar.Smooth = True
        VertScrollBar.Tracking = True
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 0
      end
    end
    object tsView: TTabSheet
      Caption = 'tsView'
      ImageIndex = 1
      object scrlbxImage: TScrollBox
        Left = 0
        Top = 0
        Width = 1081
        Height = 572
        HorzScrollBar.Smooth = True
        HorzScrollBar.Tracking = True
        VertScrollBar.Smooth = True
        VertScrollBar.Tracking = True
        Align = alClient
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 0
        OnDblClick = imgViewDblClick
        object imgView: TImage
          Left = 0
          Top = 0
          Width = 60
          Height = 60
          AutoSize = True
          DragCursor = crSizeAll
          DragMode = dmAutomatic
          OnDblClick = imgViewDblClick
          OnDragOver = imgViewDragOver
          OnEndDrag = imgViewEndDrag
          OnStartDrag = imgViewStartDrag
        end
      end
    end
  end
  object clbrBrowse: TCoolBar
    Left = 0
    Top = 0
    Width = 1089
    Height = 56
    AutoSize = True
    Bands = <
      item
        Control = tlbBrowse
        ImageIndex = -1
        Width = 1089
      end
      item
        Control = tlbView
        ImageIndex = -1
        Visible = False
        Width = 1089
      end>
    object tlbBrowse: TToolBar
      Left = 9
      Top = 0
      Width = 1076
      Height = 25
      ButtonHeight = 0
      ButtonWidth = 0
      Caption = 'tlbBrowse'
      Menu = mmBrowse
      ShowCaptions = True
      TabOrder = 0
    end
    object tlbView: TToolBar
      Left = 9
      Top = 27
      Width = 1076
      Height = 25
      ButtonHeight = 0
      ButtonWidth = 0
      Caption = 'tlbView'
      Menu = mmView
      ShowCaptions = True
      TabOrder = 1
      Visible = False
    end
  end
  object tmrImageMove: TTimer
    Enabled = False
    Interval = 30
    OnTimer = tmrImageMoveTimer
    Left = 392
    Top = 804
  end
  object mmBrowse: TMainMenu
    AutoHotkeys = maManual
    Left = 224
    Top = 122
    object mniBrowseFile: TMenuItem
      Caption = #25991#20214
      object mniBrowseFileOpen: TMenuItem
        Caption = #25171#24320
      end
    end
    object mniTools: TMenuItem
      Caption = #24037#20855
      object mniToolsConvert: TMenuItem
        Caption = #25209#37327#36716#21270'...'
      end
      object mniToolsSnapScreen: TMenuItem
        Caption = #23631#24149#25130#22270'...'
      end
      object mniToolsSlide: TMenuItem
        Caption = #24187#28783#29255#25773#25918
      end
    end
  end
  object mmView: TMainMenu
    AutoHotkeys = maManual
    Left = 224
    Top = 179
    object mniViewFile: TMenuItem
      Caption = #25991#20214
      object mniViewFileOpen: TMenuItem
        Caption = #25171#24320
      end
      object mniViewFileLine01: TMenuItem
        Caption = '-'
      end
      object mniViewFileRestore: TMenuItem
        Caption = #24674#22797
      end
    end
    object mniView: TMenuItem
      Caption = #35270#22270
      object mniViewActSize: TMenuItem
        Caption = #23454#38469#22823#23567
        OnClick = mniViewActSizeClick
      end
      object mniViewStrectch: TMenuItem
        Caption = #25289#20280#20197#31526#21512#31383#21475
        Checked = True
        OnClick = mniViewStrectchClick
      end
    end
    object mniColor: TMenuItem
      Caption = #39068#33394
      object mniColorGray: TMenuItem
        Caption = #28784#24230#22270
      end
      object mniColorInvert: TMenuItem
        Caption = #21453#33394
      end
      object mniColorLine01: TMenuItem
        Caption = '-'
      end
      object mniColorBrightness: TMenuItem
        Caption = #35843#33410#20142#24230'...'
      end
      object mniColorContrast: TMenuItem
        Caption = #35843#33410#23545#27604#24230'...'
      end
      object mniColorSaturation: TMenuItem
        Caption = #35843#33410#39281#21644#24230'...'
      end
      object mniColorGamma: TMenuItem
        Caption = #35843#33410'Gamma...'
      end
      object mniColorLine02: TMenuItem
        Caption = '-'
      end
      object mniColorHSV: TMenuItem
        Caption = #35843#33410'HSV...'
      end
      object mniColorYCbCr: TMenuItem
        Caption = #35843#33410'YCbCr...'
      end
      object mniColorCMY: TMenuItem
        Caption = #35843#33410'CMY...'
      end
      object mniColorCMYK: TMenuItem
        Caption = #35843#33410'CMYK...'
      end
      object mniColorYCoCg: TMenuItem
        Caption = #35843#33410'YCoCg...'
      end
      object mniColor03: TMenuItem
        Caption = '-'
      end
      object mniColorTranslate: TMenuItem
        Caption = #35843#33410#36879#26126#24230'...'
      end
    end
    object mniGeometry: TMenuItem
      Caption = #20960#20309
      object mniGeometryHorizonMirror: TMenuItem
        Caption = #27700#24179#32763#36716
      end
      object mniGeometryVerticalMirror: TMenuItem
        Caption = #22402#30452#32763#36716
      end
      object mniGeometryHVMirror: TMenuItem
        Caption = #35013#32622
      end
      object mniGeometry2DRotate: TMenuItem
        Caption = '2D'#26059#36716'...'
      end
      object mniGeometry3DRotate: TMenuItem
        Caption = '3D'#26059#36716'...'
      end
    end
    object mniEffect: TMenuItem
      Caption = #25928#26524
      object mniEffectExposure: TMenuItem
        Caption = #26333#20809
      end
      object mniEffectBoss: TMenuItem
        Caption = #28014#38613
      end
      object mniEffectCarve: TMenuItem
        Caption = #38613#21051
      end
      object mniEffectBlur: TMenuItem
        Caption = #27169#31946
      end
      object mniEffectSharp: TMenuItem
        Caption = #38160#21270
      end
      object mniEffectOilPainting: TMenuItem
        Caption = #27833#30011
      end
      object mniEffectFrosted: TMenuItem
        Caption = #30952#30722
      end
      object mniEffectShake: TMenuItem
        Caption = #25238#21160
      end
      object mniEffectWater: TMenuItem
        Caption = #27700#27874
      end
    end
  end
end
