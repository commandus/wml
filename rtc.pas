unit
  rtc;
(*##*)
(*******************************************************************************
*                                                                             *
*   R  T  C    u  s  e  r    p  r  o  f  i  l  e                               *
*                                                                             *
*   Copyright © 2006  Andrei Ivanov. All rights reserved.                      *
*   Microsoft RTC user profile                                                *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    :                                                             *
*   Last fix     :                                                            *
*   Lines        :                                                             *
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
  ATTR_key: String[3] = 'key';
  ATTR_name: String[4] = 'name';
  ATTR_expires: String[7] = 'expires';
  ATTR_addr: String[4] = 'addr';
  ATTR_protocol: String[8] = 'protocol';
  ATTR_auth: String[4] = 'auth';
  ATTR_role: String[4] = 'role';
  ATTR_party: String[5] = 'party';
  ATTR_uri: String[3] = 'uri';
  ATTR_account: String[7] = 'account';
  ATTR_password: String[8] = 'password';
  ATTR_realm: String[5] = 'realm';
  ATTR_banner: String[6] = 'banner';
  ATTR_updates: String[7] = 'updates';
  ATTR_homepage: String[8] = 'homepage';
  ATTR_helpdesk: String[8] = 'helpdesk';
  ATTR_personal: String[8] = 'personal';
  ATTR_calldisplay: String[11] = 'calldisplay';
  ATTR_idledisplay: String[11] = 'idledisplay';
  ATTR_minver: String[6] = 'minver';
  ATTR_curver: String[6] = 'curver';
  ATTR_updateuri: String[9] = 'updateuri';
  ATTR_TRUE: String[4] = 'true';
  ATTR_FALSE: String[5] = 'false';
  
type
  TRTCContainer = class(TxmlContainer)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCDocDesc = class(TDocDesc)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  TRTCServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCBracket = class(TBracket)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCPCData = class(TxmlPCData)
  public
  end;

  TRTCBaseElement = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCCommentedElement  = class(TRTCBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCProvision = class(TRTCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCUser = class(TRTCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCClient = class(TRTCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCProvider = class(TRTCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCSIPSrv = class(TRTCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCSession = class(TRTCCommentedElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TRTCData = class(TRTCCommentedElement)
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
  // 253..
  RTCElements: array [0..14] of TxmlElementClass = (
      TRTCContainer, TRTCBracket,
      TRTCProvision,
      TRTCUser,
      TRTCClient,
      TRTCData,
      TRTCProvider,
      TRTCSIPSrv,
      TRTCSession,
      TRTCPCData, TxmlComment, TXMLDesc, TRTCDocDesc, TRTCServerSide, TxmlssScript);


// --------- TRTCContainer ---------

constructor TRTCContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TRTCDocDesc, wciOneOrNone);
  FNestedElements.AddNew(TRTCProvision, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TRTCServerSide, wciAny);
end;

// --------- TRTCDocDesc ---------

constructor TRTCDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;
  // attribute collection
  FAttributes.AddAttribute('version', atCData, REQUIRED, '1.0', '1.0');
end;

//
function TRTCDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
begin
  Result:= ValidateLevel(ALevel) + '<!DOCTYPE RTC PUBLIC "-//IETF//DTD RTC//EN">';
end;

// --------- TRTCServerSide ---------

constructor TRTCServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TRTCPCData, wciAny);
end;

// Htm declaration

constructor TRTCBASEElement.Create(ACollection: TCollection);
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

    FNestedElements.AddNew(TRTCBracket, wciAny);
  end;
  Self.FAbstract:= False;
end;

constructor TRTCCommentedElement.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);
end;

constructor TRTCProvision.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_key, atID, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atVDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_expires, atID, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(TRTCUser, wciOne);
  FNestedElements.AddNew(TRTCSIPSrv, wciOneOrMore);
  FNestedElements.AddNew(TRTCClient, wciOneOrNone);
  FNestedElements.AddNew(TRTCProvider, wciOneOrNone);
                                                         //dt:type
  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TRTCServerSide, wciAny);
end;

constructor TRTCSIPSrv.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_addr, atVDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_protocol, atList, REQUIRED, NODEFAULT, 'TCP|UDP|TLS');
  FAttributes.AddAttribute(ATTR_auth, atList, IMPLIED, NODEFAULT, 'basic|digest');
  FAttributes.AddAttribute(ATTR_role, atList, REQUIRED, NODEFAULT, 'proxy|registrar');

  // nested elements
  FNestedElements.AddNew(TRTCSession, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TRTCServerSide, wciAny);
end;

constructor TRTCSession.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_party, atList, IMPLIED, NODEFAULT, 'first|third');
  FAttributes.AddAttribute(ATTR_party, atList, IMPLIED, NODEFAULT, 'pc2pc|pc2ph|ph2pc|im');
  // nested elements
  FNestedElements.AddNew(TRTCData, wciAny);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TRTCServerSide, wciAny);
end;

constructor TRTCData.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  // nested elements

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TRTCServerSide, wciAny);
end;

constructor TRTCUser.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_uri, atHref, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_account, atVDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_name, atVDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_password, atVDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_realm, atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // EMPTY
end;

constructor TRTCProvider.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_name, atVDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_homepage, atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_helpdesk, atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_personal, atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_calldisplay, atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_idledisplay, atHref, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(TRTCData, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TRTCServerSide, wciAny);
end;

constructor TRTCClient.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attributes
  FAttributes.AddAttribute(ATTR_banner, atList, IMPLIED, ATTR_TRUE, 'false|true');
  FAttributes.AddAttribute(ATTR_updates, atList, IMPLIED, NODEFAULT, 'false|true');
  FAttributes.AddAttribute(ATTR_minver, atVDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_curver, atVDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute(ATTR_updateuri, atHref, IMPLIED, NODEFAULT, NOLIST);

  // nested elements
  FNestedElements.AddNew(TRTCData, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TRTCServerSide, wciAny);
end;

// --------- TRTCBracket ---------

constructor TRTCBracket.Create(ACollection: TCollection);
var
  e: Integer;
begin
  inherited Create(ACollection);
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    for e:= Low(RTCElements) + 2 to High(RTCElements) do begin
      FNestedElements.AddNew(RTCElements[e], wciAny);
    end;
  end;
end;

// --------- GetDocumentTitle ---------

{
  GetDocumentTitle() calls xml parser
}

function GetDocumentTitle(const ASrc: WideString): String;
begin
  Result:= 'RTC user profile';
end;

// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 390;
    len:= 15; // last is 404, next 405
    classes:= @RTCElements;
    DocType:= edRTC;

    xmlElementClass:= TRTCContainer;
    xmlPCDataClass:= TRTCPCData;
    DocDescClass:= TRTCDocDesc;

    deficon:= ofs;
    defaultextension:= 'rtc';
    desc:= 'RTC user profile';
    extensionlist:= 'rtc';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.
