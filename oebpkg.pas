unit
  oebpkg;
(*##*)
(*******************************************************************************
*                                                                             *
*   o  e  b  p  k  g                                                           *
*                                                                             *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                       *
*   open eBook publication xml classes                                        *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Oct 27 2002                                                 *
*   Last fix     : Oct 27 2002                                                *
*   Lines        : 3047                                                        *
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

type
  TPkgDocDesc = class(TDocDesc)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  TPkgServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgBracket = class(TBracket)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgPCData = class(TxmlPCData)
  public
    // return default values
    function TextAlignment: TAlignment; override;
    function TextWrap: Boolean; override;
    function TextEmphasisis: TEmphasisis; override;
  end;

  TPkg_Base = class(TxmlElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkg_Core = class(TPkg_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkg_Lang = class(TPkg_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkg_Common = class(TPkg_Core)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkg_Dc = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- OEB Pkg elements implementation ---------

  TPkgContainer = class(TxmlContainer)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  ToebPackage = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgMetaData = class(TPkg_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgManifest = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgSpine = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgTours = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgGuide = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgDCMetadata = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgXMetadata = class(TPkg_Common)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgMeta = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcTitle = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcIdentifier = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcContributor = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcCreator = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcSubject = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcDescription = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcPublisher = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcDate = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcType = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcFormat = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcSource = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcLanguage = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcRelation = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcCoverage = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgdcRights = class(TPkg_Dc)
  public
    class function GetElementName: String; override;
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgItem = class(TPkg_Lang)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgItemRef = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgTour = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgSite = class(TPkg_Common)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TPkgReference = class(TPkg_Common)
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

  OEBPkgElements: array[0..36] of TxmlElementClass = (
     TPkgContainer, TpkgBracket, ToebPackage, TPkgMetaData,
     TPkgManifest, TPkgItem,
     TPkgSpine, TPkgItemRef,
     TPkgTours, TPkgTour, TPkgSite, TPkgGuide, TPkgReference,
     TPkgXMetadata, TPkgMeta,
     TPkgDCMetadata,
     TPkgdcTitle, TPkgdcIdentifier, TPkgdcContributor, TPkgdcCreator, TPkgdcSubject,
     TPkgdcDescription, TPkgdcPublisher, TPkgdcDate, TPkgdcType, TPkgdcFormat,
     TPkgdcSource, TPkgdcLanguage, TPkgdcRelation, TPkgdcCoverage, TPkgdcRights,
     TPkgPCData, TxmlComment, TXMLDesc, TPkgDocDesc, TPkgServerSide, TxmlssScript);


// --------- TPkg_Base ---------

constructor TPkg_Base.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);

  FAttributes.AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST); // ID unique to the entire document.
  // server extension
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    FAttributes.AddAttribute('loop', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('first', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('last', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('move', atNumber, IMPLIED, NODEFAULT, NOLIST);

    FNestedElements.AddNew(TpkgBracket, wciAny);
  end;
  FAbstract:= True;
end;

// --------- TPkg_Core ---------

constructor TPkg_Core.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // ID unique to the entire document.
  FAbstract:= True;
end;

// --------- TPkg_Lang ---------

constructor TPkg_Lang.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // An RFC1766 language code.
  FAttributes.AddAttribute('xml:lang', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAbstract:= True;
end;

// --------- TPkg_Common ---------

constructor TPkg_Common.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // ID unique to the entire document inherited.
  // An RFC1766 language code.
  FAttributes.AddAttribute('xml:lang', atID, IMPLIED, NODEFAULT, NOLIST);       // ID unique to the entire document.
  FAbstract:= True;
end;

// --------- TPkg_Dc ---------

constructor TPkg_Dc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TPkgPCData, wciAny);
  FAttributes.AddAttribute('xmlns:dc', atNoStrictList, IMPLIED, NODEFAULT, 'http://purl.org/dc/elements/1.0/');     
  FAbstract:= True;
end;

// --------- TPkgContainer ---------

constructor TPkgContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(ToebPackage, wciOne);
  FNestedElements.AddNew(TPkgDocDesc, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TPkgServerSide, wciAny);
end;

// --------- TPkgDocDesc ---------

constructor TPkgDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= False;
  // attribute collection
  FAttributes.AddAttribute('version', atCData, REQUIRED, '1.0.1', '1.0.1|');
end;

function TPkgDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
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
  Result:= t + Format('<!DOCTYPE package PUBLIC "+//ISBN 0-9673008-1-9//DTD OEB %s Package//EN" "http://openebook.org/dtds/oeb-%s/oebpkg%s.dtd">',
    [FAttributes.ValueByName['version'], FAttributes.ValueByName['version'], s]);
end;

// --------- TPkgServerSide ---------

constructor TPkgServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TPkgPCData, wciAny);
end;

// --------- TPkgPCData ---------

// return what aligmnment assigned in parent paragraph
function TPkgPCData.TextAlignment: TAlignment;
begin
  Result:= DEFAULT_TEXTALIGNMENT;
end;

// return what warpping mode set in parent paragraph
function TPkgPCData.TextWrap: Boolean;
begin
  Result:= DEF_PKG_TEXTWRAP;
end;

// return context of TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall elements
function TPkgPCData.TextEmphasisis: TEmphasisis;
begin
  Result:= [];
end;

// --------- ToebPackage ---------
{
<!ELEMENT package	(metadata, manifest, spine, tours?, guide?)>
<!ATTLIST package
  %CommonAttributes;
  unique-identifier   IDREF	#REQUIRED
  xmlns         %URI;   #FIXED  "http://openebook.org/namespaces/oeb-package/1.0/"
>
}

constructor ToebPackage.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  //
  // metadata, manifest, spine, tours?, guide?

  FNestedElements.AddNew(TPkgMetadata, wciOne);
  FNestedElements.AddNew(TPkgManifest, wciOne);
  FNestedElements.AddNew(TPkgSpine, wciOne);
  FNestedElements.AddNew(TPkgTours, wciOneOrNone);
  FNestedElements.AddNew(TPkgGuide, wciOneOrNone);
  // attribute collection
  FAttributes.AddAttribute('unique-identifier', atID, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('xmlns', atNoStrictList, IMPLIED, 'http://openebook.org/namespaces/oeb-package/1.0/', 'http://openebook.org/namespaces/oeb-package/1.0/');
  FAbstract:= False;
end;

// --------- TPkgMetadata ---------
{
<!ELEMENT  metadata	(dc-metadata, x-metadata?)>

<!-- These elements are optional in <dc-metadata>. -->
<!ENTITY % DCMetadataOptionalElements
  "dc:Contributor  | dc:Creator | dc:Subject | dc:Description
  | dc:Publisher |  dc:Date | dc:Type | dc:Format | dc:Source
  | dc:Language | dc:Relation | dc:Coverage | dc:Rights"
>
}
constructor TPkgMetaData.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TPkgDcMetadata, wciOne);
  FNestedElements.AddNew(TPkgXMetadata, wciOneOrNone);
  // attribute collection none
  FAbstract:= False;
end;

// --------- TPkgDcMetadata ---------
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
constructor TPkgDcMetaData.Create(ACollection: TCollection);
var
  ver: String;

begin
  inherited Create(ACollection);
  ver:= DTDVersion;
  if ver >= '1.2' then begin
    FNestedElements.AddNew(TPkgDcTitle, wciOneOrMore);
    FNestedElements.AddNew(TPkgDcIdentifier, wciOneOrMore)
  end else begin
    FNestedElements.AddNew(TPkgDcTitle, wciOne);
    FNestedElements.AddNew(TPkgDcIdentifier, wciOne);
  end;

  FNestedElements.AddNew(TPkgdcContributor, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcCreator, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcSubject, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcDescription, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcPublisher, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcDate, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcType, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcFormat, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcSource, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcLanguage, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcRelation, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcCoverage, wciOneOrNone);
  FNestedElements.AddNew(TPkgdcRights, wciOneOrNone);

  // attribute collection
  FAttributes.AddAttribute('xmlns:oebpackage', atNoStrictList, IMPLIED, NODEFAULT, 'http://openebook.org/namespaces/oeb-package/1.0/');
  FAbstract:= False;
end;

class function TPkgDcMetaData.GetElementName: String;
begin
  Result:= 'dc-metadata';
end;

// --------- TPkgXMetadata ---------
{
}
constructor TPkgXMetadata.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TPkgMeta, wciOneOrMore);
  // attribute collection none
  FAbstract:= False;
end;

class function TPkgXMetadata.GetElementName: String;
begin
  Result:= 'x-metadata';
end;

// --------- TPkgMeta ---------

constructor TPkgMeta.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('name', atNMToken, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('content', atCData, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('scheme', atCData, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TPkgManifest ---------

constructor TPkgManifest.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TPkgItem, wciOneOrMore);
  // attribute collection
  FAbstract:= False;
end;

// --------- TPkgItem ---------

constructor TPkgItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('href', atCData, REQUIRED, NODEFAULT, NOLIST);  // Href?
  FAttributes.AddAttribute('media-type', atID, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('fallback', atID, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TPkgSpine ---------

constructor TPkgSpine.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TPkgItemRef, wciOneOrMore);
  // attribute collection none
  FAbstract:= False;
end;

// --------- TPkgItemRef ---------

constructor TPkgItemRef.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection none
  FAttributes.AddAttribute('idref', atID, REQUIRED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TPkgTours ---------

constructor TPkgTours.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TPkgTour, wciOneOrMore);
  // attribute collection none
  FAbstract:= False;
end;

// --------- TPkgTour ---------

constructor TPkgTour.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TPkgSite, wciOneOrMore);
  // attribute collection
  FAttributes.AddAttribute('title', atCDATA, REQUIRED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TPkgSite ---------

constructor TPkgSite.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection none
  FAttributes.AddAttribute('title', atCData, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('href', atCData, REQUIRED, NODEFAULT, NOLIST);

  FAbstract:= False;
end;

// --------- TPkgGuide ---------

constructor TPkgGuide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TPkgReference, wciOneOrMore);
  // attribute collection none
  FAbstract:= False;
end;

// --------- TPkgReference ---------

constructor TPkgReference.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('type', atNoStrictList, REQUIRED, NODEFAULT,
    'cover|title-page|toc|contents|index|glossary|acknowledgements|bibliography|'+
    'colophon|copyright-page|dedication|epigraph|foreword|list of illustrations<loi>|'+
    'list of tables<lot>|notes|preface|'+
    'other.ms-chaptertour|other.ms-copyright|other.ms-coverimage-standard|' +
    'other.ms-coverimage|other.ms-firstpage|other.ms-thumbimage-standard|other.ms-thumbimage|other.ms-titleimage-standard');  // atNMToken
  FAttributes.AddAttribute('title', atCData, REQUIRED, NODEFAULT, NOLIST);
  FAttributes.AddAttribute('href', atCData, REQUIRED, NODEFAULT, NOLIST);

  FAbstract:= False;
end;

// --------- TPkgdcTitle ---------

constructor TPkgdcTitle.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcTitle.GetElementName: String;
begin
  Result:= 'dc:Title';
end;

// --------- TPkgdcIdentifier ---------

constructor TPkgdcIdentifier.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('scheme', atNoStrictList, IMPLIED, NODEFAULT, LST_IDENTIFIERSCHEME);
  FAbstract:= False;
end;

class function TPkgdcIdentifier.GetElementName: String;
begin
  Result:= 'dc:Identifier';
end;

// --------- TPkgdcContributor ---------

constructor TPkgdcContributor.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('role', atNoStrictList, IMPLIED, NODEFAULT, LST_MARCRELATOR);
  FAttributes.AddAttribute('file-as', atCData, IMPLIED, NODEFAULT, NOLIST);

  FAbstract:= False;
end;

class function TPkgdcContributor.GetElementName: String;
begin
  Result:= 'dc:Contributor';
end;

// --------- TPkgdcCreator ---------

constructor TPkgdcCreator.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('role', atNoStrictList, IMPLIED, NODEFAULT, LST_MARCRELATOR);
  FAttributes.AddAttribute('file-as', atCData, IMPLIED, NODEFAULT, NOLIST);

  FAbstract:= False;
end;

class function TPkgdcCreator.GetElementName: String;
begin
  Result:= 'dc:Creator';
end;

// --------- TPkgdcSubject ---------

constructor TPkgdcSubject.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcSubject.GetElementName: String;
begin
  Result:= 'dc:Subject';
end;

// --------- TPkgdcDescription ---------

constructor TPkgdcDescription.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcDescription.GetElementName: String;
begin
  Result:= 'dc:Description';
end;

// --------- TPkgdcPublisher ---------

constructor TPkgdcPublisher.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcPublisher.GetElementName: String;
begin
  Result:= 'dc:Publisher';
end;

// --------- TPkgdcDate ---------

constructor TPkgdcDate.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAttributes.AddAttribute('event', atNoStrictList, IMPLIED, NODEFAULT, LST_EVENT);
  FAbstract:= False;
end;

class function TPkgdcDate.GetElementName: String;
begin
  Result:= 'dc:Date';
end;

// --------- TPkgdcType ---------

constructor TPkgdcType.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcType.GetElementName: String;
begin
  Result:= 'dc:Type';
end;

// --------- TPkgdcFormat ---------

constructor TPkgdcFormat.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcFormat.GetElementName: String;
begin
  Result:= 'dc:Format';
end;

// --------- TPkgdcSource ---------

constructor TPkgdcSource.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcSource.GetElementName: String;
begin
  Result:= 'dc:Source';
end;

// --------- TPkgdcLanguage ---------

constructor TPkgdcLanguage.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcLanguage.GetElementName: String;
begin
  Result:= 'dc:Language';
end;

// --------- TPkgdcRelation ---------

constructor TPkgdcRelation.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcRelation.GetElementName: String;
begin
  Result:= 'dc:Relation';
end;

// --------- TPkgdcCoverage ---------

constructor TPkgdcCoverage.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcCoverage.GetElementName: String;
begin
  Result:= 'dc:Coverage';
end;

// --------- TPkgdcRights ---------

constructor TPkgdcRights.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

class function TPkgdcRights.GetElementName: String;
begin
  Result:= 'dc:Rights';
end;

// --------- TPkgBracket ---------

constructor TPkgBracket.Create(ACollection: TCollection);
var
  e: Integer;
begin
  inherited Create(ACollection);
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    for e:= Low(OEBPkgElements) + 2 to High(OEBPkgElements) do begin
      FNestedElements.AddNew(OEBPkgElements[e], wciAny);
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
  PkgCollection: TxmlElementCollection;
  e: TxmlElement;
begin
  Result:= '';
  PkgCollection:= TxmlElementCollection.Create(TPkgContainer, Nil, wciOne);
  with PkgCollection do begin
    Clear1;

    xmlParse.xmlCompileText(ASrc, Nil, Nil, Nil, Items[0], TPkgContainer, TPkgdcTitle);
    e:= Items[0].NestedElement[TPkgDCTitle, 0];
    Result:= Items[0].NestedElementText[TPkgDCTitle, 0];
  end;
fin:
  PkgCollection.Free;
end;


// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 120;
    len:= 37; // last is 156
    classes:= @OEBPkgElements;
    DocType:= edPKG;

    xmlElementClass:= TpkgContainer;
    xmlPCDataClass:= TPkgPCData;
    DocDescClass:= TPkgDocDesc;

    deficon:= ofs;
    defaultextension:= 'opf';
    desc:= 'OPF Open eBook packaging file';
    extensionlist:= 'opf';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.
