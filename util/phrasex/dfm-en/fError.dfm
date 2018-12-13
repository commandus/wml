object FormError: TFormError
  Left = 437
  Top = 128
  Hint = 'Fatal error occured'
  HelpType = htKeyword
  HelpKeyword = 'fatalerror'
  BorderStyle = bsDialog
  Caption = 'Fatal appication error occured'
  ClientHeight = 262
  ClientWidth = 435
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PopupMode = pmAuto
  Position = poScreenCenter
  OnCreate = FormCreate
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
    IsControl = True
  end
  object LMail: TLabel
    Left = 256
    Top = 202
    Width = 156
    Height = 13
    Cursor = crHandPoint
    Hint = 'Send report by e-mail'
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
  object LReadMe: TLabel
    Left = 120
    Top = 172
    Width = 40
    Height = 13
    Cursor = crHandPoint
    Hint = 'readme.txt'
    Caption = 'Last info'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentColor = False
    ParentFont = False
    WordWrap = True
    OnClick = LReadMeClick
    OnDblClick = LReadMeClick
    IsControl = True
  end
  object LLicense: TLabel
    Left = 120
    Top = 202
    Width = 49
    Height = 13
    Cursor = crHandPoint
    Hint = 'bugreport.txt'
    Caption = 'Bug report'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentColor = False
    ParentFont = False
    WordWrap = True
    OnClick = LReadMeClick
    OnDblClick = LReadMeClick
    IsControl = True
  end
  object LHeader: TLabel
    Left = 120
    Top = 24
    Width = 259
    Height = 33
    Caption = 'Fatal application error'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LHttp: TLabel
    Left = 256
    Top = 175
    Width = 143
    Height = 13
    Cursor = crHandPoint
    Hint = 'Visit program'#39's web site'
    Caption = 'http://www.commandus.com/'
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
  object OKButton: TButton
    Left = 120
    Top = 229
    Width = 97
    Height = 25
    Caption = 'Continue anyway'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object MemoInfo: TMemo
    Left = 120
    Top = 55
    Width = 305
    Height = 47
    BorderStyle = bsNone
    Ctl3D = False
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 1
  end
  object BCancel: TButton
    Left = 223
    Top = 229
    Width = 204
    Height = 25
    Cancel = True
    Caption = 'Close application (recommended)'
    ModalResult = 2
    TabOrder = 2
  end
  object MemoDesc: TMemo
    Left = 122
    Top = 97
    Width = 305
    Height = 72
    BorderStyle = bsNone
    Ctl3D = False
    Lines.Strings = (
      'Please send bug report by e-mail or use web-based bug-tracking '
      'system. To do so, please click corresponding link below.'
      ''
      'It is recommended immediately terminate program by pressing '
      '[Esc].')
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 3
  end
end
