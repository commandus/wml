object FormBlogUser2: TFormBlogUser2
  Left = 189
  Top = 295
  HelpType = htKeyword
  HelpKeyword = 'defaultuser'
  BorderStyle = bsDialog
  Caption = 'Blog user details'
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
  object LFirstName: TLabel
    Left = 160
    Top = 80
    Width = 48
    Height = 13
    Caption = 'First name'
  end
  object LInfo: TLabel
    Left = 40
    Top = 32
    Width = 136
    Height = 19
    Caption = 'Blog user details'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LLastName: TLabel
    Left = 160
    Top = 112
    Width = 49
    Height = 13
    Caption = 'Last name'
  end
  object LNickName: TLabel
    Left = 160
    Top = 144
    Width = 51
    Height = 13
    Caption = 'Nick name'
  end
  object LEmail: TLabel
    Left = 160
    Top = 208
    Width = 27
    Height = 13
    Caption = 'e-mail'
  end
  object LHomePage: TLabel
    Left = 160
    Top = 240
    Width = 53
    Height = 13
    Caption = 'home page'
  end
  object EFirstName: TEdit
    Left = 224
    Top = 80
    Width = 169
    Height = 21
    TabOrder = 0
  end
  object MCustom: TMemo
    Left = 160
    Top = 176
    Width = 233
    Height = 33
    TabStop = False
    BorderStyle = bsNone
    Ctl3D = False
    Lines.Strings = (
      'Contact information')
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 8
  end
  object BBack: TButton
    Left = 216
    Top = 304
    Width = 75
    Height = 25
    Caption = '< Back'
    ModalResult = 7
    TabOrder = 6
  end
  object BOK: TButton
    Left = 296
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Next >'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object BCancel: TButton
    Left = 384
    Top = 304
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
  object ELastName: TEdit
    Left = 224
    Top = 112
    Width = 169
    Height = 21
    TabOrder = 1
  end
  object ENickName: TEdit
    Left = 224
    Top = 144
    Width = 169
    Height = 21
    TabOrder = 2
  end
  object EEmail: TEdit
    Left = 224
    Top = 208
    Width = 169
    Height = 21
    TabOrder = 3
  end
  object EHomePage: TEdit
    Left = 224
    Top = 240
    Width = 169
    Height = 21
    TabOrder = 4
  end
end
