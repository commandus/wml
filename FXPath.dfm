object FormXPath: TFormXPath
  Left = 689
  Top = 133
  BorderStyle = bsDialog
  Caption = 'XPath query'
  ClientHeight = 330
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
    Height = 330
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object LText: TLabel
      Left = 8
      Top = 16
      Width = 58
      Height = 13
      Caption = '&XPath query'
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
      Top = 296
      Width = 75
      Height = 25
      Caption = 'Find'
      Default = True
      ModalResult = 1
      TabOrder = 3
    end
    object BCancel: TButton
      Left = 208
      Top = 296
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 4
    end
    object RGWhere: TRadioGroup
      Left = 88
      Top = 32
      Width = 177
      Height = 81
      Caption = '&Where'
      ItemIndex = 0
      Items.Strings = (
        'Search c&urrent file'
        'Search all &open files'
        'Search in d&irectories')
      TabOrder = 1
      OnClick = RGWhereClick
    end
    object GBDir: TGroupBox
      Left = 8
      Top = 120
      Width = 369
      Height = 169
      Caption = 'Search directory options'
      TabOrder = 2
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
        Hint = 'Browse'
        Caption = '...'
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
        Hint = 'Browse'
        Caption = '...'
        TabOrder = 6
        Visible = False
        OnClick = BProgramClick
      end
    end
    object BHelp: TButton
      Left = 302
      Top = 296
      Width = 75
      Height = 25
      Caption = '&Help'
      Default = True
      TabOrder = 5
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
      TabOrder = 6
      OnClick = BShowLinesClick
    end
  end
end
