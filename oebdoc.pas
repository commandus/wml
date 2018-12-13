unit
  oebdoc;
(*##*)
(*******************************************************************************
*                                                                             *
*   o  e  b  d  o  c                                                           *
*                                                                             *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                       *
*   open eBook publication xml classes                                        *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Oct 20 2002                                                 *
*   Last fix     : Oct 21 2002                                                *
*   Lines        : 1037                                                        *
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
  DEF_OEB_TEXTWRAP: Boolean = True;

type
  ToebDocDesc = class(TDocDesc)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  ToebServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  ToebBracket = class(TBracket)
  public
    constructor Create(ACollection: TCollection); override;
  end;
  
  ToebPCData = class(TxmlPCData)
  public
    // return what aligmnment assigned in parent paragraph
    function TextAlignment: TAlignment; override;
    function TextWrap: Boolean; override;
    // return context of TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall elements
    function TextEmphasisis: TEmphasisis; override;
  end;

  TOEB_Base = class(TxmlElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEB_BaseComment = class(TOEB_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEB_Core = class(TOEB_BaseComment)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEB_Lang = class(TOEB_BaseComment)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEB_Common = class(TOEB_Core)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEB_CommonInlineBlock = class(TOEB_Common)
  private
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

// --------- OEBDoc elements implementation ---------

  ToebContainer = class(TxmlContainer)
  public
    constructor Create(ACollection: TCollection); override;
  end;


  // flow pcdata and text

  TOEB_Flow = class(TOEB_CommonInlineBlock)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // InlineElements: %PhraseElements %FontStyleElements | a | br | span | img | object | map

  TOEBBr = class(TOEB_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBSpan = class(TOEB_CommonInlineBlock)
  end;

  TOEBB = class(TOEB_CommonInlineBlock)
  end;

  TOEBBig = class(TOEB_CommonInlineBlock)
  end;

  TOEBI = class(TOEB_CommonInlineBlock)
  end;

  TOEBSmall = class(TOEB_CommonInlineBlock)
  end;

  TOEBSub = class(TOEB_CommonInlineBlock)
  end;

  TOEBSup = class(TOEB_CommonInlineBlock)
  end;

  // FontStyleElements tt | i | b | big | small | u | s | strike |font

  TOEBTT = class(TOEB_CommonInlineBlock)
  end;

  TOEBFont = class(TOEB_CommonInlineBlock)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBS = class(TOEB_CommonInlineBlock)
  end;

  TOEBStrike = class(TOEB_CommonInlineBlock)
  end;

  TOEBU = class(TOEB_CommonInlineBlock)
  end;

  TOEBCite = class(TOEB_CommonInlineBlock)
  end;

  TOEBCode = class(TOEB_CommonInlineBlock)
  end;

  TOEBDfn = class(TOEB_CommonInlineBlock)
  end;

  // PhraseElements em | strong | dfn | code | q | sub | sup | samp | kbd | var | cite

  TOEBEm = class(TOEB_CommonInlineBlock)
  end;

  TOEBKbd = class(TOEB_CommonInlineBlock)
  end;

  TOEBQ = class(TOEB_CommonInlineBlock)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBSamp = class(TOEB_CommonInlineBlock)
  end;

  TOEBStrong = class(TOEB_CommonInlineBlock)
  end;

  TOEBVar = class(TOEB_CommonInlineBlock)
  end;

  TOEBDiv = class(TOEB_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBP = class(TOEB_CommonInlineBlock)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBHR = class(TOEB_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBCenter = class(TOEB_Flow)
  end;

  TOEBBlockQuote = class(TOEB_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBPre = class(TOEB_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEB_H = class(TOEB_CommonInlineBlock)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBH1 = class(TOEB_H)
  end;

  TOEBH2 = class(TOEB_H)
  end;

  TOEBH3 = class(TOEB_H)
  end;

  TOEBH4 = class(TOEB_H)
  end;

  TOEBH5 = class(TOEB_H)
  end;

  TOEBH6 = class(TOEB_H)
  public
  end;

  TOEBScript = class(TOEB_BaseComment)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBStyle = class(TOEB_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBImg = class(TOEB_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBA = class(TOEB_CommonInlineBlock)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBBase = class(TxmlElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBLink = class(TOEB_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBMap = class(TOEB_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBArea = class(TOEB_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBObject = class(TOEB_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBParam = class(TOEB_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBDl = class(TOEB_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBDt = class(TOEB_Flow)
  end;

  TOEBDd = class(TOEB_Flow)
  end;

  // ListElements ul|ol|dl

  TOEBOl = class(TOEB_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBUl = class(TOEB_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBLi = class(TOEB_CommonInlineBlock)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBTable = class(TOEB_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBCaption = class(TOEB_CommonInlineBlock)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBTr = class(TOEB_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBTh = class(TOEB_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBTd = class(TOEB_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBTitle = class(TOEB_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBMeta = class(TOEB_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBHead = class(TOEB_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBBody = class(TOEB_Flow)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TOEBHTML = class(TOEB_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

// register xml schema used by xmlsupported

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;

implementation

uses
  util1,
  xmlParse; // for GetDocumentTitle() implementation - document is parsed

const
  LSSTR_ENCTYPE = 'application/x-wwwform-urlencoded|multipart/form-data';

  // <?xml-stylesheet ?> is missed
  OEBDocElements: array[0..67] of TxmlElementClass = (
     ToebContainer, ToebBracket, TOEBHTML, TOEBBody, TOEBHead,          //    65 64 63 62
     TOEBMeta, TOEBTitle,  TOEBTd, TOEBTh, TOEBTr,         // 61 60 59 58 57
     TOEBCaption,  TOEBTable, TOEBLi, TOEBUl,  TOEBOl,     // 56 55 54 53 52
     TOEBDd, TOEBDt, TOEBDl, TOEBParam, TOEBObject,        // 51 50 49 48 47
     TOEBArea, TOEBMap, TOEBLink, TOEBBase, TOEBA,         // 46 45 44 43 42
     TOEBImg, TOEBStyle, TOEBScript, TOEBH6, TOEBH5,       // 41 40 39 38 37
     TOEBH4, TOEBH3, TOEBH2, TOEBH1, TOEBPre,              // 36 35 34 33 32
     TOEBBlockQuote, TOEBCenter, TOEBHR, TOEBP,TOEBDiv,    // 31 30 29 28 27
     TOEBVar, TOEBStrong, TOEBSamp, TOEBQ, TOEBKbd,        // 26 25 24 23 22
     TOEBEm, TOEBDfn, TOEBCode, TOEBCite, TOEBU,           // 21 20 19 18 17
     TOEBStrike, TOEBS, TOEBFont, TOEBTT, TOEBSup,         // 16 15 14 13 12
     TOEBSub, TOEBSmall, TOEBI, TOEBBig, TOEBB,            // 11 10 9  8  7
     TOEBSpan, TOEBBr, TOEBPCData, TxmlComment, TXMLDesc,  // 6  5  4  3  2
     ToebDocDesc,  ToebServerSide, TxmlssScript);         // 1  0

// --------- TOEBVersion ---------
{
constructor TOEBVersion.Create;
begin
  inherited Create;
  Major:= 1;
  Minor:= 1;
  OEBDocCapabilities:= [];
end;

destructor TOEBVersion.Destroy;
begin
  inherited Destroy;
end;
}

// --------- ToebDocDesc ---------

constructor ToebDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= False;

  // attribute collection
  FAttributes.AddAttribute('version', atCData, REQUIRED, '1.0.1', '1.0.1|');
end;

function ToebDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  t: String;
  i: Integer;
  s: String;
begin
  // left align
  t:= ValidateLevel(ALevel);
  s:= FAttributes.ValueByName['version'];
  i:= 1;
  while i <= Length(s) do begin
    if s[i] = '.'
    then Delete(s, i, 1)
    else Inc(i);
  end;
  Result:= t + Format('<!DOCTYPE html PUBLIC "+//ISBN 0-9673008-1-9//DTD OEB %s Document//EN" "http://openebook.org/dtds/oeb-%s/oebdoc%s.dtd">',
    [FAttributes.ValueByName['version'], FAttributes.ValueByName['version'], s]);
end;

// --------- ToebServerSide ---------

constructor ToebServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(ToebPCData, wciAny);
end;

// --------- ToebPCData ---------

// return what aligmnment assigned in parent paragraph
function ToebPCData.TextAlignment: TAlignment;
var
  p: TOEBP;
  al: String;
begin
  Result:= DEFAULT_TEXTALIGNMENT;
  p:= TOEBP(GetParentByClass(TOEBP, TOEBHTML));
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
function ToebPCData.TextWrap: Boolean;
var
  p: TOEBP;
  wr: String;
begin
  Result:= DEF_OEB_TEXTWRAP;
  p:= TOEBP(GetParentByClass(TOEBP, TOEBHTML));
  if Assigned(p) then begin
    wr:= p.Attributes.ValueByName['mode'];
    Result:= CompareText(wr, 'wrap') = 0;
  end;
end;

// return context of TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall elements
function ToebPCData.TextEmphasisis: TEmphasisis;
begin
  Result:= [];
  if Assigned(GetParentByClass(ToebEm, ToebP)) then begin
    Include(Result, emEm);
  end;
  if Assigned(GetParentByClass(ToebStrong, ToebP)) then begin
    Include(Result, emStrong);
  end;
  if Assigned(GetParentByClass(ToebB, ToebP)) then begin
    Include(Result, emB);
  end;
  if Assigned(GetParentByClass(ToebI, ToebP)) then begin
    Include(Result, emI);
  end;
  if Assigned(GetParentByClass(ToebU, ToebP)) then begin
    Include(Result, emU);
  end;
  if Assigned(GetParentByClass(ToebBig, ToebP)) then begin
    Include(Result, emBig);
  end;
  if Assigned(GetParentByClass(ToebSmall, ToebP)) then begin
    Include(Result, emSmall);
  end;
end;

// --------- TOEB_Base can contain comments ---------

constructor TOEB_Base.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= True;

  // attribute collection
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('class', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  // server extension
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    FAttributes.AddAttribute('loop', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('first', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('last', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('move', atNumber, IMPLIED, NODEFAULT, NOLIST);

    FNestedElements.AddNew(ToebBracket, wciAny);
  end;
end;

// --------- TOEB_BaseComment ---------

constructor TOEB_BaseComment.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);
end;

// --------- TOEB_Core ---------

constructor TOEB_Core.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= True;
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAttributes.AddAttribute('class', atCDATA, IMPLIED, NODEFAULT, NOLIST); // List of classes.
  FAttributes.AddAttribute('style', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Style data.
  FAttributes.AddAttribute('title', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Title or additional information.
end;

// --------- TOEB_Lang ---------

constructor TOEB_Lang.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= True;
  FAttributes.AddAttribute('xml:lang', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
end;

// --------- TOEB_Common ---------

constructor TOEB_Common.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= True;
end;

// --------- TOEB_Common ---------

constructor TOEB_CommonInlineBlock.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= True;
  // %InlineElements em|strong|dfn|code|q|sub|sup|samp|kbd|var|cite|tt|i|b|big|small|u|s|strike|font|a|br|span|img|object|map
  FNestedElements.AddNew(TOEBPCData, wciAny);
  FNestedElements.AddNew(TOEBEm, wciAny);
  FNestedElements.AddNew(TOEBStrong, wciAny);
  FNestedElements.AddNew(TOEBDfn, wciAny);
  FNestedElements.AddNew(TOEBCode, wciAny);
  FNestedElements.AddNew(TOEBQ, wciAny);
  FNestedElements.AddNew(TOEBSub, wciAny);
  FNestedElements.AddNew(TOEBSup, wciAny);
  FNestedElements.AddNew(TOEBSamp, wciAny);
  FNestedElements.AddNew(TOEBKbd, wciAny);
  FNestedElements.AddNew(TOEBVar, wciAny);
  FNestedElements.AddNew(TOEBCite, wciAny);
  FNestedElements.AddNew(TOEBTt, wciAny);
  FNestedElements.AddNew(TOEBI, wciAny);
  FNestedElements.AddNew(TOEBB, wciAny);
  FNestedElements.AddNew(TOEBBig, wciAny);
  FNestedElements.AddNew(TOEBSmall, wciAny);
  FNestedElements.AddNew(TOEBU, wciAny);
  FNestedElements.AddNew(TOEBS, wciAny);
  FNestedElements.AddNew(TOEBStrike, wciAny);
  FNestedElements.AddNew(TOEBFont, wciAny);
  FNestedElements.AddNew(TOEBA, wciAny);
  FNestedElements.AddNew(TOEBBr, wciAny);
  FNestedElements.AddNew(TOEBSpan, wciAny);
  FNestedElements.AddNew(TOEBImg, wciAny);
  FNestedElements.AddNew(TOEBObject, wciAny);
  FNestedElements.AddNew(TOEBMap, wciAny);
  // %BlockOrInlineElements
  FNestedElements.AddNew(TOEBScript, wciAny);
end;

// --------- ToebContainer ---------

constructor ToebContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(ToebHTML, wciOne);
  FNestedElements.AddNew(ToebDocDesc, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(ToebServerSide, wciAny);
end;

// --------- TOEBHTML ---------

constructor TOEBHTML.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
//  FNestedElements.AddNew(TxmlComment, wciAny);
//  FNestedElements.AddNew(TxmlSSScript, wciAny);
  FNestedElements.AddNew(TOEBHead, wciOneOrNone);
  FNestedElements.AddNew(TOEBBody, wciOne);
  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(ToebServerSide, wciAny);
end;

// --------- TOEBBody ---------

constructor TOEBBody.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('bgcolor', atColor, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('text', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FNestedElements.Cooperative:= wciAny;
end;


// --------- TOEBHead ---------

constructor TOEBHead.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // <!ELEMENT head ((%HeadElements;)*, ((title, (%HeadElements;)*, (base, (%HeadElements;)*)?) | (base, (%HeadElements;)*, (title, (%HeadElements;)*))))
  // script | style | meta | link | object
//  FNestedElements.AddNew(TxmlComment, wciAny);
//  FNestedElements.AddNew(TxmlSSScript, wciAny);

  FNestedElements.AddNew(TOEBTitle, wciOneOrNone);
  FNestedElements.AddNew(TOEBBase, wciOneOrNone);

  FNestedElements.AddNew(TOEBScript, wciAny);
  FNestedElements.AddNew(TOEBStyle, wciAny);
  FNestedElements.AddNew(TOEBMeta, wciAny);
  FNestedElements.AddNew(TOEBLink, wciAny);
  FNestedElements.AddNew(TOEBObject, wciAny);

  FNestedElements.Cooperative:= wciAny;
end;

// --------- TOEBMeta ---------

constructor TOEBMeta.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
//  FAbstract:= False;
  // Lang attributes
  FAttributes.AddAttribute('xml:lang', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  // meta attributes
  // name  content scheme
  FAttributes.AddAttribute('name', atNmToken, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('content', atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('scheme', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  // FNestedElements.AddNew(TOEBPCDATA, wciNone);
end;

// --------- TOEBTitle ---------

constructor TOEBTitle.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TOEBPCData, wciOneOrNone);
  // server extension
  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(ToebServerSide, wciAny);
  FNestedElements.Cooperative:= wciOneOrNone; // actually wciOne
end;

// --------- TOEBTd ---------

constructor TOEBTd.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('abbr', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('rowspan', atNumber, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute('colspan', atNumber, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute('align', atList, IMPLIED, NODEFAULT, 'left|center|right|justify');
  FAttributes.AddAttribute('valign', atList, REQUIRED, NODEFAULT, 'top|middle|bottom');
  FAttributes.AddAttribute('nowrap', atList, IMPLIED, NODEFAULT, '|nowrap');
  FAttributes.AddAttribute('bgcolor', atColor, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('width', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('height', atLength, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TOEBTh ---------

constructor TOEBTh.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('abbr', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('rowspan', atNumber, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute('colspan', atNumber, IMPLIED, '1', NOLIST);
  FAttributes.AddAttribute('align', atList, IMPLIED, NODEFAULT, 'left|center|right|justify');
  FAttributes.AddAttribute('valign', atList, REQUIRED, NODEFAULT, 'top|middle|bottom');
  FAttributes.AddAttribute('nowrap', atList, IMPLIED, NODEFAULT, '|nowrap');
  FAttributes.AddAttribute('bgcolor', atColor, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('width', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('height', atLength, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TOEBTr ---------

constructor TOEBTr.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);

  FAttributes.AddAttribute('valign', atList, IMPLIED, NODEFAULT, 'top|middle|bottom');
  FAttributes.AddAttribute('bgcolor', atColor, IMPLIED, NODEFAULT, NOLIST);

  FNestedElements.AddNew(TOEBTh, wciOneOrMore);
  FNestedElements.AddNew(TOEBTd, wciOneOrMore);

  FNestedElements.Cooperative:= wciOneOrMore;
end;

// --------- TOEBCaption ---------

constructor TOEBCaption.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
end;

// --------- TOEBTable ---------

constructor TOEBTable.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('summary', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('width', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('border', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('cellspacing', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('cellpadding', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('align', atList, IMPLIED, NODEFAULT, 'left|center|right|justify');
  FAttributes.AddAttribute('bgcolor', atColor, IMPLIED, NODEFAULT, NOLIST);

  FNestedElements.AddNew(TOEBCaption, wciOneOrNone);
  FNestedElements.AddNew(TOEBTr, wciOneOrMore);
end;

// --------- TOEBLi ---------

constructor TOEBLi.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('type', atList, IMPLIED, NODEFAULT, '1|a|A|i|I');
end;

// --------- TOEBDoUl ---------

constructor TOEBUl.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TOEBLi, wciOneOrMore);
end;

// --------- TOEBOl ---------

constructor TOEBOl.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('type', atList, IMPLIED, NODEFAULT, '1|a|A|i|I');
  FNestedElements.AddNew(TOEBLi, wciOneOrMore);
end;

// --------- TOEBParam ---------

constructor TOEBParam.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('name', atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('value', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('valuetype', atLIST, IMPLIED, 'data', 'data|ref|object');
  FAttributes.AddAttribute('mediatype', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FNestedElements.Cooperative:= wciOneOrNone; // actually wciNone
end;

// --------- TOEBDl ---------

constructor TOEBDl.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TOEBDt, wciOneOrMore);
  FNestedElements.AddNew(TOEBDl, wciOneOrMore);
end;

// --------- TOEBObject ---------

constructor TOEBObject.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('classid', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('codebase', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('data', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('codetype', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('archive', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('height', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('width', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('usemap', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('align', atList, IMPLIED, NODEFAULT, 'top|middle|bottom|left|right');
  FAttributes.AddAttribute('border', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('hspace', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('vspace', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FNestedElements.Cooperative:= wciOneOrNone; // actually wciNone
end;

// --------- TOEBArea ---------

constructor TOEBArea.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // core attributes
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAttributes.AddAttribute('class', atCDATA, IMPLIED, NODEFAULT, NOLIST); // List of classes.
  FAttributes.AddAttribute('style', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Style data.
  FAttributes.AddAttribute('title', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Title or additional information.
  // area attributes
  FAttributes.AddAttribute('href', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('shape', atList, IMPLIED, 'rect', 'rect|circle|poly|default');
  FAttributes.AddAttribute('coords', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('nohref', atLIST, IMPLIED, NODEFAULT, 'nohref');
  FAttributes.AddAttribute('alt', atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FNestedElements.Cooperative:= wciOneOrNone; // actually wciNone
end;

// --------- TOEBMap ---------
// -- same as flow except no PCDATA and id attribute is required
constructor TOEBMap.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.ItemByName['id'].Required:= True;
  FAttributes.AddAttribute('name', atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);

  FNestedElements.Delete(FNestedElements.GetIndexByClass(TOEBPCData));
end;

// --------- TOEBLink ---------

constructor TOEBLink.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // core attributes
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAttributes.AddAttribute('class', atCDATA, IMPLIED, NODEFAULT, NOLIST); // List of classes.
  FAttributes.AddAttribute('style', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Style data.
  FAttributes.AddAttribute('title', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Title or additional information.
  // link attributes
  FAttributes.AddAttribute('href', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atCDATA, REQUIRED, NODEFAULT, NOLIST);  // An RFC2045 media type
  FAttributes.AddAttribute('rel', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('rev', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('media', atCDATA, IMPLIED, NODEFAULT, NOLIST);  // Intended media destination

  FNestedElements.Cooperative:= wciOneOrNone; // actually wciNone
end;

// --------- TOEBBase ---------

constructor TOEBBase.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('href', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FNestedElements.Cooperative:= wciOneOrNone; // actually wciNone
end;

// --------- TOEBA ---------

constructor TOEBA.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // except <a> itself
  FNestedElements.Delete(FNestedElements.GetIndexByClass(TOEBA));

  FAttributes.AddAttribute('name', atNMTOKEN, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('href', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('rel', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('rev', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FNestedElements.Cooperative:= wciOneOrNone; // actually wciNone
end;

// --------- TOEBImg ---------

constructor TOEBImg.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // core attributes
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAttributes.AddAttribute('class', atCDATA, IMPLIED, NODEFAULT, NOLIST); // List of classes.
  FAttributes.AddAttribute('style', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Style data.
  FAttributes.AddAttribute('title', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Title or additional information.
  // img attributes
  FAttributes.AddAttribute('align', atList, IMPLIED, NODEFAULT, 'top|middle|bottom|left|right');
  FAttributes.AddAttribute('border', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('hspace', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('vspace', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('src', atHREF, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('alt', atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('rev', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('longdesc', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('height', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('width', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('usemap', atHREF, IMPLIED, NODEFAULT, NOLIST);

  FNestedElements.Cooperative:= wciOneOrNone; // actually wciNone
end;

// --------- TOEBStyle ---------

constructor TOEBStyle.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);

  FAttributes.AddAttribute('type', atList, IMPLIED, 'text/x-oeb1-css', 'text/x-oeb1-css|text/css');
  FAttributes.AddAttribute('title', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('xml:space', atList, IMPLIED, 'preserve', 'preserve');

  FNestedElements.AddNew(TOEBPCDATA, wciOneOrNone);  // actually wciOne
  FNestedElements.Cooperative:= wciOneOrNone; // actually wciNone
end;

// --------- TOEBScript ---------

constructor TOEBScript.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);

  FAttributes.AddAttribute('xml:space', atList, IMPLIED, 'preserve', 'preserve');

  FNestedElements.AddNew(TOEBPCDATA, wciOneOrNone);  // actually wciOne
  // FNestedElements.Cooperative:= wciAny;
end;

// --------- TOEB_H ---------

constructor TOEB_H.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('align', atList, IMPLIED, NODEFAULT, 'left|center|right|justify');
//  FNestedElements.Cooperative:= wciAny;
end;

// --------- TOEBPre ---------

// allow to enter #PCDATA|em|strong|dfn|code|q|sub|sup|samp|kbd|var|cite|a|br|span|map|tt|i|b|u|s
//                       |k%PhraseElements                               |a..
constructor TOEBPre.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TOEBPCData, wciAny);
  FNestedElements.AddNew(TOEBEm, wciAny);
  FNestedElements.AddNew(TOEBStrong, wciAny);
  FNestedElements.AddNew(TOEBDfn, wciAny);
  FNestedElements.AddNew(TOEBCode, wciAny);
  FNestedElements.AddNew(TOEBQ, wciAny);
  FNestedElements.AddNew(TOEBSub, wciAny);
  FNestedElements.AddNew(TOEBSup, wciAny);
  FNestedElements.AddNew(TOEBSamp, wciAny);
  FNestedElements.AddNew(TOEBKbd, wciAny);
  FNestedElements.AddNew(TOEBVar, wciAny);
  FNestedElements.AddNew(TOEBCite, wciAny);

  FNestedElements.AddNew(TOEBA, wciAny);
  FNestedElements.AddNew(TOEBBr, wciAny);
  FNestedElements.AddNew(TOEBSpan, wciAny);
  FNestedElements.AddNew(TOEBMap, wciAny);
  FNestedElements.AddNew(TOEBTt, wciAny);
  FNestedElements.AddNew(TOEBI, wciAny);
  FNestedElements.AddNew(TOEBB, wciAny);
  FNestedElements.AddNew(TOEBU, wciAny);
  FNestedElements.AddNew(TOEBS, wciAny);
  FAttributes.AddAttribute('xml:space', atList, IMPLIED, 'preserve', 'preserve');
end;

// --------- TOEBBlockQuote ---------

constructor TOEBBlockQuote.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('cite', atHREF, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TOEBHr ---------

constructor TOEBHr.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // core attributes
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAttributes.AddAttribute('class', atCDATA, IMPLIED, NODEFAULT, NOLIST); // List of classes.
  FAttributes.AddAttribute('style', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Style data.
  FAttributes.AddAttribute('title', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Title or additional information.

  FAttributes.AddAttribute('align', atList, IMPLIED, NODEFAULT, 'left|center|right');
  FAttributes.AddAttribute('size', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('width', atLength, IMPLIED, NODEFAULT, NOLIST);
  FNestedElements.Cooperative:= wciOneOrNone; // actually wciNone
end;

// --------- TOEBP ---------

constructor TOEBP.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('align', atList, IMPLIED, NODEFAULT, 'left|center|right|justify');
end;

// --------- TOEBDiv ---------

constructor TOEBDiv.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('align', atList, IMPLIED, NODEFAULT, 'left|center|right|justify');
end;

// --------- TOEBQ ---------

constructor TOEBQ.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('cite', atHREF, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TOEBFont ---------

constructor TOEBFont.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAttributes.AddAttribute('size', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('color', atColor, IMPLIED, NODEFAULT, NOLIST);  
  FAttributes.AddAttribute('face', atCDATA, IMPLIED, NODEFAULT, NOLIST);
end;

// --------- TOEBBr ---------

constructor TOEBBr.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // core attributes
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAttributes.AddAttribute('class', atCDATA, IMPLIED, NODEFAULT, NOLIST); // List of classes.
  FAttributes.AddAttribute('style', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Style data.
  FAttributes.AddAttribute('title', atCDATA, IMPLIED, NODEFAULT, NOLIST); // Title or additional information.
  // Lang attributes
  FAttributes.AddAttribute('xml:lang', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  // br attributes
  FAttributes.AddAttribute('clear', atList, IMPLIED, 'none', 'left|all|right|none');
end;

constructor TOEB_Flow.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FOption:=  elFlow;
  FAbstract:= True;
  // ...h1|h2|h3|h4|h5|h6|ul|ol|dl|p|pre|hr|blockquote|center|div|table

  FNestedElements.AddNew(TOEBH1, wciAny);
  FNestedElements.AddNew(TOEBH2, wciAny);
  FNestedElements.AddNew(TOEBH3, wciAny);
  FNestedElements.AddNew(TOEBH4, wciAny);
  FNestedElements.AddNew(TOEBH5, wciAny);
  FNestedElements.AddNew(TOEBH6, wciAny);

  FNestedElements.AddNew(TOEBUl, wciAny);
  FNestedElements.AddNew(TOEBOl, wciAny);
  FNestedElements.AddNew(TOEBDl, wciAny);

  FNestedElements.AddNew(TOEBP, wciAny);
  FNestedElements.AddNew(TOEBPre, wciAny);
  FNestedElements.AddNew(TOEBHr, wciAny);
  FNestedElements.AddNew(TOEBBlockQuote, wciAny);
  FNestedElements.AddNew(TOEBCenter, wciAny);
  FNestedElements.AddNew(TOEBDiv, wciAny);
  FNestedElements.AddNew(TOEBTable, wciAny);

  // server extension
  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(ToebServerSide, wciAny);

  FNestedElements.AddNew(TOEBPCData, wciAny);
  FNestedElements.Cooperative:= wciAny;
end;

// --------- ToebBracket ---------

constructor ToebBracket.Create(ACollection: TCollection);
var
  e: Integer;
begin
  inherited Create(ACollection);
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    for e:= Low(OEBDocElements) + 2 to High(OEBDocElements) do begin
      FNestedElements.AddNew(OEBDocElements[e], wciAny);
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
  OEBCollection: TxmlElementCollection;
  e: TxmlElement;
begin
  Result:= '';
  OEBCollection:= TxmlElementCollection.Create(TOebContainer, Nil, wciOne);
  with OEBCollection do begin
    Clear1;
    xmlParse.xmlCompileText(ASrc, Nil, Nil, Nil, Items[0], TOebContainer, TOebTitle);
    Result:= Items[0].NestedElementText[TOebTitle, 0];
    Result:= e.Attributes.ValueByName['value'];
  end;
fin:
  OebCollection.Free;
end;

// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 50;
    len:= 68; // last is 117
    classes:= @OEBDocElements;
    DocType:= edOEB;

    xmlElementClass:= ToebContainer;
    xmlPCDataClass:= ToebPCData;
    DocDescClass:= ToebDocDesc;

    deficon:= ofs;
    defaultextension:= 'oeb';
    desc:= 'OEB Open eBook publication';
    extensionlist:= 'oeb|oebf|oebp|ebook';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.
