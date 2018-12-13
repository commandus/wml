object FormCallerProxy: TFormCallerProxy
  Left = 141
  Top = 191
  Hint = 'Set internet connection settings'
  HelpType = htKeyword
  HelpKeyword = 'inetconn'
  BorderStyle = bsDialog
  Caption = 'HTTP proxy setings'
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
  object LInfo: TLabel
    Left = 40
    Top = 32
    Width = 96
    Height = 19
    Caption = 'HTTP proxy'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object MCustom: TMemo
    Left = 224
    Top = 48
    Width = 233
    Height = 49
    TabStop = False
    BorderStyle = bsNone
    Ctl3D = False
    Lines.Strings = (
      'If Bloxy proxy server is behind the proxy server, '
      'specify HTTP proxy server.')
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 4
  end
  object BOK: TButton
    Left = 296
    Top = 304
    Width = 75
    Height = 25
    Caption = 'OK'
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
    TabOrder = 3
  end
  object CBHTTPProxy: TCheckBox
    Left = 224
    Top = 96
    Width = 137
    Height = 17
    Caption = 'Enable HTTP proxy'
    TabOrder = 0
    OnClick = CBHTTPProxyClick
  end
  object GBHTTPProxy: TGroupBox
    Left = 224
    Top = 112
    Width = 257
    Height = 161
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 1
    object LHost: TLabel
      Left = 8
      Top = 20
      Width = 38
      Height = 13
      Caption = 'Address'
    end
    object LPort: TLabel
      Left = 8
      Top = 44
      Width = 19
      Height = 13
      Caption = 'Port'
    end
    object LUserName: TLabel
      Left = 8
      Top = 85
      Width = 22
      Height = 13
      Caption = 'User'
      Visible = False
    end
    object LPassword: TLabel
      Left = 8
      Top = 109
      Width = 46
      Height = 13
      Caption = 'Password'
      Visible = False
    end
    object CBHost: TComboBox
      Left = 68
      Top = 16
      Width = 161
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object EPort: TEdit
      Left = 68
      Top = 40
      Width = 49
      Height = 21
      TabOrder = 1
      Text = '8080'
    end
    object UDPort: TUpDown
      Left = 117
      Top = 40
      Width = 19
      Height = 21
      Associate = EPort
      Max = 32767
      Position = 8080
      TabOrder = 2
      Thousands = False
    end
    object CBAll: TCheckBox
      Left = 68
      Top = 136
      Width = 97
      Height = 17
      Caption = 'All protocols'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 6
    end
    object EUserName: TEdit
      Left = 68
      Top = 81
      Width = 157
      Height = 21
      TabOrder = 4
      Visible = False
    end
    object CBBasicAuth: TCheckBox
      Left = 8
      Top = 64
      Width = 177
      Height = 17
      Caption = 'Basic authentication'
      TabOrder = 3
      OnClick = CBBasicAuthClick
    end
    object EPassword: TEdit
      Left = 68
      Top = 105
      Width = 157
      Height = 21
      PasswordChar = '*'
      TabOrder = 5
      Visible = False
    end
  end
end
