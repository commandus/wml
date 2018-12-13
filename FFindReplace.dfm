object FormFindReplace: TFormFindReplace
  Left = 734
  Top = 145
  BorderStyle = bsDialog
  Caption = 'Replace text'
  ClientHeight = 449
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PanelSearch: TPanel
    Left = 0
    Top = 0
    Width = 385
    Height = 449
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object LText: TLabel
      Left = 8
      Top = 16
      Width = 68
      Height = 13
      Caption = '&Text to search'
    end
    object LReplaceWith: TLabel
      Left = 8
      Top = 56
      Width = 62
      Height = 13
      Caption = '&Replace with'
    end
    object GBOptions: TGroupBox
      Left = 8
      Top = 88
      Width = 177
      Height = 121
      Caption = 'Options'
      TabOrder = 2
      object CBCaseSensitive: TCheckBox
        Left = 16
        Top = 16
        Width = 121
        Height = 17
        Caption = '&Case sensitive'
        TabOrder = 0
      end
      object CBWholeWordsOnly: TCheckBox
        Left = 16
        Top = 36
        Width = 121
        Height = 17
        Caption = '&Whole words only'
        TabOrder = 1
      end
      object CBRegularExpressions: TCheckBox
        Left = 16
        Top = 56
        Width = 145
        Height = 17
        Caption = '&Regular expressions'
        TabOrder = 2
        OnClick = CBRegularExpressionsClick
      end
      object CBSpaceCompress: TCheckBox
        Left = 28
        Top = 76
        Width = 145
        Height = 17
        Hint = 'handle several consecutive white spaces as one white space'
        Caption = '&Space compress'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Visible = False
      end
      object CBIgnoreNonSpacing: TCheckBox
        Left = 28
        Top = 96
        Width = 145
        Height = 17
        Hint = '&ignore non-spacing characters in search text '
        Caption = '&Ignore non-spacing chars'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        Visible = False
      end
    end
    object RGDirection: TRadioGroup
      Left = 200
      Top = 232
      Width = 177
      Height = 65
      Caption = 'Direction'
      ItemIndex = 0
      Items.Strings = (
        'Forwar&d'
        '&Backward')
      TabOrder = 5
    end
    object RGScope: TRadioGroup
      Left = 200
      Top = 160
      Width = 177
      Height = 65
      Caption = 'Scope'
      ItemIndex = 0
      Items.Strings = (
        '&Global'
        '&Selected area')
      TabOrder = 4
    end
    object RGOrigin: TRadioGroup
      Left = 200
      Top = 88
      Width = 177
      Height = 65
      Caption = 'Origin'
      ItemIndex = 0
      Items.Strings = (
        '&From current position'
        '&Entire')
      TabOrder = 3
    end
    object CBText: TComboBox
      Left = 88
      Top = 8
      Width = 265
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnChange = CBTextChange
    end
    object BOk: TButton
      Left = 22
      Top = 408
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 8
    end
    object BCancel: TButton
      Left = 200
      Top = 408
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 10
    end
    object CBReplaceWith: TComboBox
      Left = 88
      Top = 48
      Width = 265
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      OnChange = CBReplaceWithChange
    end
    object BReplaceAll: TButton
      Left = 112
      Top = 408
      Width = 75
      Height = 25
      Caption = 'Replace &All'
      Default = True
      ModalResult = 10
      TabOrder = 9
    end
    object RGWhere: TRadioGroup
      Left = 8
      Top = 216
      Width = 177
      Height = 81
      Caption = 'Where'
      ItemIndex = 0
      Items.Strings = (
        'Search c&urrent file'
        'Search all &open files'
        'Search in d&irectories')
      TabOrder = 6
      OnClick = RGWhereClick
    end
    object GBDir: TGroupBox
      Left = 8
      Top = 302
      Width = 369
      Height = 91
      Caption = 'Search directory options'
      TabOrder = 7
      Visible = False
      object LFileMask: TLabel
        Left = 8
        Top = 24
        Width = 42
        Height = 13
        Caption = 'Director&y'
      end
      object Label1: TLabel
        Left = 8
        Top = 64
        Width = 52
        Height = 13
        Caption = 'W&hich files'
      end
      object CBDir: TComboBox
        Left = 64
        Top = 21
        Width = 265
        Height = 21
        ItemHeight = 13
        TabOrder = 0
      end
      object BDirBrowse: TButton
        Left = 328
        Top = 20
        Width = 22
        Height = 22
        Hint = 'Browse'
        Caption = '...'
        TabOrder = 1
        OnClick = BDirBrowseClick
      end
      object CBDirRecurse: TCheckBox
        Left = 64
        Top = 44
        Width = 185
        Height = 17
        Caption = 'Include &subdirectories'
        TabOrder = 2
      end
      object CBFilter: TComboBox
        Left = 64
        Top = 62
        Width = 161
        Height = 22
        Hint = 'Select type of files to search'
        Style = csOwnerDrawFixed
        ItemHeight = 16
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
    end
    object BHelp: TButton
      Left = 288
      Top = 408
      Width = 75
      Height = 25
      Caption = '&Help'
      Default = True
      TabOrder = 11
      OnClick = BHelpClick
    end
    object BShowLines: TButton
      Left = 356
      Top = 8
      Width = 22
      Height = 22
      Hint = 'Enter multiple lines to search'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 12
      OnClick = BShowLinesClick
    end
    object BShowLinesReplace: TButton
      Left = 355
      Top = 47
      Width = 22
      Height = 22
      Hint = 'Enter multiple lines to search'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 13
      OnClick = BShowLinesReplaceClick
    end
  end
end
