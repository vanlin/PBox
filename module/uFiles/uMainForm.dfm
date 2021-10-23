object frmSuperSearch: TfrmSuperSearch
  Left = 0
  Top = 0
  Caption = #36229#32423#25991#20214#25628#32034' v2.0'
  ClientHeight = 700
  ClientWidth = 1181
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    1181
    700)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 8
    Top = 8
    Width = 84
    Height = 13
    Caption = #26597#35810#26465#20214#25991#20214#65306
  end
  object lblTip: TLabel
    Left = 320
    Top = 7
    Width = 183
    Height = 15
    Caption = #25628#32034#36827#34892#20013#65292#35831#31245#31561'......'
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object mmoLog: TMemo
    Left = 8
    Top = 539
    Width = 1165
    Height = 153
    Anchors = [akLeft, akRight, akBottom]
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
  object btnClose: TBitBtn
    Left = 1150
    Top = 540
    Width = 22
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'X'
    TabOrder = 1
    OnClick = btnCloseClick
  end
  object srchbxFileName: TSearchBox
    Left = 88
    Top = 4
    Width = 217
    Height = 21
    Hint = #20026#31354#26102#65292#26174#31034#25152#26377#25991#20214#12290#25628#32034#23383#31526#38271#24230#19981#24471#23569#20110'2'#20010#23383#31526
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnKeyDown = srchbxFileNameKeyDown
    OnInvokeSearch = srchbxFileNameInvokeSearch
  end
  object btnReSearch: TButton
    Left = 1098
    Top = 3
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #37325#26032#25628#32034
    TabOrder = 3
    OnClick = btnReSearchClick
  end
  object lvFiles: TListView
    Left = 8
    Top = 30
    Width = 1165
    Height = 503
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #24207#21015
        Width = 80
      end
      item
        Caption = #25991#20214#21517#31216
        Width = 600
      end>
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    GridLines = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 4
    ViewStyle = vsReport
    OnData = lvFilesData
  end
  object tmrStart: TTimer
    Interval = 500
    OnTimer = tmrStartTimer
    Left = 88
    Top = 96
  end
end
