object FormElementDescription: TFormElementDescription
  Left = 283
  Top = 151
  Width = 285
  Height = 335
  BorderStyle = bsSizeToolWin
  Caption = 'Element description'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 116
    Width = 277
    Height = 7
    Cursor = crVSplit
    Align = alTop
  end
  object MemoBrief: TMemo
    Left = 0
    Top = 27
    Width = 277
    Height = 89
    Align = alTop
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clInfoBk
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object MemoAttr: TMemo
    Left = 0
    Top = 123
    Width = 277
    Height = 178
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clInfoBk
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object PanelNavigate: TPanel
    Left = 0
    Top = 0
    Width = 277
    Height = 27
    Align = alTop
    TabOrder = 2
    object LElement: TLabel
      Left = 8
      Top = 8
      Width = 38
      Height = 13
      Caption = '&Element'
    end
    object CBEElement: TComboBoxEx
      Left = 75
      Top = 2
      Width = 118
      Height = 22
      ItemsEx = <>
      Style = csExDropDownList
      ItemHeight = 16
      TabOrder = 0
      OnChange = CBEElementChange
      Images = dm1.ImageList16
      DropDownCount = 8
    end
  end
end
