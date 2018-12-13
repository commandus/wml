object FormBlogProperties: TFormBlogProperties
  Left = 73
  Top = 329
  HelpType = htKeyword
  HelpKeyword = 'bloggerproperties'
  BorderStyle = bsDialog
  Caption = 'Blogger API type properties'
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
    Width = 187
    Height = 19
    Caption = 'Blogger API properties'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object BBack: TButton
    Left = 216
    Top = 304
    Width = 75
    Height = 25
    Caption = '< Back'
    ModalResult = 7
    TabOrder = 1
  end
  object BOK: TButton
    Left = 296
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Next >'
    Default = True
    ModalResult = 1
    TabOrder = 0
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
  object CBShowSubject: TCheckBox
    Left = 168
    Top = 120
    Width = 97
    Height = 17
    Caption = 'Show &subject'
    TabOrder = 3
  end
  object CBMultipleBlogs: TCheckBox
    Left = 168
    Top = 144
    Width = 97
    Height = 17
    Caption = '&Multiple blogs'
    TabOrder = 4
  end
  object CBPublishEnabled: TCheckBox
    Left = 168
    Top = 168
    Width = 97
    Height = 17
    Caption = '&Publish'
    TabOrder = 5
  end
  object CBFileSupport: TCheckBox
    Left = 168
    Top = 192
    Width = 97
    Height = 17
    Caption = '&File support'
    TabOrder = 6
  end
  object CBHasCategories: TCheckBox
    Left = 168
    Top = 216
    Width = 97
    Height = 17
    Caption = 'Has &categories'
    TabOrder = 7
  end
  object CBEnableDates: TCheckBox
    Left = 280
    Top = 120
    Width = 97
    Height = 17
    Caption = '&Dates'
    TabOrder = 8
  end
  object CBEnableExcerpt: TCheckBox
    Left = 280
    Top = 144
    Width = 97
    Height = 17
    Caption = '&Excerpt'
    TabOrder = 9
  end
  object CBEnableKeywords: TCheckBox
    Left = 280
    Top = 168
    Width = 97
    Height = 17
    Caption = '&Keywords'
    TabOrder = 10
  end
  object CBEnableComments: TCheckBox
    Left = 280
    Top = 192
    Width = 97
    Height = 17
    Caption = 'Co&mments'
    TabOrder = 11
  end
  object CBEnableTrackBacks: TCheckBox
    Left = 280
    Top = 216
    Width = 97
    Height = 17
    Caption = '&Trackbacks'
    TabOrder = 12
  end
  object CBEnablePings: TCheckBox
    Left = 400
    Top = 120
    Width = 97
    Height = 17
    Caption = '&Pings'
    TabOrder = 13
  end
  object CBEnableApoo: TCheckBox
    Left = 400
    Top = 144
    Width = 97
    Height = 17
    Caption = '&apoo extension'
    TabOrder = 14
  end
  object CBEnableJoomla: TCheckBox
    Left = 400
    Top = 168
    Width = 97
    Height = 17
    Caption = '&joomla extension'
    TabOrder = 15
  end
  object CBUseSSL: TCheckBox
    Left = 400
    Top = 192
    Width = 97
    Height = 17
    Caption = 'SSL'
    TabOrder = 16
  end
  object CBIsCustom: TCheckBox
    Left = 400
    Top = 216
    Width = 97
    Height = 17
    Caption = 'C&ustom'
    TabOrder = 17
  end
  object MCustom: TMemo
    Left = 168
    Top = 80
    Width = 233
    Height = 33
    TabStop = False
    BorderStyle = bsNone
    Ctl3D = False
    Lines.Strings = (
      'Check the box to select the option, or uncheck it '
      'to deselect the option')
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 18
  end
end
