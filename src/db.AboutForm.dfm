object frmAbout: TfrmAbout
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #20851#20110
  ClientHeight = 232
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 32
    Top = 32
    Width = 39
    Height = 13
    Caption = #21517#31216#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl2: TLabel
    Left = 32
    Top = 58
    Width = 39
    Height = 13
    Caption = #29256#26412#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl3: TLabel
    Left = 113
    Top = 85
    Width = 191
    Height = 13
    Caption = #22522#20110' Dll '#31383#20307#30340#27169#22359#21270#24320#21457#24179#21488
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl4: TLabel
    Left = 113
    Top = 111
    Width = 189
    Height = 13
    Caption = 'Copyright (C) 2021, dbyoung'
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl5: TLabel
    Left = 32
    Top = 138
    Width = 39
    Height = 13
    Caption = #20027#39029#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl6: TLabel
    Left = 32
    Top = 165
    Width = 65
    Height = 13
    Caption = #30005#23376#37038#20214#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl7: TLabel
    Left = 113
    Top = 32
    Width = 35
    Height = 13
    Caption = 'PBox '
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl8: TLabel
    Left = 113
    Top = 58
    Width = 28
    Height = 13
    Caption = 'v4.0'
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl9: TLabel
    Left = 32
    Top = 85
    Width = 39
    Height = 13
    Caption = #21151#33021#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl10: TLabel
    Left = 32
    Top = 112
    Width = 39
    Height = 13
    Caption = #29256#26435#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl11: TLabel
    Left = 32
    Top = 192
    Width = 65
    Height = 13
    Caption = #28304#30721#22320#22336#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lnklblWebAddress: TLinkLabel
    Left = 113
    Top = 138
    Width = 85
    Height = 17
    Hint = 'https://blog.csdn.net/dbyoung'
    Caption = '<a href="https://blog.csdn.net/dbyoung">dbyoung '#30340#21338#23458'</a>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnLinkClick = lnklblWebAddressLinkClick
  end
  object lnklbl1: TLinkLabel
    Left = 113
    Top = 164
    Width = 85
    Height = 17
    Hint = 'dbyoung@sina.com'
    Caption = '<a href="mailto:dbyoung@sina.com">dbyoung '#30340#37038#31665'</a>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnLinkClick = lnklbl1LinkClick
  end
  object lnklbl2: TLinkLabel
    Left = 113
    Top = 190
    Width = 234
    Height = 20
    Hint = 'https://github.com/dbyoung720/PBox.git'
    Caption = 
      '<a href="https://github.com/dbyoung720/PBox.git">https://github.' +
      'com/dbyoung720/PBox.git</a>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnLinkClick = lnklbl1LinkClick
  end
end
