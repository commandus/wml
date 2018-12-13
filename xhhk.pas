unit
  xhhk;
(*##*)
(*******************************************************************************
*                                                                             *
*   x  h  h  k                                                                 *
*                                                                             *
*   Copyright © 2002- 2003 Andrei Ivanov. All rights reserved.                 *
*   Microsoft CHM Help keyword file                                           *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Dec 15 2002                                                 *
*   Last fix     : Dec 15 2002                                                *
*   Lines        : 6216                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Classes, Windows, SysUtils, Controls, StrUtils,
  jclUnicode, customxml;

const
  ATTR_id: String[2] = 'id';
  ATTR_name: String[4] = 'name';
  ATTR_type: String[4] = 'type';
  ATTR_value: String[5] = 'value';
  ATTR_content: String[7] = 'content';

type
  THHKContainer = class(TxmlContainer)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHKDocDesc = class(TDocDesc)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  THHKServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHKBracket = class(TBracket)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHKPCData = class(TxmlPCData)
  public
  end;

  THHKBaseElement = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHKCommentedElement  = class(THHKBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHKHtml = class(THHKCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  ThhkMeta = class(THHKBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  ThhkBody = class(THHKCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  Thhkhead = class(ThhkCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHKUl = class(THHKCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHKLi = class(THHKCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHKObject = class(THHKCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHKParam = class(THHKBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

// register xml schema used by xmlsupported

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;

implementation

uses
  xmlParse; // for GetDocumentTitle() implementation - document is parsed

const
  // 156..252
  HHKElements: array [0..15] of TxmlElementClass = (
      THHKContainer, ThhkBracket,
      THHKhtml,
      THHKbody,
      THHKhead,
      THHKmeta,
      THHKul, THHKli,
      THHKobject, THHKparam,
      THHKPCData, TxmlComment, TXMLDesc, THHKDocDesc, THHKServerSide, TxmlssScript);


// --------- THHKContainer ---------

constructor THHKContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(THHKDocDesc, wciOneOrNone);
  FNestedElements.AddNew(THHKhtml, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THHKServerSide, wciAny);
end;

// --------- THHKDocDesc ---------

constructor THHKDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;
  // attribute collection
  FAttributes.AddAttribute('version', atCData, REQUIRED, '1.0', '1.0|1.1');
end;

//
function THHKDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
begin
  Result:= ValidateLevel(ALevel) + '<!DOCTYPE  HTML PUBLIC "-//IETF//DTD HTML//EN">';
end;

// --------- THHKServerSide ---------

constructor THHKServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(THHKPCData, wciAny);
end;

// Htm declaration

constructor THHKBASEElement.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  // server extension
  if wcServerExtensions in xmlEnv.XMLCapabilities then begin
    FAttributes.AddAttribute('loop', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('first', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('last', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('move', atNumber, IMPLIED, NODEFAULT, NOLIST);

    FNestedElements.AddNew(ThhkBracket, wciAny);
  end;
  Self.FAbstract:= False;
end;

constructor THHKCommentedElement.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);
end;

constructor THHKhtml.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THHKbody, wciOneOrNone);
  FNestedElements.AddNew(THHKhead, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(ThhkServerSide, wciAny);
end;

constructor THHKul.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THHKLi, wciOneOrMore);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THHKServerSide, wciAny);
end;

constructor THHKli.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  // nested elements
  FNestedElements.AddNew(THHKobject, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THHKServerSide, wciAny);
end;

constructor THHKobject.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atList, IMPLIED, 'text/sitemap', 'text/sitemap');

  // nested elements
  FNestedElements.AddNew(THHKParam, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THHKServerSide, wciAny);
end;

constructor THHKparam.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atCDATA, REQUIRED, NODEFAULT, 'Keyword|Name|Local');
  FAttributes.AddAttribute(ATTR_value, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  // EMPTY
end;

constructor Thhkmeta.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_content, atCDATA, REQUIRED, NODEFAULT, NOLIST);

  // EMPTY
end;

constructor Thhkhead.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(TxmlSSScript, wciAny);
  FNestedElements.AddNew(ThhkMeta, wciAny);
  FNestedElements.AddNew(ThhkObject, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(ThhkServerSide, wciAny);
end;

constructor Thhkbody.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THHKul, wciAny);
  FNestedElements.AddNew(THHKobject, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THHKServerSide, wciAny);
end;

// --------- THhkBracket ---------

constructor THhkBracket.Create(ACollection: TCollection);
var
  e: Integer;
begin
  inherited Create(ACollection);
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    for e:= Low(HHKElements) + 2 to High(HHKElements) do begin
      FNestedElements.AddNew(HHKElements[e], wciAny);
    end;
  end;
end;

// --------- GetDocumentTitle ---------

{
  GetDocumentTitle() calls xml parser
}

function GetDocumentTitle(const ASrc: WideString): String;
begin
  Result:= 'Help Keywords';
end;

// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 374;
    len:= 16; // last is 383
    classes:= @HHKElements;
    DocType:= edHHK;

    xmlElementClass:= THHKContainer;
    xmlPCDataClass:= THHKPCData;
    DocDescClass:= THHKDocDesc;

    deficon:= ofs;
    defaultextension:= 'hhk';
    desc:= 'Help Keywords file';
    extensionlist:= 'hhk';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.
