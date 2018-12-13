object FormLDAPSettings: TFormLDAPSettings
  Left = 183
  Top = 58
  BorderStyle = bsDialog
  Caption = 'ldap connection settings'
  ClientHeight = 367
  ClientWidth = 338
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
  object GBLdapSettings: TGroupBox
    Left = 8
    Top = 8
    Width = 321
    Height = 305
    Caption = '&ldap server'
    TabOrder = 0
    object LScope: TLabel
      Left = 192
      Top = 96
      Width = 31
      Height = 13
      Caption = '&Scope'
    end
    object LEHost: TLabeledEdit
      Left = 8
      Top = 32
      Width = 121
      Height = 21
      Hint = 'ldap server name (or IP address) - ldap.my.com'
      EditLabel.Width = 29
      EditLabel.Height = 13
      EditLabel.Hint = 'ldap server host name, e.g. ldap.my.net'
      EditLabel.Caption = '&server'
      EditLabel.ParentShowHint = False
      EditLabel.ShowHint = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object LEUser: TLabeledEdit
      Left = 8
      Top = 72
      Width = 297
      Height = 21
      Hint = 
        'Distinguished name (DN) of an entry in the directory (e.g. dc=de' +
        'pt,dc=com)'
      EditLabel.Width = 39
      EditLabel.Height = 13
      EditLabel.Hint = 'left blank for guest access'
      EditLabel.Caption = '&user DN'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
    end
    object LEPassword: TLabeledEdit
      Left = 8
      Top = 112
      Width = 177
      Height = 21
      EditLabel.Width = 45
      EditLabel.Height = 13
      EditLabel.Hint = 'left blank for guest access'
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
      Text = '389'
    end
    object UDPort: TUpDown
      Left = 169
      Top = 32
      Width = 17
      Height = 21
      Associate = LEPort
      Max = 32767
      Position = 389
      TabOrder = 2
      Thousands = False
    end
    object CBUtf8: TCheckBox
      Left = 192
      Top = 36
      Width = 125
      Height = 17
      Hint = '&Send text in UTF-8 to the server'
      Caption = 'Send text in UTF-&8'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 3
    end
    object LEDesc: TLabeledEdit
      Left = 8
      Top = 272
      Width = 297
      Height = 21
      Hint = 'Brief ldap server description'
      EditLabel.Width = 51
      EditLabel.Height = 13
      EditLabel.Hint = 'Brief ldap description'
      EditLabel.Caption = '&description'
      EditLabel.ParentShowHint = False
      EditLabel.ShowHint = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
    end
    object LEBaseDN: TLabeledEdit
      Left = 8
      Top = 152
      Width = 297
      Height = 21
      Hint = 
        'directory entry'#39's distinguished name identifies starting point o' +
        'f the search.'
      EditLabel.Width = 42
      EditLabel.Height = 13
      EditLabel.Hint = 'left blank in most cases'
      EditLabel.Caption = '&base DN'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
    end
    object LEAttrs: TLabeledEdit
      Left = 8
      Top = 192
      Width = 297
      Height = 21
      Hint = 'Use commas to delimit the attributes (for example: cn,mail)'
      EditLabel.Width = 113
      EditLabel.Height = 13
      EditLabel.Hint = 'left blank in most cases'
      EditLabel.Caption = '&Attributes to be returned'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
    end
    object CBScope: TComboBox
      Left = 192
      Top = 112
      Width = 112
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 6
      Text = 'base'
      Items.Strings = (
        'base'
        'one'
        'sub')
    end
    object LEFilter: TLabeledEdit
      Left = 8
      Top = 232
      Width = 297
      Height = 21
      Hint = 
        'If no filter is specified, the server uses the filter (objectCla' +
        'ss=*)'
      EditLabel.Width = 22
      EditLabel.Height = 13
      EditLabel.Hint = 
        'Search filter to apply to entries within the specified scope of ' +
        'the search'
      EditLabel.Caption = '&Filter'
      EditLabel.ParentShowHint = False
      EditLabel.ShowHint = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
    end
  end
  object BOk: TButton
    Left = 72
    Top = 328
    Width = 75
    Height = 25
    Caption = 'O&k'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object BCancel: TButton
    Left = 192
    Top = 328
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
