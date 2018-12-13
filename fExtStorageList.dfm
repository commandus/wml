object FormExtStorageSites: TFormExtStorageSites
  Left = 595
  Top = 214
  Caption = 'External storage sites list (ftp, ldap)'
  ClientHeight = 223
  ClientWidth = 546
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 546
    Height = 160
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object LVList: TListView
      Left = 0
      Top = 0
      Width = 546
      Height = 160
      HelpType = htKeyword
      HelpKeyword = 'howtoftplist'
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = 'Host'
        end
        item
          AutoSize = True
          Caption = 'Port'
        end
        item
          AutoSize = True
          Caption = 'User name'
        end
        item
          AutoSize = True
          Caption = 'Password'
        end
        item
          AutoSize = True
          Caption = 'Directory/Base DN'
        end
        item
          AutoSize = True
          Caption = 'Description'
        end>
      ReadOnly = True
      RowSelect = True
      SmallImages = dm1.ImageListMenu
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = BEditClick
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 160
    Width = 546
    Height = 63
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BAdd: TButton
      Left = 3
      Top = 3
      Width = 75
      Height = 25
      Hint = 'Add new ftp site'
      Caption = 'Add &ftp'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = BAddFTPClick
    end
    object BDelete: TButton
      Left = 3
      Top = 35
      Width = 75
      Height = 25
      Hint = 'Delete site'
      Caption = '&Delete'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = BDeleteClick
    end
    object BEdit: TButton
      Left = 91
      Top = 35
      Width = 75
      Height = 25
      Hint = 'Edit site connection settings'
      Caption = '&Edit'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = BEditClick
    end
    object BProxySettings: TButton
      Left = 179
      Top = 35
      Width = 75
      Height = 25
      Hint = 'Set proxy settings'
      Caption = 'ftp Prox&y'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = BProxySettingsClick
    end
    object BOK: TButton
      Left = 355
      Top = 35
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 5
    end
    object BCancel: TButton
      Left = 443
      Top = 35
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 6
    end
    object BAddLDAP: TButton
      Left = 91
      Top = 3
      Width = 75
      Height = 25
      Hint = 'Add new ldap server'
      Caption = 'Add &ldap'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = BAddLDAPClick
    end
  end
end
