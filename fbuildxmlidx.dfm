object FormCreateIndexFile: TFormCreateIndexFile
  Left = 189
  Top = 229
  BorderStyle = bsDialog
  Caption = 'Build index'
  ClientHeight = 335
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object LIndexFileName: TLabel
    Left = 16
    Top = 20
    Width = 42
    Height = 13
    Caption = 'Inde&x file'
  end
  object EIndexFileName: TEdit
    Left = 64
    Top = 16
    Width = 265
    Height = 21
    TabOrder = 0
    Text = 'idx.lst'
  end
  object BStart: TButton
    Left = 16
    Top = 296
    Width = 75
    Height = 25
    Action = actStartCreateIdx
    Default = True
    TabOrder = 1
  end
  object BStop: TButton
    Left = 104
    Top = 296
    Width = 75
    Height = 25
    Action = actStop
    Cancel = True
    TabOrder = 2
  end
  object GBOptions: TGroupBox
    Left = 16
    Top = 40
    Width = 337
    Height = 97
    Caption = '&Skip'
    TabOrder = 3
    object LMaxWord: TLabel
      Left = 7
      Top = 18
      Width = 108
      Height = 13
      Hint = 'If word found more than N times, words would be exclude'
      Caption = '&words found more than'
      ParentShowHint = False
      ShowHint = True
    end
    object LShorterWord: TLabel
      Left = 7
      Top = 46
      Width = 63
      Height = 13
      Hint = 'Skip words shorter than'
      Caption = 'words &shorter'
      ParentShowHint = False
      ShowHint = True
    end
    object LNumberLen: TLabel
      Left = 7
      Top = 73
      Width = 72
      Height = 13
      Hint = 'Number 4 is recommended'
      Caption = '&numbers longer'
      ParentShowHint = False
      ShowHint = True
    end
    object LShorter1: TLabel
      Left = 187
      Top = 46
      Width = 50
      Height = 13
      Caption = 'characters'
    end
    object LWords1: TLabel
      Left = 187
      Top = 18
      Width = 76
      Height = 13
      Caption = 'thousands times'
    end
    object LNum1: TLabel
      Left = 187
      Top = 70
      Width = 24
      Height = 13
      Caption = 'digits'
    end
    object ENumberLen: TEdit
      Left = 119
      Top = 67
      Width = 50
      Height = 21
      TabOrder = 0
      Text = '4'
    end
    object UDNumberLen: TUpDown
      Left = 169
      Top = 67
      Width = 16
      Height = 21
      Associate = ENumberLen
      Min = 1
      Max = 64
      Increment = 8
      Position = 4
      TabOrder = 1
      Thousands = False
    end
    object UDWordLen: TUpDown
      Left = 169
      Top = 40
      Width = 16
      Height = 21
      Associate = EWordLen
      Min = 1
      Max = 32
      Increment = 8
      Position = 3
      TabOrder = 2
      Thousands = False
    end
    object EWordLen: TEdit
      Left = 119
      Top = 40
      Width = 50
      Height = 21
      TabOrder = 3
      Text = '3'
    end
    object EMaxWord: TEdit
      Left = 119
      Top = 12
      Width = 50
      Height = 21
      TabOrder = 4
      Text = '10'#160'000'
    end
    object UDMaxWord: TUpDown
      Left = 169
      Top = 12
      Width = 16
      Height = 21
      Associate = EMaxWord
      Min = 1
      Max = 32767
      Position = 10000
      TabOrder = 5
    end
  end
  object BBrowse: TButton
    Left = 331
    Top = 16
    Width = 21
    Height = 21
    Caption = '...'
    TabOrder = 4
    OnClick = BBrowseClick
  end
  object GBProgress: TGroupBox
    Left = 16
    Top = 144
    Width = 337
    Height = 137
    Caption = '&Progress'
    TabOrder = 5
    Visible = False
    object ProgressBar1: TProgressBar
      Left = 8
      Top = 16
      Width = 313
      Height = 17
      Max = 300
      TabOrder = 0
    end
    object MResult: TMemo
      Left = 2
      Top = 40
      Width = 333
      Height = 95
      Align = alBottom
      ParentColor = True
      TabOrder = 1
    end
  end
  object BClose: TButton
    Left = 192
    Top = 296
    Width = 75
    Height = 25
    Caption = '&Close'
    ModalResult = 1
    TabOrder = 6
    OnClick = BCloseClick
  end
  object BHelp: TButton
    Left = 282
    Top = 296
    Width = 75
    Height = 25
    Caption = '&Help'
    Default = True
    TabOrder = 7
    OnClick = BHelpClick
  end
  object ActionManager1: TActionManager
    Left = 344
    Top = 72
    StyleName = 'XP Style'
    object actStartCreateIdx: TAction
      Category = 'act'
      Caption = 'Start'
      OnExecute = actStartCreateIdxExecute
    end
    object actSearch: TAction
      Category = 'act'
      Caption = 'Search'
    end
    object actStop: TAction
      Category = 'act'
      Caption = 'Stop'
      OnExecute = actStopExecute
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 344
    Top = 40
  end
end
