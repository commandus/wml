object FormFind: TFormFind
  Left = 689
  Top = 96
  BorderStyle = bsDialog
  Caption = 'Find text'
  ClientHeight = 464
  ClientWidth = 386
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
    Width = 386
    Height = 464
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object LText: TLabel
      Left = 8
      Top = 16
      Width = 53
      Height = 13
      Caption = '&Text to find'
    end
    object GBOptions: TGroupBox
      Left = 8
      Top = 40
      Width = 177
      Height = 121
      Caption = 'Options'
      TabOrder = 1
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
        Height = 15
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
      Top = 184
      Width = 177
      Height = 65
      Caption = 'Direction'
      ItemIndex = 0
      Items.Strings = (
        'Forwar&d'
        '&Backward')
      TabOrder = 4
    end
    object RGScope: TRadioGroup
      Left = 200
      Top = 112
      Width = 177
      Height = 65
      Caption = 'Scope'
      ItemIndex = 0
      Items.Strings = (
        '&Global'
        '&Selected area')
      TabOrder = 3
    end
    object RGOrigin: TRadioGroup
      Left = 200
      Top = 40
      Width = 177
      Height = 65
      Caption = 'Origin'
      ItemIndex = 0
      Items.Strings = (
        '&From current position'
        '&Entire')
      TabOrder = 2
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
      Left = 112
      Top = 432
      Width = 75
      Height = 25
      Caption = 'Find'
      Default = True
      ModalResult = 1
      TabOrder = 7
    end
    object BCancel: TButton
      Left = 208
      Top = 432
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 8
    end
    object RGWhere: TRadioGroup
      Left = 8
      Top = 168
      Width = 177
      Height = 81
      Caption = 'Where'
      ItemIndex = 0
      Items.Strings = (
        'Search c&urrent file'
        'Search all &open files'
        'Search in d&irectories')
      TabOrder = 5
      OnClick = RGWhereClick
    end
    object GBDir: TGroupBox
      Left = 8
      Top = 256
      Width = 369
      Height = 169
      Caption = 'Search directory options'
      TabOrder = 6
      Visible = False
      object LFileMask: TLabel
        Left = 8
        Top = 16
        Width = 42
        Height = 13
        Caption = 'Director&y'
      end
      object LWichFiles: TLabel
        Left = 12
        Top = 64
        Width = 52
        Height = 13
        Caption = 'W&hich files'
      end
      object LAction: TLabel
        Left = 12
        Top = 92
        Width = 30
        Height = 13
        Hint = 'Action to perform in directory'
        Caption = '&Action'
        ParentShowHint = False
        ShowHint = True
      end
      object LProgram: TLabel
        Left = 72
        Top = 114
        Width = 203
        Height = 13
        Hint = 'Action to perform in directory'
        Caption = '&Program or DLL e.g. split.dll#splitByNumber'
        ParentShowHint = False
        ShowHint = True
        Visible = False
      end
      object CBDir: TComboBox
        Left = 72
        Top = 16
        Width = 267
        Height = 21
        ItemHeight = 13
        TabOrder = 0
      end
      object BDirBrowse: TButton
        Left = 340
        Top = 16
        Width = 22
        Height = 22
        Hint = 'Browse directories'
        Caption = '...'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = BDirBrowseClick
      end
      object CBDirRecurse: TCheckBox
        Left = 72
        Top = 40
        Width = 185
        Height = 17
        Caption = 'Include &subdirectories'
        TabOrder = 2
      end
      object CBFilter: TComboBox
        Left = 72
        Top = 60
        Width = 161
        Height = 22
        Hint = 'Select type of files to search'
        Style = csOwnerDrawFixed
        ItemHeight = 16
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
      object CBDirPerform: TComboBox
        Left = 72
        Top = 88
        Width = 265
        Height = 22
        Hint = 'Select action to perform in directory'
        Style = csOwnerDrawFixed
        ItemHeight = 16
        ItemIndex = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        Text = 'Show found lines in Info panel'
        OnChange = CBDirPerformChange
        Items.Strings = (
          'Show found lines in Info panel'
          'Create description file in folder where search started'
          'Create index files in folder where search started'
          'Pass found text selection to the external program')
      end
      object CBProgram: TComboBox
        Left = 72
        Top = 134
        Width = 265
        Height = 21
        Hint = 'Select action to perform in directory'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        Visible = False
      end
      object BProgram: TButton
        Left = 339
        Top = 133
        Width = 22
        Height = 22
        Hint = 'Browse libraries'
        Caption = '...'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        Visible = False
        OnClick = BProgramClick
      end
    end
    object BHelp: TButton
      Left = 302
      Top = 432
      Width = 75
      Height = 25
      Caption = '&Help'
      Default = True
      TabOrder = 9
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
      TabOrder = 10
      OnClick = BShowLinesClick
    end
  end
end
