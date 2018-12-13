object FormInfo: TFormInfo
  Left = 436
  Top = 182
  Width = 481
  Height = 335
  Caption = 'Information'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelMemo: TPanel
    Left = 0
    Top = 33
    Width = 473
    Height = 227
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object MemoInfo: TMemo
      Left = 0
      Top = 0
      Width = 473
      Height = 227
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Fixedsys'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 260
    Width = 473
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BOk: TButton
      Left = 280
      Top = 8
      Width = 75
      Height = 25
      Caption = 'O&k'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object BCancel: TButton
      Left = 368
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 473
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object LInfo: TLabel
      Left = 8
      Top = 8
      Width = 52
      Height = 13
      Caption = '&Information'
    end
  end
end
