object FormFtpProxySettings: TFormFtpProxySettings
  Left = 82
  Top = 117
  BorderStyle = bsDialog
  Caption = 'ftp proxy settings'
  ClientHeight = 262
  ClientWidth = 285
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GBFtpSettings: TGroupBox
    Left = 8
    Top = 8
    Width = 265
    Height = 193
    Caption = '&ftp proxy'
    TabOrder = 0
    object LProxyType: TLabel
      Left = 8
      Top = 98
      Width = 48
      Height = 13
      Caption = 'proxy &type'
    end
    object LEHost: TLabeledEdit
      Left = 8
      Top = 32
      Width = 121
      Height = 21
      EditLabel.Width = 20
      EditLabel.Height = 13
      EditLabel.Hint = 'FTP host name, e.g. ftp.my.net'
      EditLabel.Caption = '&host'
      EditLabel.ParentShowHint = False
      EditLabel.ShowHint = True
      TabOrder = 0
    end
    object LEUser: TLabeledEdit
      Left = 8
      Top = 72
      Width = 121
      Height = 21
      EditLabel.Width = 49
      EditLabel.Height = 13
      EditLabel.Hint = 'left blank for anonymous access'
      EditLabel.Caption = '&user name'
      TabOrder = 3
    end
    object LEPassword: TLabeledEdit
      Left = 136
      Top = 72
      Width = 121
      Height = 21
      EditLabel.Width = 45
      EditLabel.Height = 13
      EditLabel.Hint = 'left blank for anonymous access or enter your email'
      EditLabel.Caption = 'p&assword'
      PasswordChar = '*'
      TabOrder = 4
    end
    object LEPort: TLabeledEdit
      Left = 136
      Top = 32
      Width = 33
      Height = 21
      EditLabel.Width = 18
      EditLabel.Height = 13
      EditLabel.Caption = '&port'
      TabOrder = 1
      Text = '21'
    end
    object UDPort: TUpDown
      Left = 169
      Top = 32
      Width = 16
      Height = 21
      Associate = LEPort
      Max = 32767
      Position = 21
      TabOrder = 2
      Thousands = False
    end
    object CBProxyType: TComboBox
      Left = 8
      Top = 114
      Width = 249
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 5
      Text = 'None'
      Items.Strings = (
        'None'
        
          'send the proxy user name/password, followed by the client user n' +
          'ame'
        'send SITE command'
        'send OPEN command'
        'send USER and PASS commands'
        'Transparent')
    end
    object LEDesc: TLabeledEdit
      Left = 8
      Top = 152
      Width = 249
      Height = 21
      EditLabel.Width = 51
      EditLabel.Height = 13
      EditLabel.Hint = 'Brief ftp description'
      EditLabel.Caption = '&description'
      EditLabel.ParentShowHint = False
      EditLabel.ShowHint = True
      TabOrder = 6
    end
  end
  object BOk: TButton
    Left = 48
    Top = 224
    Width = 75
    Height = 25
    Caption = 'O&k'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object BCancel: TButton
    Left = 168
    Top = 224
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
