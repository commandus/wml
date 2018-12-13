unit
  EMemo;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o                                                              *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   Part of apooed                                                            *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jun 25 2001, Dec  3 2001                                    *
*   Last revision: Mar 29 2002                                                *
*   Lines        : 4455                                                        *
*   History      : Based on code of radu@rospotline.com                       *
*                                                                              *
*                                                                             *
********************************************************************************)
(*##*)

interface
{$IFNDEF VER80} { Delphi 1.0}
{$IFNDEF VER90} { Delphi 2.0}
{$IFNDEF VER93} { C++Builder 1.0}
{$IFNDEF VER100} { Borland Delphi 3.0}
{$DEFINE D4_} { Delphi 4.0 or higher}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  ExtCtrls, jclUnicode,
  util1, wmlc, util_xml, EMemoUndoRedo,
{$IFDEF USE_SAX}
  SAX,
{$ENDIF}
  Math;

type
  TGSStrings = TWideStringList;
  TGsString = WideString;

  // on exit event propagate to all memos
  TOnExitEvent = procedure(Sender: TObject) of object;

  TECustomMemo = class;

  TGsMemoEnvironment = class(TPersistent)
  private
    FOwner: TECustomMemo;
    FclText: TColor;
    FclTextBk: TColor;
    FclSelection: TColor;
    FclSelectionBk: TColor;
    FclRightEdge: TColor;
    FclHyperlink: TColor;
    FclHyperlinkBk: TColor;
  protected
    procedure Set_clText(Value: TColor);
    procedure Set_clTextBk(Value: TColor);
    procedure Set_clSelection(Value: TColor);
    procedure Set_clSelectionBk(Value: TColor);
    procedure Set_clRightEdge(Value: TColor);
    procedure Set_clHyperlink(Value: TColor);
    procedure Set_clHyperlinkBk(Value: TColor);
  public
    constructor CreateEnvironment(AOwner: TECustomMemo);
    procedure Assign(Source: TPersistent); override;
    procedure SetAsDefault;
    function GetAsString: String;
    procedure SetByString(const AValue: String);
  published
    property Hyperlink: TColor read FclHyperlink write Set_clHyperlink;
    property HyperlinkBackground: TColor read FclHyperlinkBk write Set_clHyperlinkBk;
    property SelectionBackground: TColor read FclSelectionBk write Set_clSelectionBk;
    property SelectionColor: TColor read FclSelection write Set_clSelection;
    property TextBackground: TColor read FclTextBk write Set_clTextBk;
    property TextColor: TColor read FclText write Set_clText;
    property RightEdgeColor: TColor read FclRightEdge write Set_clRightEdge;
  end;

  TGsGutter = class(TCustomControl)
  private
    FOwner: TECustomMemo;
    FBookmarkColor: TColor;
    FBookmarkBkColor: TColor;
    FShowNum: Boolean;
    FShowBookmarks: Boolean;
    FShowCaretPos: Boolean;
    FStartNum: Integer;
    FCaretPosXY: TPoint;
    FBevel, FSelLine: Boolean;
    FAlignment: TAlignment;
    FSpace: Integer;
    FZeroStart: Boolean;
    FDigits: Integer;
    FCaretPosBitmap: TGraphic;
    procedure SetShowNum(Value: Boolean);
    procedure SetShowBookmarks(Value: Boolean);
    procedure SetShowCaretPos(Value: Boolean);
    procedure SetCaretPosBitmap(Value: TGraphic);
    procedure SetStartNum(Value: Integer);
    procedure SetCaretPosXY(Value: TPoint);
    procedure SetBevel(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure SetSpace(Value: Integer);
    procedure SetZeroStart(Value: Boolean);
    procedure SetDigits(Value: Integer);
  protected
    procedure Paint; override;
    procedure DrawLineNums;
    procedure DrawBookmarks;
    procedure DrawCaretPos;

    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    constructor CreateGutter(AOwner: TECustomMemo);
    destructor Destroy; override;
    property Bevel: Boolean read FBevel write SetBevel default True;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Color;
    property LeadingDigits: Integer read FDigits write SetDigits default 0;
    property CaretPosBitmap: TGraphic read FCaretPosBitmap write SetCaretPosBitmap;
    property ShowNum: Boolean read FShowNum write SetShowNum default False;
    property ShowCaretPos: Boolean read FShowCaretPos write SetShowCaretPos default False;
    property ShowBookmarks: Boolean read FShowBookmarks write SetShowBookmarks default False;
    property Space: Integer read FSpace write SetSpace default 2;
    property StartNum: Integer read FStartNum write SetStartNum default 1;
    property CaretPosXY: TPoint read FCaretPosXY write SetCaretPosXY;
    property Width;
    property ZeroStart: Boolean read FZeroStart write SetZeroStart;
  end;

  TGsGutterOptions = class(TPersistent)
  private
    FOwner: TECustomMemo;
    FVisible: Boolean;
    function GetGutterLineNum: Boolean;
    function GetGutterBookmarks: Boolean;
    function GetGutterCaretPos: Boolean;
    function GetGutterCaretPosBitmap: TGraphic;
    procedure SetGutterLineNum(Value: Boolean);
    procedure SetGutterBookmarks(Value: Boolean);
    procedure SetGutterCaretPos(Value: Boolean);
    procedure SetGutterCaretPosBitmap(Value: TGraphic);
    function GetGutterBevel: Boolean;
    procedure SetGutterBevel(Value: Boolean);
    function GetGutterColor: TColor;
    procedure SetGutterColor(Value: TColor);
    function GetGutterFontColor: TColor;
    procedure SetGutterFontColor(Value: TColor);
    function GetGutterAlign: TAlignment;
    procedure SetGutterAlign(Value: TAlignment);
    procedure SetVisible(Value: Boolean);
    function GetGutterWidth: Integer;
    procedure SetGutterWidth(Value: Integer);
    function GetGutterSpace: Integer;
    procedure SetGutterSpace(Value: Integer);
    function GetGutterDigits: Integer;
    procedure SetGutterDigits(Value: Integer);
    function GetGutterZeroStart: Boolean;
    procedure SetGutterZeroStart(Value: Boolean);
  public
    constructor CreateGutterOptions(AOwner: TECustomMemo);
  published
    property Alignment: TAlignment read GetGutterAlign write SetGutterAlign;
    property Bevel: Boolean read GetGutterBevel write SetGutterBevel;
    property Color: TColor read GetGutterColor write SetGutterColor;
    property FontColor: TColor read GetGutterFontColor write SetGutterFontColor;
    property ShowLineNum: Boolean read GetGutterLineNum write SetGutterLineNum;
    property ShowBookmarks: Boolean read GetGutterBookmarks write SetGutterBookmarks;
    property ShowCaretPos: Boolean read GetGutterCaretPos write SetGutterCaretPos;
    property CaretPosBitmap: TGraphic read GetGutterCaretPosBitmap write SetGutterCaretPosBitmap;

    property Space: Integer read GetGutterSpace write SetGutterSpace;
    property Visible: Boolean read FVisible write SetVisible;
    property Width: Integer read GetGutterWidth write SetGutterWidth;
    property LeadingDigits: Integer read GetGutterDigits write SetGutterDigits;
    property ZeroStart: Boolean read GetGutterZeroStart write SetGutterZeroStart;
  end;

  TCharWidthArray = array of Integer;

  TGsKeyEvent = (k_Down, k_Press, k_Up, k_Mouse1, k_Mouse2, k_Mouse3, k_DoubleClick, k_None);
  TGsScrolls = (sbNone, sbBoth, sbHorizontal, sbVertical);

  TGsFindOptions = set of (foCaseSensitive, foWholeWords, foOriginFromCursor,
    foGlobalScope, foBackward,
    fRegularExpression, foXPath, foRegIgnoreNonSpacing, foRegSpaceCompress,
    foDirCreateDescFile, foDirCreateIdxFile, foDirExecProgram);

  TOnNextPageEvent = function(Sender: TObject; APage, ALine: Integer): Boolean of object;
  TTextScroledEvent = procedure(Sender: TObject; TopRow, BottomRow,
    LeftCol, MaxCols: Integer) of object;
  TGsDrawLineEvent = procedure(Sender: TObject; LineIndex: Integer;
    ACanvas: TCanvas; TextRect: TRect; var AllowSelfDraw: Boolean) of object;
  TGsHyperlinkClickEvent = procedure(Sender: TObject; Hyperlink: TGSString) of object;
  TGsMemoEvents = procedure(Sender: TObject; Shift: TShiftState; KeyEvent: TGsKeyEvent;
    Key: Word; CaretPos, MousePos: TPoint; AModified, AOverrideMode: Boolean) of object;
  TGsFindText = procedure(Sender: TObject; FindPos: TPoint;
    var ScrollToWord: Boolean) of Object;
  TGsReplaceText = procedure(Sender: TObject; FindPos: TPoint;
    var ScrollToWord, ReplaceText: Boolean) of Object;
  TGsOnSearchEnd = procedure(Sender: TObject; FindIt, ReplaceMode: Boolean) of object;
  TTimeDelayEvent = procedure(Sender: TObject) of object;
  TModifiedEvent = procedure(Sender: TObject) of object;

  TBookmarks = array['0'..'9'] of TPoint;


  TEMemoOptions = (emUseBoldTags);
  TEMemoOptionSet = set of TEMemoOptions;

  TECustomMemo = class(TCustomControl)
  private
    FCharWidths: TCharWidthArray;
    FOptions: TEMemoOptionSet;
    FEncoding: Integer;
    FBookmarks: TBookmarks;
    FKeyCommand: Char;
    FWindowHandle: HWND;
    FTracking: Boolean;
    FFullRedraw: Boolean;
    FVScrollVisible, FHScrollVisible: Boolean;
    FOnScrolled_V, FOnScrolled_H: TNotifyEvent;
    FOnTextScrolled: TTextScroledEvent;
    FOnModifiedTimeDelay: TTimeDelayEvent;
    FOnModified: TModifiedEvent;
    FModifiedSinceLastDelay: Boolean;
    FAutoComplete: Boolean;
{$IFDEF D4_}
    FOnMouseWheel: TMouseWheelEvent;
    FOnMouseWheelDown: TMouseWheelUpDownEvent;
    FOnMouseWheelUp: TMouseWheelUpDownEvent;
{$ENDIF}
    FOnPaint: TNotifyEvent;
    FScrollBars: TGsScrolls;
    FBorderStyle: TBorderStyle;
    FMaxScrollH: Integer;
    FWheelAccumulator: Integer;
    FRightEdge: Boolean;
    FRightEdgeCol: Integer;
    FGutterPan: TGsGutter;
    FEnvironment: TGsMemoEnvironment;
    FGutterOpt: TGsGutterOptions;
    FLines: TGSStrings;
    FBlockIndent: Integer;
    FChrW, FChrH: Integer;
    FTopLine, FVisLines, FVisCols: Integer;
    FSelStartNo, FSelEndNo, FSelStartOffs, FSelEndOffs: Integer;
    FSelected, FSelMouseDwn: Boolean;
    VScrollDelta, HScrollDelta, XMouse, YMouse: Integer;
//    ScrollTimer: TTimer;
    HPos, VPos, XSize, YSize: Integer;
    StartNo, EndNo, StartOffs, EndOffs: Integer;
    CaretPos, MousePos: TPoint;
    ShiftState: TShiftState;
    FDblClick, FNotHideHint: Boolean;
    FModified: Boolean;
    FOverwrite: Boolean;
    FHintWnd: THintWindow;
    FDropList: TListBox;
    FDropList_CharW, FDropList_CharH: Integer;  // FDropListLinesCount == FDropList_CharH
    FDropListTimeDelay, FDropTimeCount, FDropCol_CharW: Integer;
    FLastDropPos: TPoint;
    FDropListEvent: TNotifyEvent;

    FOnDrawLine: TGsDrawLineEvent;
    FOnHyperlinkClick: TGsHyperlinkClickEvent;
    FOnMemoEvents: TGsMemoEvents;
    FOnFindText: TGsFindText;
    FOnReplaceText: TGsReplaceText;
    FOnSearchEnd: TGsOnSearchEnd;

    FLineGliph: TBitmap;
    FFindUREPrepared: WideString; //  set by PrepareFindTextURE and UnPrepareFindTextURE

    FConvOnLoadOptions,                      // Entities2Char
    FConvOnSaveOptions: TEntityConvOptions;  // Char2Entities

    procedure SetFontWidth(const Value: Integer);
    procedure SetFontHeight(const Value: Integer);
    function GetCharWidthsPtr: Pointer;
    function GetWidthsLen: Integer;
    procedure SetWidthsLen(AValue: Integer);

    function GetVScrollPos: Integer;
    procedure SetVScrollPos(Pos: Integer);
    function GetVScrollMax: Integer;
    function GetHScrollPos: Integer;
    procedure SetHScrollPos(Pos: Integer);
    function GetHScrollMax: Integer;

    procedure SetModified(AValue: Boolean);
    procedure SetScrollBars(Value: TGsScrolls);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetLines(Value: TGsStrings);
    function GetTextInCharacterset(AConversion: TECharsetConversion): String;
    procedure SetTextInCharacterset(AConversion: TECharsetConversion; const AValue: String);
    procedure SetBlockIndent(Value: Integer);
    procedure SetRightEdge(Value: Boolean);
    procedure SetRightEdgeCol(Value: Integer);
    procedure TimeDelayProc(var Msg: TMessage);
    
    function GetCaretVPos: Integer;
    procedure SetCaretVPos(AValue: Integer);
    function GetCaretHPos: Integer;
    procedure SetCaretHPos(AValue: Integer);

    procedure SetDropTime(Value: Integer);
    function GetDropList: TStrings;
    procedure SetDropList(Value: TStrings);
    function GetSelBegin: TPoint;
    function GetSelEnd: TPoint;
    procedure SetSelBegin(Value: TPoint);
    procedure SetSelEnd(Value: TPoint);
    procedure SetSelected(AValue: Boolean);
    procedure SetEncoding(AValue: Integer);
//    procedure EditWndProc(var Message: TMessage);

  protected
    FUndoRedoMgr: TUndoRedoManager;
    procedure SetScreenCursorIfChanged(ACursor: TCursor);
    procedure DoExit; override;
    procedure InitMemoObjects;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure UpdateTimer;
    procedure UpdateScrollBars;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMGetDlgCode(var AMessage: TWMGetDlgCode); message WM_GETDLGCODE;
{$IFDEF D4_}
    procedure CMMouseWheel(var AMessage: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint); dynamic;
    function MouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; dynamic;
    function MouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; dynamic;
{$ENDIF}
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DragDropSelection(AtPos: TPoint; CopyMode: Boolean);
    procedure DblClick; override;
    procedure SetVPos(p: Integer);
    procedure SetHPos(p: Integer);
    procedure ScrollChildren(dx, dy: Integer);
    procedure UpdateChildren;
    procedure UpdateCharBounds;
    // return x coordinate where line selection must continues
    function FormatLine(ALine: Integer; ACanvas: TCanvas; R: TRect): Integer;
    procedure Paint; override;
    procedure DrawLine(CanvasSupport: TCanvas; ALine, AYOffset: Integer);
    procedure DrawVisible;
    procedure GetSelBounds(var StartNo, EndNo, StartOffs, EndOffs: Integer);
//    procedure ScrollOnTimer(Sender: TObject);
    procedure SetCaretPosXY;
    procedure SetCaretPosXYFocus;
    procedure KeyboardCaretNav(ShiftState: TShiftState; Direction: Word);
    procedure ShowTextHint(X, Y: Integer; HintMsg: TGSString);
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure KeyPress(var Key: Char); override;
    procedure DropListKeyPress(Sender: TObject; var Key: Char);
    procedure DropListExit(Sender: TObject);
    procedure DropListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    function FindReplaceProc(TextToFind: TGSString; FindOptions: TGsFindOptions;
      ReplaceMode: Boolean; var ReplaceText: Boolean): Boolean;
// function printw(lpString: PWideChar; nCount: Integer; var lpRect: TRect): Integer;
   function printcanvasVisible(AHDC: HDC; lpString: PWideChar; nCount: Integer; var lpRect: TRect): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetRowColAtPos(X, Y: Integer; var Row, Col: Integer);
    procedure ScrollTo(X, Y: Integer);
    procedure ShowDropWindow;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    function GoToBookmark(ABookmark: Char): Boolean;
    procedure SetBookmark(ABookmark: Char);
    procedure PasteFromClipboard;

    function GetSelText: TGSString;
    procedure SelectAll;
    function GetTextBetweenPos(AFrom, ATo: TPoint): TGSString;
    function GetWordAtPos(Col, Row: Integer; var XBegin: Integer): TGSString;
    function GetLeftTextBeforeWordAtPos(Col, Row: Integer; var XBegin: Integer): TGSString;
    function GetTextAtPos(AStart, AFinish: TPoint; const AStringDelimiter: TGSString): TGSString;

    procedure DrawDirect2Canvas(ACanvas: TCanvas; R: TRect; AOnNextPage: TOnNextPageEvent;
      const ACaption: String);

    procedure UpdateFontMetrics;  // set font and create line glyph

    // modified
    procedure DeleteBetweenPos(AFrom, ATo: TPoint);
    procedure DeleteSelection;
    // procedure ReplaceSelectionWith(const ANewValue: TGSString); - Delete then Insert
    procedure InsertTextAtPos(const S: TGSString; Col, Row: Integer);
    procedure InsertText(const S: TGSString);
    procedure Clear;

    procedure PrepareFindTextURE(const AFindOptions: TGsFindOptions);
    procedure UnPrepareFindTextURE;
    function FindText(TextToFind: TGSString; FindOptions: TGsFindOptions): Boolean;
    function ReplaceText(TextToFind, TextToReplace: TGSString; FindOptions: TGsFindOptions): Boolean;
    procedure SaveToStream(AStream: TStream);
    procedure SaveToFile(const AFileName: TGSString);
    procedure LoadFromFile(const AFileName: TGSString);

    property Canvas;
    property WidthsLen: Integer read GetWidthsLen write SetWidthsLen;
    property CharWidthsPtr: Pointer read GetCharWidthsPtr;
    property Encoding: Integer read FEncoding write SetEncoding;
    property SelBegin: TPoint read GetSelBegin write SetSelBegin;
    property SelEnd: TPoint read GetSelEnd write SetSelEnd;
    property Selected: Boolean read FSelected write SetSelected;
    property CaretPos_H: Integer read GetCaretHPos write SetCaretHPos;
    property CaretPos_V: Integer read GetCaretVPos write SetCaretVPos;
    property FontHeight: Integer read FChrH write SetFontHeight;
    property FontWidth: Integer read FChrW write SetFontWidth;
    property HideHintWindow: Boolean read FNotHideHint write FNotHideHint;
    property HintWindow: THintWindow read FHintWnd write FHintWnd;
    property Modified: Boolean read FModified write SetModified;
    property Overwrite: Boolean read FOverwrite write FOverwrite;
    property ScrollBars: TGsScrolls read FScrollBars write SetScrollBars default sbBoth;
    property ScrollMax_H: Integer read GetHScrollMax;
    property ScrollMax_V: Integer read GetVScrollMax;
    property ScrollPos_H: Integer read GetHScrollPos write SetHScrollPos;
    property ScrollPos_V: Integer read GetVScrollPos write SetVScrollPos;
    property TopLine: Integer read FTopLine;
    property VisibleLines: Integer read FVisLines;
    property VisibleColumns: Integer read FVisCols;
    { Published declarations }
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property DropListCharHeight: Integer read FDropList_CharH write FDropList_CharH;
    property DropListCharWidth: Integer read FDropList_CharW write FDropList_CharW;

    property DropListItems: TStrings read GetDropList write SetDropList;
    property DropListTimeDelay: Integer read FDropListTimeDelay write SetDropTime default 0;
    property DropListColumnCharWidth: Integer read FDropCol_CharW write FDropCol_CharW;
    property EnvironmentOptions: TGsMemoEnvironment read FEnvironment write FEnvironment;
    property FullRedraw: Boolean read FFullRedraw write FFullRedraw default False;
    property GutterOptions: TGsGutterOptions read FGutterOpt write FGutterOpt;
    property Lines: TGsStrings read FLines write SetLines;
    property TextInCharacterset[AConversion: TECharsetConversion]: String read GetTextInCharacterSet write SetTextInCharacterSet;
    property RightEdge: Boolean read FRightEdge write SetRightEdge default False;
    property RightEdgeCol: Integer read FRightEdgeCol write SetRightEdgeCol default 80;
    property BlockIndent: Integer read FBlockIndent write SetBlockIndent;
    property Tracking: Boolean read FTracking write FTracking default False;
    property Options: TEMemoOptionSet read FOptions write FOptions;

    property OnDrawLine: TGsDrawLineEvent read FOnDrawLine write FOnDrawLine;
    property OnDropListDown: TNotifyEvent read FDropListEvent write FDropListEvent;
    property OnFindText: TGsFindText read FOnFindText write FOnFindText;
    property OnHyperlinkClick: TGsHyperlinkClickEvent read FOnHyperlinkClick write FOnHyperlinkClick;
    property OnMemoEvents: TGsMemoEvents read FOnMemoEvents write FOnMemoEvents;
{$IFDEF D4_}
    property OnMouseWheel: TMouseWheelEvent read FOnMouseWheel write FOnMouseWheel;
    property OnMouseWheelDown: TMouseWheelUpDownEvent read FOnMouseWheelDown write FOnMouseWheelDown;
    property OnMouseWheelUp: TMouseWheelUpDownEvent read FOnMouseWheelUp write FOnMouseWheelUp;
{$ENDIF}
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnReplaceText: TGsReplaceText read FOnReplaceText write FOnReplaceText;
    property OnScrolled_H: TNotifyEvent read FOnScrolled_H write FOnScrolled_H;
    property OnScrolled_V: TNotifyEvent read FOnScrolled_V write FOnScrolled_V;
    property OnSearchEnd: TGsOnSearchEnd read FOnSearchEnd write FOnSearchEnd;
    property OnTextScrolled: TTextScroledEvent read FOnTextScrolled write FOnTextScrolled;
    property OnModifiedTimeDelay: TTimeDelayEvent read FOnModifiedTimeDelay write FOnModifiedTimeDelay;
    property OnModified: TModifiedEvent read FOnModified write FOnModified;
    property ModifiedSinceLastDelay: Boolean read FModifiedSinceLastDelay write FModifiedSinceLastDelay;
//    property WindowHandle: HWND read FWindowHandle;
    property AutoComplete: Boolean read FAutoComplete write FAutoComplete;
    // May 2004
    property UndoRedoMgr: TUndoRedoManager read FUndoRedoMgr;
    // Oct 2 2004
    property ConvOnLoadOptions: TEntityConvOptions read FConvOnLoadOptions write FConvOnLoadOptions;
    property ConvOnSaveOptions: TEntityConvOptions read FConvOnSaveOptions write FConvOnSaveOptions;

    procedure Undo;
    procedure Redo;
  end;

  TEMemo = class(TECustomMemo)
  published
    property Align;
    property BorderStyle;
    property Color;
    property Cursor;
    property DragCursor;
    property DragMode;
    property DropListCharHeight;
    property DropListCharWidth;
    property DropListItems;
    property DropListTimeDelay;
    property DropListColumnCharWidth;
    property Enabled;
    property EnvironmentOptions;
    property Font;
    property FullRedraw;
    property GutterOptions;
    property HelpContext;
    property Hint;
    property Lines;
    property ParentShowHint;
    property ParentColor;
    property RightEdge;
    property RightEdgeCol;
    property ShowHint;
    property TabStop;
    property TabOrder;
    property BlockIndent;
    property Tracking;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawLine;
    property OnDropListDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnFindText;
    property OnHyperlinkClick;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMemoEvents;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
{$IFDEF D4_}
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
{$ENDIF}
    property OnPaint;
    property OnReplaceText;
    property OnScrolled_H;
    property OnScrolled_V;
    property OnSearchEnd;
    property OnStartDrag;
    property OnTextScrolled;
  end;

{.$R GSMemo.res}

var
  RegularURL: TGSString = '([Ff][Tt][Pp]|[Hh][Tt][Tt][Pp])://([_a-zA-Z\d\-]+(\.[_a-zA-Z\d\-]+)+)((/[_a-zA-Z\d\-\\\.\?\&\%\\~=]+)+)*';
  RegularEmail: TGSString = '[_a-zA-Z\d\-\.]+@[_a-zA-Z\d\-]+(\.[_a-zA-Z\d\-]+)+';

const
  clBookmarkColor = clOlive;
  clBookmarkBkColor = clGreen;
  clCaretPosColor = clRed;
  clSelColor = clHighlightText;
  clSelColorBk = clHighlight;
  clRightEdge = clGray;
  clGutter = clBtnFace;
  clGutterFont = clBtnText;
  clTextColor = clWindowText;
  clTextColorBk = clWindow;
  clHyperlink = clBlue;
  clHyperlinkBk = clWindow;
  DT_DRAWLINE = DT_NOPREFIX or DT_LEFT or DT_SINGLELINE or DT_VCENTER;

  MEMO_NUMBERLINE_FONTSIZE = 8;
  MEMO_BOOKMARK_FONTSIZE   = 8;
  MEMO_CARET_FONTSIZE   = 8;
  MEMO_DROPLIST_FONTSIZE = 8;
  HINT_FONTSIZE = 8;

  DEF_UNDO_DEPTH = 8; // 1024;

resourcestring
  CARET_TIME_ERROR = 'Caret timer error';
  CARET_CANTCREATE = 'Can not create caret';
  CARET_CANT_SETPOS= 'Caret can not set position';
  CARET_CANT_SHOW  = 'Caret can not be show';
  S_IMAGE_HINT     = 'Image: ';
  S_LINK_HINT      = 'Link to: ';
  MEMO_NUMBERLINE_FONT = 'MS Sans Serif';
  MEMO_BOOKMARK_FONT   = 'Courier';
  MEMO_CARET_FONT   = 'Courier';
  MEMO_DROPLIST_FONT = 'MS Sans Serif';
  HINT_FONT = 'MS Sans Serif';

// replace tabs

function HideSpecialSymbols(AWS: TWideStrings): Integer;

procedure Register;

implementation

uses
  Clipbrd,
{$IFDEF USE_DOM}
  ActiveX, msxmldom, msxml,
{$ENDIF}
  xmlParse, EMemoCode;

var
  SavedType: TGSString;
  RepPos: TPoint;

(***)

procedure CtrlByTagUpdate(AControl: TControl);
begin
  if AControl.Tag > 10000 then
    AControl.Top:= 10000
  else
    if AControl.Tag < -10000 then
      AControl.Top:= -10000
    else
      AControl.Top:= AControl.Tag;
end;

(* TGsMemoEnvironment ***********************************************************************)

constructor TGsMemoEnvironment.CreateEnvironment(AOwner: TECustomMemo);
begin
  inherited Create;
  FOwner:= AOwner;
  FclText:= clTextColor;
  FclTextBk:= clTextColorBk;
  FclSelection:= clSelColor;
  FclSelectionBk:= clSelColorBk;
  FclRightEdge:= clRightEdge;
  FclHyperlink:= clHyperlink;
  FclHyperlinkBk:= clHyperlinkBk;
end;

procedure TGsMemoEnvironment.Set_clText(Value: TColor);
begin
  if FclText <> Value then begin
    FclText:= Value;
    if FOwner <> nil
    then FOwner.Invalidate;
  end;
end;

procedure TGsMemoEnvironment.Set_clTextBk(Value: TColor);
begin
  if FclTextBk <> Value then begin
    FclTextBk:= Value;
    if FOwner <> nil
    then FOwner.Invalidate;
  end;
end;

procedure TGsMemoEnvironment.Set_clSelection(Value: TColor);
begin
  if FclSelection <> Value then begin
    FclSelection:= Value;
    if FOwner <> nil
    then FOwner.Invalidate;
  end;
end;

procedure TGsMemoEnvironment.Set_clSelectionBk(Value: TColor);
begin
  if FclSelectionBk <> Value then begin
    FclSelectionBk:= Value;
    if FOwner <> nil
    then FOwner.Invalidate;
  end;
end;

procedure TGsMemoEnvironment.Set_clRightEdge(Value: TColor);
begin
  if FclRightEdge <> Value then begin
    FclRightEdge:= Value;
    if FOwner <> nil
    then FOwner.Invalidate;
  end;
end;

procedure TGsMemoEnvironment.Set_clHyperlink(Value: TColor);
begin
  if FclHyperlink <> Value then begin
    FclHyperlink:= Value;
    if FOwner <> nil
    then FOwner.Invalidate;
  end;
end;

procedure TGsMemoEnvironment.Set_clHyperlinkBk(Value: TColor);
begin
  if FclHyperlinkBk <> Value then begin
    FclHyperlinkBk:= Value;
    if FOwner <> nil
    then FOwner.Invalidate;
  end;
end;

procedure TGsMemoEnvironment.Assign(Source: TPersistent);
var
  Src: TGsMemoEnvironment;
begin
  if Source is TGsMemoEnvironment then begin
    Src:= TGsMemoEnvironment(Source);
    FclText:= Src.TextColor;
    FclTextBk:= Src.TextBackground;
    FclSelection:= Src.SelectionColor;
    FclSelectionBk:= Src.SelectionBackground;
    FclRightEdge:= Src.RightEdgeColor;
    FclHyperlink:= Src.Hyperlink;
    FclHyperlinkBk:= Src.HyperlinkBackground;
  end else
    inherited Assign(Source);
end;

procedure TGsMemoEnvironment.SetAsDefault;
begin
  FclText:= clTextColor;
  FclTextBk:= clTextColorBk;
  FclSelection:= clSelColor;
  FclSelectionBk:= clSelColorBk;
  FclRightEdge:= clRightEdge;
  if FOwner <> nil
  then FOwner.Invalidate;
end;

function TGsMemoEnvironment.GetAsString: String;
begin
  Result:= Format('%.8x%.8x%.8x%.8x%.8x%.8x%.8x', [FclText, FclTextBk, FclSelection,
    FclSelectionBk, FclRightEdge, FclHyperlink, FclHyperlinkBk]);
end;

procedure TGsMemoEnvironment.SetByString(const AValue: String);
begin
  TextColor:= StrToIntDef('$' + Copy(AValue, 1, 8), TextColor);
  TextBackground:= StrToIntDef('$' + Copy(AValue, 9, 8), TextBackground);
  SelectionColor:= StrToIntDef('$' + Copy(AValue, 17, 8), SelectionColor);
  SelectionBackground:= StrToIntDef('$' + Copy(AValue, 25, 8), SelectionBackground);
  RightEdgeColor:= StrToIntDef('$' + Copy(AValue, 33, 8), RightEdgeColor);
  Hyperlink:= StrToIntDef('$' + Copy(AValue, 41, 8), Hyperlink);
  HyperlinkBackground:= StrToIntDef('$' + Copy(AValue, 49, 8), HyperlinkBackground);
end;

(* TGsGutter ********************************************************************************)

constructor TGsGutter.CreateGutter(AOwner: TECustomMemo);
begin
  inherited Create(AOwner);
  FBookmarkColor:= clBookmarkColor;
  FBookmarkBkColor:= clBookmarkBkColor;
  FOwner:= AOwner;
  FShowNum:= False;
  FStartNum:= 1;
  FAlignment:= taLeftJustify;
  FSpace:= 2;
  FBevel:= True;
  ParentColor:= False;
  ParentShowHint:= False;
  Color:= clGutter;
  Font.Color:= clGutterFont;
  Width:= 26;
  FCaretPosBitmap:= TBitmap.Create;
end;

destructor TGsGutter.Destroy;
begin
  FCaretPosBitmap.Free;
  inherited ;
end;

procedure TGsGutter.SetShowNum(Value: Boolean);
begin
  if FShowNum <> Value then begin
    FShowNum:= Value;
    Invalidate;
  end;
end;

procedure TGsGutter.SetShowBookmarks(Value: Boolean);
begin
  if FShowBookmarks <> Value then begin
    FShowBookmarks:= Value;
    Invalidate;
  end;
end;

procedure TGsGutter.SetShowCaretPos(Value: Boolean);
begin
  if FShowCaretPos <> Value then begin
    FShowCaretPos:= Value;
    Invalidate;
  end;
end;

procedure TGsGutter.SetCaretPosBitmap(Value: TGraphic);
begin
  if FCaretPosBitmap <> Value then begin
    FCaretPosBitmap.Assign(Value);
    Invalidate;
  end;
end;

procedure TGsGutter.SetStartNum(Value: Integer);
begin
  if Value < 1 then Value:= 1;
  FStartNum:= Value;
end;

procedure TGsGutter.SetCaretPosXY(Value: TPoint);
var
  lineno: Integer;
begin
  // set column (useless)
  FCaretPosXY.Y:= Value.Y;
  // set line
  lineno:= Value.X - FStartNum + 1;
  if FCaretPosXY.X <> lineno then begin
    FCaretPosXY.X:= lineno;
    if Visible
    then Invalidate;
  end;
end;

procedure TGsGutter.SetBevel(Value: Boolean);
begin
  if FBevel <> Value then
  begin
    FBevel:= Value;
    Invalidate;
  end;
end;

procedure TGsGutter.SetSpace(Value: Integer);
begin
  if Value < 1 then Value:= 1;
  if Value > (Width div 3) then Value:= Width div 3;
  if FSpace <> Value then begin
    FSpace:= Value;
    Invalidate;
  end;
end;

procedure TGsGutter.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment:= Value;
    Invalidate;
  end;
end;

procedure TGsGutter.SetZeroStart(Value: Boolean);
begin
  if FZeroStart <> Value then begin
    FZeroStart:= Value;
    Invalidate;
  end;
end;

procedure TGsGutter.SetDigits(Value: Integer);
begin
  if Value < 0 then Value:= 0;
  if Value > 8 then Value:= 8;
  if FDigits <> Value then begin
    FDigits:= Value;
    Invalidate;
  end;
end;

procedure TGsGutter.Paint;
var
  W: Integer;
begin
  if FSpace > (Width div 3) then FSpace:= Width div 3;
  if Width < 14 then Width:= 14;
  with Canvas do begin
    Brush.Color:= Self.Color;
    FillRect(ClientRect);
    W:= ClientWidth;
    if FOwner <> nil then begin
      Pen.Color:= FOwner.Color;
      MoveTo(W - 1, 0);
      LineTo(W - 1, ClientHeight);
    end;
    if FBevel then begin
      Pen.Color:= clBtnHighlight;
      MoveTo(W - 3, 0);
      LineTo(W - 3, ClientHeight);
      Pen.Color:= clBtnShadow;
      MoveTo(W - 2, 0);
      LineTo(W - 2, ClientHeight);
    end;
  end;
  DrawLineNums;
  DrawBookmarks;
  DrawCaretPos;
end;

procedure TGsGutter.DrawLineNums;
var
  RC: TRect;
  I, MaxI, W, H, ZeroL: Integer;
//  DT_Params: Word;
  S: TGSString;
begin
  if not FShowNum then Exit;
  W:= ClientWidth - FSpace - 1;
  if FBevel
  then Dec(W, 3);
  with Canvas do begin
    if FOwner <> nil then begin
      Font.Name:= MEMO_NUMBERLINE_FONT;
      Font.Size:= MEMO_NUMBERLINE_FONTSIZE;
      Font.Color:= Self.Font.Color;
      Brush.Color:= Self.Color;
      H:= FOwner.FChrH;
      MaxI:= FOwner.FVisLines;
{     DT_Params:= DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
      case FAlignment of
        taLeftJustify: DT_Params:= DT_LEFT or DT_Params;
        taCenter: DT_Params:= DT_CENTER or DT_Params;
        taRightJustify: DT_Params:= DT_RIGHT or DT_Params;
      end;
}
      for I:= 0 to MaxI do begin
        if FZeroStart then
          S:= IntToStr(FStartNum + I - 1)
        else
          S:= IntToStr(FStartNum + I);
        for ZeroL:= Length(S) to FDigits do S:= '0' + S;
        RC:= Rect(2, I * H, W, (I * H) + H);
        FillRect(RC);
        ExtTextOutW(Canvas.Handle, RC.Left, RC.Top, ETO_OPAQUE, Nil,
         PWideChar(S), Length(S), Nil);
      end;
    end;
  end;
end;

procedure TGsGutter.DrawBookmarks;
var
  RC: TRect;
  I, MaxI, W, H, LW: Integer;
  S: TGSString;
  b: Char;
//  DT_Params: Word;
begin
  if not FShowBookmarks then Exit;
  W:= ClientWidth - FSpace - 1;
  if FBevel
  then Dec(W, 3);
  with Canvas do begin
    if FOwner <> nil then begin
      Font.Name:= MEMO_BOOKMARK_FONT;
      Font.Size:= MEMO_BOOKMARK_FONTSIZE;
      Font.Color:= Self.Font.Color;
      H:= FOwner.FChrH;
      MaxI:= FOwner.FVisLines;
      {
      DT_Params:= DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
      case FAlignment of
        taLeftJustify: DT_Params:= DT_LEFT or DT_Params;
        taCenter: DT_Params:= DT_CENTER or DT_Params;
        taRightJustify: DT_Params:= DT_RIGHT or DT_Params;
      end;
      }
      LW:= TextWidth('9') + 2;
      for I:= 0 to MaxI do begin
        Brush.Color:= Self.Color;
        RC:= Rect(2, I * H, W, (I * H) + H);
        FillRect(RC);
        for b:= '0' to '9' do begin
          if FOwner.FBookmarks[b].x = FStartNum + i - 1 then begin
            S:= b;
            Brush.Color:= FBookmarkBkColor;
            RC:= Rect((W - LW) div 2, I * H, W - (W - LW) div 2, (I * H) + H);
            Inc(RC.Top, 2); Dec(RC.Bottom, 2);
            Rectangle(RC.Left, RC.Top, RC.Right, RC.Bottom);

            Dec(RC.Left, 2); Dec(RC.Top, 2); Dec(RC.Right, 2); Dec(RC.Bottom, 2);
            Brush.Color:= FBookmarkColor;
            Rectangle(RC.Left, RC.Top, RC.Right, RC.Bottom);
            Inc(RC.Left, 4); Inc(RC.Top); Dec(RC.Right); Dec(RC.Bottom);
            Inc(RC.Left, ((RC.Right - RC.Left) - LW) div 2);
            ExtTextOutW(Canvas.Handle, RC.Left, RC.Top, ETO_OPAQUE, Nil,
              PWideChar(S), Length(S), Nil);
            Break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TGsGutter.DrawCaretPos;
var
  RC: TRect;
begin
  if not FShowCaretPos then Exit;
  with Canvas do begin
    if FOwner <> nil then begin
      if Assigned(FCaretPosBitmap) then begin
        Canvas.CopyMode:= cmSRCAnd;
        Canvas.Draw(2, FCaretPosXY.X * FOwner.FChrH, FCaretPosBitmap);
      end else begin
        Brush.Color:= clCaretPosColor;
        RC:= Rect(2, FCaretPosXY.X * FOwner.FChrH,
          FOwner.FChrW, ((FCaretPosXY.X + 1) * FOwner.FChrH));
        FillRect(RC);
      end;
    end;
  end;
end;

procedure TGsGutter.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SN, EN, SO, EO, RNo, CNo: Integer;
  S: TGSString;
begin
  inherited MouseUp(Button, Shift, X, Y);
  FSelLine:= False;
  if (X < Width - 1) and (X > 2 * (Width div 3)) then FSelLine:= True;
  if FSelLine and (FOwner <> nil) then
    with FOwner do begin
      GetRowColAtPos(X, Y, RNo, CNo);
      S:= '';
      if RNo <= FLines.Count - 1 then S:= FLines[RNo];
      if ssShift in Shift then begin
        GetSelBounds(SN, EN, SO, EO);
        if RNo < SN then begin
          FSelStartNo:= RNo;
          FSelStartOffs:= 0;
          FSelEndNo:= EN;
          FSelEndOffs:= EO;
          CaretPos.x:= RNo;
          CaretPos.y:= 0;
          FSelected:= True;
          DrawVisible;
          SetFocus;
        end else
          if RNo > EN then begin
            FSelStartNo:= SN;
            FSelStartOffs:= 0;
            FSelEndNo:= RNo;
            FSelEndOffs:= Length(S);
            CaretPos.x:= RNo;
            CaretPos.y:= 0;
            FSelected:= True;
            DrawVisible;
            SetFocus;
          end;
      end else begin
        FSelStartNo:= RNo;
        FSelEndNo:= RNo;
        CaretPos.x:= RNo;
        CaretPos.y:= 0;
        FSelStartOffs:= 0;
        FSelEndOffs:= Length(S);
        FSelected:= (FSelStartOffs <> FSelEndOffs);
        DrawVisible;
        SetFocus;
      end;
    end;
end;

procedure TGsGutter.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  FSelLine:= False;
  if (X < Width - 1) and (X > 2 * (Width div 3))
  then FSelLine:= True;
  {
  if FSelLine
  then Cursor:= crDrag
  else Cursor:= crDefault;
  }
end;

(* TGsGutterOptions ***************************************************************************)

constructor TGsGutterOptions.CreateGutterOptions(AOwner: TECustomMemo);
begin
  inherited Create;
  FOwner:= AOwner;
  FVisible:= True;
end;

function TGsGutterOptions.GetGutterSpace: Integer;
begin
  Result:= 1;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.Space;
end;

procedure TGsGutterOptions.SetGutterSpace(Value: Integer);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      FOwner.FGutterPan.Space:= Value;
end;

function TGsGutterOptions.GetGutterDigits: Integer;
begin
  Result:= 1;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.LeadingDigits;
end;

procedure TGsGutterOptions.SetGutterDigits(Value: Integer);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      FOwner.FGutterPan.LeadingDigits:= Value;
end;

function TGsGutterOptions.GetGutterZeroStart: Boolean;
begin
  Result:= False;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.ZeroStart;
end;

procedure TGsGutterOptions.SetGutterZeroStart(Value: Boolean);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      FOwner.FGutterPan.ZeroStart:= Value;
end;

procedure TGsGutterOptions.SetVisible(Value: Boolean);
begin
  FVisible:= Value;
  if FOwner <> nil then FOwner.Invalidate;
end;

function TGsGutterOptions.GetGutterAlign: TAlignment;
begin
  Result:= taLeftJustify;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.Alignment;
end;

procedure TGsGutterOptions.SetGutterAlign(Value: TAlignment);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      FOwner.FGutterPan.Alignment:= Value;
end;

function TGsGutterOptions.GetGutterWidth: Integer;
begin
  Result:= 16;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.Width;
end;

procedure TGsGutterOptions.SetGutterWidth(Value: Integer);
begin
  if Value < 12 then Value:= 12;
  if Value > 48 then Value:= 48;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
    begin
      FOwner.FGutterPan.Width:= Value;
      FOwner.Invalidate;
    end;
end;

function TGsGutterOptions.GetGutterColor: TColor;
begin
  Result:= clNone;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.Color;
end;

procedure TGsGutterOptions.SetGutterColor(Value: TColor);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      if FOwner.FGutterPan.Color <> Value then
        FOwner.FGutterPan.Color:= Value;
end;

function TGsGutterOptions.GetGutterFontColor: TColor;
begin
  Result:= clNone;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.Font.Color
    else
      Result:= clNone;
end;

procedure TGsGutterOptions.SetGutterFontColor(Value: TColor);
begin
  if FOwner <> nil then begin
    if FOwner.FGutterPan <> nil then begin
      if FOwner.FGutterPan.Font.Color <> Value then begin
        FOwner.FGutterPan.Font.Color:= Value;
        FOwner.FGutterPan.Invalidate;
      end;
    end;
  end;
end;

function TGsGutterOptions.GetGutterLineNum: Boolean;
begin
  Result:= False;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.ShowNum
end;

function TGsGutterOptions.GetGutterBookmarks: Boolean;
begin
  Result:= False;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.ShowBookmarks;
end;

function TGsGutterOptions.GetGutterCaretPos: Boolean;
begin
  Result:= False;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.ShowCaretPos;
end;

function TGsGutterOptions.GetGutterCaretPosBitmap: TGraphic;
begin
  Result:= Nil;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.CaretPosBitmap;
end;

procedure TGsGutterOptions.SetGutterLineNum(Value: Boolean);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      if FOwner.FGutterPan.ShowNum <> Value then
        FOwner.FGutterPan.ShowNum:= Value;
end;

procedure TGsGutterOptions.SetGutterBookmarks(Value: Boolean);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      FOwner.FGutterPan.ShowBookmarks:= Value;
end;

procedure TGsGutterOptions.SetGutterCaretPos(Value: Boolean);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      FOwner.FGutterPan.ShowCaretPos:= Value;
end;

procedure TGsGutterOptions.SetGutterCaretPosBitmap(Value: TGraphic);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      FOwner.FGutterPan.CaretPosBitmap:= Value;
end;

function TGsGutterOptions.GetGutterBevel: Boolean;
begin
  Result:= False;
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      Result:= FOwner.FGutterPan.Bevel;
end;

procedure TGsGutterOptions.SetGutterBevel(Value: Boolean);
begin
  if FOwner <> nil then
    if FOwner.FGutterPan <> nil then
      FOwner.FGutterPan.Bevel:= Value;
end;

(* TECustomMemo ******************************************************************************)

function TECustomMemo.printcanvasVisible(AHDC: HDC; lpString: PWideChar; nCount: Integer; var lpRect: TRect): Integer;
begin
  Result:= Integer(ExtTextOutW(AHDC, lpRect.Left, lpRect.Top, ETO_CLIPPED, @lpRect,
    lpString, ncount, CharWidthsPtr));  //
end;

{
function TECustomMemo.printw(lpString: PWideChar; nCount: Integer; var lpRect: TRect): Integer;
begin
  // ETO_OPAQUE @lpRect
  Result:= Integer(ExtTextOutW(Canvas.Handle, lpRect.Left, lpRect.Top, ETO_OPAQUE, Nil,
    lpString, ncount, CharWidthsPtr));  // CharWidthsPtr
end;
}

constructor TECustomMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // set width of line in characters for spac interval values
  WidthsLen:= 512;
  // line glyph assigned in UpdateFontMetrics()
  FLineGliph:= Nil;
  // then set width of character spacing value
  FillChar(FBookmarks, Sizeof(FBookmarks), #255);
  FKeyCommand:= #0;
  // events
  FOnScrolled_V:= Nil;
  FOnScrolled_H:= Nil;
  FOnTextScrolled:= Nil;
  FOnModifiedTimeDelay:= Nil;
  FOnModified:= Nil;
  FModifiedSinceLastDelay:= False;
  FOverwrite:= False;
  FFindUREPrepared:= ''; //  used by PrepareFindTextURE and UnPrepareFindTextURE
{$IFDEF D4_}
  FOnMouseWheel:= Nil;
  FOnMouseWheelDown:= Nil;
  FOnMouseWheelUp:= Nil;
{$ENDIF}
  FOnPaint:= Nil;

  FAutoComplete:= False;

  ControlStyle:= ControlStyle + [csReplicatable, csDisplayDragImage
{$IFDEF D4_},csActionClient{$ENDIF}];
  FWindowHandle:= AllocateHWnd(TimeDelayProc);
  Width:= 320;
  Height:= 240;
  TabStop:= True;
  FTracking:= True;
  FOptions:= [];
  FFullRedraw:= False;
  FScrollBars:= sbNone;
  FVScrollVisible:= True;
  FHScrollVisible:= True;
  FBorderStyle:= bsSingle;
  FLines:= TGsStrings.Create;
  FLines.Add('');
  ParentColor:= False;
  Color:= clWindow;
//  Font.Name:= 'Fixedsys';
//  Font.Name:= 'Arial';
  Font.Name:= 'Courier New';
//  Font.Pitch:= fpFixed; // do not this- it forces courier font instead variable withs font

  Encoding:= wmlc.csUTF8;
  Font.Color:= clWindowText;
  Font.Size:= 10;
  FTopLine:= 0;
  FBlockIndent:= 2;
  FMaxScrollH:= 0;
  Cursor:= crIBeam;
  FRightEdge:= False;
  FRightEdgeCol:= 80;
  FSelected:= False;
  FSelMouseDwn:= False;
  CaretPos.x:= 0;
  CaretPos.y:= 0;
  FDblClick:= False;
  FDropListTimeDelay:= 3;
  FDropList_CharH:= 3;
  FDropList_CharW:= 20;
  FDropCol_CharW:= 10;
  FLastDropPos.x:= 0;
  FLastDropPos.y:= 0;
  InitMemoObjects;

  FChrH:= 10;

  FConvOnLoadOptions:= [];
  FConvOnSaveOptions:= [convEnRemoveTrailingSpaces];

  FUndoRedoMgr:= TUndoRedoManager.Create(DEF_UNDO_DEPTH);
end;

procedure TECustomMemo.InitMemoObjects;
begin
  FGutterPan:= TGsGutter.CreateGutter(Self);
  with FGutterPan do begin
    Left:= -Width - 1;
    Parent:= Self;
    Visible:= False;
  end;
  FEnvironment:= TGsMemoEnvironment.CreateEnvironment(Self);
  FGutterOpt:= TGsGutterOptions.CreateGutterOptions(Self);
  { Special Hint Window }
  FHintWnd:= nil;
  { DropList Window }
  FDropList:= TListBox.Create(Self);
  with FDropList do begin
    Left:= -200;
    Parent:= Self;
    Visible:= False;
    ParentCtl3D:= False;
    Ctl3D:= False;
    IntegralHeight:= True;
    Sorted:= True;
    Style:= lbOwnerDrawFixed;
    OnKeyPress:= DropListKeyPress;
    OnExit:= DropListExit;
    OnDrawItem:= DropListDrawItem;
  end;
end;

destructor TECustomMemo.Destroy;
begin
  FUndoRedoMgr.Free;
  Visible:= False; // I don't know is it prevent casualty of exception in Paint
  FEnvironment.Free;
  FGutterOpt.Free;
  FGutterPan.Free;
//  if ScrollTimer <> nil then ScrollTimer.Free;
  KillTimer(FWindowHandle, 1);
  DeallocateHWnd(FWindowHandle);
  if FHintWnd <> nil
  then FHintWnd.Free;
  FDropList.Free;
  FLines.Free;
  if FLineGliph <> Nil
  then FLineGliph.Free;
  inherited Destroy;
end;

procedure TECustomMemo.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
  CS_OFF = CS_HREDRAW or CS_VREDRAW;
var
  save: TFNWndProc;
begin
  inherited CreateParams(Params);
  save:= Params.WindowClass.lpfnWndProc;
  with Params do begin
    Style:= Style or BorderStyles[FBorderStyle];
    Style:= Style or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_HSCROLL or WS_VSCROLL;
    WindowClass.Style:= WindowClass.Style and not CS_OFF;
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then begin
      Style:= Style and not WS_BORDER;
      ExStyle:= ExStyle or WS_EX_CLIENTEDGE;
    end;
    WindowClass.Style:= WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TECustomMemo.CreateWnd;
begin
  inherited CreateWnd;
  VPos:= 0;
  HPos:= 0;
  UpdateFontMetrics;
  UpdateCharBounds;
  UpdateScrollBars;
//  ScrollTimer:= TTimer.Create(Self);
//  ScrollTimer.Interval:= 100;
//  ScrollTimer.Enabled:= False;
//  ScrollTimer.OnTimer:= ScrollOnTimer;
  UpdateTimer;
end;

function TECustomMemo.GetCharWidthsPtr: Pointer;
begin
  Result:= FCharWidths;
end;

function TECustomMemo.GetWidthsLen: Integer;
begin
  Result:= Length(FCharWidths);
end;

procedure TECustomMemo.SetWidthsLen(AValue: Integer);
var
  i: Integer;
begin
  SetLength(FCharWidths, AValue);
  // set values
  for i:= 0 to AValue - 1 do begin
    FCharWidths[I]:= FChrW;
  end;
end;

procedure TECustomMemo.SetFontWidth(const Value: Integer);
var
  i: Integer;
begin
  if FChrW = Value
  then Exit;
  FChrW:= Value;
  for i:= 0 to WidthsLen - 1 do begin
    FCharWidths[I]:= Value;
  end;
end;

procedure TECustomMemo.SetFontHeight(const Value: Integer);
begin
  FChrH:= Value;
end;

procedure TECustomMemo.SetScreenCursorIfChanged(ACursor: TCursor);
begin
  if Screen.Cursor <> ACursor
  then Screen.Cursor:= ACursor;
end;

procedure TECustomMemo.DoExit;
begin
  inherited;
end;

procedure TECustomMemo.WMGetDlgCode(var AMessage: TWMGetDlgCode);
begin
  inherited;
  AMessage.Result:= AMessage.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
  if True
  then AMessage.Result := AMessage.Result or DLGC_WANTTAB;
end;

procedure TECustomMemo.TimeDelayProc(var Msg: TMessage);
begin
  with Msg do if Msg = WM_TIMER then begin
    try
      if csDesigning in ComponentState
      then Exit;
      if (FSelStartNo = FSelEndNo) and (FSelStartOffs = FSelEndOffs) then FSelected:= False;

      if (FDropListTimeDelay = 0) or (FDropList.Visible) then Exit;
      if (FLastDropPos.x = CaretPos.x) and (FLastDropPos.y = CaretPos.y) then Exit;
      FDropTimeCount:= FDropTimeCount + 500;
      if FDropTimeCount >= (FDropListTimeDelay * 1000) then begin
        if FModifiedSinceLastDelay then begin
          // do not forget set FModifiedSinceLastDelay:= False;
          if Assigned(FOnModifiedTimeDelay)
          then FOnModifiedTimeDelay(Self);
        end;
        ShowDropWindow;
      end;
    except
      Application.HandleException(Self);
    end
  end else Result:= DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end;

procedure TECustomMemo.UpdateTimer;
begin
  KillTimer(FWindowHandle, 1);
  if SetTimer(FWindowHandle, 1, 450, nil) = 0
  then raise EOutOfResources.Create(CARET_TIME_ERROR);
end;

{ Setting properties }

procedure TECustomMemo.SetRightEdge(Value: Boolean);
begin
  if FRightEdge <> Value then begin
    FRightEdge:= Value;
    Invalidate;
  end;
end;

procedure TECustomMemo.SetRightEdgeCol(Value: Integer);
begin
  if Value < 20 then Value:= 20;
  if Value > 160 then Value:= 160;
  if FRightEdgeCol <> Value then begin
    FRightEdgeCol:= Value;
    if FRightEdge then Invalidate;
  end;
end;

procedure TECustomMemo.SetScrollBars(Value: TGsScrolls);
const
  V_SCROLL: array[TGsScrolls] of Boolean = (False, True, False, True);
  H_SCROLL: array[TGsScrolls] of Boolean = (False, True, True, False);
begin
  if Value <> FScrollBars then
  begin
    FScrollBars:= Value;
    FVScrollVisible:= V_SCROLL[Value];
    FHScrollVisible:= H_SCROLL[Value];
    ShowScrollBar(Handle, SB_VERT, FVScrollVisible);
    ShowScrollBar(Handle, SB_HORZ, FHScrollVisible);
  end;
end;

procedure TECustomMemo.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then begin
    FBorderStyle:= Value;
    RecreateWnd;
  end;
end;

{
function TECustomMemo.GetMaxLineWidth: Integer;
begin
  Result:= 0;
end;
}

procedure TECustomMemo.SetLines(Value: TGsStrings);
begin
  FLines.Assign(Value);
  Invalidate;
end;

// convPCData is not completely supporoted
function TECustomMemo.GetTextInCharacterSet(AConversion: TECharsetConversion): String;
begin
  Result:= util_xml.WideString2EncodedString(AConversion, Encoding, FLines, FConvOnSaveOptions);
end;

// replace tabs
function HideSpecialSymbols(AWS: TWideStrings): Integer;
var
  i, l, len: Integer;
  ws: WideString;
  replaced: Boolean;
begin
  Result:= 0;
  for l:= 0 to AWS.Count - 1 do begin
    ws:= AWS[l];
    len:= Length(ws);
    replaced:= False;
    for i:= 1 to len do begin
      case ws[i] of
        #0..#9, #11..#12, #14..#31:
          begin // I hope file does not contain invalid characters
            ws[i]:= #32;
            replaced:= True;
          end;
      end; { case }
    end;
    if replaced
    then AWS[l]:= ws;
  end;
end;

procedure TECustomMemo.SetEncoding(AValue: Integer);
begin
  FEncoding:= AValue;
end;

procedure TECustomMemo.SetTextInCharacterset(AConversion: TECharsetConversion; const AValue: String);
var
  i: Integer;
  ws: WideString;
begin
  case AConversion of
    convNone: begin
        FLines.Text:= AValue;
        HideSpecialSymbols(FLines);
      end;
    convFull: begin
        FLines.Text:= util_xml.CharSet2WideString(Encoding, AValue, FConvOnLoadOptions);
        HideSpecialSymbols(FLines);
      end;
    convLine,
    convPCData:begin
        // turn off normalization ---
        // 2003/10/10 possible bug ---
        FLines.NormalizationForm:= nfNone;
        // ---
        FLines.Text:= AValue;
        HideSpecialSymbols(FLines);
        for i:= 0 to FLines.Count - 1 do begin
          ws:= util_xml.CharSet2WideString(Encoding, FLines[i], FConvOnLoadOptions);
          // check validity of conversion
          if Length(ws) > 0
          then FLines[i]:= ws;
        end;
        // do not! FLines.NormalizationForm:= nfC; ---
      end;
  end;
  if FLines.Count = 0
  then FLines.Add('');
end;

procedure TECustomMemo.SetBlockIndent(Value: Integer);
begin
  if Value < 1 then begin
    if csDesigning in ComponentState
    then MessageBox(Application.Handle, 'Value for BlockIndent must be greater than 0.', 'Tip', MB_OK or MB_ICONINFORMATION);
    Value:= FBlockIndent;
  end;
  FBlockIndent:= Value;
end;

function TECustomMemo.GetCaretVPos: Integer;
begin
  Result:= CaretPos.x;
end;

function TECustomMemo.GetCaretHPos: Integer;
begin
  Result:= CaretPos.y;
end;

procedure TECustomMemo.SetCaretVPos(AValue: Integer);
begin
  CaretPos.x:= AValue;
  if CaretPos.x >= FLines.Count
  then CaretPos.x:= FLines.Count - 1;

  // show line in center of window
  if (CaretPos.x < FTopLine) or (CaretPos.x >= FTopLine + FVisLines) then begin
    SetVPos(CaretPos.x - FVisLines div 2);
  end;
  if FGutterOpt.Visible then begin
    FGutterPan.CaretPosXY:= CaretPos;
    FGutterPan.Repaint;
  end;
end;

procedure TECustomMemo.SetCaretHPos(AValue: Integer);
begin
  CaretPos.y:= AValue;
  if (CaretPos.x < 0) or (CaretPos.x >= FLines.Count)
  then Exit;
  if CaretPos.y >= Length(FLines[CaretPos.x])
  then CaretPos.y:= Length(FLines[CaretPos.x]);
  // show line in center of window
  if (CaretPos.y < HPos) or (CaretPos.y >= HPos + FVisCols) then begin
    SetHPos(CaretPos.y - FVisCols div 2);
  end;
end;

function TECustomMemo.GetDropList: TStrings;
begin
  Result:= FDropList.Items;
end;

procedure TECustomMemo.SetDropList(Value: TStrings);
begin
  FDropList.Items.Assign(Value);
end;

{ DropDown List Implementation }

procedure TECustomMemo.SetDropTime(Value: Integer);
begin
  FDropListTimeDelay:= Value;
  if FDropListTimeDelay < 0
  then FDropListTimeDelay:= 0;
  if FDropListTimeDelay > 10
  then FDropListTimeDelay:= 10;
end;

procedure TECustomMemo.ShowDropWindow;
var
  Chk, i, L: Integer;
  S, SLine: TGSString;
  DropList_CharH: Integer;
begin
  FDropTimeCount:= 0;
  if (csDesigning in ComponentState) or (not FAutoComplete)
  then Exit;
  { Show DropList Window when: Component is not in Designing state, FDropList
    is not visible, Component is not in Selection state and FDropList is not
    empty (has items). }

  if not Focused then begin
    if FDropList.Visible
    then FDropList.Visible:= False;
  end;
  if FDropList.Visible or FSelected
  then Exit;

  if Assigned(FDropListEvent)
  then FDropListEvent(Self);

  if FDropList.Items.Count = 0
  then Exit;

  FDropList.Visible:= False;
  FDropList.Top:= (CaretPos.x - FTopLine + 1) * FChrH;
  FDropList.Left:= CaretPos.y * FChrW;

  if FDropList.Items.Count < FDropList_CharH
  then DropList_CharH:= FDropList.Items.Count
  else DropList_CharH:= FDropList_CharH;

  if FDropList.ClientHeight <> FChrH * DropList_CharH
  then FDropList.ClientHeight:= FChrH * DropList_CharH;

  // FDropList.Height:= FDropListLinesCount * FChrH * DropList_CharH;

  if FDropList.ClientWidth <> FChrW * FDropList_CharW
  then FDropList.ClientWidth:= FChrW * FDropList_CharW;
  if FGutterOpt.Visible
  then FDropList.Left:= FDropList.Left + FGutterOpt.Width;
  Chk:= FDropList.Top + FDropList.Height;
  if Chk > ClientHeight
  then FDropList.Top:= FDropList.Top - FChrH - FDropList.Height;
  Chk:= FDropList.Left + FDropList.Width;
  if Chk > ClientWidth
  then FDropList.Left:= FDropList.Left - FDropList.Width;
  if CaretPos.x < FLines.Count then begin
    SLine:= FLines[CaretPos.x];
    if (CaretPos.y) > Length(SLine)
    then Exit;
  end;
  S:= GetLeftTextBeforeWordAtPos(CaretPos.y, CaretPos.x, Chk);
  S:= Copy(S, 1, CaretPos.y - Chk);
  SavedType:= S;
  FDropList.ItemIndex:= 0;
  L:= Length(S);
  for i:= 0 to FDropList.Count - 1 do begin
    if ANSICompareText(S, Copy(FDropList.Items[i], 1, L)) = 0 then begin
      FDropList.ItemIndex:= i;
      Break;
    end;
  end;

  FDropList.Visible:= True;
  FLastDropPos.x:= CaretPos.x;
  FLastDropPos.y:= CaretPos.y;
  FDropList.SetFocus;
end;

procedure TECustomMemo.DropListKeyPress(Sender: TObject; var Key: Char);
var
  S, Cs: TGSString;
  ps: TPoint;
  I, ei, bi: Integer;
  isattribute: Boolean;
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      FDropList.Visible:= False;
      SavedType:= '';
      SetFocus;
    end;
    VK_BACK, VK_SPACE: begin
      FDropList.Visible:= False;
      SavedType:= '';
      SetFocus;
      KeyPress(Key);
    end;

    VK_RETURN: begin
      FDropList.Visible:= False;
      if FDropList.ItemIndex < 0 then begin
        SetFocus;
        SavedType:= '';
        Exit;
      end;
      S:= FDropList.Items[FDropList.ItemIndex];
      isattribute:= Pos('|attribute|', s) > 0;
      I:= Pos('|', S);
      if I > 0 then begin
        Delete(S, 1, I);
        I:= Pos('|', S);
        if I > 0 then Delete(S, 1, I);
        Cs:= S;
      end else
      Cs:= S;
      SavedType:= Trim(SavedType);

      s:= Self.FLines[CaretPos.X];
      // bi:= EMemoCode.FindTagBegin(s, CaretPos.Y);
      ei:= EMemoCode.FindTagEnd(s, CaretPos.Y);
      i:= PosBackFrom(CaretPos.Y, '>', s);
      {
      if (bi < i) or (i <= 0)
      then Self.InsertTextAtPos('<', CaretPos.X, CaretPos.Y - Length(SavedType));
      }
      for I:= 1 to Length(Cs) do begin
        if I <= Length(SavedType) then begin
          if CompareText(SavedType[I], Cs[I]) = 0
          then Continue;
        end;
        InsertText(Cs[i]);
        FSelected:= False;
      end;
      if isattribute
      then InsertText('=""')
      else begin
        InsertText(' ');
        i:= PosFrom(CaretPos.Y, '<', s);
        if (ei > i) or (i <= 0)
        then InsertText('>');
      end;

      CaretPos.Y:= CaretPos.Y - 1;
      SavedType:= '';
      SetFocus;
    end;
  else
    // KeyPress(Key);
    if Key >= #32 then begin
      InsertText(Key);
      SavedType:= SavedType + Key;
    end;
  end;
end;

procedure TECustomMemo.DropListExit(Sender: TObject);
begin
  FDropList.Visible:= False;
end;

procedure TECustomMemo.DropListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  S, Cs1, Cs2: TGSString;
  P: Integer;
begin
  with FDropList.Canvas.Font do begin
    Name:= MEMO_DROPLIST_FONT;
    Size:= MEMO_DROPLIST_FONTSIZE;
    Style:= [];
    if odSelected in State
    then Color:= clHighlightText
    else Color:= clWindowText;
  end;
  FDropList.Canvas.FillRect(Rect);
  S:= FDropList.Items[Index];
  P:= Pos('|', S);
  if P = 0 then begin
    S:= ' ' + S;
    ExtTextOutW(FDropList.Canvas.Handle, Rect.Left, Rect.Top, ETO_OPAQUE, Nil,
      PWideChar(S), Length(S), Nil);
  end else begin
    Cs1:= '  ' + Copy(S, 1, P - 1);
    Delete(S, 1, P);
    P:= Pos('|', S);
    if P > 0
    then Cs2:= ' ' + Copy(S, 1, P - 1)
    else Cs2:= ' ' + S;

    {
    Bitmap:= TBitmap.Create;
    FImageList.GetBitmap(imgIdx, Bitmap);
    if Bitmap <> nil then begin
      BrushCopy(Bounds(Rect.Left + Offset, Rect.Top, Bitmap.Width, Bitmap.Height),
        Bitmap, Bounds(0, 0, Bitmap.Width, Bitmap.Height), clRed);  // render bitmap
      Offset:= Bitmap.Width + 6;    // add four pixels between bitmap and text
    end;
    Bitmap.Free;
    }

    ExtTextOutW(FDropList.Canvas.Handle, Rect.Left, Rect.Top, ETO_OPAQUE, Nil,
      PWideChar(Cs2), Length(Cs2), Nil);

    Rect.Left:= (FChrW * FDropCol_CharW) + FChrW;
    FDropList.Canvas.Font.Style:= [fsBold];
    ExtTextOutW(FDropList.Canvas.Handle, Rect.Left, Rect.Top, ETO_OPAQUE, Nil,
      PWideChar(Cs1), Length(Cs1), Nil);
  end;
end;

{ Scrolling implementation }

procedure TECustomMemo.UpdateScrollBars;
var
  ScrollInfoV, ScrollInfoH: TScrollInfo;
begin
  ScrollInfoV.cbSize:= SizeOf(ScrollInfoV);
  ScrollInfoV.fMask:= SIF_ALL;
  ScrollInfoV.nMin:= 0;
  ScrollInfoV.nPage:= FVisLines - 2;
  ScrollInfoV.nMax:= FLines.Count + 1;
  ScrollInfoV.nPos:= VPos;
  ScrollInfoV.nTrackPos:= 0;
  SetScrollInfo(Handle, SB_VERT, ScrollInfoV, True);

  ScrollInfoH.cbSize:= SizeOf(ScrollInfoH);
  ScrollInfoH.fMask:= SIF_ALL;
  ScrollInfoH.nMin:= 0;
  ScrollInfoH.nPage:= FMaxScrollH div 2;
  ScrollInfoH.nMax:= 2 * FMaxScrollH;
  ScrollInfoH.nPos:= HPos;
  ScrollInfoH.nTrackPos:= 0;
  SetScrollInfo(Handle, SB_HORZ, ScrollInfoH, True);

  if not FVScrollVisible then ShowScrollBar(Handle, SB_VERT, FVScrollVisible);
  if not FHScrollVisible then ShowScrollBar(Handle, SB_HORZ, FHScrollVisible);
  UpdateChildren;
end;

procedure TECustomMemo.UpdateChildren;
var
  I: Integer;
begin
  for I:= 0 to ControlCount - 1 do begin
    if (Controls[I] is TGsGutter) then
      if (TGsGutter(Controls[I]) = FGutterPan) then Continue;
    if (Controls[I] is TListBox) then
      if (TListBox(Controls[I]) = FDropList) then Continue;      
    CtrlByTagUpdate(Controls[I]);
  end;
end;

procedure TECustomMemo.ScrollChildren(dx, dy: Integer);
var
  I: Integer;
begin
  if (dx = 0) and (dy = 0) then Exit;
  for I:= 0 to ControlCount - 1 do
  begin
    if (Controls[I] is TGsGutter) then
      if (TGsGutter(Controls[I]) = FGutterPan) then
        Continue;
    if dy <> 0 then
    begin
      Controls[I].Tag:= Controls[I].Tag + dy;
      CtrlByTagUpdate(Controls[I]);
    end;
    if dx <> 0 then Controls[I].Left:= Controls[I].Left + dx;
  end;
end;

procedure TECustomMemo.WMHScroll(var Message: TWMHScroll);
begin
  if FDropList.Visible
  then FDropList.Visible:= False;
  FDropTimeCount:= 0;
  FLastDropPos.x:= -1;
  FLastDropPos.y:= -1;
  with Message do
    case ScrollCode of
      SB_LINERIGHT: SetHPos(HPos + 1);
      SB_LINELEFT: SetHPos(HPos - 1);
      SB_PAGEUP: SetHPos(HPos - FVisLines);
      SB_PAGEDOWN: SetHPos(HPos + FVisLines);
      SB_THUMBPOSITION: SetHPos(Pos);
      SB_THUMBTRACK: if FTracking then SetHPos(Pos);
      SB_TOP: SetHPos(0);
      SB_BOTTOM: SetHPos(XSize);
    end;
end;

procedure TECustomMemo.WMVScroll(var Message: TWMVScroll);
begin
  if FDropList.Visible
  then FDropList.Visible:= False;
  FDropTimeCount:= 0;
  FLastDropPos.x:= -1;
  FLastDropPos.y:= -1;  
  with Message do
    case ScrollCode of
      SB_LINEUP: SetVPos(VPos - 1);
      SB_LINEDOWN: SetVPos(VPos + 1);
      SB_PAGEUP: SetVPos(VPos - FVisLines);
      SB_PAGEDOWN: SetVPos(VPos + FVisLines);
      SB_THUMBPOSITION: SetVPos(Pos);
      SB_THUMBTRACK: if FTracking then SetVPos(Pos);
      SB_TOP: SetVPos(0);
      SB_BOTTOM: SetVPos(YSize);
    end;
end;

procedure TECustomMemo.SetVPos(p: Integer);
var
  ScrollInfo: TScrollInfo;
  oldPos: Integer;
  Rc: TRect;
begin
  if p < 0
  then p:= 0; // Exit; // Jan 2003
  OldPos:= VPos;
  VPos:= p;
  ScrollInfo.cbSize:= SizeOf(ScrollInfo);
  ScrollInfo.nPos:= VPos;
  ScrollInfo.fMask:= SIF_POS;
  SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
  GetScrollInfo(Handle, SB_VERT, ScrollInfo);
  VPos:= ScrollInfo.nPos;
  Rc:= ClientRect;
  if OldPos - VPos <> 0 then begin
    ScrollChildren(0, (OldPos - VPos) * FChrH);
    FTopLine:= VPos;
    if FFullRedraw then
      Refresh
    else
      if (FTopLine + FVisLines) < FLines.Count - 1
      then DrawVisible
      else ScrollWindowEx(Handle, 0, (OldPos - VPos) * FChrH, nil, @Rc, 0, nil, SW_INVALIDATE);
    if Assigned(FOnScrolled_V) then FOnScrolled_V(Self);
    if Assigned(FOnTextScrolled)
    then FOnTextScrolled(Self, FTopLine, FTopLine + FVisLines + 1, HPos, FMaxScrollH);
  end;
end;

procedure TECustomMemo.SetHPos(p: Integer);
var
  ScrollInfo: TScrollInfo;
  oldPos: Integer;
  Rc: TRect;
begin
  if p < 0
  then p:= 0; // Exit; // Jan 2003
  OldPos:= HPos;
  HPos:= p;
  ScrollInfo.cbSize:= SizeOf(ScrollInfo);
  ScrollInfo.nPos:= HPos;
  ScrollInfo.fMask:= SIF_POS;
  SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
  GetScrollInfo(Handle, SB_HORZ, ScrollInfo);
//HPos:= ScrollInfo.nPos;
  Rc:= ClientRect;

  if OldPos - HPos <> 0 then begin
    ScrollChildren((OldPos - HPos), 0);
    if FFullRedraw
    then Refresh
    else DrawVisible;
    if Assigned(FOnScrolled_H)
    then FOnScrolled_H(Self);
    if Assigned(FOnTextScrolled)
    then FOnTextScrolled(Self, FTopLine, FTopLine + FVisLines, HPos, FMaxScrollH);
  end;
end;

procedure TECustomMemo.ScrollTo(X, Y: Integer);
begin
  SetVPos(Y div FChrH);
  SetHPos(X div FChrW);
end;

function TECustomMemo.GetVScrollPos: Integer;
begin
  Result:= VPos;
end;

procedure TECustomMemo.SetVScrollPos(Pos: Integer);
begin
  SetVPos(Pos);
end;

function TECustomMemo.GetHScrollPos: Integer;
begin
  Result:= HPos;
end;

procedure TECustomMemo.SetHScrollPos(Pos: Integer);
begin
  SetHPos(Pos);
end;

function TECustomMemo.GetVScrollMax: Integer;
var
  ScrollInfo: TScrollInfo;
begin
  ScrollInfo.cbSize:= SizeOf(ScrollInfo);
  ScrollInfo.nPos:= HPos;
  ScrollInfo.fMask:= SIF_RANGE or SIF_PAGE;
  GetScrollInfo(Handle, SB_VERT, ScrollInfo);
  Result:= ScrollInfo.nMax - Integer(ScrollInfo.nPage - 1);
end;

function TECustomMemo.GetHScrollMax: Integer;
var
  ScrollInfo: TScrollInfo;
begin
  ScrollInfo.cbSize:= SizeOf(ScrollInfo);
  ScrollInfo.nPos:= HPos;
  ScrollInfo.fMask:= SIF_RANGE or SIF_PAGE;
  GetScrollInfo(Handle, SB_HORZ, ScrollInfo);
  Result:= ScrollInfo.nMax - Integer(ScrollInfo.nPage - 1);
end;

{ Mouse Wheel scrolling implementation }
{$IFDEF D4_}
procedure TECustomMemo.CMMouseWheel(var AMessage: TCMMouseWheel);
begin
  with AMessage do begin
    MouseWheel(ShiftState, WheelDelta, SmallPointToPoint(Pos));
  end;  
end;

procedure TECustomMemo.MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint);
var
  ScrollNotify: Integer;
  hasShift, hasCtrl, NotDoIt, IsNeg: Boolean;
begin
  NotDoIt:= False;
  if Assigned(FOnMouseWheel) then
    FOnMouseWheel(Self, Shift, WheelDelta, MousePos, NotDoIt);
  if NotDoIt then Exit;
  ScrollNotify:= -1;
  hasShift:= (ssShift in Shift);
  hasCtrl:= (ssCtrl in Shift);
  if hasCtrl then begin
    if WheelDelta > 0 then ScrollNotify:= SB_LINELEFT;
    if WheelDelta < 0 then ScrollNotify:= SB_LINERIGHT;
    if (ScrollNotify <> -1) then begin
      Perform(WM_HSCROLL, ScrollNotify, 0);
      Perform(WM_HSCROLL, ScrollNotify, 0);
    end;
    Exit;
  end;
  if hasShift then begin
    DrawVisible;
    if WheelDelta > 0 then CaretPos.x:= CaretPos.x - 1;
    if WheelDelta < 0 then CaretPos.x:= CaretPos.x + 1;
    if CaretPos.x < 0 then CaretPos.x:= 0;
    if CaretPos.x >= FLines.Count
    then CaretPos.x:= FLines.Count - 1;
    SetCaretPosXY;
    Exit;
  end;
  if not hasShift and not hasCtrl then begin
    if WheelDelta > 0 then ScrollNotify:= SB_LINEUP;
    if WheelDelta < 0 then ScrollNotify:= SB_LINEDOWN;
    if (ScrollNotify <> -1) then Perform(WM_VSCROLL, ScrollNotify, 0);
  end;
  Inc(FWheelAccumulator, WheelDelta);
  while Abs(FWheelAccumulator) >= WHEEL_DELTA do begin
    IsNeg:= FWheelAccumulator < 0;
    FWheelAccumulator:= Abs(FWheelAccumulator) - WHEEL_DELTA;
    if IsNeg then begin
      if FWheelAccumulator <> 0 then FWheelAccumulator:= -FWheelAccumulator;
      NotDoIt:= MouseWheelDown(Shift, MousePos);
    end else
      NotDoIt:= MouseWheelUp(Shift, MousePos);
  end;
end;

function TECustomMemo.MouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result:= False;
  if Assigned(FOnMouseWheelDown)
  then FOnMouseWheelDown(Self, Shift, MousePos, Result);
end;

function TECustomMemo.MouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result:= False;
  if Assigned(FOnMouseWheelUp)
  then FOnMouseWheelUp(Self, Shift, MousePos, Result);
end;
{$ENDIF}

{ Control painting impementation }

procedure TECustomMemo.UpdateFontMetrics;
begin
  Canvas.Font.Assign(Self.Font);
  if emUseBoldTags in FOptions then begin
    Canvas.Font.Style:= [fsBold];
  end else begin
    Canvas.Font.Style:= [];
  end;
  FontWidth:= Canvas.TextWidth('W');
  FontHeight:= Canvas.TextHeight('Wp');
  if FLineGliph <> Nil
  then FLineGliph.Free;
  FLineGliph:= TBitmap.Create;
  with FLineGliph do begin
    Width:= FChrW * WidthsLen;
    Height:= FChrH;
  end;

  // return canvas changes back
  if emUseBoldTags in FOptions then begin
    Canvas.Font.Style:= [];
  end;
end;

procedure TECustomMemo.UpdateCharBounds;
begin
  FVisLines:= (ClientHeight div FontHeight) + 1;
  if FGutterOpt.Visible
  then FVisCols:= (ClientWidth - FGutterPan.Width) div FChrW
  else FVisCols:= ClientWidth div FChrW;
end;

procedure TECustomMemo.Paint;
begin
  UpdateCharBounds;
  if FGutterOpt.Visible then  begin
    if (FGutterPan.StartNum <> FTopLine + 1)
    then FGutterPan.StartNum:= FTopLine + 1;
    FGutterPan.CaretPosXY:= CaretPos;
    FGutterPan.Repaint;
  end;
  with Canvas do begin
    Brush.Color:= Self.Color;
    // Brush.Color:= FEnvironment.TextBackground;
    FillRect(Canvas.ClipRect);
    if not FGutterOpt.Visible then begin
      FGutterPan.Visible:= False;
      FGutterPan.Align:= alNone;
      FGutterPan.Left:= -FGutterPan.Width - 1;
    end else begin
      FGutterPan.Visible:= True;
      FGutterPan.Align:= alLeft;
    end;
    Brush.Color:= Self.Color;
  end;
  DrawVisible;
  if Assigned(FOnPaint) then FOnPaint(Self);
end;

{ Format visible lines and Drawing visible lines }

function TECustomMemo.FormatLine(ALine: Integer; ACanvas: TCanvas; R: TRect): Integer;
var
  SOrig, S, SS: TGsString;
  rr: TRect;
  len, Si, Ei: Integer;
  AllowDraw: Boolean;
begin
  // if no line exists, exit
  if (FLines.Count = 0) or (ALine < 0) or (ALine > FLines.Count - 1)
  then Exit;
  // get line
  SOrig:= FLines[ALine];
  len:= Length(SOrig);
  S:= Copy(SOrig, HPos + 1, WidthsLen);
  with ACanvas do begin
    { try to use special formatting routine }
    AllowDraw:= True;
    if Assigned(FOnDrawLine)
    then FOnDrawLine(Self, ALine, ACanvas, R, AllowDraw);
    { If not, draw simple text line... }
    if AllowDraw
    then printcanvasVisible(Handle, PWideChar(S), Length(S), R);

    if FSelected then begin
      Brush.Color:= FEnvironment.SelectionBackground;
      Font.Color:= FEnvironment.SelectionColor;
      Font.Style:= [];
      if (ALine > StartNo) and (ALine < EndNo) then begin
        // |----XXXXXX----| select all line
        Result:= Length(S) * FChrW;
        Rr:= Rect(0, 0, Result, FChrH);
        printcanvasVisible(Handle, PWideChar(S), Length(S), Rr);
      end else begin
        Ei:= EndOffs;
        Si:= StartOffs;
        if (ALine = StartNo) and (ALine = EndNo) then begin
          // |----xxXXXx----| select selected characters in single line
          if Ei = Si then begin
            // user start to select region, but now nothing is selected
            Result:= Length(S) * FChrW;
            Exit;
          end;
          if Ei > len
          then SS:= Copy(SOrig, Si + 1, len - Si)
          else SS:= Copy(SOrig, Si + 1, Ei - Si);
          Result:= Length(S) * FChrW;; // ((Si - HPos) * FChrW) + (Length(SS) * FChrW);
          Rr:= Rect((Si - HPos) * FChrW, 0, Result, FChrH);
          printcanvasVisible(Handle, PWideChar(SS), Length(SS), Rr);
        end else begin
          if (ALine = StartNo) and (ALine < EndNo) then begin
            // |    xxxXXX----| select last characters
            SS:= Copy(SOrig, Si + 1, len - Si);
            Result:= ((Si - HPos) * FChrW) + (Length(SS) * FChrW);
            Rr:= Rect((Si - HPos) * FChrW, 0, Result, FChrH);
            printcanvasVisible(Handle, PWideChar(SS), Length(SS), Rr);
          end else begin
            if (ALine > StartNo) and (ALine = EndNo) then begin
              // |----XXXxxx    | select first characters
              if Ei > len
              then Ei:= len;
              SS:= Copy(SOrig, 1, Ei);
              // No return position where  selection is started
              // Result:= (- HPos) * FChrW + (Length(SS) * FChrW);
              // Return selection positon used to CLEAR, not to mark, so it points to the end of line
              Result:= Length(S) * FChrW;
              Rr:= Rect((- HPos) * FChrW, 0, Result, FChrH);
              printcanvasVisible(Handle, PWideChar(SS), Length(SS), Rr);
            end else begin
              // |    xxxxxx    | no selected text
              Result:= Length(S) * FChrW;
            end;
          end;
        end;
      end;
    end else begin
      Result:= Length(S) * FChrW;
    end;
    { it is not necessary, bitmap is cleared allready
    Rr:= Rect(R.Left, Result, R.Right, R.Bottom);
    Brush.Color:= FEnvironment.TextBackground;
    FillRect(Rr); // to avoid flickering clear bitmap
    }
  end;

  if len > FMaxScrollH
  then FMaxScrollH:= len;
  UpdateScrollBars;
end;

procedure TECustomMemo.DrawLine(CanvasSupport: TCanvas; ALine, AYOffset: Integer);
var
  Ei, Si, GSz, selendX: Integer;
  Rc: TRect;
  f: Boolean;
begin
  // if not Assigned(FLineGliph) then Exit;
  f:= Focused;
  if F
  then Windows.HideCaret(Handle);

  if FGutterOpt.Visible then begin
    GSz:= FGutterPan.Width;
    if (FGutterPan.StartNum <> FTopLine + 1)
    then FGutterPan.StartNum:= FTopLine + 1;
    FGutterPan.CaretPosXY:= CaretPos;  // FGutterPan.RePaint;
  end else
    GSz:= 0;
  with FLineGliph.Canvas do begin
    Brush.Color:= FEnvironment.TextBackground;
    Font.Assign(Self.Font);
    Font.Color:= FEnvironment.TextColor;
    Rc:= Rect(0, 0, Width, FChrH);
    FillRect(Rc);
    if ALine < Self.FLines.Count
    then selendX:= FormatLine(ALine, FLineGliph.Canvas, Rc)
    else begin
      selendX:= Rc.Left;
    end;
  end;

  if FRightEdge then with FLineGliph.Canvas do begin  // and ((Width div FChrW) >= FRightEdgeCol)
    Pen.Width:= 1;
    Pen.Style:= psDot;
    Pen.Color:= FEnvironment.RightEdgeColor;
    MoveTo(FRightEdgeCol * FChrW, 0);
    LineTo(FRightEdgeCol * FChrW, FChrH);
  end;

  CanvasSupport.Draw(GSz, AYOffset, FLineGliph);

  // get position where string finished
  Inc(selendX, GSz);
  // if selendX < GSz then selendX:= GSz;

  Brush.Color:= FEnvironment.TextBackground; // Set default background color

  if FSelected then begin
    // fill right edges
    Ei:= EndOffs;
    Si:= StartOffs;
    if (ALine > StartNo) and (ALine < EndNo) then begin
      // |----XXXXXX----| select all line
      Rc:= Rect(selendX, AYOffset, (FMaxScrollH * FChrW) + ClientWidth - (HPos * FChrW), AYOffset + FChrH);
      CanvasSupport.Brush.Color:= FEnvironment.SelectionBackground;
      CanvasSupport.FillRect(Rc);
    end else begin
      if (ALine = StartNo) and (ALine < EndNo) then begin
        // |    xxxXXX----| select last characters
        if ALine < FLines.Count then begin
          // if line exists, look for selection start position
          if Length(FLines[ALine]) - 1 < Si then begin
            Si:= Length(FLines[ALine]) - 1;
            StartOffs:= Si;
          end;
        end;
        Rc:= Rect(selendX, AYOffset,
          (FMaxScrollH * FChrW) + ClientWidth - (HPos * FChrW), AYOffset + FChrH);
        CanvasSupport.Brush.Color:= FEnvironment.SelectionBackground;
        CanvasSupport.FillRect(Rc);
      end else begin
        if (ALine > StartNo) and (ALine = EndNo) then begin
          // |----XXXxxx    | select first characters
          // keep as is
        end else begin
          // |    xxxxxx    | no selection
          Rc:= Rect(selendX, AYOffset,
            (FMaxScrollH * FChrW) + ClientWidth - (HPos * FChrW), AYOffset + FChrH);
          CanvasSupport.Brush.Color:= FEnvironment.TextBackground;
          CanvasSupport.FillRect(Rc);
        end;
      end;
    end;
  end else begin
    Rc:= Rect(selendX, AYOffset,
      (FMaxScrollH * FChrW) + ClientWidth - (HPos * FChrW), AYOffset + FChrH);
    CanvasSupport.Brush.Color:= FEnvironment.TextBackground;
    CanvasSupport.FillRect(Rc);
  end;

  if FRightEdge then begin
    with CanvasSupport do begin
      Pen.Width:= 1;
      Pen.Style:= psDot;
      Pen.Color:= FEnvironment.RightEdgeColor; 
      MoveTo((FRightEdgeCol * FChrW) - (HPos * FChrW) + GSz, AYOffset);
      LineTo((FRightEdgeCol * FChrW) - (HPos * FChrW) + GSz, AYOffset + FChrH);
    end;
  end;

  if F
  then Windows.ShowCaret(Handle);
end;

procedure TECustomMemo.DrawVisible;
var
  I, Y: Integer;
begin
  Y:= 0;
  // cntVis:= 1;
  GetSelBounds(StartNo, EndNo, StartOffs, EndOffs);
  for I:= FTopLine to FTopLine + FVisLines do begin
    DrawLine(Canvas, I, Y);
    Inc(Y, FChrH);
    // cntVis:= cntVis + 1;
    // if cntVis > FVisLines then Break;
  end;
  SetCaretPosXY;
end;

procedure TECustomMemo.DrawDirect2Canvas(ACanvas: TCanvas; R: TRect; AOnNextPage: TOnNextPageEvent;
  const ACaption: String);
var
  I, Y: Integer;
  saveSize: TPoint;
  LogX, LogY: Integer;
  IncY: Integer;
  rc: TRect;
  p: Integer;

  procedure PrintCaption;
  var
    S: WideString;
  begin
    with ACanvas do begin
      Brush.Color:= EnvironmentOptions.TextBackground;
      MoveTo(R.Left, R.Bottom - IncY);
      LineTo(R.Right, R.Bottom - IncY);
      Font.Color:= EnvironmentOptions.TextColor;
      Font.Style:= [];
    end;
    S:= Format('apoo editor, file: %s  page %d', [ACaption, p + 1]);
    ExtTextOutW(ACanvas.Handle, R.Right - ACanvas.TextWidth(S), R.Bottom - IncY + 2, ETO_OPAQUE, Nil,
     PWideChar(S), Length(S), Nil);  // CharWidthsPtr
  end;

begin
  // pixels per line
  LogX:= GetDeviceCaps(ACanvas.Handle, LOGPIXELSX);
  LogY:= GetDeviceCaps(ACanvas.Handle, LOGPIXELSY);
  // margins
  Inc(R.Left, LogX);
  Dec(R.Right, LogX);
  Inc(R.Top, LogY);
  Dec(R.Bottom, LogY);
  if (R.Right < R.Left) or (R.Bottom < R.Top) then begin
    Exit;
  end;
  // line inc
  IncY:= Trunc(1.2 * Abs(ACanvas.Font.Height));

  y:= R.Top + IncY;

  SaveSize.X:= FontWidth; // save font width
  FontWidth:= Trunc(1.1 * ACanvas.TextWidth('W'));
  p:= 0;
  //
  ACanvas.Brush.Color:= FEnvironment.TextBackground;
  ACanvas.FillRect(R);
  for I:= 0 to FLines.Count - 1 do begin
    Rc:= Rect(R.Left, Y,
      R.Right, Y + IncY);  // Left + Length(FLines[i]) * FChrW
    FormatLine(I, ACanvas, rc);
    Inc(Y, IncY);
    if Y + (2 * IncY) >= R.Bottom then begin
      PrintCaption;
      if Assigned(AOnNextPage) then begin
        if not AOnNextPage(Self, p, i)
        then Break;
      end;
      y:= R.Top + IncY;
      Inc(p);
    end;
  end;
  if (y > IncY)
  then PrintCaption;
  FontWidth:= SaveSize.X; // restore font width
end;

{ Selection properties implementation }

function TECustomMemo.GetSelBegin: TPoint;
begin
  Result.X:= FSelStartNo;
  REsult.Y:= FSelStartOffs;
end;

function TECustomMemo.GetSelEnd: TPoint;
begin
  Result.X:= FSelEndNo;
  REsult.Y:= FSelEndOffs;
end;

procedure TECustomMemo.SetSelBegin(Value: TPoint);
begin
  if Value.X > FLines.Count - 1
  then Value.X:= FLines.Count - 1;
  if Value.X < 0 then Value.X:= 0;
  if Value.Y < 0 then Value.Y:= 0;
  FSelStartNo:= Value.X;
  FSelStartOffs:= Value.Y;
end;

procedure TECustomMemo.SetSelEnd(Value: TPoint);
begin
  if Value.X > FLines.Count - 1
  then Value.X:= FLines.Count - 1;
  if Value.X < 0 then Value.X:= 0;
  if Value.Y < 0 then Value.Y:= 0;
  FSelEndNo:= Value.X;
  FSelEndOffs:= Value.Y;
end;

procedure TECustomMemo.SelectAll;
begin
  FSelStartNo:= 0;
  FSelStartOffs:= 0;

  FSelEndNo:= FLines.Count - 1;
  if FLines.Count > 0 then begin
    FSelEndOffs:= Length(FLines[FSelEndNo]);
  end else begin
    FSelEndOffs:= 0;
  end;
  FSelected:= True;
  DrawVisible;
end;

procedure TECustomMemo.SetSelected(AValue: Boolean);
begin
  FSelected:= True;
  Invalidate;
end;

{ Mouse selection implementation }

procedure TECustomMemo.GetSelBounds(var StartNo, EndNo, StartOffs, EndOffs: Integer);
begin
  if FSelStartNo <= FSelEndNo then begin
    StartNo:= FSelStartNo;
    EndNo:= FSelEndNo;
    if not ((StartNo = EndNo) and (FSelStartOffs > FSelEndOffs)) then begin
      StartOffs:= FSelStartOffs;
      EndOffs:= FSelEndOffs;
    end else begin
      StartOffs:= FSelEndOffs;
      EndOffs:= FSelStartOffs;
    end;
  end else begin
    StartNo:= FSelEndNo;
    EndNo:= FSelStartNo;
    StartOffs:= FSelEndOffs;
    EndOffs:= FSelStartOffs;
  end;
//  if HPos > 0 then begin
//    Dec(StartOffs, HPos - 1);  // ?!!
//    Dec(EndOffs, HPos - 1);    // ?!!
//  end;
end;

procedure TECustomMemo.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  RNo, CNo: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not Focused then SetFocus;
  // disable drop list
  if FDropList.Visible
  then FDropList.Visible:= False;
  FDropTimeCount:= 0;
  ShiftState:= Shift;
  if Assigned(FOnMemoEvents) then
    case Button of
      mbRight: FOnMemoEvents(Self, Shift, k_Mouse2, 0, CaretPos, Point(X, Y), Modified, FOverwrite);
      mbMiddle: FOnMemoEvents(Self, Shift, k_Mouse3, 0, CaretPos, Point(X, Y), Modified, FOverwrite);
    end;
  if Button <> mbLeft
  then Exit;
  if FDblClick
  then Exit;
  if FGutterOpt.Visible and (X <= FGutterPan.Width) then Exit;
  GetRowColAtPos(X + HPos * FChrW, Y + VPos * FChrH, RNo, CNo);
  CaretPos.X:= RNo;
  CaretPos.Y:= CNo;
  if Assigned(FOnMemoEvents) then FOnMemoEvents(Self, Shift, k_Mouse1, 0, CaretPos, Point(X, Y), Modified, FOverwrite);
  if not (ssShift in Shift) then begin
    if FSelected then begin
    { Erase old selection, if any... }
      FSelected:= False;
      DrawVisible;
    end else begin
      // kill timer & create new one
      UpdateTimer;
    end;
    FSelStartNo:= RNo;
    FSelEndNo:= FSelStartNo;
    FSelStartOffs:= CNo;
    FSelEndOffs:= FSelStartOffs;
    FSelected:= True;
    FSelMouseDwn:= True;
//    ScrollTimer.Enabled:= True;
  end else begin
    FSelEndNo:= RNo;
    FSelEndOffs:= CNo;
    FSelected:= True;
  end;
  DrawVisible;
end;

procedure TECustomMemo.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  RNo, CNo: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  ShiftState:= Shift;
  if Assigned(FOnMemoEvents) then
    case Button of
      mbLeft: FOnMemoEvents(Self, Shift, k_Mouse1, 0, CaretPos, Point(X, Y), Modified, FOverwrite);
      mbRight: FOnMemoEvents(Self, Shift, k_Mouse2, 0, CaretPos, Point(X, Y), Modified, FOverwrite);
      mbMiddle: FOnMemoEvents(Self, Shift, k_Mouse3, 0, CaretPos, Point(X, Y), Modified, FOverwrite);
    end;
  if Button <> mbLeft then Exit;
  if FDblClick then begin
    FDblClick:= False;
    Exit;
  end;
  FSelMouseDwn:= False;
//  ScrollTimer.Enabled:= False;
  if FGutterOpt.Visible and (X <= FGutterPan.Width) then Exit;
  GetRowColAtPos(X + HPos * FChrW, Y + VPos * FChrH, RNo, CNo);
  if RNo <> FSelEndNo then FSelEndNo:= RNo;
  if CNo <> FSelEndOffs then FSelEndOffs:= CNo;
  FSelected:= (FSelStartNo <> FSelEndNo) or (FSelStartOffs <> FSelEndOffs);
  if not FSelected and (FSelStartNo = 0) and (FSelStartOffs = 0) then
  begin
    FSelStartNo:= 0;
    FSelEndNo:= FSelStartNo;
    FSelStartOffs:= 0;
    FSelEndOffs:= FSelStartOffs;
    DrawVisible;
  end;
end;

procedure TECustomMemo.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  RNo, CNo, verY: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  ShiftState:= Shift;
  MousePos:= Point(X, Y);
  if Assigned(FOnMemoEvents)
  then FOnMemoEvents(Self, Shift, k_None, 0, CaretPos, MousePos, Modified, FOverwrite);
  VScrollDelta:= 0;
  HScrollDelta:= 0;
  if Y < 0 then VScrollDelta:= -1;
  if X < 0 then HScrollDelta:= -1;
  if Y > ClientHeight then VScrollDelta:= 1;
  if X > ClientWidth then HScrollDelta:= 1;
  if Y < -FChrH then VScrollDelta:= -2;
  if Y > (ClientHeight + FChrH) then VScrollDelta:= 2;
  if X < -FChrW then HScrollDelta:= -2;
  if X > (ClientWidth + FChrW) then HScrollDelta:= 2;


  if (FSelected and FSelMouseDwn) then begin
    XMouse:= X;
    YMouse:= Y;
    verY:= Y;
    if verY < 0 then verY:= 0;
    if verY > ClientHeight then verY:= ClientHeight;
    GetRowColAtPos(X + HPos * FChrW, verY + VPos * FChrH, RNo, CNo);
    FSelEndNo:= RNo;
    FSelEndOffs:= CNo;
    CaretPos.x:= RNo;
    CaretPos.y:= CNo;
    DrawVisible;
  end;
  if FGutterOpt.Visible then begin
    if (X <= FGutterPan.Width) and (Cursor <> crArrow) then Cursor:= crArrow;
    if (X > FGutterPan.Width) and (Cursor <> crIBeam) then Cursor:= crIBeam;
  end;
  if ssCtrl in Shift then begin
    Cursor:= crIBeam;
    if (FHintWnd <> nil) and not FNotHideHint then begin
      FHintWnd.Free;
      FHintWnd:= nil;
    end;
    Exit;
  end;
  Cursor:= crIBeam;
  if FHintWnd <> nil then begin
    FHintWnd.Free;
    FHintWnd:= nil;
  end;
end;

{ Drag'n Drop selection impementation }

procedure TECustomMemo.DragDropSelection(AtPos: TPoint; CopyMode: Boolean);
var
  SL, EL, SC, EC: Integer;
  S: TGSString;
begin
  if FSelStartNo <= FSelEndNo then begin
    SL:= FSelStartNo;
    EL:= FSelEndNo;
    SC:= FSelStartOffs;
    EC:= FSelEndOffs;
  end else begin
    SL:= FSelEndNo;
    EL:= FSelStartNo;
    EC:= FSelStartOffs;
    SC:= FSelEndOffs;
  end;
  if (AtPos.x in [SL..EL]) then begin
    if (AtPos.x = SL) and (AtPos.x < EL) and (AtPos.y >= SC) then Exit;
    if (AtPos.x > SL) and (AtPos.x = EL) and (AtPos.y < EC) then Exit;
    if (AtPos.x > SL) and (AtPos.x < EL) then Exit;
    if (AtPos.x = SL) and (AtPos.x = EL) and (AtPos.y in [SC..EC]) then Exit;
  end;
  S:= GetSelText;
  if S = '' then
  begin
    FSelected:= False;
    Exit;
  end;
  if not CopyMode
  then Self.DeleteSelection;
  InsertTextAtPos(S, AtPos.y, AtPos.x);
end;

{ ... }

// Is the character alphabetic, number or tag symbol
function IsCharTag(C: UCS4): Boolean;
begin
  Result:= (C = Ord('<')) or (C = Ord('>'));
end;

function GetNextWord(SLine: TGSString; var PosX: Integer): Boolean;
// const ValidChars = ['#', '0'..'9', 'A'..#255];
var
  I, RetX: Integer;
  FindNext: Boolean;
begin
  Result:= False;
  if PosX > Length(SLine) then Exit;
  FindNext:= False;
  RetX:= 0;
  for I:= PosX to Length(SLine) do begin
    if not FindNext and (UnicodeIsAlphaNum(Cardinal(SLine[I]))) then begin
      FindNext:= True;
      Continue;
    end;
    if FindNext and (not UnicodeIsAlphaNum(Cardinal(SLine[I]))) then begin
      RetX:= I;
      Result:= True;
      Break;
    end;
  end;
  if RetX < 1 then Result:= False;
  PosX:= RetX;
end;

{ Mouse Double-Click selection impementation }

procedure TECustomMemo.DblClick;
var
  S: TGSString;
  XB, NextW: Integer;
begin
  inherited DblClick;
  ShiftState:= ShiftState + [ssDouble];
  if Assigned(FOnMemoEvents) then FOnMemoEvents(Self, ShiftState, k_None, 0, CaretPos, MousePos, Modified, FOverwrite);
  S:= GetWordAtPos(CaretPos.y, CaretPos.x, XB);
  if (S <> '') and (XB > -1) then begin
    FSelStartNo:= CaretPos.x;
    FSelEndNo:= CaretPos.x;
    FSelStartOffs:= XB;
    FSelEndOffs:= XB + Length(S);
    CaretPos.y:= FSelStartOffs;
    FSelected:= True;
    DrawVisible;
    FDblClick:= True;
  end;
  { else -- Mar 09 2003
    if CaretPos.x <= FLines.Count - 1 then begin
      S:= FLines[CaretPos.x];
      NextW:= CaretPos.y;
      if GetNextWord(S, NextW) then
      begin
        S:= GetWordAtPos(NextW, CaretPos.x, XB);
        if (S <> '') and (XB > -1) then
        begin
          FSelStartNo:= CaretPos.x;
          FSelEndNo:= CaretPos.x;
          FSelStartOffs:= XB;
          FSelEndOffs:= XB + Length(S);
          CaretPos.y:= FSelStartOffs;
          FSelected:= True;
          DrawVisible;
          FDblClick:= True;
        end;
      end;
    end; -- Mar 09 2003
    }
end;

function TECustomMemo.GetTextAtPos(AStart, AFinish: TPoint; const AStringDelimiter: TGSString): TGSString;
var
  I: Integer;
begin
  Result:= '';
  if (AStart.X > FLines.Count - 1)
  then Exit;
  if (AFinish.X > FLines.Count - 1)
  then AFinish.X:= FLines.Count - 1;
  if AFinish.X = AStart.X then begin
    Result:= Copy(FLines[AStart.X], AStart.Y, AFinish.Y - AStart.Y + 1);
    Exit;
  end;
  Result:= Copy(FLines[AStart.X], AStart.Y, MaxInt) + AStringDelimiter;
  for i:= AStart.X + 1 to AFinish.X - 1 do begin
    Result:= Result + FLines[i] + AStringDelimiter;
  end;
  Result:= Result + Copy(FLines[AFinish.X], 1, AFinish.Y);
end;

function TECustomMemo.GetWordAtPos(Col, Row: Integer; var XBegin: Integer): TGSString;
//const ValidChars = ['#', '0'..'9', 'A'..#255];
var
  S: TGSString;
  I, Si, Ei, CrX: Integer;
begin
  Result:= '';
  XBegin:= -1;
  Si:= 0;
  Ei:= 0;

  if (Row > FLines.Count - 1) or (Row < 0) or (Col <= 0)
  then Exit;
  S:= FLines[Row];
  if Length(S) = 0
  then Exit;
  if Col > Length(S) - 1
  then Col:= Length(S) - 1;
  if not UnicodeIsAlphaNum(Cardinal(S[Col])) then begin
    // try to find beginning of word from current position to the left
    CrX:= Col - 1;
    for I:= CrX downto 1 do begin
      if IsCharTag(Cardinal(S[I + 1]))
      then Break; 
      if UnicodeIsAlphaNum(Cardinal(S[I + 1])) then begin
        Col:= I + 1;
        Break;
      end;
    end;

    // try to find beginning of word JUST 1 char to the right - Mar 09 2003
    if not UnicodeIsAlphaNum(Cardinal(S[Col])) then begin
      if (Col < Length(s)) and UnicodeIsAlphaNum(Cardinal(S[Col + 1])) then begin
        Inc(Col);
      end;
    end; // - Mar 09 2003
  end;
  // find first word delimiter
  for I:= Col downto 1 do begin
    if UnicodeIsAlphaNum(Cardinal(S[I]))
    then Si:= I
    else Break;
  end;
  // find end word delimiter
  for I:= (Col) to Length(S) do begin
    if UnicodeIsAlphaNum(Cardinal(S[I]))
    then Ei:= I + 1
    else Break;
  end;
  // return found word and offset where word was found
  if Ei >= Si then begin
    Result:= Copy(S, Si, Ei - Si);
    XBegin:= Si - 1;
  end;
end;

function TECustomMemo.GetLeftTextBeforeWordAtPos(Col, Row: Integer; var XBegin: Integer): TGSString;
var
  S: TGSString;
  Si: Integer;
begin
  Result:= '';
  XBegin:= -1;
  Si:= 0;

  if (Row > FLines.Count - 1) or (Row < 0) or (Col <= 0)
  then Exit;
  S:= FLines[Row];
  if Length(S) = 0
  then Exit;
  if Col > Length(S) - 1
  then Col:= Length(S) - 1;
  Si:= Col;
  // [ccSeparatorSpace, ccSpaceOther, ccWhiteSpace, ccSegmentSeparator, ccOtherControl, ccOtherFormat, ccPunctuationOpen]
  repeat
    if jclUnicode.UnicodeIsWhiteSpace(Cardinal(S[Si])) or (S[Si] = '<')
    then Break
    else Dec(Si);
  until Si <= 0;
  Result:= Copy(S, Si + 1, Col - Si);
  XBegin:= Si - 1;
end;

procedure TECustomMemo.GetRowColAtPos(X, Y: Integer; var Row, Col: Integer);
var
  Fine: Integer;
begin
  Row:= Y div FChrH;
  if Row >= Flines.Count
  then Row:= FLines.Count - 1;
  if FGutterOpt.Visible then begin
    if X < FGutterPan.Width then X:= FGutterPan.Width;
    Col:= (X - FGutterPan.Width) div FChrW;
    Fine:= (X - FGutterPan.Width) mod FChrW;
  end else begin
    if X < 0 then X:= 0;
    Col:= X div FChrW;
    Fine:= X mod FChrW;
  end;
  if Fine > (FChrW div 2) - 1
  then Inc(Col);
//  if HPos > 0
//  then Inc(Col, HPos - 1);  // ?!!
end;

{ Wheel scrolling and Mouse selection scrolling implementation }
{
procedure TECustomMemo.ScrollOnTimer(Sender: TObject);
begin
  if VScrollDelta <> 0 then begin
    ScrollPos_V:= ScrollPos_V + VScrollDelta;
    MouseMove([], XMouse, YMouse);
  end;
  if HScrollDelta <> 0 then
  begin
    ScrollPos_H:= ScrollPos_H + HScrollDelta;
    MouseMove([], XMouse, YMouse);
  end;
end;
}
{ Caret position and Caret drawing impementation}

procedure TECustomMemo.WMSetFocus(var Message: TWMSetFocus);
begin
  if not Windows.CreateCaret(Handle, 0, 1, FChrH)
  then raise EOutOfResources.Create(CARET_CANTCREATE);
  Windows.ShowCaret(Handle);
end;

procedure TECustomMemo.WMKillFocus(var Message: TWMKillFocus);
begin
  Windows.DestroyCaret;
end;

procedure TECustomMemo.SetCaretPosXY;
var
  Xp, Yp: Integer;
begin
  if csDesigning in ComponentState
  then Exit;
  if (CaretPos.X < FTopLine) or (CaretPos.X > FTopLine + FVisLines)
  then Exit;
  Yp:= (CaretPos.X - FTopLine) * FChrH;
  Xp:= (CaretPos.Y - HPos) * FChrW;
  if FGutterOpt.Visible
  then Xp:= Xp + FGutterPan.Width;
  //  Dec(Xp, (HPos - 1) * FChrW);  // ?!!
  Windows.SetCaretPos(Xp, Yp);
end;

procedure TECustomMemo.SetCaretPosXYFocus;
begin
  SetCaretPosXY;
  // show line in center of window
  if (CaretPos.y < HPos) or (CaretPos.y > HPos + FVisCols) then begin
    SetHPos(CaretPos.y - FVisCols div 2);
  end;
end;

function TECustomMemo.GetTextBetweenPos(AFrom, ATo: TPoint): TGSString;
var
  StartLine, StartPos, EndLine, EndPos, I, LineI: Integer;
  FirstPart, LastPart, SLine: TGSString;
begin
  if AFrom.X > ATo.X then begin
    StartLine:= ATo.X;
    StartPos:= ATo.Y;
    EndLine:= AFrom.X;
    EndPos:= AFrom.Y;
  end else begin
    if (AFrom.X = ATo.X) and (ATo.Y < AFrom.Y) then begin
      StartLine:= AFrom.X;
      StartPos:= ATo.Y;
      EndLine:= AFrom.X;
      EndPos:= AFrom.Y;
    end else begin
      StartLine:= AFrom.X;
      StartPos:= AFrom.Y;
      EndLine:= ATo.X;
      EndPos:= ATo.Y;
    end;
  end;
  if StartLine > FLines.Count - 1
  then Exit;
  if EndLine > FLines.Count - 1
  then EndLine:= FLines.Count - 1;
  SLine:= FLines[StartLine];
  if StartLine < EndLine then begin
    FirstPart:= Copy(SLine, StartPos + 1, Length(SLine) - StartPos);
    SLine:= FLines[EndLine];
    if EndPos > Length(SLine)
    then EndPos:= Length(SLine);
    LastPart:= Copy(SLine, 1, EndPos);
    LineI:= StartLine + 1;
    Result:= FirstPart;
    { TODO : slow! very slow! }
    for I:= LineI to (EndLine - 1)
    do Result:= Result + #13#10 + FLines[I];
    Result:= Result + #13#10 + LastPart;
  end else begin
    Result:= Copy(SLine, StartPos + 1, EndPos - StartPos);
  end;  
end;

function TECustomMemo.GetSelText: TGSString;
var
  FromP, ToP: TPoint;
begin
  if not FSelected then begin
    Result:= '';
    Exit;
  end;
  FromP.X:= FSelStartNo;
  FromP.Y:= FSelStartOffs;
  ToP.X:= FSelEndNo;
  ToP.Y:= FSelEndOffs;
  Result:= GetTextBetweenPos(FromP, ToP);
end;

procedure TECustomMemo.CopyToClipboard;
var
  ws: WideString;
  s: String;
begin
  if not FSelected then Exit;
  ws:= GetSelText;
  s:= ws;
  Clipboard.SetTextBuf(PChar(s));
end;

procedure TECustomMemo.CutToClipboard;
begin
  if not FSelected then Exit;
  CopyToClipboard;
  DeleteSelection;
end;

procedure TECustomMemo.SetBookmark(ABookmark: Char);
begin
  case ABookmark of
    '0'..'9': begin
      if FBookmarks[ABookmark].x = CaretPos.x then begin
        FBookmarks[ABookmark].x:= - 1;
        FBookmarks[ABookmark].y:= - 1;
      end else begin
        FBookmarks[ABookmark].x:= CaretPos.x; // + FTopLine;
        FBookmarks[ABookmark].y:= CaretPos.y;
      end;
      if Assigned(FGutterPan)
      then FGutterPan.Invalidate;
    end;
  end; { case }
end;

function TECustomMemo.GoToBookmark(ABookmark: Char): Boolean;
begin
  Result:= True;
  case ABookmark of
    '0'..'9':begin
      if FBookmarks[ABookmark].x >=0 then begin
        CaretPos_H:= FBookmarks[ABookmark].x;
        CaretPos_V:= FBookmarks[ABookmark].y;
      end;
    end;
  end; { case }
end;

procedure TECustomMemo.PasteFromClipboard;
begin
  if FSelected then begin
    DeleteSelection;
  end;
  InsertTextAtPos(Clipboard.AsText, CaretPos.y, CaretPos.x);
  FSelected:= False;
//  DrawVisible;
end;

procedure TECustomMemo.InsertTextAtPos(const S: TGSString; Col, Row: Integer);
var
  SLine, BufS1, BufS2, BufS: TGSString;
  I, L, r: Integer;
begin
  if (Length(S) <= 0) or (Row > FLines.Count)
  then Exit;

  if (Row = FLines.Count) then FLines.Add('');
  SLine:= FLines[Row];
  if Col > Length(SLine) then begin
    L:= Length(SLine);
    for I:= L to Col do SLine:= Sline + ' ';
  end;
  BufS1:= Copy(SLine, 1, Col);
  BufS2:= Copy(SLine, Col + 1, Length(SLine) - Col);
  SLine:= BufS1 + S + BufS2;
  FSelected:= False;
  I:= Pos(#13#10, SLine);

  r:= Row;

  if I > 0 then begin
    BufS:= '';
    FSelStartNo:= Row;
    FSelStartOffs:= Length(BufS1);
    while I > 0 do begin
      BufS:= Copy(SLine, 1, I - 1);
      FLines.Insert(r, BufS);
      Delete(SLine, 1, I + 1);
      I:= Pos(#13#10, SLine);
      CaretPos.x:= r;
      CaretPos.y:= Length(BufS);
      FSelEndNo:= r;
      FSelEndOffs:= CaretPos.y;
      Inc(r);
    end;
    if True then begin // Length(SLine) > 0
      FLines[r]:= SLine;
      CaretPos.x:= r;
      CaretPos.y:= Length(SLine) - Length(BufS2);
      FSelEndNo:= r;
      FSelEndOffs:= CaretPos.y;
    end;
    Invalidate;
  end else begin
    I:= Pos(#13, SLine);
    if I > 0 then begin
      BufS:= '';
      FSelStartNo:= r;
      FSelStartOffs:= Length(BufS1);
      while I > 0 do begin
        BufS:= Copy(SLine, 1, I - 1);
        FLines.Insert(r, BufS);
        Delete(SLine, 1, I);
        I:= pos(#13, SLine);
        CaretPos.x:= r;
        CaretPos.y:= Length(BufS);
        FSelEndNo:= r;
        FSelEndOffs:= CaretPos.y;
        Inc(r);
      end;
      if SLine <> '' then begin
        FLines[r]:= SLine;
        CaretPos.x:= r;
        CaretPos.y:= Length(SLine) - Length(BufS2);
        FSelEndNo:= r;
        FSelEndOffs:= CaretPos.y;
      end;
      Invalidate;
    end else begin
      CaretPos.x:= r;
      FLines[r]:= SLine;
      CaretPos.y:= Col + Length(S);
      FSelStartNo:= r;
      FSelEndNo:= r;
      FSelStartOffs:= Length(BufS1);
      FSelEndOffs:= CaretPos.y;
      Invalidate;
    end;
  end;

  FUndoRedoMgr.AddDo(urInsert, Point(row, col), CaretPos, S);

  Modified:= True;
end;

procedure TECustomMemo.InsertText(const S: TGSString);
begin
  InsertTextAtPos(S, CaretPos.y, CaretPos.x);
end;

{ Keyboard implementation }

procedure TECustomMemo.DeleteBetweenPos(AFrom, ATo: TPoint);
var
  FirstPart, LastPart, SLine: TGSString;
  StartLine, StartPos, EndLine, EndPos, I, DelLine: Integer;
begin
  // x- line y- pos
  if AFrom.X > ATo.X then begin
    StartLine:= ATo.X;
    StartPos:= ATo.Y;
    EndLine:= AFrom.X;
    EndPos:= AFrom.Y;
  end else begin
    if (AFrom.X = ATo.X) and (ATo.Y < AFrom.Y) then begin
      StartLine:= AFrom.X;
      StartPos:= ATo.Y;
      EndLine:= AFrom.X;
      EndPos:= AFrom.Y;
    end else begin
      StartLine:= AFrom.X;
      StartPos:= AFrom.Y;
      EndLine:= ATo.X;
      EndPos:= ATo.Y;
    end;
  end;
  { update Undo List }
  if StartLine > FLines.Count - 1
  then Exit;
  if EndLine > FLines.Count - 1
  then EndLine:= FLines.Count - 1;
  SLine:= FLines[StartLine];
  FirstPart:= Copy(SLine, 1, StartPos);
  SLine:= FLines[EndLine];
  if EndPos > Length(SLine)
  then EndPos:= Length(SLine);
  LastPart:= Copy(SLine, EndPos + 1, Length(SLine) - EndPos);
  DelLine:= StartLine + 1;
  for I:= DelLine to EndLine do FLines.Delete(DelLine);
  FLines[StartLine]:= FirstPart + LastPart;

  CaretPos.x:= StartLine;
  CaretPos.y:= StartPos;
  FSelected:= False;
  if Assigned(FLineGliph) then begin // not assigned if window is not created
    if StartLine = EndLine then begin
      I:= (CaretPos.x - FTopLine) * FChrH;
      DrawLine(Canvas, CaretPos.x, I);
    end else
      DrawVisible;
    UpdateScrollbars;
  end;
  Modified:= True;
end;

procedure TECustomMemo.DeleteSelection;
var
  p1, p2: TPoint;
begin
  if not FSelected
  then Exit;

  p1.X:= Self.FSelStartNo;
  p2.X:= Self.FSelEndNo;
  p1.Y:= Self.FSelStartOffs;
  p2.Y:= Self.FSelEndOffs;

  FUndoRedoMgr.AddDo(urDelete, p1, p2, GetSelText);

  DeleteBetweenPos(p1, p2);
  Modified:= True;
end;

{ Showing Special Hint Window - Text only }

procedure TECustomMemo.ShowTextHint(X, Y: Integer; HintMsg: TGSString);
var
  HintPos: TPoint;
  WTxt, HTxt: Integer;
begin
  if FHintWnd <> nil then
  begin
    Exit;
    FHintWnd.Free;
    FHintWnd:= nil;
  end;
  FHintWnd:= THintWindow.Create(Self);
  HintPos:= ClientToScreen(Point(X, Y));
  with FHintWnd do begin
    Color:= clInfoBk;
    Font.Name:= HINT_FONT;
    Font.Size:= HINT_FONTSIZE;
    HTxt:= Canvas.TextHeight(HintMsg);
    WTxt:= Canvas.TextWidth(HintMsg);
    ActivateHint(Rect(HintPos.x, HintPos.y, HintPos.x + WTxt + 8, HintPos.y + HTxt + 2), HintMsg);
  end;
end;

procedure TECustomMemo.WMKeyDown(var Message: TWMKeyDown);
var
  GliphY, Y: Integer;
  CaretScroll: Boolean;
  Fill, T: Integer;
  SLine, AddS: TGsString;
begin
  CaretScroll:= False;
  FDropTimeCount:= 0;
  FLastDropPos.x:= -1;
  FLastDropPos.y:= -1;
  with Message do begin
    ShiftState:= KeyDataToShiftState(KeyData);
    if Assigned(FOnMemoEvents)
    then FOnMemoEvents(Self, ShiftState, k_Down, CharCode, CaretPos, MousePos, Modified, FOverwrite);
    case CharCode of
      VK_LEFT, VK_RIGHT, VK_DOWN, VK_UP, VK_HOME, VK_END, VK_PRIOR, VK_NEXT:
        begin
          KeyboardCaretNav(ShiftState, CharCode);
          CaretScroll:= True;
        end;
      VK_TAB: { Tab key }
        begin
          if FSelected
          then DeleteSelection;

          SLine:= FLines[CaretPos.X];
          if Length(SLine) < CaretPos.y + 1 then
            for Fill:= Length(SLine) to CaretPos.y + 1 do SLine:= SLine + ' ';
          if (CaretPos.X > 0) and (CaretPos.X <= FLines.Count - 1) then begin
            Y:= CaretPos.y + 1;
            AddS:= '';
            if GetNextWord(FLines[CaretPos.X - 1], Y) then begin
              for Fill:= 1 to Y - CaretPos.y - 1 do AddS:= AddS + ' ';
            end else
              for T:= 1 to BlockIndent do AddS:= AddS + ' ';
          end else
            for T:= 1 to BlockIndent do AddS:= AddS + ' ';

          FUndoRedoMgr.AddDo(urInsert, CaretPos, Point(CaretPos.X, CaretPos.Y + Length(AddS)), AddS);

          Insert(AddS, SLine, CaretPos.y + 1);
          FLines[CaretPos.X]:= SLine;
          CaretPos.y:= CaretPos.y + Length(AddS);
          GliphY:= (CaretPos.X - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.X, GliphY);
          FSelStartNo:= CaretPos.X;
          FSelStartOffs:= CaretPos.y;
        end;
      VK_RETURN: { Return key }
        begin
          if FSelected
          then DeleteSelection;
           SLine:= FLines[CaretPos.X];
          AddS:= '';
          if Length(SLine) > CaretPos.y then begin
            AddS:= Copy(SLine, CaretPos.y + 1, Length(SLine) - CaretPos.y + 1);
            Delete(SLine, CaretPos.y + 1, Length(SLine) - CaretPos.y);
            FLines[CaretPos.X]:= SLine;
          end;
          if CaretPos.X = pred(FLines.Count) then
            FLines.Add(AddS)
          else
            if CaretPos.X <= FLines.Count then
              FLines.Insert(CaretPos.X + 1, AddS)
            else
              if CaretPos.X > FLines.Count then
                FLines.Add(''); { ??? }
          CaretPos.X:= CaretPos.X + 1;
          CaretPos.y:= 0;
          DrawVisible;
          FSelStartNo:= CaretPos.X;
          FSelStartOffs:= CaretPos.y;
          Modified:= True;
        end;
      VK_BACK:
        begin
          if FSelected then begin
            DeleteSelection;
            Exit;
          end;
          SLine:= FLines[CaretPos.X];
          if Length(SLine) >= CaretPos.y then
            Y:= CaretPos.y
          else begin
            Y:= Length(SLine);
            CaretPos.y:= Y;
          end;
          if y > 0 then begin
            FUndoRedoMgr.AddDo(urDelete, Point(CaretPos.X, Y - 1), CaretPos, Sline[Y]);
            Delete(SLine, Y, 1);
          end;
          FLines[CaretPos.X]:= SLine;
          CaretPos.y:= CaretPos.y - 1;
          if CaretPos.y < 0 then begin
            if CaretPos.X > 0 then begin
              AddS:= FLines[CaretPos.X];
              FLines.Delete(CaretPos.X);
              CaretPos.X:= CaretPos.X - 1;
              CaretPos.y:= Length(FLines[CaretPos.X]);
              if AddS <> '' then
                FLines[CaretPos.X]:= FLines[CaretPos.X] + AddS;
              DrawVisible;
            end else begin
              CaretPos.y:= 0;
              GliphY:= (CaretPos.X - FTopLine) * FChrH;
              DrawLine(Canvas, CaretPos.X, GliphY);
            end;
          end else begin
            GliphY:= (CaretPos.X - FTopLine) * FChrH;
            DrawLine(Canvas, CaretPos.X, GliphY);
          end;
          FSelStartNo:= CaretPos.X;
          FSelStartOffs:= CaretPos.y;
          Modified:= True;
        end;
      VK_INSERT:
        begin
          FOverwrite:= not FOverwrite;
          Exit;
        end;
      VK_DELETE:
        begin
          if FSelected then begin
            DeleteSelection;
            SetCaretPosXYFocus;
            Exit;
          end;
          if CaretPos.x >= FLines.Count then Exit;
          SLine:= FLines[CaretPos.x];
          if Length(SLine) >= CaretPos.y + 1 then begin
            Y:= CaretPos.y + 1;
            FUndoRedoMgr.AddDo(urDelete, CaretPos, CaretPos, SLine[Y]);
            Delete(SLine, Y, 1);
            FLines[CaretPos.x]:= SLine;
            GliphY:= (CaretPos.x - FTopLine) * FChrH;
            DrawLine(Canvas, CaretPos.x, GliphY);
          end else begin
            if CaretPos.x + 1 >= FLines.Count then Exit;
            AddS:= FLines[CaretPos.x + 1];
            FLines[CaretPos.x]:= SLine + AddS;
            FLines.Delete(CaretPos.x + 1);
            DrawVisible;
          end;
          SetCaretPosXYFocus;
          Modified:= True;
        end;
    end;
  end;
  if CaretScroll then begin
    if CaretPos.y > HPos + FVisCols then ScrollPos_H:= CaretPos.y - FVisCols;
    if CaretPos.y < HPos then ScrollPos_H:= CaretPos.y;
    if CaretPos.x < FTopLine then ScrollPos_V:= CaretPos.x;
    if CaretPos.x > FTopLine + FVisLines - 2 then ScrollPos_V:= CaretPos.x - FVisLines + 2;
  end;
  SetCaretPosXYFocus;
  inherited;
end;

{
procedure TECustomMemo.EditWndProc(var Message: TMessage);
begin
  try
    with Message do
    begin
      case Msg of
        WM_KEYDOWN,
        WM_SYSKEYDOWN: if DoKeyDown(TWMKey(Message)) then Exit;
        WM_CHAR: if DoKeyPress(TWMKey(Message)) then Exit;
        WM_KEYUP,
        WM_SYSKEYUP: if DoKeyUp(TWMKey(Message)) then Exit;
        CN_KEYDOWN,
        CN_CHAR, CN_SYSKEYDOWN,
        CN_SYSCHAR:
          begin
            WndProc(Message);
            Exit;
          end;
      end;
//      Result := CallWindowProc(FDefEditProc, FEditHandle, Msg, WParam, LParam);
    end;
  except
    Application.HandleException(Self);
  end;
end;
}

procedure TECustomMemo.WMKeyUp(var Message: TWMKeyUp);
begin
  with Message do begin
    ShiftState:= KeyDataToShiftState(KeyData);
    if Assigned(FOnMemoEvents) then
      FOnMemoEvents(Self, ShiftState, k_Up, CharCode, CaretPos, MousePos, Modified, FOverwrite);
    Cursor:= crIBeam;
    SetScreenCursorIfChanged(crDefault);
    if FHintWnd <> nil then begin
      FHintWnd.Free;
      FHintWnd:= nil;
      FNotHideHint:= False;
    end;
  end;
  inherited;
end;

{ KeyboardCaretNav - this procedure is used to set caret position
  on keyboard navigation and to set selection if Shift key is pressed. }

procedure TECustomMemo.KeyboardCaretNav(ShiftState: TShiftState; Direction: Word);
var
  GliphY, SaveXCaret: Integer;

  procedure CtrlKeyLeftKey;
  var
    S: TGSString;
    XB: Integer;
  begin
    S:= GetWordAtPos(CaretPos.y, CaretPos.x, XB);
    if (Length(S) > 0) and (XB > -1) then begin
      if FSelected
      then FSelEndOffs:= XB;
      CaretPos.y:= XB;
    end else begin
      if FSelected then FSelEndOffs:= 0;
      CaretPos.y:= 0;
    end;
  end;

  procedure CtrlKeyRightKey;
  var
    S: TGSString;
    I: Integer;
    NotFindIt: Boolean;
  begin
    if CaretPos.x <= FLines.Count - 1 then begin
      NotFindIt:= True;
      while NotFindIt do begin
        S:= FLines[CaretPos.x];
        I:= CaretPos.y;
        if GetNextWord(S, I) then begin
          CaretPos.y:= I - 1;
          NotFindIt:= False;
        end else begin
          CaretPos.x:= CaretPos.x + 1;
          CaretPos.y:= 1;
        end;
        if CaretPos.x >= FLines.Count then begin
          NotFindIt:= False;
          CaretPos.y:= 0;
        end;
      end;
    end else
      CaretPos.y:= 0;
  end;

begin
  case Direction of
    VK_LEFT: { Left Arrow key is pressed. }
      begin
        CaretPos.y:= CaretPos.y - 1;
        if CaretPos.y < 0 then begin
          if CaretPos.x > 0 then begin
            if CaretPos.x <= FLines.Count - 1 then begin
              GliphY:= (CaretPos.x - FTopLine) * FChrH;
              DrawLine(Canvas, CaretPos.x, GliphY);
              SetCaretPosXYFocus;
              if (ssCtrl in ShiftState) and (CaretPos.X > 0) then begin
                CaretPos.X:= CaretPos.X - 1;
                CaretPos.y:= Length(FLines[CaretPos.X]);
                if FSelected then
                begin
                  FSelEndNo:= CaretPos.X;
                  FSelEndOffs:= CaretPos.y;
                  DrawVisible;
                end;
                Exit;
              end;
            end;
            CaretPos.X:= CaretPos.X - 1;
            CaretPos.y:= Length(FLines[CaretPos.X]);
            if not FSelected then begin
              GliphY:= (CaretPos.X - FTopLine) * FChrH;
              DrawLine(Canvas, CaretPos.X, GliphY);
            end else
              DrawVisible;
          end else begin
            CaretPos.y:= 0;
            GliphY:= (CaretPos.X - FTopLine) * FChrH;
            if not FSelected then
              DrawLine(Canvas, CaretPos.X, GliphY)
            else
              DrawVisible;
          end;
        end else begin
          GliphY:= (CaretPos.X - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.X, GliphY);
          SetCaretPosXYFocus;
        end;
        if ssShift in ShiftState then
        begin
          if not FSelected then
          begin
            if CaretPos.X <= FLines.Count - 1 then
              if CaretPos.y > Length(FLines[CaretPos.X]) then
                CaretPos.y:= Length(FLines[CaretPos.X]) - 1;
            FSelected:= True;
            FSelStartNo:= CaretPos.X;
            FSelStartOffs:= CaretPos.y + 1;
            FSelEndNo:= CaretPos.X;
            if ssCtrl in ShiftState then
              CtrlKeyLeftKey
            else
              FSelEndOffs:= CaretPos.y;
          end else begin
            FSelEndNo:= CaretPos.X;
            if ssCtrl in ShiftState then
              CtrlKeyLeftKey
            else
              FSelEndOffs:= CaretPos.y;
            if FSelEndNo <= pred(FLines.Count) then
            begin
              if FSelEndOffs > Length(FLines[FSelEndNo]) then
              begin
                FSelEndOffs:= Length(FLines[FSelEndNo]) - 1;
                CaretPos.y:= FSelEndOffs;
              end;
            end else
            begin
              FSelEndOffs:= 0;
              CaretPos.y:= 0;
            end;
          end;
          FSelected:= (FSelStartNo <> FSelEndNo) or (FSelStartOffs <> FSelEndOffs);
          DrawVisible;
          Exit;
        end;
        if FSelected then
        begin
          FSelected:= False;
          DrawVisible;
        end;
        if ssCtrl in ShiftState then begin
          CtrlKeyLeftKey;
          DrawVisible;
        end;
        FSelStartNo:= CaretPos.X;
        FSelStartOffs:= CaretPos.y;
      end;
    VK_RIGHT: { Right Arrow key is pressed. }
      begin
        CaretPos.y:= CaretPos.y + 1;
        if CaretPos.y > FMaxScrollH then begin
          FMaxScrollH:= FMaxScrollH + 2;
          UpdateScrollBars;
        end;
        if CaretPos.X <= FLines.Count - 1 then begin
          GliphY:= (CaretPos.X - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.X, GliphY);
        end;
        if ssShift in ShiftState then begin
          if not FSelected then begin
            FSelected:= True;
            FSelStartNo:= CaretPos.X;
            FSelStartOffs:= CaretPos.y - 1;
            if ssCtrl in ShiftState then CtrlKeyRightKey;
            FSelEndNo:= CaretPos.X;
            FSelEndOffs:= CaretPos.y;
          end else begin
            if ssCtrl in ShiftState then CtrlKeyRightKey;
            FSelEndNo:= CaretPos.X;
            FSelEndOffs:= CaretPos.y;
          end;
          FSelected:= (FSelStartNo <> FSelEndNo) or (FSelStartOffs <> FSelEndOffs);
          DrawVisible;
          Exit;
        end;
        if FSelected then begin
          FSelected:= False;
          DrawVisible;
        end;
        if ssCtrl in ShiftState then begin
          CtrlKeyRightKey;
          DrawVisible;
        end;
        SetCaretPosXYFocus;
        FSelStartNo:= CaretPos.X;
        FSelStartOffs:= CaretPos.y;
      end;
    VK_UP: { Up Arrow key is pressed. }
      begin
        if CaretPos.X = 0 then Exit;
        if not (ssShift in ShiftState) and not (ssCtrl in ShiftState) then begin
          CaretPos.X:= CaretPos.X - 1;
          if FSelected then begin
            FSelected:= False;
            DrawVisible;
            Exit;
          end;
          FSelStartNo:= CaretPos.X;
          GliphY:= (CaretPos.X - FTopLine + 1) * FChrH;
          DrawLine(Canvas, CaretPos.X + 1, GliphY);
          GliphY:= (CaretPos.X - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.X, GliphY);
          SetCaretPosXYFocus;
          Exit;
        end;
        if (ssCtrl in ShiftState) and not (ssShift in ShiftState) then begin
          CaretPos.X:= CaretPos.X - 1;
          Perform(WM_VSCROLL, SB_LINEUP, 0);
          FSelStartNo:= CaretPos.X;
          if VPos = 0 then  begin
            GliphY:= (CaretPos.X - FTopLine + 1) * FChrH;
            DrawLine(Canvas, CaretPos.X + 1, GliphY);
            GliphY:= (CaretPos.X - FTopLine) * FChrH;
            DrawLine(Canvas, CaretPos.X, GliphY);
          end;
          SetCaretPosXYFocus;
          Exit;
        end;
        if not (ssCtrl in ShiftState) and (ssShift in ShiftState) then begin
          CaretPos.X:= CaretPos.X - 1;
          if not FSelected then begin
            FSelStartNo:= CaretPos.X + 1;
            FSelStartOffs:= CaretPos.y;
            FSelEndNo:= CaretPos.X;
            FSelEndOffs:= CaretPos.y;
            FSelected:= True;
          end else begin
            FSelEndNo:= CaretPos.X;
            FSelEndOffs:= CaretPos.y;
            FSelected:= (FSelStartNo <> FSelEndNo) or (FSelStartOffs <> FSelEndOffs);
          end;
          DrawVisible;
        end;
      end;
    VK_DOWN: { Down Arrow key is pressed. }
      begin
        if CaretPos.X >= FLines.Count - 1 then Exit;
        if not (ssShift in ShiftState) and not (ssCtrl in ShiftState) then begin
          CaretPos.X:= CaretPos.X + 1;
          if FSelected then begin
            FSelected:= False;
            DrawVisible;
            Exit;
          end;
          FSelStartNo:= CaretPos.X;
          GliphY:= (CaretPos.X - FTopLine - 1) * FChrH;
          DrawLine(Canvas, CaretPos.X - 1, GliphY);
          GliphY:= (CaretPos.X - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.X, GliphY);
          SetCaretPosXYFocus;
          Exit;
        end;
        if (ssCtrl in ShiftState) and not (ssShift in ShiftState) then begin
          CaretPos.X:= CaretPos.X + 1;
          Perform(WM_VSCROLL, SB_LINEDOWN, 0);
          FSelStartNo:= CaretPos.X;
          if VPos > FLines.Count - FVisLines then begin
            GliphY:= (CaretPos.X - FTopLine - 1) * FChrH;
            DrawLine(Canvas, CaretPos.X - 1, GliphY);
            GliphY:= (CaretPos.X - FTopLine) * FChrH;
            DrawLine(Canvas, CaretPos.X, GliphY);
          end;
          SetCaretPosXYFocus;
          Exit;
        end;
        if not (ssCtrl in ShiftState) and (ssShift in ShiftState) then begin
          CaretPos.X:= CaretPos.X + 1;
          if not FSelected then begin
            FSelStartNo:= CaretPos.X - 1;
            FSelStartOffs:= CaretPos.y;
            FSelEndNo:= CaretPos.X;
            FSelEndOffs:= CaretPos.y;
            FSelected:= True;
          end else begin
            FSelEndNo:= CaretPos.X;
            FSelEndOffs:= CaretPos.y;
            FSelected:= (FSelStartNo <> FSelEndNo) or (FSelStartOffs <> FSelEndOffs);
          end;
          DrawVisible;
        end;
      end;
    VK_HOME: { Home key is pressed. }
      begin
        if not (ssCtrl in ShiftState) and not (ssShift in ShiftState) then begin
          CaretPos.y:= 0;
          if FSelected then begin
            FSelected:= False;
            DrawVisible;
          end else begin
            GliphY:= (CaretPos.X - FTopLine) * FChrH;
            DrawLine(Canvas, CaretPos.X, GliphY);
          end;
          SetCaretPosXYFocus;
        end;
        if ssCtrl in ShiftState then begin
          if ssShift in ShiftState then begin
            if not FSelected then begin
              FSelStartNo:= CaretPos.X;
              FSelStartOffs:= CaretPos.y;
              FSelected:= True;
            end;
            CaretPos.X:= 0;
            CaretPos.y:= 0;
            FSelEndNo:= 0;
            FSelEndOffs:= 0;
            DrawVisible;
          end else begin
            SetCaretPosXYFocus;
            CaretPos.X:= 0;
            CaretPos.y:= 0;
          end;
          Exit;
        end;
        if ssShift in ShiftState then begin
          SetCaretPosXYFocus;
          if not FSelected then begin
            FSelStartNo:= CaretPos.X;
            FSelStartOffs:= CaretPos.y;
            FSelected:= True;
          end;
          CaretPos.y:= 0;
          FSelEndNo:= CaretPos.X;
          FSelEndOffs:= 0;
          if FSelEndNo = FSelStartNo then FSelected:= (FSelStartOffs <> FSelEndOffs);
          DrawVisible;
        end;
      end;
    VK_END: { End key is pressed. }
      begin
        if not (ssCtrl in ShiftState) and not (ssShift in ShiftState) then begin
          if CaretPos.X <= pred(FLines.Count)
          then CaretPos.y:= Length(FLines[CaretPos.X])
          else CaretPos.y:= 0;
          if FSelected then begin
            FSelected:= False;
            DrawVisible;
          end else begin
            GliphY:= (CaretPos.X - FTopLine) * FChrH;
            DrawLine(Canvas, CaretPos.X, GliphY);
          end;
          SetCaretPosXYFocus;
        end;
        if ssCtrl in ShiftState then begin
          if ssShift in ShiftState then begin
            if not FSelected then begin
              FSelStartNo:= CaretPos.X;
              FSelStartOffs:= CaretPos.y;
              FSelected:= True;
            end;
            CaretPos.X:= FLines.Count - 1;
            CaretPos.y:= Length(FLines[CaretPos.X]);
            FSelEndNo:= pred(FLines.Count);
            FSelEndOffs:= Length(FLines[CaretPos.X]);
            DrawVisible;
          end else begin
            SetCaretPosXYFocus;
            CaretPos.X:= FLines.Count - 1;
            CaretPos.y:= Length(FLines[CaretPos.X]);
          end;
          Exit;
        end;
        if ssShift in ShiftState then begin
          SetCaretPosXYFocus;
          if not FSelected then
          begin
            FSelStartNo:= CaretPos.X;
            if CaretPos.X <= FLines.Count - 1 then
              if CaretPos.y > Length(FLines[CaretPos.X]) then
                CaretPos.y:= Length(FLines[CaretPos.X]);
            FSelStartOffs:= CaretPos.y;
            FSelected:= True;
          end;
          if CaretPos.X <= FLines.Count - 1 then
            CaretPos.y:= Length(FLines[CaretPos.X])
          else
            CaretPos.y:= 0;
          FSelEndNo:= CaretPos.X;
          FSelEndOffs:= CaretPos.y;
          if FSelEndNo = FSelStartNo then FSelected:= (FSelStartOffs <> FSelEndOffs);
          DrawVisible;
        end;
      end;
    VK_PRIOR, VK_NEXT: { Page Up key or Page Down key is pressed. }
      begin
        if not FSelected then begin
          FSelStartNo:= CaretPos.X;
          FSelStartOffs:= CaretPos.y;
        end;
        SaveXCaret:= CaretPos.X - FTopLine;
        if Direction = VK_PRIOR then begin
          if VPos = 0 then begin
            SetCaretPosXYFocus;
            CaretPos.X:= 0;
            CaretPos.y:= 0;
          end else
          begin
            Perform(WM_VSCROLL, SB_PAGEUP, 0);
            CaretPos.X:= FTopLine + SaveXCaret;
          end;
        end else
        begin
          if VPos > FLines.Count - FVisLines then
          begin
            SetCaretPosXYFocus;
            CaretPos.X:= FLines.Count - 1;
            CaretPos.y:= Length(FLines[CaretPos.X]);
          end else
          begin
            Perform(WM_VSCROLL, SB_PAGEDOWN, 0);
            CaretPos.X:= FTopLine + SaveXCaret;
          end;
        end;
        SetCaretPosXYFocus;
        if ssShift in ShiftState then begin
          FSelEndNo:= CaretPos.X;
          FSelEndOffs:= CaretPos.y;
          if not FSelected then FSelected:= True;
          DrawVisible;
        end;
      end;
  end;
end;

procedure TECustomMemo.KeyPress(var Key: Char);
var
  Fill, GliphY: Integer;
  SLine: TGsString;
  W: WideChar;
begin
  inherited KeyPress(Key);
  if CaretPos.X > FLines.Count - 1 then begin
    for fill:= FLines.Count to CaretPos.X do begin
      FLines.Add('');
    end;
  end;
  if key > #31 then begin
    Modified:= True;
    if FSelected then begin
      DeleteSelection;
    end;
    SLine:= FLines[CaretPos.X];
    if Length(SLine) < CaretPos.y + 1 then begin
      for Fill:= Length(SLine) to CaretPos.y + 1
      do SLine:= SLine + #32;
    end;

    W:= KeyUnicode(Key);

    if FOverwrite then begin
      SLine[CaretPos.y + 1]:= W;
      Self.FUndoRedoMgr.AddDo(urReplace, CaretPos, Point(CaretPos.X, CaretPos.Y +1), W);
    end else begin
      Insert(W, SLine, CaretPos.y + 1);
      Self.FUndoRedoMgr.AddDo(urInsert, CaretPos, Point(CaretPos.X, CaretPos.Y +1), W);
    end;
    FLines[CaretPos.X]:= SLine;
    CaretPos.y:= CaretPos.y + 1;
    GliphY:= (CaretPos.X - FTopLine) * FChrH;
    DrawLine(Canvas, CaretPos.X, GliphY);
    FSelStartNo:= CaretPos.X;
    FSelStartOffs:= CaretPos.y;

    if CaretPos.y > HPos + FVisCols then ScrollPos_H:= CaretPos.y - FVisCols;
    if CaretPos.y < HPos then ScrollPos_H:= CaretPos.y;
    if CaretPos.x < FTopLine then ScrollPos_V:= CaretPos.x;
    if CaretPos.x > FTopLine + FVisLines - 2 then ScrollPos_V:= CaretPos.x - FVisLines + 2;
    SetCaretPosXY;
  end;
end;

procedure TECustomMemo.PrepareFindTextURE(const AFindOptions: TGsFindOptions);
begin
  // ignore non-spacing characters in search
  if (foRegIgnoreNonSpacing in AFindOptions)
  then FFindUREPrepared:= Lines.GetSeparatedText(WideTabulator)  // #9
  else FFindUREPrepared:= Lines.Text;
  {
  // handle several consecutive white spaces as one white space (this applies to the pattern as well as the search text)
  if (foRegSpaceCompress in AFindOptions)
  then util1.DeleteDoubledSpaceStr(FFindUREPrepared);
  }
end;

procedure TECustomMemo.UnPrepareFindTextURE;
begin
  FFindUREPrepared:= '';
end;

function TECustomMemo.FindReplaceProc(TextToFind: TGSString; FindOptions: TGsFindOptions;
  ReplaceMode: Boolean; var ReplaceText: Boolean): Boolean;
var
  SrcBegin, SrcEnd: TPoint;
  R: TRect;
  found: Boolean;

  procedure ShowSelection(AFindPos, AFindPosEnd: TPoint);
  var
    ScrollX, ScrollY: Integer;
  begin

    // scroll
    ScrollX:= 0;
    ScrollY:= (FTopLine * FChrH);

    if ((AFindPosEnd.Y + 1) * FChrW) - FChrW > ClientWidth
    then ScrollX:= (AFindPos.Y * FChrW) - 2 * FChrW;
    if AFindPos.X > FTopLine + FVisLines - 2
    then ScrollY:= AFindPos.X * FChrH // forward going
    else begin
      // backward going
      if AFindPos.X < FTopLine
      then ScrollY:= AFindPos.X * FChrH
    end;
    ScrollTo(ScrollX, ScrollY);
    Invalidate;
  end;

  procedure DoSearchInStrings(const AStart, AFinish: TPoint);
  var
    SLine: TGSString;
    FindPosEnd, FindPos: TPoint;
    I, WordPos: Integer;
    AllowScroll, ContinueSrc: Boolean;
    SrcWord: TGSString;
  begin
    // case sensitive
    if not (foCaseSensitive in FindOptions)
    then SrcWord:= ANSIUpperCase(TextToFind)
    else SrcWord:= TextToFind;

    // loop (forward or backward)
    AllowScroll:= Assigned(Self.Parent);
    I:= AStart.X;
    repeat
      if (foCaseSensitive in FindOptions)
      then SLine:= FLines[I]
      else SLine:= ANSIUpperCase(FLines[I]);
      FindPos.Y:= 0;
      WordPos:= Pos(SrcWord, SLine);
      while WordPos > 0 do begin
        if (I = CaretPos.X) and (WordPos < CaretPos.y) then begin
          Inc(FindPos.Y, WordPos);
          WordPos:= util1.PosFrom(WordPos + Length(SrcWord), SrcWord, SLine);
          Continue;
        end;
        FindPos.Y:= WordPos;
        FindPos.X:= I;
        ContinueSrc:= False;
        if foWholeWords in FindOptions then begin
          if WordPos > 1 then
            if (SLine[WordPos - 1] > #32) then begin
              Inc(FindPos.Y, WordPos);
              WordPos:= util1.PosFrom(WordPos + Length(SrcWord), SrcWord, SLine);
              Continue;
            end;
          if WordPos + Length(SrcWord) <= Length(SLine) then begin
            if (SLine[WordPos + Length(SrcWord)] > #32) then begin
              Inc(FindPos.Y, WordPos);
              WordPos:= util1.PosFrom(WordPos + Length(SrcWord), SrcWord, SLine);
              Continue;
            end;
          end;
        end;

        FindPosEnd.X:= FindPos.X;
        FindPosEnd.Y:= FindPos.Y + Length(SrcWord) - 1;
        found:= True;

        // make selection
        FSelStartNo:= FindPos.X;
        FSelEndNo:= FindPosEnd.X;
        FSelStartOffs:= FindPos.Y - 1;
        FSelEndOffs:= FindPosEnd.Y;
        FSelected:= True;
        CaretPos:= FindPosEnd;

        if Self.Visible then begin
          if AllowScroll
          then ShowSelection(FindPos, FindPosEnd)
          else begin
            CaretPos:= FindPosEnd;
            Invalidate;
          end;
        end;
        Result:= True;
        if ReplaceMode then begin
          if Assigned(FOnReplaceText)
          then FOnReplaceText(Self, FindPos, AllowScroll, ReplaceText);
          RepPos:= FindPos;
        end else begin
          if Assigned(FOnFindText)
          then FOnFindText(Self, FindPos, AllowScroll);
        end;
        WordPos:= util1.PosFrom(WordPos + Length(SrcWord), SrcWord, SLine);
        if not ContinueSrc
        then Exit;
      end;
      // backward or forward
      if (foBackward in FindOptions) then begin
        Dec(I);
        if I < AFinish.X
        then Break;
      end else begin
        Inc(I);
        if I > AFinish.X
        then Break;
      end;
    until False; // of loop
  end;

  procedure DoSearchURE;
  var
    URESearch: TURESearch;
    fl: TSearchFlags;
    AllowScroll: Boolean;
    FindPos, FindEndPos: TPoint;
    ws: WideString;
    ofs0, ofs1: Cardinal;
  begin
    AllowScroll:= Assigned(Self.Parent);
    URESearch:= TURESearch.Create(FLines);
    fl:= [];
    if (foWholeWords in FindOptions)
    then Include(fl, sfWholeWordOnly);         // match only text at end/start and/or surrounded by white spaces
    if (foCaseSensitive in FindOptions)
    then Include(fl, sfCaseSensitive);         // match letter case
    if (foRegIgnoreNonSpacing in FindOptions)
    then Include(fl, sfIgnoreNonSpacing);      // ignore non-spacing characters in search
    if (foRegSpaceCompress in FindOptions)
    then Include(fl, sfSpaceCompress);         // handle several consecutive white spaces as one white space (this applies to the pattern as well as the search text)

    URESearch.FindPrepare(TextToFind, fl);
    if Length(FFindUREPrepared) = 0
    then ws:= Lines.Text
    else ws:= FFindUREPrepared;

    FindPos:= SrcBegin;
    ofs0:= util1.SLTranslateLines2Ofs(Lines, FindPos);
    FindPos:= SrcEnd;
    ofs1:= SLTranslateLines2Ofs(Lines, FindPos);

    Result:= URESearch.FindFirst(ws, ofs0, ofs1);
    FindPos:= SLTranslateOfs2Pos(Lines, ofs0);
    FindEndPos:= SLTranslateOfs2Pos(Lines, ofs1 - 1);

    if Result then begin
      // make selection
      FSelStartNo:= FindPos.X;
      FSelEndNo:= FindEndPos.X;
      FSelStartOffs:= FindPos.Y - 1;
      FSelEndOffs:= FindEndPos.Y;
      FSelected:= True;
      CaretPos:= FindEndPos;

      // scroll
      if AllowScroll
      then ShowSelection(FindPos, FindEndPos)
      else begin
          CaretPos:= FindEndPos;
          Invalidate;
        end;

      // replace
      if ReplaceMode then begin
        if Assigned(FOnReplaceText)
        then FOnReplaceText(Self, FindPos, AllowScroll, ReplaceText);
        RepPos:= FindPos;
      end else begin
        if Assigned(FOnFindText)
        then FOnFindText(Self, FindPos, AllowScroll);
      end;
    end;
    URESearch.Free;
  end;


  procedure DoSearchXPath;
  var
{$IFDEF USE_DOM}
    recs: IXMLDOMNodeList;
{$ENDIF}
    AllowScroll: Boolean;
    FindPos, FindEndPos: TPoint;
    p: Integer;
    ofs0, ofs1: Cardinal;
    tmpfn: String;
  begin
    AllowScroll:= Assigned(Self.Parent);

    tmpfn:= CreateTemporaryFileName('xpath');
    Lines.SaveToFile(tmpfn);
    FindPos:= SrcBegin;
    ofs0:= util1.SLTranslateLines2Ofs(Lines, FindPos);
    FindPos:= SrcEnd;
    ofs1:= SLTranslateLines2Ofs(Lines, FindPos);
{$IFDEF USE_SAX}
    Result:= xmlParse.xmlXPath(tmpfn, TextToFind, recs);
    if Result and (recs.length  > 0) then begin
      // recs.item[0].attributes[1]. item[i]. P.selectSingleNode
      // ofs0, ofs1
      FindPos:= SLTranslateOfs2Pos(Lines, ofs0);
      FindEndPos:= SLTranslateOfs2Pos(Lines, ofs1 - 1);

      // make selection
      FSelStartNo:= FindPos.X;
      FSelEndNo:= FindEndPos.X;
      FSelStartOffs:= FindPos.Y - 1;
      FSelEndOffs:= FindEndPos.Y;
      FSelected:= True;
      CaretPos:= FindEndPos;

      // scroll
      if AllowScroll
      then ShowSelection(FindPos, FindEndPos)
      else begin
          CaretPos:= FindEndPos;
          Invalidate;
        end;

      // replace
      if ReplaceMode then begin
        if Assigned(FOnReplaceText)
        then FOnReplaceText(Self, FindPos, AllowScroll, ReplaceText);
        RepPos:= FindPos;
      end else begin
        if Assigned(FOnFindText)
        then FOnFindText(Self, FindPos, AllowScroll);
      end;
    end;
{$ELSE}
    Result:= False;
{$ENDIF}
    DeleteFile(tmpfn);
  end;

begin
  Result:= False;
  if FLines.Count = 0
  then Exit;
  if fRegularExpression in FindOptions
  then Exclude(FindOptions, foBackward);
  // scope
  if (foGlobalScope in FindOptions) or (not FSelected) then begin
    SrcBegin.X:= 0;
    SrcBegin.Y:= 1;
    SrcEnd.X:= FLines.Count - 1;
    SrcEnd.Y:= Length(FLines[FLines.Count-1])
  end else begin
    // selection
    SrcBegin.X:= FSelStartNo;
    SrcBegin.Y:= FSelEndOffs;
    SrcEnd.X:= FSelEndNo;
    SrcEnd.Y:= FSelStartOffs;
  end;
  if (foBackward in FindOptions) then begin
    // swap
    R.TopLeft:= SrcBegin;
    SrcBegin:= SrcEnd;
    SrcEnd:= R.TopLeft;
  end;

  // SrcBegin, SrcEnd, SrcWord are prepared to search

  if (fRegularExpression in FindOptions) then begin
    if foOriginFromCursor in FindOptions then SrcBegin:= CaretPos;     // origin
    DoSearchURE;
  end else begin
    if (foXPath in FindOptions) then begin
      if foOriginFromCursor in FindOptions then SrcBegin:= CaretPos;     // origin
      DoSearchXPath;
    end else begin
      R.Left:= SrcBegin.X;
      R.Top:= 1;
      R.Right:= SrcEnd.X;
      R.Bottom:= MaxInt;
      // origin
      if foOriginFromCursor in FindOptions then begin
        SrcBegin:= CaretPos;
      end;

      if PtInRect(R, CaretPos) then begin
        found:= False;
        DoSearchInStrings(CaretPos, SrcEnd);
        if not found
        then DoSearchInStrings(SrcBegin, CaretPos);
      end else begin
        DoSearchInStrings(SrcBegin, SrcEnd);
      end;
    end;
  end;
end;

function TECustomMemo.FindText(TextToFind: TGSString; FindOptions: TGsFindOptions): Boolean;
var
  Rep: Boolean;
begin
  Result:= FindReplaceProc(TextToFind, FindOptions, False, Rep);
  if Assigned(FOnSearchEnd)
  then FOnSearchEnd(Self, Result, False);
end;

function TECustomMemo.ReplaceText(TextToFind, TextToReplace: TGSString; FindOptions: TGsFindOptions): Boolean;
var
  Rep: Boolean;
begin
  Rep:= True;
  Result:= FindReplaceProc(TextToFind, FindOptions, True, Rep);
  if Result and Rep then begin
    DeleteSelection;
    Self.InsertTextAtPos(TextToReplace, CaretPos.y, CaretPos.X);
  end;
  if Assigned(FOnSearchEnd)
  then FOnSearchEnd(Self, Result, True);
end;

procedure TECustomMemo.Clear;
begin
  CaretPos.X:= 0;
  CaretPos.y:= 0;
  ScrollTo(0, 0);
  Self.FSelStartNo:= 0;
  FSelStartOffs:= 0;
  FSelEndNo:= 0;
  FSelEndOffs:= 0;
  FLines.Clear;
  FLines.Add('');
  FSelected:= False;
  Invalidate;
  Modified:= True;
end;

procedure TECustomMemo.SaveToStream(AStream: TStream);
var
  BuffList: TWideStringList; // was TStringList Mar 02 2007
  SLine: TGSString;
  I, P: Integer;
  d: Integer;
begin
  BuffList:= TWideStringList.Create;
  BuffList.Assign(FLines);
  for I:= 0 to BuffList.Count - 1 do begin
    SLine:= BuffList[I];
    P:= Length(SLine);
    d:= 0;
    while (P > 0) and (SLine[P] = #32) do begin
      d:= p;
      Dec(P);
    end;
    if d > 0 then begin
      Delete(SLine, d, MaxInt);
      BuffList[I]:= SLine;
    end;
  end;
  BuffList.SaveToStream(AStream);
  BuffList.Free;
  Modified:= False;
end;

procedure TECustomMemo.SaveToFile(const AFileName: TGSString);
var
  Stream: TStream;
begin
  Stream:= TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TECustomMemo.LoadFromFile(const AFileName: TGSString);
begin
  if not FileExists(AFileName) then Exit;
  Clear;  // set Modified:= True;
  FLines.LoadFromFile(AFileName);
  FModified:= False;
  FModifiedSinceLastDelay:= True;
  Invalidate;
end;

procedure TECustomMemo.SetModified(AValue: Boolean);
begin
  FModified:= AValue;
  if AValue then begin
    if Assigned(FOnModified)
    then FOnModified(Self);
    FModifiedSinceLastDelay:= True;
  end;
end;

{ Undo & Redo Implementation }

procedure TECustomMemo.Undo;
var
  pt, pt2: TPoint;
  ws: WideString;
  act: TUndoRedoAction;
begin
  act:= FUndoRedoMgr.Undo(pt, pt2, ws);
  CaretPos:= pt;
  case act of
  urNone:;
  urInsert: begin
      // CaretPos:= pt;
      DeleteBetweenPos(pt, pt2);
    end;
  urDelete: begin
      CaretPos:= pt;
      InsertText(ws);
    end;
  urReplace: begin
      DeleteBetweenPos(pt, pt2);
      InsertText(ws);
    end;
  urMove: CaretPos:= pt;
  end;
end;

procedure TECustomMemo.Redo;
var
  pt, pt2: TPoint;
  ws: WideString;
  act: TUndoRedoAction;
begin
  act:= FUndoRedoMgr.Redo(pt, pt2, ws);
  CaretPos:= pt;
  case act of
  urNone:;
  urInsert: begin
      InsertText(ws);
    end;
  urDelete: DeleteBetweenPos(pt, pt2);
  urReplace: begin
      DeleteBetweenPos(pt, pt2);
      InsertText(ws);
    end;
  urMove: CaretPos:= pt;
  end;
end;

{ Register Components and  Property Editors }

procedure Register;
begin
  RegisterComponents('Additional', [TEMemo]);
end;

end.
