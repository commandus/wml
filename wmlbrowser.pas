unit
  wmlbrowser;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  m  l  b  r  o  w  s  e  r                                               *
*                                                                             *
*   Copyright © 2001-2002 Andrei Ivanov. All rights reserved.                  *
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
  customxml, wml, xmlParse, xmlsupported, wmlstyle, browserutil, Jpeg, GifImage,
  ExtCtrls;

resourcestring

  INFOMSG_HINT = 'Hint';
  INFOMSG_WARNING = 'Warning';
  INFOMSG_ERROR = 'Error';
  INFOMSG_SEARCH = 'Search';

const
  DEF_INPUT_CHARS = 5;
  DEF_COLOR = clWhite;
  DEF_FONT_FAMILY = 'Times New Roman';// 'Courier New';

type
  TTextScroledEvent = procedure(Sender: TObject; TopRow, BottomRow,
    LeftCol, MaxCols: Integer) of object;
  THyperlinkClickEvent = procedure(Sender: TObject; Hyperlink: string) of object;

  TBrowserViewOption = (bvViewControlSymbols, bvScreenSave);
  TBrowserViewOptions = set of TBrowserViewOption;

(************************ Collections ************************)

  TEditClass = class of TEdit;

  TBrowserItemCollection = class(TCollection)
  private
  protected
  public
    constructor Create(ItemClass: TCollectionItemClass);
  end;

  TControlCollection = class(TBrowserItemCollection)
  private
    FOwner: TControl;
    FParent: TControl;
  protected
  public
    constructor Create(ItemClass: TCollectionItemClass;
      AOwner: TControl; AParent: TControl);
//    procedure TurnParent(AOn: Boolean);
  end;

  TControlCollectionItem = class(TCollectionItem)
  private
  protected
    FControl: TControl;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure TurnParent(AOn: Boolean);
    property Control: TControl read FControl write FControl;
  end;

  TInputItem = class(TControlCollectionItem)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TInputCollection = class(TControlCollection)
  private
    function GetItem(Index: Integer): TInputItem;
    procedure SetItem(Index: Integer; Value: TInputItem);
    function GetInputItem(Index: Integer): TEdit;
    procedure SetInputItem(Index: Integer; Value: TEdit);
  public
    function Add: TInputItem;
    function AddInput: TEdit;
    property InputItems[Index: Integer]: TEdit read GetInputItem write SetInputItem;
    property Items[Index: Integer]: TInputItem read GetItem write SetItem; default;
  end;

  TSelectItem = class(TControlCollectionItem)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TSelectCollection = class(TControlCollection)
  private
    function GetItem(Index: Integer): TSelectItem;
    procedure SetItem(Index: Integer; Value: TSelectItem);
    function GetSelectItem(Index: Integer): TComboBox;
    procedure SetSelectItem(Index: Integer; Value: TComboBox);
  public
    function Add: TSelectItem;
    function AddSelect: TCombobox;
    property Items[Index: Integer]: TSelectItem read GetItem write SetItem; default;
    property SelectItems[Index: Integer]: TCombobox read GetSelectItem write SetSelectItem;
  end;

  TLineEnvItem = class(TCollectionItem)
  private
    FHeight: Integer;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    property Height: Integer read FHeight write FHeight;
  end;

  TLineEnvCollection = class(TBrowserItemCollection)
  private
    FBitmap: TBitmap;
    function GetItem(Index: Integer): TLineEnvItem;
    procedure SetItem(Index: Integer; Value: TLineEnvItem);
    function GetHeight(Index: Integer): Integer;
    procedure SetHeight(Index: Integer; Value: Integer);
  public
    function Add: TLineEnvItem;
    property Items[Index: Integer]: TLineEnvItem read GetItem write SetItem; default;
    property Heights[Index: Integer]: Integer read GetHeight write SetHeight;
  end;

  TBrowserState = (bsWrap);
  TBrowserStates = set of TBrowserState;

  (************************ TDrawElementEnv ************************)

  TDrawElementEnv = class(TPersistent)
  private
  public
    State: TBrowserStates;
    CaretP: TPoint;
    Size: TPoint;
    FBitmap: TBitmap;
    ClipR: TRect;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
  end;

(************************ TDrawScreenSaveEnv ************************)

  TDrawScreenSaveEnv = record
    Tick: Integer;
  end;

  TOnDrawElementEvent = procedure (var AWMLElement: TxmlElement) of object;

(************************ TWMLCustomBrowser ************************)

  TCustomWMLBrowser = class(TCustomControl)
  private
    FOnDrawElementStart: TOnDrawElementEvent;
    FOnDrawElementFinish: TOnDrawElementEvent;
    procedure SetOnDrawElementStart(AValue: TOnDrawElementEvent);
    procedure SetOnDrawElementFinish(AValue: TOnDrawElementEvent);
    { search variables in AxmlElement and replace variables. If no, remove it }
    function GetVariableValue(const AVarName: String; AEsc: Integer; var AValue: WideString): Boolean;
  protected
    FCurDrawElement: TxmlElement;
    FCurSearchElement: TxmlElement;
    FCurMouseElement: TxmlElement;  // mouse point to this element
    FCurMouseLinkElement: TxmlElement;  // if mouse point to some element (PCDATA for instance), this is points to the parent <a>
    FCurPos: TPoint;

    FxmlParser: TxmlParser;
    FWMLCollection: TxmlElementCollection;
    FParseMessages: TStrings;

    FSrc: PWideString;
    FStripHTTPHeader: Boolean;

    FCurrentCard: TxmlElement;

    FViewOptions: TBrowserViewOptions;
    FOnPaint: TNotifyEvent;
    FOnScreenSave: TNotifyEvent;
    FOnHyperlinkClick: THyperlinkClickEvent;
    FVariables: TWideStrings;
    function GetVar(AName: WideString): WideString;
    procedure SetVar(AName, AValue: WideString);
    // parse line and insert $var values. AMaskVar: MASK_VAR_ASIS MASK_VAR_ESCAPESINGLE_QUOTE MASK_VAR_UTF8
    function GetVData(const ASrc: WideString): WideString; // AMaskVar: Integer
    procedure SetViewOptions(AValue: TBrowserViewOptions);
    function ParseSource: Boolean;
    function GetSrc: String;
    // wml ForEachInOut callback functions

    procedure ProcDrawStartElement(var AWmlElement: TxmlElement); virtual;
    procedure ProcDrawFinishElement(var AWmlElement: TxmlElement); virtual;
    procedure ProcGetElementPosition(var AWmlElement: TxmlElement);

    function GetCurrentCardEl: TxmlElement;
    procedure SetCurrentCardEl(const AValue: TxmlElement);
    function GetCurrentCard: String;
    procedure SetCurrentCard(const AValue: String);

    procedure ShowParseMessage(ALevel: TReportLevel; AxmlElement: TxmlElement;
      const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
      var AContinueParse: Boolean; AEnv: Pointer);

    function LoadImageBitmap(const AUrl: WideString; ABitmap: TBitmap; var ASize: TPoint; ANoImgSize: Boolean): Boolean;
    procedure DrawScreenSave; virtual; abstract;
    procedure DrawCard; virtual; abstract;
    procedure DrawA; virtual; abstract;
    procedure DrawLineBreaks; virtual; abstract;
    procedure DrawTextLayout; virtual; abstract;
    procedure DrawInput; virtual; abstract;
    procedure DrawSelect; virtual; abstract;
    procedure DrawOption; virtual; abstract;
    procedure DrawPCData; virtual; abstract;
    procedure DrawImg; virtual; abstract;
    procedure DoSetVar; virtual;
    procedure Paint; override;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var AMsg: TMessage); override;
  public
    property Canvas; // original visibility is protected
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear; virtual;
    property Src: String read GetSrc;
    property CurMouseElement: TxmlElement read FCurMouseElement;
    property CurMouseLinkElement:TxmlElement read FCurMouseLinkElement;
    procedure SetSrcPtr(ASrc: PWideString);
    property CurrentCard: String read GetCurrentCard write SetCurrentCard;
    property CurrentCardEl: TxmlElement read GetCurrentCardEl write SetCurrentCardEl;
    property Variable[AName: WideString]: WideString read GetVar write SetVar;
    procedure ClearVariables;
    procedure Resize; override;
    procedure Reload; virtual;
    // set StripHTTPHeader before assign Src property
    function GetElementByCoord(const ACoord: TPoint): TxmlElement;

  published
    property ViewOptions: TBrowserViewOptions read FViewOptions write SetViewOptions;
    // set StripHTTPHeader before assign Src property
    property StripHTTPHeader: Boolean read FStripHTTPHeader write FStripHTTPHeader;

    property OnHyperlinkClick: THyperlinkClickEvent read FOnHyperlinkClick write FOnHyperlinkClick;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDrawElementStart: TOnDrawElementEvent read FOnDrawElementStart write SetOnDrawElementStart;
    property OnDrawElementFinish: TOnDrawElementEvent read FOnDrawElementFinish write SetOnDrawElementFinish;

  end;

procedure TTYWrap(const S: WideString; ACanvas: TCanvas; var ACaret: TPoint; var AClip: TRect;
  AYIncr: Integer; var AEdges: TRect);

const
  HINT_FONTSIZE = 8;

resourcestring
  HINT_FONT = 'MS Sans Serif';
  EMPTY_WMLDOC = '<wml><card><p><b>Sample</b></p></card></wml>';

implementation

procedure TTYWrap(const S: WideString; ACanvas: TCanvas; var ACaret: TPoint; var AClip: TRect;
  AYIncr: Integer; var AEdges: TRect);
var
  i: Integer;
  lt: Integer;
  w: WideString;
  printed: Boolean;

  procedure PrintPiece;
  var
    sz: TSize;
  begin
    Windows.GetTextExtentPoint32W(ACanvas.Handle, PWideChar(w), Length(w), sz);
    if ACaret.X + sz.cx > AClip.Right then begin
      // remember rightmost
      Inc(ACaret.y, AYIncr);
      if ACaret.X > AEdges.Right then begin
        AEdges.Right:= ACaret.X;
      end;
      // go to the next line
      ACaret.x:= AClip.Left;
      // remember leftmost
      if ACaret.X < AEdges.Left then begin
        AEdges.Left:= AClip.Left;
      end;
      //
      Windows.ExtTextOutW(ACanvas.Handle, ACaret.X, ACaret.Y,
        ACanvas.TextFlags, Nil, PWideChar(w), Length(w), 0);
      Inc(ACaret.x, sz.cx);
    end else begin
      // same line
      if ACaret.X < AEdges.Left then begin
        AEdges.Left:= ACaret.X;
      end;
      // remember rightmost
      if ACaret.X > AEdges.Right then begin
        AEdges.Right:= ACaret.X;
      end;

      Windows.ExtTextOutW(ACanvas.Handle, ACaret.X, ACaret.Y,
        ACanvas.TextFlags, Nil, PWideChar(w), Length(w), 0);
      Inc(ACaret.x, sz.cx);
    end;
  end;

begin
  printed:= False;
  with AEdges do begin
    Left:= ACaret.X;
    Right:= ACaret.X;
    Top:= ACaret.Y;
    Bottom:= ACaret.Y;
  end;
  //
  lt:= 1;
  for i:= 1 to Length(S) do begin
    case S[i]of
      #0..#32, WideLineSeparator: begin
        if not printed then begin
          w:= Copy(s, lt, i - lt) + #32;
          PrintPiece;
          printed:= True;
        end;
        lt:= i + 1;
      end;
      else begin
        printed:= False;
      end;
    end; { case }
  end;
  if not printed then begin
    w:= Copy(s, lt, Length(S) - lt + 1);
    PrintPiece;
  end;
  AEdges.Top:= AEdges.Top + AYIncr;
  AEdges.Bottom:= ACaret.Y;
end;

(************************ TBrowserItemCollection ************************)

constructor TBrowserItemCollection.Create(ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);
end;

(************************ TControlCollection ************************)

constructor TControlCollection.Create(ItemClass: TCollectionItemClass;
  AOwner: TControl; AParent: TControl);
begin
  inherited Create(ItemClass);
  FOwner:= AOwner;
  FParent:= AParent;
end;

{
procedure TControlCollection.TurnParent(AOn: Boolean);
begin
  if AOn
  then FControl.Parent:= FParent
  else FControl.Parent:= Nil;
end;
}
(************************ TControlCollectionItem ************************)

constructor TControlCollectionItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
end;

destructor TControlCollectionItem.Destroy;
begin
  FControl.Free;
  inherited Destroy;
end;

procedure TControlCollectionItem.TurnParent(AOn: Boolean);
begin
  if AOn
  then TWinControl(FControl).Parent:= TWinControl(TControlCollection(Collection).FParent)
  else FControl.Parent:= Nil;
end;

{********************************* TInputItem *********************************}

constructor TInputItem.Create(ACollection: TCollection);
begin
  FControl:= TEdit.Create(TControlCollection(ACollection).FOwner);
  inherited Create(ACollection);
end;

{********************************* TInputCollection ***************************}

function TInputCollection.GetItem(Index: Integer): TInputItem;
begin
  Result:= TInputItem(inherited GetItem(Index));
end;

procedure TInputCollection.SetItem(Index: Integer; Value: TInputItem);
begin
  inherited SetItem(Index, Value);
end;

function TInputCollection.GetInputItem(Index: Integer): TEdit;
begin
  Result:= TEdit(TInputItem(inherited GetItem(Index)).FControl);
end;

procedure TInputCollection.SetInputItem(Index: Integer; Value: TEdit);
begin
  TEdit(TInputItem(inherited GetItem(Index)).FControl).Assign(Value);
end;

function TInputCollection.Add: TInputItem;
begin
  Result:= TInputItem(inherited Add);
end;

function TInputCollection.AddInput: TEdit;
begin
  Result:= TEdit(TInputItem(inherited Add).FControl);
end;

{******************************** TSelectItem *********************************}

constructor TSelectItem.Create(ACollection: TCollection);
begin
  FControl:= TCombobox.Create(TControlCollection(ACollection).FOwner);
  inherited Create(ACollection);
end;

{***************************** TSelectCollection ******************************}

function TSelectCollection.GetItem(Index: Integer): TSelectItem;
begin
  Result:= TSelectItem(inherited GetItem(Index));
end;

procedure TSelectCollection.SetItem(Index: Integer; Value: TSelectItem);
begin
  inherited SetItem(Index, Value);
end;

function TSelectCollection.GetSelectItem(Index: Integer): TComboBox;
begin
  Result:= TComboBox(TSelectItem(inherited GetItem(Index)).FControl);
end;

procedure TSelectCollection.SetSelectItem(Index: Integer; Value: TComboBox);
begin
  TComboBox(TSelectItem(inherited GetItem(Index)).FControl).Assign(Value);
end;

function TSelectCollection.Add: TSelectItem;
begin
  Result:= TSelectItem(inherited Add);
end;

function TSelectCollection.AddSelect: TCombobox;
begin
  Result:= TComboBox(TSelectItem(inherited Add).FControl);
end;

{******************************** TLineEnvItem ********************************}

constructor TLineEnvItem.Create(ACollection: TCollection);
begin
  FHeight:= 0;
  inherited Create(ACollection);
end;

destructor TLineEnvItem.Destroy;
begin
  inherited Destroy;
end;

{*************************** TLineEnvCollection *******************************}

function TLineEnvCollection.GetItem(Index: Integer): TLineEnvItem;
begin
  Result:= TLineEnvItem(inherited GetItem(Index));
end;

procedure TLineEnvCollection.SetItem(Index: Integer; Value: TLineEnvItem);
begin
  inherited SetItem(Index, Value);
end;

function TLineEnvCollection.GetHeight(Index: Integer): Integer;
begin
  Result:= TLineEnvItem(inherited GetItem(Index)).Height;
end;

procedure TLineEnvCollection.SetHeight(Index: Integer; Value: Integer);
begin
  TLineEnvItem(inherited GetItem(Index)).Height:= Value;
end;

function TLineEnvCollection.Add: TLineEnvItem;
begin
  Result:= TLineEnvItem(inherited Add);
end;

{******************************* TDrawElementEnv ******************************}

constructor TDrawElementEnv.Create;
begin
  inherited Create;
  Clear;
  FBitmap:= TBitmap.Create;
end;

destructor TDrawElementEnv.Destroy;
begin
  FBitmap.Free;
  inherited Destroy;
end;

procedure TDrawElementEnv.Clear;
begin
  FillChar(ClipR, SizeOf(ClipR), 0);
  FillChar(CaretP, SizeOf(CaretP), 0);
  FillChar(Size, SizeOf(Size), 0);
  State:= [];
  // Element:= Nil;
end;

{****************************** TCustomWMLBrowser *****************************}

constructor TCustomWMLBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FVariables:= TWideStringList.Create;
  // FSrc:= PChar(EMPTY_WMLDOC);
  FSrc:= @EMPTY_WMLDOC;
  FStripHTTPHeader:= False;
  FParseMessages:= TStringList.Create;
  FxmlParser:= TxmlParser.Create;
  FWMLCollection:= TxmlElementCollection.Create(TWMLContainer, Nil, wciOne);
  with FWMLCollection.Add.DrawProperties.TagXYStart do begin
    x:= 0;
    y:= 1;
  end;
  FCurrentCard:= Nil;
  FCurMouseElement:= Nil;  // mouse points to this element
  FCurMouseLinkElement:= Nil;

  FOnDrawElementStart:= Nil;
  FOnDrawElementFinish:= Nil;

  FViewOptions:= [];
  // The control can be copied using the PaintTo method to draw its image to an arbitrary canvas.
  // The control can display an image from an image list when the control is dragged over. Use this setting if your control correctly handles an image list being dragged over it.
  ControlStyle:= ControlStyle + [csReplicatable, csDisplayDragImage];
  Left:= 0;
  Top:= 0;
  Width:= 100;
  Height:= 100;
  TabStop:= True;
  ParentColor:= False;
  Color:= clNone;
  Font.Name:= DEF_FONT_FAMILY;
  Font.Color:= clWindowText;
  Font.Size:= 10;
  // Cursor:= crIBeam;
end;


function TCustomWMLBrowser.GetVar(AName: WideString): WideString;
begin
  Result:= FVariables.Values[Name];
end;

procedure TCustomWMLBrowser.SetVar(AName, AValue: WideString);
begin
  FVariables.Values[Name]:= AValue;
end;

{ parse line and insert $var values.
  Parameters
    AMaskVar: MASK_VAR_ASIS MASK_VAR_ESCAPESINGLE_QUOTE MASK_VAR_UTF8
}
function TCustomWMLBrowser.GetVData(const ASrc: WideString): WideString; // ; AMaskVar: Integer
begin
  {
  if (AMaskVar and MASK_VAR_UTF8) > 0
  then Result:= UTF8Decode(ASrc)
  else Result:= '';
  if Length(Result) = 0
  then Result:= ASrc;
  }
  Result:= ASrc;
  if ExtractAndFillVars(Result, GetVariableValue, 0) > 0 then ;
end;

{ search variables in AxmlElement and replace variables. If no, remove it.
  Used by GetVData
  Parameters
    AEsc:
      escape        0
      unesc         1
      noesc         2
      + mask (start with $80)
  Returns
    Result:
      not found     False
      found         True
}
function TCustomWMLBrowser.GetVariableValue(const AVarName: String; AEsc: Integer; var AValue: WideString): Boolean;
var
  i: Integer;
  fldn,
  dsn: String;
  errs: WideString;
  Cont: Boolean;
  DataSetIdx,
  FieldIdx: Integer;
  xy: TPoint;
begin
  // look for predefined variable ready to replace
  i:= FVariables.IndexOfName(AVarName);
  if i >= 0 then begin
    AValue:= MkEscUnesc(AEsc, Copy(FVariables[i], Length(AVarName) + 2, MaxInt));
    Result:= True;
  end else begin
    Result:= True;
    AValue:= '';
  end;
end;

procedure TCustomWMLBrowser.ClearVariables;
begin
  FVariables.Clear;
end;

procedure TCustomWMLBrowser.SetOnDrawElementStart(AValue: TOnDrawElementEvent);
begin
  FOnDrawElementStart:= AValue;
end;

procedure TCustomWMLBrowser.SetOnDrawElementFinish(AValue: TOnDrawElementEvent);
begin
  FOnDrawElementFinish:= AValue;
end;

procedure TCustomWMLBrowser.CreateParams(var Params: TCreateParams);
var
  save: TFNWndProc;
begin
  inherited CreateParams(Params);
  save:= Params.WindowClass.lpfnWndProc;
  with Params do begin
    Style:= Style or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;
    ExStyle:= ExStyle or WS_EX_CLIENTEDGE;
    WindowClass.Style:= WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TCustomWMLBrowser.WndProc(var AMsg: TMessage);
var
  pt: TPoint;
begin
  case AMsg.Msg of
  WM_MOUSEMOVE: begin
      with TWMMouse(AMsg).Pos do begin
        pt.X:= x;
        pt.Y:= y;
      end;
      FCurMouseElement:= GetElementByCoord(pt);
      if Assigned(FCurMouseElement) then begin
        FCurMouseLinkElement:= FCurMouseElement.ParentByClass[TwmlA, TwmlCard];
        if Assigned(FCurMouseLinkElement)
        then Cursor:= crHandPoint  // there is only crHandPoint has no shadow. I don'know why
        else Cursor:= crDefault;
      end;
// Keys:
// MK_CONTROL	The Control key is down.
// MK_LBUTTON	The left mouse button is down.
// MK_MBUTTON	The middle mouse button is down.
// MK_RBUTTON	The right mouse button is down.
// MK_SHIFT
    end;
  end;
  inherited WndProc(AMsg);
end;

destructor TCustomWMLBrowser.Destroy;
begin
  FWMLCollection.Free;
  FxmlParser.Free;
  FParseMessages.Free;
  FVariables.Free;
  inherited Destroy;
end;

function LoadImageFN2Bitmap(const AUrl: WideString; ABitmap: TBitmap): Boolean;
var
  g: TImage;
begin
  Result:= False;
  try
    g:= TImage.Create(Nil);
    g.Picture.LoadFromFile(AUrl);
    if g.Picture.Graphic is TGifImage
    then ABitmap:= TGifImage(g.Picture).Bitmap
    else ABitmap.Assign(g.Picture.Bitmap);
    Result:= True;
  finally
    g.Free;
  end;
end;

function TCustomWMLBrowser.LoadImageBitmap(const AUrl: WideString; ABitmap: TBitmap; var ASize: TPoint; ANoImgSize: Boolean): Boolean;
begin
  Result:= LoadImageFN2Bitmap('C:\src\wml\bmp\ebook16.bmp', ABitmap);
  if ANoImgSize then begin
    ASize.X:= ABitmap.Width;
    ASize.Y:= ABitmap.Height;
  end else begin
    // Resize;
  end;
end;

{**************************** Draw implementation *****************************}

procedure TCustomWMLBrowser.ProcDrawStartElement(var AWMLElement: TxmlElement);
var
  ElementClass: TxmlElementClass;
begin
  FCurDrawElement:= AWMLElement;

  if Assigned(FOnDrawElementStart)
  then FOnDrawElementFinish(AWMLElement);

  ElementClass:= TxmlElementClass(AWMLElement.ClassType);

  if ElementClass = TWMLContainer
  then Exit; // do not draw wml because it haven't parent

  if (ElementClass = TWMLServerSide) or (ElementClass = TxmlComment) then begin
    AWMLElement.Free;
    AWMLElement:= Nil;
  end;

  if (ElementClass = TWMLP) or (ElementClass = TWMLBr)
  then DrawLineBreaks;
  if (AWMLElement is TWML_Emph)
  then DrawTextLayout;
  if ElementClass = TWMLCard
  then DrawCard;
  if ElementClass = TWMLPCData
  then DrawPCData;
  if ElementClass = TWMLImg
  then DrawImg;
  if ElementClass = TWMLSetvar
  then DoSetVar;
  if ElementClass = TWMLInput
  then DrawInput;
  if ElementClass = TWMLSelect
  then DrawSelect;
  if ElementClass = TWMLOption
  then DrawOption;

  if ElementClass = TWMLA
  then DrawA;
end;

procedure TCustomWMLBrowser.ProcDrawFinishElement(var AWMLElement: TxmlElement);
begin
  if Assigned(FOnDrawElementFinish)
  then FOnDrawElementFinish(AWMLElement);
end;

procedure TCustomWMLBrowser.DoSetVar;
begin
  with FCurDrawElement.Attributes do begin
    Variable[ValueByName['name']]:= ValueByName['value'];
  end;
end;

procedure TCustomWMLBrowser.Paint;
var
  e: Integer;
  el: TxmlElement;
  Aln: Cardinal;
begin
  if bvScreenSave in FViewOptions then begin
    // Inc(FDrawScreenSaveEnv.Tick);
    DrawScreenSave;
    if Assigned(FOnScreenSave)
    then FOnScreenSave(Self);
  end else begin
    // look for current card
    el:= CurrentCardEl;
    if Assigned(el) then with Canvas do begin
      el.ForEachInOut(ProcDrawStartElement, ProcDrawFinishElement);
    end;
    if Assigned(FOnPaint)
    then FOnPaint(Self);
  end;
end;

procedure TCustomWMLBrowser.ProcGetElementPosition(var AWmlElement: TxmlElement);
begin
  with AWmlElement.DrawProperties.elR do begin
    if (FCurPos.X >= Left) and (FCurPos.X <= Right) and (FCurPos.Y >= Top) and (FCurPos.Y <= Bottom) then begin
      if (Left >= FCurSearchElement.DrawProperties.elR.Left) and
        (FCurSearchElement.Level < AWMLElement.Level) then begin
        { (Right <= FCurSearchElement.DrawProperties.elR.Right) and
          (Top >= FCurSearchElement.DrawProperties.elR.Top) and
          (Bottom <= FCurSearchElement.DrawProperties.elR.Bottom)
        }
        FCurSearchElement:= AWMLElement;
      end;
    end;
  end;
end;

function TCustomWMLBrowser.GetElementByCoord(const ACoord: TPoint): TxmlElement;
var
  card: TxmlElement;
begin
  Result:= Nil;
  card:= CurrentCardEl;
  if not Assigned(card)
  then Exit;
  FCurPos:= ACoord;
  FCurSearchElement:= card;
  card.ForEachInOut(ProcGetElementPosition, Nil);
  Result:= FCurSearchElement;
end;

{ Selection properties implementation }

procedure TCustomWMLBrowser.WMKeyDown(var Message: TWMKeyDown);
begin
  with Message do begin
    case CharCode of
      VK_LEFT, VK_RIGHT, VK_DOWN, VK_UP, VK_HOME, VK_END, VK_PRIOR, VK_NEXT:;
    end; { case }
  end;
  inherited;
end;

procedure TCustomWMLBrowser.WMKeyUp(var Message: TWMKeyUp);
begin
  inherited;
end;

procedure TCustomWMLBrowser.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
end;

procedure TCustomWMLBrowser.Clear;
var
  strip: Boolean;
begin
  ClearVariables;
  FWMLCollection.Clear1;

  FParseMessages.Clear;

  strip:= FStripHTTPHeader; // keep FStripHTTPHeader value intact
  FStripHTTPHeader:= False;
//  FSrc:= PChar(EMPTY_WMLDOC);
  FStripHTTPHeader:= strip;

  Invalidate;
end;

function TCustomWMLBrowser.GetSrc: String;
begin
  // allways skip http header (before CRLF pair)
  Result:= FSrc^;
end;

procedure TCustomWMLBrowser.SetSrcPtr(ASrc: PWideString);
var
  st: Integer;
begin
  Clear;
  FSrc:= ASrc;
  Reload;
end;

procedure TCustomWMLBrowser.Resize;
begin
  // Width:= FDrawCurElementEnv.ClipR.Right + 1;
  // Height:= FDrawCurElementEnv.ClipR.Bottom + 1;
//  if Parent.ClientWidth > Width
//  then Width:= Parent.ClientWidth;
//  if Parent.ClientHeight > Height
//  then Height:= Parent.ClientHeight;

  Width:= Parent.ClientWidth;
  Height:= Parent.ClientHeight;
  Paint;
  inherited Resize;
end;

procedure TCustomWMLBrowser.Reload;
begin
  if ParseSource
  then;
  Resize;
end;

procedure TCustomWMLBrowser.ShowParseMessage(ALevel: TReportLevel; AxmlElement: TxmlElement;
  const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
  var AContinueParse: Boolean; AEnv: Pointer);
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
  FParseMessages.AddObject(Format('%s: (%d,%d): %s', [S, AWhere.y + 1, AWhere.x + 1, ADesc]), AxmlElement);
end;

procedure TCustomWMLBrowser.SetViewOptions(AValue: TBrowserViewOptions);
begin
  FViewOptions:= AValue;
  Repaint;
end;

function TCustomWMLBrowser.ParseSource: Boolean;
begin
  FParseMessages.Clear;
  with FxmlParser do begin
    { search header delimiter (pair of CRLF) }
    StripHTTPHeader:= FStripHTTPHeader;
    Text:= FSrc^;
    OnReport:= ShowParseMessage;
    FCurrentCard:= Nil;
    FWMLCollection.Clear1;
    Result:= Parse2xml(FWMLCollection.Items[0], Nil);
  end;
end;

function TCustomWMLBrowser.GetCurrentCardEl: TxmlElement;
begin
  Result:= FCurrentCard;
  if not Assigned(Result)
  then Result:= FWMLCollection[0].NestedElement[TWMLCard, 0];
end;

procedure TCustomWMLBrowser.SetCurrentCardEl(const AValue: TxmlElement);
begin
  FCurrentCard:= AValue;
end;

function TCustomWMLBrowser.GetCurrentCard: String;
begin
  if Assigned(FCurrentCard)
  then Result:= FCurrentCard.Attributes.ValueByName['id']
  else Result:= '';
end;

procedure TCustomWMLBrowser.SetCurrentCard(const AValue: String);
var
  e: Integer;
  el: TxmlElement;
  c: String;
begin
  FCurrentCard:= Nil;

  e:= Pos('#', AValue);
  if e > 0 then begin
    c:= Copy(AValue, e + 1, MaxInt);
  end else begin
    c:= AValue;
  end;
  if Length(c) = 0 then begin  //
    // first card
    FCurrentCard:= FWMLCollection[0].NestedElement[TWMLCard, 0];
  end else begin
    // look for card name
    for e:= 0 to FWMLCollection[0].NestedElementCount[TWMLCard] - 1 do begin
      el:= FWMLCollection[0].NestedElement[TWMLCard, e];
      if Assigned(el) then begin
        if CompareText(el.Attributes.ValueByName['id'], c) = 0 then begin
          FCurrentCard:= el;
          Break;
        end;
      end;
    end;
  end;
end;

end.
