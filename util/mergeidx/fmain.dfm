object FormMain: TFormMain
  Left = 389
  Top = 127
  Width = 647
  Height = 459
  Caption = 'mergeidx'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object EFiles: TEdit
    Left = 32
    Top = 24
    Width = 465
    Height = 21
    TabOrder = 0
    Text = 'E:\app\idx\'
  end
  object BWords: TButton
    Left = 32
    Top = 56
    Width = 75
    Height = 25
    Caption = 'BWords'
    TabOrder = 1
    OnClick = BWordsClick
  end
  object LBWords: TListBox
    Left = 32
    Top = 88
    Width = 153
    Height = 321
    Hint = 'hint'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    Sorted = True
    TabOrder = 2
    OnClick = LBWordsClick
  end
  object LBIndexes: TListBox
    Left = 200
    Top = 88
    Width = 193
    Height = 321
    ItemHeight = 13
    Sorted = True
    TabOrder = 3
  end
  object BDirs: TButton
    Left = 120
    Top = 56
    Width = 75
    Height = 25
    Caption = 'BDirs'
    TabOrder = 4
    OnClick = BDirsClick
  end
  object BStart: TButton
    Left = 216
    Top = 56
    Width = 75
    Height = 25
    Caption = 'BStart'
    Enabled = False
    TabOrder = 5
    OnClick = BStartClick
  end
  object BStop: TButton
    Left = 304
    Top = 56
    Width = 75
    Height = 25
    Caption = 'BStop'
    Enabled = False
    TabOrder = 6
    OnClick = BStopClick
  end
  object GBProgress: TGroupBox
    Left = 408
    Top = 104
    Width = 185
    Height = 193
    Caption = 'Progress'
    TabOrder = 7
    object MResult: TMemo
      Left = 2
      Top = 34
      Width = 181
      Height = 157
      Align = alClient
      TabOrder = 0
      WordWrap = False
    end
    object ProgressBar1: TProgressBar
      Left = 2
      Top = 15
      Width = 181
      Height = 19
      Align = alTop
      TabOrder = 1
    end
  end
  object Button1: TButton
    Left = 440
    Top = 336
    Width = 75
    Height = 25
    Caption = 'Button1'
    Default = True
    TabOrder = 8
    OnClick = Button1Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 584
    Top = 32
  end
end
