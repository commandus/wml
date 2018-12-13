object FormMain: TFormMain
  Left = 198
  Top = 185
  Width = 696
  Height = 480
  Caption = 'WML App Constructor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 185
    Top = 126
    Width = 12
    Height = 301
  end
  object PanelAds: TPanel
    Left = 0
    Top = 66
    Width = 688
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 66
    AutoSize = True
    BandMaximize = bmDblClick
    Bands = <
      item
        Control = ActionMainMenuBar1
        ImageIndex = -1
        MinHeight = 30
        MinWidth = 260
        Width = 330
      end
      item
        Break = False
        Control = ActionToolBar1
        ImageIndex = -1
        MinHeight = 30
        MinWidth = 210
        Width = 352
      end
      item
        Control = PageScroller1
        ImageIndex = -1
        MinHeight = 30
        MinWidth = 220
        Width = 684
      end>
    object ActionMainMenuBar1: TActionMainMenuBar
      Left = 9
      Top = 0
      Width = 317
      Height = 30
      UseSystemFont = False
      ActionManager = ActionManager1
      Caption = 'ActionMainMenuBar1'
      ColorMap.HighlightColor = 15921906
      ColorMap.BtnSelectedColor = clBtnFace
      ColorMap.UnusedColor = 15921906
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
      Left = 341
      Top = 0
      Width = 339
      Height = 30
      ActionManager = ActionManager1
      Caption = 'ActionToolBar1'
      ColorMap.HighlightColor = 15921906
      ColorMap.BtnSelectedColor = clBtnFace
      ColorMap.UnusedColor = 15921906
      EdgeInner = esNone
      ParentShowHint = False
      ShowHint = True
      Spacing = 0
    end
    object PageScroller1: TPageScroller
      Left = 9
      Top = 32
      Width = 671
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
        EdgeBorders = []
        Flat = True
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
          ImageIndex = 269
          Style = tbsDropDown
        end
      end
    end
  end
  object PanelLeft: TPanel
    Left = 0
    Top = 126
    Width = 185
    Height = 301
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
  end
  object PanelConstruction: TPanel
    Left = 197
    Top = 126
    Width = 491
    Height = 301
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object PageScrollerConstructor: TPageScroller
      Left = 0
      Top = 0
      Width = 491
      Height = 301
      Align = alClient
      TabOrder = 0
      object Shape1: TShape
        Left = 32
        Top = 16
        Width = 65
        Height = 65
        OnMouseDown = Shape1MouseDown
        OnMouseMove = Shape1MouseMove
      end
      object Shape2: TShape
        Left = 184
        Top = 88
        Width = 65
        Height = 65
        Brush.Color = clRed
        OnMouseDown = Shape1MouseDown
        OnMouseMove = Shape1MouseMove
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 427
    Width = 688
    Height = 19
    Panels = <>
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
                    Action = actFileNewSmit
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
    Left = 528
    Top = 64
    StyleName = 'XP Style'
    object actFileNewDeck: TAction
      Category = 'File'
      Caption = 'New &wml deck'
      Hint = 'New file|Create new WML document'
      ImageIndex = 5
      ShortCut = 16462
    end
    object actFileNewXHTML: TAction
      Category = 'File'
      Caption = 'New &xhtml'
      Hint = 'New xhtml file|Create new XHTML document'
    end
    object actFileNewOEB: TAction
      Category = 'File'
      Caption = 'New &OEB document'
      Hint = 'New OEB file|Create new Open eBook document'
      ImageIndex = 32
    end
    object actFileNewSmit: TAction
      Category = 'File'
      Caption = 'New &SMIT menu xml'
    end
    object actFileNewPKG: TAction
      Category = 'File'
      Caption = 'New OEB &package'
      Hint = 'New PKG file|Create new Open eBook package'
    end
    object actFileCreatePackageByOEB: TAction
      Category = 'File'
      Caption = 'Create package by OEB'
      Hint = 'Create a new package by current Open eBook document'
      ImageIndex = 12
    end
    object actFileNewFromTemplate: TAction
      Category = 'File'
      Caption = 'New deck by &template'
      ImageIndex = 113
      ShortCut = 16468
    end
    object actFileOpen: TFileOpen
      Category = 'File'
      Caption = '&Open...'
      Hint = 'Open|Opens an existing file'
      ImageIndex = 6
      ShortCut = 16463
    end
    object actFileSave: TAction
      Category = 'File'
      Caption = '&Save'
      Hint = 'Save|Saves the active file'
      ImageIndex = 7
      ShortCut = 16467
    end
    object actFileSaveAs: TFileSaveAs
      Category = 'File'
      Caption = 'Save &As...'
      Hint = 'Save As|Saves the active file with a new name'
      ImageIndex = 8
    end
    object actSaveAll: TAction
      Category = 'File'
      Caption = 'Save All'
      Hint = 'Save all modified files'
      ShortCut = 24659
    end
    object actFileClose: TAction
      Category = 'File'
      Caption = 'Close'
      Hint = 'Close|Close editor window'
      ShortCut = 16499
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
    end
    object actEditCut: TEditCut
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut|Cuts the selection and puts it on the Clipboard'
      ImageIndex = 0
      ShortCut = 16472
      SecondaryShortCuts.Strings = (
        'Shift+Del')
    end
    object actEditCopy: TEditCopy
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy|Copies the selection and puts it on the Clipboard'
      ImageIndex = 1
      ShortCut = 16451
      SecondaryShortCuts.Strings = (
        'Ctrl+Ins')
    end
    object actEditPaste: TEditPaste
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste|Inserts Clipboard contents'
      ImageIndex = 2
      ShortCut = 16470
      SecondaryShortCuts.Strings = (
        'Shift+Ins')
    end
    object actViewCompileCurrentFile: TAction
      Category = 'View'
      Caption = '&Refresh'
      Hint = 'Compile current file'
      ShortCut = 120
    end
    object actStoreCode: TAction
      Category = 'act'
      Caption = 'Store code'
    end
    object actValidateCode: TAction
      Category = 'act'
      Caption = 'Validate code'
    end
    object actHelpAbout: TAction
      Category = 'Help'
      Caption = 'About'
      ImageIndex = 20
    end
    object actHelpContents: TAction
      Category = 'Help'
      Caption = '&Contents'
      ImageIndex = 22
      ShortCut = 112
    end
    object actTagInfo: TAction
      Category = 'Help'
      Caption = 'wml tag &list'
      Hint = 'Show tag brief description|Show tag brief description'
      ImageIndex = 21
      ShortCut = 32880
    end
    object actHelpHowToRegister: TAction
      Category = 'Help'
      Caption = 'How to register'
    end
    object actHelpEnterCode: TAction
      Category = 'Help'
      Caption = '&Enter code to register evaluation copy'
      ShortCut = 115
    end
    object actHelpGetCode: TAction
      Category = 'Help'
      Caption = 'Get code online'
    end
    object actViewEditorOnly: TAction
      Category = 'View'
      Caption = 'Toggle &editor'
      Hint = 'Toggle windows scheme|Toggle windows scheme'
      ImageIndex = 30
      ShortCut = 16496
    end
    object actViewWindowEditor: TAction
      Category = 'View'
      Caption = 'View &editor'
      ShortCut = 16497
    end
    object actViewWindowElement: TAction
      Category = 'View'
      Caption = 'View &elements tree'
      ImageIndex = 11
      ShortCut = 16498
    end
    object actViewWindowAttribute: TAction
      Category = 'View'
      Caption = 'View &attribute inspector'
      ShortCut = 16500
    end
    object actViewWindowMessages: TAction
      Category = 'View'
      Caption = 'View &messages'
      ShortCut = 16501
    end
    object actViewWindowProject: TAction
      Category = 'View'
      Caption = 'View &project tree'
      ShortCut = 16502
    end
    object actViewByteCode: TAction
      Category = 'View'
      Caption = 'View WMLC byte code'
      Hint = 'View wmlc byte code'
      ShortCut = 16503
    end
    object actViewWindowAllowDock: TAction
      Category = 'View'
      Caption = 'Allow &docking'
    end
    object actOptionsFileAssociate: TAction
      Category = 'Options'
      Caption = '&File association (shell integration)'
    end
    object actParseCommandLine: TAction
      Category = 'act'
      Caption = 'Parse command line'
    end
    object actOptionsEditor: TAction
      Category = 'Options'
      Caption = '&Editor settings'
    end
    object actOptionsSettings: TAction
      Category = 'Options'
      Caption = '&Preferences'
      ImageIndex = 26
    end
    object actOptionsLoadDesktopConfiguration: TAction
      Category = 'Options'
      Caption = 'Load d&esktop configuration'
    end
    object actOptionsSaveDesktopConfiguration: TAction
      Category = 'Options'
      Caption = 'Save &desktop configuration'
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
    end
    object actRestoreDefaultWindow: TAction
      Category = 'Options'
      Caption = '&Restore default window positions'
    end
    object actEditFind: TAction
      Category = 'Edit'
      Caption = '&Find'
      ImageIndex = 9
      ShortCut = 16454
    end
    object actEditFindNext: TAction
      Category = 'Edit'
      Caption = '&Search again'
      ShortCut = 114
    end
    object actEditReplace: TAction
      Category = 'Edit'
      Caption = '&Replace'
      ImageIndex = 10
      ShortCut = 16466
    end
    object actFTPEdit: TAction
      Category = 'ftp'
      Caption = '&Edit ftp, ldap,... connections'
      ImageIndex = 27
      ShortCut = 8308
    end
    object actToolsWBMPConvertor: TAction
      Category = 'Tools'
      Caption = 'Wbmp &image convertor'
    end
    object actInsertImage: TAction
      Category = 'act'
      Caption = 'Insert image'
      ImageIndex = 31
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
    end
    object actEditMoveElementUp: TAction
      Category = 'Edit'
      Caption = 'Move element &up'
      Hint = 'Move element up'
      ImageIndex = 4
      ShortCut = 16422
    end
    object actEditMoveElementDown: TAction
      Category = 'Edit'
      Caption = 'Move element &down'
      Hint = 'Move element down'
      ImageIndex = 3
      ShortCut = 16424
    end
    object actViewInfo: TAction
      Category = 'View'
      Caption = 'Show &info'
      Hint = 'Show info|Show compiled deck size'
      ImageIndex = 21
      ShortCut = 16457
    end
    object actToolsReformat: TAction
      Category = 'Tools'
      Caption = '&Format source'
      Hint = 'Format source|Format source text'
      ImageIndex = 25
      ShortCut = 16504
    end
    object actFormatDialog: TAction
      Category = 'act'
      Caption = 'Format for user &input '
      ImageIndex = 25
    end
    object actFilePrint: TAction
      Category = 'File'
      Caption = '&Print...'
      ImageIndex = 12
    end
    object actHelpNagScreen: TAction
      Category = 'Help'
      Caption = 'Nag screen'
    end
    object actEditInsertSymbol: TAction
      Category = 'Edit'
      Caption = 'Insert s&ymbol'
      ShortCut = 49241
    end
    object actFileGenerateLIT: TAction
      Category = 'File'
      Caption = 'Generate LIT'
      ImageIndex = 32
      ShortCut = 32888
    end
    object actEnterPCDATA: TAction
      Category = 'act'
      Caption = 'Enter text'
    end
    object actFolderTreeGenerateLIT: TAction
      Category = 'act'
      Caption = 'Compile selected Open eBook package file to LIT'
    end
    object actOptionsADO: TAction
      Category = 'Options'
      Caption = 'Data &access objects files'
      ImageIndex = 27
    end
    object actRefreshPreview: TAction
      Category = 'act'
      Caption = 'Refresh preview screen'
      ShortCut = 32884
    end
    object actClearMessages: TAction
      Category = 'popup'
      Caption = 'C&lear messages'
    end
    object actClearSearch: TAction
      Category = 'popup'
      Caption = 'Clear &search in files items'
    end
    object actToolsSpellCheck: TAction
      Category = 'Tools'
      Caption = 'Spelling check'
      Hint = 'Text spelling check'
      ShortCut = 118
    end
    object actOptionsSpelling: TAction
      Category = 'Options'
      Caption = 'Spelling options'
      Hint = 'Set text spelling options'
    end
    object actFileSysCtxMenu: TAction
      Category = 'File'
      Caption = 'Shell context menu'
      Hint = 'File shell context menu'
      ShortCut = 32887
    end
    object actFileNewTaxon: TAction
      Category = 'File'
      Caption = 'New ta&xon document'
    end
    object actHelpCreateDTD: TAction
      Category = 'Help'
      Caption = 'Copy to clipboard supported DTDs'
    end
    object actRefreshConstructionForm: TAction
      Category = 'act'
      Caption = 'Refresh Construction Form'
      ShortCut = 16500
    end
    object actBuildDocIndex: TAction
      Category = 'act'
      Caption = 'Build document index'
      Hint = 'Rebuild document index'
    end
    object actApplyDocFilter: TAction
      Category = 'act'
      Caption = 'Apply document filter'
    end
    object actBuildPhrasesList: TAction
      Category = 'act'
      Caption = 'Build phrases list of all documents'
      Hint = 
        'Rebuild phrases dictionary for documents of selected type in the' +
        ' current folder'
    end
    object actPhrasesManager: TAction
      Category = 'act'
      Caption = 'Phrases manager'
      Hint = 'Manage phrases dictionary, translate,..'
    end
    object actFileNewAsCurrent: TAction
      Category = 'File'
      Caption = 'Create new document as copy of current'
      Hint = 'Create new document and copy current document to it'
      ShortCut = 24654
    end
    object actFileRecentFiles: TAction
      Category = 'File'
      Caption = '&Reopen recent file ...'
      Hint = 'reopen recent file(s)'
      ShortCut = 49231
    end
    object actEditUndo: TAction
      Category = 'Edit'
      Caption = 'Undo'
      Hint = 'Undo the last action'
      ShortCut = 16474
    end
    object actEditRedo: TAction
      Category = 'Edit'
      Caption = 'Redo'
      Hint = 'Redo the previously undone action'
      ShortCut = 24666
    end
  end
end
