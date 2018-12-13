unit wmlstyle;
(*##*)
(*******************************************************************
*                                                                 *
*   w  m  l  s  t  y  l  e                                         *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   wireless markup language stylesheet parser                    *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Aug 02 2001                                     *
*   Last fix     : Aug 02 2001                                    *
*   Lines        : 1549                                            *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface
uses
  Classes, Windows, SysUtils, Controls, Graphics,
  customxml, xmlsupported, wml;
//
//  one element: STYLE="margin-left: 27px"
//  sheet      : p,td { font:8pt MS Shell Dlg; cursor:default} ...
//

// Attributes:
// text-align: left,right,center
// background-color: #0099FF
// left:10%; right:100%; width:100%; height=100%
// margin-left,top,right,bottom: 0px
// line-color: black; line-width: 1px; line-style: Solid,Dash,Dot,DashDot,DashDotDot{,Clear,InsideFrame}
// font-color: WindowText; font-family: Arial; font-size: 10pt; font-weight: normal,bold,italic,underline,strikeout
//   font-pitch: default,fixed,variable; font-charset=ansi,oem,russian,#cc

type
  TPointNSize = record
    Left,
    Top,
    Width,
    Height: Integer;
  end;

  TStyleType = (stNone, stFontFamily, stAlign, stDimension, stColor, stText);

  TIdentStyleEntry = record
    Value: Integer;
    Name: String;
    Style: TStyleType;
  end;

const
  FIRST_STYLEATTRIBUTENO = 0;
  LAST_STYLEATTRIBUTENO = 19;
  CNT_STYLEATTRIBUTES = LAST_STYLEATTRIBUTENO + 1; // started with 0

{ every style property have his index }
  // lowercase please!
  StyleIndexes: array[0..CNT_STYLEATTRIBUTES - 1] of TIdentStyleEntry = (
    (Value: 0; Name: 'text-align'; Style: stAlign),
    (Value: 1; Name: 'background-color'; Style: stColor),
    (Value: 2; Name: 'left'; Style: stDimension),
    (Value: 3; Name: 'top'; Style: stDimension),
    (Value: 4; Name: 'width'; Style: stDimension),
    (Value: 5; Name: 'height'; Style: stDimension),
    (Value: 6; Name: 'margin-left'; Style: stDimension),
    (Value: 7; Name: 'margin-right'; Style: stDimension),
    (Value: 8; Name: 'margin-top'; Style: stDimension),
    (Value: 9; Name: 'margin-bottom'; Style: stDimension),
    (Value: 10; Name: 'line-color'; Style: stColor),
    (Value: 11; Name: 'line-width'; Style: stDimension),
    (Value: 12; Name: 'line-style'; Style: stText),
    (Value: 13; Name: 'font-color'; Style: stColor),
    (Value: 14; Name: 'font-family'; Style: stFontFamily),
    (Value: 15; Name: 'font-size'; Style: stText),
    (Value: 16; Name: 'font-weight'; Style: stText),
    (Value: 17; Name: 'font-pitch'; Style: stText),
    (Value: 18; Name: 'font-charset'; Style: stText),
    (Value: 19; Name: 'cursor'; Style: stText)
    );

type
  TEnabledStylePropertyEnum = FIRST_STYLEATTRIBUTENO..LAST_STYLEATTRIBUTENO;
  TEnabledStylePropertySet = set of TEnabledStylePropertyEnum;

  TWMLElementStyle = class(TCollectionItem)
  private
    FWMLElementClass: TxmlElementClass;
    FSize: TPointNSize;
    FSizeMeasure: TSizeMeasure;
    FMargin: TRect;
    FMarginMeasure: TSizeMeasure;

    FTextAlign: TAlignment;
    FBrush: TBrush;
    FTextFlags: Longint;

    FFont: TFont;
    {
    FFontPitch: TFontPitch;
    FFontColor: TColor;
    FFontStyles: TFontStyles;
    FFontPoints: Integer;
    FFontFamily: String;
    FFontCharset: TFontCharset;
    }

    FPen: TPen;
    {
    FLineColor: TColor;
    FLineWidth: Integer;
    FLineStyle: TPenStyle;
    }
    FCursor: TCursor;
    
    FEnabledStylePropertySet: TEnabledStylePropertySet;
    FBuffer: String; // used by InternalColorCallback
    function GetSizeStr(ACoordinate: Integer): String;
    procedure SetSizeStr(ACoordinate: Integer; AValueStr: String);
    function GetMargin(ACoordinate: Integer): String;
    procedure SetMargin(ACoordinate: Integer; AValueStr: String);
    function GetTextAlignStr: String;
    procedure SetTextAlignStr(AValue: String);
    function GetBrushStr(AIdx: Integer): String;
    procedure SetBrushStr(AIdx: Integer; AValue: String);
    function GetFontStr(AIdx: Integer): String;
    procedure SetFontStr(AIdx: Integer; AValueStr: String);
    function GetLineStr(AIdx: Integer): String;
    procedure SetLineStr(AIdx: Integer; AValueStr: String);

    function GetCursorStr: String;
    procedure SetCursorStr(AValueStr: String);

    function GetStyleStrByIndex(AIdx: Integer): String;
    procedure SetStyleStrByIndex(AIdx: Integer; AValueStr: String);
    function GetStyleStrByName(AStyleName: String): String;
    procedure SetStyleStrByName(AStyleName: String; AValueStr: String);

    // callbacks
    // Graphics.TGetStrProc = procedure(const S: string) of object;
    procedure InternalColorCallback(const S: string);
    procedure InternalCharsetCallback(const S: string);  protected
    function GetEnabledStylePropertyString: String;
    procedure SetEnabledStylePropertyString(const AValue: String);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure SetCanvas(ACanvas: TCanvas);
    procedure GetStyleStrings(AStrings: TStrings);
    procedure LoadFromStrings(ASrc: TStrings);
    function GetStyleString: String;
    function ParseStyle(const ASrc: String; AStart, AFinish: Integer): Boolean;
    function GetChooseListByIndex(AIdx: Integer): String;
    function GetStyleTypeByIndex(AIdx: Integer): TStyleType;
    property LeftStr: String index 0 read GetSizeStr write SetSizeStr;
    property TopStr: String index 1 read GetSizeStr write SetSizeStr;
    property WidthStr: String index 2 read GetSizeStr write SetSizeStr;
    property HeightStr: String index 3 read GetSizeStr write SetSizeStr;

    property MarginLeftStr: String index 0 read GetMargin write SetMargin;
    property MarginTopStr: String index 1 read GetMargin write SetMargin;
    property MarginRightStr: String index 2 read GetMargin write SetMargin;
    property MarginBottomStr: String index 3 read GetMargin write SetMargin;

    property TextAlignStr: String read GetTextAlignStr write SetTextAlignStr;
    property BackgroundColorStr: String index 0 read GetBrushStr write SetBrushStr;

    property FontPitchStr: String index 0 read GetFontStr write SetFontStr;
    property FontColorStr: String index 1 read GetFontStr write SetFontStr;
    property FontStylesStr: String index 2 read GetFontStr write SetFontStr;
    property FontPointsStr: String index 3 read GetFontStr write SetFontStr;
    property FontFamilyStr: String index 4 read GetFontStr write SetFontStr;
    property FontCharsetStr: String index 5 read GetFontStr write SetFontStr;

    property LineColorStr: String index 0 read GetLineStr write SetLineStr;
    property LineWidthStr: String index 1 read GetLineStr write SetLineStr;
    property LineStyleStr: String index 2 read GetLineStr write SetLineStr;

    property CursorStr: String read GetCursorStr write SetCursorStr;

    property ChooseListByIndex[AIndex: Integer]: String read GetChooseListByIndex;
    property StyleTypeByIndex[AIndex: Integer]: TStyleType read GetStyleTypeByIndex;

    property StyleStrByIndex[AIndex: Integer]: String read GetStyleStrByIndex write SetStyleStrByIndex;
    property StyleStrByName[AStyleName: String]:String read GetStyleStrByName write SetStyleStrByName;
  published
    property Size: TPointNSize read FSize write FSize;
    property SizeMeasure: TSizeMeasure read FSizeMeasure write FSizeMeasure;
    property Margin: TRect read FMargin write FMargin;
    property MarginMeasure: TSizeMeasure read FMarginMeasure write FMarginMeasure;
    property TextAlign: TAlignment read FTextAlign write FTextAlign;
    property Font: TFont read FFont write FFont;
    property Pen: TPen read FPen write FPen;
    property Cursor: TCursor read FCursor write FCursor;
    property Brush: TBrush read FBrush write FBrush;
    property TextFlags: LongInt read FTextFlags write FTextFlags;
    property EnabledStyleProperties: TEnabledStylePropertySet read FEnabledStylePropertySet write FEnabledStylePropertySet;
    // enabled style property list as string: 'font-color, font-weight'
    property EnabledStylePropertyString: String read GetEnabledStylePropertyString write SetEnabledStylePropertyString;
  end;

  TWMLElementStyleClass = class of TWMLElementStyle;

  // styles collection
  TWMLElementStyles = class(TCollection)
  private
    FComments: String;
    function GetItem(AOrder: Integer): TWMLElementStyle;
    procedure SetItem(AOrder: Integer; AWMLElementStyle: TWMLElementStyle);
    function GetItemByClass(AxmlElementClass: TxmlElementClass): TWMLElementStyle;
    procedure SetItemByClass(AxmlElementClass: TxmlElementClass; AWMLElementStyle: TWMLElementStyle);
    function GetItemByElementName(AElementName: String): TWMLElementStyle;
    procedure SetItemByElementName(AElementName: String; AWMLElementStyle: TWMLElementStyle);
    function IndexOf(AxmlElementClass: TxmlElementClass): Integer;
    function IndexOfElementName(const AWMLElementName: String): Integer;
    function GetEnabledStylesPropertyString: String;
    procedure SetEnabledStylesPropertyString(const AValue: String);
  protected
    function AddStyle(AxmlElementClass: TxmlElementClass): TWMLElementStyle; virtual;
    function GetStylesString: String;
    procedure SetStylesString(const ASrc: String);
    function ParseStyles(const ASrc: String; AStart, AFinish: Integer): Boolean;
  public
    constructor Create;
    procedure Clear;
    property ItemsByClass[AxmlElementClass: TxmlElementClass]: TWMLElementStyle read GetItemByClass write SetItemByClass;
    property ItemsByElementName[AWMLElementName: String]: TWMLElementStyle read GetItemByElementName write SetItemByElementName;
    property Items[AOrder: Integer]: TWMLElementStyle read GetItem write SetItem; default;
    property StylesString: String read GetStylesString write SetStylesString;
    property Comments: String read FComments;
  published
    property EnabledStylesPropertyString: String read GetEnabledStylesPropertyString write SetEnabledStylesPropertyString;
  end;

// return color by name like black, Btnface, #ff00ff
// if color name is not correct, return ADefaultColor
function GetColorByName(const AColorName: String; ADefaultColor: TColor): TColor;

// return color name like black, Btnface, #ff00ff
function GetColorString(AColor: TColor): String;

// return font charset by name: default,ansi,russian,oem or code like #CC
// if charset name is not correct, return ADefaultCharset
// TFontCharset = 0..255
function GetFontCharsetByName(const AFontCharset: String; ADefaultCharset: TFontCharset): TFontCharset;

// return font charset name like 'russian' or  '#CC'
function GetFontCharsetString(AFontCharset: TFontCharset): String;

// return font pitch by name: default,fixed,variable
// if Pitch name is not correct, return ADefaultFontPitch
function GetFontPitchByName(const AFontPitch: String; ADefaultFontPitch: TFontPitch): TFontPitch;

// return font pitch name like 'fixed'
function GetFontPitchString(AFontPitch: TFontPitch): String;

// return Alignment by name: left, right, center
// if Alignment name is not correct, return ADefaultValue
function GetTextAlignmentByName(const AAlignment: String; ADefaultValue: TAlignment): TAlignment;

// return text alignment name like 'left'
function GetTextAlignmentString(ATextAlignment: TAlignment): String;

// return pen style by name: Solid, Dash, Dot, DashDot, DashDotDot, Clear, InsideFrame
// if pen style name is not correct, return ADefaultLineStyle
function GetLineStyleByName(const ALineStyle: String; ADefaultLineStyle: TPenStyle): TPenStyle;

// return pen style name like 'solid'
function GetLineStyleString(ALineStyle: TPenStyle): String;

// return font style by name: normal,bold,italic,underline,strikeout or combination
// if pen style name is not correct, return ADefaultLineStyle
function GetFontStylesByName(const AFontStyles: String; ADefaultFontStyles: TFontStyles): TFontStyles;

// return font style name like 'bold,italic'
function GetFontStylesString(AFontStyles: TFontStyles): String;

implementation

uses
  browserutil;
  
type
  TSupportedCursor = crHelp..crDefault;

const
  CursorNames: array [TSupportedCursor] of String[9] = (
  'help', 'appstart', 'no', 'sqlwait', 'multidrag', 'vsplit', 'hsplit',
  'nodrop', 'drag', 'hourglass', 'uparrow', 'sizewe', 'sizenwse', 'sizens',
  'sizenesw', 'size', 'ibeam', 'cross', 'arrow', 'none', 'default');

function StyleIdentToInt(const Ident: string; var Int: Longint; const Map: array of TIdentStyleEntry): Boolean;
var
  I: Integer;
begin
  for I := Low(Map) to High(Map) do
    if CompareText(Map[I].Name, Ident) = 0 then
    begin
      Result := True;
      Int := Map[I].Value;
      Exit;
    end;
  Result := False;
end;

function StyleIntToIdent(Int: Longint; var Ident: string; const Map: array of TIdentStyleEntry): Boolean;
var
  I: Integer;
begin
  for I := Low(Map) to High(Map) do
    if Map[I].Value = Int then
    begin
      Result := True;
      Ident := Map[I].Name;
      Exit;
    end;
  Result := False;
end;

// return color by name like black, Btnface, #ff00ff
// if color name is not correct, return ADefaultColor
{
    Black
    Maroon
    Green
    Olive
    Navy
    Purple
    Teal
    Gray
    Silver
    Red
    Lime
    Yellow
    Blue
    Fuchsia
    Aqua
    White

    ScrollBar
    Background
    ActiveCaption
    InactiveCaption
    Menu
    Window
    WindowFrame
    MenuText
    WindowText
    CaptionText
    ActiveBorder
    InactiveBorder
    AppWorkSpace
    Highlight
    HighlightText
    BtnFace
    BtnShadow
    GrayText
    BtnText
    InactiveCaptionText
    BtnHighlight
    3DDkShadow
    3DLight
    InfoText
    InfoBk
    None
}
function GetColorByName(const AColorName: String; ADefaultColor: TColor): TColor;
var
  ColorIdentifier: String;
  L: Integer;
begin
  ColorIdentifier:= Trim(AColorName);
  L:= Length(ColorIdentifier);
  if L <= 0 then begin
    Result:= ADefaultColor;
    Exit;
  end;
  if ColorIdentifier[1] = '#' then begin
    // Delete(ColorIdentifier, 1); Dec(L);
    ColorIdentifier[1]:= '$';
    Result:= StrToIntDef(ColorIdentifier, ADefaultColor);
  end else begin
    ColorIdentifier:= 'cl' + ColorIdentifier;
    if Graphics.IdentToColor(ColorIdentifier, Integer(Result))
    then
    else Result:= ADefaultColor;
  end;
end;

// return color name like black, Btnface, #ff00ff
function GetColorString(AColor: TColor): String;
begin
  if Graphics.ColorToIdent(AColor, Result)
  then Delete(Result, 1, 2)         // delete 'cl' prefix
  else begin
    // return value string like #ff00ff
    Result:= Format('#%x', [AColor]);
  end;
end;

// return font charset by name: default,fixed,variable
// if charset name is not correct, return ADefaultCharset
// TFontCharset = 0..255
{   dec hex symbol
    0   #0  ANSI
    1   #1  DEFAULT
    2       SYMBOL
    77      MAC
    128     SHIFTJIS
    129     HANGEUL
    130     JOHAB
    134     GB2312
    136     CHINESEBIG5
    161     GREEK
    162     TURKISH
    177     HEBREW
    178     ARABIC
    186     BALTIC
    204 #CC RUSSIAN
    222     THAI
    238     EASTEUROPE
    255 #FF OEM
}
function GetFontCharsetByName(const AFontCharset: String; ADefaultCharset: TFontCharset): TFontCharset;
var
  FontCharset: String;
  L: Integer;
begin
  FontCharset:= Trim(AFontCharset);
  L:= Length(FontCharset);
  if L <= 0 then begin
    Result:= ADefaultCharset;
    Exit;
  end;
  if FontCharset[1] = '#' then begin
    // hexadecimal value #0..#FF
    FontCharset[1]:= '$';
    Result:= StrToIntDef(FontCharset, ADefaultCharset);
  end else begin
    // may be decimal value
    L:= StrToIntDef(FontCharset, -1);
    if (L >= 0) and (L<=255)
    then Result:= L else begin
      // no hexadecimal, no decimal,
      // try to search charset by name (0:ANSI 1:default 204:russian 255:OEM)
      FontCharset:= FontCharset + '_CHARSET';
      if Graphics.IdentToCharset(FontCharset, L)
      then Result:= L
      else Result:= ADefaultCharset;
    end;
  end;
end;

// return font charset name like russian, #CC
function GetFontCharsetString(AFontCharset: TFontCharset): String;
begin
  if Graphics.CharsetToIdent(AFontCharset, Result)
  then Delete(Result, Length(Result) - 8 + 1, 8)  // delete '_CHARSET' suffix
  else begin
    // return value string like #cc
    Result:= Format('#%x', [AFontCharset]);
  end;
end;

// return font pitch by name: default,fixed,variable
// if Pitch name is not correct, return ADefaultFontPitch
function GetFontPitchByName(const AFontPitch: String; ADefaultFontPitch: TFontPitch): TFontPitch;
var
  FontPitch: String;
begin
  Result:= ADefaultFontPitch;
  FontPitch:= LowerCase(Trim(AFontPitch));
  if FontPitch = 'default'
  then Result:= fpDefault
  else if FontPitch = 'variable'
    then Result:= fpVariable
    else if FontPitch ='fixed'
      then Result:= fpFixed;
end;

// return font pitch name like 'fixed'
function GetFontPitchString(AFontPitch: TFontPitch): String;
begin
  case AFontPitch of
    fpDefault: Result:= 'default';
    fpVariable: Result:= 'variable';
    fpFixed: Result:= 'fixed';
  end; { case }
end;

// return Alignment by name: left, right, center
// if Alignment name is not correct, return ADefaultValue
function GetTextAlignmentByName(const AAlignment: String; ADefaultValue: TAlignment): TAlignment;
var
  FAlignment: String;
begin
  Result:= ADefaultValue;
  FAlignment:= LowerCase(Trim(AAlignment));
  if FAlignment = 'left'
  then Result:= taLeftJustify
  else if FAlignment = 'right'
    then Result:= taRightJustify
    else if FAlignment = 'center'
      then Result:= taCenter;
end;

// return text alignment name like 'left'
function GetTextAlignmentString(ATextAlignment: TAlignment): String;
begin
  case ATextAlignment of
    taLeftJustify: Result:= 'left';
    taRightJustify: Result:= 'right';
    taCenter: Result:= 'center';
  end; { case }
end;

// return pen style by name: Solid, Dash, Dot, DashDot, DashDotDot, Clear, InsideFrame
// if pen style name is not correct, return ADefaultLineStyle
function GetLineStyleByName(const ALineStyle: String; ADefaultLineStyle: TPenStyle): TPenStyle;
var
  FLineStyle: String;
begin
  Result:= ADefaultLineStyle;
  FLineStyle:= LowerCase(Trim(ALineStyle));
  if FLineStyle = 'solid'
  then Result:= psSolid
  else if FLineStyle = 'dash'
    then Result:= psDash
    else if FLineStyle = 'dot'
      then Result:= psDot
      else if FLineStyle = 'dashdot'
        then Result:= psDashDot
        else if FLineStyle = 'dashdotdot'
          then Result:= psDashDotDot
          else if FLineStyle = 'clear'
            then Result:= psClear
            else if FLineStyle = 'insideframe'
              then Result:= psInsideFrame;
end;

// return pen style name like 'solid'
function GetLineStyleString(ALineStyle: TPenStyle): String;
begin
  case ALineStyle of
    psSolid: Result:= 'solid';
    psDash: Result:= 'dash';
    psDot: Result:= 'dot';
    psDashDot: Result:= 'dashdot';
    psDashDotDot: Result:= 'dashdotdot';
    psClear: Result:= 'clear';
    psInsideFrame: Result:= 'insideframe';
  end; { case }
end;

// return font style by name: normal,bold,italic,underline,strikeout or combination
// if pen style name is not correct, return ADefaultLineStyle
function GetFontStylesByName(const AFontStyles: String; ADefaultFontStyles: TFontStyles): TFontStyles;
var
  FontStyleStr: String;
  FontStyles: TFontStyles;
begin
  // Result:= ADefaultFontStyle;
  FontStyles:= [];
  FontStyleStr:= LowerCase(Trim(AFontStyles));
  if Pos('bold', FontStyleStr) > 0
  then Include(FontStyles, fsBold);
  if Pos('italic', FontStyleStr) > 0
  then Include(FontStyles, fsItalic);
  if Pos('underline', FontStyleStr) > 0
  then Include(FontStyles, fsUnderline);
  if Pos('strikeout', FontStyleStr) > 0
  then Include(FontStyles, fsStrikeout);
  Result:= FontStyles;
end;

// return font style name like 'bold,italic'
function GetFontStylesString(AFontStyles: TFontStyles): String;
begin
  Result:= '';
  if fsBold in AFontStyles
  then Result:= Result + ',bold';
  if fsItalic in AFontStyles
  then Result:= Result + ',italic';
  if fsUnderline in AFontStyles
  then Result:= Result + ',underline';
  if fsStrikeout in AFontStyles
  then Result:= Result + ',strikeout';
  if Length(Result) > 0
  then Delete(Result, 1, 1);  // delete first ',' character
end;

//-------------------- TWMLElementStyle ------------------------

constructor TWMLElementStyle.Create;
begin
  inherited Create(ACollection);
  FEnabledStylePropertySet:= [FIRST_STYLEATTRIBUTENO..LAST_STYLEATTRIBUTENO];
  FillChar(FSize, SizeOf(FSize), #0);
  FSizeMeasure:= smNone;
  FillChar(FMargin, SizeOf(FMargin), #0);
  FMarginMeasure:= smNone;

  FTextAlign:= taLeftJustify;

  FFont:= TFont.Create;
  FBrush:= TBrush.Create;
  FTextFlags:= 0;
  {
  FFontPitch: TFontPitch;
  FFontColor: TColor;
  FFontStyles: TFontStyles;
  FFontPoints: Integer;
  FFontFamily: String;
  FFontCharset: TFontCharset;
  }
  FPen:= TPen.Create;
  FCursor:= crDefault;
end;

destructor TWMLElementStyle.Destroy;
begin
  FBrush.Free;
  // FCursor.Free;
  FPen.Free;
  FFont.Free;
  inherited Destroy;
end;

procedure TWMLElementStyle.SetCanvas(ACanvas: TCanvas);
begin
  with ACanvas do begin
    Font.Assign(FFont);
    Pen.Assign(FPen);
    Cursor:= FCursor;
    Brush.Assign(FBrush);
    ACanvas.TextFlags:= FTextFlags or TA_NOUPDATECP or ETO_OPAQUE;
    SetTextAlign(ACanvas.Handle, TA_BASELINE);
  end;
end;

type
  TRectArray = record
  case Integer of
  0:(
    R: TRect;
    );
  1:(
    A: array[0..3] of Integer;
    );
  end;

function TWMLElementStyle.GetSizeStr(ACoordinate: Integer): String;
begin
  Result:= Format('%d%s', [TRectArray(FSize).A[ACoordinate], MeasureStr(FSizeMeasure)]);
end;

procedure TWMLElementStyle.SetSizeStr(ACoordinate: Integer; AValueStr: String);
begin
  FSizeMeasure:= GetMeasure(AValueStr, TRectArray(FSize).A[ACoordinate]);
end;

function TWMLElementStyle.GetMargin(ACoordinate: Integer): String;
begin
  Result:= Format('%d%s', [TRectArray(FMargin).A[ACoordinate], MeasureStr(FMarginMeasure)]);
end;

procedure TWMLElementStyle.SetMargin(ACoordinate: Integer; AValueStr: String);
begin
  FMarginMeasure:= GetMeasure(AValueStr, TRectArray(FMargin).A[ACoordinate]);
end;

function TWMLElementStyle.GetTextAlignStr: String;
begin
  Result:= Format('%s', [GetTextAlignmentString(FTextAlign)]);
end;

procedure TWMLElementStyle.SetTextAlignStr(AValue: String);
begin
  FTextAlign:= GetTextAlignmentByName(AValue, FTextAlign);
end;

{ Brush
Property            Index
Background color    0
Bitmap              1  - not used
Style               2  - not used
}
function TWMLElementStyle.GetBrushStr(AIdx: Integer): String;
begin
  case AIdx of
  0:begin
      // background color
      Result:= GetColorString(FBrush.Color);
    end;
  1:begin
      // background image 8x8 pixels
      Result:= ''; // FBrush.Bitmap
    end;
  2:begin
      // background style: bsSolid, bsClear, bsHorizontal, bsVertical, bsFDiagonal, ...
      Result:= ''; // FBrush.Style
    end;
  end;
end;

procedure TWMLElementStyle.SetBrushStr(AIdx: Integer; AValue: String);
begin
  case AIdx of
  0:begin
      // background color
      FBrush.Color:= GetColorByName(AValue, FBrush.Color);
    end;
  end;
end;

{ Font
Property Index
Pitch    0
Color    1
Styles   2
Points   3
Family   4
Charset  5

}
function TWMLElementStyle.GetFontStr(AIdx: Integer): String;
begin
  case AIdx of
  0:begin
      // pitch
      Result:= GetFontPitchString(FFont.Pitch);
    end;
  1:begin
      // color
      Result:= GetColorString(FFont.Color);
    end;
  2:begin
      // styles
      Result:= GetFontStylesString(FFont.Style);
    end;
  3:begin
      // points
      Result:= Format('%d%s', [FFont.Size, 'pt']);
    end;
  4:begin
      // family
      Result:= Format('%s', [FFont.Name]);
    end;
  5:begin
      // charset
      Result:= GetFontCharsetString(FFont.Charset);
    end;
  end;
end;

procedure TWMLElementStyle.SetFontStr(AIdx: Integer; AValueStr: String);
var
//  m: TSizeMeasure;
  sz: Integer;
begin
  case AIdx of
  0:begin
      // pitch
      FFont.Pitch:= GetFontPitchByName(AValueStr, FFont.Pitch);
    end;
  1:begin
      // color
      FFont.Color:= GetColorByName(AValueStr, FFont.Color);
    end;
  2:begin
      // styles
      FFont.Style:= GetFontStylesByName(AValueStr, FFont.Style);
    end;
  3:begin
      // points
      sz:= FFont.Size;
      // m:=
      GetMeasure(AValueStr, sz);  // must be px
      FFont.Size:= sz;
      // you can do other measure unit conversion there
    end;
  4:begin
      // family
      FFont.Name:= AValueStr;
    end;
  5:begin
      // charset
      FFont.Charset:= GetFontCharsetByName(AValueStr, FFont.Charset);
    end;
  end;
end;

{ Line
  Property Index
  Color    0
  Width    1
  Style    2
}
function TWMLElementStyle.GetLineStr(AIdx: Integer): String;
begin
  case AIdx of
  0:begin
      // color
      Result:= GetColorString(FPen.Color);
    end;
  1:begin
      // width
      Result:= Format('%d%s', [FPen.Width, 'px']);
    end;
  2:begin
      // style
      Result:= GetLineStyleString(FPen.Style);
    end;
  end;
end;

procedure TWMLElementStyle.SetLineStr(AIdx: Integer; AValueStr: String);
var
//  m: TSizeMeasure;
  sz: Integer;
begin
  case AIdx of
  0:begin
      // color
      FPen.Color:= GetColorByName(AValueStr, FPen.Color);
    end;
  1:begin
      // width
      sz:= FPen.Width;
      // m:=
      GetMeasure(AValueStr, sz);  // must be px
      FPen.Width:= sz;
      // you can do other measure unit conversion there
    end;
  2:begin
      // style
      FPen.Style:= GetLineStyleByName(AValueStr, FPen.Style);
    end;
  end;
end;

function TWMLElementStyle.GetCursorStr: String;
begin
  if (FCursor >= Low(CursorNames)) and (FCursor <= High(CursorNames))
  then Result:= CursorNames[FCursor]
  else Result:= CursorNames[crDefault];
end;

procedure TWMLElementStyle.SetCursorStr(AValueStr: String);
var
  i: Integer;
  v: String;
begin
  v:= Lowercase(Trim(AValueStr));
  for i:= Low(CursorNames) to High(CursorNames) do begin
    // if CompareText(CursorNames[i], v) = 0
    if CursorNames[i] = v then begin
      FCursor:= i;
      Exit;
    end;
  end;
end;

{ Style            Index
  text-align       0
  background-color 1
  left             2
  top              3
  width            4
  height           5
  margin-left      6
  margin-right     7
  margin-top       8
  margin-bottom    9
  line-color       10
  line-width       11
  line-style       12
  font-color       13
  font-family      14
  font-size        15
  font-weight      16
  font-pitch       17
  font-charset     18
  cursor           19
}
function IdentToStyleIndex(const StyleIdent: string; var StyleIndex: Integer): Boolean;
begin
  Result:= StyleIdentToInt(StyleIdent, StyleIndex, StyleIndexes);
end;

// Graphics.TGetStrProc = procedure(const S: string) of object;
procedure TWMLElementStyle.InternalColorCallback(const S: string);
begin
  FBuffer:= FBuffer + Copy(S, 3, MaxInt) + ',';
end;

procedure TWMLElementStyle.InternalCharsetCallback(const S: string);
begin
  // delete '_CHARSET' suffix
  FBuffer:= FBuffer + Copy(S, 1, Length(S) - 8) + ',';
end;

function TWMLElementStyle.GetEnabledStylePropertyString: String;
var
  i, L: Integer;
begin
  Result:= '';
  for i:= Low(StyleIndexes) to High(StyleIndexes) do begin
    if i in Self.FEnabledStylePropertySet
    then Result:= Result + Format('%s, ', [StyleIndexes[i].Name]);
  end;
  L:= Length(Result);
  if L >= 2
  then Delete(Result, L - 1, 2);
end;

procedure TWMLElementStyle.SetEnabledStylePropertyString(const AValue: String);
var
  i: Integer;
  S: String;
begin
  S:= '';
  // delete spaces
  for i:= 1 to Length(AValue) do begin
    if AValue[i] <=#32
    then Continue;
    S:= S + AValue[i];
  end;
  if Length(S) = 0 then begin
    FEnabledStylePropertySet:= [];
    Exit;
  end;
  // lowercase for use Pos instead CompareText, use delimiters ','
  S:= ',' + LowerCase(S) + ',';
  // set FEnabledStylePropertySet to appropriate values
  for i:= Low(StyleIndexes) to High(StyleIndexes) do begin
    if Pos(',' + StyleIndexes[i].Name+ ',', S) > 0
    then Include(FEnabledStylePropertySet, i)
    else Exclude(FEnabledStylePropertySet, i);
  end;
end;

function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
var
  S: TStrings;
  Temp: string;
begin
  S := TStrings(Data);
  Temp := LogFont.lfFaceName;
  if (S.Count = 0) or (AnsiCompareText(S[S.Count-1], Temp) <> 0) then
    S.Add(Temp);
  Result := 1;
end;

procedure MkFontList(AStrings: TStrings; ACharset: TFontCharset);
var
  DC: HDC;
  LFont: TLogFont;
begin
  // Result:= Forms.Screen.Fonts.CommaText;
  AStrings.Clear;
  DC:= GetDC(0);
  if Lo(GetVersion) >= 4 then begin
    // in Windows95 or higher can obtain character set
    FillChar(LFont, sizeof(LFont), 0);
    LFont.lfCharset:= ACharset;
    EnumFontFamiliesEx(DC, LFont, @EnumFontsProc, LongInt(AStrings), 0);
  end else begin
    EnumFonts(DC, nil, @EnumFontsProc, Pointer(AStrings));
  end;
  if AStrings is TStringList
  then TStringList(AStrings).Sorted:= True;
end;

function TWMLElementStyle.GetChooseListByIndex(AIdx: Integer): String;
var
  SL: TStrings;

  procedure MkColorList;
  begin
    FBuffer:= '';
    Graphics.GetColorValues(InternalColorCallback);
    Delete(FBuffer, Length(FBuffer), 1);  // delete last ','
    Result:= FBuffer;
  end;

  procedure MkCharsetList;
  begin
    FBuffer:= '';
    Graphics.GetCharsetValues(InternalCharsetCallback);
    Delete(FBuffer, Length(FBuffer), 1);  // delete last ','
    Result:= FBuffer;
  end;

  procedure MkCursorList;
  var
    i: Integer;
  begin
    Result:= '';
    for i:= High(CursorNames) downto Low(CursorNames) do begin
      Result:= Result + CursorNames[i] + ','
    end;
    Delete(Result, Length(Result), 1);  // delete last ','
  end;

begin
  case AIdx of
  0: Result:=  'left,right,center';
  1: MkColorList;
  2: Result:=  '';
  3: Result:=  '';
  4: Result:=  '';
  5: Result:=  '';
  6: Result:=  '';
  7: Result:=  '';
  8: Result:=  '';
  9: Result:=  '';
  10: MkColorList;
  11: Result:= '';
  12: Result:= 'solid,dash,dot,dashdot,dashdotdot,clear,insideframe';
  13: MkColorList;
  14: begin
      SL:= TStringList.Create;
      //MkFontList(SL, Self.FFont.Charset);
      MkFontList(SL, DEFAULT_CHARSET);
      Result:= SL.CommaText;
      SL.Free;
      end;
  15: Result:= '';
  16: Result:= ',bold,italic,underline,strikeout,"bold,italic","bold,underline","italic,underline",';
  17: Result:= 'default,variable,fixed';
  18: MkCharsetList;
  19: MkCursorList;
  else Result:= '';
  end;
end;

function TWMLElementStyle.GetStyleTypeByIndex(AIdx: Integer): TStyleType;
begin
  if (AIdx >= Low(StyleIndexes)) and (AIdx <= High(StyleIndexes))
  then Result:= StyleIndexes[AIdx].Style
  else Result:= stNone;
end;

function TWMLElementStyle.GetStyleStrByIndex(AIdx: Integer): String;
begin
  case AIdx of
  0: Result:=  TextAlignStr;
  1: Result:=  BackgroundColorStr;
  2: Result:=  LeftStr;
  3: Result:=  TopStr;
  4: Result:=  WidthStr;
  5: Result:=  HeightStr;
  6: Result:=  MarginLeftStr;
  7: Result:=  MarginRightStr;
  8: Result:=  MarginTopStr;
  9: Result:=  MarginBottomStr;
  10: Result:= LineColorStr;
  11: Result:= LineWidthStr;
  12: Result:= LineStyleStr;
  13: Result:= FontColorStr;
  14: Result:= FontFamilyStr;
  15: Result:= FontPointsStr;
  16: Result:= FontStylesStr;
  17: Result:= FontPitchStr;
  18: Result:= FontCharsetStr;
  19: Result:= CursorStr;
  else Result:= '';
  end;
end;

procedure TWMLElementStyle.SetStyleStrByIndex(AIdx: Integer; AValueStr: String);
begin
  case AIdx of
  0:   TextAlignStr:= AValueStr;
  1:   BackgroundColorStr:= AValueStr;
  2:   LeftStr:= AValueStr;
  3:   TopStr:= AValueStr;
  4:   WidthStr:= AValueStr;
  5:   HeightStr:= AValueStr;
  6:   MarginLeftStr:= AValueStr;
  7:   MarginRightStr:= AValueStr;
  8:   MarginTopStr:= AValueStr;
  9:   MarginBottomStr:= AValueStr;
  10:  LineColorStr:= AValueStr;
  11:  LineWidthStr:= AValueStr;
  12:  LineStyleStr:= AValueStr;
  13:  FontColorStr:= AValueStr;
  14:  FontFamilyStr:= AValueStr;
  15:  FontPointsStr:= AValueStr;
  16:  FontStylesStr:= AValueStr;
  17:  FontPitchStr:= AValueStr;
  18:  FontCharsetStr:= AValueStr;
  19:  CursorStr:= AValueStr;
  else ;
  end;
end;

function TWMLElementStyle.GetStyleStrByName(AStyleName: String): String;
var
  styleIndex: Integer;
begin
  if IdentToStyleIndex(AStyleName, styleIndex) then begin
    GetStyleStrByIndex(styleIndex);
  end;
end;

procedure TWMLElementStyle.SetStyleStrByName(AStyleName: String; AValueStr: String);
var
  styleIndex: Integer;
begin
  if IdentToStyleIndex(AStyleName, styleIndex) then begin
    SetStyleStrByIndex(styleIndex, AValueStr);
  end;
end;

procedure TWMLElementStyle.GetStyleStrings(AStrings: TStrings);
var
  i: Integer;
begin
  AStrings.Clear;
  for i:= Low(StyleIndexes) to High(StyleIndexes) do begin
    if i in Self.FEnabledStylePropertySet
    then AStrings.Add(StyleIndexes[i].Name + '=' + StyleStrByIndex[i]);
  end;
end;

function TWMLElementStyle.GetStyleString: String;
var
  SL: TStrings;
  i, p: Integer;
  S: String;
begin
  Result:= '';
  SL:= TStringList.Create;
  GetStyleStrings(SL);
  for i:= 0 to SL.Count - 1 do begin
    S:= SL[i];
    // replace '=' to ': '
    p:= Pos('=', S);
    if p > 0 then begin
      Result:= Result + ' ' + Copy(S, 1, p - 1) + ': ' +
        Copy(S, p + 1, MaxInt) + ';'#13#10;
    end;
  end;
  SL.Free;
end;

procedure TWMLElementStyle.LoadFromStrings(ASrc: TStrings);
var
  i, p: Integer;
begin
  with ASrc do begin
    for i:= 0 to Count - 1 do begin
      p:= Pos('=', ASrc[i]);
      if p > 0 then begin
        StyleStrByName[Copy(ASrc[i], 1, p - 1)]:= Copy(ASrc[i], p + 1, MaxInt);
      end;
    end;
  end;
end;

function TWMLElementStyle.ParseStyle(const ASrc: String; AStart, AFinish: Integer): Boolean;
var
  i: Integer;
  nm0, nm1, vl0, vl1: Integer;
  state: Integer;
begin
  Result:= False;
  // disable compiler warnings
  nm0:= 0; nm1:= 0; vl0:= 0; vl1:= 0;
  state:= 0; // wait style name
  for i:= AStart to AFinish do begin
    case ASrc[i] of
    ':':begin
         vl1:= 0;
         case state of
         0,3..4:begin
             // no style name specified
             // raise
             Exit;
           end;
         1:begin // expecting space or ':'
             nm1:= i;  // style name finished
             state:= 3;  // wait value
           end;
         2:begin // expecting ':', name finished
             state:= 3;  // wait value
           end;
         end; { case }
       end;
    ';':begin
         case state of
         0..3:begin
             // no style name specified
             // raise
             Exit;
           end;
         4:begin
             state:= 0;  // value finished, wait for next style name
             if vl1 = 0  // no spaces before ';'
             then vl1:= i;
             StyleStrByName[Copy(ASrc, nm0, nm1 - nm0)]:= Copy(ASrc, vl0, vl1 - vl0);
           end;
         end; { case }
       end;
    #10:begin
       end;
    #9,#32,#13:begin
        case state of
          0,2..3:begin // expecting name start
              // wait style name, nothing to do
            end;
          1:begin // expecting space or ':'
              // style name finished
              nm1:= i;
              state:= 2;  // wait for ':'
            end;
          4:begin // expecting value finish
              vl1:= i;
            end;
        end { case };
      end;
    else begin
      // name or values
      case state of
        0:begin  // expecting name start
            state:= 1;  // name started , wait for name finish (space or ':')
            nm0:= i;
          end;
        1:begin  // expecting space or ':'
            // name continued, nothing to do
          end;
        2:begin // expecting ':'
            // ':' expected but symbol found
            // raise
            Exit;
          end;
        3:begin // expecting value start
            state:= 4; // value started, expecting ';' or eof
            vl0:= i;
          end;
        4:begin
            vl1:= 0;
          end;
      end; { case }
    end;
    end; { case }
  end;
  if state = 4 then begin
    // last value not finfished with ';'
    if vl1 = 0
    then vl1:= AFinish + 1;
    StyleStrByName[Copy(ASrc, nm0, nm1 - nm0)]:= Copy(ASrc, vl0, vl1 - vl0);
  end;
  Result:= True;
end;

// -------------------- styles collection ------------------------

function TWMLElementStyles.GetItem(AOrder: Integer): TWMLElementStyle;
begin
  Result:= TWMLElementStyle(inherited GetItem(AOrder));
end;

procedure TWMLElementStyles.SetItem(AOrder: Integer; AWMLElementStyle: TWMLElementStyle);
begin
  inherited SetItem(AOrder, AWMLElementStyle);
end;

function TWMLElementStyles.GetItemByClass(AxmlElementClass: TxmlElementClass): TWMLElementStyle;
var
  Idx: Integer;
begin
  if AxmlElementClass = Nil then begin
    Result:= Nil
  end else begin
    Idx:= IndexOf(AxmlElementClass);
    if Idx >=0
    then Result:= TWMLElementStyle(inherited GetItem(Idx))
    else Result:= Nil;
  end;
end;

procedure TWMLElementStyles.SetItemByClass(AxmlElementClass: TxmlElementClass; AWMLElementStyle: TWMLElementStyle);
var
  Idx: Integer;
begin
  Idx:= IndexOf(AxmlElementClass);
  if Idx >=0 then begin
    inherited SetItem(Idx, AWMLElementStyle);
  end;
end;

function TWMLElementStyles.GetItemByElementName(AElementName: String): TWMLElementStyle;
var
  Idx: Integer;
begin
  Idx:= IndexOfElementName(AElementName);
  if Idx >=0
  then Result:= TWMLElementStyle(inherited GetItem(Idx))
  else Result:= Nil;
end;

procedure TWMLElementStyles.SetItemByElementName(AElementName: String; AWMLElementStyle: TWMLElementStyle);
var
  Idx: Integer;
begin
  Idx:= IndexOfElementName(AElementName);
  if Idx >=0 then begin
    inherited SetItem(Idx, AWMLElementStyle);
  end;
end;

constructor TWMLElementStyles.Create;
begin
  inherited Create(TWMLElementStyle);
  FComments:= '';
  Clear;
end;

function TWMLElementStyles.IndexOf(AxmlElementClass: TxmlElementClass): Integer;
var
  c: Integer;
begin
  Result:= -1;
  for c:= 0 to Count - 1 do begin
    if Items[c].FWMLElementClass = AxmlElementClass then begin
      Result:= c;
      Exit;
    end;
  end;
end;

function TWMLElementStyles.IndexOfElementName(const AWMLElementName: String): Integer;
var
  c: Integer;
begin
  Result:= -1;
  for c:= 0 to Count - 1 do begin
    if CompareText(Items[c].FWMLElementClass.GetElementName, AWMLElementName) = 0 then begin
      Result:= c;
      Exit;
    end;
  end;
end;

function TWMLElementStyles.GetEnabledStylesPropertyString: String;
var
  c: Integer;
begin
  Result:= '';
  for c:= 0 to Count - 1 do begin
    Result:= Result + Items[c].FWMLElementClass.GetElementName +
      ': ' + Items[c].EnabledStylePropertyString + #13#10;
  end;
end;

procedure TWMLElementStyles.SetEnabledStylesPropertyString(const AValue: String);
var
  p, p0, p1, len: Integer;
  L: String;
  style: TWMLElementStyle;
begin
  len:= Length(AValue);
  if len = 0 then begin
    Exit;
  end;
  p0:= 1;
  p1:= 1;
  repeat
    // find eol
    while (p1 <= len) and (AValue[p1] <> #13)
    do Inc(p1);
    L:= Copy(AValue, p0, p1 - p0);
    // prepare to next step
    Inc(p1);
    if p1 >= len  // no more lines
    then Exit;
    if AValue[p1] = #10
    then Inc(p1);
    // next line
    p0:= p1;

    p:= Pos(':', L);
    if p <= 0
    then Continue;
    style:= ItemsByElementName[Trim(Copy(L, 1, p - 1))];
    if Assigned(style) then begin
      style.EnabledStylePropertyString:= Copy(L, p + 1, MaxInt)
    end;
  until False;
end;

function TWMLElementStyles.AddStyle(AxmlElementClass: TxmlElementClass): TWMLElementStyle;
begin
  Result:= TWMLElementStyle(inherited Add);
  Result.FWMLElementClass:= AxmlElementClass;
end;

procedure TWMLElementStyles.Clear;
var
  c: Integer;
  dsc: TxmlClassDesc;
begin
  // free up collection items
  for c:= 0 to Count - 1 do begin
    Items[0].Free;
  end;
  if not GetxmlClassDescByClass(TwmlContainer, dsc)
  then Exit;

  // create new ones
  for c:= 0 to dsc.len - 1 do begin
    Self.AddStyle(dsc.classes[c]);
    // call class function to obtain class name like 'wml'
    // WMLElements[c].GetElementName;
  end;
end;

function TWMLElementStyles.GetStylesString: String;
var
  c: Integer;
  dsc: TxmlClassDesc;
begin
  Result:= '';
  if not GetxmlClassDescByClass(TwmlContainer, dsc)
  then Exit;
  for c:= 0 to dsc.len - 1 do begin
    Result:= Result + dsc.classes[c].GetElementName +
    ' {'#13#10 + Items[c].GetStyleString + '}'#13#10; // hmm
  end;
end;

// p, br {ELEMENTSTYLE} wml {} ...
function TWMLElementStyles.ParseStyles(const ASrc: String; AStart, AFinish: Integer): Boolean;
var
  i, c: Integer;
  ElList: TStrings;
  nm0, nm1, vl0, vl1, comment0: Integer;
  state: Integer;
  eclass: TxmlElementClass;
begin
  Result:= False;
  FComments:= '';
  comment0:= 0;  // compiler warning supress
  ElList:= TStringList.Create;
  // disable compiler warnings
  nm0:= 0; nm1:= 0; vl0:= 0;
  state:= 0; // wait style name
  for i:= AStart to AFinish do begin
    case ASrc[i] of
    '<':begin // actually <!-- -->
          case state of
          0:begin
              // wait for '>'
              state:= 4;
              comment0:= i;
            end;
          end;
        end;
    '>':begin // actually <!-- -->
          case state of
          4:begin
              // wait for style name
              state:= 0;
              FComments:= FComments + #13#10 + Copy(ASrc, comment0 + 4, i - comment0-6);
            end;
          end;
        end;

    ',':begin
         nm1:= 0;
         case state of
         0,1:begin
             // no style name specified
             // raise
             Exit;
           end;
         2:begin // expecting ',' or ':'
             if nm1 = 0 then begin
               nm1:= i;
             end;
             // add element name to list
             ElList.Add(Copy(ASrc, nm0, nm1 - nm0));
             state:= 1;  // return to expecting next element name or '{'
           end;
         end; { case }
       end;
    '{':begin
         case state of
         0,1,3:begin
             // no style name specified
             // raise
             Exit;
           end;
         2:begin // expecting ',' or '{'
             if nm1 = 0 then begin
               nm1:= i;
             end;
             // add element name to list
             ElList.Add(Copy(ASrc, nm0, nm1 - nm0));
             state:= 3;  // wait for '}'
             vl0:= i + 1;
           end;
         end; { case }
       end;
    '}':begin
         case state of
         0..2:begin
             // no style name specified
             // raise
             Exit;
           end;
         3:begin
             state:= 0;  // style declration  finished, wait for next style
             vl1:= i - 1;
             for c:= 0 to ElList.Count - 1 do begin
               eclass:= TxmlElementClass(GetxmlClassByElementName(TwmlContainer, ElList[c]));
               if Assigned(eclass)
               then ItemsByClass[eclass].ParseStyle(ASrc, vl0, vl1);
             end;
             ElList.Clear;
           end;
         end; { case }
       end;
    #10:begin
       end;
    #9,#13,#32:begin
        case state of
          1:begin // expecting space , ',' or '{'
              // element name finished
              nm1:= i;
              // do not add element name to list
              // ElList.Add(Copy(ASrc, nm0, nm1 - nm0));
              state:= 2;  // wait for ',' or '{'
            end;
        end { case };
      end;
    else begin
      // name or values
      case state of
        0:begin  // expecting element names list start
            state:= 1;  // name started , wait for ',' or '{'
            nm0:= i;
            nm1:= 0; // in case of 'p{' (w/o spaces between element name and '{')
          end;
      end; { case }
    end;
    end; { case }
  end;
  ElList.Free;
  // if ValidateStyles(Self) then;
  Result:= True;
end;

procedure TWMLElementStyles.SetStylesString(const ASrc: String);
begin
  ParseStyles(ASrc, 1, Length(ASrc));
end;

end.
