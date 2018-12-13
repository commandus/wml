unit fmain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdActns, XPStyleActnCtrls, ActnMan, ComCtrls,
  ActnCtrls, ActnMenus, ToolWin, ExtCtrls,
  Builder;

type
  TFormMain = class(TForm)
    PanelAds: TPanel;
    CoolBar1: TCoolBar;
    ActionMainMenuBar1: TActionMainMenuBar;
    ActionToolBar1: TActionToolBar;
    PageScroller1: TPageScroller;
    ToolBarElements: TToolBar;
    TBSep1: TToolButton;
    TBHelp: TToolButton;
    TBSep2: TToolButton;
    TBOpen: TToolButton;
    ActionManager1: TActionManager;
    actFileNewDeck: TAction;
    actFileNewXHTML: TAction;
    actFileNewOEB: TAction;
    actFileNewSmit: TAction;
    actFileNewPKG: TAction;
    actFileCreatePackageByOEB: TAction;
    actFileNewFromTemplate: TAction;
    actFileOpen: TFileOpen;
    actFileSave: TAction;
    actFileSaveAs: TFileSaveAs;
    actSaveAll: TAction;
    actFileClose: TAction;
    actFileExit: TFileExit;
    actEditSelectAll: TAction;
    actEditCut: TEditCut;
    actEditCopy: TEditCopy;
    actEditPaste: TEditPaste;
    actViewCompileCurrentFile: TAction;
    actStoreCode: TAction;
    actValidateCode: TAction;
    actHelpAbout: TAction;
    actHelpContents: TAction;
    actTagInfo: TAction;
    actHelpHowToRegister: TAction;
    actHelpEnterCode: TAction;
    actHelpGetCode: TAction;
    actViewEditorOnly: TAction;
    actViewWindowEditor: TAction;
    actViewWindowElement: TAction;
    actViewWindowAttribute: TAction;
    actViewWindowMessages: TAction;
    actViewWindowProject: TAction;
    actViewByteCode: TAction;
    actViewWindowAllowDock: TAction;
    actOptionsFileAssociate: TAction;
    actParseCommandLine: TAction;
    actOptionsEditor: TAction;
    actOptionsSettings: TAction;
    actOptionsLoadDesktopConfiguration: TAction;
    actOptionsSaveDesktopConfiguration: TAction;
    actUpdateMenus: TAction;
    actEditDeleteCurrentElement: TAction;
    actRestoreDefaultWindow: TAction;
    actEditFind: TAction;
    actEditFindNext: TAction;
    actEditReplace: TAction;
    actFTPEdit: TAction;
    actToolsWBMPConvertor: TAction;
    actInsertImage: TAction;
    actImageSaveAsWBMP: TFileSaveAs;
    actXPathQuery: TAction;
    actEditMoveElementUp: TAction;
    actEditMoveElementDown: TAction;
    actViewInfo: TAction;
    actToolsReformat: TAction;
    actFormatDialog: TAction;
    actFilePrint: TAction;
    actHelpNagScreen: TAction;
    actEditInsertSymbol: TAction;
    actFileGenerateLIT: TAction;
    actEnterPCDATA: TAction;
    actFolderTreeGenerateLIT: TAction;
    actOptionsADO: TAction;
    actRefreshPreview: TAction;
    actClearMessages: TAction;
    actClearSearch: TAction;
    actToolsSpellCheck: TAction;
    actOptionsSpelling: TAction;
    actFileSysCtxMenu: TAction;
    actFileNewTaxon: TAction;
    actHelpCreateDTD: TAction;
    actRefreshConstructionForm: TAction;
    actBuildDocIndex: TAction;
    actApplyDocFilter: TAction;
    actBuildPhrasesList: TAction;
    actPhrasesManager: TAction;
    actFileNewAsCurrent: TAction;
    actFileRecentFiles: TAction;
    actEditUndo: TAction;
    actEditRedo: TAction;
    PanelLeft: TPanel;
    Splitter1: TSplitter;
    PanelConstruction: TPanel;
    StatusBar1: TStatusBar;
    PageScrollerConstructor: TPageScroller;
    Shape1: TShape;
    Shape2: TShape;
    procedure Shape1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FBuilder: TBuilder;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.Shape1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ssLeft in Shift then begin
    FBuilder.MouseMoveCurrentElement(X, Y);
  end;
end;

procedure TFormMain.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FBuilder.SelectElement(Sender);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FBuilder:= TBuilder.Create(PageScrollerConstructor);
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FBuilder.Free;
end;

end.
