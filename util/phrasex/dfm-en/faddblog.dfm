object FormAddBlog: TFormAddBlog
  Left = 141
  Top = 191
  HelpType = htKeyword
  HelpKeyword = 'addblog'
  BorderStyle = bsDialog
  Caption = 'Edit connection settings'
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
    Width = 39
    Height = 13
    Caption = 'Provider'
  end
  object LHost: TLabel
    Left = 176
    Top = 168
    Width = 22
    Height = 13
    Caption = 'Host'
  end
  object LPage: TLabel
    Left = 176
    Top = 200
    Width = 45
    Height = 13
    Caption = 'End point'
  end
  object LPort: TLabel
    Left = 176
    Top = 232
    Width = 19
    Height = 13
    Caption = 'Port'
  end
  object LInfo: TLabel
    Left = 40
    Top = 32
    Width = 207
    Height = 19
    Caption = 'Add blog to the proxy list'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object CBProvider: TComboBox
    Left = 224
    Top = 80
    Width = 169
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object MCustom: TMemo
    Left = 176
    Top = 128
    Width = 233
    Height = 33
    TabStop = False
    BorderStyle = bsNone
    Ctl3D = False
    Lines.Strings = (
      'Custom host settings (do not change unless you '
      'are using custom blog server)')
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 8
  end
  object CBHost: TComboBox
    Left = 224
    Top = 168
    Width = 161
    Height = 21
    ItemHeight = 13
    TabOrder = 1
  end
  object CBEndPoint: TComboBox
    Left = 224
    Top = 200
    Width = 161
    Height = 21
    ItemHeight = 13
    TabOrder = 2
  end
  object CBUseSSL: TCheckBox
    Left = 320
    Top = 232
    Width = 97
    Height = 17
    Caption = 'Use SSL'
    TabOrder = 4
  end
  object BBack: TButton
    Left = 216
    Top = 304
    Width = 75
    Height = 25
    Caption = '< Back'
    ModalResult = 7
    TabOrder = 6
    Visible = False
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
  object EPort: TEdit
    Left = 224
    Top = 232
    Width = 57
    Height = 21
    TabOrder = 3
    Text = '80'
  end
  object UDPort: TUpDown
    Left = 281
    Top = 232
    Width = 19
    Height = 21
    Associate = EPort
    Max = 32767
    Position = 80
    TabOrder = 9
    Thousands = False
  end
  object BProperties: TButton
    Left = 392
    Top = 80
    Width = 75
    Height = 21
    Hint = 'Blog properties'
    Caption = 'Properties'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
    OnClick = BPropertiesClick
  end
end
