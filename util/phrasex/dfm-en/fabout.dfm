object AboutBox: TAboutBox
  Left = 498
  Top = 73
  HelpType = htKeyword
  HelpKeyword = 'about'
  BorderStyle = bsDialog
  Caption = 'About Bloxy'
  ClientHeight = 262
  ClientWidth = 444
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ProgramIcon: TImage
    Left = 0
    Top = 0
    Width = 100
    Height = 262
    Align = alLeft
    AutoSize = True
    ParentShowHint = False
    ShowHint = True
    Stretch = True
    OnClick = ProgramIconClick
    OnDblClick = LRegisteredDblClick
    IsControl = True
    ExplicitLeft = -6
  end
  object LMail: TLabel
    Left = 120
    Top = 68
    Width = 156
    Height = 13
    Cursor = crHandPoint
    Hint = #1054#1073#1088#1072#1090#1085#1072#1103' '#1089#1074#1103#1079#1100
    Caption = 'mailto:support@commandus.com'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentColor = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    WordWrap = True
    OnClick = LEMailClick
    OnDblClick = LEMailClick
    IsControl = True
  end
  object LHttp: TLabel
    Left = 120
    Top = 46
    Width = 116
    Height = 13
    Cursor = crHandPoint
    Hint = #1044#1086#1084#1072#1096#1085#1103#1103' '#1089#1090#1088#1072#1085#1080#1094#1072
    Caption = 'http://commandus.com/'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentColor = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    WordWrap = True
    OnClick = LHttpClick
    OnDblClick = LHttpClick
    IsControl = True
  end
  object LReadMe: TLabel
    Left = 120
    Top = 92
    Width = 43
    Height = 13
    Cursor = crHandPoint
    Hint = 'readme.txt'
    Caption = 'Read me'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentColor = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    WordWrap = True
    OnClick = LReadMeClick
    OnDblClick = LReadMeClick
    IsControl = True
  end
  object LLicense: TLabel
    Left = 248
    Top = 92
    Width = 113
    Height = 26
    Cursor = crHandPoint
    Hint = 'license.txt'
    Caption = 'License agreement'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentColor = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    WordWrap = True
    OnClick = LReadMeClick
    OnDblClick = LReadMeClick
    IsControl = True
  end
  object PanelIntro: TPanel
    Left = 100
    Top = 0
    Width = 344
    Height = 262
    Align = alClient
    Caption = '. . .'
    Color = clBlack
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -27
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    Visible = False
  end
  object OKButton: TButton
    Left = 128
    Top = 215
    Width = 97
    Height = 25
    Hint = 'Close window'
    Cancel = True
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = OKButtonClick
  end
  object MemoInfo: TMemo
    Left = 120
    Top = 128
    Width = 305
    Height = 81
    BorderStyle = bsNone
    Ctl3D = False
    Lines.Strings = (
      'Partially Copyright wdbxml.dll, dbxmlXXX.dll database to xml '
      'report engine, Commandus software development group '#169' '
      '2002-2006 '
      'http://commandus.com// All rights reserved.'
      ''
      'Partially Copyright Microsoft'#174' Reader LITGEN 1.5.1.0280 '
      
        'Microsoft'#174' is a registered trademark of Microsoft Corporation in' +
        ' '
      'the U.S. and/or other countries.')
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 1
  end
  object BRegister: TButton
    Left = 336
    Top = 215
    Width = 89
    Height = 25
    Caption = 'Register'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = BRegisterClick
  end
end
