object FormBlogUser: TFormBlogUser
  Left = 227
  Top = 357
  Hint = 'Set default user properties'
  HelpType = htKeyword
  HelpKeyword = 'defaultuser'
  BorderStyle = bsDialog
  Caption = 'Blog user name and password'
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LProvider: TLabel
    Left = 160
    Top = 128
    Width = 51
    Height = 13
    Caption = 'User name'
  end
  object LHost: TLabel
    Left = 160
    Top = 168
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object LInfo: TLabel
    Left = 40
    Top = 32
    Width = 243
    Height = 19
    Caption = 'Blog user name and password'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object EUsername: TEdit
    Left = 224
    Top = 128
    Width = 169
    Height = 21
    TabOrder = 0
  end
  object MCustom: TMemo
    Left = 160
    Top = 80
    Width = 233
    Height = 33
    TabStop = False
    BorderStyle = bsNone
    Ctl3D = False
    Lines.Strings = (
      'Each blogger host requires authentification. You '
      'must have user credentials already.')
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 5
  end
  object EPassword: TEdit
    Left = 224
    Top = 168
    Width = 161
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
  end
  object BBack: TButton
    Left = 216
    Top = 304
    Width = 75
    Height = 25
    Caption = '< Back'
    ModalResult = 7
    TabOrder = 3
  end
  object BOK: TButton
    Left = 296
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Next >'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object BCancel: TButton
    Left = 384
    Top = 304
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
