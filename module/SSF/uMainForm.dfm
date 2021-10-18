object frmSuperSearch: TfrmSuperSearch
  Left = 0
  Top = 0
  Caption = #36229#32423#25991#20214#25628#32034' v2.0'
  ClientHeight = 700
  ClientWidth = 935
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    935
    700)
  PixelsPerInch = 96
  TextHeight = 13
  object lvFiles: TListView
    Left = 8
    Top = 8
    Width = 913
    Height = 684
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #24207#21495
        Width = 150
      end
      item
        Caption = #25991#20214#21517#31216
        Width = 650
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object tmrStart: TTimer
    Interval = 500
    OnTimer = tmrStartTimer
    Left = 88
    Top = 96
  end
end
