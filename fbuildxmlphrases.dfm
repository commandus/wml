object FormCreatePhrases: TFormCreatePhrases
  Left = 117
  Top = 81
  BorderStyle = bsDialog
  Caption = 'Build phrases list (.phr)'
  ClientHeight = 335
  ClientWidth = 371
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
    Width = 54
    Height = 13
    Caption = 'Phrases &file'
  end
  object EIndexFileName: TEdit
    Left = 74
    Top = 16
    Width = 255
    Height = 21
    TabOrder = 0
    Text = 'phrases.lst'
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
    Height = 113
    Caption = '&Options'
    TabOrder = 3
    object Label1: TLabel
      Left = 174
      Top = 24
      Width = 66
      Height = 13
      Caption = 'Skip &elements'
    end
    object CBCaseSensitive: TCheckBox
      Left = 16
      Top = 24
      Width = 97
      Height = 17
      Hint = 'It is not recommended to checking up case sensitve option'
      Caption = '&Case sensitive'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object CBOutputUnicode: TCheckBox
      Left = 16
      Top = 48
      Width = 169
      Height = 17
      Caption = 'Output &unicode text (UTF-8)'
      TabOrder = 1
    end
    object CBSkipAttributes: TCheckBox
      Left = 16
      Top = 72
      Width = 97
      Height = 17
      Hint = 'It is not recommended to checking up skip attributes'
      Caption = '&Skip attributes'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object MSkipElements: TMemo
      Left = 176
      Top = 39
      Width = 127
      Height = 47
      TabOrder = 3
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
    Top = 160
    Width = 337
    Height = 121
    Caption = '&Progress'
    TabOrder = 5
    Visible = False
    object MResult: TMemo
      Left = 2
      Top = 40
      Width = 333
      Height = 79
      Align = alBottom
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 0
    end
    object ProgressBar1: TProgressBar
      Left = 136
      Top = 16
      Width = 177
      Height = 17
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
    Left = 24
    Top = 232
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
end
