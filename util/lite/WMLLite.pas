{ Based on code of HTMLLITE.PAS, 1995-2006 by L. David Baldwin
}
unit
  WMLLite;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls, StdCtrls,
  Forms, Dialogs, ExtCtrls, Clipbrd,
  LiteUn2, LitePars, LiteSubs, Menus, GDIPL2;

const
  wm_FormSubmit = wm_User + 100;
  wm_MouseScroll = wm_User + 102;

type
  THTMLBorderStyle = (htFocused, htNone, htSingle);
  TRightClickParameters = class(TObject)
    URL, Target: string;
    Image: TImageObj;
    ImageX, ImageY: integer;
    ClickWord: string;
  end;
  TRightClickEvent = procedure(Sender: TObject; Parameters: TRightClickParameters) of object;
  THotSpotEvent = procedure(Sender: TObject; const SRC: string) of object;
  THotSpotClickEvent = procedure(Sender: TObject; const SRC: string;
    var Handled: boolean) of object;
  TProcessingEvent = procedure(Sender: TObject; ProcessingOn: boolean) of object;
  TImageClickEvent = procedure(Sender, Obj: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer) of object;
  TImageOverEvent = procedure(Sender, Obj: TObject; Shift: TShiftState;
    X, Y: Integer) of object;
  TMetaRefreshType = procedure(Sender: TObject; Delay: integer; const URL: string) of object;

  htOptionEnum = (htOverLinksActive, htNoLinkUnderline, htShowDummyCaret, htShowVScroll);
  ThtmlViewerOptions = set of htOptionEnum;

  TWMLLite = class;

  TPaintPanel = class(TCustomPanel)
  private
    FOnPaint: TNotifyEvent;
    FViewer: TWMLLite;
    Canvas2: TCanvas;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_EraseBkgnd;
    procedure WMLButtonDblClk(var Message: TWMMouse); message WM_LButtonDblClk;
    procedure DoBackground(ACanvas: TCanvas; WmErase: boolean);
    constructor CreateIt(AOwner: TComponent; Viewer: TWMLLite);
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  public
    procedure Paint; override;
  end;

  T32ScrollBar = class(TScrollBar) {a 32 bit scrollbar}
  private
    FPosition: integer;
    FMin, FMax, FPage: integer;
    procedure SetPosition(Value: integer);
    procedure SetMin(Value: Integer);
    procedure SetMax(Value: Integer);
    procedure CNVScroll(var Message: TWMVScroll); message CN_VSCROLL;
  public
    property Position: integer read FPosition write SetPosition;
    property Min: integer read FMin write SetMin;
    property Max: integer read FMax write SetMax;
    procedure SetParams(APosition, APage, AMin, AMax: Integer);
  end;

  ThtmlFileType = (HTMLType, TextType, ImgType, OtherType);

  TWMLLite = class(TWinControl)
  private
    InCreate: boolean;
    procedure ParseStr(const S: string; ft: ThtmlFileType);
  protected
    hlParser: ThlParser;
    FOnDragDrop: TDragDropEvent;
    FOnDragOver: TDragOverEvent;
    function GetDragDrop: TDragDropEvent;
    function GetDragOver: TDragOverEvent;
    procedure SetDragDrop(const Value: TDragDropEvent);
    procedure SetDragOver(const Value: TDragOverEvent);
    procedure HTMLDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure HTMLDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  protected
    { Private declarations }
    DontDraw: boolean;
    FTitle: string;
    FURL: string;
    FTarget: string;
    FBase, FBaseEx: string;
    FBaseTarget: string;
    FCurrentFile: string;
    FNameList: TStringList;
    FCurrentFileType: ThtmlFileType;
    FOnHotSpotCovered: THotSpotEvent;
    FOnHotSpotClick: THotSpotClickEvent;
    FOnImageRequest: TGetImageEvent;
    FOnScript: TScriptEvent;
    FOnFormSubmit: TFormSubmitEvent;
    FOnHistoryChange: TNotifyEvent;
    FOnProcessing: TProcessingEvent;
    FOnInclude: TIncludeType;
    FOnSoundRequest: TSoundType;
    FOnMeta: TMetaType;
    FOnMetaRefresh: TMetaRefreshType;
    FRefreshURL: string;
    FRefreshDelay: Integer;
    FOnRightClick: TRightClickEvent;
    FOnImageClick: TImageClickEvent;
    FOnImageOver: TImageOverEvent;
    FOnObjectClick: TObjectClickEvent;
    FHistory, FTitleHistory: TStrings;
    FPositionHistory: TFreeList;
    FHistoryIndex: integer;
    FHistoryMaxCount: integer;
    FFontName: string;
    FPreFontName: string;
    FFontColor: TColor;
    FHotSpotColor, FVisitedColor, FOverColor: TColor;
    FVisitedMaxCount: integer;
    FBackGround: TColor;
    FFontSize: integer;
    FProcessing: boolean;
    FAction, FFormTarget, FEncType, FMethod: string;
    FStringList: TStringList;
    FImageCacheCount: integer;
    FNoSelect: boolean;
    FScrollBars: TScrollStyle;
    FBorderStyle: THTMLBorderStyle;
    FCaretPos: integer;
    FOptions: ThtmlViewerOptions;
    sbWidth: integer;
    ScrollWidth: integer;
    MaxVertical: integer;
    MouseScrolling: boolean;
    LeftButtonDown: boolean;
    MiddleScrollOn: boolean;
    MiddleY: integer;
    Hiliting: boolean;
{$IFDEF ver100_plus} {Delphi 3,4,5, C++Builder 3, 4}
    FCharset: TFontCharset;
{$ENDIF}
    FPage: integer;
    FOnMouseDouble: TMouseEvent;
    HotSpotAction: boolean;
    FMarginHeight, FMarginWidth: integer;
    FServerRoot: string;
    FSectionList: TSectionList;
    FImageStream: TMemoryStream;
    FOnExpandName: TExpandNameEvent;
    FViewBottom: boolean;
    HTMLTimer: TTimer;

    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure ScrollTo(Y: integer);
    procedure Scroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure Layout;
    procedure SetViewImages(Value: boolean);
    function GetViewImages: boolean;
    procedure SetColor(Value: TColor);
    function GetBase: string;
    procedure SetBase(Value: string);
    function GetBaseTarget: string;
    function GetFURL: string;
    function GetTitle: string;
    function GetCurrentFile: string;
    procedure SetBorderStyle(Value: THTMLBorderStyle);
    function GetPosition: integer;
    procedure SetPosition(Value: integer);
    function GetScrollPos: integer;
    procedure SetScrollPos(Value: integer);
    function GetScrollBarRange: integer;
    procedure SetHistoryIndex(Value: integer);
    function GetFontName: TFontName;
    procedure SetFontName(Value: TFontName);
    function GetPreFontName: TFontName;
    procedure SetPreFontName(Value: TFontName);
    procedure SetFontSize(Value: integer);
    procedure SetFontColor(Value: TColor);
    procedure SetHotSpotColor(Value: TColor);
    procedure SetActiveColor(Value: TColor);
    procedure SetVisitedColor(Value: TColor);
    procedure SetVisitedMaxCount(Value: integer);
    procedure SetOnImageRequest(Handler: TGetImageEvent);
    procedure SetOnScript(Handler: TScriptEvent);
    procedure SetOnFormSubmit(Handler: TFormSubmitEvent);
    function GetOurPalette: HPalette;
    procedure SetOurPalette(Value: HPalette);
    procedure SetCaretPos(Value: integer);
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
    procedure BackgroundChange(Sender: TObject);
    procedure SubmitForm(Sender: TObject; const Action, Target, EncType, Method: string;
      Results: TStringList);
    procedure SetImageCacheCount(Value: integer);
    procedure WMFormSubmit(var Message: TMessage); message WM_FormSubmit;
    procedure WMMouseScroll(var Message: TMessage); message WM_MouseScroll;
    procedure SetSelLength(Value: integer);
    procedure SetSelStart(Value: integer);
    function GetSelLength: integer;
    function GetSelText: string;
    procedure SetNoSelect(Value: boolean);
    procedure SetHistoryMaxCount(Value: integer);
    procedure DrawBorder;
    procedure DoHilite(X, Y: integer);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetProcessing(Value: boolean);
    function GetTarget: string;
{$IFDEF ver100_plus} {Delphi 3,4,5, C++Builder 3, 4}
    procedure SetCharset(Value: TFontCharset);
{$ENDIF}
    function GetFormControlList: TList;
    function GetNameList: TStringList;
    function GetLinkList: TList;
    procedure SetMarginWidth(Value: integer);
    procedure SetMarginHeight(Value: integer);
    procedure SetServerRoot(Value: string);
    procedure SetOnObjectClick(Handler: TObjectClickEvent);
    procedure FormControlEnterEvent(Sender: TObject);
    procedure HandleMeta(Sender: TObject; const HttpEq, Name, Content: string);
    procedure SetOptions(Value: ThtmlViewerOptions);
    procedure SetOnExpandName(Handler: TExpandNameEvent);
    function GetWordAtCursor(X, Y: integer; var St, En: integer;
      var AWord: string): boolean;
    procedure HTMLTimerTimer(Sender: TObject);
    procedure InitLoad;

  protected
    { Protected declarations }
    PaintPanel: TPaintPanel;
    BorderPanel: TPanel;
    VScrollBar: T32ScrollBar;
    HScrollBar: TScrollBar;
    Sel1: integer;
    Visited: TStringList; {visited URLs}

    procedure DoLogic;
    procedure DoScrollBars;
    procedure SetupAndLogic;
    function GetURL(X, Y: integer; var UrlTarg: TUrlTarget;
      var FormControl: TImageFormControlObj): boolean;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function GetPalette: HPALETTE; override;
    procedure HTMLPaint(Sender: TObject); virtual;
    procedure HTMLMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
{$IFDEF ver120_plus}
    procedure HTMLMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
{$ENDIF}
    procedure HTMLMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); virtual;
    procedure HTMLMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
    procedure HTMLMouseDblClk(Message: TWMMouse);
    procedure URLAction; virtual;
    function HotSpotClickHandled: boolean; dynamic;
    procedure LoadFile(const FileName: string; ft: ThtmlFileType);
    procedure LoadString(const Source, Reference: string; ft: ThtmlFileType);
    procedure PaintWindow(DC: HDC); override;
    procedure UpdateImageCache;
    procedure AddVisitedLink(const S: string);
    procedure CheckVisitedLinks;

  public
    { Public declarations }
    FrameOwner: TObject;
    FMarginHeightX, FMarginWidthX: integer;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function HTMLExpandFilename(const Filename: string): string; virtual;
    procedure LoadFromFile(const FileName: string);
    procedure LoadTextFile(const FileName: string);
    procedure LoadImageFile(const FileName: string);
    procedure LoadStrings(const Strings: TStrings; const Reference: string);
    procedure LoadTextStrings(const Strings: TStrings);
    procedure LoadFromString(const S, Reference: string);
    procedure LoadTextFromString(const S: string);
    procedure LoadFromStream(const AStream: TStream; const Reference: string);
    function PositionTo(Dest: string): boolean;
    function Find(const S: string; MatchCase: boolean): boolean;
    procedure Clear; virtual;
    procedure CopyToClipboard;
    procedure SelectAll;
    procedure ClearHistory;
    procedure Reload;
    procedure BumpHistory(const FileName, Title: string;
      OldPos: integer; ft: ThtmlFileType);
    function GetSelTextBuf(Buffer: PChar; BufSize: integer): integer;
    function InsertImage(const Src: string; Stream: TMemoryStream): boolean;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure Repaint; override;
    function FindSourcePos(DisplayPos: integer): integer;
    function FindDisplayPos(SourcePos: integer; Prev: boolean): integer;
    function DisplayPosToXy(DisplayPos: integer; var X, Y: integer): boolean;
    function PtInObject(X, Y: integer; var Obj: TObject): boolean; {X, Y, are client coord}

    property DocumentTitle: string read GetTitle;
    property URL: string read GetFURL;
    property Base: string read GetBase write SetBase;
    property BaseTarget: string read GetBaseTarget;
    property Position: integer read GetPosition write SetPosition;
    property VScrollBarPosition: integer read GetScrollPos write SetScrollPos;
    property VScrollBarRange: integer read GetScrollBarRange;
    property CurrentFile: string read GetCurrentFile;
    property History: TStrings read FHistory;
    property TitleHistory: TStrings read FTitleHistory;
    property HistoryIndex: integer read FHistoryIndex write SetHistoryIndex;
    property Processing: boolean read FProcessing;
    property SelStart: integer read FCaretPos write SetSelStart;
    property SelLength: integer read GetSelLength write SetSelLength;
    property SelText: string read GetSelText;
    property Target: string read GetTarget;
    property Palette: HPalette read GetOurPalette write SetOurPalette;
    property CaretPos: integer read FCaretPos write SetCaretPos;
    property FormControlList: TList read GetFormControlList;
    property NameList: TStringList read GetNameList;
    property LinkList: TList read GetLinkList;
    property SectionList: TSectionList read FSectionList;
    property OnExpandName: TExpandNameEvent read FOnExpandName write SetOnExpandName;

  published
    { Published declarations }
    property OnHotSpotCovered: THotSpotEvent read FOnHotSpotCovered
      write FOnHotSpotCovered;
    property OnHotSpotClick: THotSpotClickEvent read FOnHotSpotClick
      write FOnHotSpotClick;
    property OnImageRequest: TGetImageEvent read FOnImageRequest
      write SetOnImageRequest;
    property OnScript: TScriptEvent read FOnScript
      write SetOnScript;
    property OnFormSubmit: TFormSubmitEvent read FOnFormSubmit
      write SetOnFormSubmit;
    property OnHistoryChange: TNotifyEvent read FOnHistoryChange
      write FOnHistoryChange;
    property ViewImages: boolean read GetViewImages write SetViewImages default True;
    property Enabled;
    property TabStop;
    property TabOrder;
    property Align;
    property Name;
    property Tag;
    property PopupMenu;
    property ShowHint;
    property Height default 150;
    property Width default 150;
    property DefBackground: TColor read FBackground write SetColor default clBtnFace;
    property BorderStyle: THTMLBorderStyle read FBorderStyle write SetBorderStyle;
    property Visible;
    property HistoryMaxCount: integer read FHistoryMaxCount write SetHistoryMaxCount;
    property DefFontName: TFontName read GetFontName write SetFontName;
    property DefPreFontName: TFontName read GetPreFontName write SetPreFontName;
    property DefFontSize: integer read FFontSize write SetFontSize default 12;
    property DefFontColor: TColor read FFontColor write SetFontColor
      default clBtnText;
    property DefHotSpotColor: TColor read FHotSpotColor write SetHotSpotColor
      default clBlue;
    property DefVisitedLinkColor: TColor read FVisitedColor write SetVisitedColor
      default clPurple;
    property DefOverLinkColor: TColor read FOverColor write SetActiveColor
      default clBlue;
    property VisitedMaxCount: integer read FVisitedMaxCount write SetVisitedMaxCount default 50;
    property ImageCacheCount: integer read FImageCacheCount
      write SetImageCacheCount default 5;
    property NoSelect: boolean read FNoSelect write SetNoSelect;
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars default ssBoth;
{$IFDEF ver100_plus} {Delphi 3,4,5, C++Builder 3, 4}
    property CharSet: TFontCharset read FCharSet write SetCharset;
{$ENDIF}
    property MarginHeight: integer read FMarginHeight write SetMarginHeight default 5;
    property MarginWidth: integer read FMarginWidth write SetMarginWidth default 10;
    property ServerRoot: string read FServerRoot write SetServerRoot;
    property htOptions: ThtmlViewerOptions read FOptions write SetOptions;

    property OnMouseMove;
    property OnMouseUp;
    property OnMouseDown;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    property OnEnter;
    property OnProcessing: TProcessingEvent read FOnProcessing write FOnProcessing;
    property OnInclude: TIncludeType read FOnInclude write FOnInclude;
    property OnSoundRequest: TSoundType read FOnSoundRequest write FOnSoundRequest;
    property OnMeta: TMetaType read FOnMeta write FOnMeta;
    property OnMetaRefresh: TMetaRefreshType read FOnMetaRefresh write FOnMetaRefresh;
    property OnImageClick: TImageClickEvent read FOnImageClick write FOnImageClick;
    property OnImageOver: TImageOverEvent read FOnImageOver write FOnImageOver;
    property OnObjectClick: TObjectClickEvent read FOnObjectClick write SetOnObjectClick;
    property OnRightClick: TRightClickEvent read FOnRightClick write FOnRightClick;
    property OnMouseDouble: TMouseEvent read FOnMouseDouble write FOnMouseDouble;
    property OnDragDrop: TDragDropEvent read GetDragDrop write SetDragDrop;
    property OnDragOver: TDragOverEvent read GetDragOver write SetDragOver;
  end;

procedure Register;

implementation

const
  MaxHScroll = 6000; {max horizontal display in pixels}
  VScale = 1;
  ScrollGap = 20;

type
  PositionObj = class(TObject)
    Pos: integer;
    FileType: ThtmlFileType;
  end;

constructor TWMLLite.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InCreate:= True;
  ControlStyle:= [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csDoubleClicks];
  Height:= 150;
  Width:= 150;
{$IFDEF ver100_plus} {Delphi 3,4,5, C++Builder 3, 4}
  FCharset:= DEFAULT_CHARSET;
{$ENDIF}
  FMarginHeight:= 5;
  FMarginWidth:= 10;

  hlParser:= ThlParser.Create;

  BorderPanel:= TPanel.Create(Self);
  BorderPanel.BevelInner:= bvNone;
  BorderPanel.BevelOuter:= bvNone;
  BorderPanel.Ctl3D:= False;
  BorderPanel.ParentColor:= True;
  BorderPanel.Align:= alClient;
  BorderPanel.ParentCtl3D:= False;

  InsertControl(BorderPanel);

  PaintPanel:= TPaintPanel.CreateIt(Self, Self);
  PaintPanel.ParentFont:= False;
  InsertControl(PaintPanel);
  PaintPanel.Top:= 1;
  PaintPanel.Left:= 1;
  PaintPanel.BevelOuter:= bvNone;
  PaintPanel.BevelInner:= bvNone;
  PaintPanel.ctl3D:= False;
  PaintPanel.ParentColor:= True;

  PaintPanel.OnPaint:= HTMLPaint;
  PaintPanel.OnMouseDown:= HTMLMouseDown;
  PaintPanel.OnMouseMove:= HTMLMouseMove;
  PaintPanel.OnMouseUp:= HTMLMouseUp;
{$IFDEF ver120_plus}
  OnMouseWheel:= HTMLMouseWheel;
{$ENDIF}

  VScrollBar:= T32ScrollBar.Create(Self);
  VScrollBar.Kind:= sbVertical;
  VScrollBar.SmallChange:= 16;
  VScrollBar.Visible:= False;
  VScrollBar.TabStop:= False;
  sbWidth:= VScrollBar.Width;
  InsertControl(VScrollBar);

  HScrollBar:= TScrollBar.Create(Self);
  HScrollBar.Kind:= sbHorizontal;
  HScrollBar.SmallChange:= 15;
  HScrollBar.OnScroll:= Scroll;
  HScrollBar.Visible:= False;
  HScrollBar.TabStop:= False;
  InsertControl(HScrollBar);

  FScrollBars:= ssBoth;

  FSectionList:= TSectionList.Create(Self, PaintPanel);
  FSectionList.ControlEnterEvent:= FormControlEnterEvent;
  FSectionList.OnBackgroundChange:= BackgroundChange;
  FSectionList.ShowImages:= True;
  FSectionList.Parser:= hlParser;

  FNameList:= TStringList.Create;
  FNameList.Sorted:= True;
  DefBackground:= clBtnFace;
  DefFontColor:= clBtnText;
  DefHotSpotColor:= clBlue;
  DefOverLinkColor:= clBlue;
  DefVisitedLinkColor:= clPurple;
  FVisitedMaxCount:= 50;
  DefFontSize:= 12;
  DefFontName:= 'Times New Roman';
  DefPreFontName:= 'Courier New';
  SetImageCacheCount(5);

  FBase:= '';
  FBaseEx:= '';
  FBaseTarget:= '';
  FCurrentFile:= '';
  FTitle:= '';
  FURL:= '';
  FTarget:= '';

  FHistory:= TStringList.Create;
  FPositionHistory:= TFreeList.Create;
  FTitleHistory:= TStringList.Create;

  Visited:= TStringList.Create;

  HTMLTimer:= TTimer.Create(Self);
  HTMLTimer.Enabled:= False;
  HTMLTimer.Interval:= 200;
  HTMLTimer.OnTimer:= HTMLTimerTimer;
  InCreate:= False;
end;

destructor TWMLLite.Destroy;
begin
  FSectionList.Free;
  FNameList.Free;
  FHistory.Free;
  FPositionHistory.Free;
  FTitleHistory.Free;
  Visited.Free;
  HTMLTimer.Free;
  hlParser.Free;
  inherited Destroy;
end;

procedure TWMLLite.SetupAndLogic;
begin
  FTitle:= hlParser.Title;
  if hlParser.Base <> '' then
    FBase:= hlParser.Base
  else FBase:= FBaseEx;
  FBaseTarget:= hlParser.BaseTarget;
  try
    DontDraw:= True;
  {Load the background bitmap if any and if ViewImages set}
    FSectionList.GetBackgroundBitmap;

    DoLogic;

  finally
    DontDraw:= False;
  end;
end;

{----------------TWMLLite.LoadTextFromString}

procedure TWMLLite.LoadTextFromString(const S: string);
begin
  LoadString(S, '', TextType);
end;

{----------------TWMLLite.LoadFromString}

procedure TWMLLite.LoadFromString(const S, Reference: string);
begin
  LoadString(S, Reference, HTMLType);
end;

{----------------TWMLLite.LoadString}

procedure TWMLLite.LoadString(const Source, Reference: string; ft: ThtmlFileType);
var
  I: integer;
  Dest, FName, OldFile: string;

begin
  if Source = '' then
    Exit;
  FName:= Reference;
  I:= Pos('#', FName);
  if I > 0 then begin
    Dest:= copy(FName, I + 1, 255); {positioning information}
    System.Delete(FName, I, 255);
  end
  else Dest:= '';
  FRefreshDelay:= 0;
  try
    OldFile:= FCurrentFile;
    FCurrentFile:= ExpandFileName(FName);
    FCurrentFileType:= ft;
    DontDraw:= True;
    try
      ParseStr(Source, ft);
    finally
      DontDraw:= False;
    end;
    CheckVisitedLinks;
    if (Dest <> '') and PositionTo(Dest) then {change position, if applicable}
    else if (FCurrentFile <> OldFile) or (FCurrentFile = '') then begin
      ScrollTo(0);
      HScrollBar.Position:= 0;
    end;
  {else if same file leave position alone}
    PaintPanel.Invalidate;
  finally
    SetProcessing(False);
  end;
  if (FRefreshDelay > 0) and Assigned(FOnMetaRefresh) then
    FOnMetaRefresh(Self, FRefreshDelay, FRefreshURL);
end;

procedure TWMLLite.LoadFile(const FileName: string; ft: ThtmlFileType);
var
  I: integer;
  Dest, FName, OldFile: string;
  FS: TFileStream;
  St: string;

begin
  IOResult; {eat up any pending errors}
  FName:= FileName;
  I:= Pos('#', FName);
  if I > 0 then begin
    Dest:= copy(FName, I + 1, 255); {positioning information}
    System.Delete(FName, I, 255);
  end
  else Dest:= '';
  FRefreshDelay:= 0;
  try
    if not FileExists(FName) then
      raise(EInOutError.Create('Can''t locate file: ' + FName));
    try
      OldFile:= FCurrentFile;
      FCurrentFile:= ExpandFileName(FName);
      FCurrentFileType:= ft;
      if ft in [HTMLType, TextType] then begin
        FS:= TFileStream.Create(FName, fmOpenRead or fmShareDenyWrite);
        try
          SetLength(St, FS.Size);
          FS.ReadBuffer(St[1], FS.Size);
        finally
          FS.Free;
        end;
      end
      else St:= '';
      DontDraw:= True;
      if ft in [HTMLType, TextType] then
        ParseStr(St, ft)
      else begin
        St:= '<img src="' + FName + '">';
        ParseStr(St, HTMLType);
      end;
    finally
      DontDraw:= False;
    end;
    CheckVisitedLinks;
    if (Dest <> '') and PositionTo(Dest) then {change position, if applicable}
    else if FCurrentFile <> OldFile then begin
      ScrollTo(0);
      HScrollBar.Position:= 0;
    end;
  {else if same file leave position alone}
  finally
    PaintPanel.Invalidate;
    SetProcessing(False);
  end;
  if (FRefreshDelay > 0) and Assigned(FOnMetaRefresh) then
    FOnMetaRefresh(Self, FRefreshDelay, FRefreshURL);
end;

procedure TWMLLite.LoadFromFile(const FileName: string);
var
  OldFile, OldTitle: string;
  OldPos: integer;
  OldType: ThtmlFileType;
begin
  if FProcessing then Exit;
  if Filename <> '' then begin
    OldFile:= FCurrentFile;
    OldTitle:= FTitle;
    OldPos:= Position;
    OldType:= FCurrentFileType;
    LoadFile(FileName, HTMLType);
    if (OldFile <> FCurrentFile) or (OldType <> FCurrentFileType) then
      BumpHistory(OldFile, OldTitle, OldPos, OldType);
  end;
end;

{----------------TWMLLite.LoadTextFile}

procedure TWMLLite.LoadTextFile(const FileName: string);
var
  OldFile, OldTitle: string;
  OldPos: integer;
  OldType: ThtmlFileType;
begin
  if FProcessing then Exit;
  if Filename <> '' then begin
    OldFile:= FCurrentFile;
    OldTitle:= FTitle;
    OldPos:= Position;
    OldType:= FCurrentFileType;
    LoadFile(FileName, TextType);
    if (OldFile <> FCurrentFile) or (OldType <> FCurrentFileType) then
      BumpHistory(OldFile, OldTitle, OldPos, OldType);
  end;
end;

{----------------TWMLLite.LoadImageFile}

procedure TWMLLite.LoadImageFile(const FileName: string);
var
  OldFile, OldTitle: string;
  OldPos: integer;
  OldType: ThtmlFileType;

begin
  if FProcessing then Exit;
  if Filename <> '' then begin
    OldFile:= FCurrentFile;
    OldTitle:= FTitle;
    OldPos:= Position;
    OldType:= FCurrentFileType;
    LoadFile(FileName, ImgType);
    if (OldFile <> FCurrentFile) or (OldType <> FCurrentFileType) then
      BumpHistory(OldFile, OldTitle, OldPos, OldType);
  end;
end;

{----------------TWMLLite.LoadStrings}

procedure TWMLLite.LoadStrings(const Strings: TStrings; const Reference: string);
begin
  LoadString(Strings.Text, Reference, HTMLType);
end;

{----------------TWMLLite.LoadTextStrings}

procedure TWMLLite.LoadTextStrings(const Strings: TStrings);
begin
  LoadString(Strings.Text, '', TextType);
end;

{----------------TWMLLite.ParseStr}

procedure TWMLLite.ParseStr(const S: string; ft: ThtmlFileType);
begin
  if FProcessing then Exit;
  SetProcessing(True);
  try
    FRefreshDelay:= 0;
    InitLoad;
    MaxVertical:= 0;
    CaretPos:= 0;
    Sel1:= -1;
    if Assigned(FOnSoundRequest) then
      FOnSoundRequest(Self, '', 0, True);

    if ft = HtmlType then
      hlParser.HtmlParseString(S, FSectionList, FNameList, FOnInclude, FOnSoundRequest, HandleMeta)
    else
      hlParser.HtmlParseTextString(S, FSectionList, FNameList);
    if FSectionList.Count > 0 then begin
      SetupAndLogic;
      PaintPanel.Invalidate;
    end;
  finally
    SetProcessing(False);
  end;
end;

{----------------TWMLLite.LoadFromStream}

procedure TWMLLite.LoadFromStream(const AStream: TStream; const Reference: string);
var
  Stream: TMemoryStream;
  S: string;
begin
  Stream:= TMemoryStream.Create;
  try
    Stream.LoadFromStream(AStream);
    SetLength(S, Stream.Size);
    Move(Stream.Memory^, S[1], Stream.Size);
  finally
    Stream.Free;
  end;
  LoadString(S, Reference, HTMLType);
  ScrollTo(0);
  HScrollBar.Position:= 0;
end;

{----------------ThtmlViewer.DoScrollBars}

procedure TWMLLite.DoScrollBars;
var
  VBar, VBar1, HBar: boolean;
  Wid, HWidth, WFactor, WFactor2, VHeight: integer;
  ScrollInfo: TScrollInfo;

begin
  ScrollWidth:= IntMin(ScrollWidth, MaxHScroll);
  if FBorderStyle = htNone then begin
    WFactor:= 0;
    PaintPanel.Top:= 0;
    PaintPanel.Left:= 0;
    BorderPanel.Visible:= False;
  end
  else begin
    WFactor:= 1;
    PaintPanel.Top:= 1;
    PaintPanel.Left:= 1;
    BorderPanel.Visible:= False;
    BorderPanel.Visible:= True;
  end;
  WFactor2:= 2 * WFactor;

  VBar:= False;
  VBar1:= False;
  if (not (htShowVScroll in htOptions) and (MaxVertical < Height - WFactor2) and (ScrollWidth <= Width - WFactor2))
    or (FScrollBars = ssNone) then
  {there are no scrollbars}
    HBar:= False
  else
    if FScrollBars in [ssBoth, ssVertical] then begin {assume a vertical scrollbar}
      VBar1:= (MaxVertical >= Height - WFactor2) or
        ((FScrollBars in [ssBoth, ssHorizontal]) and
        (MaxVertical >= Height - WFactor2 - sbWidth) and
        (ScrollWidth > Width - sbWidth - WFactor2));
      HBar:= (FScrollBars in [ssBoth, ssHorizontal]) and
        ((ScrollWidth > Width - WFactor2) or
        ((VBar1 or (htShowVScroll in FOptions)) and
        (ScrollWidth > Width - sbWidth - WFactor2)));
      VBar:= Vbar1 or (htShowVScroll in htOptions);
    end
    else
    {there is no vertical scrollbar}
      HBar:= (FScrollBars = ssHorizontal) and (ScrollWidth > Width - WFactor2);

  if VBar or ((htShowVScroll in FOptions) and (FScrollBars in [ssBoth, ssVertical])) then
    Wid:= Width - sbWidth
  else
    Wid:= Width;
  PaintPanel.Width:= Wid - WFactor2;
  if HBar then begin
    PaintPanel.Height:= Height - WFactor2 - sbWidth;
    VHeight:= Height - sbWidth - WFactor2;
  end
  else begin
    PaintPanel.Height:= Height - WFactor2;
    VHeight:= Height - WFactor2;
  end;
  HWidth:= IntMax(ScrollWidth, Wid - WFactor2);
  HScrollBar.Visible:= HBar;
  HScrollBar.LargeChange:= IntMax(1, Wid - 20);
  HScrollBar.SetBounds(WFactor, Height - sbWidth - WFactor, Wid - WFactor, sbWidth);
  VScrollBar.SetBounds(Width - sbWidth - WFactor, WFactor, sbWidth, VHeight);
  VScrollBar.LargeChange:= PaintPanel.Height div VScale - VScrollBar.SmallChange;
  if htShowVScroll in FOptions then begin
    VScrollBar.Visible:= (FScrollBars in [ssBoth, ssVertical]);
    VScrollBar.Enabled:= VBar1;
  end
  else VScrollBar.Visible:= VBar;

  HScrollBar.Max:= IntMax(0, HWidth);
  VScrollBar.SetParams(VScrollBar.Position, PaintPanel.Height + 1, 0, MaxVertical);
  ScrollInfo.cbSize:= SizeOf(ScrollInfo);
  ScrollInfo.fMask:= SIF_PAGE;
  ScrollInfo.nPage:= Wid;
  SetScrollInfo(HScrollBar.Handle, SB_CTL, ScrollInfo, TRUE);
end;

{----------------TWMLLite.DoLogic}

procedure TWMLLite.DoLogic;
var
  Curs: integer;
  Wid, WFactor, H: integer;
begin
  ScrollWidth:= 0;
  Curs:= 0;
  HandleNeeded;
  try
    DontDraw:= True;
    if FBorderStyle = htNone then WFactor:= 1
    else WFactor:= 3;
    if FScrollBars in [ssBoth, ssVertical] then begin {assume a vertical scrollbar}
      Wid:= Width - sbWidth - WFactor;
      H:= FSectionList.DoLogic(PaintPanel.Canvas, FMarginHeightX,
        Wid - 2 * FMarginWidthX, ScrollWidth, Curs);
      MaxVertical:= H + 2 * FMarginHeight;
      DoScrollBars;
    end
    else begin {there is no vertical scrollbar}
      Wid:= Width - WFactor;
      H:= FSectionList.DoLogic(PaintPanel.Canvas, FMarginHeightX,
        Wid - 2 * FMarginWidthX, ScrollWidth, Curs);
      MaxVertical:= H + FMarginHeight;
      DoScrollBars;
    end;
    if Cursor = crIBeam then
      Cursor:= ThickIBeamCursor;
  finally

    DontDraw:= False;
  end;
end;

procedure TWMLLite.HTMLPaint(Sender: TObject);
var
  ARect: TRect;
begin
  if not DontDraw then begin
    ARect:= Rect(FMarginWidthX, 1, PaintPanel.Width, PaintPanel.Height);
    FSectionList.Draw(PaintPanel.Canvas2, ARect, MaxHScroll,
      FMarginWidthX - HScrollBar.Position, FMarginHeightX);
  end;
end;

procedure TWMLLite.WMSize(var Message: TWMSize);
begin
  inherited;
  if InCreate then
    Exit;
  if not FProcessing then
    Layout
  else
    DoScrollBars;
  if MaxVertical < PaintPanel.Height then
    Position:= 0
  else ScrollTo(VScrollBar.Position * integer(VScale)); {keep aligned to limits}
  with HScrollBar do
    Position:= IntMin(Position, Max - PaintPanel.Width);
end;

procedure TWMLLite.Scroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
{only the 32 bit horizontal scrollbar comes here}
begin
  SetFocus;
  ScrollPos:= IntMin(ScrollPos, HScrollBar.Max - PaintPanel.Width);
  PaintPanel.Invalidate;
end;

procedure TWMLLite.ScrollTo(Y: integer);
begin
  Y:= IntMin(Y, MaxVertical - PaintPanel.Height);
  Y:= IntMax(Y, 0);
  VScrollBar.Position:= Y;
  FSectionList.SetYOffset(Y);
  Invalidate;
end;

procedure TWMLLite.Layout;
var
  OldPos: integer;
begin
  if FProcessing then Exit;
  SetProcessing(True);
  try
    OldPos:= Position;
    DoLogic;
    Position:= OldPos; {return to old position after width change}
  finally
    SetProcessing(False);
  end;
end;

function TWMLLite.HotSpotClickHandled: boolean;
var
  Handled: boolean;
begin
  Handled:= False;
  if Assigned(FOnHotSpotClick) then
    FOnHotSpotClick(Self, URL, Handled);
  Result:= Handled;
end;

procedure TWMLLite.URLAction;
var
  S, Dest: string;
  Ext: string[5];
  I: integer;
  OldPos: integer;

begin
  if not HotSpotClickHandled then begin
    OldPos:= Position;
    S:= URL;
    I:= Pos('#', S); {# indicates a position within the document}
    if I = 1 then begin
      if PositionTo(S) then {no filename with this one} begin
        BumpHistory(FCurrentFile, FTitle, OldPos, FCurrentFileType);
        AddVisitedLink(FCurrentFile + S);
      end;
    end
    else begin
      if I >= 1 then begin
        Dest:= System.Copy(S, I, 255); {local destination}
        S:= System.Copy(S, 1, I - 1); {the file name}
      end
      else
        Dest:= ''; {no local destination}
      S:= HTMLExpandFileName(S);
      Ext:= Uppercase(ExtractFileExt(S));
      if (Ext = '.HTM') or (Ext = '.HTML') then begin {an html file}
        if S <> FCurrentFile then begin
          LoadFromFile(S + Dest);
          AddVisitedLink(S + Dest);
        end
        else
          if PositionTo(Dest) then {file already loaded, change position} begin
            BumpHistory(FCurrentFile, FTitle, OldPos, HTMLType);
            AddVisitedLink(S + Dest);
          end;
      end
      else if (Ext = '.BMP') or (Ext = '.GIF') or (Ext = '.JPG') or (Ext = '.JPEG')
        or (Ext = '.PNG') then
        LoadImageFile(S);
    end;
    {Note: Self may not be valid here}
  end;
end;

{----------------TWMLLite.AddVisitedLink}

procedure TWMLLite.AddVisitedLink(const S: string);
var
  I, J: integer;
  S1, UrlTmp: string;
begin
  if Assigned(FrameOwner) or (FVisitedMaxCount = 0) then
    Exit; {TFrameViewer will take care of visited links}
  I:= Visited.IndexOf(S);
  if I = 0 then Exit
  else if I < 0 then begin
    for J:= 0 to SectionList.LinkList.Count - 1 do
      with TFontObj(SectionList.LinkList[J]) do begin
        UrlTmp:= Url;
        if Length(UrlTmp) > 0 then begin
          if Url[1] = '#' then
            S1:= FCurrentFile + UrlTmp
          else
            S1:= HTMLExpandFilename(UrlTmp);
          if CompareText(S, S1) = 0 then
            Visited:= True;
        end;
      end;
  end
  else Visited.Delete(I); {thus moving it to the top}
  Visited.Insert(0, S);
  for I:= Visited.Count - 1 downto FVisitedMaxCount do
    Visited.Delete(I);
end;

{----------------TWMLLite.CheckVisitedLinks}

procedure TWMLLite.CheckVisitedLinks;
var
  I, J: integer;
  S, S1: string;
begin
  if FVisitedMaxCount = 0 then
    Exit;
  for I:= 0 to Visited.Count - 1 do begin
    S:= Visited[I];
    for J:= 0 to SectionList.LinkList.Count - 1 do
      with TFontObj(SectionList.LinkList[J]) do begin
        if (Url <> '') and (Url[1] = '#') then
          S1:= FCurrentFile + Url
        else
          S1:= HTMLExpandFilename(Url);
        if CompareText(S, S1) = 0 then
          Visited:= True;
      end;
  end;
end;

procedure TWMLLite.HTMLMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  XR, CaretHt: integer;
  YR: integer;
  Cell1: TObject;
  InText: boolean;
begin
  inherited MouseDown(Button, Shift, X, Y);

  SetFocus;
  HotSpotAction:= False;
  if MiddleScrollOn then begin
    MiddleScrollOn:= False;
    PaintPanel.Cursor:= Cursor;
    MouseScrolling:= False;
  end
  else if (Button = mbMiddle) then begin
    MiddleScrollOn:= True;
    MiddleY:= Y;
    PaintPanel.Cursor:= UpDownCursor;
  end
  else if (Button = mbLeft) then begin
    LeftButtonDown:= True;
    HiLiting:= True;
    with FSectionList do begin
      Sel1:= FindCursor(PaintPanel.Canvas, X, Y + YOff - FMarginHeightX, XR, YR, CaretHt, Cell1, InText);
      if Sel1 > -1 then begin
        if SelB <> SelE then
          InvalidateRect(PaintPanel.Handle, nil, True);
        SelB:= Sel1;
        SelE:= Sel1;
        CaretPos:= Sel1;
      end;
    end;
  end;
end;

procedure TWMLLite.HTMLTimerTimer(Sender: TObject);
var
  Pt: TPoint;
begin
  if GetCursorPos(Pt) and (WindowFromPoint(Pt) <> PaintPanel.Handle) then begin
    SectionList.CancelActives;
    HTMLTimer.Enabled:= False;
    if FURL <> '' then begin
      FURL:= '';
      FTarget:= '';
      if Assigned(FOnHotSpotCovered) then FOnHotSpotCovered(Self, '');
    end;
  end;
end;

function TWMLLite.PtInObject(X, Y: integer; var Obj: TObject): boolean; {X, Y, are client coord}
var
  IX, IY: integer;
begin
  Result:= PtInRect(ClientRect, Point(X, Y)) and
    FSectionList.PtInObject(X, Y + FSectionList.YOff - FMarginHeightX, Obj, IX, IY);
end;

procedure TWMLLite.HTMLMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  UrlTarget: TUrlTarget;
  Url, Target: string;
  FormControl: TImageFormControlObj;
  Obj: TObject;
  IX, IY: integer;
  XR, CaretHt: integer;
  YR: integer;
  Cell1: TObject;
  InText: boolean;
  NextCursor: TCursor;
begin
  inherited MouseMove(Shift, X, Y);

  if MiddleScrollOn then begin
    if not MouseScrolling and (Abs(Y - MiddleY) > ScrollGap) then begin
      MouseScrolling:= True;
      PostMessage(Handle, wm_MouseScroll, 0, 0);
    end;
    Exit;
  end;

  UrlTarget:= nil;
  URL:= '';
  NextCursor:= crArrow;
  if GetURL(X, Y, UrlTarget, FormControl) then begin
    NextCursor:= HandCursor;
    if not Assigned(FormControl) then begin
      Url:= UrlTarget.Url;
      Target:= UrlTarget.Target;
      UrlTarget.Free;
    end;
  end;
  if (Assigned(FOnImageClick) or Assigned(FOnImageOver)) and
    FSectionList.PtInObject(X, Y + FSectionList.YOff - FMarginHeightX, Obj, IX, IY) then begin
    if NextCursor <> HandCursor then {in case it's also a Link}
      NextCursor:= crArrow;
    if Assigned(FOnImageOver) then FOnImageOver(Self, Obj, Shift, IX, IY);
  end
  else if (FSectionList.FindCursor(PaintPanel.Canvas, X, Y + FSectionList.YOff - FMarginHeightX, XR, YR, CaretHt, Cell1, InText)
    >= 0)
    and InText and (NextCursor <> HandCursor) then
    NextCursor:= Cursor;

  PaintPanel.Cursor:= NextCursor;
  SetCursor(Screen.Cursors[NextCursor]);

  if ((NextCursor = HandCursor) or (SectionList.ActiveImage <> nil)) then
    HTMLTimer.Enabled:= True
  else HTMLTimer.Enabled:= False;

  if (URL <> FURL) or (Target <> FTarget) then begin
    FURL:= URL;
    FTarget:= Target;
    if Assigned(FOnHotSpotCovered) then FOnHotSpotCovered(Self, URL);
  end;
  if (ssLeft in Shift) and not MouseScrolling and not FNoSelect
    and ((Y <= 0) or (Y >= Self.Height)) then begin
    MouseScrolling:= True;
    PostMessage(Handle, wm_MouseScroll, 0, 0);
  end;
  if (ssLeft in Shift) and not FNoSelect then
    DoHilite(X, Y);
  inherited MouseMove(Shift, X, Y);
end;

procedure TWMLLite.HTMLMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  UrlTarget: TUrlTarget;
  FormControl: TImageFormControlObj;
  Obj: TObject;
  IX, IY: integer;
  InImage: boolean;
  Parameters: TRightClickParameters;
  AWord: string;
  St, En: integer;
begin
  if MiddleScrollOn then begin
  {cancel unless it's middle button and has moved}
    if (Button <> mbMiddle) or (Y <> MiddleY) then begin
      MiddleScrollOn:= False;
      PaintPanel.Cursor:= Cursor;
    end;
    Exit;
  end;

  inherited MouseUp(Button, Shift, X, Y);

  if Assigned(FOnImageClick) or Assigned(FOnRightClick) then begin
    InImage:= FSectionList.PtInObject(X, Y + FSectionList.YOff - FMarginHeightX, Obj, IX, IY);
    if Assigned(FOnImageClick) and InImage then
      FOnImageClick(Self, Obj, Button, Shift, IX, IY);
    if (Button = mbRight) and Assigned(FOnRightClick) then begin
      Parameters:= TRightClickParameters.Create;
      try
        if InImage then begin
          Parameters.Image:= Obj as TImageObj;
          Parameters.ImageX:= IX;
          Parameters.ImageY:= IY;
        end;
        if GetURL(X, Y, UrlTarget, FormControl) and (UrlTarget <> nil) then begin
          Parameters.URL:= UrlTarget.URL;
          Parameters.Target:= UrlTarget.Target;
          UrlTarget.Free;
        end;
        if GetWordAtCursor(X, Y, St, En, AWord) then
          Parameters.ClickWord:= AWord;
        FOnRightClick(Self, Parameters);
      finally
        Parameters.Free;
      end;
    end;
  end;

  if Button = mbLeft then begin
    MouseScrolling:= False;
    DoHilite(X, Y);
    Hiliting:= False;
    if LeftButtonDown and GetURL(X, Y, UrlTarget, FormControl) then begin
      LeftButtonDown:= False;
      if Assigned(FormControl) then
        FormControl.ImageClick
      else if (FSectionList.SelE <= FSectionList.SelB) then begin
        FURL:= UrlTarget.URL;
        FTarget:= UrlTarget.Target;
        UrlTarget.Free;
        HotSpotAction:= True; {prevent double click action}
        URLAction;
      {Note:  Self pointer may not be valid after URLAction call (TFrameViewer, HistoryMaxCount=0)}
      end;
    end;
    LeftButtonDown:= False;
  end;
end;

{----------------TWMLLite.HTMLMouseWheel}
{$IFDEF ver120_plus}

procedure TWMLLite.HTMLMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  VScrollBarPosition:= VScrollBarPosition - WheelDelta div 2;
  Handled:= True;
end;
{$ENDIF}

{----------------TWMLLite.GetWordAtCursor}

function TWMLLite.GetWordAtCursor(X, Y: integer; var St, En: integer;
  var AWord: string): boolean;
const
  AlphNum = ['a'..'z', 'A'..'Z', '0'..'9', #192..#255]; {changed in 7.2}
var
  XR, X1, CaretHt: integer;
  YR, Y1: integer;
  Cell1: TObject;
  Obj: TObject;
  Ch: char;
  InText: boolean;

  function GetCh(Pos: integer): char;
  var
    Ch: char;
    Obj1: TObject;
  begin
    Result:= ' ';
    if not FSectionList.GetChAtPos(Pos, Ch, Obj1) or (Obj1 <> Obj) then Exit;
    Result:= Ch;
  end;

begin
  Result:= False;
  AWord:= '';
  with FSectionList do begin
    InText:= False;
    CaretPos:= FindCursor(PaintPanel.Canvas, X,
      Y + YOff - FMarginHeightX, XR, YR, CaretHt, Cell1, InText);
    CursorToXy(PaintPanel.Canvas, CaretPos, X1, Y1);
    if InText then {else cursor is past end of row} begin
      en:= CaretPos;
      st:= en - 1;
      if GetChAtPos(en, Ch, Obj) and (Ch in AlphNum) then begin
        AWord:= Ch;
        Result:= True;
        Inc(en);
        Ch:= GetCh(en);
        while Ch in AlphNum do begin
          AWord:= AWord + Ch;
          Inc(en);
          Ch:= GetCh(en);
        end;
        if St >= 0 then begin
          Ch:= GetCh(st);
          while (st >= 0) and (Ch in AlphNum) do begin
            System.Insert(Ch, AWord, 1);
            Dec(st);
            if St >= 0 then
              Ch:= GetCh(St);
          end;
        end;
      end;
    end;
  end;
end;

{----------------TWMLLite.HTMLMouseDblClk}

procedure TWMLLite.HTMLMouseDblClk(Message: TWMMouse);
var
  st, en: integer;
  AWord: string;
begin
  if FProcessing or HotSpotAction then Exit;
  if not FNoSelect and GetWordAtCursor(Message.XPos, Message.YPos, St, En, AWord) then begin
    FSectionList.SelB:= st + 1;
    FSectionList.SelE:= en;
    FCaretPos:= st + 1;
    InvalidateRect(PaintPanel.Handle, nil, True);
  end;
  if Assigned(FOnMouseDouble) then
    with Message do
      FOnMouseDouble(Self, mbLeft, KeysToShiftState(Keys), XPos, YPos);
end;

procedure TWMLLite.DoHilite(X, Y: integer);
var
  Curs, YR, YWin: integer;
  CursCell: TObject;
  XR, CaretHt: integer;
  InText: boolean;
begin
  if Hiliting and (Sel1 >= 0) then
    with FSectionList do begin
      CursCell:= nil;
      YWin:= IntMin(IntMax(0, Y), Height);
      Curs:= FindCursor(PaintPanel.Canvas, X, YWin + YOff - FMarginHeightX, XR, YR, CaretHt, CursCell, InText);
      if (Curs >= 0) and not FNoSelect then begin
        if Curs > Sel1 then begin
          SelE:= Curs;
          SelB:= Sel1;
        end
        else begin
          SelB:= Curs;
          SelE:= Sel1;
        end;
        InvalidateRect(PaintPanel.Handle, nil, True);
      end;
      CaretPos:= Curs;
    end;
end;

{----------------TWMLLite.WMMouseScroll}

procedure TWMLLite.WMMouseScroll(var Message: TMessage);
const
  Ticks: DWord = 0;
var
  Pos: integer;
  Pt: TPoint;
begin
  GetCursorPos(Pt);
  Ticks:= 0;
  with VScrollBar do begin
    Pt:= PaintPanel.ScreenToClient(Pt);
    while MouseScrolling and (LeftButtonDown and ((Pt.Y <= 0) or (Pt.Y > Self.Height)))
      or (MiddleScrollOn and (Abs(Pt.Y - MiddleY) > ScrollGap)) do begin
      if GetTickCount > Ticks + 100 then begin
        Ticks:= GetTickCount;
        Pos:= Position;
        if LeftButtonDown then begin
          if Pt.Y < -15 then
            Pos:= Position - SmallChange * 8
          else if Pt.Y <= 0 then
            Pos:= Position - SmallChange
          else if Pt.Y > Self.Height + 15 then
            Pos:= Position + SmallChange * 8
          else
            Pos:= Position + SmallChange;
        end
        else begin {MiddleScrollOn}
          if Pt.Y - MiddleY < -3 * ScrollGap then
            Pos:= Position - 32
          else if Pt.Y - MiddleY < -ScrollGap then
            Pos:= Position - 8
          else if Pt.Y - MiddleY > 3 * ScrollGap then
            Pos:= Position + 32
          else if Pt.Y - MiddleY > ScrollGap then
            Pos:= Position + 8;
          if Pos < Position then
            PaintPanel.Cursor:= UpOnlyCursor
          else if Pos > Position then
            PaintPanel.Cursor:= DownOnlyCursor;
        end;
        Pos:= IntMax(0, IntMin(Pos, MaxVertical - PaintPanel.Height));
        FSectionList.SetYOffset(Pos * integer(VScale));
        SetPosition(Pos);
        DoHilite(Pt.X, Pt.Y);
        PaintPanel.Invalidate;
        GetCursorPos(Pt);
        Pt:= PaintPanel.ScreenToClient(Pt);
      end;
      Application.ProcessMessages;
      Application.ProcessMessages;
      Application.ProcessMessages;
      Application.ProcessMessages;
    end;
  end;
  MouseScrolling:= False;
  if MiddleScrollOn then
    PaintPanel.Cursor:= UpDownCursor;
end;

function TWMLLite.PositionTo(Dest: string): boolean;
var
  I: integer;
begin
  Result:= False;
  if Dest = '' then Exit;
  if Dest[1] = '#' then
    System.Delete(Dest, 1, 1);
  I:= FNameList.IndexOf(UpperCase(Dest));
  if I > -1 then begin
    ScrollTo(TSectionBase(FNameList.Objects[I]).YValue);
    HScrollBar.Position:= 0;
    Result:= True;
    AddVisitedLink(FCurrentFile + '#' + Dest);
  end;
end;

function TWMLLite.GetURL(X, Y: integer; var UrlTarg: TUrlTarget;
  var FormControl: TImageFormControlObj): boolean;
begin
  Result:= FSectionList.GetURL(PaintPanel.Canvas, X, Y + FSectionList.YOff - FMarginHeightX,
    UrlTarg, FormControl);
end;

procedure TWMLLite.SetViewImages(Value: boolean);
var
  OldPos: integer;
  OldCursor: TCursor;
begin
  if (Value <> FSectionList.ShowImages) and not FProcessing then begin
    OldCursor:= Screen.Cursor;
    try
      Screen.Cursor:= crHourGlass;
      SetProcessing(True);
      FSectionList.ShowImages:= Value;
      if FSectionList.Count > 0 then begin
        FSectionList.GetBackgroundBitmap; {load any background bitmap}
        OldPos:= Position;
        DoLogic;
        Position:= OldPos;
        Invalidate;
      end;
    finally
      Screen.Cursor:= OldCursor;
      SetProcessing(False);
    end;
  end;
end;

{----------------TWMLLite.InsertImage}

function TWMLLite.InsertImage(const Src: string; Stream: TMemoryStream): boolean;
var
  OldPos: integer;
  ReFormat: boolean;
begin
  Result:= False;
  if FProcessing then Exit;
  try
    SetProcessing(True);
    FSectionList.InsertImage(Src, Stream, Reformat);
    FSectionList.GetBackgroundBitmap; {in case it's the one placed}
    if Reformat then
      if FSectionList.Count > 0 then begin
        FSectionList.GetBackgroundBitmap; {load any background bitmap}
        OldPos:= Position;
        DoLogic;
        Position:= OldPos;
      end;
    Invalidate;
  finally
    SetProcessing(False);
    Result:= True;
  end;
end;

function TWMLLite.GetBase: string;
begin
  Result:= FBase;
end;

procedure TWMLLite.SetBase(Value: string);
begin
  FBase:= Value;
  FBaseEx:= Value;
end;

function TWMLLite.GetBaseTarget: string;
begin
  Result:= FBaseTarget;
end;

function TWMLLite.GetTitle: string;
begin
  Result:= FTitle;
end;

function TWMLLite.GetCurrentFile: string;
begin
  Result:= FCurrentFile;
end;

function TWMLLite.GetFURL: string;
begin
  Result:= FURL;
end;

function TWMLLite.GetTarget: string;
begin
  Result:= FTarget;
end;

function TWMLLite.GetViewImages: boolean;
begin
  Result:= FSectionList.ShowImages;
end;

procedure TWMLLite.SetColor(Value: TColor);
begin
  if FProcessing then Exit;
  FBackground:= Value;
  FSectionList.Background:= Value;
  PaintPanel.Color:= Value;
  Invalidate;
end;

procedure TWMLLite.SetBorderStyle(Value: THTMLBorderStyle);
begin
  if Value <> FBorderStyle then begin
    FBorderStyle:= Value;
    DrawBorder;
  end;
end;

procedure TWMLLite.KeyDown(var Key: Word; Shift: TShiftState);
var
  Pos: integer;
  OrigPos: integer;
  TheChange: integer;
begin
  inherited KeyDown(Key, Shift);
  if MiddleScrollOn then {v7.2} begin
    MiddleScrollOn:= False;
    PaintPanel.Cursor:= Cursor;
    Exit;
  end;
  with VScrollBar do
    if Key in [VK_PRIOR, VK_NEXT, VK_UP, VK_DOWN, VK_HOME, VK_END] then begin
      Pos:= Position;
      OrigPos:= Pos;
      case Key of
        VK_PRIOR: Dec(Pos, LargeChange);
        VK_NEXT: Inc(Pos, LargeChange);
        VK_UP: Dec(Pos, SmallChange);
        VK_DOWN: Inc(Pos, SmallChange);
        VK_Home: Pos:= 0;
        VK_End: Pos:= MaxVertical div VScale;
      end;
      if Pos < 0 then Pos:= 0;
      Pos:= IntMax(0, IntMin(Pos, MaxVertical - PaintPanel.Height));

      Position:= Pos;
      FSectionList.SetYOffset(Pos * integer(VScale));
      TheChange:= OrigPos - Pos;
      if abs(TheChange) = SmallChange then begin
        ScrollWindow(PaintPanel.Handle, 0, TheChange * VScale, nil, nil);
        PaintPanel.Update;
      end else
        PaintPanel.Invalidate;
    end;
  with HScrollBar do
    if Key in [VK_LEFT, VK_RIGHT] then begin
      Pos:= Position;
      case Key of
        VK_LEFT: Dec(Pos, SmallChange);
        VK_RIGHT: Inc(Pos, SmallChange);
      end;
      if Pos < 0 then Pos:= 0;
      Pos:= IntMin(Pos, Max - PaintPanel.Width);
      Position:= Pos;
      PaintPanel.Invalidate;
    end;
end;

procedure TWMLLite.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result:= DLGC_WantArrows; {else don't get the arrow keys}
end;

function TWMLLite.GetPosition: integer;
var
  Index: integer;
  TopPos, Pos: integer;
  S: TSectionBase;
begin
  Pos:= integer(VScrollBar.Position) * VScale;
  S:= FSectionList.FindSectionAtPosition(Pos, TopPos, Index);
  if Assigned(S) then
    Result:= integer(Index) shl 16 + ((Pos - TopPos) and $FFFF)
  else Result:= 0;
{Hiword is section #, Loword is displacement from top of section}
end;

procedure TWMLLite.SetPosition(Value: integer);
var
  TopPos: integer;
begin
  if (Value >= 0) and (Hiword(Value) < FSectionList.Count) then begin
    TopPos:= FSectionList.FindPositionByIndex(HiWord(Value));
    ScrollTo(TopPos + LoWord(Value));
  end;
end;

function TWMLLite.GetScrollPos: integer;
begin
  Result:= VScrollBar.Position;
end;

procedure TWMLLite.SetScrollPos(Value: integer);
begin
  if Value < 0 then Value:= 0;
  Value:= IntMin(Value, VScrollBar.Max);
  if Value <> GetScrollPos then
    ScrollTo(integer(Value) * VScale);
end;

function TWMLLite.GetScrollBarRange: integer;
begin
  Result:= MaxVertical - PaintPanel.Height;
end;

function TWMLLite.GetPalette: HPALETTE;
begin
  if ThePalette <> 0 then
    Result:= ThePalette
  else Result:= inherited GetPalette;
  Invalidate;
end;

function TWMLLite.HTMLExpandFilename(const Filename: string): string;
begin
  Result:= HTMLServerToDos(Trim(Filename), FServerRoot);

  if Pos('\', Result) = 1 then
    Result:= ExpandFilename(Result)
  else if (Pos(':', Result) <> 2) and (Pos('\\', Result) <> 1) then
    if CompareText(FBase, 'DosPath') = 0 then {let Dos find the path}
    else if FBase <> '' then
      Result:= ExpandFilename(HTMLToDos(FBase) + Result)
    else
      Result:= ExpandFilename(ExtractFilePath(FCurrentFile) + Result);
end;

{----------------TWMLLite.BumpHistory}

procedure TWMLLite.BumpHistory(const FileName, Title: string;
  OldPos: integer; ft: ThtmlFileType);
var
  I: integer;
  PO: PositionObj;
begin
  if (FHistoryMaxCount > 0) and (FCurrentFile <> '') and
    ((FileName <> FCurrentFile) or (FCurrentFileType <> ft)
    or (OldPos <> Position)) then
    with FHistory do begin
      if (Count > 0) and (Filename <> '') then begin
        Strings[FHistoryIndex]:= Filename;
        with PositionObj(FPositionHistory[FHistoryIndex]) do begin
          Pos:= OldPos;
          FileType:= ft;
        end;
        FTitleHistory[FHistoryIndex]:= Title;
        for I:= 0 to FHistoryIndex - 1 do begin
          Delete(0);
          FTitleHistory.Delete(0);
          PositionObj(FPositionHistory[0]).Free;
          FPositionHistory.Delete(0);
        end;
      end;
      FHistoryIndex:= 0;
      Insert(0, FCurrentFile);
      PO:= PositionObj.Create;
      PO.Pos:= Position;
      PO.FileType:= FCurrentFileType;
      FPositionHistory.Insert(0, PO);
      FTitleHistory.Insert(0, FTitle);
      if Count > FHistoryMaxCount then begin
        Delete(FHistoryMaxCount);
        FTitleHistory.Delete(FHistoryMaxCount);
        PositionObj(FPositionHistory[FHistoryMaxCount]).Free;
        FPositionHistory.Delete(FHistoryMaxCount);
      end;
      if Assigned(FOnHistoryChange) then FOnHistoryChange(Self);
    end;
end;

procedure TWMLLite.SetHistoryIndex(Value: integer);
begin
  with FHistory do
    if (Value <> FHistoryIndex) and (Value >= 0) and (Value < Count)
      and not FProcessing then begin
      if FCurrentFile <> '' then begin
        Strings[FHistoryIndex]:= FCurrentFile;
        with PositionObj(FPositionHistory[FHistoryIndex]) do begin
          Pos:= Position;
          FileType:= FCurrentFileType;
        end;
        FTitleHistory[FHistoryIndex]:= FTitle;
      end;
      with PositionObj(FPositionHistory[Value]) do begin
        if (FCurrentFile <> Strings[Value]) or (FCurrentFileType <> FileType) then
          Self.LoadFile(Strings[Value], FileType);
        Position:= Pos;
      end;
      FHistoryIndex:= Value;
      if Assigned(FOnHistoryChange) then FOnHistoryChange(Self);
    end;
end;

procedure TWMLLite.SetHistoryMaxCount(Value: integer);
begin
  if (Value = FHistoryMaxCount) or (Value < 0) then Exit;
  if Value < FHistoryMaxCount then
    ClearHistory;
  FHistoryMaxCount:= Value;
end;

procedure TWMLLite.ClearHistory;
var
  CountWas: integer;
begin
  CountWas:= FHistory.Count;
  FHistory.Clear;
  FTitleHistory.Clear;
  FPositionHistory.Clear;
  FHistoryIndex:= 0;
  if (CountWas > 0) and Assigned(FOnHistoryChange) then
    FOnHistoryChange(Self);
end;

function TWMLLite.GetFontName: TFontName;
begin
  Result:= FFontName;
end;

procedure TWMLLite.SetFontName(Value: TFontName);
begin
  if CompareText(Value, FSectionList.FontName) <> 0 then begin
    FFontName:= Value;
    FSectionList.FontName:= Value;
    FSectionList.UpdateFonts;
    if FSectionList.Count > 0 then
      Layout;
    Invalidate;
  end;
end;

function TWMLLite.GetPreFontName: TFontName;
begin
  Result:= FPreFontName;
end;

procedure TWMLLite.SetPreFontName(Value: TFontName);
begin
  if CompareText(Value, FSectionList.PreFontName) <> 0 then begin
    FPreFontName:= Value;
    FSectionList.PreFontName:= Value;
    FSectionList.UpdateFonts;
    if FSectionList.Count > 0 then
      Layout;
    Invalidate;
  end;
end;

procedure TWMLLite.SetFontSize(Value: integer);
begin
  Value:= IntMax(Value, 6); {minimum value of 6 pts}
  FFontSize:= Value;
  FSectionList.FontSize:= Value;
  FSectionList.UpdateFonts;
  if FSectionList.Count > 0 then
    Layout;
  Invalidate;
end;

{$IFDEF ver100_plus} {Delphi 3,4,5, C++Builder 3, 4}

procedure TWMLLite.SetCharset(Value: TFontCharset);
begin
  FCharset:= Value;
  FSectionList.Charset:= Value;
  FSectionList.UpdateFonts;
  if FSectionList.Count > 0 then
    Layout;
  Invalidate;
end;
{$ENDIF}

function TWMLLite.GetFormControlList: TList;
begin
  Result:= FSectionList.FormControlList;
end;

function TWMLLite.GetNameList: TStringList;
begin
  Result:= FNameList;
end;

function TWMLLite.GetLinkList: TList;
begin
  Result:= FSectionList.LinkList;
end;

procedure TWMLLite.SetFontColor(Value: TColor);
begin
  FFontColor:= Value;
  FSectionList.FontColor:= Value;
  FSectionList.UpdateFonts;
  Invalidate;
end;

procedure TWMLLite.SetHotSpotColor(Value: TColor);
begin
  FHotSpotColor:= Value;
  FSectionList.HotSpotColor:= Value;
  FSectionList.UpdateFonts;
  Invalidate;
end;

procedure TWMLLite.SetVisitedColor(Value: TColor);
begin
  FVisitedColor:= Value;
  FSectionList.LinkVisitedColor:= Value;
  FSectionList.UpdateFonts;
  Invalidate;
end;

procedure TWMLLite.SetActiveColor(Value: TColor);
begin
  FOverColor:= Value;
  FSectionList.LinkActiveColor:= Value;
  FSectionList.UpdateFonts;
  Invalidate;
end;

procedure TWMLLite.SetVisitedMaxCount(Value: integer);
var
  I: integer;
begin
  Value:= IntMax(Value, 0);
  if Value <> FVisitedMaxCount then begin
    FVisitedMaxCount:= Value;
    if FVisitedMaxCount = 0 then begin
      Visited.Clear;
      for I:= 0 to SectionList.LinkList.Count - 1 do
        TFontObj(LinkList[I]).Visited:= False;
      Invalidate;
    end
    else begin
      FVisitedMaxCount:= Value;
      for I:= Visited.Count - 1 downto FVisitedMaxCount do
        Visited.Delete(I);
    end;
  end;
end;

procedure TWMLLite.BackgroundChange(Sender: TObject);
begin
  PaintPanel.Color:= (Sender as TSectionList).Background or $2000000;
end;

procedure TWMLLite.SetOnImageRequest(Handler: TGetImageEvent);
begin
  FOnImageRequest:= Handler;
  FSectionList.GetImage:= Handler;
end;

procedure TWMLLite.SetOnExpandName(Handler: TExpandNameEvent);
begin
  FOnExpandName:= Handler;
  FSectionList.ExpandName:= Handler;
end;

procedure TWMLLite.SetOnScript(Handler: TScriptEvent);
begin
  FOnScript:= Handler;
  FSectionList.ScriptEvent:= Handler;
end;

procedure TWMLLite.SetOnObjectClick(Handler: TObjectClickEvent);
begin
  FOnObjectClick:= Handler;
  FSectionList.ObjectClick:= Handler;
end;

procedure TWMLLite.SetOnFormSubmit(Handler: TFormSubmitEvent);
begin
  FOnFormSubmit:= Handler;
  if Assigned(Handler) then
    FSectionList.SubmitForm:= SubmitForm
  else FSectionList.SubmitForm:= nil;
end;

procedure TWMLLite.SubmitForm(Sender: TObject; const Action, Target, EncType, Method: string;
  Results: TStringList);
begin
  if Assigned(FOnFormSubmit) then begin
    FAction:= Action;
    FMethod:= Method;
    FFormTarget:= Target;
    FEncType:= EncType;
    FStringList:= Results;
    PostMessage(Handle, wm_FormSubmit, 0, 0);
  end;
end;

procedure TWMLLite.WMFormSubmit(var Message: TMessage);
begin
  FOnFormSubmit(Self, FAction, FFormTarget, FEncType, FMethod, FStringList);
end; {user disposes of the TStringList}

function TWMLLite.Find(const S: string; MatchCase: boolean): boolean;
var
  ChArray: array[0..256] of char;
  Curs: integer;
  X: integer;
  Y, Pos: integer;
begin
  Result:= False;
  if S = '' then Exit;
  StrPCopy(ChArray, S);
  with FSectionList do begin
    Curs:= FindString(CaretPos, ChArray, MatchCase);
    if Curs >= 0 then begin
      Result:= True;
      SelB:= Curs;
      SelE:= Curs + Length(S);
      CaretPos:= SelE;
      if CursorToXY(PaintPanel.Canvas, Curs, X, Y) then begin
        Pos:= VScrollBarPosition * integer(VScale);
        if (Y < Pos) or
          (Y > Pos + ClientHeight - 20) then
          VScrollBarPosition:= (Y - ClientHeight div 2) div VScale;
        Invalidate;
      end;
    end;
  end;
end;

procedure TWMLLite.FormControlEnterEvent(Sender: TObject);
var
  Y, Pos: integer;
begin
  if Sender is TFormControlObj then begin
    Y:= TFormControlObj(Sender).YValue;
    Pos:= VScrollBarPosition * integer(VScale);
    if (Y < Pos) or (Y > Pos + ClientHeight - 20) then begin
      VScrollBarPosition:= (Y - ClientHeight div 2) div VScale;
      Invalidate;
    end;
  end;
end;

procedure TWMLLite.SelectAll;
var
  SB: TSectionBase;
begin
  with FSectionList do
    if (Count > 0) and not FNoSelect then begin
      SelB:= 0;
      SB:= TSectionBase(Items[Count - 1]);
      with SB do
        SelE:= StartCurs + Len;
      Invalidate;
    end;
end;

{----------------TWMLLite.InitLoad}

procedure TWMLLite.InitLoad;
begin
  FSectionList.Clear;
  UpdateImageCache;
  FSectionList.SetFonts(FFontName, FPreFontName, FFontSize, FFontColor,
    FHotSpotColor, FVisitedColor, FOverColor, FBackground,
    htOverLinksActive in FOptions);
  FNameList.Clear;
  FMarginWidthX:= FMarginWidth;
  FMarginHeightX:= FMarginHeight;
end;

{----------------TWMLLite.Clear}

procedure TWMLLite.Clear;
{Note: because of Frames do not clear history list here}
begin
  if FProcessing then Exit;
  HTMLTimer.Enabled:= False;
  FSectionList.Clear;
  FSectionList.SetFonts(FFontName, FPreFontName, FFontSize, FFontColor,
    FHotSpotColor, FVisitedColor, FOverColor, FBackground,
    htOverLinksActive in FOptions);
  FNameList.Clear;
  FBase:= '';
  FBaseEx:= '';
  FBaseTarget:= '';
  FTitle:= '';
  VScrollBar.Max:= 0;
  VScrollBar.Visible:= False;
  VScrollBar.Height:= PaintPanel.Height;
  HScrollBar.Visible:= False;
  CaretPos:= 0;
  Sel1:= -1;
  if Assigned(FOnSoundRequest) then
    FOnSoundRequest(Self, '', 0, True);
  Invalidate;
end;

procedure TWMLLite.PaintWindow(DC: HDC);
begin
  PaintPanel.RePaint;
  VScrollbar.RePaint;
  HScrollbar.RePaint;
end;

procedure TWMLLite.CopyToClipboard;
begin
  Clipboard.SetTextBuf(PAnsiChar(GetSelText));
end;

function TWMLLite.GetSelTextBuf(Buffer: PChar; BufSize: integer): integer;
begin
  if BufSize <= 0 then Result:= 0
  else Result:= FSectionList.GetSelTextBuf(Buffer, BufSize);
end;

function TWMLLite.GetSelText: string;
var
  Len: integer;
begin
  Len:= FSectionList.GetSelLength;
  if Len > 0 then begin
    SetString(Result, nil, Len);
    FSectionList.GetSelTextBuf(Pointer(Result), Len + 1);
  end
  else Result:= '';
end;

function TWMLLite.GetSelLength: integer;
begin
  with FSectionList do
    if FCaretPos = SelB then
      Result:= SelE - SelB
    else
      Result:= SelB - SelE;
end;

procedure TWMLLite.SetSelLength(Value: integer);
begin
  with FSectionList do begin
    if Value >= 0 then begin
      SelB:= FCaretPos;
      SelE:= FCaretPos + Value;
    end
    else begin
      SelE:= FCaretPos;
      SelB:= FCaretPos + Value;
    end;
    Invalidate;
  end;
end;

procedure TWMLLite.SetSelStart(Value: integer);
begin
  with FSectionList do begin
    CaretPos:= Value;
    SelB:= Value;
    SelE:= Value;
    Invalidate;
  end;
end;

procedure TWMLLite.SetNoSelect(Value: boolean);
begin
  if Value <> FNoSelect then begin
    FNoSelect:= Value;
    if Value = True then begin
      FSectionList.SelB:= -1;
      FSectionList.SelE:= -1;
      RePaint;
    end;
  end;
end;

procedure TWMLLite.UpdateImageCache;
begin
  BitmapList.BumpAndCheck;
end;

procedure TWMLLite.SetImageCacheCount(Value: integer);
begin
  Value:= IntMax(0, Value);
  Value:= IntMin(20, Value);
  if Value <> FImageCacheCount then begin
    FImageCacheCount:= Value;
    BitmapList.SetCacheCount(FImageCacheCount);
  end;
end;

procedure TWMLLite.DrawBorder;
begin
  if (Focused and (FBorderStyle = htFocused)) or (FBorderStyle = htSingle)
    or (csDesigning in ComponentState) then
    BorderPanel.BorderStyle:= bsSingle
  else
    BorderPanel.BorderStyle:= bsNone;
end;

procedure TWMLLite.DoEnter;
begin
  inherited DoEnter;
  DrawBorder;
end;

procedure TWMLLite.DoExit;
begin
  inherited DoExit;
  DrawBorder;
end;

procedure TWMLLite.SetScrollBars(Value: TScrollStyle);
begin
  if (Value <> FScrollBars) then begin
    FScrollBars:= Value;
    if not (csLoading in ComponentState) and HandleAllocated then begin
      SetProcessing(True);
      try
        DoLogic;
      finally
        SetProcessing(False);
      end;
      Invalidate;
    end;
  end;
end;

{----------------TWMLLite.Reload}

procedure TWMLLite.Reload; {reload the last file}
var
  Pos: integer;
begin
  if FCurrentFile <> '' then begin
    Pos:= Position;
    if FCurrentFileType = HTMLType then
      LoadFromFile(FCurrentFile)
    else if FCurrentFileType = TextType then
      LoadTextFile(FCurrentFile)
    else LoadImageFile(FCurrentFile);
    Position:= Pos;
  end;
end;

{----------------TWMLLite.GetOurPalette:}

function TWMLLite.GetOurPalette: HPalette;
begin
  if ColorBits = 8 then
    Result:= CopyPalette(ThePalette)
  else Result:= 0;
end;

{----------------TWMLLite.SetOurPalette}

procedure TWMLLite.SetOurPalette(Value: HPalette);
var
  NewPalette: HPalette;
begin
  if (Value <> 0) and (ColorBits = 8) then begin
    NewPalette:= CopyPalette(Value);
    if NewPalette <> 0 then begin
      if ThePalette <> 0 then
        DeleteObject(ThePalette);
      ThePalette:= NewPalette;
    end;
  end;
end;

procedure TWMLLite.SetCaretPos(Value: integer);
begin
  if Value >= 0 then
    FCaretPos:= Value;
end;

function TWMLLite.FindSourcePos(DisplayPos: integer): integer;
begin
  Result:= FSectionList.FindSourcePos(DisplayPos);
end;

function TWMLLite.FindDisplayPos(SourcePos: integer; Prev: boolean): integer;
begin
  Result:= FSectionList.FindDocPos(SourcePos, Prev);
end;

function TWMLLite.DisplayPosToXy(DisplayPos: integer; var X, Y: integer): boolean;
begin
  Result:= FSectionList.CursorToXY(PaintPanel.Canvas, DisplayPos, X, integer(Y)); {integer() req'd for delphi 2}
end;

{----------------TWMLLite.SetProcessing}

procedure TWMLLite.SetProcessing(Value: boolean);
begin
  if FProcessing <> Value then begin
    FProcessing:= Value;
    if Assigned(FOnProcessing) and not (csLoading in ComponentState) then
      FOnProcessing(Self, FProcessing);
  end;
end;

{----------------TWMLLite.SetMarginWidth}

procedure TWMLLite.SetMarginWidth(Value: integer);
var
  OldPos: integer;
  OldCursor: TCursor;
begin
  if (Value <> FMarginWidth) and not FProcessing and (Value >= 0) then begin
    OldCursor:= Screen.Cursor;
    try
      Screen.Cursor:= crHourGlass;
      SetProcessing(True);
      FMarginWidth:= IntMin(Value, 200);
      FMarginWidthX:= FMarginWidth;
      if FSectionList.Count > 0 then begin
        OldPos:= Position;
        DoLogic;
        Position:= OldPos;
        Invalidate;
      end;
    finally
      Screen.Cursor:= OldCursor;
      SetProcessing(False);
    end;
  end;
end;

{----------------TWMLLite.SetMarginHeight}

procedure TWMLLite.SetMarginHeight(Value: integer);
var
  OldPos: integer;
  OldCursor: TCursor;
begin
  if (Value <> FMarginHeight) and not FProcessing and (Value >= 0) then begin
    OldCursor:= Screen.Cursor;
    try
      Screen.Cursor:= crHourGlass;
      SetProcessing(True);
      FMarginHeight:= IntMin(Value, 200);
      FMarginHeightX:= FMarginHeight;
      if FSectionList.Count > 0 then begin
        OldPos:= Position;
        DoLogic;
        Position:= OldPos;
        Invalidate;
      end;
    finally
      Screen.Cursor:= OldCursor;
      SetProcessing(False);
    end;
  end;
end;

procedure TWMLLite.SetServerRoot(Value: string);
begin
  Value:= Trim(Value);
  if (Length(Value) >= 1) and (Value[Length(Value)] = '\') then
    SetLength(Value, Length(Value) - 1);
  FServerRoot:= Value;
end;

procedure TWMLLite.HandleMeta(Sender: TObject; const HttpEq, Name, Content: string);
var
  DelTime, I: integer;
begin
  if Assigned(FOnMeta) then FOnMeta(Self, HttpEq, Name, Content);
  if Assigned(FOnMetaRefresh) then
    if CompareText(Lowercase(HttpEq), 'refresh') = 0 then begin
      I:= Pos(';', Content);
      if I > 0 then
        DelTime:= StrToIntDef(copy(Content, 1, I - 1), -1)
      else DelTime:= StrToIntDef(Content, -1);
      if DelTime < 0 then Exit
      else if DelTime = 0 then DelTime:= 1;
      I:= Pos('url=', Lowercase(Content));
      if I > 0 then
        FRefreshURL:= Copy(Content, I + 4, Length(Content) - I - 3)
      else FRefreshURL:= '';
      FRefreshDelay:= DelTime;
    end;
end;

procedure TWMLLite.SetOptions(Value: ThtmlViewerOptions);
begin
  if Value <> FOptions then begin
    FOptions:= Value;
    if Assigned(FSectionList) then
      with FSectionList do begin
        LinksActive:= htOverLinksActive in FOptions;
        if htNoLinkUnderline in FOptions then
          UnLine:= []
        else UnLine:= [fsUnderline];
        ShowDummyCaret:= htShowDummyCaret in FOptions;
      end;
  end;
end;

procedure TWMLLite.Repaint;
var
  I: integer;
begin
  for I:= 0 to FormControlList.count - 1 do
    with TFormControlObj(FormControlList.Items[I]) do
      if Assigned(TheControl) then
        TheControl.Hide;
  BorderPanel.BorderStyle:= bsNone;
  inherited Repaint;
end;

function TWMLLite.GetDragDrop: TDragDropEvent;
begin
  Result:= FOnDragDrop;
end;

procedure TWMLLite.SetDragDrop(const Value: TDragDropEvent);
begin
  FOnDragDrop:= Value;
  if Assigned(Value) then
    PaintPanel.OnDragDrop:= HTMLDragDrop
  else PaintPanel.OnDragDrop:= nil;
end;

procedure TWMLLite.HTMLDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if Assigned(FOnDragDrop) then
    FOnDragDrop(Self, Source, X, Y);
end;

function TWMLLite.GetDragOver: TDragOverEvent;
begin
  Result:= FOnDragOver;
end;

procedure TWMLLite.SetDragOver(const Value: TDragOverEvent);
begin
  FOnDragOver:= Value;
  if Assigned(Value) then
    PaintPanel.OnDragOver:= HTMLDragOver
  else PaintPanel.OnDragOver:= nil;
end;

procedure TWMLLite.HTMLDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Assigned(FOnDragOver) then
    FOnDragOver(Self, Source, X, Y, State, Accept);
end;

{----------------TPaintPanel.CreateIt}

constructor TPaintPanel.CreateIt(AOwner: TComponent; Viewer: TWMLLite);

begin
  inherited Create(AOwner);
  FViewer:= Viewer;
end;

{----------------TPaintPanel.Paint}

procedure TPaintPanel.Paint;
var
  MemDC: HDC;
  ABitmap: HBitmap;
  ARect: TRect;
  OldPal: HPalette;
begin
  if (FViewer as TWMLLite).DontDraw then Exit;
  if FViewer.DontDraw or (Canvas2 <> nil) then
    Exit;
  TWMLLite(FViewer).DrawBorder;
  OldPal:= 0;
  Canvas.Font:= Font;
  Canvas.Brush.Color:= Color;
  ARect:= Canvas.ClipRect;
  Canvas2:= TCanvas.Create; {paint on a memory DC}
  try
    MemDC:= CreateCompatibleDC(Canvas.Handle);
    ABitmap:= 0;
    try
      with ARect do begin
        ABitmap:= CreateCompatibleBitmap(Canvas.Handle, Right - Left, Bottom - Top);
        if (ABitmap = 0) and (Right - Left + Bottom - Top <> 0) then
          raise EOutOfResources.Create('Out of Resources');
        try
          SelectObject(MemDC, ABitmap);
          SetWindowOrgEx(memDC, Left, Top, nil);
          Canvas2.Handle:= MemDC;
          DoBackground(Canvas2, False);
          if Assigned(FOnPaint) then FOnPaint(Self);
          OldPal:= SelectPalette(Canvas.Handle, ThePalette, False);
          RealizePalette(Canvas.Handle);
          BitBlt(Canvas.Handle, Left, Top, Right - Left, Bottom - Top,
            MemDC, Left, Top, SrcCopy);
        finally
          if OldPal <> 0 then SelectPalette(MemDC, OldPal, False);
          Canvas2.Handle:= 0;
        end;
      end;
    finally
      DeleteDC(MemDC);
      DeleteObject(ABitmap);
    end;
  finally
    FreeAndNil(Canvas2);
  end;
end;

procedure TPaintPanel.DoBackground(ACanvas: TCanvas; WmErase: boolean);
var
  Image: TGpObject;
  Mask: TBitmap;
  H, W, WW, HH, HPos, BW, BH, DCx, DCy: integer;
  Pos: integer;
  OldBrush: HBrush;
  OldPal: HPalette;
  ARect: TRect;
  DC: HDC;
  CopyFromDC: boolean;
begin
  DC:= ACanvas.handle;
  if DC <> 0 then begin
    Pos:= (FViewer as TWMLLite).VScrollBarPosition * integer(VScale);
    ARect:= Canvas.ClipRect;

    OldPal:= SelectPalette(DC, ThePalette, False);
    RealizePalette(DC);
    ACanvas.Brush.Color:= Color or $2000000;
    OldBrush:= SelectObject(DC, ACanvas.Brush.Handle);
    try
      with FViewer as TWMLLite do begin
        HPos:= HScrollBar.Position;
        Image:= FSectionList.BackgroundBitmap;
        Mask:= FSectionList.BackgroundMask;
        if FSectionList.ShowImages and Assigned(Image) then try
          DCx:= 0;
          DCy:= 0;
          if Image is TBitmap then begin
            BW:= TBitmap(Image).Width;
            BH:= TBitmap(Image).Height;
          end
          else begin
            BW:= TGpImage(Image).Width;
            BH:= TGpImage(Image).Height;
          end;
          HH:= (Pos div BH) * BH - Pos;
          WW:= (HPos div BW) * BW - HPos;
          while HH < ARect.Top do
            Inc(HH, BH);
          while WW < ARect.Left do
            Inc(WW, BW);
          {to use the fast method, the bitmap must be drawn entirely within the
           viewable area}
          if ((HH + BH <= ARect.Bottom) and ((WW + BW <= ARect.Right)
            or ((WW = ARect.Left) and (BW >= ARect.Right - ARect.Left)))) then begin
            CopyFromDC:= True; {fast}
            DCx:= WW;
            DCy:= HH;
          end
          else CopyFromDC:= False;
          Dec(HH, BH);
          Dec(WW, BW);
          H:= HH;
          if (Mask <> nil) or (Image is TGpImage) then
            ACanvas.FillRect(ARect); {background for transparency}
          if CopyFromDC then begin
            if Image is TBitmap then begin
              if Mask = nil then
                BitBlt(DC, DCx, DCy, BW, BH, TBitmap(Image).Canvas.Handle, 0, 0, SRCCOPY)
              else begin
                BitBlt(dc, DCx, DCy, BW, BH, TBitmap(Image).Canvas.Handle, 0, 0, SrcInvert);
                BitBlt(dc, DCx, DCy, BW, BH, Mask.Canvas.Handle, 0, 0, SrcAnd);
                BitBlt(dc, DCx, DCy, BW, BH, TBitmap(Image).Canvas.Handle, 0, 0, SrcPaint);
              end;
            end
            else
              StretchDrawGpImage(DC, TGPImage(Image), DCx, DCy, BW, BH);
          end;
          repeat
            W:= WW;
            repeat
              if CopyFromDC then
                BitBlt(DC, W, H, BW, BH, DC, DCx, DCy, SRCCOPY)
              else if Image is TGpImage then
                StretchDrawGpImage(DC, TGPImage(Image), W, H, BW, BH)
              else if Mask = nil then
                BitBlt(DC, W, H, BW, BH, TBitmap(Image).Canvas.Handle, 0, 0, SRCCOPY)
              else begin
                BitBlt(dc, W, H, BW, BH, TBitmap(Image).Canvas.Handle, 0, 0, SrcInvert);
                BitBlt(dc, W, H, BW, BH, Mask.Canvas.Handle, 0, 0, SrcAnd);
                BitBlt(dc, W, H, BW, BH, TBitmap(Image).Canvas.Handle, 0, 0, SrcPaint);
              end;
              Inc(W, BW);
            until W >= ARect.Right;
            Inc(H, BH);
          until H >= ARect.Bottom;
        except
          ACanvas.FillRect(ARect);
        end
        else begin
          ACanvas.FillRect(ARect);
        end;
      end;
    finally
      SelectObject(DC, OldBrush);
      SelectPalette(DC, OldPal, False);
      RealizePalette(DC);
    end;
  end;
end;

procedure TPaintPanel.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result:= 1; {it's erased}
end;

{----------------TPaintPanel.WMLButtonDblClk}

procedure TPaintPanel.WMLButtonDblClk(var Message: TWMMouse);
begin
  if Message.Keys and MK_LButton <> 0 then
    TWMLLite(FViewer).HTMLMouseDblClk(Message);
end;

{----------------T32ScrollBar.SetParams}

procedure T32ScrollBar.SetParams(APosition, APage, AMin, AMax: Integer);
var
  ScrollInfo: TScrollInfo;
begin
  if (APosition <> FPosition) or (APage <> FPage) or (AMin <> FMin)
    or (AMax <> FMax) then
    with ScrollInfo do begin
      cbSize:= SizeOf(ScrollInfo);
      fMask:= SIF_ALL;
      if htShowVScroll in (Owner as TWMLLite).FOptions then
        fMask:= fMask or SIF_DISABLENOSCROLL;
      nPos:= APosition;
      nPage:= APage;
      nMin:= AMin;
      nMax:= AMax;
      SetScrollInfo(Handle, SB_CTL, ScrollInfo, True);
      FPosition:= APosition;
      FPage:= APage;
      FMin:= AMin;
      FMax:= AMax;
    end;
end;

procedure T32ScrollBar.SetPosition(Value: integer);
begin
  SetParams(Value, FPage, FMin, FMax);
end;

procedure T32ScrollBar.SetMin(Value: Integer);
begin
  SetParams(FPosition, FPage, Value, FMax);
end;

procedure T32ScrollBar.SetMax(Value: Integer);
begin
  SetParams(FPosition, FPage, FMin, Value);
end;

procedure T32ScrollBar.CNVScroll(var Message: TWMVScroll);
var
  SPos: integer;
  ScrollInfo: TScrollInfo;
  OrigPos: integer;
  TheChange: integer;
begin
  Parent.SetFocus;
  with TWMLLite(Parent) do begin
    ScrollInfo.cbSize:= SizeOf(ScrollInfo);
    ScrollInfo.fMask:= SIF_ALL;
    GetScrollInfo(Self.Handle, SB_CTL, ScrollInfo);
    if TScrollCode(Message.ScrollCode) = scTrack then begin
      OrigPos:= ScrollInfo.nPos;
      SPos:= ScrollInfo.nTrackPos;
    end
    else begin
      SPos:= ScrollInfo.nPos;
      OrigPos:= SPos;
      case TScrollCode(Message.ScrollCode) of
        scLineUp:
          Dec(SPos, SmallChange);
        scLineDown:
          Inc(SPos, SmallChange);
        scPageUp:
          Dec(SPos, LargeChange);
        scPageDown:
          Inc(SPos, LargeChange);
        scTop:
          SPos:= 0;
        scBottom:
          SPos:= (MaxVertical - PaintPanel.Height) div VScale;
      end;
    end;
    SPos:= IntMax(0, IntMin(SPos, (MaxVertical - PaintPanel.Height) div VScale));

    Self.SetPosition(SPos);

    FSectionList.SetYOffset(SPos * VScale);
    TheChange:= OrigPos - SPos;

    ScrollWindow(PaintPanel.Handle, 0, TheChange, nil, nil);
    PaintPanel.Update;
  end;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TWMLLite]);
end;

end.

