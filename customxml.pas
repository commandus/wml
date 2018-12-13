unit
  customxml;
(*##*)
(*******************************************************************************
*                                                                             *
*   c  u  s  t  o  m  x  m  l                                                  *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language classes                                          *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Oct 20 2002                                                 *
*   Oct 04 2004 New properties:                                               *
*   Level                                                                      *
*   ParentByClass                                                             *
*                                                                              *
*                                                                             *
*   Last fix     : Oct 27 2002                                                *
*   Lines        : 2019                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Classes, SysUtils, Windows;

const
  LINESEPARATOR = #13#10;
  REQUIRED  = True;
  IMPLIED   = False;
  NODEFAULT = '';
  NOLIST    = '';
  DEFAULTXMLENCODING = 'utf-8';
  DEFAULTXMLVERSION = '1.0';
  DEFAULTWMLVERSION = '1.1';
  DEFAULT_TEXTALIGNMENT = taLeftJustify;
  DEFAULTACCEPTCHARSET = 'unknown';
  DEFAULTENCTYPE = 'application/x-wwwform-urlencoded';

var
  TextRightEdgeCol: Integer = 80;  // 0, -1 are special values means no right edge. -1 - do not wrap long text to the separate lines

type
  TVersion = String;

  TXMLCapabilities = set of (wcServerExtensions);

  TXMLEnv = record
    XMLCapabilities: TXMLCapabilities;
    dbParsing: Integer;
  end;

  TFormatText = (ftCompressSpaces, ftAsIs); // ftAsIs - do not create CRLF pair after element

  TFormatTextSet = set of TFormatText;
var
  // variables controls how wml elements works
  XMLENV: TXMLEnv = (XMLCapabilities: [wcServerExtensions]; dbParsing: 0);
  BlockIndent: Integer = 2;

type
  TSizeMeasure = (smNone, smUnit, smPixel, smPercent, smPoint,
    smInch, smCM, smMM, smPica, smEX, smEM);


  // TPoint: y: 1..N - position in line; x: 0..N - line number
  TDrawProperties = packed record
    TagXYStart: TPoint;            // «<»tag> ... </tag>
    TagXYFinish: TPoint;           // <tag«>» ... </tag>
    TagXYTerminatorStart: TPoint;  // <tag> ...«<»/tag>
    TagXYTerminatorFinish: TPoint; // <tag> ...</tag«>»
    elR: TRect; // start and end point of element coordinates
    // Added Jan 2005 for text selection coordinates
    elRM: TRect; // leftmost, rightmost, topmost and bottom coordinates 
  end;

  TEmphasis = (emEm, emStrong, emB, EmI, EmU, EmBig, EmSmall);
  TEmphasisis = set of TEmphasis;

  // forward class declarations
  TxmlContainer = class;
  TxmlElement = class;
  TxmlNestedElements = class;
  TxmlElementCollection = class;
  TxmlAttributeClass = class of TxmlAttribute;
  TxmlElementClass = class of TxmlElement;

  TEditableDoc = (edUNKNOWN, edDefault, edSame, edText, edWML, edWMLTemplate, edWMLCompiled,
    edHTML, edCSS, edOEB, edPKG, edXHTML, edTaxon, edSMIT, edHHC, edHHK, edRTC, edgenXML);

  // dynamic array - list of element classes
  TxmlElementClassArray = array [0..$10000] of TxmlElementClass;
  PxmlElementClassArray = ^TxmlElementClassArray;

  TGetDocumentTitleFunc = function (const ASrc: WideString): String;

  TxmlClassDesc = record
    ofs: Integer;
    len: Integer;
    classes: PxmlElementClassArray;
    DocType: TEditableDoc;
    OnDocumentTitle: TGetDocumentTitleFunc;

    xmlElementClass: TxmlElementClass;
    xmlPCDataClass: TxmlElementClass;
    DocDescClass: TxmlElementClass;

    deficon: Integer;
    defaultextension: String[7];
    desc: ShortString;
    extensionlist: ShortString;  // '|' delimited (w/o dots: '.')
  end;

  TxmlCollectionQtyLimit = (wciAny, wciOneOrNone, wciOne, wciOneOrMore);
  TxmlElementOption = (elNormal, elField, elEmph, elVisible, elTask, elFlow);

  // attribute types
  TAttrType = (atVData, atCData, atNumber, atHref, atLength, atNMToken,
    atID, atList, atNoStrictList, atLang, atColor,
    atIDREF, atIDREFS);

  // ForEachElement callback procedure
  // if AxmlElement deleted, set to Nil
  TForEachProc = procedure (var AxmlElement: TxmlElement) of object;

  // attribute class
  TxmlAttribute = class (TCollectionItem)
  private
    FName: String;  // String[15];
    FRequired: Boolean;
    FAttrType: TAttrType;
    FList: TStringList;
    FDefaultValue: String; // default value is in en-us, so no wide string is required
    FValue: WideString;
  protected
    procedure SetList(AListStr: String);
    function GetList: String;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Name: String read FName write FName;
    property Required: Boolean read FRequired write FRequired;
    property AttrType: TAttrType read FAttrType write FAttrType;
    property List: TStringList read FList write FList;
    property DefaultValue: String read FDefaultValue write FDefaultValue;
    property Value: WideString read FValue write FValue;
    function IsValuable: Boolean;
  end;

  // attribute collection
  TxmlAttributes = class(TCollection)
  private
    function GetItem(Index: Integer): TxmlAttribute;
    procedure SetItem(Index: Integer; Value: TxmlAttribute);
    function GetItemByName(AAttributeName: String): TxmlAttribute;
    procedure SetItemByName(AAttributeName: String; AValue: TxmlAttribute);
    function GetItemValueByName(AAttributeName: String): WideString;
    procedure SetItemValueByName(AAttributeName: String; AValue: WideString);
    function GetItemValueByNameEntity(AAttributeName: String): WideString;
    procedure SetItemValueByNameEntity(AAttributeName: String; AValue: WideString);
  protected
    // return count of attributes with value is not null
    function GetCountValuable: Integer;
    // return count of attributes with value is not null and has value is not default
    function GetCountValuableNoDefault: Integer;
  public
    constructor Create(AWMLAttributeClass: TxmlAttributeClass);
    function AddAttribute(AName: String; AAttrType: TAttrType;
      ARequired: Boolean; const ADefaultValue: String;
        AList: String; const AValue: WideString = ''): TxmlAttribute; dynamic;
    function IndexOf(const AName: String): Integer; virtual;
    procedure Clear;
    procedure Assign(Source: TPersistent); override;
    property Items[AIndex: Integer]: TxmlAttribute read GetItem write SetItem; default;
    property ItemByName[AName: String]: TxmlAttribute read GetItemByName write SetItemByName;
    property ValueByName[AName: String]: WideString read GetItemValueByName write SetItemValueByName;
    // try to replace named entity characters similar to  // WMLExtractEntityStr
    property ValueByNameEntity[AName: String]: WideString read GetItemValueByNameEntity write SetItemValueByNameEntity;
    // count of attributes with value is not null
    property CountValuable: Integer read GetCountValuable;
    // count of attributes with value is not null and has value is not default
    property CountValuableNoDefault: Integer read GetCountValuableNoDefault;
  end;

// --------- WML element class definition  ---------
  TSearchElementEnv = record
    seClass: TxmlElementClass;
    seOrder: Integer;
    seFoundElement: TxmlElement;
  end;

  TxmlElement = class(TCollectionItem)
  private
  protected
    FBinCode: Byte;  // wmlc element code in range $1C..$3F
    FOrder: Integer;
    // FRootElement: TxmlElement; instead FRootElement used GetParentRoot method
    FParentElement: TxmlElement;
    FAbstract: Boolean;
    FOption: TxmlElementOption;
    FNestedElements: TxmlNestedElements;
    FAttributes: TxmlAttributes;

    ForEachElementIteration: Integer; // can be used by callbacks.
    FSearchElementEnv: TSearchElementEnv;
    function GetName: String; virtual;
    procedure SetName(AValue: String); virtual;
    // used by GetNestedElement
    procedure CallbackGetNestedElement(var AxmlElement: TxmlElement);
    // used by GetNestedDescendantElement
    procedure CallbackGetNestedDescendantElement(var AAncestorElement: TxmlElement);

    procedure CallbackGetNestedElementCount(var AxmlElement: TxmlElement);

    // return nil if not found requested class or order is out of range
    function GetNestedElement(AClass: TxmlElementClass; AOrder: Integer): TxmlElement;

    function GetNestedElementAttribute(AClass: TxmlElementClass; AOrder: Integer; const AAttribute: String): WideString;
    procedure SetNestedElementAttribute(AClass: TxmlElementClass; AOrder: Integer; const AAttribute: String; AValue: WideString);
    function GetNestedElementText(AClass: TxmlElementClass; AOrder: Integer): WideString;
    procedure SetNestedElementText(AClass: TxmlElementClass; AOrder: Integer; AValue: WideString);

    // return count of requested class
    function GetNestedElementCount(AClass: TxmlElementClass): Integer;
    // return nil if not found requested descendant to ancestor class or order is out of range
    function GetNestedDescendantElement(AClass: TxmlElementClass; AOrder: Integer): TxmlElement;

    // return root of elements tree
    function GetParentRoot: TxmlElement;
    // return level from root element (his Parent is Nil)
    function GetLevel: Integer; // 0 - root element, 1 - first nested element and so one

    // return parent wml element of specified type or Nil if does not exists
    function GetParentByClass(AWMLElementClass: TPersistentClass;
      AStopElementClass: TPersistentClass = Nil): TxmlElement;
    // deck properties access methods
    function GetXMLVersion: TVersion;
    function GetDTDVersion: TVersion;
    procedure SetDTDVersion(AVersion: TVersion);
    function GetXMLEncoding: String;

    procedure SetParentElement(AParentElement: TxmlElement);
    function ForEachElement(AxmlElement: TxmlElement; AProc: TForEachProc): Boolean; // Initialize ForEachElementIteration
    function  ForEachElementInOut(AxmlElement: TxmlElement; AProcIn: TForEachProc; AProcOut: TForEachProc): Boolean;
    function DoGetElementName: String; // use to call virtual method
  public
    DrawProperties: TDrawProperties;
    procedure GetPrevNextTagXY(var APrevPos, ANextPos: TPoint);
    class function GetElementName: String; virtual;
    class function IsElementByName(AName: String): Boolean; virtual;
    procedure Assign(Source: TPersistent); override;
    function IsValid: Boolean; dynamic;
    function IsEmpty: Boolean; dynamic;
    function CanInsertElement(AElementClass: TPersistentClass): Boolean; dynamic;
    function GetAttributeByName(AAttributeName: String): TxmlAttribute;
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    function ValidateLevel(var ALevel: Integer): String;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; virtual;
    procedure GetListHrefs(AListHrefs: TStrings);  // add list of HRefs to list. Objects points to attribute
    procedure Clear; virtual;
    function Copy: TxmlElement;
    procedure ForEach(AProc: TForEachProc);
    procedure ForEachInOut(AProcIn: TForEachProc; AProcOut: TForEachProc);

    property BinCode: Byte read FBinCode;
    property Order: Integer read FOrder write FOrder;
    property ParentElement: TxmlElement read FParentElement write SetParentElement;
    property Root: TxmlElement read GetParentRoot;
    // return level started with root (his Parent is Nil)
    property Level: Integer read GetLevel; // 0 - root element, 1 - first nested element and so one        // Oct 04 2004
    property ParentByClass [AElClass, AStopElClass: TPersistentClass]: TxmlElement read GetParentByClass;  // Oct 04 2004

    property ElementName: String read DoGetElementName;
    property Name: String read GetName write SetName;
    property Attributes: TxmlAttributes read FAttributes write FAttributes;
    property IsAbstract: Boolean read FAbstract write FAbstract;
    property Option: TxmlElementOption read FOption write FOption;
    // return global order number if element was found, else return -1
    function GetElementGlobalOrder(AxmlElement: TxmlElement): Integer;

    // return nested elements by name & order, count of nested elements 1 level
    property NestedElements: TxmlNestedElements read FNestedElements;
    function NestedElements1Count: Integer; 
    function GetNested1ElementByName(AElementName: String; var AClass: TPersistentClass): TxmlElement;
    function GetNested1ElementByOrder(AOrder: Integer; var AClass: TPersistentClass): TxmlElement;
    procedure SetNewOrder(AOrder: Integer);
    function FindByLocation(ALocation: TPoint): TxmlElement;
    // get ALL nested elements. If AWMLElementClass is TWMLContainer, return all elements
    property NestedElement[AWMLElementClass: TxmlElementClass; AOrder: Integer]: TxmlElement read GetNestedElement;
    property NestedElementCount[AWMLElementClass: TxmlElementClass]: Integer read GetNestedElementCount;
    // get/set attribute for nested element
    property NestedElementAttribute[AWMLElementClass: TxmlElementClass; AOrder: Integer; const AAttribute: String]: WideString read GetNestedElementAttribute write SetNestedElementAttribute;
    // get/set PCData descendant value
    property NestedElementText[AWMLElementClass: TxmlElementClass; AOrder: Integer]: WideString read GetNestedElementText write SetNestedElementText;
    // by ancestor class
    property NestedDescendantElement[AAncestorElementClass: TxmlElementClass; AOrder: Integer]: TxmlElement read GetNestedDescendantElement;
    property XMLVersion: TVersion read GetXMLVersion;
    property DTDVersion: TVersion read GetDTDVersion write SetDTDVersion;
    property XMLEncoding: String read GetXMLEncoding;
  end;

// --------- xml element collection definition  ---------

// TxmlElementCollection contains collection of 0, 1 or more elements of same type

  TxmlElementCollection = class(TCollection)
  private
    FParentElement: TxmlElement;  // on creation keep parent element, used by Add method
    FWMLCollectionQtyLimit: TxmlCollectionQtyLimit;
    function GetItem(Index: Integer): TxmlElement;
    procedure SetItem(Index: Integer; Value: TxmlElement);
    procedure InsertItem(Item: TCollectionItem);
    function GetElementName: String;  // get element name from ItemClass by calling class method ItemClass.GetElementName 
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    ItemClass: TxmlElementClass;  // read-only in parent class
    constructor Create(AWMLElementClass: TxmlElementClass; AParentElement: TxmlElement;
      AWMLCollectionQtyLimit: TxmlCollectionQtyLimit);
    procedure Clear1; // clear all except root
    procedure Assign(ASource: TPersistent); override;
    function Add: TxmlElement;
    function Insert(AIndex: Integer): TxmlElement;
    procedure ReOrder(AStartFrom: Integer);
    // function AddDescendant(ADescendantClass: TxmlElementClass; AElementName: String): TxmlElement;
    function IsValid: Boolean;
    property Items[Index: Integer]: TxmlElement read GetItem write SetItem; default;
    property ElementName: String read GetElementName;
    property QtyLimit: TxmlCollectionQtyLimit read FWMLCollectionQtyLimit;
  end;

  TxmlNestedElements = class(TList)
  private
    FParentElement: TxmlElement; // on creation keep parent element, used by AddNew method
    FCooperative: TxmlCollectionQtyLimit;
  protected
    function Get(Index: Integer): TxmlElementCollection;
    procedure Put(Index: Integer; Item: TxmlElementCollection);
    procedure SetCooperative(ACooperative: TxmlCollectionQtyLimit);
  public
    constructor Create(AParentElement: TxmlElement);
    function GetIndexByClass(AWMLElementClass: TPersistentClass): Integer;
    function GetByClass(AWMLElementClass: TPersistentClass): TxmlElementCollection;
    procedure Assign(ASource: TList);
    // function Add(AWMLElementCollection: TxmlElementCollection): Integer;
    function AddNew(AWMLElementClass: TxmlElementClass;
      AWMLCollectionQtyLimit: TxmlCollectionQtyLimit): Integer;
    procedure Delete(AIndex: Integer);
    procedure Clear; override;
    procedure ClearNestedElements;
    property Items[Index: Integer]: TxmlElementCollection read Get write Put; default;
    property Cooperative: TxmlCollectionQtyLimit read FCooperative write SetCooperative;
    function IsValid: Boolean;
  end;

// --------- xml elements implementation ---------

  TxmlContainer = class(TxmlElement)
  private
  protected
    function GetName: String; override;
  public
    class function GetElementName: String; override;
    function CanInsertElement(AElementClass: TPersistentClass): Boolean; override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
    constructor Create(ACollection: TCollection); override;
    // procedure CallbackCreateDTD(var AxmlElement: TxmlElement);
    function CreateDTD(AElement: TxmlElement; var AElementList: String): WideString;
  end;

  TxmlComment = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
    class function GetElementName: String; override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  TxmlssScript = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
    class function GetElementName: String; override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  // pcdata

  TxmlPCData = class(TxmlElement)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
    class function GetElementName: String; override;
    // return what aligmnment assigned in parent paragraph
    function TextAlignment: TAlignment; virtual; abstract;
    // return what wrapping mode set in parent paragraph
    function TextWrap: Boolean; virtual; abstract;
    // return context of TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall elements
    function TextEmphasisis: TEmphasisis; virtual; abstract;
  end;

  // server side

  TServerSide = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
    class function GetElementName: String; override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  TBracket = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
    class function GetElementName: String; override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  TXMLDesc = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
    class function GetElementName: String; override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  TDocDesc = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
    class function GetElementName: String; override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

function QuotesValue(const S: String): String;
function QuotesXMLValue(const S: String): String;

const
  NOBINCODE = 0;

function  GetAttrTypeDescription(AAttrType: TAttrType): String;

function GetElementQtyDescription(AQtyLimit: TxmlCollectionQtyLimit): String;

implementation

uses
  util_xml, util1;

function QuotesValue(const S: String): String;
begin
  Result:= '"' + util_xml.WMLEntityStr(S) + '"';
end;

function QuotesXMLValue(const S: String): String;
begin
  Result:= '"' + util_xml.XMLEntityStr(S) + '"';
end;

// --------- TxmlAttribute ---------

function TxmlAttribute.IsValuable: Boolean;
begin
  Result:= FRequired or (Length(FValue)>0);
end;

function TxmlAttribute.GetList: String;
var
  i, L: Integer;
begin
  Result:= '';
  if ((FAttrType = atList) or (FAttrType = atNOSTRICTLIST))
    and Assigned(FList) then begin
    for i:= 0 to FList.Count - 1 do begin
      Result:= Result + FList[i] + '|';
    end;
    L:= Length(Result);
    if (L > 0) // and (Result[L]) = '|'
    then Delete(Result, L, 1);  // delete last '|'
  end;
end;

procedure TxmlAttribute.SetList(AListStr: String);
var
  p, n: Integer;
  S: ShortString;
begin
  if (FAttrType = atList) or (FAttrType = atNOSTRICTLIST) then begin
    if Assigned(FList)
    then FList.Free;
    FList:= TStringList.Create;
    p:= 1;
    repeat
      n:= Pos('|', AListStr);
      if n <= 0 then begin
        n:= Length(AListStr) + 1;
      end;
      S:= Copy(AListStr, p, n - p);
      if Length(S) = 0
      then Break;
      FList.AddObject(S, Nil);
      Delete(AListStr, 1, n);
    until False;
  end;
end;

constructor TxmlAttribute.Create(ACollection: TCollection);
begin
  FName:= '';
  FRequired:= False;
  FAttrType:= atVData;
  FList:= Nil;
  FDefaultValue:= '';
  FValue:= '';
  inherited Create(ACollection);
end;

destructor TxmlAttribute.Destroy;
begin
  if Assigned(FList)
  then FList.Free;
  inherited Destroy;
end;

procedure TxmlAttribute.Assign(Source: TPersistent);
begin
  if Source is TxmlAttribute then with TxmlAttribute(Source) do begin
    Self.FName:= FName;
    Self.FRequired:= FRequired;
    Self.FAttrType:= FAttrType;
    if Assigned(Self.FList)
    then Self.FList.Assign(FList)
    else begin
      if Assigned(FList) then begin
        Self.FList:= TStringList.Create;
        Self.FList.Assign(FList);
      end;
    end;
    Self.FDefaultValue:= FDefaultValue;
    Self.FValue:= FValue;
  end;
end;

// --------- TxmlAttributes ---------

function TxmlAttributes.GetItem(Index: Integer): TxmlAttribute;
begin
  Result:= TxmlAttribute(inherited GetItem(Index));
end;

procedure TxmlAttributes.SetItem(Index: Integer; Value: TxmlAttribute);
var
  i: Integer;
begin
  // ?!!
  if Index >= Self.Count then begin
    for i:= Self.Count to Index do begin
      Self.Add;
    end;
  end;
  inherited SetItem(Index, Value);
end;

function TxmlAttributes.GetItemByName(AAttributeName: String): TxmlAttribute;
var
  idx: Integer;
begin
  idx:= IndexOf(AAttributeName);
  if idx < 0
  then Result:= Nil
  else Result:= Items[idx];
end;

procedure TxmlAttributes.SetItemByName(AAttributeName: String; AValue: TxmlAttribute);
var
  idx: Integer;
begin
  idx:= IndexOf(AAttributeName);
  if idx >= 0
  then Items[idx].Assign(AValue);
end;

function TxmlAttributes.GetItemValueByName(AAttributeName: String): WideString;
var
  idx: Integer;
begin
  idx:= IndexOf(AAttributeName);
  if idx < 0
  then Result:= '' else begin
    Result:= Items[idx].FValue;
    if Length(Result) = 0
    then Result:= Items[idx].DefaultValue;
  end;
end;

procedure TxmlAttributes.SetItemValueByName(AAttributeName: String; AValue: WideString);
var
  idx: Integer;
begin
  idx:= IndexOf(AAttributeName);
  if idx >= 0
  then Items[idx].FValue:= AValue;
end;

// try to replace named entity characters similar to  // WMLExtractEntityStr
// find &#xxx; and replace to Unicode
function TxmlAttributes.GetItemValueByNameEntity(AAttributeName: String): WideString;
begin
  Result:= util_xml.WMLExtractEntityStr(GetItemValueByName(AAttributeName));
end;

// Unicode special characters and replace to &#xxx;
procedure TxmlAttributes.SetItemValueByNameEntity(AAttributeName: String; AValue: WideString);
begin
  SetItemValueByName(AAttributeName, util_xml.WMLEntityStr(AValue));
end;

// return count of attributes with value is not null
function TxmlAttributes.GetCountValuable: Integer;
var
  i: Integer;
begin
  Result:= 0;
  for i:= 0 to Count - 1 do begin
    if Length(Items[i].FValue) > 0
    then Inc(Result);
  end;
end;

// return count of attributes with value is not null and has value is not default
function TxmlAttributes.GetCountValuableNoDefault: Integer;
var
  i: Integer;
begin
  Result:= 0;
  for i:= 0 to Count - 1 do begin
    if (Length(Items[i].FValue) > 0) and (ANSICompareText(Items[i].FValue, Items[i].FDefaultValue) <> 0)
    then Inc(Result);
  end;
end;

constructor TxmlAttributes.Create(AWMLAttributeClass: TxmlAttributeClass);
begin
  inherited Create(AWMLAttributeClass);
end;

function TxmlAttributes.AddAttribute(AName: String; AAttrType: TAttrType; ARequired: Boolean;
  const ADefaultValue: String; AList: String; const AValue: WideString = ''): TxmlAttribute;
begin
  Result:= TxmlAttribute(inherited Add);
  Result.FName:= AName;
  Result.FAttrType:= AAttrType;
  Result.FRequired:= ARequired;
  Result.FDefaultValue:= ADefaultValue;
  Result.SetList(AList);
  Result.FValue:= AValue;
end;

function TxmlAttributes.IndexOf(const AName: String): Integer;
var
  p: Integer;
begin
  Result:= -1;
  for p:= 0 to Count - 1 do begin
    if (CompareText(AName, Items[p].FName) = 0) then begin
      Result:= p;
      Exit;
    end;
  end;
end;

procedure TxmlAttributes.Clear;
var
  p: Integer;
begin
  for p:= 0 to Count - 1 do begin
    Items[p].FValue:= '';
  end;
end;

procedure TxmlAttributes.Assign(Source: TPersistent);
var
  I, a, m: Integer;
begin
  if Source is TxmlAttributes then with TxmlAttributes(Source) do begin
    Self.BeginUpdate;
    try
      // Self.Clear;
      m:= Count;
      if Self.Count < m
      then m:= Self.Count;
      for I:= 0 to m - 1 do with Items[i] do begin
        // Self.AddAttribute(FName, FAttrType, FRequired, FDefaultValue, GetList, FValue);
        Self.Items[i].Assign(Items[i]);
      end;
    finally
      Self.EndUpdate;
    end;
  end else begin
    if Source is TStrings then begin
      BeginUpdate;
      try
        for I:= 0 to TStrings(Source).Count - 1 do begin
          a:= IndexOf(TStrings(Source).Names[i]);
          if a < 0
          then Continue;
          Items[a].Value:= Copy(TStrings(Source)[i], Pos('=', TStrings(Source)[i]) + 1, MaxInt);
        end;
      finally
        EndUpdate;
      end;
    end else begin
      inherited Assign(Source);
    end;
  end;
end;


// --------- TxmlElementCollection ---------

constructor TxmlElementCollection.Create(AWMLElementClass: TxmlElementClass;
  AParentElement: TxmlElement;
  AWMLCollectionQtyLimit: TxmlCollectionQtyLimit);
begin
  FParentElement:= AParentElement;
  { it is not necessary to supply wml version to all elements
  if Assigned(FParentElement) then begin
    FWMLVersion:= TxmlElementCollection(FParentElement.Collection).WMLVersion;
  end;
  }
  ItemClass:= AWMLElementClass; // == FItemClass for my Add implementation
  FWMLCollectionQtyLimit:= AWMLCollectionQtyLimit;
  inherited Create(AWMLElementClass);
  case FWMLCollectionQtyLimit of
  wciAny:
    begin
    end;
  wciOneOrNone:
    begin
    end;
  wciOne:
    begin
      // create one item
//      Add;
    end;
  wciOneOrMore:
    begin
      // create one item
//      Add;
    end;
  end; { case }
end;

procedure TxmlElementCollection.Clear1;
begin
  Clear;
  with Add.DrawProperties.TagXYStart do begin
    x:= 0;
    y:= 1;
  end;
end;

procedure TxmlElementCollection.ReOrder(AStartFrom: Integer);
var
  n, e, o: Integer;
  p: TxmlElement;
begin
  p:= FParentElement;
  for n:= 0 to p.FNestedElements.Count - 1 do begin
    for e:= 0 to p.FNestedElements[n].Count - 1 do begin
      o:= p.FNestedElements[n].Items[e].FOrder;
      // if order equil or greater than inserted element,
      if (o >= AStartFrom) then begin
        // move down
        p.FNestedElements[n].Items[e].FOrder:= o + 1;
      end;
    end;
  end;
end;

procedure TxmlElementCollection.Assign(ASource: TPersistent);
var
  i: Integer;
begin
  if ASource is TxmlElementCollection then with TxmlElementCollection(ASource) do begin
    // do not! Self.FParentElement:= FParentElement;
    Self.FWMLCollectionQtyLimit:= FWMLCollectionQtyLimit;
    Self.ItemClass:= ItemClass;

    Self.BeginUpdate;
    try
      Self.Clear;
      for i:= 0 to Count - 1 do begin
        Self.Add.Assign(Items[I]);
      end;
      // Re-order FOrder
      for i:= 0 to Count - 1 do begin
        Self.Items[i].FOrder:= Items[i].FOrder;
      end;
    finally
      Self.EndUpdate;
    end;
  end;
//  inherited Assign(ASource);
end;

function TxmlElementCollection.GetElementName: String;
begin
  Result:= ItemClass.GetElementName;
end;

function TxmlElementCollection.Insert(AIndex: Integer): TxmlElement;
var
  order: Integer;
begin
  if (AIndex < 0) or (AIndex >= Count) then begin
    Result:= Add;
  end else begin
    order:= Self.Items[Aindex].Order;
    // move elements (re-order) first
    ReOrder(order);
    // insert new element
    // inserted element added therefore SetParentElement assigns FOrder = last element
    Result:= TxmlElement(inherited Insert(AIndex));
    // set correct order to the inserted element
    Result.FOrder:= order;
  end;
end;

function TxmlElementCollection.Add: TxmlElement;
begin
  Result:= ItemClass.Create(Self); // do not call inherited Add
  Result.ParentElement:= FParentElement;
  { do not create text representaton and calc positions,
    imho it cause slow down performance
  // get element text representation
  s:= Result.CreateText(0, 2);
  // calc positions
  Result.GetPrevNextTagXY(pprev, pnext);
  // shift positions
  ShiftWMLElementTextPositions(e, s);
  }
end;

procedure TxmlElementCollection.InsertItem(Item: TCollectionItem);
begin
end;

function TxmlElementCollection.GetItem(Index: Integer): TxmlElement;
begin
  Result:= TxmlElement(inherited GetItem(Index));
end;

procedure TxmlElementCollection.SetItem(Index: Integer; Value: TxmlElement);
begin
  inherited SetItem(Index, Value);
end;

function TxmlElementCollection.GetOwner: TPersistent;
begin
  Result:= inherited GetOwner;
end;

procedure TxmlElementCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
end;

// called from TxmlNestedElements.IsValid
// call TxmlElement.IsValid
function TxmlElementCollection.IsValid: Boolean;
var
  i: Integer;
begin
  Result:= False;
  // check requred collection items qty
  case FWMLCollectionQtyLimit of
  wciAny:
    begin
      Result:= True;
    end;
  wciOneOrNone:
    begin
    end;
  wciOne:
    begin
      Result:= Self.Count = 1;
    end;
  wciOneOrMore:
    begin
      Result:= Self.Count > 0;
    end;
  end; { case }
  if Result then begin
    // check all items
    for i:= 0 to Self.Count - 1 do begin
      if not Self.Items[i].IsValid then begin
        Result:= False;
        Break;
      end;
    end;
  end;
end;

{
function TxmlElementCollection.AddDescendant(ADescendantClass: TxmlElementClass;
  AElementName: String): TxmlElement;
begin
  // add only descendant class
  Result:= TxmlElement(ADescendantClass.Create(Self));
end;
}


// --------- TxmlNestedElements ---------

constructor TxmlNestedElements.Create(AParentElement: TxmlElement);
begin
  inherited Create;
  FParentElement:= AParentElement;
  SetCooperative(wciAny);
end;

procedure TxmlNestedElements.Assign(ASource: TList);
var
  i: Integer;
begin
  if ASource is TxmlNestedElements then with TxmlNestedElements(ASource) do begin
    Self.Clear;
    // do not! Self.FParentElement:= FParentElement;
    Self.Cooperative:= FCooperative;
    Self.Capacity:= Capacity;
    for i:= 0 to Count - 1 do begin
      with Items[i]
      do Self.AddNew(ItemClass, QtyLimit);
      Self.Items[i].Assign(Items[i]);
    end;
  end else begin
    inherited Assign(ASource);
  end;
end;

function TxmlNestedElements.Get(Index: Integer): TxmlElementCollection;
begin
  if (Index > Self.Count) or (Index < 0)
  then Result:= Nil
  else Result:= TxmlElementCollection(inherited Get(Index));
end;

procedure TxmlNestedElements.Put(Index: Integer; Item: TxmlElementCollection);
begin
  inherited Put(Index, Item);
end;

procedure TxmlNestedElements.SetCooperative(ACooperative: TxmlCollectionQtyLimit);
var
  i: Integer;
begin
  FCooperative:= ACooperative;
  case FCooperative of
  wciOne: begin
    // Exclusive means that nested elements marked as wciOneOrNone
    for i:= 0 to Self.Count - 1 do begin
      Self.Items[0].FWMLCollectionQtyLimit:= wciOneOrNone;
    end;
  end;
  end; { case }
end;


{ search nested elements class of AWMLElementClass and return found class index
  return -1 if no items of required class was found
}
function TxmlNestedElements.GetIndexByClass(AWMLElementClass: TPersistentClass): Integer;
var
  c: Integer;
begin
  Result:= -1;
  for c:= 0 to Count - 1 do begin
    if Self.Get(c).ItemClass = AWMLElementClass then begin
      Result:= c;
      Break;
    end;
  end;
end;

{ search nested elements class of AWMLElementClass and return found class
  return Nil if no items of required class was found
}
function TxmlNestedElements.GetByClass(AWMLElementClass: TPersistentClass): TxmlElementCollection;
begin
  // Get method returns nil if GetIndexByClass returns -1
  Result:= Get(GetIndexByClass(AWMLElementClass));
end;

{
function TxmlNestedElements.Add(AWMLElementCollection: TxmlElementCollection): Integer;
begin
  Result:= inherited Add(AWMLElementCollection);
end;
}

function TxmlNestedElements.AddNew(AWMLElementClass: TxmlElementClass;
  AWMLCollectionQtyLimit: TxmlCollectionQtyLimit): Integer;
begin
  Result:= inherited Add(TxmlElementCollection.Create(AWMLElementClass,
    FParentElement, AWMLCollectionQtyLimit));
end;

procedure TxmlNestedElements.Delete(AIndex: Integer);
var
  ElementCollection: TxmlElementCollection;
begin
  ElementCollection:= Self.Get(AIndex);
  ElementCollection.Free;
  inherited Delete(AIndex);
end;

procedure TxmlNestedElements.Clear;
begin
  while Count > 0
  do Delete(0);
end;

procedure TxmlNestedElements.ClearNestedElements;
var
  i: Integer;
begin
  for i:= 0 to Count - 1 do begin
    Items[i].Clear
  end;
end;

// called from TxmlElement.IsValid
// call TxmlElementCollection.IsValid
function TxmlNestedElements.IsValid: Boolean;
var
  i: Integer;
begin
  Result:= True;
  for i:= 0 to Self.Count - 1 do begin
    if not Self.Items[i].IsValid then begin
      Result:= False;
      Break;
    end;
  end;
end;

// --------- TxmlElement ---------

function TxmlElement.DoGetElementName: String;
begin
  // call virtual class method
  Result:= GetElementName;
end;

// class function
class function TxmlElement.GetElementName: String;
begin
  Result:= LowerCase(System.Copy(ClassName, 5, MaxInt));
end;

// class function
class function TxmlElement.IsElementByName(AName: String): Boolean;
begin
  Result:= CompareText(AName, GetElementName) = 0;
end;

constructor TxmlElement.Create(ACollection: TCollection);
begin
//FBinCode:= 0;
  FOrder:= 0;
  FOption:=  elVisible;
  FAbstract:= False;
  inherited Create(ACollection);
  // set Order to last nested element of parent element in SetParentElement too
  if {Assigned(ACollection) and }(ACollection is TxmlElementCollection) then begin
    SetParentElement(TxmlElementCollection(ACollection).FParentElement);
  end else begin
    FParentElement:= Nil;
  end;
  // owned elements list
  FNestedElements:= TxmlNestedElements.Create(Self);
    // attribute collection
  FAttributes:= TxmlAttributes.Create(TxmlAttribute);
end;

function TxmlElement.Copy: TxmlElement;
var
  FCopyCollection: TxmlElementCollection;
begin
  // create new collections keeps new kind of ItemClass
  FCopyCollection:= TxmlElementCollection.Create(TxmlElementClass(ClassType), Nil,
    TxmlElementCollection(Self.Collection).FWMLCollectionQtyLimit);  // wciAny
  // just in case
  with FCopyCollection.Add.DrawProperties.TagXYStart do begin
    x:= 0;
    y:= 1;
  end;
  // assign all nested elements and assign correct attribute's values
  FCopyCollection.Items[0].Assign(Self);
  // test - s:= FCopyCollection.Items[0].CreateText(0, 2);
  Result:= FCopyCollection.Items[0];
end;

procedure TxmlElement.Assign(Source: TPersistent);
begin
  if Source is TxmlElement then with TxmlElement(Source) do begin
    Self.FBinCode:= FBinCode;
    // do not!
    // Self.FOrder:= FOrder;
    // do not! Self.SetParentElement(FParentElement);
    Self.FAbstract:= FAbstract;
    Self.FOption:= FOption;
    Self.FNestedElements.Assign(FNestedElements);
    Self.FAttributes.Assign(FAttributes);

    Self.ForEachElementIteration:= ForEachElementIteration;
    Self.FSearchElementEnv:= FSearchElementEnv;
    Self.DrawProperties:= DrawProperties;
  end else begin
    inherited Assign(Source);
  end;
end;


// return position between tage where element insertedDrawProperties.TagXYStart
// Result:
//   APrevPos points to '>' character.
//   ANextPos points to '<' character.
procedure TxmlElement.GetPrevNextTagXY(var APrevPos, ANextPos: TPoint);
var
  pc: TPersistentClass;
begin
  if Assigned(ParentElement) then begin
    // look for end of previous tag
    if Order = 0 then begin
      // it is first element
      APrevPos:= ParentElement.DrawProperties.TagXYFinish;
    end else begin
      // get position of previous tag
      APrevPos:= ParentElement.GetNested1ElementByOrder(Order - 1, pc).DrawProperties.TagXYTerminatorFinish;
    end;
    // look for start of next tag
    if Order = ParentElement.NestedElements1Count - 1 then begin
      // it is last element.
      ANextPos:= ParentElement.DrawProperties.TagXYTerminatorStart;
    end else begin
      // get position of followed tag
      ANextPos:= ParentElement.GetNested1ElementByOrder(Order + 1, pc).DrawProperties.TagXYStart;
    end;
  end else begin
    // default values in case of TxmlContainer
    APrevPos.x:= 0;
    APrevPos.y:= 1;
    ANextPos.x:= 0;
    ANextPos.y:= 1;
  end;
end;

// element name
function TxmlElement.GetName: String;
begin
  // try found id attribute
  Result:= Attributes.ValueByName['id'];
  // if id attribute is not set return element name + number
  if Length(Result) = 0
  then Result:= GetElementName + IntToStr(FOrder);// IntToStr(Self.ID);
end;

procedure TxmlElement.SetName(AValue: String);
begin
  Attributes.ValueByName['id']:= AValue;
end;

// called from TxmlElementCollection.IsValid
// call TxmlNestedElements.IsValid
function TxmlElement.IsValid: Boolean;
begin
  Result:= True;
  // validate is exclusive
  case FNestedElements.Cooperative of
  wciOne: begin
    if FNestedElements.Count <> 1
    then Exit;
  end;
  wciOneOrNone: begin
    if FNestedElements.Count > 1
    then Exit;
  end;
  wciOneOrMore: begin
    if FNestedElements.Count <= 0
    then Exit;
  end;
  end; { case }
  // check nested elements recursively
  Result:= FNestedElements.IsValid;
end;

function TxmlElement.IsEmpty: Boolean;
var
  cnt: Integer;
begin
  cnt:= FNestedElements.Count;
  Result:= (cnt <= 0);
{
  if wcServerExtensions in XMLENV.XMLCapabilities then
    Result:= (cnt <= 0)
  else
    Result:= (cnt <= 1);
}
  // FNestedElements.GetIndexByClass(TBracket) >= 0) removed because ThtmBracket <> TBracket
end;

function TxmlElement.GetNested1ElementByName(AElementName: String; var AClass: TPersistentClass): TxmlElement;
var
  n, e: Integer;
begin
  Result:= Nil;
  for n:= 0 to FNestedElements.Count - 1 do begin
    for e:= 0 to FNestedElements[n].Count - 1 do begin
      if CompareText(AElementName, FNestedElements[n].Items[e].Name) = 0 then begin
        Result:= FNestedElements[n].Items[e];
        AClass:= FNestedElements[n].ItemClass;
        Exit;
      end;
    end;
  end;
end;

function TxmlElement.GetNested1ElementByOrder(AOrder: Integer; var AClass: TPersistentClass): TxmlElement;
var
  n, e: Integer;
begin
  Result:= Nil;
  for n:= 0 to FNestedElements.Count - 1 do begin
    for e:= 0 to FNestedElements[n].Count - 1 do begin
      if FNestedElements[n].Items[e].FOrder = AOrder then begin
        Result:= FNestedElements[n].Items[e];
        AClass:= FNestedElements[n].ItemClass;
        Exit;
      end;
    end;
  end;
end;

procedure TxmlElement.SetNewOrder(AOrder: Integer);
var
  n, e: Integer;
  p: TxmlElement;
begin
  p:= FParentElement;
  if Assigned(p) then begin
    for n:= 0 to p.NestedElements.Count - 1 do begin
      for e:= 0 to p.FNestedElements[n].Count - 1 do begin
        if p.FNestedElements[n].Items[e].FOrder >= AOrder then begin
          Inc(p.FNestedElements[n].Items[e].FOrder);
        end;
      end;
    end;
  end;  
  FOrder:= AOrder;
end;

function TxmlElement.FindByLocation(ALocation: TPoint): TxmlElement;
var
  n, e: Integer;
begin
  Result:= Nil;
  for n:= 0 to FNestedElements.Count - 1 do begin
    for e:= 0 to FNestedElements[n].Count - 1 do begin
      with FNestedElements[n].Items[e].DrawProperties do begin
        if (ALocation.X >= TagXYStart.X) and
          (ALocation.X <= TagXYTerminatorFinish.X) and
          ((ALocation.Y >= TagXYStart.Y) or (ALocation.X > TagXYStart.X)) and
          ((ALocation.Y <= TagXYTerminatorFinish.Y) or (ALocation.X < TagXYStart.X))
        then begin
          Result:= FNestedElements[n].Items[e];
          Exit;
        end;
      end;
      Result:= FNestedElements[n].Items[e].FindByLocation(ALocation);
      if Assigned(Result) then begin
        Exit;
      end;
    end;
  end;
end;

function TxmlElement.GetAttributeByName(AAttributeName: String): TxmlAttribute;
var
  n: Integer;
begin
  Result:= Nil;
  for n:= 0 to Self.FAttributes.Count - 1 do begin
    if CompareText(AAttributeName, Self.FAttributes[n].FName) = 0 then begin
      Result:= Self.FAttributes[n];
      Exit;
    end;
  end;
end;

function TxmlElement.NestedElements1Count: Integer;
var
  n: Integer;
begin
  Result:= 0;
  for n:= 0 to FNestedElements.Count - 1 do begin
    Result:= Result + FNestedElements.Items[n].Count;
  end;
end;

procedure TxmlElement.Clear;
begin
  FNestedElements.ClearNestedElements;
  FAttributes.Clear;
end;

{ return root parent wml element (his Parent is Nil)
}
function TxmlElement.GetParentRoot: TxmlElement;
var
  p1: TxmlElement;
begin
  Result:= Self;
  repeat
    p1:= Result.ParentElement;
    if not Assigned(p1) then begin
      Exit;
    end;
    Result:= p1;
  until False;
end;

{ return level from root element (his Parent is Nil)
}
function TxmlElement.GetLevel: Integer; // 0 - root element, 1 - first nested element and so one
var
  p1: TxmlElement;
begin
  Result:= 0;
  p1:= Self;
  repeat
    p1:= p1.ParentElement;
    if not Assigned(p1) then begin
      Exit;
    end;
    Inc(Result);
  until False;
end;

{ return parent wml element of specified type
  return Nil if does not exists
}
function TxmlElement.GetParentByClass(AWMLElementClass: TPersistentClass;
  AStopElementClass: TPersistentClass = Nil): TxmlElement;
var
  p1: TxmlElement;
begin
  Result:= Self;
  repeat
    p1:= Result.ParentElement;
    // if no more parents or stop class found, return Nil
    if (not Assigned(p1)) or (p1 is AStopElementClass) then begin
      Result:= Nil;
      Exit;
    end;
    // check is class found
    if (p1 is AWMLElementClass) then begin
      Result:= p1;
      Exit;
    end;
    Result:= p1;
  until False;
end;

// deck properties access methods
function TxmlElement.GetXMLVersion: TVersion;
var
  e: TxmlElement;
begin
  Result:= '1.0';
  e:= Root;
  if not Assigned(e) then Exit;
  e:= e.NestedDescendantElement[TXMLDesc, 0];
  if not Assigned(e) then Exit;
  Result:= e.Attributes.ValueByName['version'];
end;

function TxmlElement.GetDTDVersion: TVersion;
var
  e: TxmlElement;
begin
  Result:= '1.0';
  e:= Root;
  if not Assigned(e) then Exit;
  e:= e.NestedDescendantElement[TDocDesc, 0];
  if not Assigned(e) then Exit;
  Result:= e.Attributes.ValueByName['version'];
end;

procedure TxmlElement.SetDTDVersion(AVersion: TVersion);
var
  e: TxmlElement;
begin
  e:= Root;
  if not Assigned(e)
  then Exit;
  e:= e.NestedElement[TDocDesc, 0];
  if not Assigned(e)
  then Exit;
  e.Attributes.ValueByName['version']:= AVersion;
end;

function TxmlElement.GetXMLEncoding: String;
var
  e: TxmlElement;
begin
  Result:= '';
  e:= Root;
  if not Assigned(e) then Exit;
  e:= e.NestedElement[TXMLDesc, 0];
  if not Assigned(e) then Exit;
  Result:= e.Attributes.ValueByName['encoding'];
end;

procedure TxmlElement.SetParentElement(AParentElement: TxmlElement);
begin
  FParentElement:= AParentElement;
  if Assigned(FParentElement) then begin
    FOrder:= FParentElement.NestedElements1Count - 1; // start from 0
  end;
end;

procedure TxmlElement.ForEach(AProc: TForEachProc);
begin
  ForEachElement(Self, AProc);
end;

function TxmlElement.ForEachElement(AxmlElement: TxmlElement; AProc: TForEachProc): Boolean;
var
  n: Integer;
  APClass: TPersistentClass;
begin
  AProc(AxmlElement);
  n:= 0;
  while n < AxmlElement.NestedElements1Count do begin
    if ForEachElement(AxmlElement.GetNested1ElementByOrder(n, APClass), AProc)
    then Inc(n);
  end;
  Result:= True;
end;

procedure TxmlElement.ForEachInOut(AProcIn: TForEachProc; AProcOut: TForEachProc);
begin
  ForEachElementIteration:= 0;
  ForEachElementInOut(Self, AProcIn, AProcOut);
end;

function  TxmlElement.ForEachElementInOut(AxmlElement: TxmlElement;
  AProcIn: TForEachProc; AProcOut: TForEachProc): Boolean;
var
  n: Integer;
  PersClass: TPersistentClass;
begin
  // if not Assigned(AxmlElement) then begin  Result:= True;  Exit; end;

  if Assigned(AProcIn)
  then AProcIn(AxmlElement);

  // check- AProcIn can delete element, in this case do not increment
  Result:= Assigned(AxmlElement);
  if not Result then Exit;

  n:= 0;
  // do not that! nc:= AxmlElement.NestedElements1Count; n < nc
  // because AProcIn can delete some elements
  while n < AxmlElement.NestedElements1Count do begin
    if ForEachElementInOut(AxmlElement.GetNested1ElementByOrder(n, PersClass), AProcIn, AProcOut)
    then Inc(n);
  end;
  if Assigned(AProcOut)
  then AProcOut(AxmlElement);
end;

// callback for GetNestedElement
procedure TxmlElement.CallbackGetNestedElement(var AxmlElement: TxmlElement);
begin
  if (AxmlElement.ClassType = FSearchElementEnv.seClass) or
    (FSearchElementEnv.seClass = TxmlContainer) then begin
    if FSearchElementEnv.seOrder = ForEachElementIteration then begin
      FSearchElementEnv.seFoundElement:= AxmlElement;
    end;
    Inc(ForEachElementIteration);
  end;
end;

// callback for GetNestedDescendantElement
procedure TxmlElement.CallbackGetNestedDescendantElement(var AAncestorElement: TxmlElement);
begin
  if (AAncestorElement is FSearchElementEnv.seClass) or
    (FSearchElementEnv.seClass = TxmlContainer) then begin
    if FSearchElementEnv.seOrder = ForEachElementIteration then begin
      FSearchElementEnv.seFoundElement:= AAncestorElement;
    end;
    Inc(ForEachElementIteration);
  end;
end;

procedure TxmlElement.CallbackGetNestedElementCount(var AxmlElement: TxmlElement);
begin
  if (AxmlElement.ClassType = FSearchElementEnv.seClass) or
    (FSearchElementEnv.seClass = TxmlContainer) then begin
    Inc(ForEachElementIteration);
  end;
end;

// return nil if not found requested class or order is out of range
function TxmlElement.GetNestedElement(AClass: TxmlElementClass; AOrder: Integer): TxmlElement;
begin
  with FSearchElementEnv do begin
    seClass:= AClass;
    seOrder:= AOrder;
    seFoundElement:= Nil;
    ForEachInOut(CallbackGetNestedElement, nil);
    Result:= seFoundElement;
  end;
end;

    // return nil if not found requested class or order is out of range
function TxmlElement.GetNestedElementAttribute(AClass: TxmlElementClass; AOrder: Integer; const AAttribute: String): WideString;
var
  e: TxmlElement;
begin
  e:= GetNestedElement(AClass, AOrder);
  if Assigned(e)
  then Result:= e.Attributes.ValueByName[AAttribute]
  else Result:= '';
end;

procedure TxmlElement.SetNestedElementAttribute(AClass: TxmlElementClass; AOrder: Integer; const AAttribute: String; AValue: WideString);
var
  e: TxmlElement;
begin
  e:= GetNestedElement(AClass, AOrder);
  if Assigned(e)
  then e.Attributes.ValueByName[AAttribute]:= AValue;
end;

function TxmlElement.GetNestedElementText(AClass: TxmlElementClass; AOrder: Integer): WideString;
var
  e: TxmlElement;
begin
  Result:= '';
  e:= GetNestedElement(AClass, AOrder);
  if Assigned(e)
  then e:= e.NestedDescendantElement[TxmlPCData, 0]
  else Exit;
  if not Assigned(e)
  then Exit;
  Result:= e.Attributes.ValueByName['value'];
end;

procedure TxmlElement.SetNestedElementText(AClass: TxmlElementClass; AOrder: Integer; AValue: WideString);
var
  e: TxmlElement;
begin
  e:= GetNestedElement(AClass, AOrder);
  if Assigned(e)
  then e:= e.NestedDescendantElement[TxmlPCData, 0]
  else Exit;
  if not Assigned(e)
  then Exit;
  e.Attributes.ValueByName['value']:= AValue;
end;

function TxmlElement.GetNestedDescendantElement(AClass: TxmlElementClass; AOrder: Integer): TxmlElement;
begin
  with FSearchElementEnv do begin
    seClass:= AClass;
    seOrder:= AOrder;
    seFoundElement:= Nil;
    ForEachInOut(CallbackGetNestedDescendantElement, nil);
    Result:= seFoundElement;
  end;
end;

// return count of requested class
function TxmlElement.GetNestedElementCount(AClass: TxmlElementClass): Integer;
begin
  FSearchElementEnv.seClass:= AClass;
  ForEachElementIteration:= 0;
  ForEachInOut(CallbackGetNestedElementCount, nil);
  Result:= ForEachElementIteration;
end;

// return global order number if element was found, else return -1
function TxmlElement.GetElementGlobalOrder(AxmlElement: TxmlElement): Integer;
var
  e: Integer;
begin
  Result:= -1;
  for e:= 0 to NestedElementCount[TxmlContainer] - 1 do begin
    if NestedElement[TxmlContainer, e] = AxmlElement then begin
      Result:= e;
      Exit;
    end;
  end;
end;

{ returns spaced string i.e. (see table below):
  ALevel Result
  <0     n*ABlockIndent spaces where n is level of element
         ABlockIndent is set to n
  0      no spaces
  1      ABlockIndent spaces
  2      2 * ABlockIndent
  ...
  validate level (in case of level equil -1 or is negative), in this
  case ALevel is calculated (returned)
}
function TxmlElement.ValidateLevel(var ALevel: Integer): String;
var
  e: TxmlElement;
  L: Integer;
begin
  if ALevel < 0 then begin
    // calc element level
    e:= Self;
    repeat
      e:= e.ParentElement;
      if not Assigned(e)
      then Break;
      Inc(ALevel);
    until False;
  end;
  // left align with spaces
  SetLength(Result, BlockIndent * ALevel);
  L:= Length(Result);
  if L > 0
  then FillChar(Result[1], L, #32);
end;

function TxmlElement.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  i, n: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
  t: String;
  sep: WideString;
begin
  Result:= '';
  if not IsValid then begin
    // Exit;
  end;
  t:= ValidateLevel(ALevel);

  // element and attributes
  Result:= t + '<' + GetElementName + #32;
  for i:= 0 to FAttributes.Count - 1 do begin
    if FAttributes.Items[i].IsValuable then begin
      Result:= Result + FAttributes.Items[i].FName + '=' +
        QuotesValue(FAttributes.Items[i].FValue) + #32;
    end;
  end;
  // check is nested elements exists
  if IsEmpty then begin
    // single element, replace last space to "/>".
    Result[Length(Result)]:= '/';
    Result:= Result + '>';
  end else begin
    // have nested elements, replace last space to ">".
    Result[Length(Result)]:= '>';
    Result:= Result + LINESEPARATOR;
    // insert embedded elements
    if ftAsIs in AOptions
    then Sep:= ''
    else Sep:= LINESEPARATOR;
    for n:= 0 to NestedElements1Count - 1 do begin
      NestedElement:= GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        Result:= Result + NestedElement.CreateText(ALevel + 1, AOptions) + Sep;
      end;
    end;
    // close element
    Result:= Result + t + '</' + GetElementName + '>';
  end;
end;

// add list of HRefs to list
procedure TxmlElement.GetListHrefs(AListHrefs: TStrings);
var
  i, n: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
begin
  // element and attributes
  for i:= 0 to FAttributes.Count - 1 do with FAttributes.Items[i] do begin
    if (FAttrType = atHref) and IsValuable then begin
      AListHrefs.AddObject(FValue, FAttributes.Items[i]);
    end;
  end;
  // check is nested elements exists
  if not IsEmpty then begin
    // have nested elements, replace last space to ">".
    // insert embedded elements
    for n:= 0 to NestedElements1Count - 1 do begin
      NestedElement:= GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        NestedElement.GetListHrefs(AListHRefs);
      end;
    end;
  end;
end;

function TxmlElement.CanInsertElement(AElementClass: TPersistentClass): Boolean;
var
  ElemColl: TxmlElementCollection;
begin
  ElemColl:= FNestedElements.GetByClass(AElementClass);
  Result:= Assigned(ElemColl);
  if Result then begin
    // continue check
    case ElemColl.FWMLCollectionQtyLimit of
    wciAny,
    wciOneOrMore: ;
    wciOneOrNone,
    wciOne: begin
        if wcServerExtensions in XMLENV.XMLCapabilities
        then Result:= ElemColl.Count <= 1  // <bracket>
        else Result:= ElemColl.Count = 0;
      end;
    end; { case }
  end;
end;

destructor TxmlElement.Destroy;
var
  i, L: Integer;
  pc: TPersistentClass;
begin
  FAttributes.Free;
  FNestedElements.Free;
  // rearrange Orders, for example: 1, 2, 3; delete 2, after deletion Orders are: 1, 3.
  // loop below fix it
  if Assigned(ParentElement) then begin
    L:= ParentElement.NestedElements1Count;
    for i:= Order + 1 to L - 1 do begin
      ParentElement.GetNested1ElementByOrder(i, pc).Order:= i - 1;
    end;
  end;
  inherited Destroy;
end;

// --------- TxmlComment ---------

constructor TxmlComment.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;

  FAttributes.AddAttribute('value', atCData, IMPLIED, NODEFAULT, NOLIST);
end;

class function TxmlComment.GetElementName: String;
begin
  Result:= 'comment';
end;

function TxmlComment.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  t: String;
begin
  // left align
  t:= ValidateLevel(ALevel);
  Result:= t + '<!-- ' + FAttributes.ValueByName['value'] + ' -->';
end;

// --------- TxmlssScript ---------

constructor TxmlssScript.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;

  FAttributes.AddAttribute('value', atCData, IMPLIED, NODEFAULT, NOLIST);
end;

class function TxmlssScript.GetElementName: String;
begin
  Result:= 'ssScript';
end;

function TxmlssScript.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  t: String;
begin
  t:= ValidateLevel(ALevel);
  Result:= t + '<% ' + FAttributes.ValueByName['value'] + ' %>';
end;

// --------- TxmlContainer ---------

constructor TxmlContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;
  FNestedElements.AddNew(TXMLDesc, wciAny);
  FNestedElements.AddNew(TxmlComment, wciAny);
end;

function TxmlContainer.GetName: String;
begin
  // element name
  Result:= 'document';
end;

class function TxmlContainer.GetElementName: String;
begin
  // element name
  Result:= 'document';
end;

function TxmlContainer.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  n: Integer;
  NestedElement: TxmlElement;
  NestedElementClass: TPersistentClass;
begin
  Result:= '';
  // insert embedded elements
  for n:= 0 to NestedElements1Count - 1 do begin
    NestedElement:= GetNested1ElementByOrder(n, NestedElementClass);
    if Assigned(NestedElement) then begin
      Result:= Result + NestedElement.CreateText(ALevel+1, AOptions) + LINESEPARATOR;
    end;
  end;
end;

function TxmlContainer.CanInsertElement(AElementClass: TPersistentClass): Boolean;
begin
  Result:= inherited CanInsertElement(AElementClass);
end;

{
procedure TxmlElement.CallbackCreateDTD(var AxmlElement: TxmlElement);
begin
  if (AxmlElement.ClassType = FSearchElementEnv.seClass) or
    (FSearchElementEnv.seClass = TxmlContainer) then begin
    Inc(ForEachElementIteration);
  end;
end;
}

function TxmlContainer.CreateDTD(AElement: TxmlElement; var AElementList: String): WideString;
const
  RequiredStr: array[Boolean]of String[8] = ('IMPLIED', 'REQUIRED');
var
  n: Integer;
  d: TxmlElement;
begin
  Result:= '';
  AElementList:= AElementList + '<'+AElement.GetElementName + '>';
  // element and attributes
  with AElement do begin
    if FNestedElements.Count > 0 then begin
      Result:= '<!ELEMENT ' + GetElementName + ' (';
      // insert embedded elements
      for n:= 0 to FNestedElements.Count - 1 do begin
        Result:= Result + FNestedElements[n].GetElementName +
          GetElementQtyDescription(FNestedElements[n].QtyLimit) + ', ';
      end;
      Delete(Result, Length(Result) - 1, 2); // delete last ', '
      Result:= Result + ')>'#13#10;
    end else begin
      Result:= '<!ELEMENT ' + GetElementName + ' EMPTY>'#13#10;
    end;

    with FAttributes do begin
      if (Count > 0) then begin
        Result:= Result + '<!ATTLIST ' + GetElementName + #13#10;
        for n:= 0 to Count - 1 do begin
          case Items[n].FAttrType of
          atList, atNoStrictList: begin
            Items[n].FList.Delimiter:= '|';
            Result:= Result + Items[n].FName + #9 + GetAttrTypeDescription(Items[n].FAttrType) +
              ';'#9 + '(' + Items[n].FList.DelimitedText + ')'#9'"' + Items[n].FDefaultValue + '"'#13#10;
            end;
          else
            Result:= Result + Items[n].FName + #9 + GetAttrTypeDescription(Items[n].FAttrType) +
              ';'#9'#' + RequiredStr[Items[n].FRequired] + #13#10;
          end;
        end;
        Result:= Result + '>'#13#10;
      end else begin
      end;
    end;
    Result:= Result +  #13#10;
    // iterate embedded elements
    for n:= 0 to FNestedElements.Count - 1 do begin
      if Pos('<' + FNestedElements[n].GetElementName + '>', AElementList) = 0 then begin
        d:= FNestedElements[n].Add;
        Result:= Result + CreateDTD(d, AElementList);
        d.Free;
      end;
    end;
  end;
end;

// --------- TBracket ---------

constructor TBracket.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;
  FNestedElements.AddNew(TBracket, wciAny);
  with FAttributes do begin
    AddAttribute('loop', atVData, IMPLIED, NODEFAULT, NOLIST);
    AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST);
    AddAttribute('first', atNumber, IMPLIED, NODEFAULT, NOLIST);
    AddAttribute('last', atNumber, IMPLIED, NODEFAULT, NOLIST);
    AddAttribute('move', atNumber, IMPLIED, NODEFAULT, NOLIST);
  end;
end;

class function TBracket.GetElementName: String;
begin
  Result:= 'bracket';
end;

function TBracket.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  n: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
  sep: WideString;
begin
  if customxml.XMLENV.dbParsing <= 0 then begin
    Result:= inherited CreateText(ALevel, AOptions);
    Exit;
  end;
  // else do NOT print bracket element itself
  {
  if not IsValid then begin
    // Exit;
  end;
  }
  Result:= '';
  // insert embedded elements
  if ftAsIs in AOptions
  then Sep:= ''
  else Sep:= LINESEPARATOR;
  for n:= 0 to NestedElements1Count - 1 do begin
    NestedElement:= GetNested1ElementByOrder(n, NestedElementClass);
    if Assigned(NestedElement) then begin
      Result:= Result + NestedElement.CreateText(ALevel + 1, AOptions) + Sep;
    end;
  end;
end;

// --------- TServerSide ---------

constructor TServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;
//  FNestedElements.AddNew(TxmlPCData, wciOneOrNone); DONOT! DO IT in class..
  FAttributes.AddAttribute('dataset', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('action', atList, REQUIRED, 'query', 'db|query|execute|move|defaultparam|defaultparams|send');
  FAttributes.AddAttribute('opt', atNoStrictList, IMPLIED, '', 'ado|ib|bde|cookie|mail');
  FAttributes.AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST);
end;

class function TServerSide.GetElementName: String;
begin
  Result:= 'serverside';
end;

// text of nested pc data and esever side element itself removed
function TServerSide.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  n: Integer;
  NestedElement: TxmlElement;
  dummyNestedElementClass: TPersistentClass;
  t: String;
begin
  // left align
  t:= ValidateLevel(ALevel);
  Result:= '';

  // serverSide element and attributes
  Result:= t + '<' + GetElementName + #32;
  for n:= 0 to FAttributes.Count - 1 do begin
    if FAttributes.Items[n].IsValuable then begin
      Result:= Result + FAttributes.Items[n].FName + '=' +
        QuotesValue(FAttributes.Items[n].FValue) + #32;
    end;
  end;
  // have nested elements, replace last space to ">".
  Result[Length(Result)]:= '>';
  Result:= Result + LINESEPARATOR;
  // insert embedded pcdata element if exists
  for n:= 0 to NestedElements1Count - 1 do begin
    NestedElement:= GetNested1ElementByOrder(n, dummyNestedElementClass);
    if Assigned(NestedElement) then begin
      Result:= Result + NestedElement.CreateText(ALevel+1, AOptions) + LINESEPARATOR;
    end;
  end;
  // close element
  Result:= Result + t + '</' + GetElementName + '>';
end;

// --------- TxmlPCData ---------

constructor TxmlPCData.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE; // $3A?
  FAbstract:= False;

  FAttributes.AddAttribute('value', atCData, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.ValueByName['value']:= ''// '&nbsp;';
end;

function TxmlPCData.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  vl: WideString;
begin
  // left align
  vl:= FAttributes.ValueByName['value'];
  if ftCompressSpaces in AOptions
  then util1.DeleteLeadTerminateDoubledSpaceStr(vl)
  else util1.DeleteLeadTerminateSpaceStr(vl);  // Oct 01 2004
  if Length(vl) > 0 then
    Result:= util_xml.SplitLongText(ValidateLevel(ALevel) + vl,
      1, BlockIndent * ALevel, TextRightEdgeCol)
  else
    Result:= vl;
  end;

class function TxmlPCData.GetElementName: String;
begin
  Result:= 'text';
end;

// --------- TXMLDesc ---------

constructor TXMLDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;

  FAttributes.AddAttribute('version', atCData, IMPLIED, DEFAULTXMLVERSION, NOLIST);
  FAttributes.AddAttribute('encoding', atNoStrictList, IMPLIED, DEFAULTXMLENCODING,
    'unknown|' + util_xml.GetListOfSupportedCharsetEncodings('|'));
end;

class function TXMLDesc.GetElementName: String;
begin
  Result:= '?xml';
end;

{ <?xml version="1.0" encoding="utf-8"?> }
function TXMLDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  t: String;
  e: String;
begin
  // left align
  t:= ValidateLevel(ALevel);
  e:= FAttributes.ValueByName['encoding'];
  {
  if e = DEFAULTENCODING
  then e:= '';
  }
  if Length(e) > 0
  then e:= ' encoding="' + e + '"';
  Result:= t + Format('<?xml version="%s"%s?>', [FAttributes.ValueByName['version'], e]);
end;

// --------- TDocDesc ---------

constructor TDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;
end;

class function TDocDesc.GetElementName: String;
begin
  Result:= '!DOCTYPE';
end;

//<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML 1.2//EN" "http://www.wapforum.org/DTD/wml12.dtd">
function TDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
begin
  Result:= '';
end;

function GetElementQtyDescription(AQtyLimit: TxmlCollectionQtyLimit): String;
begin
  case AQtyLimit of
  wciAny: Result:= '*';
  wciOneOrNone: Result:= '?';
  wciOne: Result:= '';
  wciOneOrMore: Result:= '+';
  else Result:= '';
  end;
end;

function GetAttrTypeDescription(AAttrType: TAttrType): String;
begin
  case AAttrType of
    atVData: Result:= '%vdata';
    atCData: Result:= '#PCDATA';
    atNumber: Result:= '%number';
    atHref: Result:= '%href';
    atLength: Result:= '%length';
    atNMToken: Result:= '%nmtoken';
    atID: Result:= '%id';
    atList: Result:= '%list';
    atNoStrictList: Result:= '%nostrictlist';
    atLang: Result:= '%lang';
    atColor: Result:= '%color';
    atIDREF: Result:= '%idref';
    atIDREFS: Result:= '%idrefs';
  else  Result:= '';
  end;
end;

end.
