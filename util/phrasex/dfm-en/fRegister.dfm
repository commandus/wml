object FormRegister: TFormRegister
  Left = 492
  Top = 134
  BorderStyle = bsDialog
  Caption = 'Register your copy now'
  ClientHeight = 262
  ClientWidth = 445
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  PopupMode = pmAuto
  Position = poScreenCenter
  OnActivate = FormActivate
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
  object Label3: TLabel
    Left = 112
    Top = 188
    Width = 83
    Height = 13
    Hint = 'Cut and paste registration code from message you received'
    Caption = 'Registration &code'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
  end
  object LName: TLabel
    Left = 112
    Top = 156
    Width = 28
    Height = 13
    Hint = 'Case sensitive'
    Caption = '&Name'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
  end
  object Label1: TLabel
    Left = 112
    Top = 124
    Width = 64
    Height = 13
    Caption = '&Product code'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 112
    Top = 16
    Width = 202
    Height = 13
    Caption = '1. Enter button to connect internet registrar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 110
    Top = 88
    Width = 199
    Height = 13
    Caption = '2. Copy name and code from the message'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object BEnterCode: TButton
    Left = 320
    Top = 228
    Width = 105
    Height = 25
    Hint = 'Enter received code'
    HelpType = htKeyword
    HelpKeyword = 'regenter'
    Caption = '&Enter code'
    Default = True
    ModalResult = 1
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object BCancel: TButton
    Left = 216
    Top = 228
    Width = 98
    Height = 25
    Hint = 'Cancel and close dialog'
    HelpType = htKeyword
    HelpKeyword = 'regcancel'
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 1
  end
  object ERegCode: TEdit
    Left = 216
    Top = 179
    Width = 209
    Height = 21
    Hint = 'Registration code'
    HelpType = htKeyword
    HelpKeyword = 'regcode'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  object BRegister: TButton
    Left = 216
    Top = 52
    Width = 145
    Height = 25
    Hint = 'Request registration code'
    HelpType = htKeyword
    HelpKeyword = 'requestregcode'
    Caption = '&Request code'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = BRegisterClick
  end
  object EUserName: TEdit
    Left = 216
    Top = 152
    Width = 209
    Height = 21
    Hint = 'Registration name'
    HelpType = htKeyword
    HelpKeyword = 'regname'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  object EProduct: TEdit
    Left = 216
    Top = 121
    Width = 129
    Height = 21
    Hint = 'product code'
    HelpType = htKeyword
    HelpKeyword = 'productcode'
    Color = clInactiveBorder
    Enabled = False
    ParentShowHint = False
    ReadOnly = True
    ShowHint = True
    TabOrder = 5
    Text = 'bloxy'
  end
  object MHttp: TMemo
    Left = 113
    Top = 32
    Width = 313
    Height = 19
    Cursor = crHandPoint
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      '%s')
    ParentColor = True
    ParentFont = False
    ReadOnly = True
    TabOrder = 6
    WordWrap = False
    OnClick = BRegisterClick
  end
end
