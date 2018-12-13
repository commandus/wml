unit generalxml;
(*##*)
(*******************************************************************************
*                                                                             *
*   G  E  N  E  R  A  L  X  M  L                                               *
*                                                                             *
*   Copyright © 2001-2006 Andrei Ivanov. All rights reserved.                  *
*   general xml classes                                                       *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Dec 01 2006                                                 *
*   Last fix     : Dec 01 2006                                                *
*   Lines        : 1107                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Classes, Windows, SysUtils, Controls, StrUtils,
  jclUnicode, customxml;

type
  TgenXMLElement = class(customxml.TxmlElement)
  private
    // class var
    FElementName: String;
  protected
  public
    class function GetElementName: String; override;
    class function IsElementByName(AName: String): Boolean; override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
    procedure SetElementName(const AElementName: String);
    constructor Create(ACollection: TCollection); override;
    function IsEmpty: Boolean; override;
  end;

  TgenServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TgenXMLAttributes = class(TxmlAttributes)
  public
    function IndexOf(const AName: String): Integer; override;
  end;

  TGENContainer = class(TxmlContainer)
  public
    constructor Create(ACollection: TCollection); override;
  end;

// register xml schema used by xmlsupported

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;

implementation

uses
  util1, util_xml,
  xmlParse; // for GetDocumentTitle() implementation - document is parsed

const

  genXMLElements: array[0..8] of TxmlElementClass = (
     TxmlContainer, TBracket, TxmlPCData, TxmlComment, TXMLDesc, TDocDesc,
     TgenServerSide, TxmlssScript, TgenXMLElement); // TgenXMLElement MUST be last!


// --------- TWMLVersion ---------
{
constructor TWMLVersion.Create;
begin
  inherited Create;
  Major:= 1;
  Minor:= 1;
  WMLCapabilities:= [];
end;

destructor TWMLVersion.Destroy;
begin
  inherited Destroy;
end;
}

// --------- TWMLBaseElement can contain comments ---------

constructor TgenXMLElement.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // replace attributes to gen 
  FAttributes.Free;
  FAttributes:= TgenxmlAttributes.Create(TxmlAttribute);

  FNestedElements.AddNew(TgenXMLElement, wciAny);

  FNestedElements.AddNew(TxmlPCData, wciAny);
  FNestedElements.AddNew(TxmlComment, wciAny);
  {
  FNestedElements.AddNew(TXMLDesc, wciAny);
  FNestedElements.AddNew(TDocDesc, wciAny);
  }

  // attribute collection
  FAttributes.AddAttribute('xml:lang', atLang, IMPLIED, NODEFAULT, NOLIST);
  // server extension
  if wcServerExtensions in xmlEnv.XMLCapabilities then begin
    FNestedElements.AddNew(TBracket, wciAny);
    FNestedElements.AddNew(TgenServerSide, wciAny);
    FNestedElements.AddNew(TxmlssScript, wciAny);

    FAttributes.AddAttribute('loop', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('first', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('last', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('move', atNumber, IMPLIED, NODEFAULT, NOLIST);
  end;
end;

class function TgenXMLElement.GetElementName: String;
begin
//  Result:= FElementName; // 'x';
  Result:= '';
end;

function TgenXMLElement.IsEmpty: Boolean;
begin
  Result:= False;
end;

//
function TgenXMLElement.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  n: Integer;
  NestedElement: TxmlElement;
  dummyNestedElementClass: TPersistentClass;
  t: String;
  nec: Integer;
  isNotText: Boolean;
  wc: WideString;
begin
  // left align
  t:= ValidateLevel(ALevel);
  Result:= '';

  // serverSide element and attributes
  Result:= t + '<' + FElementName + #32;
  for n:= 0 to FAttributes.Count - 1 do begin
    if FAttributes.Items[n].IsValuable then begin
      Result:= Result + FAttributes.Items[n].Name + '=' +
        QuotesXMLValue(FAttributes.Items[n].Value) + #32;
    end;
  end;
  // have nested elements, replace last space to ">".
  Result[Length(Result)]:= '>';
  nec:= NestedElements1Count;
  case nec of
    0: Result:= Result + '/>';
    1: begin
      NestedElement:= GetNested1ElementByOrder(0, dummyNestedElementClass);
      if Assigned(NestedElement) then begin
        isNotText:= not (NestedElement is TxmlPCData);
        if isNotText then
          Result:= Result + LINESEPARATOR + NestedElement.CreateText(ALevel + 1, AOptions) +
            LINESEPARATOR + t + '</' + FElementName + '>'
        else
          Result:= Result + NestedElement.CreateText(0, AOptions)+ '</' + FElementName + '>'
      end;
      Result:= Result ;
    end;
    else begin
        Result:= Result + LINESEPARATOR;
        // insert embedded elements if exists
        for n:= 0 to nec - 1 do begin
          NestedElement:= GetNested1ElementByOrder(n, dummyNestedElementClass);
          if Assigned(NestedElement) then begin
            wc:= NestedElement.CreateText(ALevel + 1, AOptions);
            if (Length(wc) > 0) then
              Result:= Result + wc + LINESEPARATOR;
          end;
        end;
        // close element
        Result:= Result + t + '</' + FElementName + '>';
    end;
  end;
end;

procedure TgenXMLElement.SetElementName(const AElementName: String);
begin
  FElementName:= AElementName;
end;

class function TgenXMLElement.IsElementByName(AName: String): Boolean;
begin
  Result:= True;
end;

 function NestedElements1Count: Integer;
 begin
   Result:= 1; // at least..
 end;

constructor TgenServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TxmlPCData, wciAny);
end;

// --------- TgenxmlAttributes ---------

function TgenxmlAttributes.IndexOf(const AName: String): Integer;
begin
  // search attribute
  Result:= inherited IndexOf(AName);
  if Result < 0 then begin // if not found
    // add attribute
    Result:= AddAttribute(AName, atVData, IMPLIED, NODEFAULT, NOLIST).Index;
  end;
end;


// --------- TGENContainer ---------

constructor TgenContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TgenXMLElement, wciOne);
  FNestedElements.AddNew(TDocDesc, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TgenServerSide, wciAny);
end;

// --------- GetDocumentTitle ---------

function GetDocumentTitle(const ASrc: WideString): String;
begin
  Result:= 'general XML document';
end;

// register xml schema used by xmlsupported

// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 405;
    len:= 9; // last is 414, next 414
    classes:= @genXMLElements;
    DocType:= edgenXML;

    xmlElementClass:= TGENContainer;
    xmlPCDataClass:= TxmlPCData;
    DocDescClass:= TDocDesc;

    deficon:= ofs;
    defaultextension:= 'xml';
    desc:= 'extensible markup language source document';
    extensionlist:= 'xml';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.
