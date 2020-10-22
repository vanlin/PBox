object frmSQL: TfrmSQL
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'SQL '#35821#21477#65306
  ClientHeight = 323
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  DesignSize = (
    635
    323)
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 442
    Top = 286
    Width = 85
    Height = 29
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    TabOrder = 0
    OnClick = btnCancelClick
  end
  object btnOK: TButton
    Left = 538
    Top = 286
    Width = 89
    Height = 29
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    TabOrder = 1
    OnClick = btnOKClick
  end
end
