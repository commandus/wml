object FormDockBase: TFormDockBase
  Left = 246
  Top = 129
  Caption = 'apoo editor'
  ClientHeight = 512
  ClientWidth = 762
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PanelDockSite: TPanel
    Left = 0
    Top = 126
    Width = 762
    Height = 386
    Align = alClient
    BevelOuter = bvNone
    DockSite = True
    TabOrder = 0
    object TreeViewElements: TTreeView
      Left = 241
      Top = 0
      Width = 248
      Height = 309
      Align = alLeft
      DragKind = dkDock
      HideSelection = False
      Images = dm1.ImageList16
      Indent = 27
      TabOrder = 0
      OnChange = TreeViewElementsChange
      OnClick = TreeViewElementsClick
      OnEdited = TreeViewElementsEdited
      OnKeyDown = TreeViewElementsKeyDown
    end
    object PanelProject: TPanel
      Left = 0
      Top = 0
      Width = 241
      Height = 309
      Align = alLeft
      BevelOuter = bvNone
      DragKind = dkDock
      TabOrder = 1
      OnResize = PanelProjectResize
      object PanelProjectTreeView: TPanel
        Left = 0
        Top = 0
        Width = 241
        Height = 309
        Align = alClient
        TabOrder = 0
        object PCProject: TPageControl
          Left = 1
          Top = 1
          Width = 239
          Height = 307
          ActivePage = TSFiles
          Align = alClient
          TabOrder = 0
          TabPosition = tpBottom
          OnChanging = PCProjectChanging
          object TSFiles: TTabSheet
            Caption = '&Files'
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object PanelFilter: TPanel
              Left = 0
              Top = 0
              Width = 231
              Height = 27
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 0
              OnResize = PanelFilterResize
              object LFilter: TLabel
                Left = 6
                Top = 6
                Width = 22
                Height = 13
                Caption = '&Filter'
              end
              object CBFilter: TComboBox
                Left = 32
                Top = 2
                Width = 185
                Height = 22
                Style = csOwnerDrawFixed
                DropDownCount = 12
                ItemHeight = 16
                TabOrder = 0
                OnChange = CBFilterChange
                OnDrawItem = CBFilterDrawItem
              end
            end
          end
          object TSDocuments: TTabSheet
            Caption = '&Documents'
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object LVDocuments: TListView
              Left = 0
              Top = 41
              Width = 231
              Height = 231
              Align = alClient
              Columns = <
                item
                  Caption = 'Document'
                  MaxWidth = 300
                  MinWidth = 80
                  Width = 150
                end
                item
                  Caption = 'Description'
                  MaxWidth = 300
                  MinWidth = 80
                  Width = 150
                end>
              OwnerData = True
              ReadOnly = True
              RowSelect = True
              SortType = stText
              TabOrder = 0
              ViewStyle = vsReport
              OnData = LVDocumentsData
              OnDblClick = LVDocumentsDblClick
            end
            object PanelDocumentsFolder: TPanel
              Left = 0
              Top = 0
              Width = 231
              Height = 41
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 1
              OnResize = PanelDocumentsFolderResize
              object LCurrentFolder: TLabel
                Left = 0
                Top = 24
                Width = 35
                Height = 13
                Caption = 'Folder: '
              end
              object LFilterDoc: TLabel
                Left = 0
                Top = 4
                Width = 22
                Height = 13
                Caption = '&Filter'
              end
              object EFilterDoc: TEdit
                Left = 28
                Top = 2
                Width = 141
                Height = 21
                TabOrder = 0
                OnKeyDown = EFilterDocKeyDown
              end
              object BFilterDoc: TButton
                Left = 169
                Top = 2
                Width = 22
                Height = 22
                Action = actApplyDocFilter
                Caption = '>'
                ParentShowHint = False
                ShowHint = True
                TabOrder = 1
              end
              object BBuildFilter: TButton
                Left = 192
                Top = 2
                Width = 22
                Height = 22
                Action = actBuildDocIndex
                Caption = 'B'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
                ParentShowHint = False
                ShowHint = True
                TabOrder = 2
              end
            end
          end
        end
      end
    end
    object PanelEditor: TPanel
      Left = 489
      Top = 0
      Width = 273
      Height = 309
      Align = alClient
      DragKind = dkDock
      TabOrder = 3
      object TCOpenFiles: TTabControl
        Left = 1
        Top = 1
        Width = 271
        Height = 23
        Align = alTop
        PopupMenu = pmOpenFiles
        TabOrder = 0
        OnChange = TCOpenFilesChange
      end
      object PageControlEditors: TPageControl
        Left = 1
        Top = 24
        Width = 271
        Height = 265
        ActivePage = TSCode
        Align = alClient
        TabOrder = 1
        TabPosition = tpBottom
        OnChange = PageControlEditorsChange
        OnChanging = PageControlEditorsChanging
        object TSCode: TTabSheet
          Caption = '&Code'
          OnExit = TSCodeExit
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
        end
        object TSPreview: TTabSheet
          Caption = '&Preview'
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object WBPreview: TWebBrowser
            Left = 0
            Top = 0
            Width = 263
            Height = 230
            Align = alClient
            TabOrder = 0
            ControlData = {
              4C0000002F1B0000C51700000000000000000000000000000000000000000000
              000000004C000000000000000000000001000000E0D057007335CF11AE690800
              2B2E126208000000000000004C0000000114020000000000C000000000000046
              8000000000000000000000000000000000000000000000000000000000000000
              00000000000000000100000000000000000000000000000000000000}
          end
        end
        object TSForm: TTabSheet
          Caption = '&Form'
          ImageIndex = 2
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object ScrollBoxForm: TScrollBox
            Left = 0
            Top = 0
            Width = 263
            Height = 234
            HorzScrollBar.Style = ssFlat
            VertScrollBar.Style = ssFlat
            Align = alClient
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            TabOrder = 0
            object PanelForm: TPanel
              Left = 0
              Top = 0
              Width = 246
              Height = 237
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 0
            end
          end
        end
      end
      object StatusBar1: TStatusBar
        Left = 1
        Top = 289
        Width = 271
        Height = 19
        Panels = <
          item
            Width = 80
          end
          item
            Width = 80
          end
          item
            Width = 80
          end
          item
            Width = 80
          end>
      end
    end
    object ListBoxInfo: TListBox
      Left = 0
      Top = 309
      Width = 762
      Height = 77
      Hint = 'Handle several consecutive white spaces as one white space'
      Style = lbOwnerDrawFixed
      Align = alBottom
      DragKind = dkDock
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 18
      MultiSelect = True
      ParentFont = False
      ParentShowHint = False
      PopupMenu = pmInfo
      ShowHint = True
      TabOrder = 2
      OnDblClick = ListBoxInfoDblClick
      OnDrawItem = ListBoxInfoDrawItem
    end
  end
  object PanelAds: TPanel
    Left = 0
    Top = 66
    Width = 762
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 762
    Height = 66
    AutoSize = True
    BandMaximize = bmDblClick
    Bands = <
      item
        Control = ActionMainMenuBar1
        ImageIndex = -1
        MinHeight = 30
        MinWidth = 260
        Width = 273
      end
      item
        Break = False
        Control = ActionToolBar1
        ImageIndex = -1
        MinHeight = 30
        MinWidth = 210
        Width = 483
      end
      item
        Control = PageScroller1
        ImageIndex = -1
        MinHeight = 30
        MinWidth = 220
        Width = 758
      end>
    object ActionMainMenuBar1: TActionMainMenuBar
      Left = 9
      Top = 0
      Width = 260
      Height = 30
      UseSystemFont = False
      ActionManager = ActionManager1
      Caption = 'ActionMainMenuBar1'
      ColorMap.HighlightColor = clWhite
      ColorMap.BtnSelectedColor = clBtnFace
      ColorMap.UnusedColor = clWhite
      EdgeOuter = esNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentShowHint = False
      ShowHint = True
      Spacing = 0
    end
    object ActionToolBar1: TActionToolBar
      Left = 284
      Top = 0
      Width = 470
      Height = 30
      ActionManager = ActionManager1
      Caption = 'ActionToolBar1'
      ColorMap.HighlightColor = clWhite
      ColorMap.BtnSelectedColor = clBtnFace
      ColorMap.UnusedColor = clWhite
      EdgeInner = esNone
      ParentShowHint = False
      ShowHint = True
      Spacing = 0
    end
    object PageScroller1: TPageScroller
      Left = 9
      Top = 32
      Width = 745
      Height = 30
      Align = alLeft
      Control = ToolBarElements
      TabOrder = 2
      object ToolBarElements: TToolBar
        Left = 0
        Top = 0
        Width = 109
        Height = 30
        Align = alLeft
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 31
        Images = dm1.ImageList24
        TabOrder = 0
        Wrapable = False
        object TBSep1: TToolButton
          Left = 0
          Top = 0
          Width = 17
          Caption = 'TBSep1'
          ImageIndex = 1
          Style = tbsSeparator
        end
        object TBHelp: TToolButton
          Tag = 1
          Left = 17
          Top = 0
          Hint = 'Hint'
          Action = actHelpContents
          ImageIndex = 0
          ParentShowHint = False
          ShowHint = True
        end
        object TBSep2: TToolButton
          Left = 48
          Top = 0
          Width = 17
          Caption = 'TBSep2'
          ImageIndex = 2
          Style = tbsSeparator
        end
        object TBOpen: TToolButton
          Tag = 2
          Left = 65
          Top = 0
          Action = actFileOpen
          DropdownMenu = pmRecentFiles
          ImageIndex = 269
          Style = tbsDropDown
        end
      end
    end
  end
  object ActionManager1: TActionManager
    ActionBars.SessionCount = 313
    ActionBars = <
      item
        Items.HideUnused = False
        Items = <
          item
            Items.HideUnused = False
            Items = <
              item
                Items.HideUnused = False
                Items = <
                  item
                    Action = actFileNewDeck
                    ImageIndex = 5
                    ShortCut = 16462
                  end
                  item
                    Action = actFileNewXHTML
                    LastSession = 313
                  end
                  item
                    Action = actFileNewOEB
                    ImageIndex = 32
                    LastSession = 313
                  end
                  item
                    Action = actFileNewPKG
                    LastSession = 313
                  end
                  item
                    Action = actFileNewTaxon
                    Caption = '&New taxon document'
                    LastSession = 313
                  end
                  item
                    Caption = '-'
                    LastSession = 313
                  end
                  item
                    Action = actFileNewSmit
                    LastSession = 313
                  end
                  item
                    Action = actFileNewHHC
                    LastSession = 313
                  end
                  item
                    Action = actFileNewHHK
                    LastSession = 313
                  end
                  item
                    Caption = '-'
                    LastSession = 313
                  end
                  item
                    Action = actFileNewRTC
                    Caption = 'N&ew RTC user profile'
                    LastSession = 313
                  end
                  item
                    Caption = '-'
                  end
                  item
                    Action = actFileCreatePackageByOEB
                    Caption = '&Create package by OEB'
                    LastSession = 313
                  end
                  item
                    Action = actFileNewAsCurrent
                    Caption = 'C&reate new document as copy of current'
                    LastSession = 313
                    ShortCut = 24654
                  end
                  item
                    Action = actFileNewFromTemplate
                    ImageIndex = 113
                    ShortCut = 16468
                  end>
                Caption = '&New'
              end
              item
                Action = actFileOpen
                ImageIndex = 6
                ShortCut = 16463
              end
              item
                Action = actFileRecentFiles
                LastSession = 313
                ShortCut = 49231
              end
              item
                Caption = '-'
              end
              item
                Action = actFileSave
                ImageIndex = 7
                ShortCut = 16467
              end
              item
                Action = actFileSaveAs
                ImageIndex = 8
              end
              item
                Action = actSaveAll
                Caption = 'Sa&ve All'
                LastSession = 313
                ShortCut = 24659
              end
              item
                Caption = '-'
              end
              item
                Action = actFilePrint
                ImageIndex = 12
                LastSession = 313
              end
              item
                Action = actFileSysCtxMenu
                Caption = 'S&hell context menu'
                LastSession = 313
                ShortCut = 32887
              end
              item
                Action = actFileGenerateLIT
                Caption = '&Generate LIT'
                ImageIndex = 32
                ShortCut = 32888
              end
              item
                Caption = '-'
              end
              item
                Action = actFileClose
                Caption = '&Close'
                ShortCut = 16499
              end
              item
                Caption = '-'
              end
              item
                Action = actFileExit
                ImageIndex = 16
                ShortCut = 32856
              end>
            Caption = '&File'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = actEditCut
                ImageIndex = 0
                ShortCut = 16472
              end
              item
                Action = actEditCopy
                ImageIndex = 1
                ShortCut = 16451
              end
              item
                Action = actEditPaste
                ImageIndex = 2
                ShortCut = 16470
              end
              item
                Action = actEditSelectAll
                ShortCut = 16449
              end
              item
                Caption = '-'
              end
              item
                Action = actEditUndo
                Caption = 'U&ndo'
                LastSession = 313
                ShortCut = 16474
              end
              item
                Action = actEditRedo
                Caption = 'Red&o'
                LastSession = 313
                ShortCut = 24666
              end
              item
                Caption = '-'
                LastSession = 313
              end
              item
                Action = actEditMoveElementUp
                ImageIndex = 4
                ShortCut = 16422
              end
              item
                Action = actEditMoveElementDown
                ImageIndex = 3
                ShortCut = 16424
              end
              item
                Action = actEditDeleteCurrentElement
                Caption = 'D&elete current element'
                ImageIndex = 65
              end
              item
                Caption = '-'
              end
              item
                Action = actEditFind
                ImageIndex = 9
                ShortCut = 16454
              end
              item
                Action = actEditFindNext
                ShortCut = 114
              end
              item
                Action = actEditReplace
                ImageIndex = 10
                ShortCut = 16466
              end
              item
                Caption = '-'
                LastSession = 313
              end
              item
                Action = actXPathQuery
                Caption = '&XPath query'
                LastSession = 313
                ShortCut = 16465
              end
              item
                Caption = '-'
              end
              item
                Action = actEditInsertSymbol
                ShortCut = 49241
              end>
            Caption = '&Edit'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = actViewWindowEditor
                ShortCut = 16497
              end
              item
                Action = actViewWindowElement
                Caption = '&View elements tree'
                ShortCut = 16498
              end
              item
                Action = actViewWindowAttribute
                ShortCut = 16500
              end
              item
                Action = actViewWindowMessages
                ShortCut = 16501
              end
              item
                Action = actViewWindowProject
                ShortCut = 16502
              end
              item
                Action = actViewByteCode
                Caption = 'Vie&w WMLC byte code'
                LastSession = 313
                ShortCut = 16503
              end
              item
                Caption = '-'
              end
              item
                Action = actViewEditorOnly
                Caption = '&Toggle editor'
                ImageIndex = 30
                ShortCut = 16496
              end
              item
                Action = actViewWindowAllowDock
              end
              item
                Caption = '-'
              end
              item
                Action = actViewInfo
                ImageIndex = 21
                LastSession = 248
                ShortCut = 16457
              end
              item
                Action = actViewCompileCurrentFile
                ShortCut = 120
              end
              item
                Caption = '-'
              end
              item
                Action = actRefreshPreview
                Caption = 'Re&fresh preview screen'
                ShortCut = 32884
              end>
            Caption = '&View'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = actToolsWBMPConvertor
              end
              item
                Caption = '-'
              end
              item
                Action = actToolsReformat
                ImageIndex = 25
                ShortCut = 16504
              end
              item
                Caption = '-'
                LastSession = 313
              end
              item
                Action = actToolsSpellCheck
                Caption = '&Spelling check'
                LastSession = 313
                ShortCut = 118
              end
              item
                Caption = '-'
                LastSession = 313
              end
              item
                Action = actBuildPhrasesList
                Caption = '&Build phrases list of all documents'
                LastSession = 313
              end
              item
                Action = actPhrasesManager
                Caption = '&Phrases manager'
                LastSession = 313
              end
              item
                Caption = '-'
                LastSession = 313
              end
              item
                Action = debug_ViewElementPosition
                Caption = '&View element positions'
                LastSession = 313
                ShortCut = 41050
              end>
            Caption = '&Tools'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = actFTPEdit
                ImageIndex = 27
                LastSession = 313
                ShortCut = 8308
              end>
            Caption = '&Storages'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = actOptionsFileAssociate
              end
              item
                Action = actOptionsEditor
              end
              item
                Action = actOptionsSettings
                ImageIndex = 26
              end
              item
                Action = actOptionsADO
                ImageIndex = 27
              end
              item
                Action = actOptionsSpelling
                Caption = '&Spelling options'
                LastSession = 313
              end
              item
                Caption = '-'
              end
              item
                Action = actOptionsLoadDesktopConfiguration
                Caption = '&Load desktop configuration'
              end
              item
                Action = actOptionsSaveDesktopConfiguration
              end
              item
                Caption = '-'
              end
              item
                Action = actRestoreDefaultWindow
              end>
            Caption = '&Options'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = actHelpContents
                ImageIndex = 22
                ShortCut = 112
              end
              item
                Action = actHelpAbout
                Caption = '&About'
                ImageIndex = 20
              end
              item
                Caption = '-'
                LastSession = 313
              end
              item
                Action = actTagInfo
                ImageIndex = 21
                ShortCut = 32880
              end
              item
                Action = actHelpCreateDTD
                Caption = 'C&opy to clipboard supported DTDs'
                LastSession = 313
              end
              item
                Caption = '-'
              end
              item
                Action = actHelpHowToRegister
                Caption = '&How to register'
              end
              item
                Action = actHelpEnterCode
                ShortCut = 115
              end>
            Caption = '&Help'
          end>
        ActionBar = ActionMainMenuBar1
        AutoSize = False
      end
      item
        Items = <
          item
            Items = <
              item
                Action = actFileNewDeck
                ImageIndex = 5
                ShortCut = 16462
              end
              item
                Action = actFileNewXHTML
              end
              item
                Action = actFileNewOEB
                ImageIndex = 32
              end
              item
                Action = actFileNewPKG
              end
              item
                Action = actFileNewTaxon
              end
              item
                Action = actFileNewSmit
              end>
            Action = actFileNewDeck
            ImageIndex = 5
            ShowCaption = False
            ShortCut = 16462
          end
          item
            Action = actFileOpen
            ImageIndex = 6
            ShowCaption = False
            ShortCut = 16463
          end
          item
            Action = actFileSave
            ImageIndex = 7
            ShowCaption = False
            ShortCut = 16467
          end
          item
            Action = actViewEditorOnly
            ImageIndex = 30
            ShowCaption = False
            ShortCut = 16496
          end
          item
            Action = actHelpContents
            ImageIndex = 22
            ShowCaption = False
            ShortCut = 112
          end
          item
            Caption = '-'
          end
          item
            Action = actEditMoveElementUp
            ImageIndex = 4
            ShowCaption = False
            ShortCut = 16422
          end
          item
            Action = actEditMoveElementDown
            ImageIndex = 3
            ShowCaption = False
            ShortCut = 16424
          end>
        ActionBar = ActionToolBar1
      end>
    Images = dm1.ImageListMenu
    Left = 528
    Top = 64
    StyleName = 'XP Style'
    object actFileNewDeck: TAction
      Category = 'File'
      Caption = 'New &wml deck'
      Hint = 'New file|Create new WML document'
      ImageIndex = 5
      ShortCut = 16462
      OnExecute = actFileNewDeckExecute
    end
    object actFileNewXHTML: TAction
      Category = 'File'
      Caption = 'New &xhtml'
      Hint = 'New xhtml file|Create new XHTML document'
      OnExecute = actFileNewXHTMLExecute
    end
    object actFileNewOEB: TAction
      Category = 'File'
      Caption = 'New &OEB document'
      Hint = 'New OEB file|Create new Open eBook document'
      ImageIndex = 32
      OnExecute = actFileNewOEBExecute
    end
    object actFileNewSmit: TAction
      Category = 'File'
      Caption = 'New &SMIT menu xml'
      OnExecute = actFileNewSmitExecute
    end
    object actFileNewPKG: TAction
      Category = 'File'
      Caption = 'New OEB &package'
      Hint = 'New PKG file|Create new Open eBook package'
      OnExecute = actFileNewPKGExecute
    end
    object actFileCreatePackageByOEB: TAction
      Category = 'File'
      Caption = 'Create package by OEB'
      Hint = 'Create a new package by current Open eBook document'
      ImageIndex = 12
      OnExecute = actFileCreatePackageByOEBExecute
      OnUpdate = actFileCreatePackageByOEBUpdate
    end
    object actFileNewFromTemplate: TAction
      Category = 'File'
      Caption = 'New deck by &template'
      ImageIndex = 113
      ShortCut = 16468
      OnExecute = actFileNewFromTemplateExecute
    end
    object actFileOpen: TFileOpen
      Category = 'File'
      Caption = '&Open...'
      Hint = 'Open|Opens an existing file'
      ImageIndex = 6
      ShortCut = 16463
      BeforeExecute = actFileOpenBeforeExecute
      OnAccept = actFileOpenAccept
    end
    object actFileSave: TAction
      Category = 'File'
      Caption = '&Save'
      Hint = 'Save|Saves the active file'
      ImageIndex = 7
      ShortCut = 16467
      OnExecute = actFileSaveExecute
      OnUpdate = actUpdateFileCanSave
    end
    object actFileSaveAs: TFileSaveAs
      Category = 'File'
      Caption = 'Save &As...'
      Hint = 'Save As|Saves the active file with a new name'
      ImageIndex = 8
      BeforeExecute = actFileSaveAsBeforeExecute
      OnAccept = actFileSaveAsAccept
    end
    object actSaveAll: TAction
      Category = 'File'
      Caption = 'Save All'
      Hint = 'Save all modified files'
      ShortCut = 24659
      OnExecute = actSaveAllExecute
      OnUpdate = actSaveAllUpdate
    end
    object actFileClose: TAction
      Category = 'File'
      Caption = 'Close'
      Hint = 'Close|Close editor window'
      ShortCut = 16499
      OnExecute = actFileCloseExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actFileExit: TFileExit
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit|Quits the application'
      ImageIndex = 16
      ShortCut = 32856
    end
    object actEditSelectAll: TAction
      Category = 'Edit'
      Caption = 'Se&lect all'
      ShortCut = 16449
      OnExecute = actEditSelectAllExecute
    end
    object actEditCut: TEditCut
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut|Cuts the selection and puts it on the Clipboard'
      ImageIndex = 0
      ShortCut = 16472
      SecondaryShortCuts.Strings = (
        'Shift+Del')
      OnExecute = actEditCutExecute
    end
    object actEditCopy: TEditCopy
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy|Copies the selection and puts it on the Clipboard'
      ImageIndex = 1
      ShortCut = 16451
      SecondaryShortCuts.Strings = (
        'Ctrl+Ins')
      OnExecute = actEditCopyExecute
    end
    object actEditPaste: TEditPaste
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste|Inserts Clipboard contents'
      ImageIndex = 2
      ShortCut = 16470
      SecondaryShortCuts.Strings = (
        'Shift+Ins')
      OnExecute = actEditPasteExecute
    end
    object actViewCompileCurrentFile: TAction
      Category = 'View'
      Caption = '&Refresh'
      Hint = 'Compile current file'
      ShortCut = 120
      OnExecute = actViewCompileCurrentFileExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actStoreCode: TAction
      Category = 'act'
      Caption = 'Store code'
      OnExecute = actStoreCodeExecute
    end
    object actValidateCode: TAction
      Category = 'act'
      Caption = 'Validate code'
      OnExecute = actValidateCodeExecute
    end
    object actHelpAbout: TAction
      Category = 'Help'
      Caption = 'About'
      ImageIndex = 20
      OnExecute = actHelpAboutExecute
    end
    object actHelpContents: TAction
      Category = 'Help'
      Caption = '&Contents'
      ImageIndex = 22
      ShortCut = 112
      OnExecute = actHelpContentsExecute
    end
    object actTagInfo: TAction
      Category = 'Help'
      Caption = 'wml tag &list'
      Hint = 'Show tag brief description|Show tag brief description'
      ImageIndex = 21
      ShortCut = 32880
      OnExecute = actHelpTagInfoExecute
    end
    object actHelpHowToRegister: TAction
      Category = 'Help'
      Caption = 'How to register'
      OnExecute = actHelpHowToRegisterExecute
    end
    object actHelpEnterCode: TAction
      Category = 'Help'
      Caption = '&Enter code to register evaluation copy'
      ShortCut = 115
      OnExecute = actHelpEnterCodeExecute
    end
    object actHelpGetCode: TAction
      Category = 'Help'
      Caption = 'Get code online'
      OnExecute = actHelpGetCodeExecute
    end
    object actViewEditorOnly: TAction
      Category = 'View'
      Caption = 'Toggle &editor'
      Hint = 'Toggle windows scheme|Toggle windows scheme'
      ImageIndex = 30
      ShortCut = 16496
      OnExecute = actViewEditorOnlyExecute
    end
    object actViewWindowEditor: TAction
      Category = 'View'
      Caption = 'View &editor'
      ShortCut = 16497
      OnExecute = actViewWindowEditorExecute
      OnUpdate = actViewWindowEditorUpdate
    end
    object actViewWindowElement: TAction
      Category = 'View'
      Caption = 'View &elements tree'
      ImageIndex = 11
      ShortCut = 16498
      OnExecute = actViewWindowElementExecute
      OnUpdate = actViewWindowElementUpdate
    end
    object actViewWindowAttribute: TAction
      Category = 'View'
      Caption = 'View &attribute inspector'
      ShortCut = 16500
      OnExecute = actViewWindowAttributeExecute
      OnUpdate = actViewWindowAttributeUpdate
    end
    object actViewWindowMessages: TAction
      Category = 'View'
      Caption = 'View &messages'
      ShortCut = 16501
      OnExecute = actViewWindowMessagesExecute
      OnUpdate = actViewWindowMessagesUpdate
    end
    object actViewWindowProject: TAction
      Category = 'View'
      Caption = 'View &project tree'
      ShortCut = 16502
      OnExecute = actViewWindowProjectExecute
      OnUpdate = actViewWindowProjectUpdate
    end
    object actViewByteCode: TAction
      Category = 'View'
      Caption = 'View WMLC byte code'
      Hint = 'View wmlc byte code'
      ShortCut = 16503
      OnExecute = actViewByteCodeExecute
      OnUpdate = actUpdateWML_WMLC_Opened
    end
    object actViewWindowAllowDock: TAction
      Category = 'View'
      Caption = 'Allow &docking'
      OnExecute = actViewWindowAllowDockExecute
    end
    object actOptionsFileAssociate: TAction
      Category = 'Options'
      Caption = '&File association (shell integration)'
      OnExecute = actOptionsFileAssociateExecute
    end
    object actParseCommandLine: TAction
      Category = 'act'
      Caption = 'Parse command line'
      OnExecute = actParseCommandLineExecute
    end
    object actOptionsEditor: TAction
      Category = 'Options'
      Caption = '&Editor settings'
      OnExecute = actOptionsEditorExecute
    end
    object actOptionsSettings: TAction
      Category = 'Options'
      Caption = '&Preferences'
      ImageIndex = 26
      OnExecute = actOptionsSettingsExecute
    end
    object actOptionsLoadDesktopConfiguration: TAction
      Category = 'Options'
      Caption = 'Load d&esktop configuration'
      OnExecute = actOptionsLoadDesktopConfigurationExecute
    end
    object actOptionsSaveDesktopConfiguration: TAction
      Category = 'Options'
      Caption = 'Save &desktop configuration'
      OnExecute = actOptionsSaveDesktopConfigurationExecute
    end
    object actUpdateMenus: TAction
      Category = 'act'
      Caption = 'Refresh menus'
    end
    object actEditDeleteCurrentElement: TAction
      Category = 'Edit'
      Caption = '&Delete current element'
      Hint = 
        'Delete currently selected element|Press [Delete] key in element ' +
        'tree view'
      ImageIndex = 14
      OnExecute = actEditDeleteCurrentElementExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actRestoreDefaultWindow: TAction
      Category = 'Options'
      Caption = '&Restore default window positions'
      OnExecute = actRestoreDefaultWindowExecute
    end
    object actEditFind: TAction
      Category = 'Edit'
      Caption = '&Find'
      ImageIndex = 9
      ShortCut = 16454
      OnExecute = actEditFindExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actEditFindNext: TAction
      Category = 'Edit'
      Caption = '&Search again'
      ShortCut = 114
      OnExecute = actEditFindNextExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actEditReplace: TAction
      Category = 'Edit'
      Caption = '&Replace'
      ImageIndex = 10
      ShortCut = 16466
      OnExecute = actEditReplaceExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actFTPEdit: TAction
      Category = 'ftp'
      Caption = '&Edit ftp, ldap,... connections'
      ImageIndex = 27
      ShortCut = 8308
      OnExecute = actFTPEditExecute
    end
    object actToolsWBMPConvertor: TAction
      Category = 'Tools'
      Caption = 'Wbmp &image convertor'
      OnExecute = actToolsWBMPConvertorExecute
    end
    object actInsertImage: TAction
      Category = 'act'
      Caption = 'Insert image'
      ImageIndex = 31
      OnExecute = actInsertImageExecute
    end
    object actImageSaveAsWBMP: TFileSaveAs
      Category = 'act'
      Caption = 'Save image as w&bmp'
      Dialog.DefaultExt = '.wbmp'
      Dialog.Filter = 'wbmp Image|*.wbmp|All files|*.*'
      Hint = 'Save As|Saves the active file with a new name'
    end
    object actXPathQuery: TAction
      Category = 'Edit'
      Caption = 'XPath query'
      ShortCut = 16465
      OnExecute = actXPathQueryExecute
    end
    object actEditMoveElementUp: TAction
      Category = 'Edit'
      Caption = 'Move element &up'
      Hint = 'Move element up'
      ImageIndex = 4
      ShortCut = 16422
      OnExecute = actEditMoveElementUpExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actEditMoveElementDown: TAction
      Category = 'Edit'
      Caption = 'Move element &down'
      Hint = 'Move element down'
      ImageIndex = 3
      ShortCut = 16424
      OnExecute = actEditMoveElementDownExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actViewInfo: TAction
      Category = 'View'
      Caption = 'Show &info'
      Hint = 'Show info|Show compiled deck size'
      ImageIndex = 21
      ShortCut = 16457
      OnExecute = actViewInfoExecute
      OnUpdate = actUpdateWML_WMLC_Opened
    end
    object actToolsReformat: TAction
      Category = 'Tools'
      Caption = '&Format source'
      Hint = 'Format source|Format source text'
      ImageIndex = 25
      ShortCut = 16504
      OnExecute = actToolsReformatExecute
    end
    object actFormatDialog: TAction
      Category = 'act'
      Caption = 'Format for user &input '
      ImageIndex = 25
      OnExecute = actFormatDialogExecute
    end
    object actFilePrint: TAction
      Category = 'File'
      Caption = '&Print...'
      ImageIndex = 12
      OnExecute = actFilePrintExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actHelpNagScreen: TAction
      Category = 'Help'
      Caption = 'Nag screen'
      OnExecute = actHelpNagScreenExecute
    end
    object actEditInsertSymbol: TAction
      Category = 'Edit'
      Caption = 'Insert s&ymbol'
      ShortCut = 49241
      OnExecute = actEditInsertSymbolExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actFileGenerateLIT: TAction
      Category = 'File'
      Caption = 'Generate LIT'
      ImageIndex = 32
      ShortCut = 32888
      OnExecute = actFileGenerateLITExecute
      OnUpdate = actUpdateIsFilePkg
    end
    object actEnterPCDATA: TAction
      Category = 'act'
      Caption = 'Enter text'
      OnExecute = actEnterPCDATAExecute
    end
    object actFolderTreeGenerateLIT: TAction
      Category = 'act'
      Caption = 'Compile selected Open eBook package file to LIT'
      OnExecute = actFolderTreeGenerateLITExecute
    end
    object actOptionsADO: TAction
      Category = 'Options'
      Caption = 'Data &access objects files'
      ImageIndex = 27
      OnExecute = actOptionsADOExecute
    end
    object actRefreshPreview: TAction
      Category = 'act'
      Caption = 'Refresh preview screen'
      ShortCut = 32884
      OnExecute = actRefreshPreviewExecute
    end
    object actClearMessages: TAction
      Category = 'popup'
      Caption = 'C&lear messages'
      OnExecute = actClearMessagesExecute
    end
    object actClearSearch: TAction
      Category = 'popup'
      Caption = 'Clear &search in files items'
      OnExecute = actClearSearchExecute
    end
    object actToolsSpellCheck: TAction
      Category = 'Tools'
      Caption = 'Spelling check'
      Hint = 'Text spelling check'
      ShortCut = 118
      OnExecute = actToolsSpellCheckExecute
      OnUpdate = actToolsSpellCheckUpdate
    end
    object actOptionsSpelling: TAction
      Category = 'Options'
      Caption = 'Spelling options'
      Hint = 'Set text spelling options'
      OnExecute = actOptionsSpellingExecute
      OnUpdate = actToolsSpellCheckUpdate
    end
    object actFileSysCtxMenu: TAction
      Category = 'File'
      Caption = 'Shell context menu'
      Hint = 'File shell context menu'
      ShortCut = 32887
      OnExecute = actFileSysCtxMenuExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actFileNewTaxon: TAction
      Category = 'File'
      Caption = 'New ta&xon document'
      OnExecute = actFileNewTaxonExecute
    end
    object actHelpCreateDTD: TAction
      Category = 'Help'
      Caption = 'Copy to clipboard supported DTDs'
      OnExecute = actHelpCreateDTDExecute
    end
    object actRefreshConstructionForm: TAction
      Category = 'act'
      Caption = 'Refresh Construction Form'
      ShortCut = 16500
      OnExecute = actRefreshConstructionFormExecute
    end
    object actBuildDocIndex: TAction
      Category = 'act'
      Caption = 'Build document index'
      Hint = 'Rebuild document index'
      OnExecute = actBuildDocIndexExecute
    end
    object actApplyDocFilter: TAction
      Category = 'act'
      Caption = 'Apply document filter'
      Hint = 'Apply documents filter'
      OnExecute = actApplyDocFilterExecute
    end
    object debug_ViewElementPosition: TAction
      Category = 'debug'
      Caption = 'View element positions'
      ShortCut = 41050
      OnExecute = debug_ViewElementPositionExecute
    end
    object actBuildPhrasesList: TAction
      Category = 'Tools'
      Caption = 'Build phrases list of all documents'
      Hint = 
        'Rebuild phrases dictionary for documents of selected type in the' +
        ' current folder'
      OnExecute = actBuildPhrasesListExecute
    end
    object actPhrasesManager: TAction
      Category = 'Tools'
      Caption = 'Phrases manager'
      Hint = 'Manage phrases dictionary, translate,..'
      OnExecute = actPhrasesManagerExecute
    end
    object actFileNewHHC: TAction
      Category = 'File'
      Caption = 'New hypertext &help content document'
      Hint = 'Create new help content document'
      OnExecute = actFileNewHHCExecute
    end
    object actFileNewHHK: TAction
      Category = 'File'
      Caption = 'New hypertext help &key document'
      Hint = 'Create new hypertext help key file'
      OnExecute = actFileNewHHKExecute
    end
    object actFileNewAsCurrent: TAction
      Category = 'File'
      Caption = 'Create new document as copy of current'
      Hint = 'Create new document and copy current document to it'
      ShortCut = 24654
      OnExecute = actFileNewAsCurrentExecute
      OnUpdate = actUpdateIsFileOpened
    end
    object actFileRecentFiles: TAction
      Category = 'File'
      Caption = '&Reopen recent file ...'
      Hint = 'reopen recent file(s)'
      ShortCut = 49231
      OnExecute = actFileRecentFilesExecute
    end
    object actEditUndo: TAction
      Category = 'Edit'
      Caption = 'Undo'
      Hint = 'Undo the last action'
      ShortCut = 16474
      OnExecute = actEditUndoExecute
      OnUpdate = actEditUndoUpdate
    end
    object actEditRedo: TAction
      Category = 'Edit'
      Caption = 'Redo'
      Hint = 'Redo the previously undone action'
      ShortCut = 24666
      OnExecute = actEditRedoExecute
      OnUpdate = actEditRedoUpdate
    end
    object actFileNewRTC: TAction
      Category = 'File'
      Caption = 'New RTC user profile'
      OnExecute = actFileNewRTCExecute
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 556
    Top = 64
  end
  object sys: TDdeServerConv
    OnExecuteMacro = SysExecuteMacro
    Left = 584
    Top = 64
  end
  object pmFolderTree: TPopupMenu
    OnPopup = pmFolderTreePopup
    Left = 612
    Top = 64
    object pmFolderTreeEdit: TMenuItem
      Caption = '&Edit'
      ShortCut = 13
      OnClick = FolderTree1DblClick
    end
    object pmFolderTreeSysCtxMenu: TMenuItem
      Action = actFileSysCtxMenu
    end
    object pmFolderTreeD1: TMenuItem
      Caption = '-'
    end
    object pmFolderTreeNewFile: TMenuItem
      Caption = '&New file'
      OnClick = actFileNewDeckExecute
    end
    object pmFolderTreeD2: TMenuItem
      Caption = '-'
    end
  end
  object pmOpenFiles: TPopupMenu
    Left = 640
    Top = 64
    object pmOpenFilesClosePage: TMenuItem
      Action = actFileClose
    end
    object pmOpenFileD1: TMenuItem
      Caption = '-'
    end
  end
  object pmInfo: TPopupMenu
    Left = 668
    Top = 64
    object pmInfoCopy: TMenuItem
      Action = actEditCopy
    end
    object pmInfoD0: TMenuItem
      Caption = '-'
    end
    object pmInfoClearMessages: TMenuItem
      Action = actClearMessages
    end
    object pmInfoD1: TMenuItem
      Caption = '-'
    end
    object pmInfoClearSearch: TMenuItem
      Action = actClearSearch
    end
  end
  object pmRecentFiles: TPopupMenu
    Images = dm1.ImageList16
    Left = 696
    Top = 64
  end
end
