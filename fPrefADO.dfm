object FormADO: TFormADO
  Left = 179
  Top = 161
  Width = 553
  Height = 389
  Caption = 'Data access object files'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelBottom: TPanel
    Left = 0
    Top = 314
    Width = 545
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object BOk: TButton
      Left = 344
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
      OnClick = BOkClick
    end
    object BCancel: TButton
      Left = 440
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object BAdd: TButton
      Left = 104
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Add file'
      TabOrder = 2
      OnClick = BAddClick
    end
    object BDelete: TButton
      Left = 192
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Delete file'
      TabOrder = 3
      OnClick = BDeleteClick
    end
    object BProp: TButton
      Left = 16
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Properties'
      TabOrder = 4
      OnClick = BPropClick
    end
  end
  object PanelClient: TPanel
    Left = 0
    Top = 25
    Width = 545
    Height = 289
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object LVAdo: TListView
      Left = 0
      Top = 0
      Width = 545
      Height = 289
      Align = alClient
      Columns = <>
      FlatScrollBars = True
      LargeImages = dm1.ImageList24
      PopupMenu = pmView
      SmallImages = dm1.ImageList16
      SortType = stText
      TabOrder = 0
      OnDblClick = BPropClick
    end
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 545
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object LFolder: TLabel
      Left = 8
      Top = 6
      Width = 32
      Height = 13
      Caption = '&Folder:'
    end
    object EUDLFolder: TEdit
      Left = 48
      Top = 2
      Width = 345
      Height = 21
      Hint = 'Press Enter to take effect on changes'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnKeyDown = EUDLFolderKeyDown
    end
    object BUDLFolder: TButton
      Left = 393
      Top = 2
      Width = 19
      Height = 21
      Hint = 'Select folder where .UDL files resides'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = BUDLFolderClick
    end
    object BShowUDLFolder: TButton
      Left = 413
      Top = 2
      Width = 19
      Height = 21
      Hint = 'Show .UDL files in selected folder'
      Caption = '>'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = BShowUDLFolderClick
    end
  end
  object pmView: TPopupMenu
    Left = 432
    Top = 32
    object pmViewProp: TMenuItem
      Caption = '&Properties'
      ShortCut = 13
      OnClick = BPropClick
    end
    object pmViewD2: TMenuItem
      Caption = '-'
    end
    object pmViewAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = BAddClick
    end
    object pmViewMakeACopyOfSelectedFile: TMenuItem
      Caption = 'Make a &copy of selected file'
      OnClick = BAddClick
    end
    object pmViewDelete: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = BDeleteClick
    end
    object pmViewD1: TMenuItem
      Caption = '-'
    end
    object pmViewIcon: TMenuItem
      AutoCheck = True
      Caption = 'Icons'
      Checked = True
      GroupIndex = 1
      RadioItem = True
      OnClick = pmViewIconClick
    end
    object pmViewList: TMenuItem
      AutoCheck = True
      Caption = 'List'
      GroupIndex = 1
      RadioItem = True
      OnClick = pmViewListClick
    end
    object pmViewReport: TMenuItem
      AutoCheck = True
      Caption = 'Report'
      GroupIndex = 1
      RadioItem = True
      OnClick = pmViewReportClick
    end
    object pmViewSmallicon: TMenuItem
      AutoCheck = True
      Caption = 'Small icons'
      GroupIndex = 1
      RadioItem = True
      OnClick = pmViewSmalliconClick
    end
  end
end
