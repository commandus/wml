object FormFTPSettings: TFormFTPSettings
  Left = 489
  Top = 119
  BorderStyle = bsDialog
  Caption = 'ftp connection settings'
  ClientHeight = 262
  ClientWidth = 283
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object GBFtpSettings: TGroupBox
    Left = 8
    Top = 8
    Width = 265
    Height = 193
    Caption = '&ftp site'
    TabOrder = 0
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
      TabOrder = 4
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
      TabOrder = 5
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
      Width = 17
      Height = 21
      Associate = LEPort
      Max = 32767
      Position = 21
      TabOrder = 2
      Thousands = False
    end
    object CBPASV: TCheckBox
      Left = 192
      Top = 36
      Width = 57
      Height = 17
      Hint = 
        'Issues the PASV command and the server tells where to establish ' +
        'the data connection.|This method is sometimes used with some pro' +
        'xy configurations'
      Caption = '&PASV'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
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
      TabOrder = 7
    end
    object LERootDir: TLabeledEdit
      Left = 8
      Top = 112
      Width = 249
      Height = 21
      EditLabel.Width = 61
      EditLabel.Height = 13
      EditLabel.Hint = 'left blank in most cases'
      EditLabel.Caption = '&root directory'
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
