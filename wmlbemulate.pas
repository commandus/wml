unit
  wmlbemulate;
(*##*)
(*******************************************************************
*                                                                 *
*   w  m  l  b  e  m  u  l  a  t  e                                *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   wireless markup language classes                              *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Nov 28 2001                                     *
*   Last fix     : Nov 28 2001                                    *
*   Lines        : 583                                             *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface
uses
  Classes, SysUtils, StrUtils, Types, Graphics, Controls,
  jclUnicode,
  customxml, wml, util_xml, xmlparse, wmleditutil;

type
  TWAPPlatform = (wpWAP1_1, wpopenwave3_0, wpopenwave3_03, wpopenwave3_1, wpopenwave4_1, wpNokia1_1);
  TWAPPlatforms = set of TWAPPlatform;

  TSoftButtonsStyle = Byte;
  TSoftButtonsPresentationStyle = Byte;

  TDeviceSupport = (dsBold, dsItalics, dsUnderline, dsStrong, dsEmphasis, dsBig, dsSmall,
    dsImages, dsLocalsrcimages, dsAccesskeys);

  TDeviceSupports = set of TDeviceSupport;

  TDeviceAcceptType = (mtWML, mtWMLS, mtWMLC, mtWBMP);
  TDeviceAcceptTypes = set of TDeviceAcceptType;

  TDispArea = class(TPersistent)
  private
    Fx0, Fy0, Fx1, Fy1: Integer;
    FBackColor: TColor;
    FFont: TFont;
    FAlign: TAlign;
    procedure SetFont(AValue: TFont);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property x0: Integer read Fx0 write Fx0;
    property y0: Integer read Fy0 write Fy0;
    property x1: Integer read Fx1 write Fx1;
    property y1: Integer read Fy1 write Fy1;
    property BackColor: TColor read FBackColor write FBackColor;
    property Font: TFont read FFont write SetFont;
    property Align: TAlign read FAlign write FAlign;
  end;

  TDisplayArea = class(TDispArea)
  private
    Fxofs, Fyofs: Integer;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
  published
    property xofs: Integer read Fxofs write Fxofs;
    property yofs: Integer read Fyofs write Fyofs;
  end;

  TWAPSoftButton = class(TCollectionItem)
  private
    FDisplayArea: TDisplayArea;
    procedure SetDisplayArea(AValue: TDisplayArea);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property DisplayArea: TDisplayArea read FDisplayArea write SetDisplayArea;
  end;

  TWAPSoftButtonClass = class of TWAPSoftButton;

  TWAPSoftButtons = class(TCollection)
  private
    FDisplayArea: TDispArea;
    FSoftButtonsStyle: TSoftButtonsStyle;
    FSoftButtonsPresentationStyle: TSoftButtonsPresentationStyle;
    function GetItem(Index: Integer): TWAPSoftButton;
    procedure SetItem(Index: Integer; Value: TWAPSoftButton);
    procedure SetSoftButtonsPresentationStyle(AValue: TSoftButtonsStyle);
    procedure SetSoftButtonsStyle(AValue: TSoftButtonsPresentationStyle);
    procedure SetDisplayArea(AValue: TDispArea);
  public
    constructor Create(AWAPSoftButtonClass: TCollectionItemClass);
    property Items[AIndex: Integer]: TWAPSoftButton read GetItem write SetItem; default;
    function Add: TWAPSoftButton;
    procedure Assign(Source: TPersistent); override;
  published
    property DisplayArea: TDispArea read FDisplayArea write SetDisplayArea;
    property SoftButtonsStyle: TSoftButtonsStyle read FSoftButtonsStyle write SetSoftButtonsStyle;
    property SoftButtonsPresentationStyle: TSoftButtonsPresentationStyle read FSoftButtonsPresentationStyle write SetSoftButtonsPresentationStyle;
  end;


  TWAPButton = class(TCollectionItem)
  private
    FComment: String;
    Fx0, Fy0, Fx1, Fy1: Integer;
    FValue: Char;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Comment: String read FComment write FComment;
    property x0: Integer read Fx0 write Fx0;
    property y0: Integer read Fy0 write Fy0;
    property x1: Integer read Fx1 write Fx1;
    property y1: Integer read Fy1 write Fy1;
    property Value: Char read FValue write FValue;
  end;

  TWAPButtonClass = class of TWAPButton;

  TWAPButtons = class(TCollection)
  private
    function GetItem(Index: Integer): TWAPButton;
    procedure SetItem(Index: Integer; Value: TWAPButton);
  public
    constructor Create(AWAPButtonClass: TCollectionItemClass);
    property Items[AIndex: Integer]: TWAPButton read GetItem write SetItem; default;
    procedure Assign(Source: TPersistent); override;
    function Add: TWAPButton;
  end;

  TCharacterProperty = class (TCollectionItem)
  private
    FValue: Integer;
    FComment: String;
    FWidth: Integer;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Comment: String read FComment write FComment;
    property Width: Integer read FWidth write FWidth;
    property CharValue: Integer read FValue write FValue;
  end;

  TCharacterPropertyClass = class of TCharacterProperty;

  TCharacterSet = class(TCollection)
  private
    FHeight: Integer;
    FWidth: Integer;
    FVariableWidth: Boolean;
    function GetItem(Index: Integer): TCharacterProperty;
    procedure SetItem(Index: Integer; Value: TCharacterProperty);
  public
    constructor Create(ACharacterPropertyClass: TCollectionItemClass);
    procedure Assign(Source: TPersistent); override;
    function Add: TCharacterProperty;
    property Items[AIndex: Integer]: TCharacterProperty read GetItem write SetItem; default;
  published
    property Height: Integer read FHeight write FHeight;
    property Width: Integer read FWidth write FWidth;
    property VariableWidth: Boolean read FVariableWidth write FVariableWidth;
  end;

  TWMLBEmulator = class(TControl)
  private
    FImgNormal,
    FImgOver,
    FImgPressed: String;
    FName: String;
    FPlatforms: TWAPPlatforms;
    FDisplay: TDisplayArea;
    FTitleBar: TDispArea;
    FBrowserArea: TDispArea;
    FSoftButtons: TWAPSoftButtons;
    FButtons: TWAPButtons;
    FCharacterSet: TCharacterSet;
    Fcxprefix: Integer;
    Fcyprefix: Integer;
    FHighlightMode: Integer;
    Fxdevicebrowser: Integer;
    FAnchorDelimiterLeft,
    FAnchorDelimiterRight: String;
    FDeviceSupports: TDeviceSupports;
    FDeviceAcceptTypes: TDeviceAcceptTypes;

    procedure SetDisplay(AValue: TDisplayArea);
    procedure SetTitleBar(AValue: TDispArea);
    procedure SetBrowserArea(AValue: TDispArea);
    procedure SetSoftButtons(AValue: TWAPSoftButtons);
    procedure SetButtons(AValue: TWAPButtons);
    procedure SetCharacterSet(AValue: TCharacterSet);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ImgNormal: String read FImgNormal write FImgNormal;
    property ImgOver: String read FImgOver write FImgOver;
    property ImgPressed: String read FImgPressed write FImgPressed;
    property Name: String read FName write FName;
    property Platforms: TWAPPlatforms read FPlatforms write FPlatforms;
    property cxprefix: Integer read Fcxprefix write Fcxprefix;
    property cyprefix: Integer read Fcyprefix write Fcyprefix;
    property HighlightMode: Integer read FHighlightMode write FHighlightMode;
    property xdevicebrowser: Integer read Fxdevicebrowser write Fxdevicebrowser;
    property DeviceSupports: TDeviceSupports read FDeviceSupports write FDeviceSupports;
    property DeviceAcceptTypes: TDeviceAcceptTypes read FDeviceAcceptTypes write FDeviceAcceptTypes;
    property Display: TDisplayArea read FDisplay write SetDisplay;
    property TitleBar: TDispArea read FTitleBar write SetTitleBar;
    property BrowserArea: TDispArea read FBrowserArea write SetBrowserArea;
    property SoftButtons: TWAPSoftButtons read FSoftButtons write SetSoftButtons;
    property Buttons: TWAPButtons read FButtons write SetButtons;
    property CharacterSet: TCharacterSet read FCharacterSet write SetCharacterSet;
    property AnchorDelimiterLeft: String read FAnchorDelimiterLeft write FAnchorDelimiterLeft;
    property AnchorDelimiterRight: String read FAnchorDelimiterRight write FAnchorDelimiterRight;
  end;

const

  DEFTWAPPLATFORMS = [wpWAP1_1, wpNokia1_1];
  DEFDEVICESUPPORTS = [dsBold, dsItalics, dsUnderline, dsStrong, dsEmphasis, dsBig, dsSmall,
    dsImages, dsLocalsrcimages, dsAccesskeys];
  DEFDEVICEACCEPTTYPES = [mtWML, mtWMLS, mtWMLC, mtWBMP];
  DEFFSOFTBUTTONSSTYLE = 0;
  DEFSOFTBUTTONSPRESENTATIONSTYLE = 0;

implementation

// --------- TWAPButton ---------

constructor TWAPButton.Create(ACollection: TCollection);
begin
  Comment:= '';
  Fx0:= 0;
  Fy0:= 0;
  Fx1:= 0;
  Fy1:= 0;
  FValue:= #0;
  inherited Create(ACollection);
end;

destructor TWAPButton.Destroy;
begin
  inherited Destroy;
end;

procedure TWAPButton.Assign(Source: TPersistent);
begin
  if Source <> nil then begin
    if Source is TDisplayArea then with TDisplayArea(Source) do begin
      Self.Comment:= Comment;
      Self.Fx0:= Fx0;
      Self.Fy0:= Fy0;
      Self.Fx1:= Fx1;
      Self.Fy1:= Fy1;
      Self.FValue:= FValue;
    end;
    inherited Assign(Source);
  end;
end;

// --------- TWAPButtons ---------

function TWAPButtons.GetItem(Index: Integer): TWAPButton;
begin
  Result:= TWAPButton(inherited GetItem(Index));
end;

procedure TWAPButtons.SetItem(Index: Integer; Value: TWAPButton);
begin
  inherited SetItem(Index, Value);
end;

function TWAPButtons.Add: TWAPButton;
begin
  Result:= TWAPButton(inherited Add);
end;

constructor TWAPButtons.Create(AWAPButtonClass: TCollectionItemClass);
begin
  inherited Create(AWAPButtonClass);
end;

procedure TWAPButtons.Assign(Source: TPersistent);
begin
  if Source <> nil then begin
    if Source is TWAPButtons then with TWAPButtons(Source) do begin
    end;
    inherited Assign(Source);
  end;
end;

// --------- TWAPSoftButton ---------

constructor TWAPSoftButton.Create(ACollection: TCollection);
begin
  FDisplayArea:= TDisplayArea.Create;
  inherited Create(ACollection);
end;

destructor TWAPSoftButton.Destroy;
begin
  FDisplayArea.Free;
  inherited Destroy;
end;

procedure TWAPSoftButton.Assign(Source: TPersistent);
begin
  if Source <> nil then begin
    if Source is TWAPSoftButton then with TWAPSoftButton(Source) do begin
      Self.FDisplayArea:= FDisplayArea;
    end;
    inherited Assign(Source);
  end;
end;

procedure TWAPSoftButton.SetDisplayArea(AValue: TDisplayArea);
begin
  FDisplayArea:= AValue;
end;

// --------- TWAPSoftButtons ---------

function TWAPSoftButtons.GetItem(Index: Integer): TWAPSoftButton;
begin
  Result:= TWAPSoftButton(inherited GetItem(Index));
end;

procedure TWAPSoftButtons.SetItem(Index: Integer; Value: TWAPSoftButton);
begin
  inherited SetItem(Index, Value);
end;

procedure TWAPSoftButtons.SetDisplayArea(AValue: TDispArea);
begin
  FDisplayArea.Assign(AValue);
end;

function TWAPSoftButtons.Add: TWAPSoftButton;
begin
  Result:= TWAPSoftButton(inherited Add);
end;

constructor TWAPSoftButtons.Create(AWAPSoftButtonClass: TCollectionItemClass);
begin
  FDisplayArea:= TDispArea.Create;
  FSoftButtonsStyle:= DEFFSOFTBUTTONSSTYLE;
  FSoftButtonsPresentationStyle:= DEFSOFTBUTTONSPRESENTATIONSTYLE;
  inherited Create(AWAPSoftButtonClass);
end;

procedure TWAPSoftButtons.Assign(Source: TPersistent);
begin
  if Source <> nil then begin
    if Source is TWAPSoftButtons then with TWAPSoftButtons(Source) do begin
      Self.FDisplayArea.Assign(FDisplayArea);
      Self.FSoftButtonsStyle:= FSoftButtonsStyle;
      Self.FSoftButtonsPresentationStyle:= FSoftButtonsPresentationStyle;
    end;
    inherited Assign(Source);
  end;
end;

procedure TWAPSoftButtons.SetSoftButtonsPresentationStyle(AValue: TSoftButtonsStyle);
begin
  FSoftButtonsPresentationStyle:= AValue;
end;

procedure TWAPSoftButtons.SetSoftButtonsStyle(AValue: TSoftButtonsPresentationStyle);
begin
  FSoftButtonsStyle:= AValue;
end;

// --------- TCharacterProperty ---------

constructor TCharacterProperty.Create(ACollection: TCollection);
begin
  FValue:= 0;
  FComment:= '';
  FWidth:= 0;
  inherited Create(ACollection);
end;

destructor TCharacterProperty.Destroy;
begin
  inherited Destroy;
end;

procedure TCharacterProperty.Assign(Source: TPersistent);
begin
  if Source <> nil then begin
    if Source is TCharacterProperty then with TCharacterProperty(Source) do begin
      Self.FValue:= FValue;
      Self.FComment:= FComment;
      Self.FWidth:= FWidth;
    end;
    inherited Assign(Source);
  end;
end;

// --------- TCharacterSet ---------

function TCharacterSet.GetItem(Index: Integer): TCharacterProperty;
begin
  Result:= TCharacterProperty(inherited GetItem(Index));
end;

procedure TCharacterSet.SetItem(Index: Integer; Value: TCharacterProperty);
begin
  inherited SetItem(Index, Value);
end;

function TCharacterSet.Add: TCharacterProperty;
begin
  Result:= TCharacterProperty(inherited Add);
end;

constructor TCharacterSet.Create(ACharacterPropertyClass: TCollectionItemClass);
begin
  FHeight:= 0;
  FWidth:= 0;
  FVariableWidth:= False;
  inherited Create(ACharacterPropertyClass);
end;

procedure TCharacterSet.Assign(Source: TPersistent);
begin
  if Source <> nil then begin
    if Source is TCharacterSet then with TCharacterSet(Source) do begin
      Self.FHeight:= FHeight;
      Self.FWidth:= FWidth;
      Self.FVariableWidth:= FVariableWidth;
    end;
    inherited Assign(Source);
  end;
end;

// --------- TDispArea ---------

constructor TDispArea.Create;
begin
  inherited Create;
  Fx0:= 0;
  Fy0:= 0;
  Fx1:= 0;
  Fy1:= 0;
  FBackColor:= clBlack;
  FFont:= TFont.Create;
  FAlign:= alLeft;
end;

procedure TDispArea.Assign(Source: TPersistent);
begin
  if Source <> nil then begin
    if Source is TDispArea then with TDispArea(Source) do begin
      Self.Fx0:= Fx0;
      Self.Fy0:= Fy0;
      Self.Fx1:= Fx1;
      Self.Fy1:= Fy1;
      Self.FBackColor:= FBackColor;
      Self.FFont.Assign(FFont);
      Self.FAlign:= FAlign;
    end;
    inherited Assign(Source);
  end;
end;

destructor TDispArea.Destroy;
begin
  Font.Free;
  inherited Destroy;
end;

procedure TDispArea.SetFont(AValue: TFont);
begin
  FFont.Assign(AValue);
end;

// --------- TDisplayArea ---------

constructor TDisplayArea.Create;
begin
  inherited Create;
  Fxofs:= 0;
  Fyofs:= 0;
end;

procedure TDisplayArea.Assign(Source: TPersistent);
begin
  if Source <> nil then begin
    if Source is TDisplayArea then with TDisplayArea(Source) do begin
      Self.Fxofs:= Fxofs;
      Self.Fyofs:= Fyofs;
    end;
    inherited Assign(Source);
  end;
end;

// --------- TWMLBEmulator ---------

constructor TWMLBEmulator.Create(AOwner: TComponent);
begin

  FName:= '';
  FImgNormal:= '';
  FImgOver:= '';
  FImgPressed:= '';

  FPlatforms:= DEFTWAPPLATFORMS;
  FDisplay:= TDisplayArea.Create;
  FTitleBar:= TDispArea.Create;
  FBrowserArea:= TDispArea.Create;
  FSoftButtons:= TWAPSoftButtons.Create(TWAPSoftButton);
  FButtons:= TWAPButtons.Create(TWAPButton);
  FCharacterSet:= TCharacterSet.Create(TCharacterProperty);

  Fcxprefix:= 0;
  Fcyprefix:= 0;
  FHighlightMode:= 0;
  Fxdevicebrowser:= 0;

  FDeviceSupports:= DEFDEVICESUPPORTS;
  FDeviceAcceptTypes:= DEFDEVICEACCEPTTYPES;
  FAnchorDelimiterLeft:= '';
  FAnchorDelimiterRight:= '';

  inherited Create(AOwner);
end;

destructor TWMLBEmulator.Destroy;
begin
  FCharacterSet.Free;
  FButtons.Free;
  FSoftButtons.Free;
  FBrowserArea.Free;
  FTitleBar.Free;
  FDisplay.Free;
  inherited Destroy;
end;

procedure TWMLBEmulator.SetDisplay(AValue: TDisplayArea);
begin
  FDisplay.Assign(AValue);
end;

procedure TWMLBEmulator.SetTitleBar(AValue: TDispArea);
begin
  FTitleBar.Assign(AValue);
end;

procedure TWMLBEmulator.SetBrowserArea(AValue: TDispArea);
begin
  FBrowserArea.Assign(AValue);
end;

procedure TWMLBEmulator.SetSoftButtons(AValue: TWAPSoftButtons);
begin
  FSoftButtons.Assign(AValue);
end;

procedure TWMLBEmulator.SetButtons(AValue: TWAPButtons);
begin
  FButtons.Assign(AValue);
end;

procedure TWMLBEmulator.SetCharacterSet(AValue: TCharacterSet);
begin
  FCharacterSet.Assign(AValue);
end;

end.
