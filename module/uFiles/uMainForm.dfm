object frmNTFSFiles: TfrmNTFSFiles
  Left = 0
  Top = 0
  Caption = 'NTFS '#25991#20214#25628#32034' v1.0'
  ClientHeight = 662
  ClientWidth = 1094
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    1094
    662)
  PixelsPerInch = 96
  TextHeight = 13
  object lblTip: TLabel
    Left = 443
    Top = 8
    Width = 224
    Height = 15
    Caption = #27491#22312#25628#32034#65292#35831#31245#20505#183#183#183#183#183#183
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object srchbxFile: TSearchBox
    Left = 8
    Top = 4
    Width = 245
    Height = 21
    TabOrder = 1
    Visible = False
    OnInvokeSearch = srchbxFileInvokeSearch
  end
  object lvData: TListView
    Left = 8
    Top = 32
    Width = 1078
    Height = 622
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #24207#21015
        Width = 100
      end
      item
        Caption = #25991#20214#21517
        Width = 900
      end>
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    GridLines = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 0
    ViewStyle = vsReport
    OnData = lvDataData
  end
  object btnReSearch: TButton
    Left = 992
    Top = 3
    Width = 94
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #20877#27425#20840#30424#25628#32034
    TabOrder = 2
    Visible = False
    OnClick = btnReSearchClick
  end
  object tmrSearchStart: TTimer
    OnTimer = tmrSearchStartTimer
    Left = 48
    Top = 96
  end
  object tmrSearchStop: TTimer
    Enabled = False
    OnTimer = tmrSearchStopTimer
    Left = 52
    Top = 172
  end
  object tmrGetFileFullNameStart: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = tmrGetFileFullNameStartTimer
    Left = 232
    Top = 100
  end
  object ADOCNN: TADOConnection
    Left = 80
    Top = 304
  end
end
