unit wmlbrowserwin;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  m  l  b  r  o  w  s  e  r  w  i  n                                      *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*   wireless markup language browser component                                *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Aug 02 2001                                                 *
*   Last fix     : Aug 13 2001                                                *
*   Lines        : 1102                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  StdCtrls, jclUnicode,
  customxml, wml, xmlParse, wmlstyle, browserutil, wmlbrowser;

(************************ TWMLBrowserWin ************************)

type
  TWMLBrowserWin = class(TCustomWMLBrowser)
  private
    FDrawCurElementEnv: TDrawElementEnv;
    FDrawScreenSaveEnv: TDrawScreenSaveEnv;
    // FLinesEnv: TLineEnvCollection;

    FInputs: TInputCollection;
    FSelects: TSelectCollection;
  protected
    FWMLElementStyles: TWMLElementStyles;
    procedure SetWMLElementStyles(AWMLElementStyles: TWMLElementStyles);

    procedure DrawScreenSave; override;
    procedure IncreaseCanvas(ANewRect: TRect);
    procedure DrawCard; override;
    procedure DrawLineBreaks; override;
    procedure DrawTextLayout; override;
    procedure DrawInput; override;
    procedure DrawSelect; override;
    procedure DrawOption; override;
    procedure DrawPCData; override;
    procedure DrawImg; override;
    procedure Paint; override;
    // procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear; override;
    // procedure Reload; override;
    // set StripHTTPHeader before assign Src property
    property WMLElementStyles: TWMLElementStyles read FWMLElementStyles write SetWMLElementStyles;
  published
    // set StripHTTPHeader before assign Src property
  end;

implementation

{********************************* TWMLBrowserWin ********************************}

constructor TWMLBrowserWin.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWMLElementStyles:= TWMLElementStyles.Create;
  FDrawCurElementEnv:= TDrawElementEnv.Create;
  FillChar(FDrawScreenSaveEnv, Sizeof(FDrawScreenSaveEnv), #0);

  FInputs:= TInputCollection.Create(TInputItem, Self, Self);
  FSelects:= TSelectCollection.Create(TSelectItem, Self, Self);
end;

destructor TWMLBrowserWin.Destroy;
begin
  FDrawCurElementEnv.Free;
  // FLinesEnv.Free;
  FSelects.Free;
  FInputs.Free;
  FWMLElementStyles.Free;
  inherited Destroy;
end;

procedure TWMLBrowserWin.Paint;
begin
  FDrawCurElementEnv.Clear;
  inherited Paint;
end;

procedure TWMLBrowserWin.SetWMLElementStyles(AWMLElementStyles: TWMLElementStyles);
begin
  FWMLElementStyles.Assign(AWMLElementStyles);
  // if ValidateStyles(FWMLElementStyles) then;
end;


{***************************** Draw implementation ****************************}

procedure TWMLBrowserWin.DrawScreenSave;
var
  s: String;
  R: TRect;
begin
  if not (Self.Parent is TControl)
  then Exit;
  Canvas.TextFlags:= 0;
  s:= 'apoo wml browser styler';
  Color:= clWhite;
  with Canvas do begin
    Brush.Style:= bsSolid;

    Font.Name:= 'Times';
    Font.Color:= clGray;
    Font.Height:= - Width div 4;
    repeat
      if TextWidth(s) < Height
      then Break;
      Font.Height:= Font.Height + 2;
      if Font.Height >= -6
      then Break;
    until False;

    browserutil.RotateFont(Canvas, 90 * 10);

    R:= ClientRect;
    R.Right:= -2 - Font.Height;

    Brush.Color:= Font.Color;
    FillRect(R);

    R.Left:= R.Right;
    R.Right:= ClientRect.Right;
    Brush.Color:= Color;
    FillRect(R);

    TextOut(- Font.Height, - FDrawScreenSaveEnv.Tick + Height - (Height - TextWidth(s)) div 2 , s);
  end;
end;

procedure TWMLBrowserWin.IncreaseCanvas(ANewRect: TRect);
begin
  with FDrawCurElementEnv do begin
    if ANewRect.Right > ClipR.Right then begin
      ClipR.Right:= ANewRect.Right;
    end;
    if ANewRect.Bottom > ClipR.Bottom then begin
      ClipR.Bottom:= ANewRect.Bottom;
    end;
  end;
end;

procedure TWMLBrowserWin.DrawCard;
var
  WMLElementStyle: TWMLElementStyle;
begin
  Self.Color:= FWMLElementStyles.ItemsByClass[TWMLCard].Brush.Color;
  with FDrawCurElementEnv, FCurDrawElement.DrawProperties do begin
    WMLElementStyle:= FWMLElementStyles.ItemsByClass[TWMLCard];

    elR:= GetClientRect;
    Inc(elr.Left, WMLElementStyle.Margin.Left);
    Inc(elr.Top, WMLElementStyle.Margin.Top);
    Dec(elr.Right, WMLElementStyle.Margin.Right);
    Dec(elr.Bottom, WMLElementStyle.Margin.Bottom);
    Inc(CaretP.X, WMLElementStyle.Margin.Left);
    Inc(CaretP.Y, WMLElementStyle.Margin.Top);
    {
    elR.Left:= ElementStyle.Size.Left;
    elR.Top:= ElementStyle.Size.Top;
    elR.Right:= ElementStyle.Size.Width - 1;
    elR.Bottom:= ElementStyle.Size.Height - 1;
    }
    {
    if ElementStyle.Pen.Width > 0 then begin
      Canvas.Rectangle(0, 0, ElementStyle.Size.Width, ElementStyle.Size.Height);
      i:= ElementStyle.Pen.Width;
      Inc(elR.Left, i);
      Inc(elR.Top, i);
      Dec(elR.Right, i);
      Dec(elR.Bottom, i);
    end;
    }
    Canvas.FillRect(BoundsRect);
  end;
end;
{
    // pcdata haven't style ?!!
    // ElementStyle:= FWMLElementStyles.ItemsByClass[TxmlElementClass(Element.ParentElement.ClassType)];
  end else begin
    // ElementStyle:= FWMLElementStyles.ItemsByClass[ElementClass];
}
procedure TWMLBrowserWin.DrawLineBreaks;
var
  WMLElementStyle: TWMLElementStyle;
begin
  with FDrawCurElementEnv, FCurDrawElement.DrawProperties do begin
    // FLinesEnv.Add;
    WMLElementStyle:= FWMLElementStyles.ItemsByClass[TxmlElementClass(FCurDrawElement.ClassType)];

    elR.Left:= FCurDrawElement.ParentElement.DrawProperties.elR.Left +
      WMLElementStyle.Margin.Left;
    elR.Right:= FCurDrawElement.ParentElement.DrawProperties.elR.Right -
      WMLElementStyle.Margin.Right - 1;
    elR.Top:= FDrawCurElementEnv.CaretP.y + WMLElementStyle.Margin.Top;
    elR.Bottom:= FCurDrawElement.ParentElement.DrawProperties.elR.Bottom;

    CaretP.x:= elR.Left;
    CaretP.y:= elR.Top;
    if bvViewControlSymbols in FViewOptions then begin
      WMLElementStyle.SetCanvas(Canvas);
      ExtTextOutW(Canvas.Handle, elR.Left, elR.Top, Canvas.TextFlags, Nil, #182, 1, 0); // '¶'
      Inc(FDrawCurElementEnv.CaretP.x, Canvas.TextWidth(#182));
    end;

    Inc(CaretP.X, WMLElementStyle.Size.Width);
    Inc(CaretP.Y, WMLElementStyle.Size.Height);
  end;
end;

procedure TWMLBrowserWin.DrawTextLayout;
var
  WMLElementStyle: TWMLElementStyle;
begin
  with FDrawCurElementEnv, FCurDrawElement.DrawProperties do begin
    WMLElementStyle:= FWMLElementStyles.ItemsByClass[TxmlElementClass(FCurDrawElement.ClassType)];
    elR.Left:= FCurDrawElement.ParentElement.DrawProperties.elR.Left +
      WMLElementStyle.Margin.Left;
    elR.Right:= FCurDrawElement.ParentElement.DrawProperties.elR.Right +
      WMLElementStyle.Margin.Right;
    elR.Top:= FDrawCurElementEnv.CaretP.y + FWMLElementStyles.ItemsByClass[TxmlElementClass(FCurDrawElement.ClassType)].Margin.Top;
    elR.Bottom:= FCurDrawElement.ParentElement.DrawProperties.elR.Bottom;
    Inc(FDrawCurElementEnv.CaretP.x, WMLElementStyle.Margin.Left);
    Inc(FDrawCurElementEnv.CaretP.y, WMLElementStyle.Margin.Top);
  end;
end;

procedure TWMLBrowserWin.DrawInput;
var
  WMLElementStyle: TWMLElementStyle;
  createnewone: Boolean;
  w, SizeInChars, lw: Integer;
  ws: WideString;
  R: TRect;
begin

  with FDrawCurElementEnv, FCurDrawElement.DrawProperties do begin

    WMLElementStyle:= FWMLElementStyles.ItemsByClass[TxmlElementClass(FCurDrawElement.ClassType)];

    elR.Left:= CaretP.x + WMLElementStyle.Margin.Left;
    elR.Right:= elR.Left + WMLElementStyle.Size.Width - 1;

    // note CaretP - is a font baseline value
    elR.Bottom:= CaretP.y + WMLElementStyle.Margin.Top + WMLElementStyle.Margin.Bottom;
    elR.Top:= elR.Bottom - WMLElementStyle.Size.Height - WMLElementStyle.Margin.Top;
    // add input
    // ...
    WMLElementStyle.SetCanvas(Canvas);
    ws:= FCurDrawElement.Attributes.ValueByName['value'];
    if CompareText(FCurDrawElement.Attributes.ValueByName['type'], 'password') = 0
    then ws:= '*';
    // BUGBUG -- analyse format string instead
    SizeInChars:= StrToIntDef(FCurDrawElement.Attributes.ValueByName['size'], DEF_INPUT_CHARS);
    w:= Canvas.TextWidth('W') * SizeInChars;
    if w > elr.Right - elr.Left
    then elr.Right:= elR.Left + w;

    // if ElementStyle.Pen.Width = 0
    // then BorderStyle:= Forms.bsNone
    // else BorderStyle:= Forms.bsSingle;
    Canvas.Rectangle(elR);
    lw:= Canvas.Pen.Width;
    R:= elR;
    Inc(R.Left, lw);
    Inc(R.Top, lw);
    Dec(R.Right, lw);
    Dec(R.Bottom, lw);
    Windows.ExtTextOutW(Canvas.Handle, R.Left + lw, R.Bottom - lw,
      Canvas.TextFlags + ETO_CLIPPED, @R, PWideChar(ws), Length(ws), 0);

    // CaretP.y:= CaretP.y;
    CaretP.X:= elr.Right + WMLElementStyle.Margin.Right;

    // set new height
    if FDrawCurElementEnv.Size.Y < 10
    then FDrawCurElementEnv.Size.Y:= 10;
  end;
end;

procedure TWMLBrowserWin.DrawImg;
var
  bmp: TBitmap;
  noImgSize: Boolean;
  WMLElementStyle: TWMLElementStyle;
  createnewone: Boolean;
  w, SizeInChars, lw: Integer;
  ws: WideString;
  R: TRect;
  imgsize: TPoint;
  url: WideString;
begin
  with FDrawCurElementEnv, FCurDrawElement.DrawProperties do begin
    // BUGBUG -- % size (% of screen)
    imgsize.X:= StrToIntDef(FCurDrawElement.Attributes.ValueByName['width'], 0);
    imgsize.Y:= StrToIntDef(FCurDrawElement.Attributes.ValueByName['height'], 0);

    WMLElementStyle:= FWMLElementStyles.ItemsByClass[TxmlElementClass(FCurDrawElement.ClassType)];


    elR.Left:= CaretP.Y + WMLElementStyle.Margin.Left;
    elR.Top:= CaretP.Y + WMLElementStyle.Margin.Top;

    noImgSize:= (imgsize.X <= 0) or (imgsize.Y <= 0);
    if imgsize.X <= 0
    then imgsize.X:= WMLElementStyle.Size.Width;
    if imgsize.Y <= 0
    then imgsize.Y:=  WMLElementStyle.Size.Height;
    elR.Right:= elR.Left + imgsize.X;
    elR.Bottom:= elR.Top + imgsize.Y + WMLElementStyle.Margin.Bottom;

    // note CaretP - is a font baseline value
    // add input
    // ...
    WMLElementStyle.SetCanvas(Canvas);
    ws:= FCurDrawElement.Attributes.ValueByName['alt'];
    // BUGBUG -- analyse format string instead
    SizeInChars:= StrToIntDef(FCurDrawElement.Attributes.ValueByName['size'], DEF_INPUT_CHARS);
    w:= Canvas.TextWidth('W') * SizeInChars;
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
    CaretP.X:= elr.Right + WMLElementStyle.Margin.Right;

    // set new height
    if FDrawCurElementEnv.Size.Y < 10
    then FDrawCurElementEnv.Size.Y:= 10;
  end;
end;

procedure TWMLBrowserWin.DrawSelect;
begin
  // not implemented yet
end;

procedure TWMLBrowserWin.DrawOption;
begin
end;

procedure TWMLBrowserWin.DrawPCData;
var
  s: WideString;
  r: TRect;
  fmt: HWND;
  incr: TRect;
  lh: Integer;
  WMLElementStyle: TWMLElementStyle;
  wrap: Boolean;
  emph: TEmphasisis;
  alignment: TAlignment;
begin
  with FDrawCurElementEnv do begin
    WMLElementStyle:= FWMLElementStyles.ItemsByClass[TxmlElementClass(FCurDrawElement.ParentElement.ClassType)];
    WMLElementStyle.SetCanvas(Canvas);
    with FCurDrawElement.ParentElement.DrawProperties do begin
//    parentSizeX:= elR.Right - elR.Left + 1;
//    parentSizeY:= elR.Bottom - elR.Top + 1;
    end;

    s:= FCurDrawElement.Attributes.ValueByNameEntity['value'];

    with TWMLPCData(FCurDrawElement) do begin
      wrap:= TextWrap;
      emph:= TextEmphasisis;
      alignment:= TextAlignment;
    end;
    with Canvas.Font do begin
      if emStrong in emph then begin
        Size:= FWMLElementStyles.ItemsByClass[TwmlStrong].Font.Size;
        Style:= Style + [fsBold];
      end;
      if emEm in emph then begin
        Size:= FWMLElementStyles.ItemsByClass[TwmlEm].Font.Size;
        Style:= Style + [fsItalic];
      end;
      if emB in emph
      then  Style:= Style + [fsBold];
      if emI in emph
      then  Style:= Style + [fsItalic];
      if emU in emph
      then  Style:= Style + [fsUnderline];

      if emBig in emph
      then Size:= FWMLElementStyles.ItemsByClass[TwmlBig].Font.Size;

      if emSmall in emph
      then  Size:= FWMLElementStyles.ItemsByClass[TwmlSmall].Font.Size;
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
    r.Bottom:= r.Top + 2 * Canvas.TextHeight('Wp');

    incr.Left:= 0;
    incr.Right:= CaretP.x + Canvas.TextWidth(s);
    incr.Top:= 0;
    incr.Bottom:= 0;
    // incr.Bottom:= CaretP.y  + Canvas.TextHeight(s);
    IncreaseCanvas(incr);
    {
    Windows.DrawText(Canvas.Handle, PChar(s), Length(S), r, Fmt or DT_CALCRECT);
    lh:= r.Bottom - r.Top + 1;
    Windows.DrawText(Canvas.Handle, PChar(s), Length(S), r, Fmt);
    }
    if wrap then begin
      TTYWrap(s, Canvas, CaretP, r, FWMLElementStyles.ItemsByClass[TwmlBr].Size.Height,
        FCurDrawElement.DrawProperties.elRM);
    end else begin
      Windows.ExtTextOutW(Canvas.Handle, CaretP.X, CaretP.Y,
        Canvas.TextFlags, Nil, PWideChar(s), Length(S), 0);
      Inc(CaretP.x, Canvas.TextWidth(s));
      Inc(CaretP.y, 0);  // Canvas.TextHeight(s)
    end;
    // set new height
    { ?!!
    if FDrawCurElementEnv.Size.Y < lh
    then FDrawCurElementEnv.Size.Y:= lh;
    }
    // Canvas.TextOut(CaretP.X, CaretP.Y, s);
  end;
end;

{ Selection properties implementation }

procedure TWMLBrowserWin.Clear;
var
  strip: Boolean;
begin
  FInputs.Clear;
  FSelects.Clear;
  // FLinesEnv.Clear;
  FDrawCurElementEnv.Clear;
  inherited Clear;
end;

end.
