object FormCodePage: TFormCodePage
  Left = 141
  Top = 191
  Hint = 'Select code page'
  HelpType = htKeyword
  HelpKeyword = 'codepage'
  BorderStyle = bsDialog
  Caption = 'Set codepage'
  ClientHeight = 345
  ClientWidth = 503
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmAuto
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LProvider: TLabel
    Left = 176
    Top = 80
    Width = 52
    Height = 13
    Caption = 'Code page'
  end
  object LInfo: TLabel
    Left = 40
    Top = 32
    Width = 127
    Height = 19
    Caption = 'Force codepage'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object CBCodePage: TComboBox
    Left = 248
    Top = 80
    Width = 169
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = 'UTF-8'
    Items.Strings = (
      'UTF-8'
      'ISO-8859-1'
      'ISO-8859-2'
      'ISO-8859-3'
      'ISO-8859-4'
      'ISO-8859-5'
      'ISO-8859-6'
      'ISO-8859-7'
      'ISO-8859-8'
      'ISO-8859-9'
      'ISO-8859-10'
      'ISO-8859-13'
      'ISO-8859-14'
      'ISO-8859-15'
      'Latin-1'
      'Latin-2'
      'Latin-3'
      'Latin-4'
      'Latin-5'
      'Latin-6'
      'Latin-7'
      'Latin-8'
      'Latin-9'
      'Cyrillic'
      'Arabic'
      'Greek'
      'Hebrew'
      'KOI8-R'
      'cp10000_MacRoman'
      'windows-1250'
      'windows-1251'
      'windows-1252'
      'cp1250'
      'cp1251'
      'cp1252')
  end
  object BOK: TButton
    Left = 296
    Top = 304
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object BCancel: TButton
    Left = 384
    Top = 304
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
