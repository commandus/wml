object dm1: Tdm1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 202
  Width = 263
  object OpenDialog1: TOpenDialog
    Left = 24
    Top = 8
  end
  object ImageListMenu: TImageList
    Left = 136
    Top = 56
  end
  object ImageList24: TImageList
    AllocBy = 16
    Height = 24
    Width = 24
    Left = 81
    Top = 59
  end
  object ImageList16: TImageList
    AllocBy = 16
    Left = 25
    Top = 59
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Fixedsys'
    Font.Style = []
    MinFontSize = 8
    MaxFontSize = 20
    Options = [fdNoStyleSel, fdLimitSize]
    Left = 80
    Top = 8
  end
end
