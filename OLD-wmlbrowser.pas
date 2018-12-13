unit wmlbrowser;
(*##*)
(*******************************************************************************
*                                                                              *
*   w  m  l  b  r  o  w  s  e  r                                              *
*   wml browser class implementation, part of apooed                           *
*   THIS CODE IS DEPRECATED                                                   *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    :                                                             *
*   Last revision:                                                            *
*   Lines        : 1751                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls,
  wml, wmlparse, wmlstyle;

resourcestring
  INFOMSG_HINT = 'Hint';
  INFOMSG_WARNING = 'Warning';
  INFOMSG_ERROR = 'Error';
  INFOMSG_SEARCH = 'Search';

type
  TForEachProc = procedure (AWMLElement: TWMLElement) of object;

  TWMLBrowserKeyEvent = (k_Down, k_Press, k_Up, k_Mouse1, k_Mouse2, k_Mouse3, k_DoubleClick, k_None);

  TTextScroledEvent = procedure(Sender: TObject; TopRow, BottomRow,
    LeftCol, MaxCols: Integer) of object;
  TDrawLineEvent = procedure(Sender: TObject; LineText: string; LineIndxe: Integer;
    LineGlyph: TBitmap; TextRect: TRect; var AllowSelfDraw: Boolean) of object;
  THyperlinkClickEvent = procedure(Sender: TObject; Hyperlink: string) of object;

  TWMLBrowser = class(TCustomControl)
  private
    FCalculatedSize: TRect;
    FWMLParser: TWMLParser;
    FWMLCollection: TWMLElementCollection;
    FWMLElementStyles: TWMLElementStyles;
    FParseMessages: TStrings;

    FTracking: Boolean;
    FFullRedraw: Boolean;
    FVScrollVisible, FHScrollVisible: Boolean;
    FOnScrolled_V,
    FOnScrolled_H: TNotifyEvent;
    FOnTextScrolled: TTextScroledEvent;
{$IFDEF D4_}
    FOnMouseWheel: TMouseWheelEvent;
    FOnMouseWheelDown: TMouseWheelUpDownEvent;
    FOnMouseWheelUp: TMouseWheelUpDownEvent;
    FWheelAccumulator: Integer;
{$ENDIF}
    FOnPaint: TNotifyEvent;
    FScrollBars: TScrollStyle;
    FBorderStyle: TBorderStyle;
    FMaxScrollH: Integer;
    FLines: TStrings;
    FSrc: String;
    FChrW, FChrH: Integer;
    FTopLine, FVisLines, FVisCols: Integer;
    FSelStartNo, FSelEndNo, FSelStartOffs, FSelEndOffs: Integer;
    FSelected, FSelMouseDwn: Boolean;
    ScrollHPos, ScrollVPos, XSize, YSize: Integer;
    StartNo, EndNo, StartOffs, EndOffs: Integer;
    CaretPos, MousePos: TPoint;
    ShiftState: TShiftState;
    FDblClick,
    FNotHideHint: Boolean;
    FHintWnd: THintWindow;

    FOnDrawLine: TDrawLineEvent;
    FOnHyperlinkClick: THyperlinkClickEvent;

    procedure SetVScrollPos(P: Integer);
    function GetVScrollMax: Integer;
    procedure SetHScrollPos(P: Integer);
    function GetHScrollMax: Integer;

    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetLines(Value: TStrings);
    function GetSelBegin: TPoint;
    function GetSelEnd: TPoint;
    procedure SetSelBegin(Value: TPoint);
    procedure SetSelEnd(Value: TPoint);
    function ParseSource: Boolean;
    procedure ProcCalcPageSize(AWmlElement: TWMLElement);
    procedure CalcPageSize;
    procedure ShowParseMessage(ALevel: TReportLevel; AWMLElement: TWMLElement;
      const ASrc: String; AWhere: TPoint; const ADesc: String; var AContinueParse: Boolean);
  protected
    procedure ForEachElement(AWMLElement: TWMLElement; AProc: TForEachProc);
    procedure DoExit; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure UpdateScrollBars;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
{$IFDEF D4_}
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint); dynamic;
    function MouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; dynamic;
    function MouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; dynamic;
{$ENDIF}
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure ScrollChildren(dx, dy: Integer);
    procedure UpdateChildren;
    procedure UpdateCharBounds;
    procedure FormatLine(I: Integer; var LGliph: TBitmap);
    procedure Paint; override;
    procedure DrawLine(CanvasSupport: TCanvas; I, Y: Integer);
    procedure DrawVisible;
    procedure GetSelBounds(var StartNo, EndNo, StartOffs, EndOffs: Integer);
    procedure KeyboardCaretNav(ShiftState: TShiftState; Direction: Word);
    procedure ShowTextHint(X, Y: Integer; HintMsg: string);
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure KeyPress(var Key: Char); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetSelText: string;
    function GetWordAtPos(Col, Row: Integer; var XBegin: Integer): string;
    procedure GetRowColAtPos(X, Y: Integer; var Row, Col: Integer);
    procedure ScrollTo(X, Y: Integer);
    procedure CopyToClipboard;
    procedure Clear;
    procedure LoadFromFile(const FileName: string);
    property SelBegin: TPoint read GetSelBegin write SetSelBegin;
    property SelEnd: TPoint read GetSelEnd write SetSelEnd;
    property Selected: Boolean read FSelected;
    property FontHeight: Integer read FChrH;
    property FontWidth: Integer read FChrW;
    property HideHintWindow: Boolean read FNotHideHint write FNotHideHint;
    property HintWindow: THintWindow read FHintWnd write FHintWnd;
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars default ssBoth;
    property ScrollMax_H: Integer read GetHScrollMax;
    property ScrollMax_V: Integer read GetVScrollMax;
    property ScrollPos_H: Integer read ScrollHPos write SetHScrollPos;
    property ScrollPos_V: Integer read ScrollVPos write SetVScrollPos;
    property TopLine: Integer read FTopLine;
    property VisibleLines: Integer read FVisLines;
    { Published declarations }
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property FullRedraw: Boolean read FFullRedraw write FFullRedraw default False;
    property Lines: TStrings read FLines write SetLines;
    property Tracking: Boolean read FTracking write FTracking default False;
    property OnDrawLine: TDrawLineEvent read FOnDrawLine write FOnDrawLine;
    property OnHyperlinkClick: THyperlinkClickEvent read FOnHyperlinkClick write FOnHyperlinkClick;
{$IFDEF D4_}
    property OnMouseWheel: TMouseWheelEvent read FOnMouseWheel write FOnMouseWheel;
    property OnMouseWheelDown: TMouseWheelUpDownEvent read FOnMouseWheelDown write FOnMouseWheelDown;
    property OnMouseWheelUp: TMouseWheelUpDownEvent read FOnMouseWheelUp write FOnMouseWheelUp;
{$ENDIF}
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnScrolled_H: TNotifyEvent read FOnScrolled_H write FOnScrolled_H;
    property OnScrolled_V: TNotifyEvent read FOnScrolled_V write FOnScrolled_V;
    property OnTextScrolled: TTextScroledEvent read FOnTextScrolled write FOnTextScrolled;
    {}
    property WMLElementStyles: TWMLElementStyles read FWMLElementStyles write FWMLElementStyles;
  end;

const
  clBookmarkColor = clOlive;
  clBookmarkBkColor = clGreen;
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

  HINT_FONTSIZE = 8;

resourcestring
  HINT_FONT = 'MS Sans Serif';

implementation

uses
  Clipbrd;

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

(* TWMLBrowser ******************************************************************************)

constructor TWMLBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSrc:= '';
  FParseMessages:= TStringList.Create;
  FWMLParser:= TWMLParser.Create;
  FWMLCollection:= TWMLElementCollection.Create(TWMLWML, Nil, wciOne);
  FWMLCollection.Add;
  // FWML:= TWMLWML(FWMLCollection.Items[0]);
  FWMLElementStyles:= TWMLElementStyles.Create;

  ControlStyle:= ControlStyle + [csReplicatable, csDisplayDragImage
{$IFDEF D4_},csActionClient{$ENDIF}];
  Width:= 320;
  Height:= 240;
  TabStop:= True;
  FTracking:= True;
  FFullRedraw:= False;
  FVScrollVisible:= True;
  FHScrollVisible:= True;
  FBorderStyle:= bsSingle;
  FLines:= TStringList.Create;
  ParentColor:= False;
  Color:= clWindow;
  Font.Name:= 'Fixedsys';
  Font.Color:= clWindowText;
  Font.Size:= 10;
  FTopLine:= 0;
  FMaxScrollH:= 0;
  Cursor:= crIBeam;
  FSelected:= False;
  FSelMouseDwn:= False;
  CaretPos.x:= 0;
  CaretPos.y:= 0;
  FDblClick:= False;

  { Special Hint Window }
  FHintWnd:= nil;

  FChrW:= 10;
  FChrH:= 10;
end;

procedure TWMLBrowser.DoExit;
begin
  inherited;
end;

destructor TWMLBrowser.Destroy;
begin
  FWMLElementStyles.Free;
  FWMLCollection.Free;
  FWMLParser.Free;
  FParseMessages.Free;
  FLines.Free;
  if FHintWnd <> nil
  then FHintWnd.Free;
  inherited Destroy;
end;

procedure TWMLBrowser.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do begin
    Style:= Style or BorderStyles[FBorderStyle];
    Style:= Style or WS_CLIPCHILDREN or WS_HSCROLL or WS_VSCROLL;
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then begin
      Style:= Style and not WS_BORDER;
      ExStyle:= ExStyle or WS_EX_CLIENTEDGE;
    end;
    WindowClass.Style:= WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TWMLBrowser.CreateWnd;
begin
  inherited CreateWnd;
  ScrollVPos:= 0;
  ScrollHPos:= 0;
  UpdateCharBounds;
  UpdateScrollBars;
  if csDesigning in ComponentState then begin
    if FLines.Count = 0
    then FLines.Add(Name);
  end;
end;

procedure TWMLBrowser.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result:= Message.Result or DLGC_WANTTAB or DLGC_WANTARROWS;
end;

{ Setting properties }

procedure TWMLBrowser.SetScrollBars(Value: TScrollStyle);
const
  V_SCROLL: array[TScrollStyle] of Boolean = (False, True, False, True);
  H_SCROLL: array[TScrollStyle] of Boolean = (False, True, True, False);
begin
  if Value <> FScrollBars then begin
    FScrollBars:= Value;
    FVScrollVisible:= V_SCROLL[Value];
    FHScrollVisible:= H_SCROLL[Value];
    ShowScrollBar(Handle, SB_VERT, FVScrollVisible);
    ShowScrollBar(Handle, SB_HORZ, FHScrollVisible);
  end;
end;

procedure TWMLBrowser.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then begin
    FBorderStyle:= Value;
    RecreateWnd;
  end;
end;

procedure TWMLBrowser.SetLines(Value: TStrings);
begin
  FLines.Assign(Value);
  Invalidate;
end;

{ Scrolling implementation }

procedure TWMLBrowser.UpdateScrollBars;
var
  ScrollInfoV, ScrollInfoH: TScrollInfo;
begin
  ScrollInfoV.cbSize:= SizeOf(ScrollInfoV);
  ScrollInfoV.fMask:= SIF_ALL;
  ScrollInfoV.nMin:= 0;
  ScrollInfoV.nPage:= FVisLines - 2;
  ScrollInfoV.nMax:= FLines.Count + 1;
  ScrollInfoV.nPos:= ScrollVPos;
  ScrollInfoV.nTrackPos:= 0;
  SetScrollInfo(Handle, SB_VERT, ScrollInfoV, True);

  ScrollInfoH.cbSize:= SizeOf(ScrollInfoH);
  ScrollInfoH.fMask:= SIF_ALL;
  ScrollInfoH.nMin:= 0;
  ScrollInfoH.nPage:= FMaxScrollH div 4;
  ScrollInfoH.nMax:= FMaxScrollH;
  ScrollInfoH.nPos:= ScrollHPos;
  ScrollInfoH.nTrackPos:= 0;
  SetScrollInfo(Handle, SB_HORZ, ScrollInfoH, True);

  if not FVScrollVisible
  then ShowScrollBar(Handle, SB_VERT, FVScrollVisible);
  if not FHScrollVisible
  then ShowScrollBar(Handle, SB_HORZ, FHScrollVisible);
  UpdateChildren;
end;

procedure TWMLBrowser.UpdateChildren;
var
  I: Integer;
begin
  for I:= 0 to ControlCount - 1 do begin
    CtrlByTagUpdate(Controls[I]);
  end;
end;

procedure TWMLBrowser.ScrollChildren(dx, dy: Integer);
var
  I: Integer;
begin
  if (dx = 0) and (dy = 0) then Exit;
  for I:= 0 to ControlCount - 1 do
  begin
    if dy <> 0 then
    begin
      Controls[I].Tag:= Controls[I].Tag + dy;
      CtrlByTagUpdate(Controls[I]);
    end;
    if dx <> 0 then Controls[I].Left:= Controls[I].Left + dx;
  end;
end;

procedure TWMLBrowser.WMHScroll(var Message: TWMHScroll);
begin
  with Message do
    case ScrollCode of
      SB_LINERIGHT: SetHScrollPos(ScrollHPos + 1);
      SB_LINELEFT: SetHScrollPos(ScrollHPos - 1);
      SB_PAGEUP: SetHScrollPos(ScrollHPos - FVisLines);
      SB_PAGEDOWN: SetHScrollPos(ScrollHPos + FVisLines);
      SB_THUMBPOSITION: SetHScrollPos(Pos);
      SB_THUMBTRACK: if FTracking then SetHScrollPos(Pos);
      SB_TOP: SetHScrollPos(0);
      SB_BOTTOM: SetHScrollPos(XSize);
    end;
end;

procedure TWMLBrowser.WMVScroll(var Message: TWMVScroll);
begin
  with Message do
    case ScrollCode of
      SB_LINEUP: SetVScrollPos(ScrollVPos - 1);
      SB_LINEDOWN: SetVScrollPos(ScrollVPos + 1);
      SB_PAGEUP: SetVScrollPos(ScrollVPos - FVisLines);
      SB_PAGEDOWN: SetVScrollPos(ScrollVPos + FVisLines);
      SB_THUMBPOSITION: SetVScrollPos(Pos);
      SB_THUMBTRACK: if FTracking then SetVScrollPos(Pos);
      SB_TOP: SetVScrollPos(0);
      SB_BOTTOM: SetVScrollPos(YSize);
    end;
end;

procedure TWMLBrowser.SetVScrollPos(p: Integer);
var
  ScrollInfo: TScrollInfo;
  oldPos: Integer;
  Rc: TRect;
begin
  OldPos:= ScrollVPos;
  ScrollVPos:= p;
  ScrollInfo.cbSize:= SizeOf(ScrollInfo);
  ScrollInfo.nPos:= ScrollVPos;
  ScrollInfo.fMask:= SIF_POS;
  SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
  GetScrollInfo(Handle, SB_VERT, ScrollInfo);
  ScrollVPos:= ScrollInfo.nPos;
  Rc:= ClientRect;
  if OldPos - ScrollVPos <> 0 then begin
    ScrollChildren(0, (OldPos - ScrollVPos) * FChrH);
    FTopLine:= ScrollVPos;
    if FFullRedraw
    then Refresh
    else begin
      if (FTopLine + FVisLines) < Pred(FLines.Count)
      then DrawVisible
      else ScrollWindowEx(Handle, 0, (OldPos - ScrollVPos) * FChrH, nil, @Rc, 0, nil, SW_INVALIDATE);
    end;
    if Assigned(FOnScrolled_V) then FOnScrolled_V(Self);
    if Assigned(FOnTextScrolled) then FOnTextScrolled(Self, FTopLine, FTopLine + FVisLines + 1,
        ScrollHPos, FMaxScrollH);
  end;
end;

procedure TWMLBrowser.SetHScrollPos(p: Integer);
var
  ScrollInfo: TScrollInfo;
  oldPos: Integer;
  Rc: TRect;
begin
  OldPos:= ScrollHPos;
  ScrollHPos:= p;
  ScrollInfo.cbSize:= SizeOf(ScrollInfo);
  ScrollInfo.nPos:= ScrollHPos;
  ScrollInfo.fMask:= SIF_POS;
  SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
  GetScrollInfo(Handle, SB_HORZ, ScrollInfo);
  ScrollHPos:= ScrollInfo.nPos;
  Rc:= ClientRect;
  if OldPos - ScrollHPos <> 0 then begin
    ScrollChildren((OldPos - ScrollHPos), 0);
    if FFullRedraw
    then Refresh
    else DrawVisible;
    if Assigned(FOnScrolled_H)
    then FOnScrolled_H(Self);
    if Assigned(FOnTextScrolled)
    then FOnTextScrolled(Self, FTopLine, FTopLine + FVisLines, ScrollHPos, FMaxScrollH);
  end;
end;

procedure TWMLBrowser.ScrollTo(X, Y: Integer);
begin
  SetVScrollPos(Y div FChrH);
  SetHScrollPos(X div FChrW);
end;

function TWMLBrowser.GetVScrollMax: Integer;
var
  ScrollInfo: TScrollInfo;
begin
  ScrollInfo.cbSize:= SizeOf(ScrollInfo);
  ScrollInfo.nPos:= ScrollHPos;
  ScrollInfo.fMask:= SIF_RANGE or SIF_PAGE;
  GetScrollInfo(Handle, SB_VERT, ScrollInfo);
  Result:= ScrollInfo.nMax - Integer(ScrollInfo.nPage - 1);
end;

function TWMLBrowser.GetHScrollMax: Integer;
var
  ScrollInfo: TScrollInfo;
begin
  ScrollInfo.cbSize:= SizeOf(ScrollInfo);
  ScrollInfo.nPos:= ScrollHPos;
  ScrollInfo.fMask:= SIF_RANGE or SIF_PAGE;
  GetScrollInfo(Handle, SB_HORZ, ScrollInfo);
  Result:= ScrollInfo.nMax - Integer(ScrollInfo.nPage - 1);
end;

{ Mouse Wheel scrolling implementation }
{$IFDEF D4_}
procedure TWMLBrowser.CMMouseWheel(var Message: TCMMouseWheel);
begin
  with Message do
    MouseWheel(ShiftState, WheelDelta, SmallPointToPoint(Pos));
end;

procedure TWMLBrowser.MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint);
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
    HideCaret:= False;
    if WheelDelta > 0 then CaretPos.x:= CaretPos.x - 1;
    if WheelDelta < 0 then CaretPos.x:= CaretPos.x + 1;
    if CaretPos.x < 0 then CaretPos.x:= 0;
    if CaretPos.x > pred(FLines.Count) then CaretPos.x:= pred(FLines.Count);
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

function TWMLBrowser.MouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result:= False;
  if Assigned(FOnMouseWheelDown)
  then FOnMouseWheelDown(Self, Shift, MousePos, Result);
end;

function TWMLBrowser.MouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result:= False;
  if Assigned(FOnMouseWheelUp)
  then FOnMouseWheelUp(Self, Shift, MousePos, Result);
end;
{$ENDIF}

{ Control painting impementation }

procedure TWMLBrowser.UpdateCharBounds;
begin
  Canvas.Font.Assign(Self.Font);
  FChrW:= Canvas.TextWidth('W');
  FChrH:= Canvas.TextHeight('Wp');
  FVisLines:= (ClientHeight div FChrH) + 1;
  FVisCols:= ClientWidth div FChrW;
end;

procedure TWMLBrowser.Paint;
begin
  UpdateCharBounds;
  with Canvas do begin
    Brush.Color:= Self.Color;
    FillRect(Canvas.ClipRect);
    Brush.Color:= Self.Color;
  end;
  DrawVisible;
  if Assigned(FOnPaint)
  then FOnPaint(Self);
end;

procedure TWMLBrowser.FormatLine(I: Integer; var LGliph: TBitmap);
var
  S, CorrectS, SS: string;
  TI, Si, Ei: Integer;
  R: TRect;
  AllowDraw: Boolean;
begin
  if FLines.Count = 0 then Exit;
  if (I < 0) or (I > Pred(FLines.Count)) then Exit;
  S:= FLines[I];
  LGliph.Width:= FChrW * Length(S);
  LGliph.Height:= FChrH;

  with LGliph.Canvas do begin
    R:= Rect(0, 0, Length(S) * FChrW, FChrH);
    AllowDraw:= True;
    if Assigned(FOnDrawLine)
    then FOnDrawLine(Self, S, I, LGliph, R, AllowDraw);
    { Draw simple text line... }
    if AllowDraw
    then DrawText(LGliph.Canvas.Handle, PChar(S), Length(S), R, DT_DRAWLINE);
    // TextOut(0, 0, S);
    if FSelected then begin
      // Font.Color:= FEnvironment.TextColor;
      // Brush.Color:= FEnvironment.TextBackground;
      Font.Style:= [];
      if (I > StartNo) and (I < EndNo) then begin
        // Brush.Color:= FEnvironment.SelectionBackground;
        // Font.Color:= FEnvironment.SelectionColor;
        R:= Rect(0, 0, Length(S) * FChrW, FChrH);
        DrawText(LGliph.Canvas.Handle, PChar(S), Length(S), R, DT_DRAWLINE);
        // TextOut(0, 0, S);
      end else begin
        Ei:= EndOffs;
        Si:= StartOffs;
        if (I = StartNo) and (I = EndNo) then begin
          // Brush.Color:= FEnvironment.SelectionBackground;
          // Font.Color:= FEnvironment.SelectionColor;
          SS:= Copy(S, Si + 1, Length(S) - Si);
          if Ei > Length(S)
          then SS:= Copy(S, Si + 1, Length(S) - Si)
          else SS:= Copy(S, Si + 1, Ei - Si);
          R:= Rect(Si * FChrW, 0, (Si * FChrW) + (Length(SS) * FChrW), FChrH);
          DrawText(LGliph.Canvas.Handle, PChar(SS), Length(SS), R, DT_DRAWLINE);
          // TextOut(Si * FChrW, 0, SS)
        end else begin
          if (I = StartNo) and (I < EndNo) then begin
            // Brush.Color:= FEnvironment.SelectionBackground;
            // Font.Color:= FEnvironment.SelectionColor;
            SS:= Copy(S, Si + 1, Length(S) - Si);
            R:= Rect(Si * FChrW, 0, (Si * FChrW) + (Length(SS) * FChrW), FChrH);
            DrawText(LGliph.Canvas.Handle, PChar(SS), Length(SS), R, DT_DRAWLINE);
            // TextOut(Si * FChrW, 0, SS);
          end else begin
            if (I > StartNo) and (I = EndNo) then begin
              // Brush.Color:= FEnvironment.SelectionBackground;
              // Font.Color:= FEnvironment.SelectionColor;
              if Ei > Length(S) then Ei:= Length(S);
              SS:= Copy(S, 1, Ei);
              R:= Rect(0, 0, (Length(SS) * FChrW), FChrH);
              DrawText(LGliph.Canvas.Handle, PChar(SS), Length(SS), R, DT_DRAWLINE);
              // TextOut(0, 0, Copy(S, 1, Ei));
            end;
          end;
        end;  
      end;
    end;
  end;
  if Length(S) > FMaxScrollH then FMaxScrollH:= Length(S);
  UpdateScrollBars;
end;

procedure TWMLBrowser.DrawLine(CanvasSupport: TCanvas; I, Y: Integer);
var
  L, Ei, Si, GSz: Integer;
  LGliph: TBitmap;
  Rc: TRect;
begin
  GSz:= 0;
  LGliph:= TBitmap.Create;
  with LGliph.Canvas do begin
    // Brush.Color:= FEnvironment.TextBackground;
    Font.Assign(Self.Font);
    // Font.Color:= FEnvironment.TextColor;
  end;
  if I < FLines.Count
  then FormatLine(I, LGliph)
  else LGliph.Width:= 0;

  with CanvasSupport do begin
    Draw(-(ScrollHPos * FChrW) + GSz, Y, LGliph);
    L:= LGliph.Width - (ScrollHPos * FChrW) + GSz;
    if L < GSz then L:= GSz;
    // Brush.Color:= FEnvironment.TextBackground; { Set default background color }
    if FSelected then begin
      Ei:= EndOffs;
      Si:= StartOffs;
      if (I > StartNo) and (I < EndNo) then begin
        // Brush.Color:= FEnvironment.SelectionBackground;
        Rc:= Rect(L, Y, (FMaxScrollH * FChrW) + ClientWidth - (ScrollHPos * FChrW), Y + FChrH);
        FillRect(Rc);
      end else
        if (I = StartNo) and (I < EndNo) then begin
          if I < FLines.Count then
            if Length(FLines[I]) - 1 < Si then begin
              Si:= Length(FLines[I]) - 1;
              StartOffs:= Si;
            end;
          if LGliph.Width < 1 then begin
            Color:= Self.Color;
            Rc:= Rect(-(ScrollHPos * FChrW) + GSz, Y, (Si * FChrW) - (ScrollHPos * FChrW) +
              GSz, Y + FChrH);
            FillRect(Rc);
            L:= (Si * FChrW) - (ScrollHPos * FChrW) + GSz;
          end else
            L:= LGliph.Width - (ScrollHPos * FChrW) + GSz;
          if LGliph.Width < (Si * FChrW) then begin
            Brush.Color:= Self.Color;
            Rc:= Rect(L, Y, (Si * FChrW) - (ScrollHPos * FChrW) + GSz, Y + FChrH);
            FillRect(Rc);
            L:= (Si * FChrW) - (ScrollHPos * FChrW) + GSz;
          end;
          // Brush.Color:= FEnvironment.SelectionBackground;
          Rc:= Rect(L, Y, (FMaxScrollH * FChrW) + ClientWidth - (ScrollHPos * FChrW) +
            GSz, Y + FChrH);
          FillRect(Rc);
        end else
          if (I > StartNo) and (I = EndNo) then
          begin
            // Brush.Color:= FEnvironment.SelectionBackground;
            if LGliph.Width < 1 then
            begin
              Rc:= Rect(-(ScrollHPos * FChrW) + GSz, Y, (Ei * FChrW) - (ScrollHPos * FChrW) +
                GSz, Y + FChrH);
              FillRect(Rc);
            end else
              if LGliph.Width < (Ei * FChrW) then
              begin
                L:= LGliph.Width - (ScrollHPos * FChrW) + GSz;
                Rc:= Rect(L, Y, (Ei * FChrW) - (ScrollHPos * FChrW) + GSz, Y + FChrH);
                FillRect(Rc);
              end;
            L:= (Ei * FChrW) - (ScrollHPos * FChrW) + GSz;
            if LGliph.Width - (ScrollHPos * FChrW) + GSz > L then
              L:= LGliph.Width - (ScrollHPos * FChrW) + GSz;
            Brush.Color:= Self.Color;
            Rc:= Rect(L, Y, (FMaxScrollH * FChrW) + ClientWidth - (ScrollHPos * FChrW) +
              GSz, Y + FChrH);
            FillRect(Rc);
          end else begin
            Color:= Self.Color;
            Rc:= Rect(L, Y, (FMaxScrollH * FChrW) + ClientWidth - (ScrollHPos * FChrW) +
              GSz, Y + FChrH);
            FillRect(Rc);
          end;
    end else begin
      Brush.Color:= Self.Color;
      Rc:= Rect(L, Y, (FMaxScrollH * FChrW) + ClientWidth - (ScrollHPos * FChrW), Y + FChrH);
      FillRect(Rc);
    end;
  end;
  LGliph.Free;
end;

procedure TWMLBrowser.DrawVisible;
var
  I, Y, cntVis: Integer;
begin
  Y:= 0;
  cntVis:= 1;
  GetSelBounds(StartNo, EndNo, StartOffs, EndOffs);
  for I:= FTopLine to FTopLine + FVisLines do begin
    DrawLine(Canvas, I, Y);
    Y:= Y + FChrH;
    cntVis:= cntVis + 1;
    if cntVis > FVisLines then Break;
  end;
end;

{ Selection properties implementation }

function TWMLBrowser.GetSelBegin: TPoint;
begin
  Result.X:= FSelStartNo;
  REsult.Y:= FSelStartOffs;
end;

function TWMLBrowser.GetSelEnd: TPoint;
begin
  Result.X:= FSelEndNo;
  REsult.Y:= FSelEndOffs;
end;

procedure TWMLBrowser.SetSelBegin(Value: TPoint);
begin
  if Value.X > pred(FLines.Count) then Value.X:= pred(FLines.Count);
  if Value.X < 0 then Value.X:= 0;
  if Value.Y < 0 then Value.Y:= 0;
  FSelStartNo:= Value.X;
  FSelStartOffs:= Value.Y;
end;

procedure TWMLBrowser.SetSelEnd(Value: TPoint);
begin
  if Value.X > pred(FLines.Count) then Value.X:= pred(FLines.Count);
  if Value.X < 0 then Value.X:= 0;
  if Value.Y < 0 then Value.Y:= 0;
  FSelEndNo:= Value.X;
  FSelEndOffs:= Value.Y;
end;

{ Mouse selection implementation }

procedure TWMLBrowser.GetSelBounds(var StartNo, EndNo, StartOffs, EndOffs: Integer);
begin
  if FSelStartNo <= FSelEndNo then
  begin
    StartNo:= FSelStartNo;
    EndNo:= FSelEndNo;
    if not ((StartNo = EndNo) and (FSelStartOffs > FSelEndOffs)) then
    begin
      StartOffs:= FSelStartOffs;
      EndOffs:= FSelEndOffs;
    end else
    begin
      StartOffs:= FSelEndOffs;
      EndOffs:= FSelStartOffs;
    end;
  end else
  begin
    StartNo:= FSelEndNo;
    EndNo:= FSelStartNo;
    StartOffs:= FSelEndOffs;
    EndOffs:= FSelStartOffs;
  end;
end;

procedure TWMLBrowser.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  RNo, CNo: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not Focused then SetFocus;
  ShiftState:= Shift;
  if Button <> mbLeft then Exit;
  if FDblClick then Exit;
  GetRowColAtPos(X + ScrollHPos * FChrW, Y + ScrollVPos * FChrH, RNo, CNo);
  CaretPos.X:= RNo;
  CaretPos.Y:= CNo;
  if not (ssShift in Shift) then begin
    if FSelected then begin
    { Erase old selection, if any... }
      FSelected:= False;
      DrawVisible;
    end;
    FSelStartNo:= RNo;
    FSelEndNo:= FSelStartNo;
    FSelStartOffs:= CNo;
    FSelEndOffs:= FSelStartOffs;
    FSelected:= True;
    FSelMouseDwn:= True;
  end else begin
    FSelEndNo:= RNo;
    FSelEndOffs:= CNo;
    FSelected:= True;
  end;
  DrawVisible;
end;

procedure TWMLBrowser.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  RNo, CNo: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  ShiftState:= Shift;
  if Button <> mbLeft then Exit;
  if FDblClick then begin
    FDblClick:= False;
    Exit;
  end;
  FSelMouseDwn:= False;
  GetRowColAtPos(X + ScrollHPos * FChrW, Y + ScrollVPos * FChrH, RNo, CNo);
  if RNo <> FSelEndNo then FSelEndNo:= RNo;
  if CNo <> FSelEndOffs then FSelEndOffs:= CNo;
  FSelected:= (FSelStartNo <> FSelEndNo) or (FSelStartOffs <> FSelEndOffs);
  if ssCtrl in Shift then
  if not FSelected and (FSelStartNo = 0) and (FSelStartOffs = 0) then begin
    FSelStartNo:= 0;
    FSelEndNo:= FSelStartNo;
    FSelStartOffs:= 0;
    FSelEndOffs:= FSelStartOffs;
    DrawVisible;
  end;
end;

procedure TWMLBrowser.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  RNo, CNo, verY: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  ShiftState:= Shift;
  MousePos:= Point(X, Y);

  if (FSelected and FSelMouseDwn) then begin
    verY:= Y;
    if verY < 0 then verY:= 0;
    if verY > ClientHeight then verY:= ClientHeight;
    GetRowColAtPos(X + ScrollHPos * FChrW, verY + ScrollVPos * FChrH, RNo, CNo);
    FSelEndNo:= RNo;
    FSelEndOffs:= CNo;
    CaretPos.x:= RNo;
    CaretPos.y:= CNo;
    DrawVisible;
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

function GetNextWord(SLine: string; var PosX: Integer): Boolean;
const
  ValidChars = ['a'..'z', 'A'..'Z', '0'..'9', 'À'..'ÿ', '#'];
var
  I, RetX: Integer;
  FindNext: Boolean;
begin
  Result:= False;
  if PosX > Length(SLine) then Exit;
  FindNext:= False;
  RetX:= 0;
  for I:= PosX to Length(SLine) do
  begin
    if not FindNext and not (SLine[I] in ValidChars) then
    begin
      FindNext:= True;
      Continue;
    end;
    if FindNext and (SLine[I] in ValidChars) then
    begin
      RetX:= I;
      Result:= True;
      Break;
    end;
  end;
  if RetX < 1 then Result:= False;
  PosX:= RetX;
end;

{ Mouse Double-Click selection impementation }

procedure TWMLBrowser.DblClick;
var
  S: string;
  XB, NextW: Integer;
begin
  inherited DblClick;
  ShiftState:= ShiftState + [ssDouble];
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
  end else
    if CaretPos.x <= pred(FLines.Count) then begin
      S:= FLines[CaretPos.x];
      NextW:= CaretPos.y;
      if GetNextWord(S, NextW) then begin
        S:= GetWordAtPos(NextW, CaretPos.x, XB);
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
      end;
    end;
end;

{ ... }

function TWMLBrowser.GetWordAtPos(Col, Row: Integer; var XBegin: Integer): string;
const
  ValidChars = ['a'..'z', 'A'..'Z', '0'..'9', 'À'..'ÿ', '#'];
var
  S: string;
  C: Char;
  I, Si, Ei, CrX: Integer;
begin
  Result:= '';
  XBegin:= -1;
  Si:= 0;
  Ei:= 0;
  if Row > pred(FLines.Count) then Exit;
  S:= FLines[Row];
  if S = '' then Exit;
  if Col > Length(S) - 1 then Col:= Length(S) - 1;
  if not (S[Col + 1] in ValidChars) then
  begin
    CrX:= Col - 1;
    for I:= CrX downto 1 do
    begin
      C:= S[I + 1];
      if (C in ValidChars) then
      begin
        Col:= I;
        Break;
      end;
    end;
    if Col = 0 then Exit;
  end;
  for I:= (Col + 1) downto 1 do
    if S[I] in ValidChars then
      Si:= I
    else
      Break;
  for I:= (Col + 1) to Length(S) do
    if S[I] in ValidChars then
      Ei:= I + 1
    else
      Break;
  if Ei >= Si then
  begin
    Result:= Copy(S, Si, Ei - Si);
    XBegin:= Si - 1;
  end;
end;

procedure TWMLBrowser.GetRowColAtPos(X, Y: Integer; var Row, Col: Integer);
var
  Fine: Integer;
begin
  Row:= Y div FChrH;
  if Row > Flines.Count then Row:= FLines.Count;
  if X < 0 then X:= 0;
  Col:= X div FChrW;
  Fine:= X mod FChrW;
  if Fine > (FChrW div 2) - 1 then Col:= Col + 1;
end;

function TWMLBrowser.GetSelText: string;
var
  StartLine, StartPos, EndLine, EndPos, I, LineI: Integer;
  FirstPart, LastPart, SLine: string;
begin
  Result:= '';
  if not FSelected then Exit;
  if not FSelected then Exit;
  if FSelStartNo > FSelEndNo then begin
    StartLine:= FSelEndNo;
    StartPos:= FSelEndOffs;
    EndLine:= FSelStartNo;
    EndPos:= FSelStartOffs;
  end else
    if (FSelStartNo = FSelEndNo) and (FSelEndOffs < FSelStartOffs) then begin
      StartLine:= FSelStartNo;
      StartPos:= FSelEndOffs;
      EndLine:= StartLine;
      EndPos:= FSelStartOffs;
    end else
    begin
      StartLine:= FSelStartNo;
      StartPos:= FSelStartOffs;
      EndLine:= FSelEndNo;
      EndPos:= FSelEndOffs;
    end;
  if StartLine > pred(FLines.Count) then Exit;
  if EndLine > pred(FLines.Count) then EndLine:= pred(FLines.Count);
  SLine:= FLines[StartLine];
  if StartLine < EndLine then begin
    FirstPart:= Copy(SLine, StartPos + 1, Length(SLine) - StartPos);
    SLine:= FLines[EndLine];
    if EndPos > Length(SLine) then EndPos:= Length(SLine);
    LastPart:= Copy(SLine, 1, EndPos);
    LineI:= StartLine + 1;
    Result:= FirstPart;
    for I:= LineI to (EndLine - 1) do Result:= Result + #13#10 + FLines[I];
    Result:= Result + #13#10 + LastPart;
  end else
    Result:= Copy(SLine, StartPos + 1, EndPos - StartPos);
end;

procedure TWMLBrowser.CopyToClipboard;
var
  PC: PChar;
begin
  if not FSelected
  then Exit;
  PC:= PChar(GetSelText);
  Clipboard.SetTextBuf(PC);
end;

{ Showing Special Hint Window - Text only }

procedure TWMLBrowser.ShowTextHint(X, Y: Integer; HintMsg: string);
var
  HintPos: TPoint;
  WTxt, HTxt: Integer;
begin
  if FHintWnd <> nil then begin
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

procedure TWMLBrowser.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
end;

procedure TWMLBrowser.WMKeyDown(var Message: TWMKeyDown);
var
  CaretScroll: Boolean;
begin
  CaretScroll:= False;
  with Message do begin
    ShiftState:= KeyDataToShiftState(KeyData);
    Cursor:= crIBeam;
    case CharCode of
      VK_LEFT, VK_RIGHT, VK_DOWN, VK_UP, VK_HOME, VK_END, VK_PRIOR, VK_NEXT:
        begin
          KeyboardCaretNav(ShiftState, CharCode);
          CaretScroll:= True;
        end;
      end; { case }
  end;
  if CaretScroll then begin
    if CaretPos.y > ScrollHPos + FVisCols then ScrollPos_H:= CaretPos.y - FVisCols;
    if CaretPos.y < ScrollHPos then ScrollPos_H:= CaretPos.y;
    if CaretPos.x < FTopLine then ScrollPos_V:= CaretPos.x;
    if CaretPos.x > FTopLine + FVisLines - 2 then ScrollPos_V:= CaretPos.x - FVisLines + 2;
  end;
  inherited;
end;

procedure TWMLBrowser.WMKeyUp(var Message: TWMKeyUp);
begin
  with Message do begin
    ShiftState:= KeyDataToShiftState(KeyData);
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

procedure TWMLBrowser.KeyboardCaretNav(ShiftState: TShiftState; Direction: Word);
var
  GliphY, SaveXCaret: Integer;

  procedure CtrlKeyLeftKey;
  var
    S: String;
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
    S: string;
    I: Integer;
    NotFindIt: Boolean;
  begin
    if CaretPos.x <= pred(FLines.Count) then
    begin
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
        if CaretPos.x > pred(FLines.Count) then
        begin
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
        if CaretPos.y < 0 then
        begin
          if CaretPos.x > 0 then
          begin
            if CaretPos.x <= pred(FLines.Count) then
            begin
              GliphY:= (CaretPos.x - FTopLine) * FChrH;
              DrawLine(Canvas, CaretPos.x, GliphY);
              if (ssCtrl in ShiftState) and (CaretPos.x > 0) then
              begin
                CaretPos.x:= CaretPos.x - 1;
                CaretPos.y:= Length(FLines[CaretPos.x]);
                if FSelected then begin
                  FSelEndNo:= CaretPos.x;
                  FSelEndOffs:= CaretPos.y;
                  DrawVisible;
                end;
                Exit;
              end;
            end;
            CaretPos.x:= CaretPos.x - 1;
            CaretPos.y:= Length(FLines[CaretPos.x]);
            if not FSelected then
            begin
              GliphY:= (CaretPos.x - FTopLine) * FChrH;
              DrawLine(Canvas, CaretPos.x, GliphY);
            end else
              DrawVisible;
          end else
          begin
            CaretPos.y:= 0;
            GliphY:= (CaretPos.x - FTopLine) * FChrH;
            if not FSelected then
              DrawLine(Canvas, CaretPos.x, GliphY)
            else
              DrawVisible;
          end;
        end else
        begin
          GliphY:= (CaretPos.x - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.x, GliphY);
        end;
        if ssShift in ShiftState then
        begin
          if not FSelected then
          begin
            if CaretPos.x <= pred(FLines.Count) then
              if CaretPos.y > Length(FLines[CaretPos.x]) then
                CaretPos.y:= Length(FLines[CaretPos.x]) - 1;
            FSelected:= True;
            FSelStartNo:= CaretPos.x;
            FSelStartOffs:= CaretPos.y + 1;
            FSelEndNo:= CaretPos.x;
            if ssCtrl in ShiftState then
              CtrlKeyLeftKey
            else
              FSelEndOffs:= CaretPos.y;
          end else
          begin
            FSelEndNo:= CaretPos.x;
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
        if ssCtrl in ShiftState then
        begin
          CtrlKeyLeftKey;
          DrawVisible;
        end;
        FSelStartNo:= CaretPos.x;
        FSelStartOffs:= CaretPos.y;
      end;
    VK_RIGHT: { Right Arrow key is pressed. }
      begin
        CaretPos.y:= CaretPos.y + 1;
        if CaretPos.y > FMaxScrollH then
        begin
          FMaxScrollH:= FMaxScrollH + 2;
          UpdateScrollBars;
        end;
        if CaretPos.x <= pred(FLines.Count) then
        begin
          GliphY:= (CaretPos.x - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.x, GliphY);
        end;
        if ssShift in ShiftState then
        begin
          if not FSelected then
          begin
            FSelected:= True;
            FSelStartNo:= CaretPos.x;
            FSelStartOffs:= CaretPos.y - 1;
            if ssCtrl in ShiftState then CtrlKeyRightKey;
            FSelEndNo:= CaretPos.x;
            FSelEndOffs:= CaretPos.y;
          end else
          begin
            if ssCtrl in ShiftState then CtrlKeyRightKey;
            FSelEndNo:= CaretPos.x;
            FSelEndOffs:= CaretPos.y;
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
        if ssCtrl in ShiftState then
        begin
          CtrlKeyRightKey;
          DrawVisible;
        end;
        FSelStartNo:= CaretPos.x;
        FSelStartOffs:= CaretPos.y;
      end;
    VK_UP: { Up Arrow key is pressed. }
      begin
        if CaretPos.x = 0 then Exit;
        if not (ssShift in ShiftState) and not (ssCtrl in ShiftState) then
        begin
          CaretPos.x:= CaretPos.x - 1;
          if FSelected then
          begin
            FSelected:= False;
            DrawVisible;
            Exit;
          end;
          FSelStartNo:= CaretPos.x;
          GliphY:= (CaretPos.x - FTopLine + 1) * FChrH;
          DrawLine(Canvas, CaretPos.x + 1, GliphY);
          GliphY:= (CaretPos.x - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.x, GliphY);
          Exit;
        end;
        if (ssCtrl in ShiftState) and not (ssShift in ShiftState) then
        begin
          CaretPos.x:= CaretPos.x - 1;
          Perform(WM_VSCROLL, SB_LINEUP, 0);
          FSelStartNo:= CaretPos.x;
          if ScrollVPos = 0 then
          begin
            GliphY:= (CaretPos.x - FTopLine + 1) * FChrH;
            DrawLine(Canvas, CaretPos.x + 1, GliphY);
            GliphY:= (CaretPos.x - FTopLine) * FChrH;
            DrawLine(Canvas, CaretPos.x, GliphY);
          end;
          Exit;
        end;
        if not (ssCtrl in ShiftState) and (ssShift in ShiftState) then
        begin
          CaretPos.x:= CaretPos.x - 1;
          if not FSelected then
          begin
            FSelStartNo:= CaretPos.x + 1;
            FSelStartOffs:= CaretPos.y;
            FSelEndNo:= CaretPos.x;
            FSelEndOffs:= CaretPos.y;
            FSelected:= True;
          end else
          begin
            FSelEndNo:= CaretPos.x;
            FSelEndOffs:= CaretPos.y;
            FSelected:= (FSelStartNo <> FSelEndNo) or (FSelStartOffs <> FSelEndOffs);
          end;
          DrawVisible;
        end;
      end;
    VK_DOWN: { Down Arrow key is pressed. }
      begin
        if CaretPos.x > FLines.Count then Exit;
        if not (ssShift in ShiftState) and not (ssCtrl in ShiftState) then
        begin
          CaretPos.x:= CaretPos.x + 1;
          if FSelected then
          begin
            FSelected:= False;
            DrawVisible;
            Exit;
          end;
          FSelStartNo:= CaretPos.x;
          GliphY:= (CaretPos.x - FTopLine - 1) * FChrH;
          DrawLine(Canvas, CaretPos.x - 1, GliphY);
          GliphY:= (CaretPos.x - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.x, GliphY);
          Exit;
        end;
        if (ssCtrl in ShiftState) and not (ssShift in ShiftState) then
        begin
          CaretPos.x:= CaretPos.x + 1;
          Perform(WM_VSCROLL, SB_LINEDOWN, 0);
          FSelStartNo:= CaretPos.x;
          if ScrollVPos > FLines.Count - FVisLines then
          begin
            GliphY:= (CaretPos.x - FTopLine - 1) * FChrH;
            DrawLine(Canvas, CaretPos.x - 1, GliphY);
            GliphY:= (CaretPos.x - FTopLine) * FChrH;
            DrawLine(Canvas, CaretPos.x, GliphY);
          end;
          Exit;
        end;
        if not (ssCtrl in ShiftState) and (ssShift in ShiftState) then
        begin
          CaretPos.x:= CaretPos.x + 1;
          if not FSelected then
          begin
            FSelStartNo:= CaretPos.x - 1;
            FSelStartOffs:= CaretPos.y;
            FSelEndNo:= CaretPos.x;
            FSelEndOffs:= CaretPos.y;
            FSelected:= True;
          end else
          begin
            FSelEndNo:= CaretPos.x;
            FSelEndOffs:= CaretPos.y;
            FSelected:= (FSelStartNo <> FSelEndNo) or (FSelStartOffs <> FSelEndOffs);
          end;
          DrawVisible;
        end;
      end;
    VK_HOME: { Home key is pressed. }
      begin
        if not (ssCtrl in ShiftState) and not (ssShift in ShiftState) then
        begin
          CaretPos.y:= 0;
          GliphY:= (CaretPos.x - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.x, GliphY);
        end;
        if ssCtrl in ShiftState then
        begin
          if ssShift in ShiftState then
          begin
            if not FSelected then
            begin
              FSelStartNo:= CaretPos.x;
              FSelStartOffs:= CaretPos.y;
              FSelected:= True;
            end;
            CaretPos.x:= 0;
            CaretPos.y:= 0;
            FSelEndNo:= 0;
            FSelEndOffs:= 0;
            DrawVisible;
          end else
          begin
            CaretPos.x:= 0;
            CaretPos.y:= 0;
          end;
          Exit;
        end;
        if ssShift in ShiftState then
        begin
          if not FSelected then
          begin
            FSelStartNo:= CaretPos.x;
            FSelStartOffs:= CaretPos.y;
            FSelected:= True;
          end;
          CaretPos.y:= 0;
          FSelEndNo:= CaretPos.x;
          FSelEndOffs:= 0;
          if FSelEndNo = FSelStartNo then FSelected:= (FSelStartOffs <> FSelEndOffs);
          DrawVisible;
        end;
      end;
    VK_END: { End key is pressed. }
      begin
        if not (ssCtrl in ShiftState) and not (ssShift in ShiftState) then
        begin
          if CaretPos.x <= pred(FLines.Count) then
            CaretPos.y:= Length(FLines[CaretPos.x])
          else
            CaretPos.y:= 0;
          GliphY:= (CaretPos.x - FTopLine) * FChrH;
          DrawLine(Canvas, CaretPos.x, GliphY);
        end;
        if ssCtrl in ShiftState then
        begin
          if ssShift in ShiftState then
          begin
            if not FSelected then
            begin
              FSelStartNo:= CaretPos.x;
              FSelStartOffs:= CaretPos.y;
              FSelected:= True;
            end;
            CaretPos.x:= pred(FLines.Count);
            CaretPos.y:= Length(FLines[CaretPos.x]);
            FSelEndNo:= pred(FLines.Count);
            FSelEndOffs:= Length(FLines[CaretPos.x]);
            DrawVisible;
          end else
          begin
            CaretPos.x:= pred(FLines.Count);
            CaretPos.y:= Length(FLines[CaretPos.x]);
          end;
          Exit;
        end;
        if ssShift in ShiftState then
        begin
          if not FSelected then
          begin
            FSelStartNo:= CaretPos.x;
            if CaretPos.x <= pred(FLines.Count) then
              if CaretPos.y > Length(FLines[CaretPos.x]) then
                CaretPos.y:= Length(FLines[CaretPos.x]);
            FSelStartOffs:= CaretPos.y;
            FSelected:= True;
          end;
          if CaretPos.x <= pred(FLines.Count) then
            CaretPos.y:= Length(FLines[CaretPos.x])
          else
            CaretPos.y:= 0;
          FSelEndNo:= CaretPos.x;
          FSelEndOffs:= CaretPos.y;
          if FSelEndNo = FSelStartNo then FSelected:= (FSelStartOffs <> FSelEndOffs);
          DrawVisible;
        end;
      end;
    VK_PRIOR, VK_NEXT: { Page Up key or Page Down key is pressed. }
      begin
        if not FSelected then
        begin
          FSelStartNo:= CaretPos.x;
          FSelStartOffs:= CaretPos.y;
        end;
        SaveXCaret:= CaretPos.x - FTopLine;
        if Direction = VK_PRIOR then begin
          if ScrollVPos = 0 then begin
            CaretPos.x:= 0;
            CaretPos.y:= 0;
          end else begin
            Perform(WM_VSCROLL, SB_PAGEUP, 0);
            CaretPos.x:= FTopLine + SaveXCaret;
          end;
        end else begin
          if ScrollVPos > FLines.Count - FVisLines then begin
            CaretPos.x:= pred(FLines.Count);
            CaretPos.y:= Length(FLines[CaretPos.x]);
          end else begin
            Perform(WM_VSCROLL, SB_PAGEDOWN, 0);
            CaretPos.x:= FTopLine + SaveXCaret;
          end;
        end;
        if ssShift in ShiftState then
        begin
          FSelEndNo:= CaretPos.x;
          FSelEndOffs:= CaretPos.y;
          if not FSelected then FSelected:= True;
          DrawVisible;
        end;
      end;
  end;
end;

procedure TWMLBrowser.KeyPress(var Key: Char);
var
  SLine, AddS: string;
  Fill, GliphY: Integer;
  KeyOrd: Word;
begin
  inherited KeyPress(Key);
  KeyOrd:= ord(Key);
  if CaretPos.x > pred(FLines.Count) then FLines.Add('');
  if CaretPos.x > pred(FLines.Count) then Exit; { ??? }
  if (KeyOrd = VK_ESCAPE) or (ssCtrl in ShiftState) then Exit;
  if FSelected then begin
    if KeyOrd = 8 then Exit;
  end;
  SLine:= FLines[CaretPos.x];
  if KeyOrd < 32 then Exit;
  if Length(SLine) < CaretPos.y + 1
  then for Fill:= Length(SLine) to CaretPos.y + 1
    do SLine:= SLine + ' ';
  AddS:= Key;
  Insert(AddS, SLine, CaretPos.y + 1);
  FLines[CaretPos.x]:= SLine;
  CaretPos.y:= CaretPos.y + 1;
  GliphY:= (CaretPos.x - FTopLine) * FChrH;
  DrawLine(Canvas, CaretPos.x, GliphY);
  FSelStartNo:= CaretPos.x;
  FSelStartOffs:= CaretPos.y;

  if CaretPos.y > ScrollHPos + FVisCols
  then ScrollPos_H:= CaretPos.y - FVisCols;
  if CaretPos.y < ScrollHPos
  then ScrollPos_H:= CaretPos.y;
  if CaretPos.x < FTopLine
  then ScrollPos_V:= CaretPos.x;
  if CaretPos.x > FTopLine + FVisLines - 2
  then ScrollPos_V:= CaretPos.x - FVisLines + 2;
end;

procedure TWMLBrowser.Clear;
begin
  CaretPos.x:= 0;
  CaretPos.y:= 0;
  ScrollTo(0, 0);
  Self.FSelStartNo:= 0;
  FSelStartOffs:= 0;
  FSelEndNo:= 0;
  FSelEndOffs:= 0;
  FLines.Clear;
  FSelected:= False;
  Invalidate;
end;

procedure TWMLBrowser.LoadFromFile(const FileName: string);
begin
  if not FileExists(FileName) then Exit;
  Clear;
  FLines.LoadFromFile(FileName);
  Invalidate;
end;

procedure TWMLBrowser.ShowParseMessage(ALevel: TReportLevel; AWMLElement: TWMLElement;
  const ASrc: String; AWhere: TPoint; const ADesc: String; var AContinueParse: Boolean);
var
  S: String;
begin
  case ALevel of
  rlHint: begin
      S:= INFOMSG_HINT;
    end;
  rlWarning: begin
      S:= INFOMSG_WARNING;
    end;
  rlError: begin
      S:= INFOMSG_ERROR;
    end;
  rlSearch: begin
      S:= INFOMSG_SEARCH;
    end;
  end;
  FParseMessages.AddObject(Format('%s: (%d,%d): %s', [S, AWhere.y + 1, AWhere.x + 1, ADesc]), AWMLElement);
end;

function TWMLBrowser.ParseSource: Boolean;
begin
  FParseMessages.Clear;
  with FWMLParser do begin
    Text:= FSrc;
    OnReport:= ShowParseMessage;
    Result:= Parse2WML(FWMLCollection.Items[0]);
  end;
end;

procedure TWMLBrowser.ForEachElement(AWMLElement: TWMLElement; AProc: TForEachProc);
var
  n: Integer;
  APClass: TPersistentClass;
begin
  AProc(AWMLElement);
  for n:= 0 to FWMLCollection.Items[0].NestedElementsCount - 1 do begin
    ForEachElement(FWMLCollection.Items[0].GetNestedElementByOrder(n, APClass), AProc);
  end;
end;

procedure TWMLBrowser.ProcCalcPageSize(AWmlElement: TWMLElement);
begin
  Inc(FCalculatedSize.Right);
  Inc(FCalculatedSize.Bottom);  
end;

// calculate page size
procedure TWMLBrowser.CalcPageSize;
var
  n: Integer;
  e: TWMLElement;
begin
  // parse source
  if ParseSource
  then;
  FillChar(FCalculatedSize, SizeOf(FCalculatedSize), #0);
  ForEachElement(FWMLCollection.Items[0], ProcCalcPageSize);
end;

end.
