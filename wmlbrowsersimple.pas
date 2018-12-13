unit
  wmlbrowsersimple;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  m  l  b  r  o  w  s  e  r  s  i  m  p  l  e                             *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language browser component                                *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Aug 02 2001                                                 *
*   Last fix     : Aug 13 2001                                                *
*   Lines        : 505                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  StdCtrls, jclUnicode,
  customxml, wml, xmlsupported, xmlParse, wmlstyle, browserutil, wmlbrowser;

  (************************ TWMLFlowCount ************************)

type
  TWMLFlow = (cTWMLAnchor, cTWMLA, cTWMLTable, cTWMLTr, cTWMLTd,
    cTWMLEm, cTWMLStrong, cTWMLB, cTWMLI, cTWMLU, cTWMLBig, cTWMLSmall, cTWMLpre);

  TWMLFlowCount = record
    charw,
    lineh: Integer;
    Caret: TPoint;
    Size: TPoint;
    Flow: array[TWMLFlow] of Integer;
  end;

  (************************ TSimpleWMLBrowser ************************)

type
  TSimpleWMLBrowser = class(TCustomWMLBrowser)
  private
    FWMLFlowCount: TWMLFlowCount; // FDrawCurElementEnv: TDrawElementEnv;
    FMargin: Integer;
    FFont: TFont;
    FColor: TColor;
    procedure IncreaseCanvas(ANewRect: TRect);
    procedure SetColor(AValue: TColor);
    procedure SetFont(AValue: TFont);
  protected
    procedure Paint; override;
    procedure DrawCard; override;
    procedure DrawLineBreaks; override;
    procedure DrawTextLayout; override;
    procedure DrawInput; override;
    procedure DrawSelect; override;
    procedure DrawOption; override;
    procedure DrawPCData; override;
    procedure DrawImg; override;
    procedure DrawA; override;
    procedure ProcDrawStartElement(var AWmlElement: TxmlElement); override;
    procedure ProcDrawFinishElement(var AWmlElement: TxmlElement); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear; override;
  published
    property Font: TFont read FFont write SetFont;
    property BackColor: TColor read FColor write SetColor;
    property Margin: Integer read FMargin write FMargin;
  end;

implementation

procedure ClearWMLFlowCounts(AWMLFlowCount: TWMLFlowCount);
begin
  FillChar(AWMLFlowCount, SizeOf(AWMLFlowCount), 0);
end;

procedure IncWMLFlowCounts(AwmlElement: TxmlElement; var AWMLFlowCount: TWMLFlowCount; AInc: Integer);
begin
  if (AwmlElement is wml.TWMLAnchor)
  then Inc(AWMLFlowCount.Flow[cTWMLAnchor], AInc);
  if (AwmlElement is wml.TWMLA)
  then Inc(AWMLFlowCount.Flow[cTWMLA], AInc);
  if (AwmlElement is wml.TWMLTable)
  then Inc(AWMLFlowCount.Flow[cTWMLTable], AInc);
  if (AwmlElement is wml.TWMLTr)
  then Inc(AWMLFlowCount.Flow[cTWMLTr], AInc);
  if (AwmlElement is wml.TWMLTd)
  then Inc(AWMLFlowCount.Flow[cTWMLTd], AInc);
  if (AwmlElement is wml.TWMLEm)
  then Inc(AWMLFlowCount.Flow[cTWMLEm], AInc);
  if (AwmlElement is wml.TWMLStrong)
  then Inc(AWMLFlowCount.Flow[cTWMLStrong], AInc);
  if (AwmlElement is wml.TWMLB)
  then Inc(AWMLFlowCount.Flow[cTWMLB], AInc);
  if (AwmlElement is wml.TWMLI)
  then Inc(AWMLFlowCount.Flow[cTWMLI], AInc);
  if (AwmlElement is wml.TWMLU)
  then Inc(AWMLFlowCount.Flow[cTWMLU], AInc);
  if (AwmlElement is wml.TWMLBig)
  then Inc(AWMLFlowCount.Flow[cTWMLBig], AInc);
  if (AwmlElement is wml.TWMLSmall)
  then Inc(AWMLFlowCount.Flow[cTWMLSmall], AInc);
  if (AwmlElement is wml.TWMLpre)
  then Inc(AWMLFlowCount.Flow[cTWMLpre], AInc);
end;

(************************ TSimpleWMLBrowser ************************)

constructor TSimpleWMLBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFont:= TFont.Create;
  FColor:= DEF_COLOR;
  Font.Name:= DEF_FONT_FAMILY;
  FMargin:= 0;
  ClearWMLFlowCounts(FWMLFlowCount);
end;

destructor TSimpleWMLBrowser.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TSimpleWMLBrowser.ProcDrawStartElement(var AWmlElement: TxmlElement);
begin
  IncWMLFlowCounts(AWmlElement, FWMLFlowCount, 1);
  with FWMLFlowCount, AWmlElement.DrawProperties do begin
    elR.Left:= Caret.X;
    elR.Top:= Caret.y; //  - lineh // in case of TA_BASELINE
    elRM.Left:= elr.Left;
    elRM.Top:= elr.Top;
  end;
  inherited ProcDrawStartElement(AWmlElement);
end;

procedure TSimpleWMLBrowser.ProcDrawFinishElement(var AWmlElement: TxmlElement);
begin
  IncWMLFlowCounts(AWmlElement, FWMLFlowCount, -1);
  // if AWmlElement is
  with FWMLFlowCount, AWmlElement.DrawProperties do begin
    elR.Right:= Caret.X;
    elR.Bottom:= Caret.Y + lineh;  // just Caret.Y in case of TA_BASELINE

    if elRM.Right < elr.Right
    then elRM.Right:= elr.Right;
    elRM.Bottom:= elr.Bottom;
  end;
  inherited ProcDrawFinishElement(AWmlElement);
end;

procedure TSimpleWMLBrowser.Paint;
var
  e: Integer;
  el: TxmlElement;
  Aln: Cardinal;
begin
  with Canvas do begin
    Canvas.TextFlags:= TA_NOUPDATECP or ETO_OPAQUE;
    // SetTextAlign(Canvas.Handle, TA_BASELINE); // see TA_BASELINE comments if you would like to uncomment this statement
  end;

  ClearWMLFlowCounts(FWMLFlowCount);
  // look for current card
  el:= CurrentCardEl;
  if Assigned(el) then with Canvas do begin
    el.ForEachInOut(ProcDrawStartElement, ProcDrawFinishElement);
  end;
  if Assigned(FOnPaint)
  then FOnPaint(Self);
end;

procedure TSimpleWMLBrowser.Clear;
begin
  ClearWMLFlowCounts(FWMLFlowCount);
  inherited Clear;
end;

procedure TSimpleWMLBrowser.SetColor(AValue: TColor);
begin
  FColor:= AValue;
  Canvas.Brush.Color:= AValue;
end;

procedure TSimpleWMLBrowser.SetFont(AValue: TFont);
begin
  FFont.Assign(AValue);
  Canvas.Font.Assign(AValue);
end;

procedure TSimpleWMLBrowser.IncreaseCanvas(ANewRect: TRect);
begin
  with FWMLFlowCount do begin
    if ANewRect.Right > Size.X then begin
      Size.X:= ANewRect.Right;
    end;
    if ANewRect.Bottom > Size.Y then begin
      Size.Y:= ANewRect.Bottom;
    end;
  end;
end;

function GetTextExtentW(ACanvas: TCanvas; const Text: WideString): TSize;
begin
  Result.cX:= 0;
  Result.cY:= 0;
  Windows.GetTextExtentPoint32W(ACanvas.Handle, PWideChar(Text), Length(Text), Result);
end;

procedure TSimpleWMLBrowser.DrawCard;
var
  sz: TSize;
begin
  with FWMLFlowCount, FCurDrawElement.DrawProperties do begin
    Canvas.Font:= FFont;
    Canvas.Brush.Color:= FColor;
    elR:= GetClientRect;

    sz:= GetTextExtentW(Canvas, 'Wp');
    lineh:= 12 * sz.cy div 10;
    charw:= sz.cx;

    Canvas.FillRect(BoundsRect);
    Inc(elR.Left, FMargin);
    Dec(elR.Right, FMargin);
    Inc(elR.Top, FMargin);
    Dec(elR.Bottom, FMargin);
    Caret.Y:= elR.Top; // + lineh; // in case of TA_BASELINE
  end;
end;

procedure TSimpleWMLBrowser.DrawLineBreaks;
begin
  with FWMLFlowCount, FCurDrawElement.DrawProperties do begin
    elR.Left:= FCurDrawElement.ParentElement.DrawProperties.elR.Left;
    elR.Right:= FCurDrawElement.ParentElement.DrawProperties.elR.Right;
    elR.Top:= Caret.y;
    elR.Bottom:= FCurDrawElement.ParentElement.DrawProperties.elR.Bottom;
    Caret.x:= elR.Left;
    Caret.y:= elR.Top + lineh;
  end;
end;

procedure TSimpleWMLBrowser.DrawTextLayout;
begin
  with FWMLFlowCount, FCurDrawElement.DrawProperties do begin
    elR.Left:= FCurDrawElement.ParentElement.DrawProperties.elR.Left;
    elR.Right:= FCurDrawElement.ParentElement.DrawProperties.elR.Right;
    elR.Top:= Caret.y;
    elR.Bottom:= FCurDrawElement.ParentElement.DrawProperties.elR.Bottom;
  end;
end;

procedure TSimpleWMLBrowser.DrawInput;
var
  w, SizeInChars: Integer;
  ws: WideString;
  sz: TSize;
  x, y: Integer;
begin
  with FWMLFlowCount, FCurDrawElement.DrawProperties do begin
    Canvas.Font:= FFont;
    Canvas.Brush.Color:= FColor;
    elR.Left:= Caret.x;
    elR.Right:= elR.Left;
    // note CaretP - is a font baseline value
    elR.Bottom:= Caret.y;
    elR.Top:= elR.Bottom - lineh + 2;
    ws:= GetVData(FCurDrawElement.Attributes.ValueByName['value']); // , MASK_VAR_ASIS
    if CompareText(FCurDrawElement.Attributes.ValueByName['type'], 'password') = 0
    then ws:= '*';
    // BUGBUG -- analyse format string instead
    // 1. uncomment next line if size attribute is used
    // SizeInChars:= StrToIntDef(FCurDrawElement.Attributes.ValueByName['size'], DEF_INPUT_CHARS);
    // 2. uncomment next line if actual lenght is used
    SizeInChars:= Length(ws) + 1;
    w:= charw * SizeInChars;
    if w > elr.Right - elr.Left
    then elr.Right:= elR.Left + w;
    // negate color
    Canvas.Font.Color:= not ($FF000000 or Canvas.Font.Color);
    Canvas.Brush.Color:= not ($FF000000 or Canvas.Brush.Color);
    Canvas.Pen.Color:= clRed;
    Canvas.Rectangle(elR);
    Inc(elr.Left);
    Inc(elr.Top);
    Dec(elr.Right);
    Dec(elr.Bottom);

    sz:= GetTextExtentW(Canvas, ws);

    x:= elR.Left + ((elR.Right - elR.Left - sz.cx) div 2);
    y:= elR.Bottom - ((elR.Bottom - elR.Top - sz.cy) div 2);
    Windows.ExtTextOutW(Canvas.Handle, x, y, // elR.Left, elR.Bottom - 2,
      Canvas.TextFlags + ETO_CLIPPED, @elR, PWideChar(ws), Length(ws), 0);
    // Canvas.Brush.Color:= clRed;
    // Canvas.Rectangle(elR);
    Caret.X:= elr.Right;
    // set new height
    if Size.Y < 10
    then Size.Y:= 10;
  end;
end;

procedure TSimpleWMLBrowser.DrawSelect;
begin
end;

procedure TSimpleWMLBrowser.DrawOption;
var
  ws: WideString;
begin
  with FWMLFlowCount, FCurDrawElement.DrawProperties do begin
    Canvas.Font:= FFont;
    Canvas.Brush.Color:= FColor;
    elR.Left:= Caret.x;
    elR.Right:= elR.Left + lineh - 2;
    // note CaretP - is a font baseline value
    elR.Bottom:= Caret.y;
    elR.Top:= elR.Bottom - lineh + 2;
    ws:= GetVData(FCurDrawElement.Attributes.ValueByName['value']); // MASK_VAR_ASIS
    Canvas.Rectangle(elR);
    Caret.X:= elr.Right;
    // Caret.Y:= elr.Top;
    // set new height
    // if Size.Y < 10 then Size.Y:= 10;
  end;
end;

procedure TSimpleWMLBrowser.DrawPCData;
var
  wrap: Boolean;
  r, incr: TRect;
  fmt: HWND;
  emph: TEmphasisis;
  alignment: TAlignment;
  ws: WideString;
  sz: TSize;
begin
  with FWMLFlowCount do begin
    Canvas.Font:= FFont;
    Canvas.Brush.Color:= FColor;
    Ws:= GetVData(FCurDrawElement.Attributes.ValueByNameEntity['value']);
    with TWMLPCData(FCurDrawElement) do begin
      wrap:= TextWrap;
      // emph:= TextEmphasisis;
      alignment:= TextAlignment;
    end;

    with Canvas.Font do begin
      Style:= [];
      if FWMLFlowCount.Flow[cTWMLEm] > 0
      then Style:= Style + [fsBold];

      if FWMLFlowCount.Flow[cTWMLStrong] > 0 then begin
        Style:= Style + [fsBold];
        Size:= 4 * Size div 3
      end;

      if FWMLFlowCount.Flow[cTWMLB] > 0
      then Style:= Style + [fsBold];

      if FWMLFlowCount.Flow[cTWMLI] > 0
      then Style:= Style + [fsItalic];

      if FWMLFlowCount.Flow[cTWMLU] > 0
      then  Style:= Style + [fsUnderline];

      if FWMLFlowCount.Flow[cTWMLBig] > 0
      then Size:= 4 * Size div 3;

      if FWMLFlowCount.Flow[cTWMLSmall] > 0
      then Size:= 2 * Size div 3;

      if FWMLFlowCount.Flow[cTWMLpre] > 0
      then;

      if FWMLFlowCount.Flow[cTWMLA] > 0 then begin
        Style:= Style + [fsUnderline];
        Font.Color:= clNavy;
       end;
    end;
//    szx:= Canvas.TextWidth(s); if szx < parentSizeX then begin
//  h:= Canvas.Handle;
    Fmt:= DT_NOPREFIX or DT_NOCLIP;
    if wrap
    then Fmt:= Fmt or DT_WORDBREAK;
    // set the reference point will be aligned horizontally depends indicated aligntment
    case alignment of
      taLeftJustify: Fmt:= Fmt or DT_LEFT;
      taRightJustify: Fmt:= Fmt or DT_RIGHT;
      taCenter: Fmt:= Fmt or DT_CENTER;
    end; { case }
    r:= FCurDrawElement.ParentElement.DrawProperties.elR;
//    r.Bottom:= r.Top + 2 * lineh;

    sz:= GetTextExtentW(Canvas, ws);

    incr.Left:= 0;
    incr.Right:= Caret.x + sz.cx;
    incr.Top:= 0;
    incr.Bottom:= 0;
    IncreaseCanvas(incr);

    if wrap then begin
      TTYWrap(ws, Canvas, Caret, r, lineh, FCurDrawElement.DrawProperties.elRM);
    end else begin
      // BUGBUG
      Windows.ExtTextOutW(Canvas.Handle, Caret.X, Caret.Y,
        Canvas.TextFlags, Nil, PWideChar(ws), Length(ws), 0);
      // Windows.Rectangle(Canvas.Handle, Caret.X, Caret.Y, Caret.X+2, Caret.Y+2);

      Inc(Caret.x, sz.cx);
      Inc(Caret.y, 0);  // lineh
    end;
    {
    with FCurDrawElement.DrawProperties do begin
      elR.Left:= elRM.Left;
      elR.Right:= elRM.Right;
      elR.Top:= elRM.Top;
      elR.Bottom:= elRM.Bottom;
    end;
    }
  end;
end;

function Percent(APercent, AValue: Integer): Integer;
begin
  if APercent <= 0
  then Result:= AValue
  else Result:= APercent * AValue div 100;
end;

procedure TSimpleWMLBrowser.DrawImg;
var
  bmp: TBitmap;
  noImgSize: Boolean;
  createnewone: Boolean;
  w, SizeInChars, lw: Integer;
  ws: WideString;
  R: TRect;
  imgsize: TPoint;
  url: WideString;
begin
  with FWMLFlowCount, FCurDrawElement.DrawProperties do begin
    // BUGBUG -- % size (% of screen)
    with elr do begin
      if GetMeasure(FCurDrawElement.Attributes.ValueByName['width'], imgsize.X) = smPercent
      then imgsize.X:= Percent(imgsize.X, Right - Left + 1);
      if GetMeasure(FCurDrawElement.Attributes.ValueByName['height'], imgsize.Y) = smPercent
      then imgsize.X:= Percent(imgsize.Y, Bottom - Top + 1);
    end;
    elR.Left:= Caret.Y;
    elR.Top:= Caret.Y;

    noImgSize:= (imgsize.X <= 0) or (imgsize.Y <= 0);
    elR.Right:= elR.Left + imgsize.X;
    elR.Bottom:= elR.Top + imgsize.Y;

    // note CaretP - is a font baseline value
    // add input
    // ...
    ws:= FCurDrawElement.Attributes.ValueByName['alt'];
    // BUGBUG -- analyse format string instead
    SizeInChars:= StrToIntDef(FCurDrawElement.Attributes.ValueByName['size'], DEF_INPUT_CHARS);
    w:= charw * SizeInChars;
    if w > elr.Right - elr.Left
    then elr.Right:= elR.Left + w;

    bmp:= TBitmap.Create;
    if LoadImageBitmap(url, bmp, imgSize, noImgSize) then begin
      Canvas.Draw(elr.Left, elr.Top, bmp);
    end else begin
      Canvas.Rectangle(elR);
      lw:= Canvas.Pen.Width;
      R:= elR;
      Inc(R.Left, lw);
      Inc(R.Top, lw);
      Dec(R.Right, lw);
      Dec(R.Bottom, lw);
      Windows.ExtTextOutW(Canvas.Handle, R.Left + lw, R.Bottom - lw,
        Canvas.TextFlags + ETO_CLIPPED, @R, PWideChar(ws), Length(ws), 0);
    end;
    bmp.Free;
    // CaretP.y:= CaretP.y;
    Caret.X:= elr.Right;

    // set new height
    if FWMLFlowCount.Size.Y < 10
    then FWMLFlowCount.Size.Y:= 10;
  end;
end;

procedure TSimpleWMLBrowser.DrawA;
begin
  with FWMLFlowCount, FCurDrawElement.DrawProperties do begin
  end;
end;

end.
