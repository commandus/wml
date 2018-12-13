unit
  wml;
(*##*)
(*******************************************************************************
*                                                                             *
*   W  M  L                                                                    *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language classes                                          *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2001                                                 *
*   Last fix     : Mar 29 2002                                                *
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

var
  DEF_WML_TEXTWRAP: Boolean = True;
const
  DEF_WML_TEXTWRAP_VAL = 'wrap';

type
  TWMLWML = class;
  TWMLCard  = class;
  TWMLTemplate = class;
  TWMLClass = class of TWMLWML;
  TWMLCardClass = class of TWMLCard;
  TWMLPCDataClass = class of TwmlPCData;
  TWMLElementCollectionClass = class of TxmlElementCollection;

  TWMLDocDesc = class(TDocDesc)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  TwmlServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLPCData = class(TxmlPCData)
  public
    // return what aligmnment assigned in parent paragraph
    function TextAlignment: TAlignment; override;
    function TextWrap: Boolean; override;
    // return context of TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall elements
    function TextEmphasisis: TEmphasisis; override;
  end;

  TWMLBaseElement = class(TxmlElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLBracket = class(TBracket)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWML_Lang = class(TWMLBaseElement)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWML_Task = class(TWMLBaseElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

// --------- WML elements implementation ---------

  TWMLWML = class(TWML_Lang)
  private
  protected
  public
    function CanInsertElement(AElementClass: TPersistentClass): Boolean; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLHead = class(TWMLBaseElement)
  private
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLTemplate = class(TWMLBaseElement)
  private
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLCard = class(TWML_Lang)
  private
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLAccess = class(TWMLBaseElement)
  private
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLMeta = class(TWMLBaseElement)
  private
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLDo = class(TWML_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLOnEvent = class(TWMLBaseElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLTimer = class(TWMLBaseElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLP = class(TWML_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // tasks

  TWMLGo = class(TWML_Task)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLPrev = class(TWML_Task)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLNoop = class(TWML_Task)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLRefresh = class(TWML_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLPostfield = class(TWMLBaseElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLSetvar = class(TWMLBaseElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // flow

  TWML_Flow = class(TWML_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLBr = class(TWML_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLImg = class(TWML_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLAnchor = class(TWML_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLA = class(TWML_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLTable = class(TWML_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLTr = class(TWMLBaseElement) // no lang attribute
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLTd = class(TWML_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // emph: TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall

  TWML_Emph = class(TWMLBaseElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLEm = class(TWML_Emph)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLStrong = class(TWML_Emph)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLB = class(TWML_Emph)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLI = class(TWML_Emph)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLU = class(TWML_Emph)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLBig = class(TWML_Emph)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLSmall = class(TWML_Emph)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // fields

  TWML_Field = class(TWML_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLInput = class(TWML_Field)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLSelect = class(TWML_Field)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLFieldSet = class(TWML_Field)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLoptgroup = class(TWML_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLoption = class(TWML_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLpre = class(TWMLBaseElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TwmlContainer = class(TxmlContainer)
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
  LSSTR_ENCTYPE = 'application/x-wwwform-urlencoded|multipart/form-data';

  WMLElements: array[0..43] of TxmlElementClass = (
     TwmlContainer, TWmlBracket, TWMLWML, TWMLHead, TWMLTemplate, TWMLCard, TWMLAccess, TWMLGo, TWMLMeta, TWMLDo,
     TWMLOnEvent, TWMLTimer, TWMLP, TWMLPrev, TWMLNoop, TWMLRefresh, TWMLPostfield,
     TWMLSetvar, TWMLBr, TWMLImg, TWMLAnchor, TWMLA, TWMLTable,
     TWMLTr, TWMLTd,
     TWMLEm, TWMLStrong, TWMLB, TWMLI, TWMLU, TWMLBig, TWMLSmall,
     TWMLInput, TWMLSelect, TWMLFieldSet, TWMLoptgroup, TWMLoption,
     TWMLpre,
     TwmlPCData, TxmlComment, TXMLDesc, TWMLDocDesc, TwmlServerSide, TxmlssScript);


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

// --------- TwmlDocDesc ---------

constructor TwmlDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= NOBINCODE;
  FAbstract:= False;
  // attribute collection
  FAttributes.AddAttribute('version', atNOSTRICTLIST, REQUIRED, '1.1', '1.1|1.2|1.3');
end;

//<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML 1.2//EN" "http://www.wapforum.org/DTD/wml12.dtd">
function TwmlDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  t: String;
begin
  // left align
  t:= ValidateLevel(ALevel);
  Result:= t + Format('<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML %s//EN" "http://www.wapforum.org/DTD/wml%s.dtd">',
    [FAttributes.ValueByName['version'], FAttributes.ValueByName['version']]);
end;

// --------- TwmlServerSide ---------

constructor TwmlServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TwmlPCData, wciAny);
end;

// --------- TwmlPCData ---------

// return what aligmnment assigned in parent paragraph
function TwmlPCData.TextAlignment: TAlignment;
var
  p: TWMLP;
  al: String;
begin
  Result:= DEFAULT_TEXTALIGNMENT;
  p:= TWMLP(GetParentByClass(TWMLP, TWMLCard));
  if Assigned(p) then begin
    al:= p.Attributes.ValueByName['align'];
    if CompareText(al, 'left') = 0
    then Result:= taLeftJustify
    else if CompareText(al, 'right') = 0
      then Result:= taRightJustify
      else if CompareText(al, 'center') = 0
        then Result:= taCenter;
  end;
end;

// return what warpping mode set in parent paragraph
function TwmlPCData.TextWrap: Boolean;
var
  p: TWMLP;
  wr: String;
begin
  Result:= DEF_WML_TEXTWRAP;
  p:= TWMLP(GetParentByClass(TWMLP, TWMLCard));
  if Assigned(p) then begin
    wr:= p.Attributes.ValueByName['mode'];
    Result:= CompareText(wr, 'wrap') = 0;
  end;
end;

// return context of TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall elements
function TwmlPCData.TextEmphasisis: TEmphasisis;
begin
  Result:= [];
  if Assigned(GetParentByClass(TWMLEm, TWMLP)) then begin
    Include(Result, emEm);
  end;
  if Assigned(GetParentByClass(TWMLStrong, TWMLP)) then begin
    Include(Result, emStrong);
  end;
  if Assigned(GetParentByClass(TWMLB, TWMLP)) then begin
    Include(Result, emB);
  end;
  if Assigned(GetParentByClass(TWMLI, TWMLP)) then begin
    Include(Result, emI);
  end;
  if Assigned(GetParentByClass(TWMLU, TWMLP)) then begin
    Include(Result, emU);
  end;
  if Assigned(GetParentByClass(TWMLBig, TWMLP)) then begin
    Include(Result, emBig);
  end;
  if Assigned(GetParentByClass(TWMLSmall, TWMLP)) then begin
    Include(Result, emSmall);
  end;
end;

// --------- TWMLBaseElement can contain comments ---------

constructor TWMLBaseElement.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= True;
  // FNestedElements.AddNew(TxmlComment, wciAny);

  // attribute collection
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('class', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  // server extension
  if wcServerExtensions in xmlEnv.XMLCapabilities then begin
    FAttributes.AddAttribute('loop', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('first', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('last', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('move', atNumber, IMPLIED, NODEFAULT, NOLIST);

    FNestedElements.AddNew(TwmlBracket, wciAny);
  end;
end;

// --------- TWML_Lang ---------

constructor TWML_Lang.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= True;
  FAttributes.AddAttribute('xml:lang', atLang, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWMLWML ---------

constructor TWMLWML.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $3F;
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);

  FNestedElements.AddNew(TWMLHead, wciAny);
  FNestedElements.AddNew(TWMLTemplate, wciAny);
  FNestedElements.AddNew(TWMLCard, wciOneOrMore);
  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TwmlServerSide, wciAny);
end;

function TWMLWML.CanInsertElement(AElementClass: TPersistentClass): Boolean;
begin
  Result:= inherited CanInsertElement(AElementClass);
end;

// --------- TWMLHead ---------

constructor TWMLHead.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $2C;
  // FAttributes.AddAttribute('onenterforward', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);

  FNestedElements.AddNew(TWMLAccess, wciOneOrMore);
  FNestedElements.AddNew(TWMLMeta, wciOneOrMore);
  FNestedElements.Cooperative:= wciOneOrMore;
end;

// --------- TWMLTemplate ---------

constructor TWMLTemplate.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);  // , 'template'
  FBinCode:= $3B;
  FAttributes.AddAttribute('onenterforward', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('onenterbackward', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('ontimer', atHREF, IMPLIED, NODEFAULT, NOLIST);

  FNestedElements.AddNew(TWMLDo, wciAny);
  FNestedElements.AddNew(TWMLOnEvent, wciAny);
end;

// --------- TWMLCard ---------

constructor TWMLCard.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);  // 'card'
  FBinCode:= $27;
  FAttributes.AddAttribute('title', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('newcontext', atList, IMPLIED, 'false', 'false|true');
  FAttributes.AddAttribute('ordered', atList, IMPLIED, 'true', 'false|true');
  FAttributes.AddAttribute('onenterforward', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('onenterbackward', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('ontimer', atHREF, IMPLIED, NODEFAULT, NOLIST);

  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);

  FNestedElements.AddNew(TWMLOnEvent, wciAny);
  FNestedElements.AddNew(TWMLTimer, wciOneOrNone);
  FNestedElements.AddNew(TWMLDo, wciAny);
  FNestedElements.AddNew(TWMLP, wciAny);
  // 1.3
  FNestedElements.AddNew(TWMLpre, wciAny);
  // server extension
  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TwmlServerSide, wciAny);
end;

// --------- TWMLAccess ---------

constructor TWMLAccess.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);  // , 'access'
  FBinCode:= $23;
  FAttributes.AddAttribute('domain', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('path', atCDATA, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWMLMeta ---------

constructor TWMLMeta.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);  // , 'meta'
  FBinCode:= $30;
  FAttributes.AddAttribute('http-equiv', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('name', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('forua', atLIST, IMPLIED, NODEFAULT, 'false|true');
  FAttributes.AddAttribute('content', atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('scheme', atCDATA, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWMLDo ---------

constructor TWMLDo.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $28;
  FNestedElements.AddNew(TWMLGo, wciOneOrNone);
  FNestedElements.AddNew(TWMLPrev, wciOneOrNone);
  FNestedElements.AddNew(TWMLNoop, wciOneOrNone);
  FNestedElements.AddNew(TWMLRefresh, wciOneOrNone);
  FNestedElements.Cooperative:= wciOne;

  FAttributes.AddAttribute('type', atNoStrictList, REQUIRED, NODEFAULT,
    'accept|prev|help|reset|options|delete|unknown');
  FAttributes.AddAttribute('label', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('name', atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('optional', atList, IMPLIED, 'false', 'false|true');
end;

// --------- TWMLOnEvent ---------

constructor TWMLOnEvent.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $33;
  FNestedElements.AddNew(TWMLGo, wciOneOrNone);
  FNestedElements.AddNew(TWMLPrev, wciOneOrNone);
  FNestedElements.AddNew(TWMLNoop, wciOneOrNone);
  FNestedElements.AddNew(TWMLRefresh, wciOneOrNone);
  FNestedElements.Cooperative:= wciOne;

  FAttributes.AddAttribute('type', atCDATA, REQUIRED, NODEFAULT, NOLIST);
end;

// --------- TWMLTimer ---------

constructor TWMLTimer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $3C;
  FAttributes.AddAttribute('name', atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('value', atVDATA, REQUIRED, NODEFAULT, NOLIST);
end;

// --------- TWMLP ---------

constructor TWMLP.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $20;
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);

  FNestedElements.AddNew(TwmlPCData, wciAny);
  FNestedElements.AddNew(TWMLBr, wciAny);
  FNestedElements.AddNew(TWMLImg, wciAny);
  FNestedElements.AddNew(TWMLAnchor, wciAny);
  FNestedElements.AddNew(TWMLA, wciAny);
  FNestedElements.AddNew(TWMLTable, wciAny);

  // emphasis
  FNestedElements.AddNew(TWMLEm, wciAny);
  FNestedElements.AddNew(TWMLStrong, wciAny);
  FNestedElements.AddNew(TWMLB, wciAny);
  FNestedElements.AddNew(TWMLI, wciAny);
  FNestedElements.AddNew(TWMLU, wciAny);
  FNestedElements.AddNew(TWMLBig, wciAny);
  FNestedElements.AddNew(TWMLSmall, wciAny);

  // input fields
  FNestedElements.AddNew(TWMLInput, wciAny);
  FNestedElements.AddNew(TWMLSelect, wciAny);
  FNestedElements.AddNew(TWMLFieldSet, wciAny);
  FNestedElements.AddNew(TWMLDo, wciAny);

  FAttributes.AddAttribute('align', atList, IMPLIED, 'left', 'left|right|center');
  FAttributes.AddAttribute('mode', atList, IMPLIED, DEF_WML_TEXTWRAP_VAL, 'wrap|nowrap');
end;

// --------- TWML_Emph ---------

constructor TWML_Emph.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TwmlPCData, wciAny);

  // all emphasis is available too
  FNestedElements.AddNew(TWMLEm, wciAny);
  FNestedElements.AddNew(TWMLStrong, wciAny);
  FNestedElements.AddNew(TWMLB, wciAny);
  FNestedElements.AddNew(TWMLI, wciAny);
  FNestedElements.AddNew(TWMLU, wciAny);
  FNestedElements.AddNew(TWMLBig, wciAny);
  FNestedElements.AddNew(TWMLSmall, wciAny);
  // all layout is available too
  FNestedElements.AddNew(TWMLBr, wciAny);

  FOption:=  elEmph;
  FAbstract:= True;
end;

// --------- TWMLEm ---------

constructor TWMLEm.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $29;
end;

// --------- TWMLStrong ---------

constructor TWMLStrong.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $39;
end;

// --------- TWMLB ---------

constructor TWMLB.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $24;
end;

// --------- TWMLI ---------

constructor TWMLI.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $2D;
end;

// --------- TWMLU ---------

constructor TWMLU.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $3D;
end;

// --------- TWMLBig ---------

constructor TWMLBig.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $25;
end;

// --------- TWMLSmall ---------

constructor TWMLSmall.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $38;
end;

// --------- TWML_Task ---------

constructor TWML_Task.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FOption:=  elTask;
  FAbstract:= True;
end;

// --------- TWMLGo ---------

constructor TWMLGo.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $2B;
  FNestedElements.AddNew(TWMLPostfield, wciAny);
  FNestedElements.AddNew(TWMLSetvar, wciAny);
  FNestedElements.Cooperative:= wciOneOrMore;

  FAttributes.AddAttribute('href', atHRef, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('sendreferer', atList, IMPLIED, 'false', 'false|true');
  FAttributes.AddAttribute('method', atList, IMPLIED, 'get', 'post|get');
  // 1.3
  // if WMLVersion >= '1.2' then
  FAttributes.AddAttribute('enctype', atNoStrictList, IMPLIED, DEFAULTENCTYPE, LSSTR_ENCTYPE);
  FAttributes.AddAttribute('cache-control', atNoStrictList, IMPLIED, 'no-cache', 'no-cache');
  // 1.3
  FAttributes.AddAttribute('accept-charset', atNoStrictList, IMPLIED, DEFAULTACCEPTCHARSET,
    'unknown|' + util_xml.GetListOfSupportedCharsetEncodings('|'));
end;

// --------- TWMLPrev ---------

constructor TWMLPrev.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $32;
  FNestedElements.AddNew(TWMLSetvar, wciAny);
end;
// --------- TWMLNoop ---------

constructor TWMLNoop.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $31;
end;

// --------- TWMLRefresh ---------

constructor TWMLRefresh.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $36;
  FNestedElements.AddNew(TWMLSetvar, wciAny);
end;

// --------- TWMLPostfield ---------

constructor TWMLPostfield.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $21;
  FAttributes.AddAttribute('name', atNMTOKEN, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('value', atVDATA, REQUIRED, NODEFAULT, NOLIST);
end;

// --------- TWMLSetvar ---------

constructor TWMLSetvar.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $3E;
  FAttributes.AddAttribute('name', atNMTOKEN, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('value', atVDATA, REQUIRED, NODEFAULT, NOLIST);
end;

// --------- TWML_Flow: {TWMLText} TWMLBr TWMLImg TWMLAnchor TWMLA TWMLTable ---------
// --------- TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall ---------
constructor TWML_Flow.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FOption:=  elFlow;
  FAbstract:= True;
end;

// --------- TWMLBr ---------

constructor TWMLBr.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $26;
end;

// --------- TWMLImg ---------

constructor TWMLImg.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $2E;
  FAttributes.AddAttribute('alt', atVData, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('src', atHREF, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('localsrc', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('vspace', atLength, IMPLIED, '0', NOLIST);
  FAttributes.AddAttribute('hspace', atLength, IMPLIED, '0', NOLIST);
  FAttributes.AddAttribute('align', atList, IMPLIED, 'bottom', 'top|middle|bottom');
  FAttributes.AddAttribute('height', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('width', atLength, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWMLAnchor ---------

constructor TWMLAnchor.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $22;
  FNestedElements.AddNew(TwmlPCData, wciAny);
  FNestedElements.AddNew(TWMLBr, wciAny);
  FNestedElements.AddNew(TWMLImg, wciAny);
  FNestedElements.AddNew(TWMLGo, wciAny);
  FNestedElements.AddNew(TWMLPrev, wciAny);
  FNestedElements.AddNew(TWMLRefresh, wciAny);
  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
  // 1.3 if WMLVersion >= '1.2' then
  FAttributes.AddAttribute('accesskey', atVData, IMPLIED, NODEFAULT, NOLIST);
  // 1.3
end;

// --------- TWMLA ---------

constructor TWMLA.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $1C;
  FNestedElements.AddNew(TwmlPCData, wciAny);
  FNestedElements.AddNew(TWMLBr, wciAny);
  FNestedElements.AddNew(TWMLImg, wciAny);
  FAttributes.AddAttribute('href', atHREF, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
  // 1.3 if WMLVersion >= '1.2' then
  FAttributes.AddAttribute('accesskey', atVData, IMPLIED, NODEFAULT, NOLIST);
  // 1.3
end;

// --------- TWMLTable ---------

constructor TWMLTable.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $1F;
  FNestedElements.AddNew(TWMLTr, wciAny);
  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('align', atCData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('columns', atNumber, REQUIRED, NODEFAULT, NOLIST);
end;

// --------- TWMLTr ---------

constructor TWMLTr.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $1E;
  FNestedElements.AddNew(TWMLTd, wciAny);
  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWMLTd ---------

constructor TWMLTd.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $1D;
  FNestedElements.AddNew(TwmlPCData, wciAny);
  FNestedElements.AddNew(TWMLBr, wciAny);
  FNestedElements.AddNew(TWMLImg, wciAny);
  FNestedElements.AddNew(TWMLAnchor, wciAny);
  FNestedElements.AddNew(TWMLA, wciAny);

  // emphasis
  FNestedElements.AddNew(TWMLEm, wciAny);
  FNestedElements.AddNew(TWMLStrong, wciAny);
  FNestedElements.AddNew(TWMLB, wciAny);
  FNestedElements.AddNew(TWMLI, wciAny);
  FNestedElements.AddNew(TWMLU, wciAny);
  FNestedElements.AddNew(TWMLBig, wciAny);
  FNestedElements.AddNew(TWMLSmall, wciAny);

  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWML_Field ---------

constructor TWML_Field.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FOption:=  elField;
  FAbstract:= True;
end;

// --------- TWMLInput ---------

constructor TWMLInput.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $2F;
  FAttributes.AddAttribute('name', atNMToken, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atList, IMPLIED, 'text', 'text|password');
  FAttributes.AddAttribute('value', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('format', atCData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('emptyok', atList, IMPLIED, 'false', 'false|true');
  FAttributes.AddAttribute('size', atNumber, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('maxlength', atNumber, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('tabindex', atNumber, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
  // 1.3
  // if WMLVersion >= '1.2' then
  FAttributes.AddAttribute('accesskey', atVData, IMPLIED, NODEFAULT, NOLIST);
  // 1.3
end;

// --------- TWMLSelect ---------

constructor TWMLSelect.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $37;
  FNestedElements.AddNew(TWMLoptgroup, wciOneOrMore);
  FNestedElements.AddNew(TWMLoption, wciOneOrMore);
  FNestedElements.Cooperative:= wciOneOrMore;

  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('name', atNMToken, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('value', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('iname', atNMToken, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('ivalue', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('multiple', atList, IMPLIED, 'false', 'false|true');
  FAttributes.AddAttribute('tabindex', atNumber, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWMLFieldSet ---------

constructor TWMLFieldSet.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $2A;
  // FNestedElements.AddNew(TWMLText, wciAny);
  FNestedElements.AddNew(TWMLBr, wciAny);
  FNestedElements.AddNew(TWMLImg, wciAny);
  FNestedElements.AddNew(TWMLAnchor, wciAny);
  FNestedElements.AddNew(TWMLA, wciAny);
  FNestedElements.AddNew(TWMLTable, wciAny);

  // emphasis
  FNestedElements.AddNew(TWMLEm, wciAny);
  FNestedElements.AddNew(TWMLStrong, wciAny);
  FNestedElements.AddNew(TWMLB, wciAny);
  FNestedElements.AddNew(TWMLI, wciAny);
  FNestedElements.AddNew(TWMLU, wciAny);
  FNestedElements.AddNew(TWMLBig, wciAny);
  FNestedElements.AddNew(TWMLSmall, wciAny);

  // input fields
  FNestedElements.AddNew(TWMLInput, wciAny);
  FNestedElements.AddNew(TWMLSelect, wciAny);
  FNestedElements.AddNew(TWMLFieldSet, wciAny);
  FNestedElements.AddNew(TWMLDo, wciAny);

  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWMLoptgroup ---------

constructor TWMLoptgroup.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $34;
  FNestedElements.AddNew(TWMLOptGroup, wciAny);
  FNestedElements.AddNew(TWMLOption, wciAny);

  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWMLoption ---------

constructor TWMLoption.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $35;
  FNestedElements.AddNew(TwmlPCData, wciAny);
  FNestedElements.AddNew(TWMLOnEvent, wciAny);

  FAttributes.AddAttribute('value', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('title', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('onpick', atHREF, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TWMLpre ---------

constructor TWMLpre.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FBinCode:= $1B;
  FNestedElements.AddNew(TwmlPCData, wciAny);
  FNestedElements.AddNew(TWMLBr, wciAny);
//FNestedElements.AddNew(TWMLImg, wciAny); //!??
  FNestedElements.AddNew(TWMLAnchor, wciAny);
  FNestedElements.AddNew(TWMLA, wciAny);

  // emphasis
  FNestedElements.AddNew(TWMLEm, wciAny);
  FNestedElements.AddNew(TWMLStrong, wciAny);
  FNestedElements.AddNew(TWMLB, wciAny);
  FNestedElements.AddNew(TWMLI, wciAny);
  FNestedElements.AddNew(TWMLU, wciAny);
  FNestedElements.AddNew(TWMLBig, wciAny);
  FNestedElements.AddNew(TWMLSmall, wciAny);

  // user input elements
  FNestedElements.AddNew(TWMLInput, wciAny);
  FNestedElements.AddNew(TWMLSelect, wciAny);

  FAttributes.AddAttribute('xml:space', atCData, IMPLIED, NODEFAULT, 'preserve');
end;

// --------- TwmlContainer ---------

constructor TwmlContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TWMLWML, wciOne);
  FNestedElements.AddNew(TwmlDocDesc, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TwmlServerSide, wciAny);
end;

// --------- TWMLBracket ---------

constructor TWMLBracket.Create(ACollection: TCollection);
var
  e: Integer;
begin
  inherited Create(ACollection);
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    for e:= Low(WMLElements) + 2 to High(WMLElements) do begin
      FNestedElements.AddNew(WMLElements[e], wciAny);
    end;
  end;
end;

// --------- GetDocumentTitle ---------

{
  GetDocumentTitle() calls xml parser
}

function GetDocumentTitle(const ASrc: WideString): String;
label
  fin;
var
  WmlCollection: TxmlElementCollection;
begin
  Result:= '';
  WmlCollection:= TxmlElementCollection.Create(TWmlContainer, Nil, wciOne);
  with WmlCollection do begin
    Clear1;
    // take a look at yhe FIRST card
    xmlParse.xmlCompileText(ASrc, Nil, Nil, Nil, Items[0], TWmlContainer, TWmlCard);
    Result:= Items[0].NestedElementAttribute[TWmlCard, 0, 'title'];
  end;
fin:
  WmlCollection.Free;
end;


// register xml schema used by xmlsupported

// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 0;
    len:= 44; // last is 43, next 44
    classes:= @WMLElements;
    DocType:= edWML;

    xmlElementClass:= TwmlContainer;
    xmlPCDataClass:= TwmlPCData;
    DocDescClass:= TwmlDocDesc;

    deficon:= ofs;
    defaultextension:= 'wml';
    desc:= 'wireless markup language source document';
    extensionlist:= 'wml|wmlc|wmlt';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.
