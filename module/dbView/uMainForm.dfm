object frmdbView: TfrmdbView
  Left = 0
  Top = 0
  Caption = #25968#25454#24211#26597#30475#22120' v2.0'
  ClientHeight = 696
  ClientWidth = 1156
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    1156
    696)
  PixelsPerInch = 96
  TextHeight = 13
  object btnConnect: TButton
    Left = 8
    Top = 7
    Width = 177
    Height = 33
    Caption = #21019#24314#25968#25454#24211#36830#25509
    TabOrder = 0
    OnClick = btnConnectClick
  end
  object grpTables: TGroupBox
    Left = 8
    Top = 46
    Width = 177
    Height = 642
    Anchors = [akLeft, akTop, akBottom]
    Caption = #25152#26377#34920#65306
    TabOrder = 1
    object lstTables: TListBox
      Left = 2
      Top = 15
      Width = 173
      Height = 625
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      ItemHeight = 13
      TabOrder = 0
      OnClick = lstTablesClick
    end
  end
  object grpFields: TGroupBox
    Left = 196
    Top = 46
    Width = 297
    Height = 642
    Anchors = [akLeft, akTop, akBottom]
    Caption = #23383#27573#34920#65306
    TabOrder = 2
    object lvFields: TListView
      Left = 2
      Top = 15
      Width = 293
      Height = 625
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Columns = <
        item
          Width = 32
        end
        item
          Caption = #21517#31216
          Width = 80
        end
        item
          Caption = #31867#22411
          Width = 80
        end
        item
          Caption = #20013#25991#21517
          Width = 80
        end>
      GridLines = True
      OwnerDraw = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = lvFieldsClick
      OnDrawItem = lvFieldsDrawItem
    end
  end
  object grpView: TGroupBox
    Left = 504
    Top = 46
    Width = 644
    Height = 642
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = #25968#25454#27983#35272#65306
    TabOrder = 3
    object lvData: TListView
      Left = 2
      Top = 15
      Width = 640
      Height = 625
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Columns = <>
      GridLines = True
      OwnerData = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnData = lvDataData
    end
  end
  object btnSQL: TButton
    Left = 637
    Top = 7
    Width = 119
    Height = 33
    Caption = #33258#23450#20041' SQL '#26597#35810
    TabOrder = 4
    OnClick = btnSQLClick
  end
  object btnExportExcel: TButton
    Left = 1029
    Top = 7
    Width = 119
    Height = 33
    Anchors = [akTop, akRight]
    Caption = #23548#20986#21040' EXCEL'
    TabOrder = 5
    OnClick = btnExportExcelClick
  end
  object btnSearch: TButton
    Left = 504
    Top = 7
    Width = 119
    Height = 33
    Caption = #26597#35810
    TabOrder = 6
    OnClick = btnSearchClick
  end
  object ADOCNN: TADOConnection
    Left = 84
    Top = 118
  end
  object qryTemp: TADOQuery
    Connection = ADOCNN
    Parameters = <>
    Left = 84
    Top = 186
  end
  object qryFieldChineseName: TADOQuery
    Connection = ADOCNN
    Parameters = <>
    Left = 84
    Top = 254
  end
  object qryData: TADOQuery
    Connection = ADOCNN
    Parameters = <>
    Left = 84
    Top = 330
  end
  object dlgSaveExcel: TSaveDialog
    Filter = 'EXCEL|*.xlsx'
    Left = 84
    Top = 434
  end
end
