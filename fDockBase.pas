unit
  fDockBase;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  d  o  c  k  b  a  s  e                                                  *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   apoo editor main form                                                     *
*   Conditional defines: XML_IDX-building words vs USMARC field number in idx  *
*                        USE_DOM-using XSLT if MS DOM engine in preview       *
*                        USE_SAX-using SAX routines in XPATH search dialog     *
*                        USE_JCL-reserved                                     *
*   Revisions    : Jul 06 2001, Oct 11 2001                                    *
*   Last revision: Oct 24 2003                                                *
*   Lines        : 5431                                                        *
*   History      : see todo file                                              *
*                                                                              *
*                                                                             *
*   Printed      :                                                             *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Clipbrd,
  Dialogs, ExtCtrls, StdCtrls, StdActns, ActnList, ActnMan, ComCtrls, ActnCtrls,
  ToolWin, ActnMenus, Registry, ValEdit, DdeMan, Menus, OleCtrls, SHDocVw, XPStyleActnCtrls,
  jclUnicode, jclDateTime, jclShell, HtmlHlp, FileCtrl,
  wml, xhtml, oebdoc, oebpkg, biotaxon, smit, xhhc, xhhk, rtc,
  util1, utilwin, utilHttp, browserutil, wmleditutil,
  customxml, wmlc, xmlsupported, xmlParse,
  EMemo, EMemoCode, EMemos,
  EMemoHTMLCode, EMemoWMLCode, EMemoOEBCode, EMemoPkgCode, EMemoXHTMLCode, EMemoTaxonCode, EMemoSMITCode,
  rtcShellHelper, rtcFolderTree, SpellerMSO,
  secure, wmlAEdit, wbmpImage,
  LitConv, IE5Tools,
  appconst,
  xmlidx,  // requires XML_IDX conditional defines
  fbuildxmlidx, fbuildxmlphrases, fGenLit, fByteCode, fEditText,
  ActiveX,
  GifImage,
  util_DOM,
  ShellAPI,  // DragAcceptFiles
  dbxmlInt   // db server extension
  ;

const
  ICON_LINE_CURSOR = 48;
  { ads }
  MyBannerImg = 'http://www.qksrv.net/image-1020521-1169313';
  MyBannerHref = 'http://affiliates.allposters.com/link/redirect.asp?AID=1639823880&PSTID=4&LTID=16';

  MyBannerHint     = 'Click to request posters'#13#10'If you want to remove this banner, press F4 to register evaluation copy';
  SMSG_WARNING     = 'This feature is not avaliable in evaluation version.'#13#10'You can register your copy of this progran for $19 online:'#13#10'http://www.regsoft.net/purchase.php3?productid=38958';
  SMSG_THANKS      = 'Thank you!'#13#10'Please save message with your license key';
  SMSG_INVALIDKEY  = 'Sorry, entered key is invalid'#13#10'Please copy and paste license key from message'#13#10+
    'Note: Name and key are case sensitive';
  MSG_NOT_IMPLEMENTED = 'Sorry, this feature is not implemented yet.'#13#10+
    'This feature ''ll be available soon'#13#10+
    'You can download latest version from web site soon free of charge';

  // in "File Find" dialog in case of "Search in Directories" option this file created in root search directory
  // and contains found file description
  SRCH_DIR_DESC_FILE = 'idx.lst';
  SRCH_DIR_EXEC_FILE = 'found.tmp';

  DEFAULT_OPENDIALOG_FILTER =
  // 1
    'WML files(*.wml)|' +
  // 2
    '*.wml|Text files(*.txt)|*.txt|'+
  // 3                                     4
    'HTML files(*.htm;*.html)|*.htm;*.html|WML compiled(*.wmlc)|*.wmlc|'+
  // 5
    'WML template(*.wmlt)|*.wmlt|'+
  // 6
    'Open eBook publication(*.oeb;*.htm;*.html)|*.oeb;*.htm;*.html|'+
  // 7
    'Open eBook packaging file(*.opf)|*.opf|'+
  // 8
    'Cascade style sheet file(*.css)|*.css|'+
  // 9
    'xHTML files(*.xhtml;*.html;*.htm;*.xml)|*.xhtml;*.html;*.htm;*.xml|'+
  // 10
    'taxon files(*.txn;*.xml)|*.txn;*.xml|'+
  // 11
    'SMIT xml files(*.smt;*.xml)|*.smt;*.xml|'+
  // 12
    'CHM Help Content(*.hhc)|*.hhc|'+
  // 13
    'CHM Help Keywords(*.hhk)|*.hhk|'+
  // 14
    'All files(*.*)|*.*';
  DEFAULT_OPENDIALOG_TITLE  = 'Open file(s)';
  DEFAULT_SAVEASDIALOG_TITLE  = 'Save file';
  { registry constants }
  APPNAME = 'apoo editor';
  { version }
  LNVERSION = '1.0';
  { resource language }
  LNG = ''; { DLL language usa, 409 }
  { registry path }
  RGPATH = '\Software\ensen\' + APPNAME + '\' + LNVERSION;
  RG_EXTERNALSTORAGE_SITES = '\sites';

  ID_FIRST                     = 0;
  ID_COMPANY                   = 0;
  ID_USER                      = 1;
  ID_CODE                      = 2;
  ID_ConfigDir                 = 3;
  ID_DesktopGeometry           = 4;
  ID_WindowSize                = 5;
  ID_DesktopDock               = 6;
  ID_Settings                  = 7;
  ID_LastDirectory             = 8;
  ID_DefDitherMode             = 9;
  ID_StretchPreview            = 10;
  ID_BlockIndent               = 11;
  ID_Encoding                  = 12;
  ID_Languages                 = 13;
  ID_FontName                  = 14;
  ID_FontSize                  = 15;
  ID_RightMarginWidth          = 16;
  ID_GutterWidth               = 17;
  ID_UseRightMargin            = 18;
  ID_UseGutter                 = 19;
  ID_UseBoldTags               = 20;
  ID_Extensions                = 21;
  ID_WBXMLVersion              = 22;
  ID_FIRSTDATESTART            = 23;
  ID_EditorColors              = 24;
  ID_AutoComplete              = 25;
  ID_AutoCompleteInterval      = 26;
  ID_LastFileFilter            = 27;
  ID_AutoStartGenLIT           = 28;  // automatically start up generate LIT
  ID_CompileModifiedAtDelay    = 29;  // automatically compile if source is modified after time delay
  ID_CompileBeforeSave         = 30;  // compile source before savings
  ID_HighlightTag              = 31;
  ID_HighlightSTag             = 32;
  ID_HighLightEntity           = 33;  //
  ID_NumerateLines             = 34;  // show line numbers
  ID_UDLFolder                 = 35;  // default ADO .udl folder
  ID_INFOTIP                   = 36;  // explore info tip
  ID_TOGGLEISTBUTTON           = 37;  // show/hide IE toolbar button
  ID_WORKDIR                   = 38;  // temporary files folder
  ID_DbDrvEnable               = 39;
  ID_DbDrvFileName             = 40;
  ID_SymbolUnicodeBlock        = 41;
  ID_FtpProxy                  = 42;
  ID_SrchDirExecExternal       = 43;
  ID_FormatCompressSpaces      = 44;
  ID_Entities2Char             = 45;
  ID_Char2Entities             = 46;

  ID_Reserved                  = 47;
  ID_LAST                      = 47;

  ParameterNames: array[ID_FIRST..ID_LAST] of String[15] = (
  'Company', 'Name', 'Code', 'ConfigDir', 'Geometry',
  'WindowSize','DesktopDock', 'Settings', 'LastDirectory', 'DefDitherMode',
  'StretchPreview', 'BlockIndent', 'EncodingCharSet', 'Languages', 'FontName',
  'FontSize', 'RightMargin', 'GutterWidth', 'UseRightMargin', 'UseGutter',
  'BoldTags', 'Extensions',  'WBXMLVersionIdx', '1stDate', 'EditorColors',
  'AutoComplete', 'AutoCompleteInt', 'LastFileExtFilt', 'AutoStartGenLIT', 'CmplMdfdAtDelay',
  'CmplBeforeSave', 'HighlightTag', 'HighlightSTag', 'HighlightEntity', 'NumerateLines',
  'UDLFolder', 'InfoTip', 'ShowIETBtn', 'WorkDir', 'DbDrvEnable', 'DbDrvFileName',
  'UnicodeBlock', 'FtpProxy', 'SrchDirExecExt', 'FmtCompressSpc', 'LoadOpts',
  'SaveOpts', 'Reserved');

  DOCKCONTROLCOUNT = 5;

  // help topic file prefix
  HELP_PREFIX_OEB = 'ob';
  HELP_PREFIX_PKG = 'op';
  HELP_PREFIX_XHTML = 'ob'; // must be 'xh', but help file does not ready

resourcestring
  MSG_SAVEFILE      = 'File %s has been modified. Save?';
  MSG_NOFEATURE     = 'Cannot proceed file %s - feature is not implemented.';
  // MSG_CONFIRMFORMAT = 'Incorrect elements will be deleted. Format source "%s"?';
  MSG_TEXTNOTFOUND  = 'Search string ''%s'' not found.';
  MSG_INTERNALERROR = 'Internal error: %d';
  MSG_NOHELPFILE    = 'Help file: %s not found.';
  MSG_REPLACEFILE   = 'File %s exists. Override?';
  MSG_DELETEFILE    = 'Can not delete file %s.';

type
  TWMLEditorState = set of (esCompiling, esClearCollection);
  {
    asShowBanner - show banners from the internet (otherwise from resource)
  }
  TAppSettings = (asEvaluation, asShowBanner, asAllowDocking);
  TAppSettingsSet = set of TAppSettings;

  TDockableControlsArray = array[0..DOCKCONTROLCOUNT - 1] of TWinControl;

var
  FileList2Open: TStrings;
  HaveFolder: Integer;

type
  TFormDockBase = class(TForm)
    Timer1: TTimer;
    sys: TDdeServerConv;
    ActionManager1: TActionManager;
    CoolBar1: TCoolBar;
    TreeViewElements: TTreeView;
    ActionMainMenuBar1: TActionMainMenuBar;
    ActionToolBar1: TActionToolBar;
    ToolBarElements: TToolBar;
    TBHelp: TToolButton;

    PanelDockSite: TPanel;
    PanelAds: TPanel;
    PanelProject: TPanel;
    PanelProjectTreeView: TPanel;
    PanelEditor: TPanel;
    ListBoxInfo: TListBox;
    PageControlEditors: TPageControl;
    TCOpenFiles: TTabControl;
    TSCode: TTabSheet;
    TSPreview: TTabSheet;
    StatusBar1: TStatusBar;

    actFileNewDeck: TAction;
    actFileNewFromTemplate: TAction;
    actFileOpen: TFileOpen;
    actFileSaveAs: TFileSaveAs;
    actFileSave: TAction;
    actFileClose: TAction;
    actFileExit: TFileExit;

    actEditCut: TEditCut;
    actEditCopy: TEditCopy;
    actEditPaste: TEditPaste;

    actHelpAbout: TAction;
    actHelpHowToRegister: TAction;
    actHelpEnterCode: TAction;
    actHelpGetCode: TAction;

    actViewWindowProject: TAction;
    actViewWindowEditor: TAction;
    actViewWindowElement: TAction;
    actViewWindowAttribute: TAction;
    actViewWindowMessages: TAction;
    actViewWindowAllowDock: TAction;
    actViewEditorOnly: TAction;

    actOptionsSaveDesktopConfiguration: TAction;
    actOptionsLoadDesktopConfiguration: TAction;
    actOptionsFileAssociate: TAction;
    actOptionsEditor: TAction;
    actOptionsSettings: TAction;

    actEditDeleteCurrentElement: TAction;
    actRestoreDefaultWindow: TAction;
    actEditFind: TAction;
    actEditFindNext: TAction;
    actEditReplace: TAction;
    actFTPEdit: TAction;

    actToolsWBMPConvertor: TAction;

    actUpdateMenus: TAction;
    actParseCommandLine: TAction;
    actViewCompileCurrentFile: TAction;
    actStoreCode: TAction;
    actValidateCode: TAction;
    actTagInfo: TAction;
    actInsertImage: TAction;
    actImageSaveAsWBMP: TFileSaveAs;
    actEditMoveElementUp: TAction;
    actEditMoveElementDown: TAction;
    actViewInfo: TAction;
    actToolsReformat: TAction;
    actFormatDialog: TAction;
    actEditSelectAll: TAction;
    actHelpContents: TAction;
    pmFolderTree: TPopupMenu;
    pmFolderTreeEdit: TMenuItem;
    pmFolderTreeD1: TMenuItem;
    pmFolderTreeNewFile: TMenuItem;
    pmFolderTreeD2: TMenuItem;
    actFilePrint: TAction;
    actHelpNagScreen: TAction;
    actEditInsertSymbol: TAction;
    actFileGenerateLIT: TAction;
    actFolderTreeGenerateLIT: TAction;
    pmOpenFiles: TPopupMenu;
    pmOpenFilesClosePage: TMenuItem;
    pmOpenFileD1: TMenuItem;
    actOptionsADO: TAction;
    WBPreview: TWebBrowser;
    actRefreshPreview: TAction;
    pmInfo: TPopupMenu;
    actClearMessages: TAction;
    actClearSearch: TAction;
    pmInfoClearMessages: TMenuItem;
    pmInfoD1: TMenuItem;
    pmInfoClearSearch: TMenuItem;
    actSaveAll: TAction;
    actFileNewXHTML: TAction;
    actFileNewOEB: TAction;
    actFileNewPKG: TAction;
    actFileCreatePackageByOEB: TAction;
    actToolsSpellCheck: TAction;
    actOptionsSpelling: TAction;
    actViewByteCode: TAction;
    pmFolderTreeSysCtxMenu: TMenuItem;
    PageScroller1: TPageScroller;
    PCProject: TPageControl;
    TSFiles: TTabSheet;
    TSDocuments: TTabSheet;
    LVDocuments: TListView;
    PanelDocumentsFolder: TPanel;
    LCurrentFolder: TLabel;
    actFileNewTaxon: TAction;
    actHelpCreateDTD: TAction;
    TSForm: TTabSheet;
    actRefreshConstructionForm: TAction;
    ScrollBoxForm: TScrollBox;
    PanelForm: TPanel;
    actXPathQuery: TAction;
    EFilterDoc: TEdit;
    LFilterDoc: TLabel;
    BFilterDoc: TButton;
    BBuildFilter: TButton;
    actBuildDocIndex: TAction;
    actApplyDocFilter: TAction;
    PanelFilter: TPanel;
    LFilter: TLabel;
    CBFilter: TComboBox;
    actFileNewSmit: TAction;
    actEnterPCDATA: TAction;
    debug_ViewElementPosition: TAction;
    TBSep1: TToolButton;
    TBOpen: TToolButton;
    TBSep2: TToolButton;
    pmRecentFiles: TPopupMenu;
    actBuildPhrasesList: TAction;
    actPhrasesManager: TAction;
    pmInfoD0: TMenuItem;
    pmInfoCopy: TMenuItem;
    actFileNewAsCurrent: TAction;
    actFileRecentFiles: TAction;
    actEditUndo: TAction;
    actEditRedo: TAction;
    actFileNewHHC: TAction;
    actFileNewHHK: TAction;
    actFileNewRTC: TAction;

    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    // File browser actions
    procedure FolderTree1DblClick(Sender: TObject);
    // folder tree popup menu
    procedure pmFolderTreePopup(Sender: TObject);
    // Elements tree view actions
    procedure ButtonEditClick(Sender: TObject);
    // procedure TCTopElementChange(Sender: TObject);
    procedure TreeViewElementsChange(Sender: TObject; Node: TTreeNode);
    procedure CBFilterChange(Sender: TObject);
    // Messages
    procedure ListBoxInfoDblClick(Sender: TObject);
    // editor
    procedure TCOpenFilesChange(Sender: TObject);
    procedure OnMemoEvents(Sender: TObject; Shift: TShiftState; KeyEvent: TGsKeyEvent;
      Key: Word; CaretPos, MousePos: TPoint; Modified, OverwriteMode: Boolean);
    procedure TreeViewElementsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeViewElementsEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure PanelProjectResize(Sender: TObject);
    procedure sysExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure TSCodeExit(Sender: TObject);

    procedure actFileNewFromTemplateExecute(Sender: TObject);
    procedure actFileNewDeckExecute(Sender: TObject);
    procedure actFileSaveExecute(Sender: TObject);
    procedure actFileOpenBeforeExecute(Sender: TObject);
    procedure actFileOpenAccept(Sender: TObject);
    procedure actFileSaveAsBeforeExecute(Sender: TObject);
    procedure actFileSaveAsAccept(Sender: TObject);
    procedure actFileCloseExecute(Sender: TObject);
    procedure actFTPEditExecute(Sender: TObject);

    procedure actEditCopyExecute(Sender: TObject);
    procedure actEditCutExecute(Sender: TObject);
    procedure actEditPasteExecute(Sender: TObject);
    procedure actEditDeleteCurrentElementExecute(Sender: TObject);
    procedure actEditFindExecute(Sender: TObject);
    procedure actEditFindNextExecute(Sender: TObject);
    procedure actEditReplaceExecute(Sender: TObject);

    procedure actOptionsLoadDesktopConfigurationExecute(Sender: TObject);
    procedure actOptionsSaveDesktopConfigurationExecute(Sender: TObject);
    procedure actOptionsSettingsExecute(Sender: TObject);
    procedure actOptionsFileAssociateExecute(Sender: TObject);

    procedure actHelpAboutExecute(Sender: TObject);
    procedure actHelpEnterCodeExecute(Sender: TObject);
    procedure actHelpHowToRegisterExecute(Sender: TObject);
    procedure actHelpGetCodeExecute(Sender: TObject);

    procedure actViewWindowProjectExecute(Sender: TObject);
    procedure actViewWindowEditorExecute(Sender: TObject);
    procedure actViewWindowElementExecute(Sender: TObject);
    procedure actViewWindowAttributeExecute(Sender: TObject);
    procedure actViewWindowMessagesExecute(Sender: TObject);
    procedure actViewWindowAllowDockExecute(Sender: TObject);
    procedure actViewCompileCurrentFileExecute(Sender: TObject);
    procedure actViewEditorOnlyExecute(Sender: TObject);

    procedure actToolsWBMPConvertorExecute(Sender: TObject);

    procedure actValidateCodeExecute(Sender: TObject);
    procedure actStoreCodeExecute(Sender: TObject);
    procedure actParseCommandLineExecute(Sender: TObject);
    procedure actHelpTagInfoExecute(Sender: TObject);
    procedure actRestoreDefaultWindowExecute(Sender: TObject);
    procedure ListBoxInfoDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure actInsertImageExecute(Sender: TObject);
    procedure actEditMoveElementUpExecute(Sender: TObject);
    procedure actEditMoveElementDownExecute(Sender: TObject);
    procedure actViewInfoExecute(Sender: TObject);
    procedure actToolsReformatExecute(Sender: TObject);
    procedure actFormatDialogExecute(Sender: TObject);
    procedure actEditSelectAllExecute(Sender: TObject);
    procedure actHelpContentsExecute(Sender: TObject);
    procedure actFilePrintExecute(Sender: TObject);
    procedure actHelpNagScreenExecute(Sender: TObject);
    procedure actEditInsertSymbolExecute(Sender: TObject);
    procedure actUpdateFileCanSave(Sender: TObject);
    procedure actUpdateIsFileOpened(Sender: TObject);
    procedure actUpdateIsFilePkg(Sender: TObject);
    procedure actOptionsEditorExecute(Sender: TObject);
    procedure actFileGenerateLITExecute(Sender: TObject);
    procedure actFolderTreeGenerateLITExecute(Sender: TObject);
    procedure CBFilterDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure PanelFilterResize(Sender: TObject);
    procedure actOptionsADOExecute(Sender: TObject);
    procedure actRefreshPreviewExecute(Sender: TObject);
    procedure PageControlEditorsChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure actClearMessagesExecute(Sender: TObject);
    procedure actClearSearchExecute(Sender: TObject);
    procedure actSaveAllExecute(Sender: TObject);
    procedure actSaveAllUpdate(Sender: TObject);
    procedure actFileNewXHTMLExecute(Sender: TObject);
    procedure actFileNewOEBExecute(Sender: TObject);
    procedure actFileNewPKGExecute(Sender: TObject);
    procedure actFileCreatePackageByOEBExecute(Sender: TObject);
    procedure actFileCreatePackageByOEBUpdate(Sender: TObject);
    procedure actToolsSpellCheckUpdate(Sender: TObject);
    procedure actToolsSpellCheckExecute(Sender: TObject);
    procedure actOptionsSpellingExecute(Sender: TObject);
    procedure actUpdateWML_WMLC_Opened(Sender: TObject);
    procedure actViewWindowEditorUpdate(Sender: TObject);
    procedure actViewWindowElementUpdate(Sender: TObject);
    procedure actViewWindowAttributeUpdate(Sender: TObject);
    procedure actViewWindowMessagesUpdate(Sender: TObject);
    procedure actViewWindowProjectUpdate(Sender: TObject);
    procedure actViewByteCodeUpdate(Sender: TObject);
    procedure actViewByteCodeExecute(Sender: TObject);
    procedure PCProjectChanging(Sender: TObject; var AllowChange: Boolean);
    procedure LVDocumentsDblClick(Sender: TObject);
    procedure actFileSysCtxMenuExecute(Sender: TObject);
    procedure actFileNewTaxonExecute(Sender: TObject);
    procedure actHelpCreateDTDExecute(Sender: TObject);
    procedure LVDocumentsData(Sender: TObject; Item: TListItem);
    procedure PageControlEditorsChange(Sender: TObject);
    procedure actRefreshConstructionFormExecute(Sender: TObject);
    procedure TreeViewElementsClick(Sender: TObject);
    procedure actXPathQueryExecute(Sender: TObject);
    procedure actBuildDocIndexExecute(Sender: TObject);
    procedure actApplyDocFilterExecute(Sender: TObject);
    procedure EFilterDocKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actFileNewSmitExecute(Sender: TObject);
    procedure actEnterPCDATAExecute(Sender: TObject);
    procedure PanelDocumentsFolderResize(Sender: TObject);
    procedure debug_ViewElementPositionExecute(Sender: TObject);
    procedure actBuildPhrasesListExecute(Sender: TObject);
    procedure actPhrasesManagerExecute(Sender: TObject);
    procedure actFileNewAsCurrentExecute(Sender: TObject);
    procedure actFileRecentFilesExecute(Sender: TObject);
    procedure actEditUndoExecute(Sender: TObject);
    procedure actEditRedoExecute(Sender: TObject);
    procedure actEditRedoUpdate(Sender: TObject);
    procedure actEditUndoUpdate(Sender: TObject);
    procedure actFileNewHHCExecute(Sender: TObject);
    procedure actFileNewHHKExecute(Sender: TObject);
    procedure actFileNewRTCExecute(Sender: TObject);
  private
    { Private declarations }
    FirstTime: Boolean;
    FCanSpell: Boolean;
    FMSOSpellChecker: TMSOSpellChecker;
    FBanner: THttpGifLoader;      // ads
    FCurElement: TxmlElement;
    // collection of wml elements. First element is TWMLContainer
    FWMLCollection: TxmlElementCollection;
    // collection of oeb elements. First element is TOEBContainer
    FOEBCollection: TxmlElementCollection;
    // collection of oeb package elements. First element is TPkgContainer
    FPkgCollection: TxmlElementCollection;
    // collection of XHTML package elements. First element is THtmContainer
    FXHTMLCollection: TxmlElementCollection;
    // collection of Taxon package elements. First element is THtmContainer
    FTaxonCollection: TxmlElementCollection;
    // collection of SMIT elements. First element is TSmtContainer
    FSMITCollection: TxmlElementCollection;
    // collection of HHC elements. First element is THHCContainer
    FxHHCCollection: TxmlElementCollection;
    // collection of HHK elements. First element is THHCContainer
    FxHHKCollection: TxmlElementCollection;
    // collection of RTC elements. First element is THHCContainer
    FxRTCCollection: TxmlElementCollection;

    // file browser filter
    FolderTree1: TrtcFolderTree;
    // attribute string grid
    FAttributeInspector: TPropertyEditor;
    // text search engine context
    FSearchContext: wmleditutil.TSearchContext;
    // FSearchEngine: jclUnicode.TSearchEngine;
    // compiler state
    FState: TWMLEditorState;
    // character set to encode
    FEncoding: Integer; // like csUTF8
    // WBXML version used to store compiled wmlc
    FWBXMLVersion: Integer;
    // language list
    FLanguages: TStrings;
    // db parser buffer
    FCallBackBuffer: WideString;

    MemoWMLCode: TEMemoWMLCode;
    MemoHTMLCode: TEMemoHTMLCode;
    MemoOEBCode: TEMemoOEBCode;
    MemoPkgCode: TEMemoPkgCode;
    MemoXHTMLCode: TEMemoXHTMLCode;
    MemoTaxonCode: TEMemoTaxonCode;
    MemoSMITCode: TEMemoSMITCode;

    FDockableControlsArray: TDockableControlsArray;

    FDocListViewCache: array of record d: Pointer; s: ShortString; end;
    //

    function GetCurrentParentNode: TTreeNode;
    function CheckSpellEngine: Boolean;
    procedure SetEncoding(AValue: Integer);
    procedure SetWBXMLVersion(AValue: Integer);
    // file browser filter
    procedure RebuildFilter;
    procedure RefreshFolderViews(const AFilter: String);
    // display element
    procedure ViewElement(AxmlElement: TxmlElement);
    // attributes
    procedure ToolButtonNewClick(Sender: TObject);  // create nested new element
    procedure ReflectAttributeChange(const AAttributeName: String; AAttributeValue: WideString; AElement: TxmlElement; AMemo: TECustomMemo);
    procedure ViewSource(AWMLElement: TxmlElement);
    procedure OnValidateAttributes(Sender: TObject; ACol, ARow: Longint; const KeyName, KeyValue: string);
    procedure OnKeyDownAttributes(Sender: TObject; var Key: Word; Shift: TShiftState);
    function OnProcessTemplateAttributes (AWMLElement: TxmlElement; const AAttribute, AValue: String): Boolean;
    procedure OnLoadingProcessTemplate(Sender: TObject; var ATemplate: WideString);
    procedure OnModifiedSourceTimeDelay(Sender: TObject);
    procedure OnClickFBanner(Sender: TObject);  // ads
    procedure OnEllipsisClick(Sender: TObject);

    procedure ShowSysCtxMenu(APosition: TPoint);
    procedure MenuRecentFileClick(Sender: TObject);
    procedure BuildDocIndex(const AFileFolderName, AListFileName: String);
  protected
    function GetElementTreeViewNode(AxmlElement: TxmlElement): TTreeNode; // return  tree node points to wml element, nil if not found
    function getContainerByDoctype(ADocType: TEditableDoc): TxmlElement;
    procedure OnReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
      const ASrc: PWideChar; ASrcLen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
      var AContinueParse: Boolean; AEnv: Pointer);
    procedure WMDropFiles(var Msg: TWMDropFiles); message wm_DropFiles;
  public
    { Public declarations }
    FAppSettingsSet: TAppSettingsSet;
    FParameters: TStrings;
    FRegistered: Boolean;
    // editor
    Memos: TEMemos;
    function GetXMLByFileNameProc(const AFileName: String; ADocType: TEditableDoc): TxmlElement;
    function LoadIni: Boolean;
    function StoreIni(AKind: Integer): Boolean;
    //
    procedure AddParseMessage(ALevel: TReportLevel; AWMLElement: TxmlElement;
      const ASrc: PWideChar; ASrcLen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
      var AContinueParse: Boolean; AEnv: Pointer);
    procedure Start;
    procedure Finish;
    // editor
    function GetCurMemo: TECustomMemo;
    function GetCurMemoFileStatus: TFileStatus;
    function NewFile(ADoc: TEditableDoc; const ADeckNamePrefix: String; const AContent: WideString): String;
    function CloseFile(AIdx: Integer; AAppClose: Boolean): Word;  // close opened file

    function OpenFiles(AFilesList: TStrings; AType: TEditableDoc = edDefault;
      ARefreshViewOnChangeTab: Boolean = True): Integer;
    procedure CreateBanner(AControl: TControl);
    property CurElement: TxmlElement read FCurElement write ViewElement;
    property Encoding: Integer read FEncoding write SetEncoding;
    property WBXMLVersion: Integer read FWBXMLVersion write SetWBXMLVersion;
    // property EMemos: TEMemos read Memos;
    procedure GenerateLIT(const AFileName: String; ADocType: TEditableDoc; AStorage: TStorageType);
    procedure ShowHelpByIndex(Pt: TPoint; AFileStatus: TFileStatus; AKey: String);
    procedure OnElementChange(ANewElement: TxmlElement);
    procedure OnSelectElementClick(Sender: TObject);  // create nested new element
  end;

var
  FormDockBase: TFormDockBase;

implementation

uses
  util_xml, ememocmd, versions, litgen_msgcodes,
  fRegister, FAbout, FPrint,
  fElDesc, fFind, fFindReplace, fXPath, fPreferences, fFmtInput, fNag,
  fFloating, ffileassoc, fInformation, fEditorOptions, fExtStorageList,
  fAskFormat, // fFTPSettings,
  dm,
{$IFDEF NOSPLASH}
{$ELSE}
  fSplash,
{$ENDIF}
  fSymbol, fPrefADO, fSearching;

{$R *.dfm}

// return  tree node points to wml element, nil if not found
function TFormDockBase.GetElementTreeViewNode(AxmlElement: TxmlElement): TTreeNode;
var
  i: Integer;
begin
  Result:= Nil;
  with TreeviewElements do begin
    for i:= 0 to Items.Count - 1 do begin
      if Items[i].Data = AxmlElement then begin
        Result:= TreeviewElements.Items[i];
        Exit;
      end;
    end;
  end;
end;

function HexString2Bin(AHexString: String): String;
var
  i: Integer;
  S3: String[3];
begin
  Result:= '';
  i:= 1;
  while i < Length(AHexString) do begin
    S3:= '$' + AHexString[i] + AHexString[i+1];
    Result:= Result + Char(StrToIntDef(S3, 0));
    Inc(i, 2);
  end;
end;

function BinString2Hex(ABinString: String): String;
var
  i: Integer;
begin
  Result:= '';
  for i:= 1 to Length(ABinString) do begin
    Result:= Result + IntToHex(Byte(ABinString[i]), 2);
  end;
end;

{ load settings from registry }
function TFormDockBase.LoadIni: Boolean;
var
  i: Integer;
  Rg: TRegistry;
  S: String;
  loaded: Boolean;

  function RgPar(ParamName, DefaultValue: String): String;
  var
    S: String;
  begin
    try
      S:= Rg.ReadString(ParamName);
    except
    end;
    if S = ''
    then RgPar:= DefaultValue
    else RgPar:= S;
  end;

  procedure AddPar(ParamName, DefaultValue: String);
  begin
    FParameters.Add(ParamName + '=' + RgPar(ParamName, DefaultValue));
  end;

  procedure LoadRecentFiles;
  var
    SL: TStringList;
    c: Integer;
    m: TMenuItem;
    p: String;
  begin
    pmRecentFiles.Items.Clear;
    SL:= TStringList.Create;
    p:= RGPATH + '\RecentFiles';
    if not Rg.KeyExists(p)
    then Exit;
    try
      Rg.OpenKey(p, False);
      RG.GetValueNames(SL);
    except
      Exit;
    end;
    //  pmRecentFiles.Delete(0);
    for c:= 0 to SL.Count - 1 do begin
      if c >= $10 then Break;
      m:= TMenuItem.Create(pmRecentFiles);
      m.Caption:= '&' + IntToHex(c, 1) + #32 + SL[c];
      m.ImageIndex:= GetBitmapIndexByFileName(SL[c]) + 1;
      m.OnClick:= MenuRecentFileClick;
      pmRecentFiles.Items.Add(m);
    end;
    SL.Free;
  end;

begin
  FParameters.Clear;
  Rg:= TRegistry.Create;
  loaded:= true;
  Rg.RootKey:= HKEY_CURRENT_USER;// HKEY_LOCAL_MACHINE;
  if not Rg.OpenKey(RGPath, False) then begin
    // create default values
    // first try open local machine registry
    Rg.RootKey:= HKEY_LOCAL_MACHINE;
    if Rg.OpenKey(RGPATH, False) then begin
      // ok, us it
    end else begin
      // no, create new one
      Rg.RootKey:= HKEY_CURRENT_USER;// HKEY_LOCAL_MACHINE;
      Rg.OpenKey(RGPATH, True);
      //
      actRestoreDefaultWindowExecute(Self);
      actOptionsSaveDesktopConfigurationExecute(Self);
      loaded:= false;
    end;
    FParameters.Values[ParameterNames[ID_LastDirectory]]:= GetCurrentDir;
  end;
  if loaded then begin
    // read settings from registry
    for i:= Low(ParameterNames) to High(ParameterNames) do begin
      AddPar(ParameterNames[i], '');
    end;
  end;
  // I can't shoot this bug after creaion, so just disable
  FAppSettingsSet:= FAppSettingsSet - [asAllowDocking];
  {
  for i:= 0 to $F do begin
    AddPar(ParameterNames[ID_LASTPRODUCT]+'-'+sysutils.IntToHex(i, 1), '');
    S:= FParameters.Values[ParameterNames[ID_LASTPRODUCT]+'-'+sysutils.IntToHex(i, 1)];
    if Length(S) > 0
    then CBProduct.Items.Add(S);
  end;
  }
  // last directory
  s:= FParameters.Values[ParameterNames[ID_LastDirectory]];
  if DirectoryExists(s) then begin
    FolderTree1.Directory:= s;
  end else begin
    s:= ExtractFilePath(s);
    if (Length(S) > 0) and (DirectoryExists(S))
    then FolderTree1.Directory:= s;
  end;
  // last file extension filter
  i:= StrToIntDef(FParameters.Values[ParameterNames[ID_LastFileFilter]], 0);
  if (i >= 0) and (i < CBFilter.Items.Count)
  then CBFilter.ItemIndex:= i;

  // config directory
  if Length(FParameters.Values[ParameterNames[ID_ConfigDir]]) = 0
  then FParameters.Values[ParameterNames[ID_ConfigDir]]:= GetCurrentDir;
  // set path to litgen.dll
  litConv.LITGENPATH:= FParameters.Values[ParameterNames[ID_ConfigDir]];

  // ftp proxy settings
  s:= FParameters.Values[ParameterNames[ID_FtpProxy]];
  if Length(s) > 0 then begin
    dm.dm1.SetStorageProxy(ftFTPNode, s);
  end;
  // Settings
  s:= HexString2Bin(FParameters.Values[ParameterNames[ID_Settings]]);
  SetLength(s, SizeOf(FAppSettingsSet));
  Move(s[1], FAppSettingsSet, SizeOf(FAppSettingsSet));

  // load recent files
  LoadRecentFiles;

  Rg.Free;
  Result:= True;
end; { LoadIni }

function TFormDockBase.StoreIni(AKind: Integer): Boolean;
var
  Rg: TRegistry;
  i, p: Integer;
  s: String;
begin
  Result:= True;
  Rg:= TRegistry.Create;
  Rg.RootKey:= HKEY_CURRENT_USER; //HKEY_LOCAL_MACHINE;
  Rg.OpenKey(RGPATH, True);
  case AKind of
  0:begin
    // all parameters except registration key

    // Desktop Dock
    // actSaveDesktopConfigurationExecute(Self);

    // last directory
    FParameters.Values[ParameterNames[ID_LastDirectory]]:= ExtractFilePath(FolderTree1.Directory);
    // last file extension filter
    FParameters.Values[ParameterNames[ID_LastFileFilter]]:= IntToStr(CBFilter.ItemIndex);

    for i:= Low(ParameterNames) to High(ParameterNames) do begin
      try
        if (ANSICompareText(ParameterNames[i], ParameterNames[ID_USER])=0) or
          (ANSICompareText(ParameterNames[i], ParameterNames[ID_CODE])=0)
        then Continue;
        Rg.WriteString(ParameterNames[i], FParameters.Values[ParameterNames[i]]);
      except
        Result:= False;
      end;
    end;
    // write recent files
    Rg.DeleteKey(RGPATH + '\RecentFiles');
    Rg.OpenKey(RGPATH + '\RecentFiles', True);
    for i:= 0 to pmRecentFiles.Items.Count - 1 do begin
      if i >= $10
      then Break;
      S:= pmRecentFiles.Items[i].Caption;
      p:= Pos(#32, s);
      if p > 0
      then Delete(S, 1, p);
      Rg.WriteString(S, IntToStr(i));
    end;
    end;
  1:begin
      // registration key only
      try
        Rg.WriteString(ParameterNames[ID_USER], FParameters.Values[ParameterNames[ID_USER]]);
        Rg.WriteString(ParameterNames[ID_CODE], FParameters.Values[ParameterNames[ID_CODE]]);
      except
        Result:= False;
      end;
    end;
  end; { case }
  Rg.Free;
end; { StoreIni }

procedure TFormDockBase.FormActivate(Sender: TObject);
var
  i: Integer;
  s: String;
  dt: TDateTime;
  p: TPoint;
begin
  if FirstTime then begin
    // Desktop Dock & Geometry
    actOptionsLoadDesktopConfigurationExecute(Self);

    // set default folder for data module
    dm1.WOpenPictureDialog0.InitialDir:= FParameters.Values[ParameterNames[ID_LastDirectory]];
    actParseCommandLineExecute(Self);
    if Memos.Size = 0 then begin
      // create new deck if nothing to edit
      actFileNewDeckExecute(Self);
      // this file can close immediately so mark as non modified
      if Memos.Size > 0
      then Memos.Memo[0].Modified:= False;
    end;
{$IFDEF NOSPLASH}
{$ELSE}
    if Assigned(FormSplash) then with FormSplash do begin
      // time-out
      // LabelUserName.Caption:= ';)';  // display registered user name
      Hide;
      Free;
    end;
{$ENDIF}
    {
    Application.HelpFile := 'apoo.chm';
    HelpFile:= 'apoo.chm';
    BorderIcons:= BorderIcons + [biHelp];
    }

    // check first date
    if not FRegistered then begin
      S:= FParameters.Values[ParameterNames[ID_FIRSTDATESTART]];
      if Length(s) > 0 then begin
        try
          dt:= StrToFloat(s);
        except
          dt:= Now - 31;
        end;
      end else dt:= Now;
      s:= FloatToStr(Trunc(dt));
      FParameters.Values[ParameterNames[ID_FIRSTDATESTART]]:= s;
      if Now > dt + 31 then begin
        // expired
        actHelpNagScreenExecute(Self);
      end;
    end;

    FirstTime:= False;
  end;
end;

procedure TFormDockBase.OnValidateAttributes(Sender: TObject; ACol, ARow: Longint; const KeyName, KeyValue: string);
begin
  ReflectAttributeChange(KeyName, KeyValue, FCurElement, GetCurMemo);
end;

procedure TFormDockBase.OnKeyDownAttributes(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  with FAttributeInspector do begin
    case Key of
      VK_RETURN:begin
        ReflectAttributeChange(Keys[Selection.Top], Cells[1, Selection.Top], FCurElement, GetCurMemo);
      end;
    end; { case }
  end;
end;

// process special attributes: templates
function TFormDockBase.OnProcessTemplateAttributes (AWMLElement: TxmlElement; const AAttribute, AValue: String): Boolean;
begin
  //
  Result:= False;
end;

procedure TFormDockBase.OnLoadingProcessTemplate(Sender: TObject; var ATemplate: WideString);
var
  TempWMLCollection: TxmlElementCollection;
begin
  TempWMLCollection:= TxmlElementCollection.Create(TWMLContainer, Nil, wciOne);
  TempWMLCollection.Clear1;
  xmlParse.xmlCompileText(ATemplate, Nil, OnProcessTemplateAttributes, Nil, TempWMLCollection.Items[0], TWMLContainer);
  ATemplate:= TempWMLCollection.Items[0].CreateText(0, []);
  TempWMLCollection.Free;
end;

procedure TFormDockBase.OnModifiedSourceTimeDelay(Sender: TObject);
begin
  // if not checked this feature, do not
  if FParameters.Values[ParameterNames[ID_CompileModifiedAtDelay]] <> '1'
  then Exit;

  if not (Sender is TEMemo)
  then raise Exception.CreateFmt(MSG_INTERNALERROR, [1]);
  if GetCurMemo = TEMemo(Sender) then begin
    // just in case of current memo
    with TEMemo(Sender) do begin
      actViewCompileCurrentFileExecute(Self);
    end;
  end;
end;

procedure TFormDockBase.SetEncoding(AValue: Integer);
begin
  FEncoding:= AValue;
  Memos.DefaultEncoding:= AValue;
end;

procedure TFormDockBase.SetWBXMLVersion(AValue: Integer);
begin
  FWBXMLVersion:= AValue;
  Memos.WBXMLVersion:= AValue;
end;

type
  TEmemoCodeHighlighters = array [0..5] of TEMemoCode;
var
  HLA: TEmemoCodeHighlighters; // assigned in TFormDockBase.FormCreate(

procedure TFormDockBase.FormCreate(Sender: TObject);
var
  i, c: Integer;
  p: TPoint;
  s: String;
  b, b1, b2: Boolean;
begin
  FirstTime:= True;
  // DropTarget:= True;
  FState:= [];
  FParameters:= TStringList.Create;
  FLanguages:= TStringList.Create;

  // first wml element is TWMLContainer
  FWMLCollection:= TxmlElementCollection.Create(TWMLContainer, Nil, wciOne);
  FWMLCollection.Clear1;

  // first oeb element is TOEBContainer
  FOEBCollection:= TxmlElementCollection.Create(TOEBContainer, Nil, wciOne);
  FOEBCollection.Clear1;

  // first oeb package element is TPkgContainer
  FPkgCollection:= TxmlElementCollection.Create(TPkgContainer, Nil, wciOne);
  FPkgCollection.Clear1;

  // first XHTML package element is TPkgContainer
  FXHTMLCollection:= TxmlElementCollection.Create(THtmContainer, Nil, wciOne);
  FXHTMLCollection.Clear1;

  // first taxon element is TTxnContainer
  FTaxonCollection:= TxmlElementCollection.Create(TTxnContainer, Nil, wciOne);
  FTaxonCollection.Clear1;

  // first smit element is TSmtContainer
  FSMITCollection:= TxmlElementCollection.Create(TSmtContainer, Nil, wciOne);
  FSmitCollection.Clear1;

  // first HHC element is ThhcContainer
  FxHHCCollection:= TxmlElementCollection.Create(ThhcContainer, Nil, wciOne);
  FxHHCCollection.Clear1;

  // first HHK element is ThhkContainer
  FxHHKCollection:= TxmlElementCollection.Create(ThhkContainer, Nil, wciOne);
  FxHHKCollection.Clear1;

  // first RTC element is ThhkContainer
  FxRTCCollection:= TxmlElementCollection.Create(TRTCContainer, Nil, wciOne);
  FxRTCCollection.Clear1;

  SetLength(FDocListViewCache, 0);

  // file browser
//  CBStorage.ItemIndex:= 0;
  FolderTree1:= TrtcFolderTree.Create(TSFiles);  // PanelProjectTreeView
  with FolderTree1 do begin
    Name:= 'FolderTree1';
    Align:= alClient;
    OnDblClick:= FolderTree1DblClick;
    PopupMenu:= pmFolderTree;
    FolderOptions:= [foMyComputer, foNetworkNeighborhood, foFiles, foRecycleBin,
      foFTP, foLDAP, foHTTP, foVirtualFirst];  //FolderTree1.FolderOptions + [foFiles, foNetworkNeighborhood, foVirtualFirst, foFiles];
    OnListExternalStorageSites:= dm1.edOnListStorageSites;
    OnExternalStorageFolderList:= dm1.edOnStorageFolderList;
    Active:= True;
    DragKind:= dkDock;
    // DragMode:= dmAutomatic;
    UseDockManager:= False;
  end;

  with CBFilter do begin
    Items.Clear;
    wmleditutil.CreateFilterStrings(Items);
    ItemIndex:= 0;
  end;

  // create search context
  FSearchContext:= wmleditutil.TSearchContext.Create;
  // create property grid
  FAttributeInspector:= TPropertyEditor.Create(Self);
  // ellipsis button calls image selection form
  FAttributeInspector.OnEditButtonClick:= OnEllipsisClick;

  FAttributeInspector.ExtLanguages:= FLanguages;
  with FAttributeInspector do begin
    Name:= 'PropertyEditor';
    // Options:= Options + [goEditing, goAlwaysShowEditor];
    // DisplayOptions:= [doColumnTitles, doAutoColResize, doKeyColFixed];
    TitleCaptions.Text:= 'Attribute'#13#10'Value';
    // ParentColor:= True;
    ColWidths[0]:= 65;
    Align:= alClient;
    Parent:= Self;

    DragKind:= dkDock;
    // DragMode:= dmAutomatic;
    UseDockManager:= False;
    OnKeyDown:= OnKeyDownAttributes;   // Enter key call validate
    OnValidate:= OnValidateAttributes; //
  end;

  // WML Elements treeview
  // disable code elimination
  // GetListOfWMLElements;

  // editor
  Memos:= TEMemos.Create(TSCode, TSCode);
  with Memos do begin
    OnExit:= TSCodeExit;
    OnProcessTemplate:= OnLoadingProcessTemplate;
    OnModifiedTimeDelay:= OnModifiedSourceTimeDelay;
    OnGetStorageFile:= dm.Dm1.OnGetStorageFile;
    OnPutStorageFile:= dm.Dm1.OnPutStorageFile;
    // OnMemoDragOver:= Nil; // for inserting tag from panels reserved
    // OnMemoDragDrop:= Nil;
  end;

  MemoWMLCode:= TEMemoWMLCode.Create(Self);
  MemoOEBCode:= TEMemoOEBCode.Create(Self);
  MemoPkgCode:= TEMemoPkgCode.Create(Self);
  MemoHTMLCode:= TEMemoHTMLCode.Create(Self);
  MemoXHTMLCode:= TEMemoXHTMLCode.Create(Self);
  MemoTaxonCode:= TEMemoTaxonCode.Create(Self);
  MemoSMITCode:= TEMemoSMITCode.Create(Self);
  // FormMain.Width:= StrToIntDef(GetToken(1, 'x', FParameters.Values[ParameterNames[ID_FormSizeXY]]), FormMain.Width);
  // FolderTree.Width:= StrToIntDef(FParameters.Values[ParameterNames[ID_FolderTreeX]], FolderTree.Width);

  // ads

  CreateBanner(PanelAds);  // create FBanner

  // dockable controls

  FDockableControlsArray[0]:= PanelProject;
  FDockableControlsArray[1]:= PanelEditor;
  FDockableControlsArray[2]:= TreeViewElements;
  FDockableControlsArray[3]:= FAttributeInspector;
  FDockableControlsArray[4]:= ListBoxInfo;

  // p.X:= Self.Left;  p.Y:= Self.Top; // it doesn't matter
  // PanelDockSite.DockSite:= True;

  // undock...
  p.X:= 0;
  p.Y:= 0;

  for i:= Low(TDockableControlsArray) to High(TDockableControlsArray) do with FDockableControlsArray[i] do begin
    //  FDockableControlsArray[i].Visible:= False;
    FloatingDockSiteClass:= fFloating.TFormFloating;// TCustomDockForm;
    ManualFloat(browserutil.RectInc(P, BoundsRect));
    // '000004000000000078030000000000000279010000000000000100000001A601000000000000020000000257010000000000000300000000C80000000C00000050616E656C50726F6A6563740300000001A601000000000000040000000090000000100000005472656556696577456C656D656E74730400000000570100000E00000050726F7065727479456469746F720200000000790100000B0000004C697374426F78496E666F0100000000780300000B00000050616E656C456469746F72FFFFFFFF'
  end;

  // spell checker
  FMSOSpellChecker:= Nil;
  // is spelling engine installed
  FCanSpell:= IsMSOInstalled;

  LoadIni;

  // fix unassigned parameters (default is not '0', '1' is default value
  if Length(FParameters.Values[ParameterNames[ID_UseGutter]]) = 0
  then FParameters.Values[ParameterNames[ID_UseGutter]]:= '1';
  if Length(FParameters.Values[ParameterNames[ID_UseBoldTags]]) = 0
  then FParameters.Values[ParameterNames[ID_UseBoldTags]]:= '1';
  if Length(FParameters.Values[ParameterNames[ID_UDLFolder]]) = 0
  then FParameters.Values[ParameterNames[ID_UDLFolder]]:= '\udl';
  if Length(FParameters.Values[ParameterNames[ID_WORKDIR]]) = 0
  then FParameters.Values[ParameterNames[ID_WORKDIR]]:= ConcatPath(FParameters.Values[ParameterNames[ID_CONFIGDIR]], 'work');

  if Length(FParameters.Values[ParameterNames[ID_HighlightTag]]) = 0
  then FParameters.Values[ParameterNames[ID_HighlightTag]]:= '1';
  if Length(FParameters.Values[ParameterNames[ID_HighlightEntity]]) = 0
  then FParameters.Values[ParameterNames[ID_HighlightEntity]]:= '1';

  HLA[0]:= MemoWMLCode; HLA[1]:= MemoOEBCode; HLA[2]:= MemoPKGCode;
  HLA[3]:= MemoHTMLCode; HLA[4]:= MemoXHTMLCode; HLA[5]:= MemoTaxonCode;
  // highlighing settings

  b:= FParameters.Values[ParameterNames[ID_HighlightTag]] = '1';
  b1:= FParameters.Values[ParameterNames[ID_HighlightSTag]] = '1';
  b2:= FParameters.Values[ParameterNames[ID_HighlightEntity]] = '1';
  for i:= Low(HLA) to High(HLA) do begin
    with HLA[i] do begin
      SetBackgroundColors(clWindow);
      UseTagHighlight:= b;
      UseSpecTagsHighlight:= b1;
      UseEntityHighlight:= b2;
    end;
  end;
  // rebuilt filter
  CBFilter.OnChange(Self);

  // banner
  // FBanner.LoadPreloadedBannersFromIniFile('cf.ini', FParameters.Values[ParameterNames[ID_ConfigDir]]);

  FBanner.LoadPreloadedBannersFromResource(ConcatPath(FParameters.Values[ParameterNames[ID_ConfigDir]], RESDLLNAME),
    'cf', FParameters.Values[ParameterNames[ID_ConfigDir]]);

  // editor settings

  with Memos do begin
    BlockIndent:= StrToIntDef(FParameters.Values[ParameterNames[ID_BlockIndent]], BlockIndent);
    customxml.BlockIndent:= BlockIndent;
    FontName:= FParameters.Values[ParameterNames[ID_FontName]];
    FontSize:= StrToIntDef(FParameters.Values[ParameterNames[ID_FontSize]], 10);
    AutoComplete:= FParameters.Values[ParameterNames[ID_AutoComplete]] = '1';
    AutoCompleteInterval:= StrToIntDef(FParameters.Values[ParameterNames[ID_AutoCompleteInterval]], 3);

    DefRightMargin:= StrToIntDef(FParameters.Values[ParameterNames[ID_RightMarginWidth]], 80);
    DefGutterWidth:= StrToIntDef(FParameters.Values[ParameterNames[ID_GutterWidth]], 26);
    UseGutter:= FParameters.Values[ParameterNames[ID_UseGutter]] = '1';
    UseRightMargin:= FParameters.Values[ParameterNames[ID_UseRightMargin]] = '1';
    ShowLineNum:= FParameters.Values[ParameterNames[ID_NumerateLines]] = '1';
    EnvironmentOptions:= FParameters.Values[ParameterNames[ID_EditorColors]];

    { auto conversion tabsheet settings }
    try
      ConvOnLoadOptions:= TEntityConvOptions(Byte(StrToIntDef(FParameters.Values[ParameterNames[ID_Entities2Char]], 0)));
      ConvOnSaveOptions:= TEntityConvOptions(Byte(StrToIntDef(FParameters.Values[ParameterNames[ID_Char2Entities]], 0)));
    except
      ConvOnLoadOptions:= [];
      ConvOnSaveOptions:= [];
    end;
    Options:= [];
    if FParameters.Values[ParameterNames[ID_UseBoldTags]] = '1'
    then Options:= Options + [emUseBoldTags];
  end;

  // code page
  Encoding:= StrToIntDef(FParameters.Values[ParameterNames[ID_Encoding]], csUTF8);
  // WBXMLVersion
  WBXMLVersion:= StrToIntDef(FParameters.Values[ParameterNames[ID_WBXMLVersion]], 3);
  // languages
  with FLanguages do begin
    BeginUpdate;
    Clear;
    SetLength(S, 9);
    S[1]:= '$';
    i:= 1;
    while i + 7 <= Length(FParameters.Values[ParameterNames[ID_Languages]]) do begin
      System.Move(FParameters.Values[ParameterNames[ID_Languages]][i], S[2], 8);
      c:= StrToIntDef(S, -1);
      if c >= 0
      then AddObject(util_xml.winLangId2Abbr(c), TObject(c));
      Inc(i, 8);
    end;
    EndUpdate;
  end;

  // Desktop Dock & Geometry
//  actOptionsLoadDesktopConfigurationExecute(Self);
  // no docking is allowed immediately after creation
  // in Menu Show
  //  actViewWindowAllowDock.Checked:= asAllowDocking in FAppSettingsSet;
  // menu
  // actUpdateMenusExecute(Self);
  // wml environment
  if StrtoIntDef(FParameters.Values[ParameterNames[ID_Extensions]], 0) and 1 > 0
  then Include(xmlENV.xmlCapabilities, wcServerExtensions)
  else Exclude(xmlENV.xmlCapabilities, wcServerExtensions);
  // validate license
  actValidateCodeExecute(Self);
  ShellAPI.DragAcceptFiles(Handle, True);
end;

procedure TFormDockBase.FormDestroy(Sender: TObject);
begin
  MemoHTMLCode.Free;
  MemoPkgCode.Free;
  MemoOEBCode.Free;
  MemoWMLCode.Free;
  MemoXHTMLCode.Free;
  MemoTaxonCode.Free;
  Memos.Free;
  FSearchContext.Free;
  // FAttributeInspector.Free; // bug AVE. Free metohod called twice if attribute window is not docked- destructef eearlier
  //   FolderTree1.Free; // bug Exception 22 1D, move dot FormClose event
  FxRTCCollection.Free;
  FxHHKCollection.Free;
  FxHHCCollection.Free;
  FSmitCollection.Free;
  FTaxonCollection.Free;
  FXHTMLCollection.Free;
  FPkgCollection.Free;
  FOEBCollection.Free;
  FWMLCollection.Free;
  FLanguages.Free;
  FParameters.Free;
end;

procedure TFormDockBase.OnEllipsisClick(Sender: TObject);
var
  attrn: String;
begin
  if not Assigned(CurElement)
  then Exit;

  with FAttributeInspector do begin
    if (Selection.Top >= RowCount) or (Selection.Top < 0)
    then Exit;
    attrn:= Keys[Selection.Top];
  end;
  //
  if CurElement.ClassType = TWMLImg then begin
    // show image choose dialog
    if Pos('src', attrn) = 1 // no localsrc, just src!
    then actInsertImageExecute(Sender)
    else actEnterPCDATAExecute(Sender); // show PCDATA editor
  end else begin
    if CurElement.ClassType = TWMLInput then begin
      // show format dialog
      actFormatDialogExecute(Sender);
    end else begin
      // show PCDATA editor
      actEnterPCDATAExecute(Sender);
    end;
  end;  
end;

function TFormDockBase.getContainerByDoctype(ADocType: TEditableDoc): TxmlElement;
begin
 case ADocType of
   edWML, edWMLTemplate, edWMLCompiled: Result:= FWMLCollection.Items[0];
   edOEB: Result:= FOEBCollection.Items[0];
   edPkg: Result:= FPkgCollection.Items[0];
   edXHTML: Result:= FXHTMLCollection.Items[0];
   edTaxon: Result:= FTaxonCollection.Items[0];
   edSMIT: Result:= FSmitCollection.Items[0];
   edHHC: Result:= FxHHCCollection.Items[0];
   edHHK: Result:= FxHHKCollection.Items[0];
   edRTC: Result:= FxRTCCollection.Items[0];   
 else Result:= Nil;
 end;
end;

procedure TFormDockBase.actViewCompileCurrentFileExecute(Sender: TObject);
var
  c: Integer;
  CurMemo: TECustomMemo;
  CurFileStatus: TFileStatus;
  savecursor: TPoint;
begin
  if esCompiling in FState then begin
    Exit; // it's impossible - but in case of multithread compiling..
  end;

  CurFileStatus:= GetCurMemoFileStatus;
  if not Assigned(CurFileStatus)
  then Exit;

  // remember where we are
  if Assigned(TreeViewElements.Selected)
  then c:= TreeViewElements.Selected.AbsoluteIndex
  else c:= 0;

  // clear all elements
  FState:= FState + [esClearCollection];
  // disable listview redraws
  with TreeViewElements do begin
    Perform(WM_SETREDRAW, 0, 0);
    Items.BeginUpdate;
    Items.Clear;
  end;
  FWMLCollection.Clear1;
  FOEBCollection.Clear1;
  FPkgCollection.Clear1;
  FXHTMLCollection.Clear1;
  FTaxonCollection.Clear1;
  FSmitCollection.Clear1;
  FxHHCCollection.Clear1;
  FxHHKCollection.Clear1;
  FxRTCCollection.Clear1;  
  FAttributeInspector.xmlElement:= Nil;
  TreeViewElements.Items.EndUpdate;
  // enable listview redraws
  TreeViewElements.Perform(WM_SETREDRAW, 1, 0);

  FState:= FState - [esClearCollection];

  if CurFileStatus.DocType in [edUnknown, edText, edHTML, edCss] then begin
    // TreeViewElements.Items[0].Data:= FPkgCollection.Items[0];
    Exit;
  end;

  FState:= FState + [esCompiling];
  try
    CurMemo:= GetCurMemo;
    if not Assigned(CurMemo)
    then Exit;

    // save cursor positions
    savecursor.x:= CurMemo.CaretPos_V;
    savecursor.y:= CurMemo.CaretPos_H;
    Start;
    // wmleditutil.WMLCompileStrings(FormMain.GetCurMemo.Lines, finfo.FormInfo.AddParseMessage,
    //  TreeViewElements, FWMLCollection.Items[0]);
    xmlParse.xmlCompileText(CurMemo.Lines.Text, AddParseMessage, Nil, TreeViewElements,
      getContainerByDoctype(CurFileStatus.DocType), getContainerClassByDoctype(CurFileStatus.DocType));
    TreeViewElements.Items[0].Data:= getContainerByDoctype(CurFileStatus.DocType);
    // restore position where we were before
    if c >= TreeViewElements.Items.Count
    then c:= TreeViewElements.Items.Count - 1;

    if c >= 0
    then TreeViewElements.Select(TreeViewElements.Items[c]);  // calls TreeViewElementsChange

    with TreeViewElements.Items do begin
      // Perform(WM_SETREDRAW, 0, 0);
      BeginUpdate;
      TreeViewElements.FullExpand;
      EndUpdate;
      // Perform(WM_SETREDRAW, 1, 0);
    end;

    if (CurFileStatus.DocType in [edWML, edWMLTemplate, edWMLCompiled]) and Assigned(FormByteCode) and FormByteCode.Visible then begin
      // view byte code
      FormByteCode.SyncViewXML(FWMLCollection);
    end;

    CurMemo.ModifiedSinceLastDelay:= False;
    Finish;

    // restore cursor positions
    CurMemo.CaretPos_V:= savecursor.x;
    CurMemo.CaretPos_H:= savecursor.y;
  finally
    FState:= FState - [esCompiling];
  end;

  if PageControlEditors.TabIndex = 2 then begin
    xmlParse.AddxmlElement2Panel(getContainerByDoctype(CurFileStatus.DocType), PanelForm,
    dm.dm1.ImageList16, OnElementChange, OnSelectElementClick, ToolButtonNewClick);
  end;
end;

// new deck
procedure TFormDockBase.actFileNewDeckExecute(Sender: TObject);
begin
  // create new deck
  NewFile(edWML, 'NewDeck%s.wml', '<?xml version="1.0" encoding="utf-8"?>'#13#10 +
    '<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML 1.2//EN" "http://www.wapforum.org/DTD/wml1.2.dtd">'#13#10 +
    '<wml>'#13#10 + '</wml>');
end;

// new xhtml
procedure TFormDockBase.actFileNewXHTMLExecute(Sender: TObject);
begin
  // create new xhtml document
  NewFile(edXHTML, 'NewXHTML%s.xhtml',' <?xml version="1.0" encoding="utf-8"?>'#13#10 +
    '<!DOCTYPE xhtml PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'#13#10 +
    '<html>'#13#10 + '</html>');
end;

// new eBook document
procedure TFormDockBase.actFileNewOEBExecute(Sender: TObject);
begin
  // create new eBook document
  NewFile(edOEB, 'NewOEB%s.oeb', '<?xml version="1.0" encoding="utf-8"?>'#13#10 +
    '<!DOCTYPE xhtml PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'#13#10 +
    '<html>'#13#10'</html>');
end;

procedure TFormDockBase.actFileNewTaxonExecute(Sender: TObject);
begin
  // create new taxon document
  NewFile(edTaxon, 'NewTaxon%s.txn', '<?xml version="1.0" encoding="utf-8"?>'#13#10 +
    '<!DOCTYPE taxon PUBLIC "-//taxon//DTD taxon 1.0//EN" "http://ensen.sitc.ru/dtds/taxon-1.0/taxon1.0.dtd">'#13#10 +
    '<taxon unique-identifier="xxx">'#13#10'</taxon>');
end;

procedure TFormDockBase.actFileNewSmitExecute(Sender: TObject);
begin
  // create new SMIT document
  NewFile(edSMIT, 'NewSMIT%s.smt', '<?xml version="1.0" encoding="utf-8"?>'#13#10 +
    '<!DOCTYPE smit PUBLIC "-//smit//DTD smit 1.0//EN" "http://ensen.sitc.ru/dtds/smit-1.0/smit1.0.dtd">'#13#10 +
    '<menu>'#13#10'</menu>');
end;

// new eBook package
procedure TFormDockBase.actFileNewPKGExecute(Sender: TObject);
begin
  // create new eBook package
  NewFile(edPKG, 'NewPKG%s.opf', '<?xml version="1.0" encoding="utf-8"?>'#13#10 +
    '<!DOCTYPE package PUBLIC "+//ISBN 0-9673008-1-9//DTD OEB 1.2 Package//EN" "http://openebook.org/dtds/oeb-1.2/oebpkg12.dtd">'#13#10 +
    '<package unique-identifier="notisbn">'#13#10'</package>');
end;

procedure TFormDockBase.actFileNewHHCExecute(Sender: TObject);
begin
  // create new HHC document
  NewFile(edHHC, 'NewHHC%s.hhc',' <?xml version="1.0" encoding="utf-8"?>'#13#10 +
    ''#13#10 +  '');
end;

procedure TFormDockBase.actFileNewHHKExecute(Sender: TObject);
begin
  // create new HHK document
  NewFile(edHHK, 'NewHHK%s.hhk',' <?xml version="1.0" encoding="utf-8"?>'#13#10 +
    ''#13#10 +  '');
end;

procedure TFormDockBase.actFileNewRTCExecute(Sender: TObject);
begin
  // create new RTC document
  // guid
  NewFile(edRTC, 'NewRTC%s.rtc',' <?xml version="1.0" encoding="utf-8"?>'#13#10 +
    '<provision key="" name="">'#13#10'</provision>'#13#10);
end;

// new deck by template
procedure TFormDockBase.actFileNewFromTemplateExecute(Sender: TObject);
var
  FNs: TStrings;
begin
  //
  FNs:= TStringList.Create;
  FNs.AddObject('template 1.wmlt', Nil);
  // by template
  OpenFiles(FNs, edDefault);
  FNs.Free;
end;

procedure TFormDockBase.actFileOpenBeforeExecute(Sender: TObject);
var
  dsc: TxmlClassDesc;
  doct: TEditableDoc;
begin
  doct:= GetDocTypeByFilter(CBFilter.ItemIndex + 1);

  if Sender is TFileOpen then begin
    with TFileOpen(Sender).Dialog do begin
      Title:= DEFAULT_OPENDIALOG_TITLE;
      Options:= Options + [ofAllowMultiSelect];
      Filter:= DEFAULT_OPENDIALOG_FILTER;

      if GetxmlClassDescByDoc(doct, dsc) then begin
        DefaultExt:= dsc.defaultextension;
        FilterIndex:= CBFilter.ItemIndex + 1;
      end else DefaultExt:= DEFAULT_WML_FILEEXTENSION;
      // InitialDir:= '';
    end;
  end;
end;

procedure TFormDockBase.actFileOpenAccept(Sender: TObject);
var
  lastDir: String;
begin
  if Sender is TFileOpen then begin
    with TFileOpen(Sender).Dialog do begin
      OpenFiles(Files, GetDocTypeByFilter(FilterIndex));
      // Dec 03 2003
      if (Files.Count > 0) then begin
        lastDir:= ExtractFilePath(Files[Files.Count - 1]);
        if DirectoryExists(lastDir)
        then FolderTree1.Directory:= Files[Files.Count - 1];
      end;
    end;
  end;
end;

procedure TFormDockBase.actEditCopyExecute(Sender: TObject);
var
  ws: WideString;
  i: Integer;
begin
  if ActiveControl = TreeViewElements then begin
    if Assigned(FCurElement)
    then Clipboard.AsText:= FCurElement.CreateText(0, []);
  end else begin
    if ActiveControl = FAttributeInspector then with FAttributeInspector do begin
      // if FAttributeInspector.Row < FAttributeInspector.RowCount
      Clipboard.AsText:= Cells[0, Row] +
        '=' + WMLEntityStr(Cells[1, Row]);
    end else begin
      if ActiveControl = ListboxInfo then begin
        ws:= '';
        for i:= 0 to ListboxInfo.Items.Count - 1 do begin
          if ListboxInfo.Selected[i] then begin
            ws:= ws + ListboxInfo.Items[i] + #13#10;
          end;
        end;
        Clipboard.AsText:= ws;
      end else begin
        if ActiveControl is TECustomMemo then begin
          TECustomMemo(ActiveControl).CopyToClipboard;
        end else begin
          if ActiveControl is TCustomEdit then begin
            TCustomEdit(ActiveControl).CopyToClipboard;
          end;
        end;
      end;
    end;
  end;
end;

procedure TFormDockBase.actEditCutExecute(Sender: TObject);
var
  i: Integer;
  ws: WideString;
begin
  if ActiveControl = TreeViewElements then begin
    if Assigned(FCurElement)
    then Clipboard.AsText:= FCurElement.CreateText(0, []);
  end else begin
    if ActiveControl = FAttributeInspector then with FAttributeInspector do begin
      // if FAttributeInspector.Row < FAttributeInspector.RowCount
      Clipboard.AsText:= Cells[0, Row] +
        '=' + WMLEntityStr(Cells[1, Row]);
      Cells[1, Row]:= ''; // cutting
    end else begin
      if ActiveControl = ListboxInfo then begin
        // no cut. Just copy
        ws:= '';
        for i:= 0 to ListboxInfo.Items.Count - 1 do begin
          if ListboxInfo.Selected[i] then begin
            ws:= ws + ListboxInfo.Items[i] + #13#10;
          end;
        end;
        Clipboard.AsText:= ws;
      end else begin
        if ActiveControl is TECustomMemo then begin
          TECustomMemo(ActiveControl).CutToClipboard;
        end else begin
          if ActiveControl is TCustomEdit then begin
            TCustomEdit(ActiveControl).CutToClipboard;
          end;
        end;
      end;
    end;
  end;
end;

procedure TFormDockBase.actEditPasteExecute(Sender: TObject);
var
  CurMemo: TECustomMemo;
  n, v: String;
  pc: PChar;
  p: Integer;
begin
  //
  if ActiveControl = TreeViewElements then begin
    {
    if Assigned(FCurElement)
    then Clipboard.AsText:= FCurElement.CreateText(0);
    }
  end else begin
    if ActiveControl = FAttributeInspector then with FAttributeInspector do begin
      p:= Pos('=', Clipboard.AsText);
      if p > 0 then begin
        n:= Copy(Clipboard.AsText, 1, p - 1);
        v:= Copy(Clipboard.AsText, p + 1, MaxInt);
        pc:= PChar(v);
        if FAttributeInspector.FindRow(n, p) then begin
          Cells[1, p]:= HTMLExtractEntityStr(pc);
        end;
      end else begin
        // paste just value
        with FAttributeInspector do begin
          if Length(Keys[Selection.Top]) > 0 
          then Cells[1, Selection.Top]:= Clipboard.AsText;
        end;
      end;
    end else begin
      if ActiveControl = ListboxInfo then begin
        // no paste.
      end else begin
        if ActiveControl is TECustomMemo then begin
          TECustomMemo(ActiveControl).PasteFromClipboard;
        end else begin
          if ActiveControl is TCustomEdit then begin
            TCustomEdit(ActiveControl).PasteFromClipboard;
          end;
        end;
      end;
    end;
  end;
end;

// select all
procedure TFormDockBase.actEditSelectAllExecute(Sender: TObject);
var
  CurMemo: TECustomMemo;
begin
  //
  if ActiveControl = TreeViewElements then begin
  end else begin
    if ActiveControl = FAttributeInspector then with FAttributeInspector do begin
    end else begin
      if ActiveControl = ListboxInfo then begin
        if ListboxInfo.ItemIndex >= 0 then begin
          ListboxInfo.SelectAll;
        end;
      end else begin
        if ActiveControl is TECustomMemo then begin
          CurMemo:= GetCurMemo;
          if Assigned(CurMemo)
          then CurMemo.SelectAll;
        end;
      end;
    end;
  end;
end;

procedure TFormDockBase.actEditDeleteCurrentElementExecute(Sender: TObject);
var
  p, shift: TPoint;
  CurMemo: TECustomMemo;
begin
  // can't destroy TWMLContainer (checked by Assigned(CurElement.ParentElement))
  if Assigned(CurElement) and Assigned(CurElement.ParentElement) then begin
    // show changes in attribute list and text
    CurMemo:= GetCurMemo;
    if not Assigned(CurMemo)
    then Exit;

    p:= CurElement.DrawProperties.TagXYStart;
    Dec(p.Y);
    CurMemo.DeleteBetweenPos(p, CurElement.DrawProperties.TagXYTerminatorFinish);

    // refresh code positions in element treeview w/o recompilation
    // ShiftWMLElementTextPositions(CurElement, '');
    with CurElement.DrawProperties do begin
      // negative because delete
      Shift.X:= - (TagXYTerminatorFinish.X - TagXYStart.X);
      Shift.Y:= - (TagXYTerminatorFinish.Y - TagXYStart.Y + 1);
    end;
    ShiftNodeElementsTextPositions(TreeViewElements.Selected, Shift);
    CurElement.Free;
    TreeViewElements.Selected.Delete();

    { brute- force deletion
    AMemo.Lines.Text:= FWMLCollection.Items[0].CreateText(0, 2);
    AMemo.Refresh;
    actViewCompileCurrentFileExecute(Self);
    }
  end;
end;

procedure TFormDockBase.actFileSaveExecute(Sender: TObject);
var
  idx: Integer;
  mdf: Boolean;
begin
  idx:= TCOpenFiles.TabIndex;
  if idx < 0
  then Exit;
  // AFileName = ''        - save with previous name
  // AStorage  = srDefault - store in previous storage
  // if not checked this feature, do not
  if FParameters.Values[ParameterNames[ID_CompileBeforeSave]] = '1' then begin
    actViewCompileCurrentFileExecute(Self);
    Memos.Store(idx, '', srSame, edSame);
  end else begin
    // store and restore modification flag
    mdf:= Memos[idx].ModifiedSinceLastDelay;
    Memos.Store(idx, '', srSame, edSame);
    Memos[idx].ModifiedSinceLastDelay:= mdf;
  end;
end;

procedure TFormDockBase.actFileSaveAsBeforeExecute(Sender: TObject);
var
  CurMemo: TECustomMemo;
  CurMemoFileStatus: TFileStatus;
  dsc: TxmlClassDesc;
  doct: TEditableDoc;
begin
  CurMemo:= GetCurMemo;
  CurMemoFileStatus:= GetCurMemoFileStatus;
  if (not Assigned(CurMemo)) or (not Assigned(CurMemoFileStatus))
  then Exit;
  doct:= CurMemoFileStatus.DocType;
  if Sender is TFileSaveAs then with TFileSaveAs(Sender).Dialog do begin
    Title:= DEFAULT_SAVEASDIALOG_TITLE;
    Filter:= DEFAULT_OPENDIALOG_FILTER;
    if GetxmlClassDescByDoc(doct, dsc) then begin
      FilterIndex:= GetFilterIdxByDocType(doct);
      DefaultExt:= dsc.defaultextension
    end else DefaultExt:= DEFAULT_WML_FILEEXTENSION;

    Options:= Options - [ofAllowMultiSelect];
    InitialDir:= ExtractFilePath(CurMemoFileStatus.FileName);
    FileName:= CurMemoFileStatus.FileName;
  end;
end;

procedure TFormDockBase.actFileSaveAsAccept(Sender: TObject);
var
  idx: Integer;
  // storage: TStorageType;
begin
  idx:= TCOpenFiles.TabIndex;
  if idx < 0
  then Exit;
  if Sender is TFileSaveAs then begin
    with TFileSaveAs(Sender).Dialog do begin
      case FilterIndex of
      -1: Dialogs.MessageDlg(Format(MSG_NOFEATURE, [FileName]), mtInformation, [mbCancel], 0);
      else begin
        // AFileName = ''        - save with previous name
        // AStorage  = srDefault - store in previous storage
        actViewCompileCurrentFileExecute(Self);
        Memos.Store(idx, FileName, srSame, edSame);
        TCOpenFiles.Tabs[idx]:= Copy(FileName, LastDelimiter('\', FileName) + 1, MaxInt);
        end;
      end;
    end;
  end;
end;

// close current file
procedure TFormDockBase.actFileCloseExecute(Sender: TObject);
begin
  if CloseFile(TCOpenFiles.TabIndex, False) = mrYes
  then ;
end;

procedure TFormDockBase.actOptionsLoadDesktopConfigurationExecute(Sender: TObject);
var
  Stream: TStream;
  s, sz: String;
  i: Integer;
begin
  // window position & size
  S:= FParameters.Values[ParameterNames[ID_WindowSize]];
  Left:= StrToIntDef(util1.GetToken(1, ',', S), 0);
  Top:= StrToIntDef(util1.GetToken(2, ',', S), 0);
  Width:= StrToIntDef(util1.GetToken(3, ',', S), Screen.Width - 32);
  Height:= StrToIntDef(util1.GetToken(4, ',', S), Screen.Height - 32);

  // dockable controls bounds rectangles
  S:= HexString2Bin(FParameters.Values[ParameterNames[ID_DesktopGeometry]]);
  if Length(s) > 0 then begin
    for i:= Low(TDockableControlsArray) to High(TDockableControlsArray) do begin
      sz:= Copy(S, (i * SizeOf(TRect)) + 1, SizeOf(TRect));
      if Length(sz) = SizeOf(TRect) then begin
        if FDockableControlsArray[i].Parent is TCustomForm then begin
          FDockableControlsArray[i].Parent.BoundsRect:= TRect((@(sz[1]))^);
        end else begin
          // FDockableControlsArray[i].BoundsRect:= TRect((@(sz[1]))^);
        end;
      end;
    end;
  end;

  // docking information
  with PanelDockSite.DockManager do begin
    S:= HexString2Bin(FParameters.Values[ParameterNames[ID_DesktopDock]]);
    if Length(s) > 0 then begin
      Stream:= TStringStream.Create(S);
      PanelDockSite.DockManager.LoadFromStream(Stream);
      PanelDockSite.DockManager.ResetBounds(True);
      Stream.Free;
    end else begin
      // dock all
      for i:= Low(TDockableControlsArray) to High(TDockableControlsArray) do begin
        FDockableControlsArray[i].ManualDock(PanelDockSite);
      end;
    end;
  end;

end;

procedure TFormDockBase.actOptionsSaveDesktopConfigurationExecute(Sender: TObject);
var
  Stream: TStream;
  i: Integer;
  R: TRect;
  S: String;
begin
  // window position & size
  FParameters.Values[ParameterNames[ID_WindowSize]]:= Format('%d,%d,%d,%d', [Left, Top, Width, Height]);

  // dockable controls bounds rectangles
  SetLength(S, DOCKCONTROLCOUNT * SizeOf(TRect));
  for i:= Low(TDockableControlsArray) to High(TDockableControlsArray) do begin
    if FDockableControlsArray[i].Parent is TCustomForm then begin
      R:= FDockableControlsArray[i].Parent.BoundsRect;
    end else begin
      R:= FDockableControlsArray[i].BoundsRect;
    end;
    Move(R, S[(i * SizeOf(TRect)) + 1], SizeOf(TRect));
  end;
  FParameters.Values[ParameterNames[ID_DesktopGeometry]]:= BinString2Hex(S);

  // docking information
  if Assigned(PanelDockSite.DockManager) then with PanelDockSite.DockManager do begin
    Stream:= TStringStream.Create('');
    PanelDockSite.DockManager.SaveToStream(Stream);
    // BinString2Hex
    FParameters.Values[ParameterNames[ID_DesktopDock]]:= BinString2Hex(TStringStream(Stream).DataString);
    Stream.Free;
  end;
end;

function RegisterAxLib(const AFileName: String; ARegister: Boolean): Boolean;
const
  ProcName: array[Boolean] of PChar = ('DllUnregisterServer', 'DllRegisterServer');

  SFileNotFound = 'File "%s" not found';
  SLoadFail = 'Failed to load "%s"';
  SCantFindProc = '%s procedure not found in "%s"';
  SRegFail = 'Call to %s failed in "%s"';

type
  TRegProc = function: HResult; stdcall;
var
  LibHandle: THandle;
  OleAutLib: THandle;
  RegProc: TRegProc;
begin
  Result:= False;
  if not FileExists(AFileName)
  then raise Exception.CreateFmt(SFileNotFound, [AFileName]);
  LibHandle:= LoadLibrary(PChar(AFileName));
  if LibHandle = 0 then raise Exception.CreateFmt(SLoadFail, [AFileName]);
  try
    @RegProc := GetProcAddress(LibHandle, ProcName[ARegister]);
    if @RegProc = Nil
    then raise Exception.CreateFmt(SCantFindProc, [ProcName[ARegister], AFileName]);
    if RegProc <> 0
    then raise Exception.CreateFmt(SRegFail, [ProcName[ARegister], AFileName]);
  finally
    FreeLibrary(LibHandle);
  end;
  Result:= True;
end;

const
  DEF_AP_PROTOCOLNAME = 'ap';

function IsIEProtocolRegistered(const AProtocolName: String): Boolean;
begin
  Result:= False;
  with TRegistry.Create do begin
    try
      RootKey:= HKEY_CLASSES_ROOT;
      Result:= OpenKeyReadOnly('PROTOCOLS\Handler\' + AProtocolName);
    finally
      Free;
    end;
  end;
end;

procedure TFormDockBase.actOptionsFileAssociateExecute(Sender: TObject);
var
  InfotipDLLName,
  IEExtDLLName: String;
begin
  FormFileAssociations:= TFormFileAssociations.Create(Self);
  with FormFileAssociations do begin
    CBShowIETBtn.Checked:= FParameters.Values[ParameterNames[ID_TOGGLEISTBUTTON]] = '1';
    CBInfoTip.Checked:= FParameters.Values[ParameterNames[ID_INFOTIP]] = '1';

    if ShowModal = mrOk then with CheckListBoxFileTypes do begin
      DoAssociate;
      // ie browser toolbar button
      if CBShowIETBtn.Checked xor (FParameters.Values[ParameterNames[ID_TOGGLEISTBUTTON]] = '1') then begin
        IEExtDLLName:= util1.ConcatPath(FParameters.Values[ParameterNames[ID_ConfigDir]], wmleditutil.IEEXTDLLNAME);
        if RegisterAxLib(IEExtDLLName, CBShowIETBtn.Checked) then begin
        end;
        if CBShowIETBtn.Checked then begin
          IE5Tools.AddToolbarBtn(True, COM_OBJECT, // EXPLORER_BAR,
            CAP_APOOED,
            ConcatPath(FParameters.Values[ParameterNames[ID_ConfigDir]], RESDLLNAME) + CAP_APOOEDICON,
            ConcatPath(FParameters.Values[ParameterNames[ID_ConfigDir]], RESDLLNAME) + CAP_APOOEDICONGRAY,
            GUID_APOO_BTN);  // GUID_APOO_BAR
        end else begin
          IE5Tools.RemoveToolbarBtn(CAP_APOOED);
        end;
      end;
      if CBShowIETBtn.Checked then begin
        FParameters.Values[ParameterNames[ID_TOGGLEISTBUTTON]]:= '1';
      end else begin
        FParameters.Values[ParameterNames[ID_TOGGLEISTBUTTON]]:= '0';
      end;

      // info tip
      if CBInfoTip.Checked xor (FParameters.Values[ParameterNames[ID_INFOTIP]] = '1') then begin
        InfotipDLLName:= util1.ConcatPath(FParameters.Values[ParameterNames[ID_ConfigDir]], wmleditutil.INFOTIPDLLNAME);
        if RegisterAxLib(InfotipDLLName, CBInfoTip.Checked) then begin
        end;
      end;
      if CBInfoTip.Checked
      then FParameters.Values[ParameterNames[ID_INFOTIP]]:= '1'
      else FParameters.Values[ParameterNames[ID_INFOTIP]]:= '0';

    end;
  end;
  FormFileAssociations.Free;
end;

procedure TFormDockBase.actOptionsSettingsExecute(Sender: TObject);
var
  i, l: Integer;
  S: String;
begin
  //
  FormPreferences:= TFormPreferences.Create(Self);
  with FormPreferences do begin
    CBDefaultDitherMode.ItemIndex:= StrToIntDef(FParameters.Values[ParameterNames[ID_DefDitherMode]], 0);
    CBStretchPreview.Checked:= FParameters.Values[ParameterNames[ID_StretchPreview]] = '1';
    CBServerSide.Checked:= StrToIntDef(FParameters.Values[ParameterNames[ID_Extensions]], 0) and 1 > 0;
    CBDbDrvEnable.Checked:= StrToIntDef(FParameters.Values[ParameterNames[ID_DbDrvEnable]], 0) and 1 > 0;
    // that is much better in case of SPC.DLL . SPC.DLL can be registered outside of program
    // CBDbDrvEnable.Checked:= IsIEProtocolRegistered(DEF_AP_PROTOCOLNAME);
//  UDBlockIndent.Position:= StrToIntDef(FParameters.Values[ParameterNames[ID_BlockIndent]], 2);
    CBCharSet.ItemIndex:= CBCharSet.Items.IndexOf(wmlc.CharSetCode2Name(Encoding));
    CBWBXMLVersion.ItemIndex:= StrToIntDef(FParameters.Values[ParameterNames[ID_WBXMLVersion]], 0);
    CBLitgenGenAutoStart.Checked:= FParameters.Values[ParameterNames[ID_AutoStartGenLIT]]= '1';
    EUDLFolder.Text:= FParameters.Values[ParameterNames[ID_UDLFolder]];
    EDbDrvFileName.Text:= FParameters.Values[ParameterNames[ID_DbDrvFileName]];
    ETempFolder.Text:= FParameters.Values[ParameterNames[ID_WORKDIR]];
//  EFontSample.Font.Name:= Memos.FontName;
//  EFontSample.Font.Size:= Memos.FontSize;
//  CBUseBoldTags.Checked:= emUseBoldTags in Memos.Options;
    // set languages set
    with CLBLanguages, Items do begin
      // disable listview redraws
      Perform(WM_SETREDRAW, 0, 0);
      BeginUpdate;
      for i:= 0 to FLanguages.Count - 1 do begin
        l:= IndexOfObject(FLanguages.Objects[i]);
        if L >= 0 then begin
          Checked[l]:= True;
        end;
      end;
      EndUpdate;
      // enable listview redraws
      Perform(WM_SETREDRAW, 1, 0);
    end;

    if ShowModal = mrOk then begin
      FParameters.Values[ParameterNames[ID_DefDitherMode]]:=
        IntToStr(CBDefaultDitherMode.ItemIndex);
      if CBStretchPreview.Checked
      then FParameters.Values[ParameterNames[ID_StretchPreview]]:= '1'
      else FParameters.Values[ParameterNames[ID_StretchPreview]]:= '0';
      if CBServerSide.Checked
      then FParameters.Values[ParameterNames[ID_Extensions]]:= '1'
      else FParameters.Values[ParameterNames[ID_Extensions]]:= '0';
      if CBServerSide.Checked
      then Include(xmlENV.xmlCapabilities, wcServerExtensions)
      else Exclude(xmlENV.xmlCapabilities, wcServerExtensions);

//    FParameters.Values[ParameterNames[ID_BlockIndent]]:= IntToStr(UDBlockIndent.Position);
//    Memos.BlockIndent:= UDBlockIndent.Position;
      Encoding:= wmlc.CharSetName2Code(CBCharSet.Text);
      FParameters.Values[ParameterNames[ID_Encoding]]:= IntToStr(Encoding);
      FWBXMLVersion:= CBWBXMLVersion.ItemIndex;
      FParameters.Values[ParameterNames[ID_WBXMLVersion]]:= IntToStr(CBWBXMLVersion.ItemIndex);
      if CBLitgenGenAutoStart.Checked
      then FParameters.Values[ParameterNames[ID_AutoStartGenLIT]]:= '1'
      else FParameters.Values[ParameterNames[ID_AutoStartGenLIT]]:= '0';

      FParameters.Values[ParameterNames[ID_UDLFolder]]:= EUDLFolder.Text;
      FParameters.Values[ParameterNames[ID_WORKDIR]]:= ETempFolder.Text;
      FParameters.Values[ParameterNames[ID_DbDrvFileName]]:= EDbDrvFileName.Text;

      if CBDbDrvEnable.Checked  // instead of checking IsIEProtocolRegistered(DEF_AP_PROTOCOLNAME)
      then begin
        FParameters.Values[ParameterNames[ID_DbDrvEnable]]:= '1'
      end else begin
        FParameters.Values[ParameterNames[ID_DbDrvEnable]]:= '0';
      end;
      {
      if RegisterAxLib(FParameters.Values[ParameterNames[ID_DbDrvFileName]], CBDbDrvEnable.Checked) then begin
      end;
      }

      // update languages set
      with FLanguages do begin
        // Perform(WM_SETREDRAW, 0, 0);
        BeginUpdate;
        Clear;
        for i:= 0 to CLBLanguages.Count - 1 do begin
          if CLBLanguages.Checked[i] then begin
            AddObject(util_xml.winLangId2Abbr(LCID(CLBLanguages.Items.Objects[i])), CLBLanguages.Items.Objects[i])
          end;
        end;
        EndUpdate;
        // Perform(WM_SETREDRAW, 1, 0);
      end;

      //SetLength(S, FLanguages.Count * SizeOf(Integer));
      //Move(S[i * SizeOf(Integer) + 1]:= FLanguages.Objects[i];
      // languages
      FParameters.Values[ParameterNames[ID_Languages]]:= '';
      with FLanguages do begin
        for i:= 0 to Count - 1 do begin
          S:= IntToHex(Integer(FLanguages.Objects[i]), 8);
          FParameters.Values[ParameterNames[ID_Languages]]:= FParameters.Values[ParameterNames[ID_Languages]] + S;
        end;
      end;
      // set font, first name then size
//    Memos.FontName:= EFontSample.Font.Name;
//    Memos.FontSize:= EFontSample.Font.Size;
//    FParameters.Values[ParameterNames[ID_FontName]]:= Memos.FontName;
//    FParameters.Values[ParameterNames[ID_FontSize]]:= IntToStr(Memos.FontSize);
      // use bold tag
//    if CBUseBoldTags.Checked
//    then Memos.Options:= Memos.Options + [emUseBoldTags]
//    else Memos.Options:= Memos.Options - [emUseBoldTags];

//    if emUseBoldTags in Memos.Options
//    then FParameters.Values[ParameterNames[ID_UseBoldTags]]:= '1'
//    else FParameters.Values[ParameterNames[ID_UseBoldTags]]:= '0';

//    Memos.FontName:= FParameters.Values[ParameterNames[ID_FontName]];
//    Memos.FontSize:= StrToIntDef(FParameters.Values[ParameterNames[ID_FontSize]], 8);
    end;
  end;
  FormPreferences.Free;
end;

procedure TFormDockBase.actOptionsEditorExecute(Sender: TObject);
var
  i: Integer;
begin
  FormEditorOptions:= TFormEditorOptions.Create(Self);
  with FormEditorOptions do begin
    UDBlockIndent.Position:= StrToIntDef(FParameters.Values[ParameterNames[ID_BlockIndent]], 2);
    EFontSample.Font.Name:= Memos.FontName;
    EFontSample.Font.Size:= Memos.FontSize;
    CBUseBoldTags.Checked:= emUseBoldTags in Memos.Options;
    CBAutoComplete.Checked:= Memos.AutoComplete;
    UDAutoComplete.Position:= Memos.AutoCompleteInterval;
    CBCompileModifiedAtDelay.Checked:= FParameters.Values[ParameterNames[ID_CompileModifiedAtDelay]]= '1';
    CBCompileBeforeSave.Checked:= FParameters.Values[ParameterNames[ID_CompileBeforeSave]]= '1';

    CBHighlightTag.Checked:= FParameters.Values[ParameterNames[ID_HighlightTag]]= '1';
    CBHighlightSTag.Checked:= FParameters.Values[ParameterNames[ID_HighlightSTag]]= '1';
    CBHighlightEntity.Checked:= FParameters.Values[ParameterNames[ID_HighlightEntity]]= '1';

    CBNumerateLines.Checked:= FParameters.Values[ParameterNames[ID_NumerateLines]]= '1';

    UDRightMargin.Position:= Memos.DefRightMargin;
    CBVisibleRightMargin.Checked:= Memos.UseRightMargin;
    UDGutterWidth.Position:= Memos.DefGutterWidth;
    CBVisibleGutter.Checked:= Memos.UseGutter;

    { auto conversion tabsheet settings }
    CBEntities2Char.Checked:= convEnEntity2Char in Memos.ConvOnLoadOptions;
    CBChar2Entities.Checked:= convEnChar2Entity in Memos.ConvOnSaveOptions;

    CBLoadRefCharset.Checked:= convEnRefCharset in Memos.ConvOnLoadOptions;
    CBSaveRefCharset.Checked:= convEnRefCharset in Memos.ConvOnSaveOptions;

    MemoSample.EnvironmentOptions.SetByString(Memos.EnvironmentOptions);
    if ShowModal = mrOk then begin
      { block indent }
      FParameters.Values[ParameterNames[ID_BlockIndent]]:= IntToStr(UDBlockIndent.Position);
      Memos.BlockIndent:= UDBlockIndent.Position;
      customxml.BlockIndent:= UDBlockIndent.Position;
      { font }
      Memos.FontName:= EFontSample.Font.Name;
      Memos.FontSize:= EFontSample.Font.Size;
      FParameters.Values[ParameterNames[ID_FontName]]:= Memos.FontName;
      FParameters.Values[ParameterNames[ID_FontSize]]:= IntToStr(Memos.FontSize);

      Memos.AutoComplete:= CBAutoComplete.Checked;
      Memos.AutoCompleteInterval:= UDAutoComplete.Position;
      if CBCompileModifiedAtDelay.Checked
      then FParameters.Values[ParameterNames[ID_CompileModifiedAtDelay]]:= '1'
      else FParameters.Values[ParameterNames[ID_CompileModifiedAtDelay]]:= '0';

      if CBCompileBeforeSave.Checked
      then FParameters.Values[ParameterNames[ID_CompileBeforeSave]]:= '1'
      else FParameters.Values[ParameterNames[ID_CompileBeforeSave]]:= '0';

      if CBHighlightTag.Checked
      then FParameters.Values[ParameterNames[ID_HighlightTag]]:= '1'
      else FParameters.Values[ParameterNames[ID_HighlightTag]]:= '0';

      if CBHighlightSTag.Checked
      then FParameters.Values[ParameterNames[ID_HighlightSTag]]:= '1'
      else FParameters.Values[ParameterNames[ID_HighlightSTag]]:= '0';

      if CBHighlightEntity.Checked
      then FParameters.Values[ParameterNames[ID_HighlightEntity]]:= '1'
      else FParameters.Values[ParameterNames[ID_HighlightEntity]]:= '0';

      if Memos.AutoComplete
      then FParameters.Values[ParameterNames[ID_AutoComplete]]:= '1'
      else FParameters.Values[ParameterNames[ID_AutoComplete]]:= '0';

      for i:= Low(HLA) to High(HLA) do begin
        with HLA[i] do begin
          SetBackgroundColors(clWindow);
          UseTagHighlight:= CBHighlightTag.Checked;
          UseSpecTagsHighlight:= CBHighlightSTag.Checked;
          UseEntityHighlight:= CBHighlightEntity.Checked;
        end;
      end;

      { auto conversion tabsheet settings }

      if CBEntities2Char.Checked
      then Memos.ConvOnLoadOptions:= [convEnEntity2Char]
      else Memos.ConvOnLoadOptions:= [];
      if CBChar2Entities.Checked
      then Memos.ConvOnSaveOptions:= [convEnChar2Entity]
      else Memos.ConvOnSaveOptions:= [];

      if CBLoadRefCharset.Checked
      then Memos.ConvOnLoadOptions:= Memos.ConvOnLoadOptions + [convEnRefCharset];
      if CBSaveRefCharset.Checked
      then Memos.ConvOnSaveOptions:= Memos.ConvOnSaveOptions + [convEnRefCharset];

      { save changes in options }
      FParameters.Values[ParameterNames[ID_Entities2Char]]:= IntToStr(Byte(Memos.ConvOnLoadOptions));
      FParameters.Values[ParameterNames[ID_Char2Entities]]:= IntToStr(Byte(Memos.ConvOnSaveOptions));

      { numerate lines }
      Memos.ShowLineNum:= CBNumerateLines.Checked;
      if CBNumerateLines.Checked
      then FParameters.Values[ParameterNames[ID_NumerateLines]]:= '1'
      else FParameters.Values[ParameterNames[ID_NumerateLines]]:= '0';

      { gutter and margin }
      Memos.DefRightMargin:= UDRightMargin.Position;
      Memos.DefGutterWidth:= UDGutterWidth.Position;
      Memos.UseRightMargin:= CBVisibleRightMargin.Checked;
      Memos.UseGutter:= CBVisibleGutter.Checked;
      FParameters.Values[ParameterNames[ID_RightMarginWidth]]:= IntToStr(UDRightMargin.Position);
      FParameters.Values[ParameterNames[ID_GutterWidth]]:= IntToStr(UDGutterWidth.Position);
      if CBVisibleRightMargin.Checked
      then FParameters.Values[ParameterNames[ID_UseRightMargin]]:= '1'
      else FParameters.Values[ParameterNames[ID_UseRightMargin]]:= '0';
      if CBVisibleGutter.Checked
      then FParameters.Values[ParameterNames[ID_UseGutter]]:= '1'
      else FParameters.Values[ParameterNames[ID_UseGutter]]:= '0';

      // use bold tag
      if CBUseBoldTags.Checked
      then Memos.Options:= Memos.Options + [emUseBoldTags]
      else Memos.Options:= Memos.Options - [emUseBoldTags];

      if emUseBoldTags in Memos.Options
      then FParameters.Values[ParameterNames[ID_UseBoldTags]]:= '1'
      else FParameters.Values[ParameterNames[ID_UseBoldTags]]:= '0';

      Memos.EnvironmentOptions:= MemoSample.EnvironmentOptions.GetAsString;
      FParameters.Values[ParameterNames[ID_EditorColors]]:= Memos.EnvironmentOptions;
    end;
  end;
end;

procedure TFormDockBase.actRestoreDefaultWindowExecute(Sender: TObject);
var
  i: Integer;
  p: TPoint;
begin
  {
  FParameters.Values[ParameterNames[ID_DesktopDock]]:=
  '000000000C000000FC00000026010000000200000C000000B40200005C010000000100000C000000FC0100009100000000010000A1000000FC010000260100000000000036010000FC0100005C010000';
  actOptionsLoadDesktopConfigurationExecute(Self);
  }
  if not (asAllowDocking in FAppSettingsSet)
  then actViewWindowAllowDockExecute(Self);
  // undock all
  with PanelDockSite.DockManager do begin
    for i:= Low(TDockableControlsArray) to High(TDockableControlsArray) do begin
      FDockableControlsArray[i].ManualFloat(browserutil.RectInc(P, FDockableControlsArray[i].BoundsRect));
    end;
  end;
  // FAttributeInspector
  FDockableControlsArray[3].ManualDock(PanelDockSite, PanelDockSite, alTop);
  // TreeViewElements
  FDockableControlsArray[2].ManualDock(PanelDockSite, PanelDockSite, alTop);
  // PanelProject
  FDockableControlsArray[0].ManualDock(PanelDockSite, PanelDockSite, alLeft);
  // ListBoxInfo
  FDockableControlsArray[4].ManualDock(PanelDockSite, PanelDockSite, alBottom);
  // PanelEditor
  FDockableControlsArray[1].ManualDock(PanelDockSite, PanelDockSite, alClient);
  // disable docking outside this procedure
  //  actViewWindowAllowDockExecute(Self);
end;

function CenterX(AX: Integer; AControl: TControl): Integer;
begin
  // Screen.WorkAreaWidth - AControl.Width;
  // Screen.WorkAreaHeight - AControl.Height;
  Result:= (AX - AControl.Width) div 2;
  AControl.Left:= Result;
end;

procedure TFormDockBase.FormResize(Sender: TObject);
begin
  CenterX(PanelAds.Width, FBanner);
end;

procedure TFormDockBase.actStoreCodeExecute(Sender: TObject);
begin
  // store entered code and validate
  FParameters.Values[ParameterNames[ID_USER]]:= FormRegister.EUserName.Text;
  FParameters.Values[ParameterNames[ID_CODE]]:= FormRegister.RegCode;
  // store ini
  StoreIni(1);
  // validate
  actValidateCodeExecute(Self);
  if FRegistered then begin
    Application.MessageBox(SMSG_THANKS, PROGNAMEU + '. Thank you!');
  end else begin
    Application.MessageBox(SMSG_INVALIDKEY, PROGNAMEU + '. Misprint.');
  end;
end;

procedure TFormDockBase.actValidateCodeExecute(Sender: TObject);
var
  S, ver: String;
  code: String;
  showbanner: Boolean;
begin
  // calculate hash
  S:= 'enzi' + REGISTER_PRODUCTCODE + FParameters.Values[ParameterNames[ID_USER]];
  ver:= Versions.GetVersionInfo(LNG, 'FileVersion');
  code:= FParameters.Values[ParameterNames[ID_CODE]];
  // remove spaces and '-' if exists
  util1.DeleteLeadTerminateDoubledSpaceStr(code);
  while util1.ReplaceStr(code, False, '-', '') do;
{$IFDEF FREEWARE}
  FRegistered:= True;
{$ELSE}
  FRegistered:= code = secure.GetMD5Digest(PChar(S), Length(S), 36);
{$ENDIF}
  if FRegistered then begin
    Caption:= APPNAME + ' version '+ ver;
  end else begin
    Caption:= APPNAME + ', evaluation version '+ ver;
  end;

  showbanner:= False;
  if showbanner then begin
    // show ads
    PanelAds.Height:= 60;
    Timer1.Interval:= 250;
    CenterX(PanelAds.Width, FBanner);
    Timer1.Enabled:= True;
  end else begin
    // do not show ads
    PanelAds.Height:= 0;
    Timer1.Enabled:= False;
  end;
end;

function AdsText(AWidth, AHeight: Integer; AText: String; APicture: TPicture): Boolean;
var
  R: TRect;
  Sz: TSize;
  bmp: TBitmap;
begin
  Result:= True;
  bmp:= TBitmap.Create;
  R.Left:= 0;
  R.Top:= 0;
  R.Right:= AWidth - 1;
  R.Bottom:= AHeight - 1;

  bmp.Width:= AWidth;
  bmp.Height:= AHeight;

  with bmp.Canvas do begin
    Brush.Color:= clWhite;
    Brush.Style:= bsSolid;
    Pen.Color:= clBlack;
    Rectangle(R);
    Font.Name:= 'Times New Roman';
    Font.Color:= clSilver;
    Font.Size:= 20;
    Font.Style:= [];
    Sz:= TextExtent(AText);
    TextOut((AWidth - Sz.cx) div 2, (AHeight - Sz.cy) div 2, AText);
  end;
  APicture.Bitmap.Assign(bmp);
  bmp.Free;
end;

procedure TFormDockBase.CreateBanner(AControl: TControl);
begin
  FBanner:= THttpGifLoader.Create(Self);

  with FBanner do begin
    Parent:= TWinControl(AControl);
    Top:= 0;
    Width:= 468;
    Height:= 1000;
    CenterX(AControl.Width, FBanner);
    url:= MyBannerImg;
    Stretch:= True;
    Hint:= MyBannerHint;
    Cursor:= crHandPoint;
    OnClick:= OnClickFBanner;
    ReadProxySettings;
    NextTimeOutSec:= 120;
    TimeOutSec:= NextTimeOutSec div 2;
    // banner
    AdsText(468, 60, 'Thank you for using ' + PROGNAMEU + ' editor', Picture);
    ClickURL:= MyBannerHref;
    // banner

    Timer1Timer(Self);
  end;
end;

procedure TFormDockBase.Timer1Timer(Sender: TObject);
begin
  if asShowBanner in FAppSettingsSet then begin
    // show banners from the internet (otherwise from resource)
    FBanner.Started:= (not FRegistered) and util1.IsIPPresent;
  end else begin
    // show banners from the resources
    FBanner.NextPreloadedImage;
    // AdsText(468, 60, 'Thank you for using ' + PROGNAMEU + ' wml editor', FBanner.Picture);
  end;
  // if not FRegistered then actHelpNagScreenExecute(Self);
end;

procedure TFormDockBase.OnClickFBanner(Sender: TObject);
begin
  util1.EExecuteFile(FBanner.ClickURL);  //
end;

procedure TFormDockBase.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  idx: Integer;
begin
  CanClose:= True;
  // set focus to "static" created control. If FAttributeInspector has focus,
  // it cause AVE
  try
    if CBFilter.CanFocus
    then ActiveControl:= CBFilter;
  except
    // if documents does not saved
  end;

  // close opened files
  for idx:= 0 to Memos.Size - 1 do begin
    if CloseFile(0, True) = mrYes
    then ;
  end;

  // store changes in initializtions
  StoreIni(0);

  // do not destroy dinamically created components
  // FolderTree1 and FAttributeInspector
end;

procedure TFormDockBase.actHelpAboutExecute(Sender: TObject);
begin
  AboutBox:= TAboutBox.Create(Self);
  AboutBox.ShowModal;
  AboutBox.Free;
end;

procedure TFormDockBase.actHelpEnterCodeExecute(Sender: TObject);
begin
  FormRegister:= TFormRegister.Create(Self);
  with FormRegister do begin
    EUserName.Text:= FParameters.Values[ParameterNames[ID_USER]];
    RegCode:= FParameters.Values[ParameterNames[ID_CODE]];
    ShowModal;
    Free;
  end;
end;

procedure TFormDockBase.actHelpHowToRegisterExecute(Sender: TObject);
var
  p: TPoint;
begin
  // how to register
  p.X:= 0;
  p.Y:= 0;
  ShowHelpByIndex(p, Nil, 'register');
end;

procedure TFormDockBase.actHelpGetCodeExecute(Sender: TObject);
begin
  //
  util1.EExecuteFile(REGISTER_URL);
end;

procedure TFormDockBase.actHelpTagInfoExecute(Sender: TObject);
begin
  if Assigned(fElDesc.FormElementDescription) then begin
    fElDesc.FormElementDescription.Visible:= True;
    fElDesc.FormElementDescription.BringToFront;
  end else begin
    fElDesc.FormElementDescription:= TFormElementDescription.Create(Self);
    fElDesc.FormElementDescription.Visible:= True;
  end;

  if Assigned(CurElement) then begin
    fElDesc.FormElementDescription.ShowElement(TxmlElementClass(CurElement.ClassType));
  end else begin
    fElDesc.FormElementDescription.ShowAbout;
  end;
end;

procedure TFormDockBase.ButtonEditClick(Sender: TObject);
var
  b: TButton;
  p: TPersistentClass;
  e: TxmlElement;
begin
  if not (Sender is TButton)
  then Exit;

  b:= TButton(Sender);
  e:= FCurElement.GetNested1ElementByName(b.Caption, p);
  if not Assigned(e)
  then Exit;
end;

procedure TFormDockBase.TreeViewElementsChange(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned(Node) then begin
    FCurElement:= TxmlElement(Node.Data);  // TreeViewElements.Selected.
    if Assigned(FAttributeInspector) then
      FAttributeInspector.xmlElement:= FCurElement;
    ViewSource(FCurElement);
  end;
end;

procedure TFormDockBase.TreeViewElementsClick(Sender: TObject);
begin
  // we must to do this twice because user can click on current element after manual changes 
  if Assigned(FCurElement) then begin
    FAttributeInspector.xmlElement:= FCurElement;
    ViewSource(FCurElement);
  end;
end;

procedure TFormDockBase.pmFolderTreePopup(Sender: TObject);
var
  i: Integer;
  node: TTreeNode;
  NewItem: TMenuItem;
  hm: HMENU;
begin
  // clear customized items
  with pmFolderTree do begin
    i:= 0;
    while i < Items.Count do begin
      if Items[i].Tag <> 0
      then Items.Delete(i)
      else Inc(i);
    end;
  end;

  // get tree node
  node:= FolderTree1.Selected;
  if not Assigned(node)
  then Exit;

  if DirectoryExists(FolderTree1.Directory)
  then Exit;
  // if FileExists(FolderTree1.Directory) then with pmFolderTree do begin
  case GetDocTypeByFilter(CBFilter.ItemIndex + 1) of
    edOEB: begin
      // Open eBook publications (*.oeb;*.htm;*.html)
    end;
    edPKG: begin
      // Compile Open eBook packaging file(*.opf)
      NewItem:= TMenuItem.Create(Self);
      with NewItem do begin
        Caption:= Format('&Compile open eBook package: %s', [ExtractFileName(FolderTree1.Directory)]);
        Tag:= 1;
        { add the new item to the Windows menu }
        OnClick:= actFolderTreeGenerateLITExecute;
      end;
      pmFolderTree.Items.Add(NewItem);
    end;
  end;
  // popup menu cancels selection, so select file again
  FolderTree1.Directory:= FolderTree1.Directory;
end;

procedure TFormDockBase.actFolderTreeGenerateLITExecute(Sender: TObject);
var
  fn: String;
begin
  //
  fn:= FolderTree1.Directory;
  GenerateLIT(fn, GetDocTypeByFilter(CBFilter.ItemIndex + 1), GetStorageTypeByFileName(fn));
end;

procedure TFormDockBase.FolderTree1DblClick(Sender: TObject);
var
  FNs: TStrings;
  node: TTreeNode;
begin
  // do not open entire folder files
  // ldap - how to know is it expandable node
  node:= FolderTree1.Selected;
  if not Assigned(node)
  then Exit;
  if (TFolderNode(Node.Data^).FN_NodeType = ntFolder) and (TFolderNode(Node.Data^).FN_Type <> ftLdapNode)
  then Exit;
  // if DirectoryExists(FolderTree1.Directory) then Exit;
  // if FileExists(FolderTree1.Directory) then begin
  FNs:= TStringList.Create;
  FNs.AddObject(FolderTree1.Directory, Nil);
  OpenFiles(FNs, GetDocTypeByFilter(CBFilter.ItemIndex + 1));
  FNs.Free;
  // end;
end;

function TFormDockBase.GetCurrentParentNode: TTreeNode;
begin
  Result:= FolderTree1.Selected;
  if not Assigned(Result)  then Exit;
  // if node is not a folder, find out parent node
  if (TFolderNode(Result.Data^).FN_NodeType <> ntFolder) then Result:= Result.Parent;
  if (not Assigned(Result)) or (TFolderNode(Result.Data^).FN_NodeType <> ntFolder)  then Exit;
end;

{ fill out document list view
}
function RebuildDocumentListView(ANode: TTreeNode; ADocType: TEditableDoc;
  AOnGetStorageFile: TOnGetExternalStorageFile;
  AResult: TListView): Integer;
label
  fin;
var
  node: TTreeNode;
  i, cnt: Integer;
  li: TListItem;
  desc: String;
  dsc: TxmlClassDesc;
  src: WideString;
  memo: TECustomMemo;
  storage: TStorageType;
begin
  AResult.OwnerData:= True;

  Result:= -1;
  if not Assigned(Anode)
  then Exit;
  // set default description
  desc:= GetDocTypeDesc(ADocType);
  i:= 0;
  if AResult.OwnerData then begin
    // virtual list view, just set count of items
    cnt:= Anode.Count;
    SetLength(FormDockBase.FDocListViewCache, cnt);

    if GetxmlClassDescByDoc(ADocType, dsc) and
      (ADocType in [edWML, edWMLCompiled, edWMLTemplate, edOEB, edPKG, edXHTML, edTaxon, edSMIT]) then begin
      // fill up known types
      node:= ANode.getFirstChild;
      while Assigned(node) do begin
        storage:= GetStorageTypeByFileName(TFolderNode(Node.Data^).FN_Path);
        if TFolderNode(Node.Data^).FN_NodeType <> ntFolder then with FormDockBase.FDocListViewCache[i] do begin
          if Assigned(dsc.OnDocumentTitle) then begin
            memo:= Load2NewMemo(storage, TFolderNode(Node.Data^).FN_Path, AOnGetStorageFile);
            src:= memo.Lines.Text;
            desc:= util_xml.WMLExtractEntityStr(dsc.OnDocumentTitle(src));
            memo.Free;

            if Length(desc) = 0 then begin
              s:= node.Text + #10 + node.Text;
            end else begin
              s:= desc + #10 + node.text;
            end;
            d:= node;
            Inc(i);
          end;
        end;
        node:= node.GetNext;
      end;
    end else begin
      // fill up all other types
      node:= ANode.getFirstChild;
      while Assigned(node) do begin
        if i >= cnt then Break;
        if (TFolderNode(Node.Data^).FN_NodeType <> ntFolder) then with FormDockBase.FDocListViewCache[i] do begin
          s:= node.Text + #10 + desc;
          d:= node;
          Inc(i);
        end;
        node:= node.GetNext;
      end;
    end;
    AResult.Items.Count:= i;
    Exit;
  end;

  // not a virtual list view, fill out all items
  with AResult,Items do begin
    Perform(WM_SETREDRAW, 0, 0);
    SortType:= stNone;
    BeginUpdate;
    Clear;
  end;
  if not Assigned(ANode)
  then goto fin;

  if GetxmlClassDescByDoc(ADocType, dsc) then begin
    case ADocType of
      edWML,            // WML files (*.wml)
      edWMLCompiled,    // WML compiled files (*.wmlc)
      edWMLTemplate,    // WML templates (*.wmlt)
      edOEB,            // Open eBook publications (*.oeb;*.htm;*.html)
      edPKG,            // Open eBook packaging file(*.opf)
      edXHTML: begin    // Extensible HTML files (*.xhtml;*.html;*.htm;*.xml)
        node:= ANode.getFirstChild;
        while Assigned(node) do begin
          storage:= GetStorageTypeByFileName(TFolderNode(Node.Data^).FN_Path);
          if TFolderNode(Node.Data^).FN_NodeType <> ntFolder then begin
            li:= AResult.Items.Add;
            with li do begin
              if Assigned(dsc.OnDocumentTitle) then begin
                memo:= Load2NewMemo(storage, TFolderNode(Node.Data^).FN_Path, AOnGetStorageFile);
                src:= memo.Lines.Text;
                desc:= util_xml.WMLExtractEntityStr(dsc.OnDocumentTitle(src));
                memo.Free;
                if Length(desc) = 0
                then Caption:= node.Text
                else Caption:= desc;
                SubItems.Add(node.Text);
              end else begin
                Caption:= node.Text;
                SubItems.Add(desc);
              end;
              Data:= node;
            end;
          end;
          node:= node.GetNext;
        end;
      end;
      else begin
        cnt:= 0;
        node:= ANode.getFirstChild;
        while Assigned(node) do begin
          Inc(cnt);
          if TFolderNode(Node.Data^).FN_NodeType <> ntFolder then begin
            li:= AResult.Items.Add;
            with li do begin
              Caption:= node.Text;
              SubItems.Add(desc);
              Data:= node;
            end;
          end;
          node:= node.GetNext;
        end;
      end;
    end;
  end;
fin:
  with AResult,Items do begin
    SortType:= stText;
    EndUpdate;
    Perform(WM_SETREDRAW, 1, 0);
  end;
end;

{ OnData gets called once for each item for which the ListView needs data. If the ListView is in Report View, be sure to add the subitems.
  Item is a "dummy" item whose only valid data is it's index which is used to index into the underlying data.
}
procedure TFormDockBase.LVDocumentsData(Sender: TObject; Item: TListItem);
var
  n: TTreeNode;
  idx: Integer;
  ptr: Pointer;
  str, name, desc: ShortString;
begin
  {
  n:= GetCurrentParentNode;
  if not Assigned(n) then Exit;
  n:= n.getFirstChild;
  for idx:= 0 to Item.Index + 1 do begin
    if n = Nil then Exit;
    n:= n.GetNext;
  end;
  if (TFolderNode(n.Data^).FN_NodeType = ntFolder)
  then Exit;
  }
  if Item.Index > Length(FDocListViewCache) then Exit;
  with FDocListViewCache[Item.Index] do begin
    str:= s;
    ptr:= d;
    idx:= Pos(#10, str);
    if idx > 0 then begin
      name:= Copy(str, 1, idx - 1);
      desc:= Copy(str, idx + 1, MaxInt);
    end else begin
      desc:= str;
      name:= str;
    end;
  end;

  with Item do begin
    Caption:= name;
    Data:= ptr;
    // if LVDocuments.ViewStyle <> vsReport then Exit;
    // desc:= GetDocTypeDesc(GetDocTypeByFilter(CBFilter.ItemIndex + 1));
    // desc:= 'unknown';
    SubItems.Add(desc);
  end;
end;

procedure TFormDockBase.RebuildFilter;
var
  R: TStrings;
  F: String;
  i: Integer;
begin
  R:= TStringList.Create;
  util_xml.GetStringsFromFileFilter(CBFilter.Text, 2, R);
  F:= '';
  for i:= 0 to R.Count - 1 do begin
    F:= F + '*' + R[i] + ';';
  end;
  i:= Length(F);
  if (i > 0) and (F[i] = ';')
  then Delete(F, i, 1);
  // update folder tree
  if FolderTree1.FileMask <> F
  then RefreshFolderViews(F);
  R.Free;
end;

procedure TFormDockBase.RefreshFolderViews(const AFilter: String);
begin
  FolderTree1.FileMask:= AFilter;
  // update document list view if visible
  if PCProject.TabIndex = 1 then begin
    RebuildDocumentListView(GetCurrentParentNode, GetDocTypeByFilter(CBFilter.ItemIndex + 1),
      dm.Dm1.OnGetStorageFile, LVDocuments);
  end;
end;

// creates new nested element
procedure TFormDockBase.ToolButtonNewClick(Sender: TObject);
var
  FormScrollPt: TPoint;
  b: TToolButton;
  p: TPersistentClass;
  c: TxmlElementCollection;
  e: TxmlElement;
  fs: TFileStatus;
  n: TTreeNode;
  CurMemo: TECustomMemo;
  pprev, pnext: TPoint;
  Shift: TPoint;
  s: String;
begin
  if not (Sender is TToolButton)
  then Exit;
  b:= TToolButton(Sender);
  p:= GetClassByBitmapIndex(b.ImageIndex);  // use generalise function
  if (not Assigned(p))
  then Exit;

  // show changes in attribute list and text
  CurMemo:= GetCurMemo;
  if not Assigned(CurMemo)
  then Exit;
  if CurMemo.Focused and CurMemo.ModifiedSinceLastDelay 
  then Exit; // because text was changed we must recalculate positions but (see later)
      // if memo is changed since last compilation, compile it
      // DO NOT! if CurMemo.ModifiedSinceLastDelay  then actViewCompileCurrentFileExecute(Sender);

  // Tag contains parent element. go to the element if it is not done allready
  OnElementChange(TxmlElement(b.Tag)); // this is for external buttons
                                       // do not change element in this event (it destroys button itself)
                                       // and do not compile text (it destroys buttons)
  c:= CurElement.NestedElements.GetByClass(p);
  if not Assigned(c)
  then Exit;


  fs:= GetCurMemoFileStatus;

  if CurElement.CanInsertElement(p) then begin
    e:= c.Add;
    n:= TreeViewElements.Items.AddChildObject(TreeViewElements.Selected, e.name, e);
    n.ImageIndex:= GetBitmapIndexByClass(p);
    n.SelectedIndex:= n.ImageIndex;
    // n.Selected:= True;
    n.Parent.Expand(False);

    // reflect changes in attribute list and text
    if Assigned(CurElement) then begin  //  and Assigned(CurElement.ParentElement)
      s:= #13#10+e.CreateText(-1, []);  // CRLF - 2003 Mar 09

      e.GetPrevNextTagXY(pprev, pnext);
      CurMemo.InsertTextAtPos(s, pprev.y, pprev.x);

      with e.DrawProperties do begin
        TagXYStart:= pprev;
        Inc(TagXYStart.Y);
        TagXYFinish:= TagXYStart;  // Jul 09 2008
      end;

      {
      // refresh code positions in element treeview w/o recompilation
      Dec(pprev.y);
      with e.DrawProperties do begin
        TagXYStart:= pprev;
        TagXYFinish:= pprev;
        TagXYTerminatorStart:= pprev;
        TagXYTerminatorFinish:= pprev;
      end;
      }
      xmlParse.xmlCompileText(s, Nil, Nil, Nil, e, getContainerClassByDoctype(fs.DocType));

      Shift.X:= 0; Shift.Y:= 0;
      CalcTextColsRows(S, Shift);
      {
      with e.DrawProperties do begin
        Shift.X:= e.DrawProperties.TagXYTerminatorFinish.X - TagXYStart.X;
        Shift.Y:= e.DrawProperties.TagXYTerminatorFinish.Y - TagXYStart.Y + 1;
      end;
      }
      ShiftNodeElementsTextPositions(n, Shift);

      { brute- force insert
      AMemo.Lines.Text:= FWMLCollection.Items[0].CreateText(0, 2);
      AMemo.Refresh;
      actViewCompileCurrentFileExecute(Self);
      }
      if (fs.DocType in [edWML, edWMLTemplate, edWMLCompiled]) and Assigned(FormByteCode) and FormByteCode.Visible then begin
        // view byte code
        FormByteCode.SyncViewXML(FWMLCollection);
      end;
      // go to the new element
      // do not call OnElementChange(e) after because button 'll be destroyed but processing buttonUp methods cause AVE

      if PageControlEditors.TabIndex = 2 then begin
        FormScrollPt.Y:= ScrollBoxForm.VertScrollBar.Position;
        FormScrollPt.X:= ScrollBoxForm.HorzScrollBar.Position;
        xmlParse.AddxmlElement2Panel(getContainerByDoctype(fs.DocType), PanelForm,
          dm.dm1.ImageList16, OnElementChange, OnSelectElementClick, ToolButtonNewClick);
        ScrollBoxForm.VertScrollBar.Position:= FormScrollPt.Y;
        ScrollBoxForm.HorzScrollBar.Position:= FormScrollPt.X;
      end;
    end;
  end;
end;

// display element in treeview
procedure TFormDockBase.ViewElement(AxmlElement: TxmlElement);
var
  i: Integer;
begin
  with TreeViewElements do begin
    for i:= 0 to Items.Count - 1 do begin
      if Items[i].Data = AxmlElement then begin
        // element found, display
        Items[i].Selected:= True;
        Items[i].Focused:= True;
        Items[i].Expand(False);
        Exit;
      end;
    end;
  end;
end;

// reflect attributes changes
procedure TFormDockBase.ReflectAttributeChange(const AAttributeName: String; AAttributeValue: WideString; AElement: TxmlElement; AMemo: TECustomMemo);
var
  st, len: Integer;
  s_element, s_element_old: WideString;
  eq:  String[2];
  p: TPoint;
  shift: TPoint;
  ValueOnly, EDNeeds: Boolean;
  fs: TFileStatus;
begin
  // AElement.Attributes.Assign(AAttributes);
  if (not Assigned(AMemo)) or (not Assigned(AElement)) or (Length(AAttributeName) = 0)
  then Exit;
  fs:= GetCurMemoFileStatus;
  
  st:= AElement.Attributes.IndexOf(AAttributeName);
  if st < 0
  then Exit;
  AElement.Attributes.ValueByName[AAttributeName]:= HTMLExtractEntityStr(AAttributeValue);
  // AMemo.ModifiedSinceLastDelay:= False;  // debug
  s_element_old:= AMemo.GetTextAtPos(AElement.DrawProperties.TagXYStart, AElement.DrawProperties.TagXYFinish, #13#10);

  if AElement is TxmlPCData then begin
    s_element:= WMLEntityStr(AAttributeValue);
  end else begin
    if AElement is TxmlComment then begin
      s_element:= '<!-- ' +  WMLEntityStr(AAttributeValue) + ' -->';
    end else begin
      if AElement is TXMLDesc then begin
        // s_element:= Format('<?xml version="%s" ?>', [AAttributeValue]);  // AAttributes.Values['version']
        s_element:= AElement.CreateText(0, []);
        AMemo.Encoding:= wmlc.CharSetName2Code(TXMLDesc(AElement).Attributes.ValueByName['encoding']);
      end else begin
        if AElement is TDocDesc then begin
          s_element:= AElement.CreateText(0, []);
          // Format('<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML %s//EN" "http://www.wapforum.org/DTD/wml%s.dtd">', [AAttributeValue, AAttributeValue]);  // AAttributes.Values['version']
        end else begin
          if AElement is TxmlSSScript then begin
            s_element:= '<% ' +  AAttributeValue + ' %>';
          end else begin
            // other tags- do not recreate, add new attribute or replace old value to new attribute value
            s_element:= s_element_old;
            ValueOnly:= Length(AAttributeValue) > 0;
            if SearchAttributePosition(s_element_old, AAttributeName,
              ValueOnly, st, len, EDNeeds) then begin
              // attribute values exists, just replace value
              Delete(s_element, st, len);
              if ValueOnly then begin
                // add new value, else attribute is deleted
                if EDNeeds
                then eq:= '="'
                else eq:= '"';
                Insert(eq + WMLEntityStr(AAttributeValue) + '"', s_element, st);
              end;
            end else begin
              // no attribute was specified, add attribute if valuable
              if Length(AAttributeValue) > 0
              then Insert(#32 + AAttributeName + '="' + WMLEntityStr(AAttributeValue) + '"', s_element, st);
            end;
          end;
        end;
      end;
    end;
  end;
  p:= AElement.DrawProperties.TagXYStart;
  Dec(p.Y);
  // delete old element text
  AMemo.DeleteBetweenPos(p, AElement.DrawProperties.TagXYFinish);
  // add new element text
  s_element:= util_xml.SplitLongText(s_element, AElement.DrawProperties.TagXYStart.Y,
    AElement.DrawProperties.TagXYStart.Y + BlockIndent, AMemo.RightEdgeCol);
  AMemo.InsertTextAtPos(s_element, AElement.DrawProperties.TagXYStart.Y - 1, AElement.DrawProperties.TagXYStart.X);

  // refresh code positions in element treeview (calculate new text positions of edited element and below this element)
  with AElement.DrawProperties do begin
    Shift.X:= TagXYFinish.X - TagXYStart.X;
    Shift.Y:= TagXYFinish.Y - TagXYStart.Y;
  end;

  // fix new end of element
  with AElement.DrawProperties do begin
    TagXYFinish:= TagXYStart;
    CalcTextColsRows(s_element, TagXYFinish);
  end;
  // compile new element text to calculate text positions
  xmlParse.xmlCompileText(s_element, Nil, Nil, Nil, TreeViewElements.Selected.Data, getContainerClassByDoctype(fs.DocType));
  // shift down or up text positions of other elements located below edited element
  with AElement.DrawProperties do begin
    Shift.X:= (TagXYFinish.X - TagXYStart.X) - Shift.X;
    Shift.Y:= (TagXYFinish.Y - TagXYStart.Y) - Shift.Y;
  end;
  ShiftNodeElementsTextPositions(TreeViewElements.Selected, Shift);

  // show changed id in tree list (if element name has been changed)
  if CompareText(AAttributeName, 'id') = 0 then begin
    if Assigned(TreeViewElements.Selected) and
      (TreeViewElements.Selected.Data = AElement) then begin
      TreeViewElements.Selected.Text:= AAttributeValue;
    end else begin
      // search tree node here. Not implemented.
    end;
  end;
  // show changes in byte code window
  if (fs.DocType in [edWML, edWMLTemplate, edWMLCompiled]) and Assigned(FormByteCode) and FormByteCode.Visible then begin
    // view byte code
    FormByteCode.SyncViewXML(FWMLCollection);
  end;

  AMemo.ModifiedSinceLastDelay:= False;
  ToolBarElements.Enabled:= True;
//AMemo.Modified:= True;
  // in case of errors found recompile source. Do not if no errors found
  // it is commented for
  if (ListBoxInfo.Items.Count > 0) and (PageControlEditors.TabIndex <> 2) 
  then actViewCompileCurrentFileExecute(Self);
end;

procedure TFormDockBase.ViewSource(AWMLElement: TxmlElement);
var
  M: TECustomMemo;
begin
  NestedElements2ToolButtons(AWMLElement, ToolbarElements, ToolButtonNewClick);
  M:= GetCurMemo;
  if Assigned(M) then begin
    M.CaretPos_V:= AWMLElement.DrawProperties.TagXYStart.x;
    M.CaretPos_H:= AWMLElement.DrawProperties.TagXYStart.y - 1;
  end;
end;

procedure TFormDockBase.CBFilterChange(Sender: TObject);
begin
  RebuildFilter;
end;

procedure TFormDockBase.Start;
begin
  actClearMessagesExecute(Self);
  with ListBoxInfo, Items do begin
    // disable listview redraws
    Perform(WM_SETREDRAW, 0, 0);
    BeginUpdate;
    Hint:= 'Messages window';
  end;
  ToolBarElements.Enabled:= False;
end;

procedure TFormDockBase.Finish;
begin
  if ListBoxInfo.Items.Count > 0 then begin
  end;
  ListBoxInfo.Items.EndUpdate;
  // enable listview redraws
  ListBoxInfo.Perform(WM_SETREDRAW, 1, 0);
  ToolBarElements.Enabled:= True;
end;

procedure TFormDockBase.AddParseMessage(ALevel: TReportLevel; AWMLElement: TxmlElement;
  const ASrc: PWideChar; ASrcLen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
  var AContinueParse: Boolean; AEnv: Pointer);
var
  Src: String;
begin
  if ASrcLen = 0
  then Src:= GetCurMemoFileStatus.FileName
  else Src:= ASrc;  // ignore #0 and all beyond
  ListBoxInfo.Items.AddObject(Format('%s: %s(%d,%d): %s', [xmlParse.ReportLevelStr[ALevel], Src, AWhere.x + 1, AWhere.y + 1, ADesc]), AWMLElement);
end;

// go to object or/and text editor
procedure TFormDockBase.ListBoxInfoDblClick(Sender: TObject);
var
  p, L: Integer;
  wh: TPoint;
  s, s1: String;
begin
  if Assigned(ListBoxInfo.Items.Objects[ListBoxInfo.ItemIndex]) then begin
    with TreeViewElements do begin
      for p:= 0 to Items.Count - 1 do begin
        if Items[p].Data = ListBoxInfo.Items.Objects[ListBoxInfo.ItemIndex] then begin
          Items[p].Selected:= True;
          // Exit; -- do not Exit, but try to find out position more precisely
          Break;
        end;
      end;
    end;
  end;
  //
  s:= util1.GetToken(2, #32, ListboxInfo.Items[ListboxInfo.ItemIndex]);
  p:= PosBack('(', s);
  if p <= 0
  then Exit;
  s1:= Copy(s, p + 1, MaxInt);
  // get file name
  Delete(s, p, MaxInt);
  // get position
  L:= Length(s1);
  if L <= 1
  then Exit;
  Delete(s1, L - 1, 2);
  wh.x:= StrToIntDef(util1.GetToken(1, ',', s1), 1);
  wh.y:= StrToIntDef(util1.GetToken(2, ',', s1), 1);

  Dec(wh.x);

  FileList2Open.Clear;
  FileList2Open.AddObject(s, TObject(@wh));
  OpenFiles(FileList2Open, edDefault, False);
end;

// editor

function TFormDockBase.GetCurMemo: TECustomMemo;
begin
  if TCOpenFiles.TabIndex < 0
  then Result:= Nil
  else Result:= Memos.Memo[TCOpenFiles.TabIndex];
end;

function TFormDockBase.GetCurMemoFileStatus: TFileStatus;
begin
  if TCOpenFiles.TabIndex < 0
  then Result:= Nil
  else Result:= Memos.FileStatus[TCOpenFiles.TabIndex];
end;

function TFormDockBase.NewFile(ADoc: TEditableDoc; const ADeckNamePrefix: String; const AContent: WideString): String;
var
  idx: Integer;
  bmp: TBitmap;
  foldername: String;
begin
  if SysUtils.DirectoryExists(FolderTree1.Directory)
  then foldername:= FolderTree1.Directory
  else foldername:= ExtractFilePath(FolderTree1.Directory);
  Result:= util1.ConcatPath(foldername, Format(ADeckNamePrefix,
    [FormatDateTime('yymmdd', Now)]));
  idx:= Memos.AddNew(Result, AContent, ADoc, srFile);
  with Memos.Memo[idx].GutterOptions do begin
    {
    ShowBookmarks:= False;
    }
    ShowCaretPos:= True;
    bmp:= TBitmap.Create;
    dm1.Imagelist16.GetBitmap(ICON_LINE_CURSOR, bmp);
    CaretPosBitmap:= bmp;
    bmp.Free;
  end;
  // store type of opened file
  TCOpenFiles.Tabs.AddObject(Result, TObject(Nil));
  // select last opened file
  if idx >= 0 then begin
    TCOpenFiles.TabIndex:= idx;
    TCOpenFiles.OnChange(Self);
  end;
//  FolderTree1.
end;

// close opened file

function TFormDockBase.CloseFile(AIdx: Integer; AAppClose: Boolean): Word;
begin
  Result:= mrCancel;

  if (Aidx < 0) or (AIdx >= Memos.Size)
  then Exit;

  if Memos.Memo[Aidx].Modified then begin
    Result:= Dialogs.MessageDlg(Format(MSG_SAVEFILE, [Memos.FileStatus[Aidx].FileName]), mtWarning, [mbYes, mbNo], 0);
    case Result of
      mrNo: ;
      mrYes: Memos.Store(Aidx, '', srSame, edSame);
    end;
  end;

  // before Memos.Delete, it calls TSCodeExit to compile current memo (if changed)
  // delete memo
  TCOpenFiles.TabIndex:= -1;  // disable compilation memo requested to delete
  Memos.Delete(Aidx);
  // ?!!
  TCOpenFiles.Tabs.Delete(Aidx);
  TCOpenFiles.Repaint;

  if Aidx >= TCOpenFiles.Tabs.Count
  then Dec(Aidx);
  if Aidx >= 0 then begin
    TCOpenFiles.TabIndex:= Aidx;
    if not AAppClose
    then TCOpenFiles.OnChange(Self);
  end else begin
    // clear attributes
    FAttributeInspector.XMLElement:= Nil;
    // delete tree view items
    with TreeViewElements.Items do begin
      // disable listview redraws
      Perform(WM_SETREDRAW, 0, 0);
      BeginUpdate;
      Clear;
      EndUpdate;
      // enable listview redraws
      Perform(WM_SETREDRAW, 1, 0);
    end;
    TreeViewElements.Refresh;  // show cleared area

    // clear buttons
    NestedElements2ToolButtons(Nil, ToolbarElements, ToolButtonNewClick);
    // clear messages
    actClearMessages.Execute;
    // recreate wml tag collection
    FWMLCollection.Clear1;
    FOEBCollection.Clear1;
    FPkgCollection.Clear1;
    FXHTMLCollection.Clear1;
    FTaxonCollection.Clear1;
    FSmitCollection.Clear1;
    FxHHCCollection.Clear1;
    FxHHKCollection.Clear1;
    FxRTCCollection.Clear1;
  end;
end;

{ OpenFiles()
  Parameters:
    ARefreshViewOnChangeTab - force refresh (recompile sources) if tab is changed
}
// open files, select to last file and compile last file
function TFormDockBase.OpenFiles(AFilesList: TStrings; AType: TEditableDoc = edDefault;
  ARefreshViewOnChangeTab: Boolean = True): Integer;
var
  i: Integer;
  bmp: TBitmap;
  storage: TStorageType;

  procedure SetCursor2NewPos(ALast: Integer);
  var
    pwh: ^TPoint;
  begin
    pwh:= Pointer(AFilesList.Objects[ALast]);
    if pwh = Nil
    then Exit;
    if (pwh^.x >= 0) and (pwh^.y >= 0) and
      (pwh^.x < Memos.Memo[Result].Lines.Count) then begin
      with Memos.Memo[Result] do begin
        CaretPos_V:= pwh^.x;
        if (CaretPos_H < pwh^.y - 1) or (CaretPos_H >= pwh^.y - 1 + VisibleColumns)
        then CaretPos_H:= pwh^.y - 1;
      end;
    end;
  end;

  procedure DoAddDoc;
  begin
    // doctype:= Memos.FileStatus[Result].doctype;
    with Memos.Memo[Result].GutterOptions do begin
      {
      ShowBookmarks:= False;
      }
      ShowCaretPos:= True;
      bmp:= TBitmap.Create;
      dm1.Imagelist16.GetBitmap(ICON_LINE_CURSOR, bmp);
      CaretPosBitmap:= bmp;
      bmp.Free;
      // update recent files menu
      wmleditutil.UpdateRecentFilesMenu(pmRecentFiles, MenuRecentFileClick, AFilesList[i]);
    end;
    // store type of opened file
    TCOpenFiles.Tabs.AddObject(Copy(AFilesList[i], LastDelimiter('\', AFilesList[i]) + 1, MaxInt),
      TObject(Nil));
    // scroll cursor to
    if AFilesList.Objects[i] <> Nil then begin
      SetCursor2NewPos(i);
    end;
  end;

begin
  // ?!! BUGBUG strip protocol or UNC prefix there 'll be helpful such file://
  Result:= -1;
  i:= 0;
  while i < AFilesList.Count do begin
    Result:= Memos.IndexOfFileName(AFilesList[i]);
    // set to code editor
    if PageControlEditors.ActivePage <> TSCode
    then PageControlEditors.ActivePage:= TSCode;
    if Result < 0 then begin
      if DirectoryExists(AFilesList[i]) then begin
        FolderTree1.Directory:= AFilesList[i];
      end else begin
        storage:= GetStorageTypeByFileName(AFilesList[i]);
        // load document, define doctype
        Result:= Memos.Add(AFilesList[i], storage, AType);
        DoAddDoc;
      end;
    end;
    Inc(i);
  end;
  // if nothing to open, open last
  if Result < 0
  then Result:= TCOpenFiles.Tabs.Count - 1 else begin
    // select last opened file
    if ARefreshViewOnChangeTab or (TCOpenFiles.TabIndex <> Result) then begin
      TCOpenFiles.TabIndex:= Result;
      TCOpenFiles.OnChange(Self);  // call actViewCompileCurrentFileExecute
    end;
    SetCursor2NewPos(i-1);
  end;
end;

procedure TFormDockBase.OnMemoEvents(Sender: TObject; Shift: TShiftState; KeyEvent: TGsKeyEvent;
  Key: Word; CaretPos, MousePos: TPoint; Modified, OverwriteMode: Boolean);
var
  p: TPoint;
  fs: TFileStatus;
begin
  with Memos.Memo[TCOpenFiles.TabIndex] do begin
    // fs:= GetCurMemoFileStatus;
    // ToolBarElements.Enabled:= not ModifiedSinceLastDelay;
    p.x:= CaretPos_V;
    p.y:= CaretPos_H;
    Statusbar1.Panels[0].Text:= Format('%5d:%5d', [p.x+1, p.y+1]);
    if Modified then begin
      Statusbar1.Panels[1].Text:= 'Modified';
    end else begin
      Statusbar1.Panels[1].Text:= '';
    end;
    if OverwriteMode
    then Statusbar1.Panels[2].Text:= 'Overwrite'
    else Statusbar1.Panels[2].Text:= 'Insert';
    Statusbar1.Panels[3].Text:= wmlc.CharSetCode2Name(Encoding);

    //if not Assigned(fs) then Exit;
    // reflect treeview - it works, but bug in somewhere
    {
      CurElement:= getContainerByDoctype(fs.DocType).FindByLocation(p);
    }
  end;
end;

procedure TFormDockBase.TCOpenFilesChange(Sender: TObject);
begin
  TCOpenFiles.Hint:= Format('%s', [Memos.FileStatus[TCOpenFiles.TabIndex].FileName]);
  // set to code editor
  if PageControlEditors.ActivePage <> TSCode
  then PageControlEditors.ActivePage:= TSCode;

  Memos.Selected[TCOpenFiles.TabIndex]:= True;

  MemoWMLCode.CxMemo:= Nil;
  MemoOEBCode.CxMemo:= Nil;
  MemoPkgCode.CxMemo:= Nil;
  MemoHTMLCode.CxMemo:= Nil;
  MemoXHTMLCode.CxMemo:= Nil;
  MemoTaxonCode.CxMemo:= Nil;
  case Memos.FileStatus[TCOpenFiles.TabIndex].doctype of
    edText: ;
    edWML, edWMLCompiled, edWMLTemplate:  MemoWMLCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
    edCSS, edOEB: MemoOEBCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
    edPKG: MemoPkgCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
    edHTML: MemoHTMLCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
    edXHTML: MemoXHTMLCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
    edTaxon: MemoTaxonCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
    edSMIT: MemoSMITCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
    edHHC: MemoXHTMLCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
    edHHK: MemoXHTMLCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
    edRTC: MemoXHTMLCode.CxMemo:= Memos.Memo[TCOpenFiles.TabIndex];
  end;
  Memos.Memo[TCOpenFiles.TabIndex].OnMemoEvents:= OnMemoEvents;
  actViewCompileCurrentFileExecute(Sender);
end;

procedure TFormDockBase.actViewWindowProjectExecute(Sender: TObject);
begin
  PanelProject.Visible:= not PanelProject.Visible;
  actViewWindowProject.Checked:= PanelProject.Visible;
end;

procedure TFormDockBase.actViewWindowEditorExecute(Sender: TObject);
begin
  PanelEditor.Visible:= not PanelEditor.Visible;
  actViewWindowEditor.Checked:= PanelEditor.Visible;
end;

procedure TFormDockBase.actViewWindowElementExecute(Sender: TObject);
begin
  with TreeViewElements do begin
    Visible:= not Visible;
    actViewWindowElement.Checked:= Visible;
  end;  
end;

procedure TFormDockBase.actViewWindowAttributeExecute(Sender: TObject);
begin
  FAttributeInspector.Visible:= not FAttributeInspector.Visible;
  actViewWindowAttribute.Checked:= FAttributeInspector.Visible;
end;

procedure TFormDockBase.actViewWindowMessagesExecute(Sender: TObject);
begin
  ListBoxInfo.Visible:= not ListBoxInfo.Visible;
  actViewWindowMessages.Checked:= ListBoxInfo.Visible;
end;

procedure TFormDockBase.actViewEditorOnlyExecute(Sender: TObject);
var
  b: Boolean;
begin
  // view editor only
  PanelEditor.Visible:= True;
  b:= actViewEditorOnly.Checked;

  actViewEditorOnly.Checked:= not b;
  PanelProject.Visible:= b;
  TreeViewElements.Visible:= b;
  FAttributeInspector.Visible:= b;
  ListBoxInfo.Visible:= b;
end;

procedure TFormDockBase.actViewWindowAllowDockExecute(Sender: TObject);
var
  i: Integer;
begin
  //
  if asAllowDocking in FAppSettingsSet then begin
    FAppSettingsSet:= FAppSettingsSet - [asAllowDocking];
    actViewWindowAllowDock.Checked:= False;
    PanelDockSite.DockSite:= False;
    for i:= Low(TDockableControlsArray) to High(TDockableControlsArray) do begin
      if  FDockableControlsArray[0] is TPanel
      then TPanel(FDockableControlsArray[i]).DragMode:= dmManual;
      if  FDockableControlsArray[0] is TTreeView
      then TTreeView(FDockableControlsArray[i]).DragMode:= dmManual;
      if  FDockableControlsArray[0] is TValueListEditor
      then TValueListEditor(FDockableControlsArray[i]).DragMode:= dmManual;
      if  FDockableControlsArray[0] is TListBox
      then TListBox(FDockableControlsArray[i]).DragMode:= dmManual;
    end;
  end else begin
    FAppSettingsSet:= FAppSettingsSet + [asAllowDocking];
    PanelDockSite.DockSite:= True;
    actViewWindowAllowDock.Checked:= True;    
    for i:= Low(TDockableControlsArray) to High(TDockableControlsArray) do begin
      if  FDockableControlsArray[0] is TPanel
      then TPanel(FDockableControlsArray[i]).DragMode:= dmAutomatic;
      if  FDockableControlsArray[0] is TTreeView
      then TTreeView(FDockableControlsArray[i]).DragMode:= dmAutomatic;
      if  FDockableControlsArray[0] is TValueListEditor
      then TValueListEditor(FDockableControlsArray[i]).DragMode:= dmAutomatic;
      if  FDockableControlsArray[0] is TListBox
      then TListBox(FDockableControlsArray[i]).DragMode:= dmAutomatic;
    end;
  end;
end;

procedure TFormDockBase.PanelProjectResize(Sender: TObject);
begin
  PanelProjectTreeView.Height:= PanelProject.Height - PanelFilter.Height - 6;
  PanelProjectTreeView.Width:= PanelProject.Width - 6;
end;

procedure TFormDockBase.sysExecuteMacro(Sender: TObject; Msg: TStrings);
var
  i, p0, p1: Integer;
  cmd, Macro: String;
  R: TStrings;
begin
  // open files thru DDE
  R:= TStringList.Create;
  for i:= 0 to Msg.Count - 1 do begin
    // parse command - 1. macro name 2. parameter list ("par 1", "par 2")
    Macro:= Trim(Msg[i]);
    p0:= Pos('(', Macro);
    p1:= Pos(')', Macro);
    if (p0 = 0) or (p0 >= p1)
    then Break;
    cmd:= Trim(Copy(Macro, 1, p0-1));
    // get list of parameters
    R.CommaText:= Trim(Copy(Macro, p0+1, p1-p0-1));
    if AnsiCompareText(cmd, 'fileopen') = 0 then begin
      OpenFiles(R);
    end;
    if (AnsiCompareText(cmd, 'folderopen') = 0) and (R.Count > 0) and (Length(R[0]) > 0) then begin
      R[0]:= ExtractFilePath(R[0]);
      if DirectoryExists(R[0]) then begin
        FolderTree1.Directory:= R[0];
      end;
    end;
  end;
  R.Free;
end;

procedure TFormDockBase.actParseCommandLineExecute(Sender: TObject);
begin
  // parse command line
  OpenFiles(FileList2Open);
  FileList2Open.Clear;
end;

procedure TFormDockBase.TSCodeExit(Sender: TObject);
var
  CurMemo: TECustomMemo;
begin
  //
  CurMemo:= GetCurMemo;
  if Assigned(CurMemo) then begin
    // if memo is changed since last compilation, compile it
    if CurMemo.ModifiedSinceLastDelay
    then actViewCompileCurrentFileExecute(Sender);
  end;
end;

procedure TFormDockBase.TreeViewElementsEdited(Sender: TObject;
  Node: TTreeNode; var S: String);
begin
  //
  TxmlElement(Node.Data).Name:= S;
  // re- assign after validation
  S:= TxmlElement(Node.Data).Name;
  // show changes in attribute list and text
  FAttributeInspector.Values['id']:= FCurElement.Attributes.ValueByName['id'];
  ReflectAttributeChange('id', FCurElement.Attributes.ValueByName['id'], FCurElement, GetCurMemo);
end;

procedure TFormDockBase.TreeViewElementsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then begin
    if ssShift in Shift then begin
      //
    end else begin
      actEditDeleteCurrentElementExecute(Self);
    end;
  end;
end;

function WalkFolder_Search(const FN: String; AEnv: TObject = Nil): Boolean;
type
  TDLLFunc = procedure (const AFileName: PChar); stdcall;
var
  idx: Integer;
  opt: TGsFindOptions;
  cm: TECustomMemo;
  dllFunc: TDllFunc;
  p: Integer;
  extHandle: HMODULE;
  extfn, extfunc: String;
  ofn: String;
  justcount: Boolean;
begin
  Result:= Assigned(FormSearching) and (FormSearching.Visible);
  if not Result
  then Exit;
  // just file count if condition is not set
  justcount:= Length(FormDockBase.FSearchContext.LastSearchText) = 0;
  // load memo if not opened yet
  idx:= FormDockBase.Memos.IndexOfFileName(fn);
  if idx < 0 then begin
    if not justcount then begin
      cm:= Load2NewMemo(GetStorageTypeByFileName(fn), fn,
        dm.Dm1.OnGetStorageFile);
      if not Assigned(cm)
      then Exit;
    end;
  end else begin
    cm:= FormDockBase.Memos[idx];
    cm.CaretPos_H:= 1;  // Nov 18 2003
    cm.CaretPos_V:= 0;
  end;

  opt:= TGsFindOptions(Pointer(AEnv)^);

  // we start globally, later after first search loop we must turn off this..

  Exclude(opt, foBackward);
  Include(opt, foGlobalScope);
  Exclude(opt, foOriginFromCursor);

  FormSearching.LabelIndicator.Caption:= 'Search ' + fn;
  Application.ProcessMessages;

  // count entries
  FormDockBase.FSearchContext.Count:= FormDockBase.FSearchContext.Count + 1;

  if (foDirCreateDescFile in opt) or (foDirCreateIdxFile in opt) then begin
    // create file description
    if justcount or cm.FindText(FormDockBase.FSearchContext.LastSearchText, opt) then begin
      ofn:= ConcatPath(FormDockBase.FSearchContext.LastInitDir, SRCH_DIR_DESC_FILE, '\');
      util1.String2File(ofn, IntToStr(FormDockBase.FSearchContext.Count) + #9 + util1.DiffPath(FormDockBase.FSearchContext.LastInitDir,  Fn) + #13#10);
      FormDockBase.ListBoxInfo.Items.AddObject(Format('%s: %s(%d,%d): %s', [ReportLevelStr[rlSearch],
        fn, 1, 1, 'File '+ IntToStr(FormDockBase.FSearchContext.Count)]), Nil);
    end;
  end else begin
    // add found lines refs to the Info panel list
    if justcount then begin
      FormDockBase.ListBoxInfo.Items.AddObject(Format('%s: %s(%d,%d): %s', [ReportLevelStr[rlSearch],
        fn, 1, 1, 'File '+ IntToStr(FormDockBase.FSearchContext.Count)]), Nil);
      Include(opt, foOriginFromCursor);
    end else begin
      if (foDirExecProgram in opt) then begin
        // execute external program or procedure
        ofn:= ConcatPath(ExtractFilePath(fn), SRCH_DIR_EXEC_FILE, '\');
        extfn:= FormDockBase.FParameters.Values[ParameterNames[ID_SrchDirExecExternal]];
        if Pos('.dll', Lowercase(extfn)) > 0 then begin
          p:= Pos('#', extFn);
          if p = 0
          then Exit;
          extHandle:= LoadLibrary(PChar(Copy(extFn, 1, p - 1)));
          if extHandle = 0
          then Exit;
          extfunc:= Copy(extFn, p + 1, MaxInt);
          if Length(extFunc) = 0 then begin
            FreeLibrary(extHandle);
            Exit;
          end;
          dllFunc:= GetProcAddress(extHandle, PChar(extfunc));
          if not Assigned(dllFunc) then begin
            FreeLibrary(extHandle);
            Exit;
          end;
        end else dllFunc:= Nil;
        // prepare regular expressions
        if (fRegularExpression in opt) then cm.PrepareFindTextURE(opt);
        while cm.FindText(FormDockBase.FSearchContext.LastSearchText, opt) do begin
          DeleteFile(ofn);
          util1.String2File(ofn, cm.GetTextBetweenPos(cm.SelBegin, cm.SelEnd));
          if Assigned(dllFunc) then begin
             dllFunc(PChar(ofn));
          end else begin
            util1.EExecuteFile(Format('%s %s', [extfn, ofn]));
          end;
          DeleteFile(ofn);
          FormDockBase.ListBoxInfo.Items.AddObject(Format('%s: %s(%d,%d): %s', [ReportLevelStr[rlSearch],
            fn, cm.CaretPos_V + 1, cm.CaretPos_H + 1, Trim(cm.Lines[cm.CaretPos_V])]), Nil);
          // we started globally, now back to iterate
          Include(opt, foOriginFromCursor);
          // Exclude(opt, foGlobalScope);
        end;
        if (fRegularExpression in opt) then cm.UnPrepareFindTextURE;
        if Assigned(dllFunc) then begin
           FreeLibrary(extHandle);
        end;
      end else begin
        Include(opt, foOriginFromCursor);
        while cm.FindText(FormDockBase.FSearchContext.LastSearchText, opt) do begin
          FormDockBase.ListBoxInfo.Items.AddObject(Format('%s: %s(%d,%d): %s', [ReportLevelStr[rlSearch],
            fn, cm.CaretPos_V + 1, cm.CaretPos_H + 1, Trim(cm.Lines[cm.CaretPos_V])]), Nil);
          // we started globally, now back to iterate
          Include(opt, foOriginFromCursor);
          // Exclude(opt, foGlobalScope);
        end;
      end;
    end;
  end;
  // release temporary created memo
  if (not justcount) and (idx < 0)
  then cm.Free;
end;

function WalkFolder_Replace(const FN: String; AEnv: TObject = Nil): Boolean;
var
  idx: Integer;
  opt: TGsFindOptions;
  cm: TECustomMemo;
  cnt: Integer;
begin
  Result:= Assigned(FormSearching) and (FormSearching.Visible);
  if not Result
  then Exit;
  // load memo if not opened yet
  idx:= FormDockBase.Memos.IndexOfFileName(fn);
  if idx < 0
  then cm:= Load2NewMemo(GetStorageTypeByFileName(fn), fn,
    dm.Dm1.OnGetStorageFile)
  else cm:= FormDockBase.Memos[idx];
  if not Assigned(cm)
  then Exit;

  cnt:= 0;
  opt:= TGsFindOptions(Pointer(AEnv)^);
  Include(opt, foOriginFromCursor);

  FormSearching.LabelIndicator.Caption:= 'Replacing in ' + fn;
  Application.ProcessMessages;
  while cm.ReplaceText(FormDockBase.FSearchContext.LastSearchText, FormDockBase.FSearchContext.LastReplaceText, opt) do begin
    Inc(Cnt);
    FormSearching.LabelIndicator.Caption:= 'Replacing in ' + fn + ': ' + IntToStr(Cnt);
    Application.ProcessMessages;
    Include(opt, foOriginFromCursor);
  end;

  // save and release temporary created memo
  if idx < 0 then begin
    if cnt > 0 then begin
      StoreMemo2File(cm, edDefault, GetStorageTypeByFileName(fn), fn);
    end;
    cm.Free;
  end;
end;

procedure TFormDockBase.actEditFindExecute(Sender: TObject);
var
  cm: TECustomMemo;
  fs: TFileStatus;
  fopt: TGsFindOptions;
  searchingtext: WideString;
  m, count: Integer;
  R: TStrings;
  fn: String;
begin
  // find text
  fs:= GetCurMemoFileStatus;
  cm:= GetCurMemo;
  if (not Assigned(fs)) or (not Assigned(cm))
  then Exit;

  // Dialogs.MessageDlg(Format(MSG_NOFEATURE, ['Find Text']), mtInformation, [mbCancel], 0);
  fopt:= FSearchContext.LastFindOptions;

  FFind.FormFind:= TFormFind.Create(Self);
  with FormFind do begin
    Text2Search:= FSearchContext.LastSearchText;
    CBText.Items.Assign(FSearchContext.LastSearches);
    CBRegularExpressions.Checked:= fRegularExpression in fopt;
    CBIgnoreNonSpacing.Checked:= foRegIgnoreNonSpacing  in fopt;
    CBSpaceCompress.Checked:= foRegSpaceCompress in fopt;

    CBWholeWordsOnly.Checked:= foWholeWords in fopt;
    CBCaseSensitive.Checked:= foCaseSensitive in fopt;
    CBDirRecurse.Checked:= FSearchContext.DirRecurse;

    if foDirCreateDescFile in fopt then CBDirPerform.ItemIndex:= 1
    else if foDirCreateIdxFile in fopt then CBDirPerform.ItemIndex:= 2
    else if foDirExecProgram in fopt then begin CBDirPerform.ItemIndex:= 3; CBDirPerformChange(Self); end
    else CBDirPerform.ItemIndex:= 0;

    if foOriginFromCursor in fopt
    then RGOrigin.ItemIndex:= 0
    else RGOrigin.ItemIndex:= 1;
    if foBackward in fopt
    then RGDirection.ItemIndex:= 1;

    // check is current file opened is ordinal file
    if fs.Storage <> srFile then begin
      // remove search in directory options
      if RGWhere.Items.Count >= 3
      then RGWhere.Items.Delete(2);
      CBDir.Text:= FolderTree1.Directory;
    end else begin;
      // set directory to find
      CBDir.Text:= ExtractFilePath(fs.FileName);
      // set file filter
      CBFilter.ItemIndex:= Self.CBFilter.ItemIndex;
    end;

    // RGWhere.ItemIndex:= FSearchContext.Where;
    // allways set where to find occurencied in current file (for safety)
    RGWhere.ItemIndex:= 0;

    CBProgram.Text:= FParameters.Values[ParameterNames[ID_SrchDirExecExternal]];

    if cm.Selected              // mark scope "Selected" if text selected in editor
    then RGScope.ItemIndex:= 1;

    if ShowModal = mrOK then begin
      searchingtext:= Text2Search;
      fopt:= [];
      if CBRegularExpressions.Checked
      then Include(fopt, fRegularExpression);
      if CBIgnoreNonSpacing.Checked
      then Include(fopt, foRegIgnoreNonSpacing);
      if CBSpaceCompress.Checked
      then Include(fopt, foRegSpaceCompress);

      if CBCaseSensitive.Checked
      then Include(fopt, foCaseSensitive);
      if CBWholeWordsOnly.Checked
      then Include(fopt, foWholeWords);
      FSearchContext.DirRecurse:= CBDirRecurse.Checked;

      if RGScope.ItemIndex = 0
      then Include(fopt, foGlobalScope);

      if (RGOrigin.ItemIndex = 0) and (foGlobalScope in fopt)
      then Include(fopt, foOriginFromCursor);

      if RGDirection.ItemIndex > 0
      then Include(fopt, foBackward);

      case CBDirPerform.ItemIndex of
      1: Include(fopt, foDirCreateDescFile);
      2: Include(fopt, foDirCreateIdxFile);
      3: Include(fopt, foDirExecProgram);
      end;

      if (fRegularExpression in fopt) then cm.PrepareFindTextURE(fopt);
      case RGWhere.ItemIndex of
      0:begin
          // search in current file
          if not cm.FindText(searchingtext, fopt) then begin
            Dialogs.MessageDlg(Format(MSG_TEXTNOTFOUND, [searchingtext]), mtInformation, [mbCancel], 0);
          end;
        end;
      1:begin
          // search in all open files
          fSearching.FormSearching:= TFormSearching.Create(Nil);
          FormSearching.Show;
          count:= 0;
          actClearSearchExecute(Self);

          Exclude(fopt, foBackward);
          Include(fopt, foGlobalScope);
          Include(fopt, foOriginFromCursor);
          
          for m:= 0 to Memos.Size - 1 do begin
            cm:= Memos.Memo[m];
            fs:= Memos.FileStatus[m];

            cm.CaretPos_V:= 0;
            cm.CaretPos_H:= 1;
            while cm.FindText(searchingtext, fopt) do begin
              Inc(Count);
              ListBoxInfo.Items.AddObject(Format('%s: %s(%d,%d): %s', [ReportLevelStr[rlSearch],
                fs.FileName, cm.CaretPos_V + 1, cm.CaretPos_H + 1, Trim(cm.Lines[cm.CaretPos_V])]), Nil);
            end;
          end;
          FormSearching.Free;
          FormSearching:= Nil;
        end;
      2:begin
          // search in directory (and subdirectories)
          fSearching.FormSearching:= TFormSearching.Create(Nil);
          FormSearching.Show;
          // search in directory
          actClearSearchExecute(Self);
          FSearchContext.LastSearchText:= searchingtext;
          count:= 0;

          Exclude(fopt, foBackward);
          Include(fopt, foGlobalScope);
          Exclude(fopt, foOriginFromCursor);
          cm.CaretPos_V:= 0;
          cm.CaretPos_H:= 1;

          // set root directory
          FSearchContext.LastInitDir:= CBDir.Text;

          // set count to 0
          FSearchContext.Count:= 0;

          // build extensions list
          R:= TStringList.Create;
          util_xml.GetStringsFromFileFilter(CBFilter.Text, 3, R);

          // special action preparations
          if (foDirCreateDescFile in fopt) or (foDirCreateIdxFile in fopt) then begin
            fn:= ConcatPath(FormDockBase.FSearchContext.LastInitDir, SRCH_DIR_DESC_FILE, '\');
            // delete description file if allready exists
            if FileExists(fn)
            then DeleteFile(fn);
            // store first line with description of files structure if applicable
            // for each file extension mask
            // first string must be started with space (for sort purposes)
            util1.String2File(fn, #32 + GetDocTypeDesc(getDoctypeByContainerClass(GetClassByBitmapIndex(Integer(CBFilter.Items.Objects[CBFilter.ItemIndex])))) +
              ',' + DateTimeToStr(Now) + ',');
            for m:= 0 to R.Count - 1 do begin
              util1.String2File(fn, R[m] + ',');
            end;
            util1.String2File(fn, 'search:' + searchingtext + #13#10);
          end;
          if (foDirExecProgram in fopt) then begin
            FParameters.Values[ParameterNames[ID_SrchDirExecExternal]]:= CBProgram.Text;
            // ask for external program name and options
          end;

          // for each file extension mask
          for m:= 0 to R.Count - 1 do begin
            util1.Walk_Tree(R[m], CBDir.Text, 0, FSearchContext.DirRecurse, WalkFolder_Search, TObject(@fopt));
          end;
          R.Free;

          if (foDirCreateDescFile in fopt) then begin
            // sort descript.ion file
            // util1.SortFile(fn, 1);
          end;
          FormSearching.Free;
          FormSearching:= Nil;

          if (foDirCreateIdxFile in fopt) then begin
            // display build index form
            actBuildDocIndex.Execute;
          end;
        end;
      end; { case }
      if (fRegularExpression in fopt) then cm.UnPrepareFindTextURE;
      // update search context
      FSearchContext.AddOperation(srchSearch, searchingtext, '',
        RGWhere.ItemIndex, FSearchContext.DirRecurse, fopt);

      if foDirCreateDescFile in fopt
      then ListBoxInfo.Items.AddObject(Format('Search finished. Description file of %d file(s) created.',
        [FSearchContext.Count]), Nil);

      if foDirCreateIdxFile in fopt
      then ListBoxInfo.Items.AddObject(Format('Search finished. Index file of %d file(s) created.',
        [FSearchContext.Count]), Nil);
    end;
    Free;
  end;
end;

// search again
procedure TFormDockBase.actEditFindNextExecute(Sender: TObject);
var
  cm: TECustomMemo;
  fopt: TGsFindOptions;
begin
  // find text
  cm:= GetCurMemo;
  // if memo is assigned and search text exists
  if (not Assigned(cm)) or (Length(FSearchContext.LastSearchText) <= 0)
  then Exit;
  with FSearchContext do begin

    // exclude special (action) options  - Oct 24 2004
    fopt:= LastFindOptions - [foDirCreateDescFile, foDirCreateIdxFile, foDirExecProgram];

    case FSearchContext.LastOperation of
    srchNone:;
    srchSearch: begin
        if not cm.FindText(LastSearchText, fopt) then begin
          Dialogs.MessageDlg(Format(MSG_TEXTNOTFOUND, [LastSearchText]), mtInformation, [mbCancel], 0);
        end;
      end;
    srchReplace: begin
        if not cm.ReplaceText(LastSearchText, LastReplaceText, fopt) then begin
          Dialogs.MessageDlg(Format(MSG_TEXTNOTFOUND, [LastSearchText]), mtInformation, [mbCancel], 0);
        end;
      end;
    end; // case
  end;
end;

// find and replace text

procedure TFormDockBase.actEditReplaceExecute(Sender: TObject);
var
  cm: TECustomMemo;
  fs: TFileStatus;
  fopt: TGsFindOptions;
  searchingtext, replacetext: WideString;
  r, count, m: Integer;
  sl: TStrings;
begin
  // find and replace text
  fs:= GetCurMemoFileStatus;
  cm:= GetCurMemo;
  if (not Assigned(fs)) or (not Assigned(cm))
  then Exit;

  actClearSearchExecute(Self);

  fopt:= FSearchContext.LastFindOptions;
  FFindReplace.FormFindReplace:= TFormFindReplace.Create(Self);
  with FormFindReplace do begin
    // set search options to last used
    Text2Search:= FSearchContext.LastSearchText;
    CBReplaceWith.Text:= FSearchContext.LastReplaceText;
    CBText.Items.Assign(FSearchContext.LastSearches);
    CBReplaceWith.Items.Assign(FSearchContext.LastReplaces);
    CBRegularExpressions.Checked:= fRegularExpression in fopt;
    CBIgnoreNonSpacing.Checked:= foRegIgnoreNonSpacing  in fopt;
    CBSpaceCompress.Checked:= foRegSpaceCompress in fopt;
    CBCaseSensitive.Checked:= foCaseSensitive in fopt;
    CBWholeWordsOnly.Checked:= foWholeWords in fopt;
    CBDirRecurse.Checked:= FSearchContext.DirRecurse;

    if foOriginFromCursor in fopt
    then RGOrigin.ItemIndex:= 0
    else RGOrigin.ItemIndex:= 1;
    if foBackward in fopt
    then RGDirection.ItemIndex:= 1;

    if cm.Selected
    then RGScope.ItemIndex:= 1;

    // check is file opened is ordinal file
    if fs.Storage <> srFile then begin
      // remove search in directory options
      if RGWhere.Items.Count >= 3
      then RGWhere.Items.Delete(2);
      CBDir.Text:= FolderTree1.Directory;
    end else begin;
      // set directory to find
      CBDir.Text:= ExtractFilePath(fs.FileName);
      // set file filter
      CBFilter.ItemIndex:= Self.CBFilter.ItemIndex;
    end;

    // RGWhere.ItemIndex:= FSearchContext.Where;
    // allways set where to find occurencied in current file (for safety)
    RGWhere.ItemIndex:= 0;

    // show window
    r:= ShowModal;

    // get search options
    searchingtext:= Text2Search;
    replacetext:= Text2Replace;

    fopt:= [];
    if CBCaseSensitive.Checked
    then Include(fopt, foCaseSensitive);
    if CBWholeWordsOnly.Checked
    then Include(fopt, foWholeWords);
    if CBRegularExpressions.Checked
    then Include(fopt, fRegularExpression);
    if CBIgnoreNonSpacing.Checked
    then Include(fopt, foRegIgnoreNonSpacing);
    if CBSpaceCompress.Checked
    then Include(fopt, foRegSpaceCompress);

    if RGScope.ItemIndex = 0
    then Include(fopt, foGlobalScope);

    if (RGOrigin.ItemIndex = 0) and (foGlobalScope in fopt)
    then Include(fopt, foOriginFromCursor);

    if RGDirection.ItemIndex > 0
    then Include(fopt, foBackward);

    FSearchContext.DirRecurse:= CBDirRecurse.Checked;

    case r of
      mrOK: begin
        if not cm.ReplaceText(searchingtext, replacetext, fopt) then begin
          Dialogs.MessageDlg(Format(MSG_TEXTNOTFOUND, [searchingtext]), mtInformation, [mbCancel], 0);
        end;
      end;
      mrYesToAll: begin
        count:= 0;
        case RGWhere.ItemIndex of
        0:begin
            // search in current file
            while cm.ReplaceText(searchingtext, replacetext, fopt) do begin
              Inc(Count);
            end;
            if Count <= 0 then begin
              Dialogs.MessageDlg(Format(MSG_TEXTNOTFOUND, [searchingtext]), mtInformation, [mbCancel], 0);
            end;
          end;
        1:begin
            // search and replace in all open files
            fSearching.FormSearching:= TFormSearching.Create(Nil);
            FormSearching.Show;

            count:= 0;
            Exclude(fopt, foBackward);
            Include(fopt, foGlobalScope);
            Include(fopt, foOriginFromCursor);

            for m:= 0 to Memos.Size - 1 do begin
              cm:= Memos.Memo[m];
              fs:= Memos.FileStatus[m];
              while cm.ReplaceText(searchingtext, replacetext, fopt) do begin
                Inc(Count);
                // Exclude(fopt, foOriginFromCursor););
              end;
            end;
            FormSearching.Free;
            FormSearching:= Nil;
          end;
        2:begin
            // search in directory
            fSearching.FormSearching:= TFormSearching.Create(Nil);
            FormSearching.Show;

            count:= 0;
            with FSearchContext do begin
              LastSearchText:= searchingtext;
              LastReplaceText:= replacetext;
            end;
            Exclude(fopt, foBackward);
            Include(fopt, foGlobalScope);
            Exclude(fopt, foOriginFromCursor);

            // build extensions list
            sl:= TStringList.Create;
            util_xml.GetStringsFromFileFilter(CBFilter.Text, 3, sl);
            // for each file extension mask
            for m:= 0 to sl.Count - 1 do begin
              util1.Walk_Tree(sl[m], CBDir.Text, 0, FSearchContext.DirRecurse, WalkFolder_Replace, TObject(@fopt));
            end;
            sl.Free;
            FormSearching.Free;
            FormSearching:= Nil;
          end;
        end;
      end;
    end; // case
    // update search context
    FSearchContext.AddOperation(srchReplace, searchingtext, replacetext,
      RGWhere.ItemIndex, FSearchContext.DirRecurse, fopt);
    Free;
  end;
  // Dialogs.MessageDlg(Format(MSG_NOFEATURE, ['Replace']), mtInformation, [mbCancel], 0);
end;

// ----------------- ftp options --------------------

procedure TFormDockBase.actFTPEditExecute(Sender: TObject);
begin
  //
  fExtStorageList.FormExtStorageSites:= TFormExtStorageSites.Create(Self);
  with FormExtStorageSites do begin
    LoadIni;
    if ShowModal = mrOK then begin
      // fFtpList.StoreSiteList(HKEY_CURRENT_USER, RGPath + RG_FTPSITES, URLList);
      StoreIni;
      FParameters.Values[ParameterNames[ID_FtpProxy]]:= dm1.GetStorageProxy(ftFTPNode);
      // refresh Project window
      FolderTree1.FileMask:= FolderTree1.FileMask;
    end;
    Free;
  end;
end;

procedure TFormDockBase.actToolsWBMPConvertorExecute(Sender: TObject);
begin
  // call wbmp image convertor
  util1.EExecuteFile('cvrt2wbmp.exe');
end;

procedure TFormDockBase.ListBoxInfoDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Bitmap: TBitmap;      { temporary variable for the item’s bitmap }
  Offset: Integer;      { text offset width }
  e: TxmlElement;
  imgidx: Integer;
  txt: String;
  sel: Boolean;
begin
  { draw on control canvas, not on the form }
  txt:= TListBox(Control).Items[Index];
  imgidx:= -1;
  with TListBox(Control).Canvas do begin
    if odSelected in State then begin
      // use passed values
      TListBox(Control).Hint:= util_xml.SplitLongText(txt, 1, 0, 80);
      if Pos(ReportLevelStr[rlSearch], txt) = 1
      then imgidx:= 0;
    end else begin
      Brush.Color:= clWindow;
      // 'Hint'
      if Pos(ReportLevelStr[rlHint], txt) = 1 then begin
        Font.Color:= clGrayText;
        Brush.Color:= clWindow;
      end;
      if Pos(ReportLevelStr[rlWarning], txt) = 1 // 'Warning'
      then Font.Color:= clWindowText;
      // 'Error:...
      if Pos(ReportLevelStr[rlError], txt) = 1 then begin
        Font.Color:= clWindowText;
        Brush.Color:= clWindow;
      end;
      // 'Search'
      if Pos(ReportLevelStr[rlSearch], txt) = 1 then begin
        imgidx:= 0;
        Font.Color:= clInfoText;
        Brush.Color:= clInfoBk;
      end;
    end;
    FillRect(Rect);       { clear the rectangle }
    Offset:= 2;          { provide default offset }
    if imgidx < 0 then begin
      // get image form element
      e:= TxmlElement((Control as TListBox).Items.Objects[Index]);
      if Assigned(e) then begin
        imgidx:= GetBitmapIndexByClass(TPersistentClass(e.ClassType));
      end;
    end;
    { get the bitmap }
    if (imgidx >= 0) and (imgidx < dm1.ImageList16.Count) then begin
      Bitmap:= TBitmap.Create;
      dm1.ImageList16.GetBitmap(imgIdx, Bitmap);
      if Bitmap <> nil then begin
        BrushCopy(Bounds(Rect.Left + Offset, Rect.Top, Bitmap.Width, Bitmap.Height),
          Bitmap, Bounds(0, 0, Bitmap.Width, Bitmap.Height), clRed);  {render bitmap}
        Offset:= Bitmap.Width + 6;    { add four pixels between bitmap and text}
      end;
      Bitmap.Free;
    end;
    TextOut(Rect.Left + Offset, Rect.Top, txt)  { display the text }
  end;
end;

procedure TFormDockBase.actInsertImageExecute(Sender: TObject);
var
  fn: String;
  ImageSize: TPoint;
begin

  if (not Assigned(CurElement)) or (not (CurElement.ClassType = TWMLImg))
  then Exit;

  // call wbmp image convertor
  with dm1.WOpenPictureDialog0 do begin
    // Set filter to all supported image formats
    // Filter:= GraphicFilter(TGraphic);
    DitherMode:= TDitherMode(StrToIntDef(FParameters.Values[ParameterNames[ID_DefDitherMode]], 0));
    Stretch:= FParameters.Values[ParameterNames[ID_StretchPreview]] = '1';

    DefaultExt:= GraphicExtension(TWBMPImage);
    InitialDir:= ExtractFilePath(FileName);
    // Use buffering since we have no control over the preview canvas.
    Exclude(GIFImageDefaultDrawOptions, goDirectDraw);
    Options:= Options - [ofAllowMultiSelect];
    try
      if Execute then with FAttributeInspector do begin
        if wmleditutil.IsValidWBMPFile(FileName) then begin
          if GetWBMPSizeFile(FileName, ImageSize) then;
        end else begin
          // choose wbmp file name
          with actImageSaveAsWBMP.Dialog do begin
            FileName:= ReplaceExt('.wbmp', ExtractFileName(dm1.WOpenPictureDialog0.FileName));
            InitialDir:= ExtractFilePath(dm1.WOpenPictureDialog0.FileName);
            DefaultExt:= '.wbmp';
            Filter:= 'wbmp image|*.wbmp|All files|*.*';
            FilterIndex:= 1;
            if not actImageSaveAsWBMP.Execute then begin
              Include(GIFImageDefaultDrawOptions, goDirectDraw);
              Exit;
            end;
            // store using DitherMode
            if not ConvertImage2WBMPFile(dm1.WOpenPictureDialog0.FileName,
              FileName, DitherMode, ImageTransformOptions, ImageSize) then begin
              Include(GIFImageDefaultDrawOptions, goDirectDraw);
              Exit;
            end;
          end;
          // select saved file name
          FileName:= actImageSaveAsWBMP.Dialog.FileName;
        end;
        //
        fn:= util1.DiffPath(ExtractFilePath(GetCurMemoFileStatus.FileName), FileName);
        // set src of image
        Values['src']:= fn;
        ReflectAttributeChange('src', Values['src'], FCurElement, GetCurMemo);
        // set width & height of image
        Values['width']:= IntToStr(ImageSize.X);
        ReflectAttributeChange('width', Values['width'], FCurElement, GetCurMemo);
        Values['height']:= IntToStr(ImageSize.Y);
        ReflectAttributeChange('height', Values['height'], FCurElement, GetCurMemo);
      end;
    finally
      Include(GIFImageDefaultDrawOptions, goDirectDraw);
    end;
  end;
end;

procedure TFormDockBase.actEditMoveElementUpExecute(Sender: TObject);
var
  p, pfin, prev_p: TPoint;
  CurMemo: TECustomMemo;
  fs: TFileStatus;

  prevElement: TxmlElement;
  pc: TPersistentClass;
  s: WideString;
  n: TTreeNode;
begin
  // move current element up
  if (not Assigned(CurElement)) or (not Assigned(CurElement.ParentElement))
  then Exit;

  CurMemo:= GetCurMemo;
  fs:= GetCurMemoFileStatus;
  if (not Assigned(CurMemo)) or (not Assigned(fs))
  then Exit;

  // check is it first element allready
  if CurElement.Order = 0
  then Exit;

  // get current element positions and text
  p:= CurElement.DrawProperties.TagXYStart;
  Dec(p.Y);
  pfin:= CurElement.DrawProperties.TagXYTerminatorFinish;

  s:= CurMemo.GetTextBetweenPos(p, pfin);

  // get previous element and his positions
  prevElement:= CurElement.ParentElement.GetNested1ElementByOrder(CurElement.Order - 1, pc);
  prev_p:= prevElement.DrawProperties.TagXYStart;
  Dec(prev_p.Y);

  // delete element at current position
  CurMemo.DeleteBetweenPos(p, CurElement.DrawProperties.TagXYTerminatorFinish);

  // insert code
  CurMemo.InsertTextAtPos(s, prev_p.y, prev_p.x);

  // select previous element in tree view
  n:= GetElementTreeViewNode(prevElement);
  if Assigned(n)
  then n.Selected:= True;

  // refresh code positions by recompilation
  actViewCompileCurrentFileExecute(Self);
  xmlParse.AddxmlElement2Panel(getContainerByDoctype(fs.DocType), PanelForm,
    dm.dm1.ImageList16, OnElementChange, OnSelectElementClick, ToolButtonNewClick);
end;

procedure TFormDockBase.actEditMoveElementDownExecute(Sender: TObject);
var
  p, pfin, next_p: TPoint;
  CurMemo: TECustomMemo;
  fs: TFileStatus;

  nextElement: TxmlElement;
  pc: TPersistentClass;
  s: WideString;
  n: TTreeNode;
begin
  // move current element up
  if (not Assigned(CurElement)) or (not Assigned(CurElement.ParentElement))
  then Exit;

  CurMemo:= GetCurMemo;
  fs:= GetCurMemoFileStatus;

  if (not Assigned(CurMemo)) or (not Assigned(fs))
  then Exit;

  // check is it last element allready
  if CurElement.Order = CurElement.ParentElement.NestedElements1Count - 1
  then Exit;

  // get current element positions and text
  p:= CurElement.DrawProperties.TagXYStart;
  Dec(p.Y);
  pfin:= CurElement.DrawProperties.TagXYTerminatorFinish;

  s:= CurMemo.GetTextBetweenPos(p, pfin);

  // get next element and his positions
  nextElement:= CurElement.ParentElement.GetNested1ElementByOrder(CurElement.Order + 1, pc);
  next_p:= nextElement.DrawProperties.TagXYTerminatorFinish;

  // first insert code
  CurMemo.InsertTextAtPos(s, next_p.y, next_p.x);

  // then delete element at current position
  CurMemo.DeleteBetweenPos(p, CurElement.DrawProperties.TagXYTerminatorFinish);

  // select next element in tree view
  n:= GetElementTreeViewNode(nextElement);
  if Assigned(n)
  then n.Selected:= True;

  // refresh code positions by recompilation
  // refresh code positions by recompilation
  actViewCompileCurrentFileExecute(Self);
  xmlParse.AddxmlElement2Panel(getContainerByDoctype(fs.DocType), PanelForm,
    dm.dm1.ImageList16, OnElementChange, OnSelectElementClick, ToolButtonNewClick);

end;

// Show compiled deck size
procedure TFormDockBase.actViewInfoExecute(Sender: TObject);
var
  fs: TFileStatus;
  cm: TECustomMemo;
  hrefs: TStringList;
  compiled: String;
  errDesc: TWideStrings;
  sr: TSearchRec;
  i, compiledlen: Integer;
begin
  //
  fs:= GetCurMemoFileStatus;
  cm:= GetCurMemo;
  if (not Assigned(fs)) or (not Assigned(cm))
  then Exit;
  hrefs:= TStringList.Create;
  hrefs.Duplicates:= dupIgnore;
  hrefs.Sorted:= True;

  fInformation.FormInfo:= TFormInfo.Create(Self);
  with FormInfo do begin
    //
    with MemoInfo.Lines do begin
      Clear;

      Add('Source: ' + fs.FileName);
      Add(GetDocTypeDesc(fs.DocType));
      Add(GetStorageTypeDesc(fs.Storage));
      Add('Encoding: ' + wmlc.CharSetCode2Name(cm.Encoding));
      case fs.Storage of
        srFile: begin
            if FindFirst(fs.FileName, faAnyFile, sr) = 0 then begin
              SysUtils.FindClose(sr);
              Add('File created: '+ DateTimeToStr(FileTimeToDateTime(sr.FindData.ftCreationTime)));
              Add('Last accessed: '+ DateTimeToStr(FileTimeToDateTime(sr.FindData.ftLastAccessTime)));
              Add('Last written: '+ DateTimeToStr(FileTimeToDateTime(sr.FindData.ftLastWriteTime)));
            end;
          end;
        srFtp: begin
          end;
        srHttp: begin
          end;
        srDb: begin
          end;
        end; { case of storage type }

      Add(Format('Lines: %d', [cm.Lines.Count]));

      if fs.DocType in [edWML, edWMLTemplate, edWMLCompiled] then begin
        Add('Links: ');

        FWMLCollection.Items[0].GetListHrefs(hrefs);
        MemoInfo.Lines.AddStrings(hrefs);

        errDesc:= TWideStringList.Create;
        compiled:= wmlc.CompileWMLCString(WBXMLVersion, cm.Lines.Text, errDesc);
        compiledlen:= Length(compiled);
        Add(Format('Compiled size (approximately): %d bytes (%xh)', [compiledlen, compiledlen]));
        Add('Compilation messages: ');
        for i:= 0 to errDesc.Count - 1 do begin
          MemoInfo.Lines.Add(errDesc[i]);
        end;
        errDesc.Free;
      end;
    end;
    if ShowModal = mrOk then begin
      //
    end;
  end;
  hrefs.Free;
end;

// Format source text
procedure TFormDockBase.actToolsReformatExecute(Sender: TObject);
var
  fs: TFileStatus;
  cm: TECustomMemo;
  xmlElement: TxmlElement;
  sm: Boolean;
  rm, bi: Integer;
  cs: Boolean;
  ft: TFormatTextSet;
begin
  //
  fs:= GetCurMemoFileStatus;
  if fs.DocType in [edText, edCSS, edHTML]
  then Exit; // do not reformat unsupported files

  cm:= GetCurMemo;

  if (not Assigned(fs)) or (not Assigned(cm))
  then Exit;

  cs:= FParameters.Values[ParameterNames[ID_FormatCompressSpaces]] = '1';
  FormFormatSource:= fAskFormat.TFormFormatSource.Create(Nil);
  with FormFormatSource do begin
    UDRightMargin.Position:= Memos.DefRightMargin;;
    UDBlockIndent.Position:= Memos.BlockIndent;
    L2.Caption:= Format(L2.Caption, [fs.FileName]);
    CBCompressSpaces.Checked:= cs;

    if ShowModal = mrOk // if Dialogs.MessageDlg(Format(MSG_CONFIRMFORMAT, [fs.FileName]), mtInformation, [mbYes, mbNo], 0) = mrYes
    then begin
      if cm.ModifiedSinceLastDelay then begin
        // compile first
        actViewCompileCurrentFileExecute(Self);
      end;

      // get xml element AFTER compiling
      xmlElement:= getContainerByDoctype(fs.DocType);
      if not Assigned(xmlElement)
      then Exit;

      sm:= CBRightMargin.Checked;
      cs:= CBCompressSpaces.Checked;
      rm:= UDRightMargin.Position;
      bi:= UDBlockIndent.Position;
      if sm and (rm <= 0) then rm:= Memos.DefRightMargin;

      if sm
      then customxml.TextRightEdgeCol:= rm
      else customxml.TextRightEdgeCol:= MaxInt;
      if cs then begin
        ft:= [ftCompressSpaces];
        FParameters.Values[ParameterNames[ID_FormatCompressSpaces]]:= '1';
      end else begin
        ft:= [];
        FParameters.Values[ParameterNames[ID_FormatCompressSpaces]]:= '0';        
      end;
      cm.Lines.Text:= xmlElement.CreateText(-bi, ft);
      cm.Modified:= True;
      cm.ModifiedSinceLastDelay:= True;
      // repaint current memo
      cm.Repaint;
      // refresh elements treeview again
      actViewCompileCurrentFileExecute(Self);
    end;
    Free;
  end;
end;

procedure TFormDockBase.actFormatDialogExecute(Sender: TObject);
var
  fmt: String;
begin
  if (not Assigned(CurElement)) or (not (CurElement.ClassType = TWMLInput))
  then Exit;
  FormFormatUserInput:= TFormFormatUserInput.Create(Self);
  with FormFormatUserInput do begin
    CBFormat.Text:= FAttributeInspector.Values['format'];
    if ShowModal = mrOK then begin
      with FAttributeInspector do begin
        fmt:= FormFormatUserInput.CBFormat.Text;
        Values['format']:= fmt;
        ReflectAttributeChange('format', Values['format'], FCurElement, GetCurMemo);
      end;
    end;
  end;
end;

procedure TFormDockBase.actEnterPCDATAExecute(Sender: TObject);
var
  attrn: String;
  ws: WideString;
begin
  if (not Assigned(CurElement))
  then Exit;

  with FAttributeInspector do begin
    if (Selection.Top >= RowCount) or (Selection.Top < 0)
    then Exit;
    attrn:= Keys[Selection.Top];
  end;

  FormEditText:= TFormEditText.Create(Self);
  with FormEditText do begin
    EMemo.Lines.Text:= WMLExtractEntityStr(CurElement.Attributes.ValueByName[attrn], False); // FAttributeInspector.Values[attrn];
    if ShowModal = mrOK then begin
      ws:= EMemo.Lines.Text;
      with FAttributeInspector do begin
        Values[attrn]:= WMLExtractEntityStr(ws);
        ReflectAttributeChange(attrn, ws, FCurElement, GetCurMemo);
      end;
    end;
    Free;
  end;
end;

procedure TFormDockBase.actHelpContentsExecute(Sender: TObject);
var
  p: TPoint;
  CurMemo: TECustomMemo;
  helpIndexStr: String;
  fs: TFileStatus;
begin
  //
  helpIndexStr:= '';
  FillChar(p, SizeOf(p), #0);
  if ActiveControl = TreeViewElements then begin
    if Assigned(FCurElement) then begin
      helpIndexStr:= FCurElement.GetElementName;
      p.x:= 1;
    end;
  end else begin
    if ActiveControl = FAttributeInspector then with FAttributeInspector do begin
      if FAttributeInspector.Row > -1
      then helpIndexStr:= Cells[0, Row];
      p.x:= 2;
    end else begin
      if ActiveControl = ListboxInfo then begin
        if ListboxInfo.ItemIndex >= 0 then begin
          helpIndexStr:= util1.GetToken(1, #32, ListboxInfo.Items[ListboxInfo.ItemIndex]);
          p.x:= 3;
        end;
      end else begin
        CurMemo:= GetCurMemo;
        if Assigned(CurMemo) then begin
          helpIndexStr:= CurMemo.GetWordAtPos(CurMemo.CaretPos_H, CurMemo.CaretPos_V, p.x);
          p.x:= 4;
        end;
      end;
    end;
  end;
  // display help screen
  if Length(helpIndexStr) = 0 then begin
    helpIndexStr:= 'interfaceguide';
    fs:= Nil;
  end else begin
    // get file status from current document
    fs:= GetCurMemoFileStatus;
  end;
  ShowHelpByIndex(p, fs, helpIndexStr);
end;

// search help file and call help API to display topic by index
procedure TFormDockBase.ShowHelpByIndex(Pt: TPoint; AFileStatus: TFileStatus; AKey: String);
var
  Link: THHAKLink;
  helpfn: String;
begin
  helpfn:= util1.ConcatPath(FParameters.Values[ParameterNames[ID_ConfigDir]], DEFHELPFILE, '\');
  if not FileExists(helpfn) then begin
    raise Exception.CreateFmt(MSG_NOHELPFILE, [helpfn]);
  end;
  helpfn:= helpfn + '::/';

  FillChar(Link, SizeOf(Link), 0);
  Link.cbStruct:= SizeOf(Link);
  Link.fReserved:= False;
  if Assigned(AFileStatus) and (pt.x <> 0) then begin
  { it does not works because no 2 keywords assigned to topic such wml, card
    case AFileStatus.DocType of
      edWML, edWMLTemplate, edWMLCompiled: AKey:= 'wml;' + AKey;
      edHTML:;
      edCSS:;
      edOEB: AKey:= 'oeb;' + AKey;
      edPKG: AKey:= 'opf;' + AKey;
    end;
  end;
  }
    // so, just try search topic
    case AFileStatus.DocType of
      edWML, edWMLTemplate, edWMLCompiled: helpfn:= helpfn + 'e' + AKey + '.htm';
      edHTML:;
      edCSS:;
      edOEB: helpfn:= helpfn + HELP_PREFIX_OEB + AKey + '.htm';
      edPKG: helpfn:= helpfn + HELP_PREFIX_PKG + AKey + '.htm';
      edXHTML: helpfn:= helpfn + HELP_PREFIX_XHTML + AKey + '.htm';  // must be 'xh', but help file does not ready
    end;
  end else begin
    helpfn:= helpfn + AKey + '.htm';
  end;

  with Link do begin
    fReserved:= False;
    pszKeywords:= PChar(AKey);
    pszUrl:= Nil;
    pszMsgText:= Nil;
    pszMsgTitle:= nil;
    pszWindow:= Nil; // PChar('Main');
  end;

  // on fault display message box

  {
  Link.fIndexOnFail:= True;
  Link.pszMsgText:= PChar(Format('Topic: %s. No information found.', [Link.pszKeywords]));
  Link.pszMsgTitle:= PChar('Lookup failure');
  }
  // it is no way to display topic because you must provide 2 jeywords. But how?
  //  HtmlHelp(Handle, PChar(helpFn), HH_KEYWORD_LOOKUP, DWORD(@Link));  // HH_ALINK_LOOKUP
  HtmlHelp(Handle, PChar(helpFn), HH_DISPLAY_TOPIC, 0);
end;

procedure TFormDockBase.actFilePrintExecute(Sender: TObject);
begin
  // print current file
  FormPrint:= TFormPrint.Create(Self);
  if FormPrint.ShowModal = mrOk then begin
    //
  end;
  FormPrint.Free;
end;

procedure TFormDockBase.actHelpNagScreenExecute(Sender: TObject);
begin
  // display nag screen
  FormNag:= TFormNag.Create(Self);
  with FormNag do begin
    case ShowModal of
    mrOK:begin
      // register
      if not FRegistered
      then FormDockBase.Close;
    end;
    mrCancel:begin
      FormDockBase.Close;
    end;
    end; { case }
    Free;
  end;
end;

procedure TFormDockBase.actEditInsertSymbolExecute(Sender: TObject);
var
  CurMemo: TECustomMemo;
  c: TWinControl;
  idx: Integer;
  ws: WideString;
begin
  // insert symbol
  FormSpecialSymbol:= TFormSpecialSymbol.Create(Self);
  c:= ActiveControl;
  with FormSpecialSymbol do begin
    // set font
    UsedFontName:= FParameters.Values[ParameterNames[ID_FontName]];  // Memos.FontName;
    // set previously selected block
    idx:= StrToIntDef(FParameters.Values[ParameterNames[ID_SymbolUnicodeBlock]], -1);
    SelectBlock(idx);

    if ShowModal = mrOK then begin
      if Assigned(LVChar.Selected) then begin
        if c = FAttributeInspector then with FAttributeInspector do begin
          if FAttributeInspector.Row < FAttributeInspector.RowCount
          then Exit;
        end else begin
          CurMemo:= GetCurMemo;
          if Pointer(c) = Pointer(CurMemo) then begin
            SetLength(ws, 1);
            Word(ws[1]):= StrToIntDef('$' + LVChar.Selected.Caption, 32);
            CurMemo.InsertTextAtPos(ws, CurMemo.CaretPos_H, CurMemo.CaretPos_V);
          end;
        end;
      end;
    end;
    FParameters.Values[ParameterNames[ID_SymbolUnicodeBlock]]:= IntToStr(LBUnicodeBlock.ItemIndex);
    Free;
  end;
end;

{--- action updates ---}

procedure TFormDockBase.actUpdateFileCanSave(Sender: TObject);
var
  cm: TECustomMemo;
  fs: TFileStatus;
begin
  cm:= GetCurMemo;
  fs:= GetCurMemoFileStatus;
  (Sender as TAction).Enabled:= (Assigned(cm)) and (cm.Modified) and (not (dsIsNew in fs.State));
end;

procedure TFormDockBase.actUpdateWML_WMLC_Opened(Sender: TObject);
var
  b: Boolean;
  fs: TFileStatus;
begin
  //
  fs:= GetCurMemoFileStatus;
  b:= Assigned(fs) and (fs.DocType in [edWML, edWMLTemplate, edWMLCompiled]);
  (Sender as TAction).Enabled:= b;
  (Sender as TAction).Checked:= Assigned(FormByteCode) and FormByteCode.Visible;
end;

procedure TFormDockBase.actSaveAllUpdate(Sender: TObject);
begin
  // enable save all if some files are modified
  (Sender as TAction).Enabled:= Memos.ModifiedCount > 0;
end;

procedure TFormDockBase.actUpdateIsFileOpened(Sender: TObject);
var
  cm: TECustomMemo;
begin
  cm:= GetCurMemo;
  (Sender as TAction).Enabled:= Assigned(cm);
end;

procedure TFormDockBase.actUpdateIsFilePkg(Sender: TObject);
var
  FileStatus: TFileStatus;
begin
  FileStatus:= GetCurMemoFileStatus;
  (Sender as TAction).Enabled:= (FileStatus <> Nil) and (FileStatus.DocType = edPKG);
end;

procedure TFormDockBase.actFileCreatePackageByOEBUpdate(Sender: TObject);
var
  FileStatus: TFileStatus;
begin
  FileStatus:= GetCurMemoFileStatus;
  (Sender as TAction).Enabled:= (FileStatus <> Nil) and (FileStatus.DocType = edOEB);
end;

procedure TFormDockBase.actToolsSpellCheckUpdate(Sender: TObject);
var
  b: Boolean;
  cm: TECustomMemo;
begin
  //
  cm:= GetCurMemo;
  b:= FCanSpell and (Assigned(cm));
  actToolsSpellCheck.Enabled:= b;
end;

procedure TFormDockBase.actViewWindowEditorUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked:= PanelEditor.Visible;
end;

procedure TFormDockBase.actViewWindowElementUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked:= TreeViewElements.Visible;
end;

procedure TFormDockBase.actViewWindowAttributeUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked:= FAttributeInspector.Visible;
end;

procedure TFormDockBase.actViewWindowMessagesUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked:= ListBoxInfo.Visible;
end;

procedure TFormDockBase.actViewWindowProjectUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked:= PanelProject.Visible;
end;

procedure TFormDockBase.actViewByteCodeUpdate(Sender: TObject);
begin
  //
end;

{------------------------------------------------------------------------------}

procedure TFormDockBase.actSaveAllExecute(Sender: TObject);
begin
  // save all. If file is new, provided dialog appears
  Memos.SaveAllModified(actFileSaveAs);
end;

procedure TFormDockBase.actFileCreatePackageByOEBExecute(Sender: TObject);
var
  coll: TxmlElementCollection;
  FileStatus: TFileStatus;
  fn: String;
  Images: TStrings;
  Manifest: TStrings;
  Identifier, Title, Source: WideString;
begin
  FileStatus:= GetCurMemoFileStatus;
  if (FileStatus = Nil) or (FOEBCollection = Nil) or (FileStatus.DocType <> edOEB)
  then Exit;

  Images:= TStringList.Create;
  Manifest:= TStringList.Create;
  Manifest.AddObject(FileStatus.FileName, Nil);
  Identifier:= '--Enter identifier--';
  Title:= '--Enter title--';
  Source:= '--Enter source--';
  fn:= ChangeFileExt(FileStatus.FileName, '');
  //
  // build image list

  BuildImageList(FOEBCollection[0], Images, 1);
  // create package collection
  coll:= CreateDefaultPkgContainer(Identifier, Title,
    FParameters.Values[ParameterNames[ID_USER]],
    FParameters.Values[ParameterNames[ID_USER]], Source, Images[0], Images[0], Images[0], Manifest);
  // create new eBook package
  NewFile(edPKG, fn + '%s' + '.opf', coll[0].CreateText(0, []));
  coll.Free;
  Manifest.Free;
  Images.Free;
end;

procedure TFormDockBase.GenerateLIT(const AFileName: String; ADocType: TEditableDoc; AStorage: TStorageType);
var
  fn: String;
  ofn: String;
begin
  // generate lit from package file

  case ADocType of
    edPkg:;
    edSame, edDefault: if GetDocTypeByFileName(AFileName) <> edPkg then Exit;
    else Exit;
  end;

  fn:= ExpandFileName(AFileName);
  ofn:= ReplaceExt('.lit', fn);
  if FileExists(ofn) then begin
    case  Dialogs.MessageDlg(Format(MSG_REPLACEFILE, [ofn]), mtWarning, [mbYes, mbNo, mbCancel], 0) of
      mrCancel, mrNo: Exit;
      mrYes: begin
          if not DeleteFile(ofn) then begin
            ShowMessage(Format(MSG_DELETEFILE, [ofn]));
            Exit;
          end;
        end;
    end;
  end;
  FormGenerateLIT:= fgenLit.TFormGenerateLIT.Create(Self);
  with FormGenerateLIT do begin
    OnGetXMLByFileNameProc:= GetXMLByFileNameProc;
    LEPackage.Text:= fn;
    LEOutput.Text:= ofn;
    AutoStart:= FParameters.Values[ParameterNames[ID_AutoStartGenLIT]] = '1';
    if ShowModal = mrOK then begin
    end;
    if AutoStart
    then FParameters.Values[ParameterNames[ID_AutoStartGenLIT]]:= '1'
    else FParameters.Values[ParameterNames[ID_AutoStartGenLIT]]:= '0';
    Free;
  end;
end;

procedure TFormDockBase.actFileGenerateLITExecute(Sender: TObject);
var
  idx: Integer;
  fn: String;
begin
  // generate lit from package file
  idx:= TCOpenFiles.TabIndex;
  if idx < 0
  then Exit;
  // is it oeb package
  fn:= Memos.FileStatus[idx].FileName;
  GenerateLIT(fn, Memos.FileStatus[idx].DocType, GetStorageTypeByFileName(fn));
end;

procedure TFormDockBase.CBFilterDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  idx: Integer;      { text offset width }
begin
 if Index >= TComboBox(Control).Items.Count
 then Exit;
  // draw file types CheckListBox
  with TComboBox(Control).Canvas do begin
    // clear the rectangle
    FillRect(Rect);
    // get the bitmap
    idx:= Integer(TComboBox(Control).Items.Objects[Index]);
    if idx >= 0 then begin
      dm.dm1.ImageList16.Draw(TComboBox(Control).Canvas, Rect.Left + 2, Rect.Top,  idx);
    end;
    // add 4 pixels between bitmap and text
    TextOut(Rect.Left + dm.dm1.ImageList16.Width + 6, Rect.Top, TComboBox(Control).Items[Index])  { display the text }
  end;
end;

procedure TFormDockBase.PanelFilterResize(Sender: TObject);
begin
  CBFilter.Width:= PanelFilter.Width - CBFilter.Left - 4;
end;

procedure TFormDockBase.actOptionsADOExecute(Sender: TObject);
begin
  FormADO:= TFormADO.Create(Self);
  with FormADO do begin
    if ShowModal = mrOK then begin
    end;
    Free;
  end;
end;

function TFormDockBase.GetXMLByFileNameProc(const AFileName: String; ADocType: TEditableDoc): TxmlElement;
label
  STP;
var
  fn, s: String;
  hm: HMODULE;
  h: HRSRC;
  g: HGLOBAL;
  p: Pointer;
  len: Cardinal;
  fs: TFileStatus;
  idx: Integer;
  FFile1: TStrings;
  TmpColl: TxmlElementCollection;

  procedure ErrorLoadSrc(const AFmt: String);
  begin
    // DO NOT UNCOMMENT this! It causes program termination
    // because it is called from DLL I mean (anything is ok in IDE) but
    // stop program - no handl or smth
    // raise Exception.CreateFmt(AFmt, [0, AFileName]);
    // ShowMessage(Format(AFmt, [0, AFileName]))
  end;

begin
  Result:= Nil;

  // try to load from resource
  if Pos(litConv.DEF_RES_PREFIX, AFileName) > 0 then begin
    // find resource
    h:= 0;
    hm:= HInstance;
    if Pos(DEF_ABOUT_URL, AFileName) > 0 then begin
      h:= FindResource(hm, 'about', MakeIntResource(23));
      if h = 0 then begin
        ErrorLoadSrc(LITCONV_ERR_RESNOTF_COPYSRC);
        Exit;
      end;

      len:= SizeofResource(hm, h);
      // load resource
      g:= LoadResource(hm, h);
      if (g = 0) or (len = 0) then begin
        ErrorLoadSrc(LITCONV_ERR_RESLOAD_COPYSRC);
        Exit;
      end;
      // lock resource
      p:= LockResource(g);
      // copy resource
      SetLength(s, len);
      Move(p^, s[1], len);
      try
        TmpColl:= EMemos.LoadXMLElement(srString, ADocType, s, Memos.ConvOnLoadOptions);
        if Assigned(TmpColl) and Assigned(TmpColl.Items[0])
        then Result:= TmpColl.Items[0];
      except
        ErrorLoadSrc(LITCONV_ERR_RESCOPY_COPYSRC);
        Exit;
      end;
    end;
    Exit;
  end;

  FFile1:= TStringList.Create;
  FFile1.Add('');

  if Pos('file://', LowerCase(AFileName)) = 1
  then FFile1[0]:= Copy(AFileName, Length('file://') + 1, MaxInt)
  else FFile1[0]:= AFileName;
  idx:= fdockbase.FormDockBase.Memos.IndexOfFileName(FFile1[0]);
  if idx >= 0 then begin
    fdockbase.FormDockBase.OpenFiles(FFile1, ADocType);
    Application.ProcessMessages;
    fs:= fdockbase.FormDockBase.GetCurMemoFileStatus;
    // check is file opened
    if (not Assigned(fs)) or (not SameFileName(fs.FileName, FFile1[0]))
    then goto STP;
    // check is compiled
    if fdockbase.FormDockBase.TreeViewElements.Items.Count <= 0
    then goto STP;
    // return first container element
    Result:= fdockbase.FormDockBase.TreeViewElements.Items[0].Data;
  end;
STP:
  FFile1.Free;
end;

// parse database extension report event
// used by actRefreshPreviewExecute - refresh preview screen if serverside preview enabled

procedure TFormDockBase.OnReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
  const ASrc: PWideChar; ASrcLen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
  var AContinueParse: Boolean; AEnv: Pointer);
begin
  if ALevel = rlFinishThread then begin
    FState:= [];
    FCallBackBuffer:= ASrc;
  end else begin
    ListBoxInfo.Items.AddObject(Format('%s: %s(%d,%d): %s', [ReportLevelStr[ALevel],
      ASrc, AWhere.x + 1, AWhere.y + 1, ADesc]), AxmlElement);
  end;
end;

// refresh preview screen

procedure TFormDockBase.actRefreshPreviewExecute(Sender: TObject);
var
  idx, cnt, cp: Integer;
  DocT: TEditableDoc;
//  mdf: Boolean;
//  url: String;
  strm: TStream;
  // db server extension
  FDBXMLDLLCalls: TDBXMLDLLCalls;
  FDllHandle: THandle; // TFuncFmtDll
  ws, vars: WideString;
  pvars, pcookies: PWideChar;
begin
  idx:= TCOpenFiles.TabIndex;
  if idx < 0
  then Exit;

  {
  //navigate to saved file
  url:= url + Memos.FileStatus[idx].FileName;
  WBPreview.Navigate(url);
  }
  // get source
  with Memos.Memo[idx] do begin
    FCallBackBuffer:= Lines.Text;
    cp:= Encoding;
    DocT:= Memos.FileStatus[idx].DocType;
  end;
  // directly load document to the browser
  if (StrToIntDef(FParameters.Values[ParameterNames[ID_DbDrvEnable]], 0) and 1) > 0  // instead of checking IsIEProtocolRegistered(DEF_AP_PROTOCOLNAME)
  then begin
    // do serverside parsing

    // Load DLL
    {
    if FDllHandle <> 0 then begin
      FDBXMLDLLCalls.FClearThreadCache;
      FreeLibrary(FDllHandle);
    end;
    }
    // in case of loading DB driver directly bypassing wdbxml.dll
    //
    FDllHandle:= dbXMLInt.LoadDBXMLDLLCalls(FParameters.Values[ParameterNames[ID_DbDrvFileName]],
      FParameters.Values[ParameterNames[ID_WORKDIR]], FDBXMLDLLCalls);
    if FDllHandle = 0 then begin
      // can not do serverside parsing
    end else begin
      ws:= 'Connect';
      FDBXMLDLLCalls.FInit(PWideChar(ws), [], Nil);

      // start parse
      vars:= ''; // vars MVars.Lines.CommaText;
      FState:= [esCompiling];
      pvars:= PWideChar(vars);
      pcookies:= Nil;
      FDBXMLDLLCalls.FStartDbXMLParse(DocT, PWideChar(FCallBackBuffer), pvars, pcookies, OnReportEvent,
      [pcParse], Self);

      // wait until
      { TODO: rewrite code in use of TEvent }
      // wdbxml procedure TWebModule1.WebModule1waDefaultAction(
      // FEvent.WaitFor(2 * 60*1000) <> wrSignaled

      cnt:= 0;
      repeat
        sleep(100);
        Inc(cnt);
      until (FState = []);  //  or (cnt >= 10*2*60) do not wait more than 2 minutes
      // done, FCallBackBuffer contain parsed source
      sleep(100);
      FDBXMLDLLCalls.FClearThreadCache;
      FDBXMLDLLCalls.FDone;
      FreeLibrary(FDllHandle);
    end;
  end else begin
    // do not serverside parsing
  end;

  // actually can not show edWMLTemplate, edWMLCompiled because transformation works in files only. I can not pass xml text to the transformer
  if DocT in [edWML, edWMLTemplate, edWMLCompiled, edPKG, edTaxon, edSMIT] then begin
    // translate document
    // ShowMessage(GetXSLTFileName(DocT, edxHTML));
    // util_dom.xmlTransform(Memos.FileStatus[idx].FileName, ConcatPath(FParameters.Values[ParameterNames[ID_CONFIGDIR]], GetXSLTFileName(DocT, edxHTML), '\'), src);
    util_dom.xmlWSTransform(FCallBackBuffer, ConcatPath(FParameters.Values[ParameterNames[ID_CONFIGDIR]], GetXSLTFileName(DocT, edxHTML), '\'), FCallBackBuffer);
  end;

  // load [dbParsed] source into [utf-8] stream
  strm:= TStringStream.Create(WideString2EncodedString(convPCDATA, cp, FCallBackBuffer, []));

  // on startup document is not loaded
  if WBPreview.Document = Nil
  then WBPreview.Navigate('about:hi');

  // load stream to the document
  util_dom.LoadStream2Browser(strm, WBPreview);
  // ShowMessage((WBPreview.Document as msxml.IXMLDocument).charset); //:= 'utf-8'; -- does not works

  strm.Free;
  with Memos.Memo[idx] do if CanFocus then SetFocus;
end;

procedure TFormDockBase.actRefreshConstructionFormExecute(Sender: TObject);
var
  fs: TFileStatus;
  cm: TECustomMemo;
  xmlElement: TxmlElement;
begin
  //
  fs:= GetCurMemoFileStatus;

  with PanelForm do begin
    // clear up panel
    Visible:= False;
    DestroyComponents;
  end;

  if fs.DocType in [edText, edCSS, edHTML]
  then Exit; // do not show unsupported files

  cm:= GetCurMemo;

  if (not Assigned(fs)) or (not Assigned(cm))
  then Exit;
  xmlElement:= getContainerByDoctype(fs.DocType);
  if not Assigned(xmlElement)
  then Exit;

  // draw
  xmlParse.AddxmlElement2Panel(xmlElement, PanelForm,
    dm.dm1.ImageList16, OnElementChange, OnSelectElementClick, ToolButtonNewClick);
end;

procedure TFormDockBase.PageControlEditorsChanging(Sender: TObject;
  var AllowChange: Boolean);
var
  idx: Integer;
//  mdf: Boolean;
//  url: String;
begin
  AllowChange:= False;
  idx:= TCOpenFiles.TabIndex;
  if (idx < 0) // or (Memos.FileStatus[idx].Storage <> srFile) -- commented Oct 12 2003
  then Exit;
  if ((Sender as TPageControl).ActivePage = TSCode) then begin
    // can not show edWMLTemplate, edWMLCompiled because transformation works in files only. I can not pass xml text to the transformer
    AllowChange:= Memos.FileStatus[idx].DocType in [edWML, edPKG, edTaxon, edSMIT, edOEB, edHTML, edXHTML];
  end else AllowChange:= True;
end;

procedure TFormDockBase.PageControlEditorsChange(Sender: TObject);
begin
  case (Sender as TPageControl).TabIndex of
  1: actRefreshPreviewExecute(Self);  // preview
  2: actRefreshConstructionFormExecute(Self);  // construction form
  end;
end;

procedure TFormDockBase.actClearMessagesExecute(Sender: TObject);
var
  i: Integer;
begin
  i:= 0;
  with ListBoxInfo do begin
    // disable listview redraws
    Perform(WM_SETREDRAW, 0, 0);
    Items.BeginUpdate;
    while i < Count do begin
      if Pos(ReportLevelStr[rlSearch], Items[i]) <> 1 then begin
        ListBoxInfo.Items.Delete(i);
        Continue;
      end;
      Inc(i);
    end;
    // enable listview redraws
    Items.EndUpdate;
    Perform(WM_SETREDRAW, 1, 0);
  end;
end;

procedure TFormDockBase.actClearSearchExecute(Sender: TObject);
var
  i: Integer;
begin
  i:= 0;
  with ListBoxInfo do begin
    // disable listview redraws
    Perform(WM_SETREDRAW, 0, 0);
    Items.BeginUpdate;

    while i < Count do begin
      if Pos(ReportLevelStr[rlSearch], Items[i]) > 0 then begin
        ListBoxInfo.Items.Delete(i);
        Continue;
      end;
      Inc(i);
    end;
    // enable listview redraws
    Items.EndUpdate;
    Perform(WM_SETREDRAW, 1, 0);
  end;
end;

// create an instance of spell engine if needed
function TFormDockBase.CheckSpellEngine: Boolean;
begin
  Result:= False;
  if not FCanSpell
  then Exit;
  Result:= Assigned(FMSOSpellChecker);
  if not Result
  then FMSOSpellChecker:= TMSOSpellChecker.Create(Self);  // Self indicates that form destroing checker
  Result:= Assigned(FMSOSpellChecker);
end;

procedure TFormDockBase.actToolsSpellCheckExecute(Sender: TObject);
var
  ws: WideString;
  CurMemo: TECustomMemo;
  c, g: Boolean;
begin
  //
  if CheckSpellEngine then begin
    ws:= '';
    if ActiveControl = TreeViewElements then begin
      if Assigned(FCurElement)
      then ws:= FCurElement.Attributes.ValueByName['value'];
    end else begin
      if ActiveControl = FAttributeInspector then with FAttributeInspector do begin
        ws:= Cells[1, Row];
      end else begin
        CurMemo:= GetCurMemo;
        if Assigned(CurMemo) then begin
          if CurMemo.Selected
          then ws:= CurMemo.GetSelText
          else ws:= CurMemo.Lines[CurMemo.CaretPos_V];
        end;
      end;
    end;

    if Length(ws) = 0
    then Exit;

    c:= FMSOSpellChecker.CheckSpelling(ws);
    if c
    then ws:= FMSOSpellChecker.ChangedText;
    g:= FMSOSpellChecker.CheckGrammar(ws);
    if g
    then ws:= FMSOSpellChecker.ChangedText;
    if c or g then begin
      ws:= HTMLExtractEntityStr(ws);

      if ActiveControl = TreeViewElements then begin
        if (FCurElement.Attributes.IndexOf('value') >= 0)
        then FCurElement.Attributes.ValueByName['value']:= ws;
      end else begin
        if ActiveControl = FAttributeInspector then with FAttributeInspector do begin
          Cells[1, Row]:= ws;
        end else begin
          CurMemo.DeleteSelection;
          CurMemo.InsertText(ws);
        end;
      end;
    end;
  end;
end;

procedure TFormDockBase.actOptionsSpellingExecute(Sender: TObject);
begin
  //
  if CheckSpellEngine then begin
    FMSOSpellChecker.DialogSpellingOptions;
  end;
end;

procedure TFormDockBase.actViewByteCodeExecute(Sender: TObject);
begin
  //
  if Assigned(FormByteCode) then with FormByteCode do begin
    if Visible then begin
      Close;
      Free;
      FormByteCode:= Nil;
    end else begin
      Visible:= True;
      BringToFront;
    end;
  end else begin
    FormByteCode:= TFormByteCode.Create(Nil);
    with FormByteCode do begin
      // if (CurFileStatus.DocType in [edWML, edWMLTemplate, edWMLCompiled]) then begin
      SyncViewXML(FWMLCollection);
      Show;
    end;
  end;
end;

procedure TFormDockBase.ShowSysCtxMenu(APosition: TPoint);
var
  node: TTreeNode;
  {
  CurMemo: TECustomMemo;
  CurFileStatus: TFileStatus;
  }
begin
  // get tree node
  node:= FolderTree1.Selected;
  if not Assigned(node)
  then Exit;
  DisplayContextMenu(Handle, TFolderNode(Node.Data^).FN_Path, Mouse.CursorPos);
  {
  CurFileStatus:= GetCurMemoFileStatus;
  CurMemo:= GetCurMemo;
  if (not Assigned(CurMemo)) or (not Assigned(CurFileStatus))
  then Exit;

  if FileExists(CurFileStatus.FileName) then begin
    DisplayContextMenu(Handle, CurFileStatus.FileName, Mouse.CursorPos);
  end;
  }
  // refresh tree view
  RefreshFolderViews(FolderTree1.FileMask);
end;

procedure TFormDockBase.PCProjectChanging(Sender: TObject;
  var AllowChange: Boolean);
var
  path: String;
  node: TTreeNode;
begin
  if ((Sender as TPageControl).ActivePage = TSFiles) then begin
    AllowChange:= False;
    node:= GetCurrentParentNode;
    path:= TFolderNode(Node.Data^).FN_Path;
    // show current folder name
    LCurrentFolder.Caption:= Format('Folder: %s', [FileCtrl.MinimizeName(path, Canvas, 128)]);

    // fill out LVDocuments
    RebuildDocumentListView(node, GetDocTypeByFilter(CBFilter.ItemIndex + 1),
      dm.Dm1.OnGetStorageFile, LVDocuments);

    // if anything is ok, allow to view
    AllowChange:= True;
  end else begin
    // clear virtual listview cache
    SetLength(FormDockBase.FDocListViewCache, 0);
    AllowChange:= True;
  end;
end;

{ open files from document list view
}
procedure TFormDockBase.LVDocumentsDblClick(Sender: TObject);
var
  FNs: TStrings;
  node: TTreeNode;
  idx: Integer;
begin
  // do not open entire folder files
  // ldap - how to know is it expandable node
  idx:= LVDocuments.ItemIndex;
  if idx < 0
  then Exit;
  node:= TTreeNode(LVDocuments.Items[idx].Data);
  if Assigned(node) then begin
    if (TFolderNode(Node.Data^).FN_NodeType = ntFolder) and (TFolderNode(Node.Data^).FN_Type <> ftLdapNode)
    then Exit;
    FNs:= TStringList.Create;
    FNs.AddObject(TFolderNode(Node.Data^).FN_Path, Nil);
    OpenFiles(FNs, GetDocTypeByFilter(CBFilter.ItemIndex + 1));
    FNs.Free;
  end else begin
    FNs:= TStringList.Create;
    FNs.AddObject(LVDocuments.Items[idx].Caption, Nil);
    OpenFiles(FNs, GetDocTypeByFilter(CBFilter.ItemIndex + 1));
    FNs.Free;
  end;
end;

procedure TFormDockBase.actFileSysCtxMenuExecute(Sender: TObject);
begin
  ShowSysCtxMenu(Mouse.CursorPos);
end;

procedure TFormDockBase.actHelpCreateDTDExecute(Sender: TObject);
var
  s: String;
  l: String;
begin
  l:= '';
  s:= s + #13#10#13#10'<!-- RTC -->'#13#10#13#10;
  s:= s + TrtcContainer(FxRTCCollection[0]).CreateDTD(FxRTCCollection[0], l);

  l:= '';
  s:= s + #13#10#13#10'<!-- HHC -->'#13#10#13#10;
  s:= s + ThhcContainer(FxHHCCollection[0]).CreateDTD(FxHHCCollection[0], l);

  l:= '';
  s:= s + #13#10#13#10'<!-- HHK -->'#13#10#13#10;
  s:= s + ThhkContainer(FxHHKCollection[0]).CreateDTD(FxHHKCollection[0], l);

  l:= '';
  s:= s + #13#10#13#10'<!-- SMIT -->'#13#10#13#10;
  s:= s + TSmtContainer(FSmitCollection[0]).CreateDTD(FSmitCollection[0], l);

  l:= '';
  s:= s + #13#10#13#10'<!-- Taxon -->'#13#10#13#10;
  s:= s + TTxnContainer(FTaxonCollection[0]).CreateDTD(FTaxonCollection[0], l);

  l:= '';
  s:= s + #13#10#13#10'<!-- xHTML -->'#13#10#13#10;
  s:= s + THTMContainer(FxHTMLCollection[0]).CreateDTD(FxHTMLCollection[0], l);    // collection of oeb package elements. First element is TPkgContainer

  l:= '';
  s:= s + #13#10#13#10'<!-- OEB -->'#13#10#13#10;
  s:= s + TOebContainer(FOebCollection[0]).CreateDTD(FOebCollection[0], l);

  l:= '';
  s:= s + #13#10#13#10'<!-- OPF -->'#13#10#13#10;
  s:= s + TPkgContainer(FPkgCollection[0]).CreateDTD(FPkgCollection[0], l);

  l:= '';
  s:= s + #13#10#13#10'<!-- WML -->'#13#10#13#10;
  s:= s + TWmlContainer(FWMLCollection[0]).CreateDTD(FWMLCollection[0], l);    // collection of oeb package elements. First element is TPkgContainer

  ClipBoard.AsText:= s;
end;

// called from document panel
procedure TFormDockBase.OnElementChange(ANewElement: TxmlElement);
begin
  if CurElement <> ANewElement
  then CurElement:= ANewElement;
end;

procedure TFormDockBase.OnSelectElementClick(Sender: TObject);  // create nested new element
begin
  OnElementChange(TxmlElement(TComponent(Sender).Tag));
end;

procedure TFormDockBase.actXPathQueryExecute(Sender: TObject);
var
  cm: TECustomMemo;
  fs: TFileStatus;
  fopt: TGsFindOptions;
  searchingtext: WideString;
  m, count: Integer;
  R: TStrings;
  fn: String;
begin
  // find text
  fs:= GetCurMemoFileStatus;
  cm:= GetCurMemo;
  if (not Assigned(fs)) or (not Assigned(cm))
  then Exit;

  // Dialogs.MessageDlg(Format(MSG_NOFEATURE, ['Find Text']), mtInformation, [mbCancel], 0);
  fopt:= FSearchContext.LastFindOptions;

  FXPath.FormXPath:= TFormXPath.Create(Self);
  with FXPath.FormXPath do begin
    Text2Search:= FSearchContext.LastSearchText;
    CBText.Items.Assign(FSearchContext.LastSearches);
    CBDirRecurse.Checked:= FSearchContext.DirRecurse;

    if foDirCreateDescFile in fopt then CBDirPerform.ItemIndex:= 1
    else if foDirCreateIdxFile in fopt then CBDirPerform.ItemIndex:= 2
    else if foDirExecProgram in fopt then begin CBDirPerform.ItemIndex:= 3; CBDirPerformChange(Self); end
    else CBDirPerform.ItemIndex:= 0;

    // check is current file opened is ordinal file
    if fs.Storage <> srFile then begin
      // remove search in directory options
      if RGWhere.Items.Count >= 3
      then RGWhere.Items.Delete(2);
      CBDir.Text:= FolderTree1.Directory;
    end else begin;
      // set directory to find
      CBDir.Text:= ExtractFilePath(fs.FileName);
      // set file filter
      CBFilter.ItemIndex:= Self.CBFilter.ItemIndex;
    end;

    RGWhere.ItemIndex:= FSearchContext.Where;

    CBProgram.Text:= FParameters.Values[ParameterNames[ID_SrchDirExecExternal]];

    if ShowModal = mrOK then begin
      searchingtext:= Text2Search;
      fopt:= [];
      FSearchContext.DirRecurse:= CBDirRecurse.Checked;

      case CBDirPerform.ItemIndex of
      1: Include(fopt, foDirCreateDescFile);
      2: Include(fopt, foDirCreateIdxFile);
      3: Include(fopt, foDirExecProgram);
      end;

      case RGWhere.ItemIndex of
      0:begin
          // search in current file
          if not cm.FindText(searchingtext, fopt) then begin
            Dialogs.MessageDlg(Format(MSG_TEXTNOTFOUND, [searchingtext]), mtInformation, [mbCancel], 0);
          end;
        end;
      1:begin
          // search in all open files
          fSearching.FormSearching:= TFormSearching.Create(Nil);
          FormSearching.Show;
          count:= 0;
          actClearSearchExecute(Self);

          Exclude(fopt, foBackward);
          Include(fopt, foGlobalScope);
          Include(fopt, foOriginFromCursor);
          for m:= 0 to Memos.Size - 1 do begin
            cm:= Memos.Memo[m];
            fs:= Memos.FileStatus[m];
            cm.CaretPos_V:= 0;
            cm.CaretPos_H:= 1;
            while cm.FindText(searchingtext, fopt) do begin
              Inc(Count);
              ListBoxInfo.Items.AddObject(Format('%s: %s(%d,%d): %s', [ReportLevelStr[rlSearch],
                fs.FileName, cm.CaretPos_V + 1, cm.CaretPos_H + 1, Trim(cm.Lines[cm.CaretPos_V])]), Nil);
            end;
          end;
          FormSearching.Free;
          FormSearching:= Nil;
        end;
      2:begin
          // search in directory (and subdirectories)
          fSearching.FormSearching:= TFormSearching.Create(Nil);
          FormSearching.Show;
          // search in directory
          actClearSearchExecute(Self);
          FSearchContext.LastSearchText:= searchingtext;
          count:= 0;

          Exclude(fopt, foBackward);
          Include(fopt, foGlobalScope);
          Exclude(fopt, foOriginFromCursor);
          cm.CaretPos_V:= 0;
          cm.CaretPos_H:= 1;

          // set root directory
          FSearchContext.LastInitDir:= CBDir.Text;

          // set count to 0
          FSearchContext.Count:= 0;

          // build extensions list
          R:= TStringList.Create;
          util_xml.GetStringsFromFileFilter(CBFilter.Text, 3, R);

          // special action preparations
          if (foDirCreateDescFile in fopt) or (foDirCreateIdxFile in fopt) then begin
            fn:= ConcatPath(FormDockBase.FSearchContext.LastInitDir, SRCH_DIR_DESC_FILE, '\');
            // delete description file if allready exists
            if FileExists(fn)
            then DeleteFile(fn);
            // store first line with description of files structure if applicable
            // for each file extension mask
            // first string must be started with space (for sort purposes)
            util1.String2File(fn, #32 + GetDocTypeDesc(getDoctypeByContainerClass(GetClassByBitmapIndex(Integer(CBFilter.Items.Objects[CBFilter.ItemIndex])))) +
              ',' + DateTimeToStr(Now) + ',');
            for m:= 0 to R.Count - 1 do begin
              util1.String2File(fn, R[m] + ',');
            end;
            util1.String2File(fn, 'search:' + searchingtext + #13#10);
          end;
          if (foDirExecProgram in fopt) then begin
            FParameters.Values[ParameterNames[ID_SrchDirExecExternal]]:= CBProgram.Text;
            // ask for external program name and options
          end;

          // for each file extension mask
          for m:= 0 to R.Count - 1 do begin
            util1.Walk_Tree(R[m], CBDir.Text, 0, FSearchContext.DirRecurse, WalkFolder_Search, TObject(@fopt));
          end;
          R.Free;

          if (foDirCreateDescFile in fopt) then begin
            // sort descript.ion file
            // util1.SortFile(fn, 1);
          end;

          FormSearching.Free;
          FormSearching:= Nil;
        end;
      end; { case }
      // update search context
      FSearchContext.AddOperation(srchSearch, searchingtext, '', RGWhere.ItemIndex, FSearchContext.DirRecurse, fopt);
    end;
    Free;
  end;
end;

procedure TFormDockBase.BuildDocIndex(const AFileFolderName, AListFileName: String);
begin
  fbuildxmlidx.FormCreateIndexFile:= TFormCreateIndexFile.Create(Nil);
  with FormCreateIndexFile do begin
    RootFolder:= AFileFolderName;
    ListFile:= AListFileName;
    util_xml.GetStringsFromFileFilter(CBFilter.Text, 2, Extensions);
    if ShowModal = mrOk then;
    Free;
  end;
end;

procedure TFormDockBase.actBuildDocIndexExecute(Sender: TObject);
var
  node: TTreeNode;
  p, fn: String;
begin
  fn:= SRCH_DIR_DESC_FILE;
  node:= GetCurrentParentNode;
  if Assigned(Node) then p:= TFolderNode(Node.Data^).FN_Path
  else p:= GetCurrentDir;
  BuildDocIndex(p, fn);
end;

procedure TFormDockBase.actApplyDocFilterExecute(Sender: TObject);
var
  invSrch: TInvSearch;
  r: Integer;
  path: String;
  node: TTreeNode;
begin
  //
  LVDocuments.OwnerData:= False;
  LVDocuments.Clear;

  node:= GetCurrentParentNode;
  if not Assigned(node)
  then Exit;
  path:= TFolderNode(Node.Data^).FN_Path;

  invSrch:= TInvSearch.Create(nil);
  with invSrch do begin

    LoadIndex(ConcatPath(path, 'idx', '\'));
    
    WordsAllFields:= EFilterDoc.Text;
    Search;
    for r:= 0 to FoundCount - 1 do begin
      LVDocuments.Items.Add.Caption:= ConcatPath(path, Urls[r], '\');
    end;
    Free;
  end;
end;

procedure TFormDockBase.EFilterDocKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN
  then BFilterDoc.Click;
end;

procedure TFormDockBase.PanelDocumentsFolderResize(Sender: TObject);
var
  w, l: Integer;
begin
  //
  w:= PanelDocumentsFolder.Width;
  l:= w - BBuildFilter.Width - 2;
  if l < 0
  then l:= 0;
  BBuildFilter.Left:= l;
  l:= l - BFilterDoc.Width - 2;
  if l < 0
  then l:= 0;
  BFilterDoc.Left:= l;
  EFilterDoc.Width:= l - EFilterDoc.Left - 2;
end;

procedure TFormDockBase.debug_ViewElementPositionExecute(Sender: TObject);
var
  i: Integer;
  e: TxmlElement;
begin
  //
  with TreeViewElements do begin
    for i:= 0 to Items.Count - 1 do begin
      e:= TxmlElement(Items[i].Data);
      Items[i].Text:= Format('%d %s [%d - %d]', [Items[i].AbsoluteIndex, e.GetElementName,
        e.DrawProperties.TagXYStart.X + 1,
        e.DrawProperties.TagXYTerminatorStart.X + 1]);
    end;
  end;
end;

procedure TFormDockBase.MenuRecentFileClick(Sender: TObject);
var
  S: String;
  FNs: TStrings;
begin
  // call recent file
  FNs:= TStringList.Create;
  S:= TMenuItem(Sender).Caption;
  if Length(S) < 3
  then Exit;
  Delete(S, 1, 3);
  FNs.AddObject(s, Nil);
  OpenFiles(FNs, edDefault);

  s:= ExtractFilePath(s);
  if DirectoryExists(s)
  then FolderTree1.Directory:= s;
  
  FNs.Free;
end;

// Build phrases

procedure TFormDockBase.actBuildPhrasesListExecute(Sender: TObject);
var
  node: TTreeNode;
begin
  node:= GetCurrentParentNode;
  fbuildxmlphrases.FormCreatePhrases:= TFormCreatePhrases.Create(Nil);
  with FormCreatePhrases do begin
    if Assigned(Node)
    then RootFolder:= TFolderNode(Node.Data^).FN_Path;
    util_xml.GetStringsFromFileFilter(CBFilter.Text, 2, Extensions);
    if ShowModal = mrOk then;
    Free;
  end;
end;

// Phrases manager

procedure TFormDockBase.actPhrasesManagerExecute(Sender: TObject);
begin
  //
  ShowMessage(MSG_NOT_IMPLEMENTED);
end;

procedure TFormDockBase.actFileNewAsCurrentExecute(Sender: TObject);
var
  CurMemo: TECustomMemo;
  CurMemoFileStatus: TFileStatus;
  doct: TEditableDoc;
  dsc: TxmlClassDesc;
begin
  CurMemo:= GetCurMemo;
  CurMemoFileStatus:= GetCurMemoFileStatus;
  if (not Assigned(CurMemo)) or (not Assigned(CurMemoFileStatus))
  then Exit;
  doct:= CurMemoFileStatus.DocType;
  if not GetxmlClassDescByDoc(doct, dsc)
  then Exit;
  // create new document
  NewFile(doct, 'new_' + dsc.defaultextension + '%s.' + dsc.defaultextension,
    curMemo.Lines.Text);
end;

procedure TFormDockBase.actFileRecentFilesExecute(Sender: TObject);
begin
  //
  pmRecentFiles.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TFormDockBase.actEditUndoExecute(Sender: TObject);
var
  cm: TECustomMemo;
begin
  cm:= GetCurMemo;
  if not Assigned(cm)
  then Exit;
  cm.Undo;
end;

procedure TFormDockBase.actEditRedoExecute(Sender: TObject);
var
  cm: TECustomMemo;
begin
  cm:= GetCurMemo;
  if not Assigned(cm)
  then Exit;
  cm.Redo;
end;

procedure TFormDockBase.actEditUndoUpdate(Sender: TObject);
var
  cm: TECustomMemo;
begin
  cm:= GetCurMemo;
  (Sender as TAction).Enabled:= Assigned(cm) and (cm.UndoRedoMgr.CanUndo);
end;

procedure TFormDockBase.actEditRedoUpdate(Sender: TObject);
var
  cm: TECustomMemo;
begin
  cm:= GetCurMemo;
  (Sender as TAction).Enabled:= Assigned(cm) and (cm.UndoRedoMgr.CanRedo);
end;

procedure TFormDockBase.WMDropFiles(var Msg: TWMDropFiles);
var
  i,
  nCount: Integer;
  acFileName: array [0..MAX_PATH] of Char;
  fl: TStrings;
begin
  try
    nCount:= DragQueryFile(Msg.Drop, $FFFFFFFF, acFileName, MAX_PATH);
    // query Windows one at a time for the file name
    fl:= TStringList.Create;
    for i:= 0 to nCount-1 do begin
      DragQueryFile(Msg.Drop, i, acFileName, MAX_PATH);
      // do your thing with the acFileName
      fl.Add(acFileName);
    end;
    Self.OpenFiles(fl);
    fl.Free;
  finally
    // let Windows know that you're done
    DragFinish(msg.Drop );
  end;
end;

end.
