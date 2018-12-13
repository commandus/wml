unit
  xhhc;
(*##*)
(*******************************************************************************
*                                                                             *
*   x  h  h  c                                                                 *
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

type
  THHCContainer = class(TxmlContainer)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHCDocDesc = class(TDocDesc)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  THHCServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHCBracket = class(TBracket)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHCPCData = class(TxmlPCData)
  public
  end;

  THHCBaseElement = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHCCommentedElement  = class(THHCBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHCHtml = class(THHCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHCUl = class(THHCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHCLi = class(THHCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHCObject = class(THHCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  THHCParam = class(THHCBaseElement)
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
  HHCElements: array [0..12] of TxmlElementClass = (
      THHCContainer, ThhcBracket, THHCHtml,
      THHCul, THHCli,
      THHCobject, THHCparam,
      THHCPCData, TxmlComment, TXMLDesc, THHCDocDesc, THHCServerSide, TxmlssScript);


// --------- THHCContainer ---------

constructor THHCContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(THHChtml, wciOne);
  FNestedElements.AddNew(THHCDocDesc, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THHCServerSide, wciAny);
end;

// --------- THHCDocDesc ---------

constructor THHCDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;
  // attribute collection
  FAttributes.AddAttribute('version', atCData, REQUIRED, '1.0', '1.0|1.1');
end;

//
function THHCDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  t: String;
begin
  // left align
  t:= ValidateLevel(ALevel);

  Result:= t + Format('<!DOCTYPE xhtml PUBLIC "-//W3C//DTD XHTML %s Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    [FAttributes.ValueByName['version']]);
end;

// --------- THHCServerSide ---------

constructor THHCServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(THHCPCData, wciAny);
end;

// Htm declaration

constructor THHCBASEElement.Create(ACollection: TCollection);
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

    FNestedElements.AddNew(ThhcBracket, wciAny);
  end;
  Self.FAbstract:= False;
end;

constructor THHCCommentedElement.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);
end;

constructor THHChtml.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(Thhcul, wciAny);
  FNestedElements.AddNew(Thhcobject, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(ThhcServerSide, wciAny);
end;

constructor THHCul.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(THHCLi, wciAny);
  FNestedElements.AddNew(Thhcul, wciAny);
  
  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THHCServerSide, wciAny);
end;

constructor THHCli.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  // nested elements
  FNestedElements.AddNew(THHCobject, wciAny);
  FNestedElements.AddNew(THHCUl, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THHCServerSide, wciAny);
end;

constructor THHCobject.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_type, atList, IMPLIED, 'text/sitemap', 'text/sitemap');

  // nested elements
  FNestedElements.AddNew(THHCParam, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(THHCServerSide, wciAny);
end;

constructor THHCparam.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_id, atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atList, REQUIRED, NODEFAULT, 'Name|Local');
  FAttributes.AddAttribute(ATTR_value, atCDATA, REQUIRED, NODEFAULT, NOLIST);
  // EMPTY
end;

// --------- THhcBracket ---------

constructor THhcBracket.Create(ACollection: TCollection);
var
  e: Integer;
begin
  inherited Create(ACollection);
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    for e:= Low(HHCElements) + 2 to High(HHCElements) do begin
      FNestedElements.AddNew(HHCElements[e], wciAny);
    end;
  end;
end;

// --------- GetDocumentTitle ---------

{
  GetDocumentTitle() calls xml parser
}

function GetDocumentTitle(const ASrc: WideString): String;
begin
  Result:= 'Help Content';
end;

// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 361;
    len:= 12; // last is 373
    classes:= @HHCElements;
    DocType:= edHHC;

    xmlElementClass:= THHCContainer;
    xmlPCDataClass:= THHCPCData;
    DocDescClass:= THHCDocDesc;

    deficon:= ofs;
    defaultextension:= 'hhc';
    desc:= 'Help Content file';
    extensionlist:= 'hhc';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.
