object FormDbSettings: TFormDbSettings
  Left = 141
  Top = 191
  Hint = 'Role'
  HelpType = htKeyword
  HelpKeyword = 'dbsettings'
  BorderStyle = bsDialog
  Caption = 'Settings'
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
    Left = 176
    Top = 80
    Width = 38
    Height = 13
    Hint = 'Database server address'
    Caption = 'Address'
    ParentShowHint = False
    ShowHint = True
  end
  object LInfo: TLabel
    Left = 40
    Top = 32
    Width = 240
    Height = 19
    Caption = 'Database connection settings'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LDbName: TLabel
    Left = 176
    Top = 104
    Width = 46
    Height = 13
    Hint = 'Database name or alias'
    Caption = 'Database'
    ParentShowHint = False
    ShowHint = True
  end
  object LUser: TLabel
    Left = 176
    Top = 128
    Width = 51
    Height = 13
    Hint = 'Database user name'
    Caption = 'User name'
    ParentShowHint = False
    ShowHint = True
  end
  object Label3: TLabel
    Left = 176
    Top = 152
    Width = 46
    Height = 13
    Hint = 'Password'
    Caption = 'Password'
    ParentShowHint = False
    ShowHint = True
  end
  object LDbCodePage: TLabel
    Left = 176
    Top = 176
    Width = 52
    Height = 13
    Hint = 'Code page'
    Caption = 'Code page'
    ParentShowHint = False
    ShowHint = True
  end
  object LDbRole: TLabel
    Left = 176
    Top = 200
    Width = 22
    Height = 13
    Hint = 'Role'
    Caption = 'Role'
    ParentShowHint = False
    ShowHint = True
  end
  object LDialect: TLabel
    Left = 176
    Top = 224
    Width = 33
    Height = 13
    Hint = 'SQL dialect number'
    Caption = 'Dialect'
    ParentShowHint = False
    ShowHint = True
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
  object EDbSvr: TEdit
    Left = 248
    Top = 80
    Width = 217
    Height = 21
    Hint = 'Database server address'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object EDbName: TEdit
    Left = 248
    Top = 104
    Width = 217
    Height = 21
    Hint = 'Database name or alias'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object EDbUser: TEdit
    Left = 248
    Top = 128
    Width = 217
    Height = 21
    Hint = 'Database user name'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  object EDbPwd: TEdit
    Left = 248
    Top = 152
    Width = 217
    Height = 21
    Hint = 'Password'
    ParentShowHint = False
    PasswordChar = '*'
    ShowHint = True
    TabOrder = 5
  end
  object EDbCodePage: TEdit
    Left = 248
    Top = 176
    Width = 217
    Height = 21
    Hint = 'Code page'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
  end
  object EDbRole: TEdit
    Left = 248
    Top = 200
    Width = 217
    Height = 21
    Hint = 'Role'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
  end
  object EDbDialect: TEdit
    Left = 248
    Top = 224
    Width = 41
    Height = 21
    Hint = 'SQL dialect number'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    Text = '3'
  end
  object UDDbDialect: TUpDown
    Left = 289
    Top = 224
    Width = 18
    Height = 21
    Hint = 'SQL dialect number'
    Associate = EDbDialect
    Min = 1
    Max = 5
    ParentShowHint = False
    Position = 3
    ShowHint = True
    TabOrder = 9
  end
end
