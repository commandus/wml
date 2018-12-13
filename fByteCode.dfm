object FormByteCode: TFormByteCode
  Left = 629
  Top = 329
  Width = 393
  Height = 405
  BorderStyle = bsSizeToolWin
  Caption = 'Byte code'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 352
    Width = 385
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object MemoBytes: TMemo
    Left = 0
    Top = 0
    Width = 385
    Height = 352
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentColor = True
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
    WordWrap = False
  end
end
