unit
  biotaxon;
(*##*)
(*******************************************************************************
*                                                                             *
*   b  i  o  t  a  x  o  n                                                     *
*                                                                             *
*   Copyright © 2003 Andrei Ivanov. All rights reserved.                       *
*   taxonomy xml                                                              *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Oct 12 2003                                                 *
*   Last fix     : Oct 12 2003                                                *
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

var
  DEF_PKG_TEXTWRAP: Boolean = True;

const
  LIST_TAXON = 'kingdom|subkingdom|phylum|division|subdivision|superclass|class|phylum|subphylum|infraclass|superorder|order|suborder|superfamily|family|subfamily|infrafamily|tribe|subtribe|genus|subgenus|section|species|taxon|outgroup';

type
  TTxnDocDesc = class(TDocDesc)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  TTxnServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnBracket = class(TBracket)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnPCData = class(TxmlPCData)
  public
    // return default values
    function TextAlignment: TAlignment; override;
    function TextWrap: Boolean; override;
    function TextEmphasisis: TEmphasisis; override;
  end;

  TTxn_Base = class(TxmlElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxn_Core = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxn_Lang = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxn_Common = class(TTxn_Core)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxn_Dc = class(TTxn_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- Taxon elements implementation ---------

  TTxnContainer = class(TxmlContainer)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnTaxon = class(TTxn_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnSys = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnTitle = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnSynonyms = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnAuthors = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnDistributions = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnPublications = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnPlants = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnSymbiosises = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnCollections = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- Taxon subelements implementation ---------

  TTxnXMetadata = class(TTxn_Common)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnMeta = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- Person elements implementation ---------

  TTxnPerson = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnName = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnDegree = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnPosition = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnInstitute = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnDepartment = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnPhone = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnMail = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnEmail = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnBirthday = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnDyingday = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- Publication elements implementation ---------

  TTxnPublication = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnOPF = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnRecord = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- Dublin core elements implementation ---------

  TTxnDCMetadata = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcTitle = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcIdentifier = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcContributor = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcCreator = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcSubject = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcDescription = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcPublisher = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcDate = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcType = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcFormat = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcSource = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcLanguage = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcRelation = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcCoverage = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TTxndcRights = class(TTxn_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- symbiosis elements implementation ---------

  TTxnSymbiosis = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnHosts = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnParasites = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- collection elements implementation ---------

  TTxnCollection = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnItem = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnSex = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnAge = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnCount = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnDate = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnType = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- distribution elements implementation ---------

  TTxnDistribution = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnArea = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnStay = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnLabel = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // area

  TTxnRegion = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnTerritory = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnLocation = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnSource = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnHorisont = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnSection = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnSquare = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnDepth = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnGear = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnSample = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnPoint = class(TTxn_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnLatitude = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnLongitude = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TTxnBase = class(TTxn_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- common elements implementation ---------

  TTxnDescription = class(TTxn_Lang)
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

  LST_MARCRELATOR = 'Adapter <adp>|Annotator <ann>|Arranger <arr>|Artist <art>|Associated name <asn>|'+
    'Author <aut>|Author in quotations or text extracts <aqt>|Author of afterword, colophon, etc. <aft>|'+
    'Author of introduction, etc. <aui>|Bibliographic antecedent <ant>|Book producer <bkp>|'+
    'Collaborator <clb>|Commentator <cmm>|Compiler <com>|Designer <dsr>|Editor <edt>|Illustrator <ill>|'+
    'Lyricist <lyr>|Metadata contact <mdc>|Musician <mus>|Narrator <nrt>|Other <oth>|Photographer <pht>|'+
    'Printer <prt>|Redactor <red>|Reviewer <rev>|Sponsor <spn>|Thesis advisor <ths>|Transcriber <trc>|'+
    '+Translator <trl>';
  LST_IDENTIFIERSCHEME = 'ISBN|DOI';
  LST_EVENT = 'creation|publication|modification';

  TaxonElements: array[0..78] of TxmlElementClass = (
    TTxnContainer, TTxnBracket,
    TTxnTaxon,
    TTxnSys,
    TTxnTitle,
    TTxnSynonyms,
    TTxnAuthors,
    TTxnDistributions,
    TTxnPublications,
    TTxnSymbiosises,
    TTxnCollections,
    TTxnPerson,
    TTxnDegree,
    TTxnPosition,
    TTxnInstitute,
    TTxnDepartment,
    TTxnPhone,
    TTxnMail, 
    TTxnEmail, 
    TTxnBirthday, 
    TTxnDyingday, 
    TTxnPublication,
    TTxnOPF,
    TTxnRecord,
    TTxnSymbiosis, 
    TTxnHosts, 
    TTxnParasites, 
    TTxnPlants, 
    TTxnCollection,
    TTxnItem, 
    TTxnSex,
    TTxnAge, 
    TTxnCount,
    TTxnDate, 
    TTxnType, 
    TTxnDistribution,
    TTxnArea,
    TTxnStay, 
    TTxnLabel, 
    TTxnRegion, 
    TTxnTerritory, 
    TTxnLocation, 
    TTxnHorisont, 
    TTxnSection, 
    TTxnSquare,
    TTxnSource, 
    TTxnDepth,
    TTxnGear,
    TTxnSample, 
    TTxnPoint, 
    TTxnLatitude,
    TTxnLongitude, 
    TTxnBase,
    TTxnDescription, 
    TTxnName, 
    TTxnDCMetadata,
    TTxnXMetadata, 
    TTxnMeta,
    TTxndcTitle,
    TTxndcIdentifier, 
    TTxndcContributor, 
    TTxndcCreator, 
    TTxndcSubject, 
    TTxndcDescription, 
    TTxndcPublisher, 
    TTxndcDate, 
    TTxndcType,
    TTxndcFormat,
    TTxndcSource,
    TTxndcLanguage,
    TTxndcRelation,
    TTxndcCoverage,
    TTxndcRights,
    TTxnPCData,
    TxmlComment,
    TXMLDesc,
    TTxnDocDesc,
    TTxnServerSide,
    TxmlssScript
);

// --------- TTxn_Base ---------

constructor TTxn_Base.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);

  // server extension
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    FAttributes.AddAttribute('loop', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('first', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('last', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('move', atNumber, IMPLIED, NODEFAULT, NOLIST);

    FNestedElements.AddNew(TtxnBracket, wciAny);
  end;
  FAbstract:= True;
end;

// --------- TTxn_Core ---------

constructor TTxn_Core.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // ID unique to the entire document.
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAbstract:= True;
end;

// --------- TTxn_Lang ---------

constructor TTxn_Lang.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // An RFC1766 language code.
  FAttributes.AddAttribute('xml:lang', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAbstract:= True;
end;

// --------- TTxn_Common ---------

constructor TTxn_Common.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // ID unique to the entire document inherited.
  // An RFC1766 language code.
  FAttributes.AddAttribute('xml:lang', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAbstract:= True;
end;

// --------- TTxn_Dc ---------

constructor TTxn_Dc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciAny);
  FAttributes.AddAttribute('xmlns:dc', atNoStrictList, IMPLIED, NODEFAULT, 'http://purl.org/dc/elements/1.0/');     
  FAbstract:= True;
end;

// --------- TTxnContainer ---------

constructor TTxnContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnTaxon, wciOne);
  FNestedElements.AddNew(TTxnDocDesc, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TTxnServerSide, wciAny);
end;

// --------- TTxnDocDesc ---------

constructor TTxnDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= False;
  // attribute collection
  FAttributes.AddAttribute('version', atCData, REQUIRED, '1.0', '0.1|1.0');
end;

function TTxnDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
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
  Result:= t + Format('<!DOCTYPE taxon PUBLIC "-//taxon//DTD taxon %s//EN" "http://ensen.sitc.ru/dtds/taxon-%s/taxon%s.dtd">',
    [FAttributes.ValueByName['version'], FAttributes.ValueByName['version'], s]);
end;

// --------- TTxnServerSide ---------

constructor TTxnServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciAny);
end;

// --------- TTxnPCData ---------

// return what aligmnment assigned in parent paragraph
function TTxnPCData.TextAlignment: TAlignment;
begin
  Result:= DEFAULT_TEXTALIGNMENT;
end;

// return what warpping mode set in parent paragraph
function TTxnPCData.TextWrap: Boolean;
begin
  Result:= DEF_PKG_TEXTWRAP;
end;

// return context of TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall elements
function TTxnPCData.TextEmphasisis: TEmphasisis;
begin
  Result:= [];
end;

// --------- TTxnTaxon ---------
{
<!ELEMENT taxon	(metadata, manifest, spine, tours?, guide?)>
<!ATTLIST taxon
  %CommonAttributes;
  unique-identifier   IDREF	#REQUIRED
  xmlns         %URI;   #FIXED  "http://openebook.org/namespaces/oeb-package/1.0/"
>
}

constructor TTxnTaxon.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  //
  // metadata, manifest, spine, tours?, guide?
  FNestedElements.AddNew(TTxnSys, wciOneOrMore);
  FNestedElements.AddNew(TTxnTitle, wciAny);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnSynonyms, wciOneOrNone);
  FNestedElements.AddNew(TTxnAuthors, wciOneOrNone);
  FNestedElements.AddNew(TTxnDistributions, wciOneOrNone);
  FNestedElements.AddNew(TTxnPublications, wciOneOrNone);
  FNestedElements.AddNew(TTxnDate, wciOneOrNone);
  FNestedElements.AddNew(TTxnPlants, wciOneOrNone);
  FNestedElements.AddNew(TTxnSymbiosises, wciOneOrNone);
  FNestedElements.AddNew(TTxnCollections, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('unique-identifier', atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('xmlns:taxon', atNoStrictList, IMPLIED, 'http://commandus.com/dtd/taxon/1.0/', 'http://commandus.com/dtd/taxon/1.0/');
  FAbstract:= False;
end;

// --------- TTxnSys ---------

constructor TTxnSys.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  // FAttributes.AddAttribute('unique-identifier', atID, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('name', atNOSTRICTLIST, IMPLIED, NODEFAULT, LIST_TAXON);
  FAttributes.AddAttribute('rank', atNumber, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnTitle ---------

constructor TTxnTitle.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAttributes.AddAttribute('option', atCData, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnSynonyms ---------

constructor TTxnSynonyms.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnName, wciOneOrMore);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnAuthors ---------

constructor TTxnAuthors.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPerson, wciOneOrMore);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnDistributions ---------

constructor TTxnDistributions.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnDistribution, wciOneOrMore);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnPublications ---------

constructor TTxnPublications.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPublication, wciOneOrMore);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnSymbiosises ---------

constructor TTxnSymbiosises.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnHosts, wciOneOrNone);
  FNestedElements.AddNew(TTxnParasites, wciOneOrNone);
  FNestedElements.AddNew(TTxnPlants, wciOneOrNone);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnCollections ---------

constructor TTxnCollections.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnCollection, wciOneOrMore);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnPerson ---------

constructor TTxnPerson.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnName, wciOneOrMore);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnDegree, wciAny);
  FNestedElements.AddNew(TTxnPosition, wciAny);
  FNestedElements.AddNew(TTxnInstitute, wciAny);
  FNestedElements.AddNew(TTxnDepartment, wciAny);
  FNestedElements.AddNew(TTxnPhone, wciAny);
  FNestedElements.AddNew(TTxnMail, wciAny);
  FNestedElements.AddNew(TTxnEmail, wciAny);
  FNestedElements.AddNew(TTxnBirthday, wciOneOrNone);
  FNestedElements.AddNew(TTxnDyingday, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('date', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('rel', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnDegree ---------

constructor TTxnDegree.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnPosition ---------

constructor TTxnPosition.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnInstitute ---------

constructor TTxnInstitute.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnDepartment ---------

constructor TTxnDepartment.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnPhone ---------

constructor TTxnPhone.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnMail ---------

constructor TTxnMail.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnEmail ---------

constructor TTxnEmail.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnBirthday ---------

constructor TTxnBirthday.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnDyingday ---------

constructor TTxnDyingday.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnPublication ---------

constructor TTxnPublication.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnOpf, wciOneOrNone);
  FNestedElements.AddNew(TTxnRecord, wciOneOrNone);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnDCMetadata, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  FNestedElements.AddNew(TTxnAuthors, wciAny);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('unique-identifier', atID, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnOPF ---------

constructor TTxnOPF.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnRecord ---------

constructor TTxnRecord.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAttributes.AddAttribute('href', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnSymbiosis ---------

constructor TTxnSymbiosis.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnTaxon, wciAny);
  FNestedElements.AddNew(TTxnPerson, wciAny);
  FNestedElements.AddNew(TTxnPublications, wciAny);
  FNestedElements.AddNew(TTxnRegion, wciAny);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHREF, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnHosts ---------

constructor TTxnHosts.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnSymbiosis, wciAny);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnParasites ---------

constructor TTxnParasites.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnSymbiosis, wciAny);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnPlants ---------

constructor TTxnPlants.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnSymbiosis, wciAny);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnCollection ---------

constructor TTxnCollection.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnItem, wciAny);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('name', atCData, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnItem ---------

constructor TTxnItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnSex, wciOneOrNone);
  FNestedElements.AddNew(TTxnAge, wciOneOrNone);
  FNestedElements.AddNew(TTxnCount, wciOneOrNone);
  FNestedElements.AddNew(TTxnDate, wciOneOrNone);
  FNestedElements.AddNew(TTxnAuthors, wciOneOrNone);
  FNestedElements.AddNew(TTxnType, wciOneOrNone);
  FNestedElements.AddNew(TTxnDistribution, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('unique-identifier', atID, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnSex ---------

constructor TTxnSex.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atList, IMPLIED, NODEFAULT, 'm|f');
  FAttributes.AddAttribute('ratio', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnAge ---------

constructor TTxnAge.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atLength, IMPLIED, NODEFAULT, 'm|f');
  FAttributes.AddAttribute('ratio', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnCount ---------

constructor TTxnCount.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atLength, IMPLIED, NODEFAULT, 'm|f');
  FAttributes.AddAttribute('ratio', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnDate ---------

constructor TTxnDate.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('ratio', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnType ---------

constructor TTxnType.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnDistribution ---------

constructor TTxnDistribution.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnArea, wciOneOrNone);
  FNestedElements.AddNew(TTxnStay, wciOneOrNone);
  FNestedElements.AddNew(TTxnLabel, wciOneOrNone);
  FNestedElements.AddNew(TTxnAuthors, wciOneOrNone);
  FNestedElements.AddNew(TTxnPublications, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('unique-identifier', atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnArea ---------

constructor TTxnArea.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnRegion, wciOneOrNone);
  FNestedElements.AddNew(TTxnTerritory, wciOneOrNone);
  FNestedElements.AddNew(TTxnLocation, wciOneOrNone);

  FNestedElements.AddNew(TTxnAuthors, wciOneOrNone);
  FNestedElements.AddNew(TTxnPublications, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('unique-identifier', atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('name', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnStay ---------

constructor TTxnStay.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnSource, wciOneOrNone);
  FNestedElements.AddNew(TTxnLocation, wciOneOrNone);
  FNestedElements.AddNew(TTxnHorisont, wciOneOrNone);
  FNestedElements.AddNew(TTxnSection, wciOneOrNone);
  FNestedElements.AddNew(TTxnSquare, wciOneOrNone);
  FNestedElements.AddNew(TTxnDepth, wciOneOrNone);
  FNestedElements.AddNew(TTxnDate, wciOneOrNone);
  FNestedElements.AddNew(TTxnGear, wciOneOrNone);
  FNestedElements.AddNew(TTxnSample, wciOneOrNone);

  FNestedElements.AddNew(TTxnAuthors, wciOneOrNone);
  FNestedElements.AddNew(TTxnPublications, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('unique-identifier', atID, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atNOSTRICTLIST, IMPLIED, NODEFAULT, 'station|vessel');
  FAbstract:= False;
end;

// --------- TTxnLabel ---------

constructor TTxnLabel.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnLatitude, wciOneOrNone);
  FNestedElements.AddNew(TTxnLongitude, wciOneOrNone);
  FNestedElements.AddNew(TTxnBase, wciOneOrNone);
  FNestedElements.AddNew(TTxnPoint, wciOneOrNone);

  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnRegion ---------

constructor TTxnRegion.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCDATA, wciOneOrNone);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnAuthors, wciOneOrNone);
  FNestedElements.AddNew(TTxnPublications, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atNOSTRICTLIST, IMPLIED, NODEFAULT, 'ocean|sea|basin');
  FAbstract:= False;
end;

// --------- TTxnTerritory ---------

constructor TTxnTerritory.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCDATA, wciOneOrNone);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnAuthors, wciOneOrNone);
  FNestedElements.AddNew(TTxnPublications, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atNOSTRICTLIST, IMPLIED, NODEFAULT, 'ocean|sea|basin');
  FAbstract:= False;
end;

// --------- TTxnLocation ---------

constructor TTxnLocation.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCDATA, wciOneOrNone);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnAuthors, wciOneOrNone);
  FNestedElements.AddNew(TTxnPublications, wciOneOrNone);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('name', atVData, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnHorisont ---------

constructor TTxnHorisont.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCDATA, wciOneOrNone);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atNOSTRICTLIST, IMPLIED, NODEFAULT, 'hydro|pelagy');
  FAbstract:= False;
end;

// --------- TTxnSection ---------

constructor TTxnSection.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCDATA, wciOneOrNone);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atNOSTRICTLIST, IMPLIED, NODEFAULT, 'hydro|pelagy');
  FAbstract:= False;
end;

// --------- TTxnSquare ---------

constructor TTxnSquare.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCDATA, wciOneOrNone);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atNOSTRICTLIST, IMPLIED, NODEFAULT, 'hydro|pelagy');
  FAbstract:= False;
end;

// --------- TTxnSource ---------

constructor TTxnSource.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCDATA, wciOneOrNone);
  FNestedElements.AddNew(TTxnDescription, wciAny);
  FNestedElements.AddNew(TTxnXMetadata, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('href', atHref, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('type', atNOSTRICTLIST, IMPLIED, NODEFAULT, 'log');
  FAbstract:= False;
end;

// --------- TTxnDepth ---------

constructor TTxnDepth.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('ratio', atLength, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnGear ---------

constructor TTxnGear.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('alt', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnSample ---------

constructor TTxnSample.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('alt', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnPoint ---------

constructor TTxnPoint.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('alt', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnLatitude ---------

constructor TTxnLatitude.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('alt', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnLongitude ---------

constructor TTxnLongitude.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('alt', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnBase ---------

constructor TTxnBase.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('value', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('alt', atCDATA, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('distance', atLENGTH, IMPLIED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('direction', atNOSTRICTLIST, IMPLIED, NODEFAULT, 'N|E|S|W');
  FAbstract:= False;
end;

// --------- TTxnDescription ---------

constructor TTxnDescription.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCDATA, wciOneOrNone);
  // attribute collection
  FAbstract:= False;
end;

// --------- TTxnName ---------

constructor TTxnName.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnPCData, wciOne);
  // attribute collection
  FAttributes.AddAttribute('option', atCData, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxnDCMetadata ---------
{
<!-- A dc-metadata section must have a dc:Title and a
  dc:Identifier, and optionally other dc:XXX elements, all in any
  order. -->
<!ELEMENT dc-metadata ((%DCMetadataOptionalElements;)*,
  ((dc:Title, (%DCMetadataOptionalElements; | dc:Title)*,
    (dc:Identifier, (%DCMetadataGeneralElements;)*)) |
  (dc:Identifier, (%DCMetadataOptionalElements; | dc:Identifier)*,
    (dc:Title, (%DCMetadataGeneralElements;)*))))
>
}
constructor TTxnDCMetadata.Create(ACollection: TCollection);
var
  ver: String;

begin
  inherited Create(ACollection);
  ver:= DTDVersion;
  if ver >= '1.2' then begin
    FNestedElements.AddNew(TTxndcTitle, wciOneOrMore);
    FNestedElements.AddNew(TTxndcIdentifier, wciOneOrMore)
  end else begin
    FNestedElements.AddNew(TTxndcTitle, wciOne);
    FNestedElements.AddNew(TTxndcIdentifier, wciOne);
  end;

  FNestedElements.AddNew(TTxndcContributor, wciOneOrNone);
  FNestedElements.AddNew(TTxndcCreator, wciOneOrNone);
  FNestedElements.AddNew(TTxndcSubject, wciOneOrNone);
  FNestedElements.AddNew(TTxndcDescription, wciOneOrNone);
  FNestedElements.AddNew(TTxndcPublisher, wciOneOrNone);
  FNestedElements.AddNew(TTxndcDate, wciOneOrNone);
  FNestedElements.AddNew(TTxndcType, wciOneOrNone);
  FNestedElements.AddNew(TTxndcFormat, wciOneOrNone);
  FNestedElements.AddNew(TTxndcSource, wciOneOrNone);
  FNestedElements.AddNew(TTxndcLanguage, wciOneOrNone);
  FNestedElements.AddNew(TTxndcRelation, wciOneOrNone);
  FNestedElements.AddNew(TTxndcCoverage, wciOneOrNone);
  FNestedElements.AddNew(TTxndcRights, wciOneOrNone);

  // attribute collection
  FAttributes.AddAttribute('xmlns:oebpackage', atNoStrictList, IMPLIED, NODEFAULT, 'http://openebook.org/namespaces/oeb-package/1.0/');
  FAbstract:= False;
end;

class function TTxnDCMetadata.GetElementName: String;
begin
  Result:= 'dc-metadata';
end;

// --------- TTxnXMetadata ---------
{
}
constructor TTxnXMetadata.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TTxnMeta, wciOneOrMore);
  // attribute collection none
  FAbstract:= False;
end;

class function TTxnXMetadata.GetElementName: String;
begin
  Result:= 'x-metadata';
end;

// --------- TTxnMeta ---------

constructor TTxnMeta.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('name', atNMToken, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('content', atCData, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('scheme', atCData, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TTxndcTitle ---------

constructor TTxndcTitle.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcTitle.GetElementName: String;
begin
  Result:= 'dc:Title';
end;

// --------- TTxndcIdentifier ---------

constructor TTxndcIdentifier.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('scheme', atNoStrictList, IMPLIED, NODEFAULT, LST_IDENTIFIERSCHEME);
  FAbstract:= False;
end;

class function TTxndcIdentifier.GetElementName: String;
begin
  Result:= 'dc:Identifier';
end;

// --------- TTxndcContributor ---------

constructor TTxndcContributor.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('role', atNoStrictList, IMPLIED, NODEFAULT, LST_MARCRELATOR);
  FAttributes.AddAttribute('file-as', atCData, IMPLIED, NODEFAULT, NOLIST);

  FAbstract:= False;
end;

class function TTxndcContributor.GetElementName: String;
begin
  Result:= 'dc:Contributor';
end;

// --------- TTxndcCreator ---------

constructor TTxndcCreator.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('role', atNoStrictList, IMPLIED, NODEFAULT, LST_MARCRELATOR);
  FAttributes.AddAttribute('file-as', atCData, IMPLIED, NODEFAULT, NOLIST);

  FAbstract:= False;
end;

class function TTxndcCreator.GetElementName: String;
begin
  Result:= 'dc:Creator';
end;

// --------- TTxndcSubject ---------

constructor TTxndcSubject.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcSubject.GetElementName: String;
begin
  Result:= 'dc:Subject';
end;

// --------- TTxndcDescription ---------

constructor TTxndcDescription.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcDescription.GetElementName: String;
begin
  Result:= 'dc:Description';
end;

// --------- TTxndcPublisher ---------

constructor TTxndcPublisher.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcPublisher.GetElementName: String;
begin
  Result:= 'dc:Publisher';
end;

// --------- TTxndcDate ---------

constructor TTxndcDate.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('event', atNoStrictList, IMPLIED, NODEFAULT, LST_EVENT);
  FAbstract:= False;
end;

class function TTxndcDate.GetElementName: String;
begin
  Result:= 'dc:Date';
end;

// --------- TTxndcType ---------

constructor TTxndcType.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcType.GetElementName: String;
begin
  Result:= 'dc:Type';
end;

// --------- TTxndcFormat ---------

constructor TTxndcFormat.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcFormat.GetElementName: String;
begin
  Result:= 'dc:Format';
end;

// --------- TTxndcSource ---------

constructor TTxndcSource.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcSource.GetElementName: String;
begin
  Result:= 'dc:Source';
end;

// --------- TTxndcLanguage ---------

constructor TTxndcLanguage.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcLanguage.GetElementName: String;
begin
  Result:= 'dc:Language';
end;

// --------- TTxndcRelation ---------

constructor TTxndcRelation.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcRelation.GetElementName: String;
begin
  Result:= 'dc:Relation';
end;

// --------- TTxndcCoverage ---------

constructor TTxndcCoverage.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcCoverage.GetElementName: String;
begin
  Result:= 'dc:Coverage';
end;

// --------- TTxndcRights ---------

constructor TTxndcRights.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TTxndcRights.GetElementName: String;
begin
  Result:= 'dc:Rights';
end;

// --------- TTxnBracket ---------

constructor TTxnBracket.Create(ACollection: TCollection);
var
  e: Integer;
begin
  inherited Create(ACollection);
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    for e:= Low(TaxonElements) + 2 to High(TaxonElements) do begin
      FNestedElements.AddNew(TaxonElements[e], wciAny);
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
  TxnCollection: TxmlElementCollection;
begin
  Result:= '';
  TxnCollection:= TxmlElementCollection.Create(TTxnContainer, Nil, wciOne);
  with TxnCollection do begin
    Clear1;
    xmlParse.xmlCompileText(ASrc, Nil, Nil, Nil, Items[0], TTxnContainer, TTxnSys);
    Result:= Items[0].NestedElementText[TTxnSys, 0];
  end;
fin:
  TxnCollection.Free;
end;

// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 260;  // xhtml last 252
    len:= 79; // last is 330
    classes:= @TaxonElements;
    DocType:= edTaxon;

    xmlElementClass:= TTxnContainer;
    xmlPCDataClass:= TTxnPCData;
    DocDescClass:= TTxnDocDesc;

    deficon:= ofs;
    defaultextension:= 'txn';
    desc:= 'Taxon file';
    extensionlist:= 'txn';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.
