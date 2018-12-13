unit
  util_xml;
(*##*)
(*******************************************************************************
*                                                                             *
*   u  t  i  l  _  x  m  l                                                     *
*                                                                             *
*   Copyright©2001-2004 Andrei Ivanov. All rights reserved.                    *
*   xml utility roitines                                                      *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2001                                                 *
*   Last fix     : Mar 29 2001                                                *
*                  Nov 25 2003  ShiftNodeElementsTextPositions rewritten       *
*                                                                             *
*   Lines        : 2171                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Classes, Windows, StrUtils, Types, Registry, SysUtils, ComCtrls, // TTreeNode
  jclUnicode, jclLocales,
  util1, customxml, xmlparse, oebDoc, oebPkg;

type
  TECharsetConversion = (convNone, convFull, convLine, convPCData);
  TEntityConv = (convEnEntity2Char, convEnChar2Entity, convEnRefCharset, convEnRemoveTrailingSpaces);
  { convEnEntity2Char - convert numeric entity to character
    convEnChar2Entity - convert non-ASCII character to the numeric entity
    convEnRefCharset  - all numeric character entities are referenced with respect to the Unicode and not to the current document encoding (charset).
  }
  TEntityConvOptions = set of TEntityConv;  //

function GetStringsFromFileFilter(const AFilter: String; AStyle: Integer; AResult: TStrings): Boolean;

function WMLEntityStr(const Src: WideString): WideString;
function XMLEntityStr(const Src: WideString): WideString;
function HTMLEntityStr(const Src: WideString): WideString;

function WMLExtractEntityStr(const Src: WideString; ACompressSpaces: Boolean = True): WideString;
// extended version
function HTMLExtractEntityStr(const Src: WideString): WideString;

// calculate new position APosition depending lines and chars in ATag text
procedure CalcTextColsRows(const ATag: String; var APosition: TPoint); overload;
procedure CalcTextColsRows(const ATag: WideString; var APosition: TPoint); overload;

procedure ShiftWMLElementTextPositions(AxmlElement: TxmlElement; const Tag: String);

procedure ShiftNodeElementsTextPositions(ANode: TTreeNode; Shift: TPoint);

function ParseDate(const DateStr: string; var isValid: Boolean): TDateTime;

function GetDateTimeStamp(ADt: TDateTime): String;

type
  TWideStringStream = class(TStream)
  private
    FDataString: WideString;
    FPosition: Integer;
  protected
    procedure SetSize(NewSize: Longint); override;
  public
    constructor Create(const AString: WideString);
    function Read(var Buffer; Count: Longint): Longint; override;
    function ReadWideString(Count: Longint): WideString;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure WriteWideString(const AString: WideString);
    property DataString: WideString read FDataString;
  end;

function GetListOfSupportedCharsetEncodings(const ADlmt: String): String;

// return 'en-us', 'ru' for english-american, russian language for windows language identifier
function winLangId2Abbr(ALCId: LCID): String;

// return windows language identifier for 'en-us', 'ru'
function winLangAbbr2Id(ALangAbbr: String): LCID;

// get wml source encoding (search for <xml encoding="utf-8"?>
// return ADefaultEncoding if not found or cannot resolve name of encoding code page
function GetEncoding(const AWMLSource: String; ADefaultEncoding: Integer): Integer;

// get wml source encoding (search for <xml encoding="utf-8"?>
// return '' if not found or cannot resolve name of encoding code page
function GetEncodingName(const AWMLSource: String): String;

{ convert utf-8 and other character set to unicode 2
  Parameters:
    ACharsetCode:   csusascii, csiso8859_1..csiso8859_9, csshift_JIS, csiso10646_ucs_2, csbig5, csUTF8
                    usually csUTF8
    S:              source string in indicated (e.g. utf-8) code page
  Returns:          2-byte wide string (unicode)
}
function CharSet2WideString(ACharsetCode: Integer; const S: String; AOptions: TEntityConvOptions): WideString;

function CharSet2WideStrings(ACharsetCode: Integer; S: String; AOptions: TEntityConvOptions): TWideStrings;
{ similar to CharSet2WideString except #13#10 instead widechar AStr separator is allowed
}
function CharSet2WideStringLine(ACharsetCode: Integer; S: String; AOptions: TEntityConvOptions): WideString;

{ convert unicode 2- byte wide string list to utf-8 or other character set string
  Parameters:
    ACharsetCode:   csusascii, csiso8859_1..csiso8859_9, csshift_JIS, csiso10646_ucs_2, csbig5, csUTF8
                    usually csUTF8
    W:              source 2- byte unicode wide string
  Returns:          string in code page has benn choosed
}

function WideString2EncodedString(AConversion: TECharsetConversion; AEncoding: Integer; ALines: TWideStrings; AOptions: TEntityConvOptions): String; overload;
function WideString2EncodedString(AConversion: TECharsetConversion; AEncoding: Integer; const ASrc: WideString; AOptions: TEntityConvOptions): String; overload;

{ simple remove wide line separator and insert CRLF pair instead
}
function WideStrings2CRLFString(ALines: TWideStrings): WideString;

{ simple remove wide line separator and insert CRLF pair instead
}
function WideString2CRLFString(const ASrc: WideString): WideString;

{ convert unicode 2- byte wide string to utf-8 or other character set string
  Parameters:
    ACharsetCode:   csusascii, csiso8859_1..csiso8859_9, csshift_JIS, csiso10646_ucs_2, csbig5, csUTF8
                    usually csUTF8
    W:              source 2- byte unicode wide string
  Returns:          string in code page has benn choosed
}
function Unicode2CharSet(ACharsetCode: Integer; const W: WideString; AOptions: TEntityConvOptions): String;

{---------------------------- Useless routines --------------------------------}

{ Tool. ISO 639 language codes.
  read text file AInFileName, parse and sort by language code each AStr consists of:

  Afar aa $01
  ...
  Rhaeto-Romance rm $8C
  ...

  Result file AOutFileName :
  ...
  $01 (d: 'aa'; n: 'Afar'),
  ...
}
procedure Tool_ReadLanguage2Pascal(AInFileName, AOutFileName: String);

{---------------------------- http header routines ----------------------------}

function GetHeaderName(var AContent: PChar): String;

{ Extract header string to list of values. Extensions stored in AExt
  Parameter:
    Content: Accept: text/plain; q=0.3, text/html; q=0.7...
  Result (objects points to AExt):
    AList[0] text/plain AList.Objects[0]=TObject(0)
    AList[1] text/html  AList.Objects[1]=TObject(1)
    AExt[0]  q=0.3
    AExt[1]  q=0.7
    ...
}
function ExtractHeaderExtFields(Content: PChar; AList: TStrings; AExt: TStrings): String;

{ In accompany to ExtractHeaderExtFields, extract extension value if exists
  Usage:
    qval:= GetHeaderExt(i, 'q', pars, ext);
  Return value of extension AExtName (i.e. '0.3') for parameter no
  if i >= pars.Count or i < 0 return ''
}
function GetHeaderExt(AOrder: Integer; const AExtName: String; AList: TStrings; AExt: TStrings): String;

// split long text to lines CRLF delimited

function SplitLongText(const AStr: WideString; APos: Integer; ABlockIndent, AMargin: Integer): WideString;

{ 1. ButtonText = Text at the bottom of the button
  2. MenuText = The tools menu item with a reference to your program.
  3. MenuStatusbar = *Ignore*
  4. CLSID = Your unique classID. You can use GUIDTOSTRING to create a new CLSID (for each button).
  5. Default Visible := Display it.
  6. Exec := Your program path to execute.
  7. Hoticon := (Mouse Over Event) ImageIndex in shell32.dll
  8. Icon := ImageIndex in shell32.dll
}

procedure CreateExplorerButton(ProgramPath: String);

{--------------------- simplify xml routines ----------------------------------}

{ ExtractExternalLinks
    extract external links in ADoc wide strings, add found links to AResultList
  Parameters:
    AIEDownload pointer to IE download component
    ADocKind: edOEB or edXHTML
    ADepth -
      = -1 do not parse
      = 0  parse passed document only
      > 0  parse nested documents
    ANotify
      reserved
    AReserved
      reserved
  Return
    Result ?
    AResultList list of extenal links with object (lo)
      = 0 - texts
      = 1 - css
      = 2 - images
      = 3 - binaries
    high bits contains is set if this page solved
}

function ExtractExternalLinks(var ABaseURI: String; AElement: TxmlElement;
  ADepth: Integer; AResultList: TStrings;
  ANotify: Pointer; AReserved: Pointer): Integer;

// remove specified class elements nested to AElement

procedure RemoveElements(AElement: TxmlElement; AClass2Remove: TxmlElementClass);
procedure RemoveElementsKeepInner(AElement: TxmlElement; AClass2Remove: TxmlElementClass);

procedure SimplifyBodyAsText(AElement: TxmlElement);

procedure SimplifyTables(AElement: TxmlElement);

procedure SimplifyRemoveTables(AElement: TxmlElement);

procedure SimplifySetTahomaFont(const AElement: TxmlElement);

procedure SimplifySkipIndents(const AElement: TxmlElement);

procedure SimplifyForceLanguage(AElement: TxmlElement);

procedure AddAds2Body(AElement: TxmlElement);

function RemoveAllTextLinksExcept1(AList: TStrings): Integer;

function ExtractFolder(const AURI: String): String;

{--------------------- OEB package routines -----------------------------------}

function CreateDefaultPkgContainer(const AIdentifier, ATitle,
  ACreator, APublisher, ASource,
  ACoverImage, AThumbImage, ATitleImage: WideString; AManifestItems: TStrings): TxmlElementCollection;

// build image list
procedure BuildImageList(AElement: TxmlElement; AImages: TStrings; AMaxImagesCount: Integer);

function SimpleGetMimeType(const AURI: String): String;

{ codepage to unicode conversion functions }

function Iso8859_1ToWS(const AStr: String): WideString;  // Latin-1
function Iso8859_2ToWS(const AStr: String): WideString;  // Latin-2
function Iso8859_3ToWS(const AStr: String): WideString;  // Latin-3
function Iso8859_4ToWS(const AStr: String): WideString;  // Latin-4
function Iso8859_5ToWS(const AStr: String): WideString;  // Cyrillic
function Iso8859_6ToWS(const AStr: String): WideString;  // Arabic
function Iso8859_7ToWS(const AStr: String): WideString;  // Greek
function Iso8859_8ToWS(const AStr: String): WideString;  // Hebrew
function Iso8859_9ToWS(const AStr: String): WideString;  //
function Iso8859_10ToWS(const AStr: String): WideString; // Latin-6
function Iso8859_13ToWS(const AStr: String): WideString; // Latin-7
function Iso8859_14ToWS(const AStr: String): WideString; // Latin-8
function Iso8859_15ToWS(const AStr: String): WideString; // Latin-9
function KOI8_RToWS(const AStr: String): WideString;     // KOI8-R
function cp10000_MacRomanToWS(const AStr: String): WideString;  // cp10000_MacRoman
function cp1250ToWS(const AStr: String): WideString;     // Windows-1250
function cp1251ToWS(const AStr: String): WideString;     // Windows-1251
function cp1252ToWS(const AStr: String): WideString;     // Windows-1251

// and vice versa, unicode to specific code page conversion

function WSTo_Iso8859_1(const AStr: WideString): String;  // Latin-1
function WSTo_Iso8859_2(const AStr: WideString): String;  // Latin-2
function WSTo_Iso8859_3(const AStr: WideString): String;  // Latin-3
function WSTo_Iso8859_4(const AStr: WideString): String;  // Latin-4
function WSTo_Iso8859_5(const AStr: WideString): String;  // Cyrillic
function WSTo_Iso8859_6(const AStr: WideString): String;  // Arabic
function WSTo_Iso8859_7(const AStr: WideString): String;  // Greek
function WSTo_Iso8859_8(const AStr: WideString): String;  // Hebrew
function WSTo_Iso8859_9(const AStr: WideString): String;  //
function WSTo_Iso8859_10(const AStr: WideString): String; // Latin-6
function WSTo_Iso8859_13(const AStr: WideString): String; // Latin-7
function WSTo_Iso8859_14(const AStr: WideString): String; // Latin-8
function WSTo_Iso8859_15(const AStr: WideString): String; // Latin-9
function WSTo_KOI8_R(const AStr: WideString): String;     // KOI8-R
function WSTo_cp10000_MacRoman(const AStr: WideString): String;  // cp10000_MacRoman
function WSTo_cp1250(const AStr: WideString): String;     // Windows-1250
function WSTo_cp1251(const AStr: WideString): String;     // Windows-1251
function WSTo_cp1252(const AStr: WideString): String;     // Windows-1251

function Utf8DecodePChar(p: PChar; Alen: Integer): WideString;

var
  ForcedLanguage: String;

implementation

uses
  Math, wmlc, litconv;

const
  UCHAR_INVALID_CODE = '?';

function Utf8DecodePChar(p: PChar; Alen: Integer): WideString;
var
  L: Integer;
  Temp: WideString;
begin
  Result:= '';
  SetLength(Temp, ALen);

  L:= Utf8ToUnicode(PWideChar(Temp), ALen + 1, p, ALen); 
  if L > 0 then begin
    SetLength(Temp, L - 1);
    Result:= Temp;
  end else begin
  {
    SetLength(Result, ALen);
    jclUnicode.StrLCopyW(PWideChar(Result), p, ALen);
    }
  end;
end;

function GetStringsFromFileFilter(const AFilter: String; AStyle: Integer; AResult: TStrings): Boolean;
var
  F, S, SPrev, ext: String;
  cnt, p: Integer;
begin
  Result:= True;
  AResult.Clear;
  F:= AFilter;
  cnt:= 0;
  SPrev:= '';
  case AStyle of
  0:begin
      //
      repeat
        Inc(cnt);
        S:= GetToken(cnt, '|', F);
        if Length(S) = 0
        then Break;
        if Odd(cnt)
        then AResult.Add(S);
        SPrev:= S;
      until False;
    end;
  1:begin
      //
      repeat
        Inc(cnt);
        S:= GetToken(cnt, '|', F);
        if Length(S) = 0
        then Break;
        if not Odd(cnt) then begin
          // parse list of extensions
          p:= 0;
          repeat
            Inc(p);
            Ext:= GetToken(p, ';', S);
            if Length(Ext) = 0
            then Break;
            if Ext[1] = '*'
            then Delete(Ext, 1, 1);
            // if AResult.IndexOf(Ext) < 0 then
            AResult.AddObject(Ext, TObject(cnt div 2));
          until False;
        end;
      until False;
    end;
  2:begin
      // 'xhtml files (*.html;*.htm)' -> '.html', '.htm'
      p:= Pos('(', F);
      if p <=0
      then Exit;
      Delete(F, 1, p);
      p:= Pos(')', F);
      if p <=0
      then Exit;
      Delete(F, p, MaxInt);
      repeat
        Inc(cnt);
        S:= GetToken(cnt, '|', F);
        if Length(S) = 0
        then Break;
          // parse list of extensions
          p:= 0;
          repeat
            Inc(p);
            Ext:= GetToken(p, ';', S);
            if Length(Ext) = 0
            then Break;
            if Ext[1] = '*'
            then Delete(Ext, 1, 1);
            AResult.Add(Ext);
          until False;
      until False;
    end;
  3:begin
      // 'xhtml files (*.html;*.htm)' -> '*.html', '*.htm'
      p:= Pos('(', F);
      if p <= 0
      then Exit;
      Delete(F, 1, p);
      p:= Pos(')', F);
      if p <=0
      then Exit;
      Delete(F, p, MaxInt);
      repeat
        Inc(cnt);
        S:= GetToken(cnt, '|', F);
        if Length(S) = 0
        then Break;
          // parse list of extensions
          p:= 0;
          repeat
            Inc(p);
            Ext:= GetToken(p, ';', S);
            if Length(Ext) = 0
            then Break;
            AResult.Add(Ext);
          until False;
      until False;
    end;
  end;
end;

type
  TEntityCode = record
    n: String[8];
    c: Word;
  end;

const
  NamedEntities: array[0..6] of String[4] =
    ('quot', 'amp', 'apos', 'lt', 'gt', 'nbsp', 'shy');

  HTMLLongNamedEntities: array[0..252] of TEntityCode = (
    (n: 'quot'; c: 34), (n: 'amp'; c: 38), (n: 'apos'; c: 39), (n: 'lt'; c: 60), (n: 'gt'; c: 62), (n: 'nbsp'; c: 160), (n: 'shy'; c: 173),
    (n: 'ordf';c:170), (n: 'ordm';c:186), (n: 'Agrave';c: 192), (n: 'Aacute';c: 193), (n: 'Acirc';c:194),
    (n: 'Atilde';c: 195), (n: 'Auml';c:196), (n: 'Aring';c:197), (n: 'AElig';c:198), (n: 'Ccedil';c: 199),
    (n: 'Egrave';c: 200), (n: 'Eacute';c: 201), (n: 'Ecirc';c:202), (n: 'Euml';c:203), (n: 'Igrave';c: 204),
    (n: 'Iacute';c: 205), (n: 'Icirc';c:206), (n: 'Iuml';c:207), (n: 'ETH';c:208), (n: 'Ntilde';c: 209),
    (n: 'Ograve';c: 210), (n: 'Oacute';c: 211), (n: 'Ocirc';c:212), (n: 'Otilde';c: 213), (n: 'Ouml';c:214),
    (n: 'Oslash';c: 216), (n: 'Ugrave';c: 217), (n: 'Uacute';c: 218), (n: 'Ucirc';c:219), (n: 'Uuml';c:220),
    (n: 'Yacute';c: 221), (n: 'THORN';c:222), (n: 'szlig';c:223), (n: 'agrave';c: 224), (n: 'aacute';c: 225),
    (n: 'acirc';c:226), (n: 'atilde';c: 227), (n: 'auml';c:228), (n: 'aring';c:229), (n: 'aelig';c:230),
    (n: 'ccedil';c: 231), (n: 'egrave';c: 232), (n: 'eacute';c: 233), (n: 'ecirc';c:234), (n: 'euml';c:235),
    (n: 'igrave';c: 236), (n: 'iacute';c: 237), (n: 'icirc';c:238), (n: 'iuml';c:239), (n: 'eth';c:240),
    (n: 'ntilde';c: 241), (n: 'ograve';c: 242), (n: 'oacute';c: 243), (n: 'ocirc';c:244), (n: 'otilde';c: 245),
    (n: 'ouml';c:246), (n: 'oslash';c: 248), (n: 'ugrave';c: 249), (n: 'uacute';c: 250), (n: 'ucirc';c:251),
    (n: 'uuml';c:252), (n: 'yacute';c: 253), (n: 'thorn';c:254), (n: 'yuml';c:255), (n: 'OElig';c:338),
    (n: 'oelig';c:339), (n: 'Scaron';c: 352), (n: 'scaron';c: 353), (n: 'Yuml';c:376), (n: 'fnof';c:402),
    (n: 'Alpha';c:913), (n: 'Beta';c:914), (n: 'Gamma';c:915), (n: 'Delta';c:916), (n: 'Epsilon';c: 917),
    (n: 'Zeta';c:918), (n: 'Eta';c:919), (n: 'Theta';c:920), (n: 'Iota';c:921), (n: 'Kappa';c:922),
    (n: 'Lambda';c: 923), (n: 'Mu';c:924), (n: 'Nu';c:925), (n: 'Xi';c:926), (n: 'Omicron';c: 927), (n: 'Pi';c:928),
    (n: 'Rho';c:929), (n: 'Sigma';c:931), (n: 'Tau';c:932), (n: 'Upsilon';c: 933), (n: 'Phi';c:934),
    (n: 'Chi';c:935), (n: 'Psi';c:936), (n: 'Omega';c:937), (n: 'alpha';c:945), (n: 'beta';c:946),
    (n: 'gamma';c:947), (n: 'delta';c:948), (n: 'epsilon';c: 949), (n: 'zeta';c:950), (n: 'eta';c:951),
    (n: 'theta';c:952), (n: 'iota';c:953), (n: 'kappa';c:954), (n: 'lambda';c: 955), (n: 'mu';c:956),
    (n: 'nu';c:957), (n: 'xi';c:958), (n: 'omicron';c: 959), (n: 'pi';c:960), (n: 'rho';c:961),
    (n: 'sigmaf';c: 962), (n: 'sigma';c:963), (n: 'tau';c:964), (n: 'upsilon';c: 965), (n: 'phi';c:966),
    (n: 'chi';c:967), (n: 'psi';c:968), (n: 'omega';c:969), (n: 'thetasym'; c: 977), (n: 'upsih';c:978),
    (n: 'piv';c:982), (n: 'ensp';c:8194), (n: 'emsp';c:8195), (n: 'thinsp';c: 8201), (n: 'zwnj';c:8204),
    (n: 'zwj';c:8205), (n: 'lrm';c:8206), (n: 'rlm';c:8207), (n: 'ndash';c:8211), (n: 'mdash';c:8212),
    (n: 'lsquo';c:8216), (n: 'rsquo';c:8217), (n: 'sbquo';c:8218), (n: 'ldquo';c:8220), (n: 'rdquo';c:8221),
    (n: 'bdquo';c:8222), (n: 'dagger';c: 8224), (n: 'Dagger';c: 8225), (n: 'bull';c:8226), (n: 'hellip';c: 8230),
    (n: 'permil';c: 8240), (n: 'prime';c:8242), (n: 'Prime';c:8243), (n: 'lsaquo';c: 8249), (n: 'rsaquo';c: 8250),
    (n: 'oline';c:8254), (n: 'frasl';c:8260), (n: 'circ'; c:  710), (n: 'tilde'; c:  732), (n: 'iexcl'; c:  161),
    (n: 'cent'; c:  162), (n: 'pound'; c:  163), (n: 'curren'; c:  164), (n: 'yen';c:165), (n: 'brvbar';c:166),
    (n: 'sect';c:167), (n: 'uml';c:168), (n: 'copy';c:169), (n: 'laquo';c:171), (n: 'not';c:172),
    (n: 'reg';c:174), (n: 'macr';c:175), (n: 'deg';c:176), (n: 'plusmn';c:177), (n: 'sup2';c:178),
    (n: 'sup3';c:179), (n: 'acute';c:180), (n: 'micro';c:181), (n: 'para';c:182), (n: 'middot';c:183),
    (n: 'cedil';c:184), (n: 'sup1';c:185), (n: 'raquo';c:187), (n: 'frac14';c:188), (n: 'frac12';c:189),
    (n: 'frac34';c:190), (n: 'iquest';c:191), (n: 'times';c:215), (n: 'divide';c:247), (n: 'euro';c:8364),
    (n: 'image';c:8465), (n: 'weierp';c:8472), (n: 'real';c:8476), (n: 'trade';c:8482), (n: 'alefsym';c:  8501),
    (n: 'larr';c:8592), (n: 'uarr';c:8593), (n: 'rarr';c:8594), (n: 'darr';c:8595), (n: 'harr';c:8596),
    (n: 'crarr';c:8629), (n: 'lArr';c:8656), (n: 'uArr';c:8657), (n: 'rArr';c:8658), (n: 'dArr';c:8659),
    (n: 'hArr';c:8660), (n: 'forall';c:8704), (n: 'part';c:8706), (n: 'exist';c:8707), (n: 'empty';c:8709),
    (n: 'nabla';c:8711), (n: 'isin';c:8712), (n: 'notin';c:8713), (n: 'ni';c:8715), (n: 'prod';c:8719),
    (n: 'sum';c:8721), (n: 'minus';c:8722), (n: 'lowast';c:8727), (n: 'radic';c:8730), (n: 'prop';c:8733),
    (n: 'infin';c:8734), (n: 'ang';c:8736), (n: 'and';c:8743), (n: 'or';c:8744), (n: 'cap';c:8745),
    (n: 'cup';c:8746), (n: 'int';c:8747), (n: 'there4';c:8756), (n: 'sim';c:8764), (n: 'cong';c:8773),
    (n: 'asymp';c:8776), (n: 'ne';c:8800), (n: 'equiv';c:8801), (n: 'le';c:8804), (n: 'ge';c:8805),
    (n: 'sub';c:8834), (n: 'sup';c:8835), (n: 'nsub';c:8836), (n: 'sube';c:8838), (n: 'supe';c:8839),
    (n: 'oplus';c:8853), (n: 'otimes';c:8855), (n: 'perp';c:8869), (n: 'sdot';c:8901), (n: 'lceil';c:8968),
    (n: 'rceil';c:8969), (n: 'lfloor';c:8970), (n: 'rfloor';c:8971), (n: 'lang';c:9001), (n: 'rang';c:9002),
    (n: 'loz';c:9674), (n: 'spades';c:9824), (n: 'clubs';c:9827), (n: 'hearts';c:9829), (n: 'diams';c:9830));
{
WML supports the following character entity formats:
- Named character entities, such as &amp; and &lt;
- Decimal numeric character entities, such as &#123;
- Hexadecimal numeric character entities, such as &#x12;

quot    &#34;   quotation mark "
amp     &#38;   ampersand      &
apos    &#39;   apostrophe     '
lt      &#60;   less than      <
gt      &#62;   greater than   >
nbsp    &#160;  non-breaking space
shy     &#173;  soft hyphen (discretionary hyphen)
}
function WMLEntityStr(const Src: WideString): WideString;
var
  i: Integer;
begin
  Result:= '';
  for i:= 1 to Length(Src) do begin
    case Src[i] of
    #0..#9, #11..#12, #13..#31: Result:= Result + '&#' + IntToStr(Byte(Src[i])) + ';';
      //  named entity
    #34: Result:= Result + '&' + NamedEntities[0] + ';';
//    #38: Result:= Result + '&' + NamedEntities[1] + ';'; -- do not uncomment
//    #39: Result:= Result + '&' + NamedEntities[2] + ';';
    #60: Result:= Result + '&' + NamedEntities[3] + ';';
    #62: Result:= Result + '&' + NamedEntities[4] + ';';
    #160: Result:= Result + '&' + NamedEntities[5] + ';';
    #173: Result:= Result + '&' + NamedEntities[6] + ';';
    WideLineSeparator: Result:= Result + #13#10;
    else
      Result:= Result + Src[i];
    end;
  end;
end;

function XMLEntityStr(const Src: WideString): WideString;
var
  i: Integer;
begin
  Result:= '';
  for i:= 1 to Length(Src) do begin
    case Src[i] of
    #0..#9, #11..#12, #13..#31: Result:= Result + '&#' + IntToStr(Byte(Src[i])) + ';';
    #34: Result:= Result + '&' + NamedEntities[0] + ';';
    #60: Result:= Result + '&' + NamedEntities[3] + ';';
    #62: Result:= Result + '&' + NamedEntities[4] + ';';
    WideLineSeparator: Result:= Result + #13#10;
    else
      Result:= Result + Src[i];
    end;
  end;
end;

function HTMLEntityStr(const Src: WideString): WideString;
var
  i: Integer;
begin
  Result:= '';
  for i:= 1 to Length(Src) do begin
    case Src[i] of
    #0..#31: Result:= Result + '&#' + IntToStr(Byte(Src[i])) + ';';
      //  named entity
    #34: Result:= Result + '&' + NamedEntities[0] + ';';
    #38: Result:= Result + '&' + NamedEntities[1] + ';';
//    #39: Result:= Result + '&' + NamedEntities[2] + ';';
    #60: Result:= Result + '&' + NamedEntities[3] + ';';
    #62: Result:= Result + '&' + NamedEntities[4] + ';';
    #160: Result:= Result + '&' + NamedEntities[5] + ';';
    #173: Result:= Result + '&' + NamedEntities[6] + ';';
    else
      Result:= Result + Src[i];
    end;
  end;
end;

{ NonASCIIChar2Entity
  Return
    all characters greater #127 replaced to entity in code page
  See also:
    overloaded NonASCIIChar2Entity for  utf-8 encoding
}
function NonASCIIChar2Entity(const Src: String): String;
var
  i: Integer;
  ch: Char;
begin
  Result:= '';
  for i:= 1 to Length(Src) do begin
    ch:= Src[i];
    if (ch < #32) or (ch > #127)
    then Result:= Result + '&#' + IntToStr(Byte(Src[i])) + ';'  // + '&#x' + IntToHex(Byte(ch), 2) + ';'  // hexadecimal (it is shorter I mean)
    else Result:= Result + ch;
  end;
end;

{ overloaded version of NonASCIIChar2Entity for utf-8 encoding
}
function NonASCIIChar2EntityWS(const Src: WideString): String;
var
  i: Integer;
  ch: WideChar;
begin
  Result:= '';
  for i:= 1 to Length(Src) do begin
    ch:= Src[i];
    if (ch < #32) or (ch > #127)
    then Result:= Result + '&#x' + IntToHex(Word(ch), 2) + ';'  // hexadecimal (it is shorter I mean)
    else Result:= Result + ch;
  end;
end;

{ this WMLExtractEntityStr() code is slow down for really very big attribute values }
function WMLExtractEntityStr(const Src: WideString; ACompressSpaces: Boolean = True): WideString;
var
  p, L, code: Integer;
  S: String;
  SpaceExists: Boolean;
begin
  Result:= '';
  p:= 1;
  SpaceExists:= False;
  while p <= Length(Src) do begin
    case Src[P] of
    #0..#32, WideLineSeparator: begin
        if not SpaceExists then begin
          if ACompressSpaces
          then Result:= Result + #32
          else Result:= Result + Src[p];
          SpaceExists:= True;
        end;
        Inc(P);
      end;
    '&': begin
        SpaceExists:= False;
        L:= PosFrom(P, ';', Src) + 1 - P;
        S:= Copy(Src, P + 1, L - 2);

        Code:= -1;
        if (L > 2) then begin
          // &#16; &#x10; &lt;
          case S[1] of
          '#': begin
               Delete(s, 1, 1);
               if s[1] in ['X', 'x']
               then s[1]:= '$';
               Code:= StrToIntDef(S, -1);
               end;
          else begin
            if CompareText(NamedEntities[0], s) = 0 then Code:= 34
            else if CompareText(NamedEntities[1], s) = 0 then Code:= 38
              else if CompareText(NamedEntities[2], s) = 0 then Code:= 39
                else if CompareText(NamedEntities[3], s) = 0 then Code:= 60
                  else if CompareText(NamedEntities[4], s) = 0 then Code:= 62
                    else if CompareText(NamedEntities[5], s) = 0 then Code:= 160
                      else if CompareText(NamedEntities[6], s) = 0 then Code:= 173;
            end;
          end; { case }
        end;
        if (code < 32) then begin // or (code > 255) 
          // L = 0 if '&' w/o ';'
          if L <= 0
          then L:= 1;
          Result:= Result + Copy(Src, p, L);
        end else begin
          Result:= Result + WideChar(Code);
        end;
        Inc(P, L); { &#; - 3 characters }
      end;
    else begin
        SpaceExists:= False;
        Result:= Result + Src[P];
        Inc(P);
      end;
    end; { case }
  end;
end;

function HTMLExtractEntityStr(const Src: WideString): WideString;
var
  p, L, code, c: Integer;
  S: String;
  SpaceExists: Boolean;
begin
  Result:= '';
  p:= 1;
  SpaceExists:= False;
  while p <= Length(Src) do begin
    case Src[P] of
    #0..#32, WideLineSeparator: begin
        if not SpaceExists then begin
          Result:= Result + #32;
          SpaceExists:= True;
        end;
        Inc(P);
      end;
    '&': begin
        SpaceExists:= False;
        L:= PosFrom(P, ';', Src) + 1 - P;
        S:= Copy(Src, P + 1, L - 2);

        Code:= -1;
        if (L > 2) then begin
          // &#16; &#x10; &lt;
          case S[1] of
          '#': begin
               Delete(s, 1, 1);
               if s[1] in ['X', 'x']
               then s[1]:= '$';
               Code:= StrToIntDef(S, -1);
               end;
          else begin
            Code:= 0;
            for c:= Low(HTMLLongNamedEntities) to High(HTMLLongNamedEntities) do begin
              if HTMLLongNamedEntities[c].n = s then begin
                Code:= HTMLLongNamedEntities[c].c;
                Break;
              end;
            end;
            if Code = 0 then begin
              for c:= Low(HTMLLongNamedEntities) to High(HTMLLongNamedEntities) do begin
                if CompareText(HTMLLongNamedEntities[c].n, s) = 0 then begin
                  Code:= HTMLLongNamedEntities[c].c;
                  Break;
                end;
              end;
            end;
            end;
          end; { case }
        end;
        if (code < 32) or (code > 255) then begin
          // L = 0 if '&' w/o ';'
          if L <= 0
          then L:= 1;
          Result:= Result + Copy(Src, p, L);
        end else begin
          Result:= Result + Chr(Code);
        end;
        Inc(P, L); { &#; - 3 characters }
      end;
    else begin
        SpaceExists:= False;
        Result:= Result + Src[P];
        Inc(P);
      end;
    end; { case }
  end;
end;

function ExtractEntityStrWS(const Src: WideString): WideString;
var
  p, L, code: Integer;
  S: String;
begin
  Result:= '';
  p:= 1;
  while p <= Length(Src) do begin
    case Src[P] of
    '&': begin
        L:= PosFrom(P, ';', Src) + 1 - P;
        S:= Copy(Src, P + 1, L - 2);

        Code:= -1;
        if (L > 2) then begin
          // &#16; &#x10; &lt;
          case S[1] of
          '#': begin
               Delete(s, 1, 1);
               if s[1] in ['X', 'x']
               then s[1]:= '$';
               Code:= StrToIntDef(S, -1);
               end;
          else begin
            end;
          end; { case }
        end;
        if (code < 32) then begin // or (code > 255)
          // L = 0 if '&' w/o ';'
          if L <= 0
          then L:= 1;
          Result:= Result + Copy(Src, p, L);
        end else begin
          Result:= Result + WideChar(Code);
        end;
        Inc(P, L); { &#; - 3 characters }
      end;
    else begin
        Result:= Result + Src[P];
        Inc(P);
      end;
    end; { case }
  end;
end;

function ExtractEntityStrS(const Src: String): String;
var
  p, L, code: Integer;
  S: String;
begin
  Result:= '';
  p:= 1;
  while p <= Length(Src) do begin
    case Src[P] of
    '&': begin
        L:= PosFrom(P, ';', Src) + 1 - P;
        S:= Copy(Src, P + 1, L - 2);
        Code:= -1;
        if (L > 2) then begin
          // &#16; &#x10; &lt;
          case S[1] of
          '#': begin
               Delete(s, 1, 1);
               if s[1] in ['X', 'x']
               then s[1]:= '$';
               Code:= StrToIntDef(S, -1);
               end;
          else begin
            end;
          end; { case }
        end;
        if (code < 32) then begin // or (code > 255)
          // L = 0 if '&' w/o ';'
          if L <= 0
          then L:= 1;
          Result:= Result + Copy(Src, p, L);
        end else begin
          Result:= Result + Char(Code);
        end;
        Inc(P, L); { &#; - 3 characters }
      end;
    else begin
        Result:= Result + Src[P];
        Inc(P);
      end;
    end; { case }
  end;
end;

type
  // shift draw properties
  TShiftProcClass = class(TObject)
    FPosBefore, FPosAfter: TPoint;
    FShift: TPoint;
  public
    constructor Create(APosBefore, APosAfter: TPoint);
    procedure ShiftProc(var AxmlElement: TxmlElement);
  end;

constructor TShiftProcClass.Create(APosBefore, APosAfter: TPoint);
begin
  FPosBefore:= APosBefore;
  FPosAfter:= APosAfter;
  FShift.X:= APosAfter.X - APosBefore.X;
  FShift.Y:= APosAfter.Y - APosBefore.Y;
end;

procedure TShiftProcClass.ShiftProc(var AxmlElement: TxmlElement);
begin
  with AxmlElement.DrawProperties do begin
    if (TagXYStart.X > FPosAfter.X) or ((TagXYStart.X = FPosAfter.X) and (TagXYStart.Y >= FPosAfter.Y)) then begin
      Inc(TagXYStart.X, FShift.X);
      Inc(TagXYStart.Y, FShift.Y);
      Inc(TagXYFinish.X, FShift.X);
      Inc(TagXYFinish.Y, FShift.Y);

      Inc(TagXYTerminatorStart.X, FShift.X);
      Inc(TagXYTerminatorStart.Y, FShift.Y);
      Inc(TagXYTerminatorFinish.X, FShift.X);
      Inc(TagXYTerminatorFinish.Y, FShift.Y);
    end;
  end;
end;

procedure ShiftWMLElementTextPositions(AxmlElement: TxmlElement; const Tag: String);
var
  ShiftProcClass: TShiftProcClass;
  NewXYFinish: TPoint;
//SaveXY: TPoint;
  i: Integer;
  SaveDrawProperties: TDrawProperties;
begin
//  SaveXY:= AWMLElement.DrawProperties.TagXYStart;
  SaveDrawProperties:= AxmlElement.DrawProperties;
  NewXYFinish:= AxmlElement.DrawProperties.TagXYStart;
  // calc new tag finish position (-1)
  for i:= 2 to Length(Tag) do  begin
    case Tag[i] of
    #13:begin
        Inc(NewXYFinish.X);
      end;
    #10:begin
        NewXYFinish.Y:= 0;
      end;
    else begin
        Inc(NewXYFinish.Y);
      end;
    end;
  end;
  ShiftProcClass:= TShiftProcClass.Create(AxmlElement.DrawProperties.TagXYFinish, NewXYFinish);
  // search all elements, not just nested.
  AxmlElement.Root.ForEach(ShiftProcClass.ShiftProc);
  // first element TagXYStart value is shifted too, so repair this value
  AxmlElement.DrawProperties.TagXYStart:= SaveDrawProperties.TagXYStart;
//  AxmlElement.DrawProperties:= SaveDrawProperties;
  ShiftProcClass.Free;
end;

// calculate new position APosition depending lines and chars in ATag text
procedure CalcTextColsRows(const ATag: String; var APosition: TPoint);
var
  i: Integer;
begin
  for i:= 1 to Length(ATag) do begin
    case ATag[i] of
    #13:begin
        Inc(APosition.X);
      end;
    #10:begin
        APosition.Y:= 0;
      end;
    else begin
        Inc(APosition.Y);
      end;
    end;
  end;
end;

procedure CalcTextColsRows(const ATag: WideString; var APosition: TPoint);
var
  i: Integer;
begin
  for i:= 1 to Length(ATag) do begin
    case ATag[i] of
    WideLineSeparator:begin
        Inc(APosition.X);
        APosition.Y:= 0;
      end;
    #13:begin
        Inc(APosition.X);
      end;
    #10:begin
        APosition.Y:= 0;
      end;
    else begin
        Inc(APosition.Y);
      end;
    end;
  end;
end;

{
  oldtagp.X:= e.DrawProperties.TagXYFinish.X - e.DrawProperties.TagXYStart.X + 1;
  oldtagp.Y:= e.DrawProperties.TagXYFinish.Y - e.DrawProperties.TagXYStart.Y + 1;
  // calc new tag finish position (-1)
  newtagp.X:= 0; newtagp.Y:= 0;
  CalcTextColsRows(ANewTag, newtagp);

  Shift.X:= newtagp.X - oldtagp.X;
  Shift.Y:= newtagp.Y - oldtagp.Y;

  BUGBUG sometimes after deleteing element Terminal tag of parent of perent (parent.parent) X greate actual by 1
  someteimes. No condition was found. May be all is correct?
}
procedure ShiftNodeElementsTextPositions(ANode: TTreeNode; Shift: TPoint);
var
  el_shifted: TxmlElement;
  tv: TTreeView;
  line: Integer;

  procedure ShiftNode(AElement: TxmlElement);
  var
    i: Integer;
    APClass: TPersistentClass;
  begin
    if AElement = el_shifted
    then Exit;
    with AElement.DrawProperties do begin
      // skip same AStr and all lines before inserted element
      if TagXYStart.X > el_shifted.DrawProperties.TagXYStart.X then begin
        Shift.Y:= 0; // do not shift all next lines

        Inc(TagXYStart.X, Shift.X);
        Inc(TagXYFinish.X, Shift.X);
        Inc(TagXYTerminatorStart.X, Shift.X);
        Inc(TagXYTerminatorFinish.X, Shift.X);
      end else begin
        // shift all terminators after inserted line
        if (TagXYTerminatorStart.X >= line)  then begin
          Inc(TagXYTerminatorStart.X, Shift.X);
          Inc(TagXYTerminatorFinish.X, Shift.X);
        end;

        // skip elements in same AStr but before element
        if (Shift.Y <> 0) and (TagXYStart.Y > el_shifted.DrawProperties.TagXYStart.Y) then begin
          Inc(TagXYStart.Y, Shift.Y);
          Inc(TagXYFinish.Y, Shift.Y);
          Inc(TagXYTerminatorStart.Y, Shift.Y);
          Inc(TagXYTerminatorFinish.Y, Shift.Y);
        end;
      end;
    end;

    i:= 0;
    while i < AElement.NestedElements1Count do begin
      ShiftNode(AElement.GetNested1ElementByOrder(i, APClass));
      Inc(i);
    end;
  end;

begin
  if (not Assigned(ANode)) or ((Shift.X = 0) and (Shift.Y = 0))
  then Exit;
  el_shifted:= TxmlElement(ANode.Data);
  line:= el_shifted.DrawProperties.TagXYStart.X;
  tv:= ANode.TreeView as TTreeView;
  // if not Assigned(e) then Exit; // must be assigned, do not check

  // shift lines below recursively (all tags after and terminators of tags)
  // there are no other way- all following tags must be fixed
  // and all parent tags must be fixed. There are one way to enhance performance-
  // check in prevoius tags only parents. Unfortunately, because we must fix
  ShiftNode(TxmlElement(tv.TopItem.Data));
end;

constructor TWideStringStream.Create(const AString: WideString);
begin
  inherited Create;
  FDataString:= AString;
end;

function TWideStringStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result:= Length(FDataString) - FPosition;
  if Result > Count
  then Result:= Count;
  Move(PWideChar(@FDataString[FPosition + 1])^, Buffer, Result * 2);
  Inc(FPosition, Result);
end;

function TWideStringStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result:= Count;
  SetLength(FDataString, (FPosition + Result));
  Move(Buffer, PChar(@FDataString[FPosition + 1])^, Result * 2);
  Inc(FPosition, Result);
end;

function TWideStringStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: FPosition := FPosition + Offset;
    soFromEnd: FPosition := Length(FDataString) - Offset;
  end;
  if FPosition > Length(FDataString) then
    FPosition:= Length(FDataString)
  else if FPosition < 0 then FPosition := 0;
  Result:= FPosition;
end;

function TWideStringStream.ReadWideString(Count: Longint): WideString;
var
  Len: Integer;
begin
  Len:= Length(FDataString) - FPosition;
  if Len > Count then Len := Count;
  SetString(Result, PWideChar(@FDataString[FPosition + 1]), Len);
  Inc(FPosition, Len);
end;

procedure TWideStringStream.WriteWideString(const AString: WideString);
begin
  Write(PWideChar(AString)^, Length(AString));
end;

procedure TWideStringStream.SetSize(NewSize: Longint);
begin
  SetLength(FDataString, NewSize);
  if FPosition > NewSize
  then FPosition:= NewSize;
end;

function GetListOfSupportedCharsetEncodings(const ADlmt: String): String;
var
  i, L, LR: Integer;
begin
  Result:= ''; 
  for i:= Low(wmlc.CharSetDef) to High(wmlc.CharSetDef) do begin
    Result:= Result + wmlc.CharSetDef[i].n + ADlmt;
  end;
  // delete last delimiter
  L:= Length(Adlmt);
  LR:= Length(Result);
  if (L > 0) and (LR > L)
  then Delete(Result, LR - L + 1, L);
end;

// get wml source encoding (search for <xml encoding="utf-8"?>
// return '' if not found or cannot resolve name of encoding code page
function GetEncodingName(const AWMLSource: String): String;
var
  i, p, p1: Integer;
  s: String;
  wf: Boolean;
begin
  Result:= '';
  // try to search <xml> tag
  p:= Pos('<?xml', AWMLSource);
  if p > 0 then begin
    p1:= util1.PosFrom(p, '?>', AWMLSource);
    if p1 > 0 then begin
      s:= Copy(AWMLSource, p + 2, p1 - p - 2);
      p:= Pos('encoding=', s);
      if p > 0 then begin
        wf:= False;
        p1:= -1;
        for i:= p + 9 to Length(s) do begin
          case s[i] of
            #0..#32, '"', '''': begin
                if wf then begin
                  p1:= i-1;
                  Break;
                end;
              end;
            else begin
              if not wf then begin
                p:= i;
                wf:= True;
              end;
            end;
          end;
        end;
        if p1 < 0 then p1:= Length(s);
        Result:= Copy(s, p, p1 - p + 1);
      end;
    end;
  end else begin
    // html? <meta http-equiv="Content-Type" content="text/html;charset=windows-1251">
    p:= Pos('charset', AWMLSource);
    if p > 0 then begin
      p1:= util1.PosFrom(p, '>', AWMLSource);
      if p1 > 0 then begin
        s:= Copy(AWMLSource, p + 7, p1 - p - 7);
        p:= Pos('=', s);
        if p > 0 then begin
          wf:= False;
          p1:= -1;
          for i:= p + 1 to Length(s) do begin
            case s[i] of
              #0..#32, '"', '''': begin
                  if wf then begin
                    p1:= i-1;
                    Break;
                  end;
                end;
              else begin
                if not wf then begin
                  p:= i;
                  wf:= True;
                end;
              end;
            end;
          end;
          if p1 < 0 then p1:= Length(s);
          Result:= Copy(s, p, p1 - p + 1);
        end;
      end;
    end;
  end;
end;

// get xml source encoding (search for <xml encoding="utf-8"?>
// return ADefaultEncoding if not found or cannot resolve name of encoding code page
function GetEncoding(const AWMLSource: String; ADefaultEncoding: Integer): Integer;
var
  i: Integer;
  s: String;
begin
  Result:= ADefaultEncoding;
  s:= GetEncodingName(AWMLSource);
  if Length(s) = 0
  then Exit;
  i:= CharSetName2Code(s);
  if i >= 0
  then Result:= i;
end;

// return code of language by name, '' if not defined
function winLangId2Abbr(ALCId: LCID): String;
var
  LL: TjclLocalesList;
  sub: String;
  i: Integer;
begin
  Result:= '';
  LL:= TjclLocalesList.Create(lkInstalled);
  for i:= 0 to LL.Count - 1 do with LL[i] do begin
    if LangID = ALCId then begin
      Result:= ISOAbbreviatedLangName;
      sub:= Lowercase(ISOAbbreviatedCountryName);
      if CompareText(Result, sub) = 0
      then
      else Result:= Result + '-' + sub;
      Break;
    end;
  end;
  LL.Free;
end;

// return windows language identifier for 'en-us', 'ru'
function winLangAbbr2Id(ALangAbbr: String): LCID;
var
  LL: TjclLocalesList;
  s, sub: String;
  i: Integer;
begin
  Result:= 0;
  LL:= TjclLocalesList.Create(lkInstalled);
  for i:= 0 to LL.Count - 1 do with LL[i] do begin
    s:= ISOAbbreviatedLangName;
    sub:= Lowercase(ISOAbbreviatedCountryName);
    if CompareText(s, sub) = 0
    then
    else s:= s + '-' + sub;
    if CompareText(ALangAbbr, s) = 0 then begin
      Result:= LangID;
      Break;
    end;
  end;
  LL.Free;
end;

function UTF8DecodeByChunks(const S: String): WideString;
var
  p1, p2: PChar;
  i, len, chunk_len: Integer;
  ws: WideString;
begin
  Result:= '';
  len:= Length(s);
  if len <= 0
  then Exit;

  i:= 1;
  p1:= @(s[1]);
  p2:= p1;
  while i <= len do begin
    case S[i] of
      #0..#31: begin
          p2:= @(s[i]);
          chunk_len:= p2 - p1;
          if chunk_len > 0 then begin
            ws:= UTF8DecodePChar(p1, chunk_len);
            if Length(ws) = 0 then begin
              Result:= S;
              Exit;
            end
            else Result:= Result + ws + S[i]; //#13#10;
          end else Result:= Result + S[i];
          p1:= p2 + 1;
        end;
    end;
    Inc(i);
  end;

  p2:= @(s[len]);
  p2:= p2 + 1;
  chunk_len:= p2 - p1;
  if chunk_len > 0
  then Result:= Result + UTF8DecodePChar(p1, chunk_len);

end;

{ convert utf-8 and other character set to unicode
  Parameters:
    ACharsetCode:   csusascii, csiso8859_1..csiso8859_9, csshift_JIS, csiso10646_ucs_2, csbig5, csUTF8
                    usually csUTF8
    S:              source string in indicated (e.g. utf-8) code page
  Returns:          2-byte wide string (unicode)
}

function CharSet2WideString(ACharsetCode: Integer; const S: String; AOptions: TEntityConvOptions): WideString;
begin
  if convEnEntity2Char in AOptions then begin
    if convEnRefCharset in AOptions then begin
      // numeric character entities are referenced with respect to the current document encoding (charset).
      // In WML it is wrong. Implemented for loading invalid documents.
      case ACharsetCode of
        csiso8859_1: Result:= Iso8859_1ToWS(ExtractEntityStrS(S)); // Latin-1
        csiso8859_2: Result:= Iso8859_2ToWS(ExtractEntityStrS(S)); // Latin-2
        csiso8859_3: Result:= Iso8859_3ToWS(ExtractEntityStrS(S)); // Latin-3
        csiso8859_4: Result:= Iso8859_4ToWS(ExtractEntityStrS(S)); // Latin-4
        csiso8859_5: Result:= Iso8859_5ToWS(ExtractEntityStrS(S)); // Cyrillic
        csiso8859_6: Result:= Iso8859_6ToWS(ExtractEntityStrS(S)); // Arabic
        csiso8859_7: Result:= Iso8859_7ToWS(ExtractEntityStrS(S)); // Greek
        csiso8859_8: Result:= Iso8859_8ToWS(ExtractEntityStrS(S)); // Hebrew
        csiso8859_9: Result:= Iso8859_9ToWS(ExtractEntityStrS(S)); // Latin-6
        csiso8859_10: Result:= Iso8859_10ToWS(ExtractEntityStrS(S)); // Latin-6
        csiso8859_13: Result:= Iso8859_13ToWS(ExtractEntityStrS(S)); // Latin-7
        csiso8859_14: Result:= Iso8859_14ToWS(ExtractEntityStrS(S)); // Latin-8
        csiso8859_15: Result:= Iso8859_15ToWS(ExtractEntityStrS(S)); // Latin-9
        csKOI8R     : Result:= KOI8_RToWS(ExtractEntityStrS(S));     // KOI8-R
        cs10000_MacRoman: Result:= cp10000_MacRomanToWS(ExtractEntityStrS(S));   // cp10000_MacRoman
        csWindows1250: Result:= cp1250ToWS(ExtractEntityStrS(S));     // Windows-1250
        csWindows1251: Result:= cp1251ToWS(ExtractEntityStrS(S));     // Windows-1251
        csWindows1252: Result:= cp1252ToWS(ExtractEntityStrS(S));     // Windows-1252
        csUTF8: Result:= ExtractEntityStrWS(UTF8DecodeByChunks(S));
        else Result:= ExtractEntityStrS(S);
      end; { case }
    end else begin
      // numeric character entities are referenced with respect to the Unicode
      // In WML it is correct. I do not know what about other XML documents.
      case ACharsetCode of
        csiso8859_1: Result:= ExtractEntityStrWS(Iso8859_1ToWS(S)); // Latin-1
        csiso8859_2: Result:= ExtractEntityStrWS(Iso8859_2ToWS(S)); // Latin-2
        csiso8859_3: Result:= ExtractEntityStrWS(Iso8859_3ToWS(S)); // Latin-3
        csiso8859_4: Result:= ExtractEntityStrWS(Iso8859_4ToWS(S)); // Latin-4
        csiso8859_5: Result:= ExtractEntityStrWS(Iso8859_5ToWS(S)); // Cyrillic
        csiso8859_6: Result:= ExtractEntityStrWS(Iso8859_6ToWS(S)); // Arabic
        csiso8859_7: Result:= ExtractEntityStrWS(Iso8859_7ToWS(S)); // Greek
        csiso8859_8: Result:= ExtractEntityStrWS(Iso8859_8ToWS(S)); // Hebrew
        csiso8859_9: Result:= ExtractEntityStrWS(Iso8859_9ToWS(S)); // Latin-6
        csiso8859_10: Result:= ExtractEntityStrWS(Iso8859_10ToWS(S)); // Latin-6
        csiso8859_13: Result:= ExtractEntityStrWS(Iso8859_13ToWS(S)); // Latin-7
        csiso8859_14: Result:= ExtractEntityStrWS(Iso8859_14ToWS(S)); // Latin-8
        csiso8859_15: Result:= ExtractEntityStrWS(Iso8859_15ToWS(S)); // Latin-9
        csKOI8R     : Result:= ExtractEntityStrWS(KOI8_RToWS(S));     // KOI8-R
        cs10000_MacRoman: Result:= ExtractEntityStrWS(cp10000_MacRomanToWS(S));   // cp10000_MacRoman
        csWindows1250: Result:= ExtractEntityStrWS(cp1250ToWS(S));     // Windows-1250
        csWindows1251: Result:= ExtractEntityStrWS(cp1251ToWS(S));     // Windows-1251
        csWindows1252: Result:= ExtractEntityStrWS(cp1252ToWS(S));     // Windows-1252
        csUTF8: Result:= ExtractEntityStrWS(UTF8DecodeByChunks(S));
        else Result:= ExtractEntityStrWS(S);
      end; { case }
    end;
  end else begin
    case ACharsetCode of
      csiso8859_1: Result:= Iso8859_1ToWS(S); // Latin-1
      csiso8859_2: Result:= Iso8859_2ToWS(S); // Latin-2
      csiso8859_3: Result:= Iso8859_3ToWS(S); // Latin-3
      csiso8859_4: Result:= Iso8859_4ToWS(S); // Latin-4
      csiso8859_5: Result:= Iso8859_5ToWS(S); // Cyrillic
      csiso8859_6: Result:= Iso8859_6ToWS(S); // Arabic
      csiso8859_7: Result:= Iso8859_7ToWS(S); // Greek
      csiso8859_8: Result:= Iso8859_8ToWS(S); // Hebrew
      csiso8859_9: Result:= Iso8859_9ToWS(S); // Latin-6

      csiso8859_10: Result:= Iso8859_10ToWS(S); // Latin-6
      csiso8859_13: Result:= Iso8859_13ToWS(S); // Latin-7
      csiso8859_14: Result:= Iso8859_14ToWS(S); // Latin-8
      csiso8859_15: Result:= Iso8859_15ToWS(S); // Latin-9
      csKOI8R     : Result:= KOI8_RToWS(S);     // KOI8-R
      cs10000_MacRoman: Result:= cp10000_MacRomanToWS(S);   // cp10000_MacRoman
      csWindows1250: Result:= cp1250ToWS(S);     // Windows-1250
      csWindows1251: Result:= cp1251ToWS(S);     // Windows-1251
      csWindows1252: Result:= cp1252ToWS(S);     // Windows-1252
      csUTF8: Result:= UTF8DecodeByChunks(S);
      else begin
        // csusascii, csshift_JIS, csiso10646_ucs_2, csbig5
        Result:= S;
      end; { else case }
    end; { case }
  end;
end;

function CharSet2WideStrings(ACharsetCode: Integer; S: String; AOptions: TEntityConvOptions): TWideStrings;
var
  i: Integer;
  ws: WideString;
begin
  Result:= TWideStringList.Create;
  Result.Text:= s;
  for i:= 0 to Result.Count - 1 do begin
    ws:= util_xml.CharSet2WideString(ACharsetCode, Result[i], AOptions);
    // check validity of conversion
    if Length(ws) > 0
    then Result[i]:= ws;
  end;
end;

{ similar to CharSet2WideString except #13#10 instead widechar AStr separator is allowed
}
function CharSet2WideStringLine(ACharsetCode: Integer; S: String; AOptions: TEntityConvOptions): WideString;
var
  wsl: TWideStrings;
begin
  {
  wsl:= CharSet2WideStrings(ACharsetCode, S, AOptions);
  Result:= wsl.GetSeparatedText(#13#10);
  wsl.Free;
  }
  Result:= util_xml.CharSet2WideString(ACharsetCode, S, AOptions);
end;

{ convert unicode 2- byte wide string list to utf-8 or other character set string
  Parameters:
    ACharsetCode:   csusascii, csiso8859_1..csiso8859_9, csshift_JIS, csiso10646_ucs_2, csbig5, csUTF8
                    ususally csUTF8
    W:              source 2- byte unicode wide string
  Returns:          string in code page has benn choosed
}
function WideString2EncodedString(AConversion: TECharsetConversion; AEncoding: Integer;
  ALines: TWideStrings; AOptions: TEntityConvOptions): String;
var
  i: Integer;
begin
  case AConversion of
    convNone: Result:= ALines.Text;
    convFull: Result:= Unicode2CharSet(AEncoding, ALines.Text, AOptions);
    convLine,
    convPCData:begin
        // does not change CRLF to unicode WideLineSeparator
        Result:= '';
        for i:= 0 to ALines.Count - 1 do begin
          Result:= Result + Unicode2CharSet(AEncoding, ALines[i], AOptions) + #13#10;
        end;
        // delete last CRLF
        if Length(Result) > 2
        then Delete(Result, Length(Result) - 1, 2);
      end;
  end;
end;

function WideString2EncodedString(AConversion: TECharsetConversion; AEncoding: Integer; const ASrc: WideString; AOptions: TEntityConvOptions): String;
var
  i, p0, Len: Integer;
begin
  case AConversion of
    convNone: Result:= ASrc;
    convFull: Result:= Unicode2CharSet(AEncoding, ASrc, AOptions);
    convLine,
    convPCData:begin
        // does not change CRLF to unicode WideLineSeparator
        Result:= '';
        i:= 1;
        p0:= 1;
        Len:= Length(ASrc);
        while i <= Len do begin
          case ASrc[i] of
          #10: begin
              p0:= i + 1;
            end;
          #13, WideLineSeparator: begin
              Result:= Result + Unicode2CharSet(AEncoding, Copy(ASrc, p0, i - p0), AOptions) + #13#10;
              p0:= i + 1;
            end;
          end; { case }
          Inc(i);
        end;
        if p0 <= Len then begin
          // last string
          Result:= Result + Unicode2CharSet(AEncoding, Copy(ASrc, p0, Len - p0 + 1), AOptions);
        end;
      end;
  end;
end;

function WideStrings2CRLFString(ALines: TWideStrings): WideString;
var
  i: Integer;
begin
  Result:= '';
  for i:= 0 to ALines.Count - 1 do begin
    Result:= Result + ALines[i] + #13#10;
  end;
end;

{ simple remove wide line separator and insert CRLF pair instead
}
function WideString2CRLFString(const ASrc: WideString): WideString;
var
  p, cnt, L: Integer;
begin
  L:= Length(ASrc);
  SetLength(Result, 2 * L);
  cnt:= 1;
  for p:= 1 to L do begin
    case ASrc[p] of
    jclUnicode.WideLineSeparator: begin
        Result[cnt]:= #13;
        Inc(cnt);
        Result[cnt]:= #10;
      end;
    else
      Result[cnt]:= ASrc[p];
      Inc(cnt);
    end;
  end;
  SetLength(Result, cnt - 1);
end;

{ convert unicode 2- byte wide string to utf-8 or other character set string
  Parameters:
    ACharsetCode:   csusascii, csiso8859_1..csiso8859_9, csshift_JIS, csiso10646_ucs_2, csbig5, csUTF8
                    ususally csUTF8
    W:              source 2- byte unicode wide string
  Returns:          string in code page has been choosed
}
function Unicode2CharSet(ACharsetCode: Integer; const W: WideString; AOptions: TEntityConvOptions): String;
begin
  if not (convEnChar2Entity in AOptions) then begin
    // no entity conversion is required
    case ACharsetCode of
      csiso8859_1: Result:= WSTo_Iso8859_1(W); // Latin-1
      csiso8859_2: Result:= WSTo_Iso8859_2(W); // Latin-2
      csiso8859_3: Result:= WSTo_Iso8859_3(W); // Latin-3
      csiso8859_4: Result:= WSTo_Iso8859_4(W); // Latin-4
      csiso8859_5: Result:= WSTo_Iso8859_5(W); // Cyrillic
      csiso8859_6: Result:= WSTo_Iso8859_6(W); // Arabic
      csiso8859_7: Result:= WSTo_Iso8859_7(W); // Greek
      csiso8859_8: Result:= WSTo_Iso8859_8(W); // Hebrew
      csiso8859_9: Result:= WSTo_Iso8859_9(W); // Latin-6
      csiso8859_10: Result:= WSTo_Iso8859_10(W); // Latin-6
      csiso8859_13: Result:= WSTo_Iso8859_13(W); // Latin-7
      csiso8859_14: Result:= WSTo_Iso8859_14(W); // Latin-8
      csiso8859_15: Result:= WSTo_Iso8859_15(W); // Latin-9
      csKOI8R     : Result:= WSTo_KOI8_R(W);     // KOI8-R
      cs10000_MacRoman: Result:= cp10000_MacRomanToWS(W);   // cp10000_MacRoman
      csWindows1250: Result:= WSTo_cp1250(W);     // Windows-1250
      csWindows1251: Result:= WSTo_cp1251(W);     // Windows-1251
      csWindows1252: Result:= WSTo_cp1252(W);     // Windows-1252
      csUTF8: Result:= System.Utf8Encode(W);
      else begin
        // csusascii, csshift_JIS, csiso10646_ucs_2, csbig5
        Result:= W;
      end; { else case }
    end; { case }
  end else begin
    // numeric entity to character conversion is required
    if (convEnRefCharset in AOptions) then begin
      // convert numeric entity to the current character set
      case ACharsetCode of
        csiso8859_1: Result:= NonASCIIChar2Entity(WSTo_Iso8859_1(W)); // Latin-1
        csiso8859_2: Result:= NonASCIIChar2Entity(WSTo_Iso8859_2(W)); // Latin-2
        csiso8859_3: Result:= NonASCIIChar2Entity(WSTo_Iso8859_3(W)); // Latin-3
        csiso8859_4: Result:= NonASCIIChar2Entity(WSTo_Iso8859_4(W)); // Latin-4
        csiso8859_5: Result:= NonASCIIChar2Entity(WSTo_Iso8859_5(W)); // Cyrillic
        csiso8859_6: Result:= NonASCIIChar2Entity(WSTo_Iso8859_6(W)); // Arabic
        csiso8859_7: Result:= NonASCIIChar2Entity(WSTo_Iso8859_7(W)); // Greek
        csiso8859_8: Result:= NonASCIIChar2Entity(WSTo_Iso8859_8(W)); // Hebrew
        csiso8859_9: Result:= NonASCIIChar2Entity(WSTo_Iso8859_9(W)); // Latin-6
        csiso8859_10: Result:= NonASCIIChar2Entity(WSTo_Iso8859_10(W)); // Latin-6
        csiso8859_13: Result:= NonASCIIChar2Entity(WSTo_Iso8859_13(W)); // Latin-7
        csiso8859_14: Result:= NonASCIIChar2Entity(WSTo_Iso8859_14(W)); // Latin-8
        csiso8859_15: Result:= NonASCIIChar2Entity(WSTo_Iso8859_15(W)); // Latin-9
        csKOI8R     : Result:= NonASCIIChar2Entity(WSTo_KOI8_R(W));     // KOI8-R
        cs10000_MacRoman: Result:= NonASCIIChar2Entity(cp10000_MacRomanToWS(W));   // cp10000_MacRoman
        csWindows1250: Result:= NonASCIIChar2Entity(WSTo_cp1250(W));     // Windows-1250
        csWindows1251: Result:= NonASCIIChar2Entity(WSTo_cp1251(W));     // Windows-1251
        csWindows1252: Result:= NonASCIIChar2Entity(WSTo_cp1252(W));     // Windows-1252
        csUTF8: Result:= System.Utf8Encode(NonASCIIChar2EntityWS(W));
        else begin
          // csusascii, csshift_JIS, csiso10646_ucs_2, csbig5
          Result:= W;
        end;
      end; { case }
    end else begin
      // convert numeric entity to the Unicode
      case ACharsetCode of
        csiso8859_1: Result:= WSTo_Iso8859_1(NonASCIIChar2EntityWS(W)); // Latin-1
        csiso8859_2: Result:= WSTo_Iso8859_2(NonASCIIChar2EntityWS(W)); // Latin-2
        csiso8859_3: Result:= WSTo_Iso8859_3(NonASCIIChar2EntityWS(W)); // Latin-3
        csiso8859_4: Result:= WSTo_Iso8859_4(NonASCIIChar2EntityWS(W)); // Latin-4
        csiso8859_5: Result:= WSTo_Iso8859_5(NonASCIIChar2EntityWS(W)); // Cyrillic
        csiso8859_6: Result:= WSTo_Iso8859_6(NonASCIIChar2EntityWS(W)); // Arabic
        csiso8859_7: Result:= WSTo_Iso8859_7(NonASCIIChar2EntityWS(W)); // Greek
        csiso8859_8: Result:= WSTo_Iso8859_8(NonASCIIChar2EntityWS(W)); // Hebrew
        csiso8859_9: Result:= WSTo_Iso8859_9(NonASCIIChar2EntityWS(W)); // Latin-6
        csiso8859_10: Result:= WSTo_Iso8859_10(NonASCIIChar2EntityWS(W)); // Latin-6
        csiso8859_13: Result:= WSTo_Iso8859_13(NonASCIIChar2EntityWS(W)); // Latin-7
        csiso8859_14: Result:= WSTo_Iso8859_14(NonASCIIChar2EntityWS(W)); // Latin-8
        csiso8859_15: Result:= WSTo_Iso8859_15(NonASCIIChar2EntityWS(W)); // Latin-9
        csKOI8R     : Result:= WSTo_KOI8_R(NonASCIIChar2EntityWS(W));     // KOI8-R
        cs10000_MacRoman: Result:= cp10000_MacRomanToWS(NonASCIIChar2EntityWS(W));   // cp10000_MacRoman
        csWindows1250: Result:= WSTo_cp1250(NonASCIIChar2EntityWS(W));     // Windows-1250
        csWindows1251: Result:= WSTo_cp1251(NonASCIIChar2EntityWS(W));     // Windows-1251
        csWindows1252: Result:= WSTo_cp1252(NonASCIIChar2EntityWS(W));     // Windows-1252
        csUTF8: Result:= System.Utf8Encode(NonASCIIChar2EntityWS(W));
        else begin
          // csusascii, csshift_JIS, csiso10646_ucs_2, csbig5
          Result:= W;
        end;
      end; { case }
    end;
  end;
  if convEnRemoveTrailingSpaces in AOptions
  then Result:= TrimRight(Result);

end;

{ Tool. ISO 639 language codes.
  read text file AInFileName, parse and sort by language code each AStr consists of:

  Afar aa $01
  ...
  Rhaeto-Romance rm $8C
  ...

  Result file AOutFileName :
  ...
  $01 (d: 'aa'; n: 'Afar'),
  ...
}
procedure Tool_ReadLanguage2Pascal(AInFileName, AOutFileName: String);
var
  i: Integer;
  sl, r: TStringList;
  s, lang, shortlang, langnumber: String;
  langnum: Integer;
  o: Integer;
begin
  sl:= TStringList.Create;
  r:= TStringList.Create;
  sl.LoadFromFile(AInFileName);
  for i:= 0 to sl.Count - 1 do begin
    s:= sl[i];
    o:= 1;
    lang:= GetToken(o, #32, s);
    Inc(o);
    shortlang:= GetToken(o, #32, s);
    if Length(shortlang) > 2 then begin
      lang:= lang + shortlang;
      Inc(o);
      shortlang:= GetToken(o, #32, s);
    end;
    Inc(o);
    langnumber:= GetToken(o, #32, s);
    langnum:= StrToIntDef(langnumber, -1);
    r.Add(Format('{ $%.2x } (d: ''%s''; n: ''%s''),' , [langnum, shortlang, lang]));
  end;
  r.Sorted:= True;
  r.SaveToFile(AOutFileName);
  r.Free;
  sl.Free;
end;

{---------------------------- http header routines ----------------------------}

{ sumilar to httpApp implementation
  Cookie  ExtractHeaderFields([';'], [' '], PChar(CookieStr), Strings, True);
  Query   ExtractHeaderFields(['&'], [], PChar(ContentStr), Strings, False);
}

function GetHeaderName(var AContent: PChar): String;
var
  p: Integer;
begin
  p:= 0;
  repeat
    case AContent[p] of
    #0: Break;
    ':', '=': Break;
    end;
    Inc(p);
  until False;
  Result:= Copy(AContent, 1, p);
  AContent:= AContent + p + 1;
  while (AContent^ <> #0) and (AContent^ <= #32)
  do Inc(AContent);
end;

{ Extract header string to list of values. Extensions stored in AExt
  Parameter:
    Content: Accept: text/plain; q=0.3, text/html; q=0.7...
  Result (objects points to AExt):
    AList[0] text/plain AList.Objects[0]=TObject(0)
    AList[1] text/html  AList.Objects[1]=TObject(1)
    AExt[0]  q=0.3
    AExt[1]  q=0.7
    ...
}
function ExtractHeaderExtFields(Content: PChar; AList: TStrings; AExt: TStrings): String;
var
  Head, Tail: PChar;
  EOS, InQuote, LeadQuote: Boolean;
  QuoteChar: Char;

  procedure DoStripQuotes(const S: string);
  var
    I: Integer;
    st: Integer;
    extfound: Boolean;
    idx, eidx, extstart: Integer;
  begin
    extstart:= 0; // just for compiler
    idx:= AList.Add('');
    extfound:= False;
    {       state
            0   no '=' found, no " found
        "=  1   " found before =
        '=' 2   = found
        = " 3   " found after =
    }
    st:= 0;
    for i:= 1 to Length(S) do begin
      case S[i] of
      '''', '"':begin
          case st of
          0: st:= 1;                 // "^par=
          2: st:= 3;                 // par="^
          3: st:= 2;
          end;
        end;
      ';': begin
          case st of
          0, 2:begin
              extfound:= True;
              extstart:= i + 1;
              Break;
            end;
          end;
          AList[idx]:= AList[idx] + S[i];
        end;
      '=': begin
          case st of
          0,1: st:= 2;               // par=^
          end;
          AList[idx]:= AList[idx] + S[i];
        end;
      #0..#32: begin
          case st of
          0,1,3: AList[idx]:= AList[idx] + S[i]; // par="Word1 ^
          end;
        end;
      else AList[idx]:= AList[idx] + S[i]; //
      end;
    end; { for }
    { extension }
    if extfound then begin
      eidx:= AExt.AddObject('', TObject(idx));
      st:= 0;
      for i:= extstart to Length(S) do begin
        case S[i] of
        '''', '"':begin
            case st of
            0: st:= 1;                 // "^par=
            2: st:= 3;                 // par="^
            3: st:= 2;
            end;
          end;
        ';': begin
            case st of
            2:begin
                eidx:= AExt.AddObject('', TObject(idx));
              end;
            end;
            AExt[eidx]:= AExt[eidx] + S[i];
          end;
        '=': begin
            case st of
            0,1: st:= 2;               // par=^
            end;
            AExt[eidx]:= AExt[eidx] + S[i];
          end;
        #0..#32: begin
            case st of
            1,3: AExt[eidx]:= AExt[eidx] + S[i]; // par="Word1 ^
            end;
          end;
        else AExt[eidx]:= AExt[eidx] +  S[i]; //
        end;
      end; { for }
    end;
  end;

begin
  if (Content = nil) or (Content^ = #0) then Exit;
  Result:= GetHeaderName(Content);
  Tail:= Content;

  QuoteChar := #0;
  repeat
    while Tail^ in [#32, #13, #10] do Inc(Tail);
    Head := Tail;
    InQuote := False;
    LeadQuote := False;
    while True do begin
      while (InQuote and not (Tail^ in [#0, #13, #10, '"'])) or
        not (Tail^ in [#0, #13, #10, '"', ',']) do Inc(Tail);
      if Tail^ = '"' then begin
        if (QuoteChar <> #0) and (QuoteChar = Tail^) then
          QuoteChar := #0
        else begin
          LeadQuote := Head = Tail;
          QuoteChar := Tail^;
          if LeadQuote then Inc(Head);
        end;
        InQuote := QuoteChar <> #0;
        if InQuote then
          Inc(Tail)
        else Break;
      end else Break;
    end;
    if not LeadQuote and (Tail^ <> #0) and (Tail^ = '"') then
      Inc(Tail);
    EOS := Tail^ = #0;
    Tail^ := #0;
    if Head^ <> #0 then
      DoStripQuotes(Head);
    Inc(Tail);
  until EOS;
end;

function GetHeaderFieldString(Index: Integer): string;
begin
  Result := '';
end;

{ In accompany to ExtractHeaderExtFields, extract extension value if exists
  Usage:
    qval:= GetHeaderExt(i, 'q', pars, ext);
  Return value of extension AExtName (i.e. '0.3') for parameter no
  if i >= pars.Count or i < 0 return ''
  i.e.
    Accept: text/plain; q=0.5, text/html, text/x-dvi; q=0.8, text/x-c
    AList       AExt    AExt.Objects
    text/plain  q=0.5   0
    text/html,
    text/x-dvi  q=0.8   2
    text/x-c
}
function GetHeaderExt(AOrder: Integer; const AExtName: String; AList: TStrings; AExt: TStrings): String;
var
  i: Integer;
  ct: String;
  L: Integer;
begin
  Result:= '';
  if (AOrder < 0) // or (not (Assigned(AList))) or (not (Assigned(AExt)))
    or (AOrder >= AList.Count) then Exit;
  ct:= AExtName + '=';
  L:= Length(ct);
  for i:= 0 to AExt.Count - 1 do begin
    if AOrder <= Integer(AExt.Objects[i]) then begin  // <= because AList can consists of list
      if CompareText(ct, Copy(AExt[i], 1, L)) = 0 then begin
        Result:= Copy(AExt[i], L + 1, MaxInt);
        Exit;
      end;
    end;
  end;
end;

const
// These strings are NOT to be resourced
  Months: array[1..12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
  DaysOfWeek: array[1..7] of string = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');

function ParseDate(const DateStr: string; var isValid: Boolean): TDateTime;
var
  Month, Day, Year, Hour, Minute, Sec: Integer;
  Parser: TParser;
  StringStream: TStringStream;

  function GetMonth: Boolean;
  begin
    if Month < 13 then begin
      Result := False;
      Exit;
    end;
    Month := 1;
    while not Parser.TokenSymbolIs(Months[Month]) and (Month < 13) do Inc(Month);
    Result := Month < 13;
  end;

  procedure GetTime;
  begin
    with Parser do begin
      Hour := TokenInt;
      NextToken;
      if Token = ':' then NextToken;
      Minute := TokenInt;
      NextToken;
      if Token = ':' then NextToken;
      Sec := TokenInt;
      NextToken;
    end;
  end;

begin
  isValid:= False;
  Month := 13;
  StringStream := TStringStream.Create(DateStr);
  try
    Parser := TParser.Create(StringStream);
    with Parser do
    try
      Month := TokenInt;
      NextToken;
      if Token = ':' then NextToken;
      NextToken;
      if Token = ',' then NextToken;
      if GetMonth then begin
        NextToken;
        Day := TokenInt;
        NextToken;
        GetTime;
        Year := TokenInt;
      end else begin
        Day := TokenInt;
        NextToken;
        if Token = '-' then NextToken;
        GetMonth;
        NextToken;
        if Token = '-' then NextToken;
        Year := TokenInt;
        if Year < 100 then Inc(Year, 1900);
        NextToken;
        GetTime;
      end;
      Result := EncodeDate(Year, Month, Day) + EncodeTime(Hour, Minute, Sec, 0);
      isValid:= True;
    finally
      Free;
    end;
  finally
    StringStream.Free;
  end;
end;

function GetDateTimeStamp(ADt: TDateTime): String;
var
  Year, Month, Day: Word;
begin
  DecodeDate(ADt, Year, Month, Day);
  Result:= Format(FormatDateTime('"%s", dd "%s" yyyy hh:mm:ss', ADt),  //  "GMT"
    [DaysOfWeek[DayOfWeek(ADt)], Months[Month]]);
end;

function GetHeaderFieldDate(Index: Integer): TDateTime;
var
  Value: string;
  v: Boolean;
begin
  Value:= GetHeaderFieldString(Index);
  if Value <> '' then
    Result := ParseDate(Value, v)
  else Result := -1;
end;

function GetHeaderFieldInteger(Index: Integer): Integer;
var
  Value: string;
begin
  Value:= GetHeaderFieldString(Index);
  if Value <> ''
  then Result:= StrToIntDef(Value, -1) // or raise?
  else Result := -1;
end;

{
  Parameters:
     AMargin: tight margin value
       usually 80
       0, -1 are special values means no right edge so no split
  See also:
    customxml.TextRightEdgeCol: Integer = 80;
}
function SplitLongText(const AStr: WideString; APos: Integer; ABlockIndent, AMargin: Integer): WideString;
var
  Col, i: Integer;
  LinePos, LineLen: Integer;
  BreakLen, BreakPos: Integer;
  CurChar: WideChar;
  ExistingBreak: Boolean;
  L: Integer;
begin
  if AMargin <= 0 then begin
    Result:= AStr;
    Exit;
  end;    
  Col:= 1;
  LinePos:= 1;
  BreakPos:= 0;
  ExistingBreak:= False;
  LineLen:= Length(AStr);
  BreakLen:= Length(WideCRLF);
  Result:= '';
  while APos <= LineLen do begin
    CurChar:= AStr[APos];
    if CurChar = WideCRLF[1] then begin
      ExistingBreak := CompareText(WideCRLF, Copy(AStr, APos, BreakLen)) = 0;
      if ExistingBreak then begin
        Inc(APos, BreakLen - 1);
        BreakPos:= APos;
      end;
    end else begin
      if ((CurChar = #32) or (CurChar = '-') or (CurChar = #9))
      then BreakPos:= APos;
    end;
    Inc(APos);
    Inc(Col);
    if (ExistingBreak or ((Col > AMargin) and (BreakPos > LinePos))) then begin
      Col:= APos - BreakPos;
      Result:= Result + Copy(AStr, LinePos, BreakPos - LinePos + 1);
      while APos <= LineLen do begin
        if ((AStr[APos] = #32) or (AStr[APos] = '-') or(AStr[APos] = #9)) then
          Inc(APos)
        else if Copy(AStr, APos, Length(sLineBreak)) = sLineBreak then
          Inc(APos, Length(WideCRLF))
        else
          Break;
      end;
      if not ExistingBreak and (APos < LineLen) then begin
        Result:= Result + WideCRLF;
        // left align with spaces
        if customxml.BlockIndent > 0 then begin
          i:= Length(Result);
          SetLength(Result, i + ABlockIndent);
          Inc(i);
          L:= Length(Result);
          while i <= L do begin
            Result[i]:= #32;
            Inc(i);
          end;
        end;
      end;
      Inc(BreakPos);
      LinePos:= BreakPos;
      ExistingBreak:= False;
    end;
  end;
  Result:= Result + Copy(AStr, LinePos, MaxInt);
end;

{
1. ButtonText = Text at the bottom 
of the button 
2. MenuText = The tools menu item with 
a reference to your program. 
3. MenuStatusbar = *Ignore* 
4. CLSID = Your unique classID.
You can use GUIDTOSTRING to create 
a new CLSID (for each button).   

5. Default Visible := Display it. 
6. Exec := Your program path to execute. 
7. Hoticon := (Mouse Over Event) 
ImageIndex in shell32.dll 
8. Icon := ImageIndex in shell32.dll
}

procedure CreateExplorerButton(ProgramPath: String);
const
  // the same explanation as for the CLSID
  TagID = '\{10954C80-4F0F-11d3-B17C-00C0DFE39736}\';
var
  Reg: TRegistry;
  RegKeyPath: string;
begin
 Reg:= TRegistry.Create;
 try
  with Reg do begin
   RootKey := HKEY_LOCAL_MACHINE;
   RegKeyPath := 'Software\Microsoft\Internet Explorer\Extensions';
   OpenKey(RegKeyPath + TagID, True);
   WriteString('ButtonText', 'Your program Button text');
   WriteString('MenuText', 'Your program Menu text');
   WriteString('MenuStatusBar', 'Run Script');
   WriteString('ClSid', '{1FBA04EE-3024-11d2-8F1F-0000F87ABD16}');
   WriteString('Default Visible', 'Yes');
   WriteString('Exec', ProgramPath);
   WriteString('HotIcon', ',4');
   WriteString('Icon', ',4');
  end
 finally
  Reg.CloseKey;
  Reg.Free;
 end;
end;

{
After you run this code, start a new
instance of IE. You might need to go to
View | Toolbars | Customize and
move your button from "Available toolbar
buttons" to "Current toolbar buttons"
}

{--------------------- simplify xml routines ----------------------------------}

const
  URL_COMMERCIAL = 'http://commandus.com/';
  MSG_COMMERCIAL = 'Made in Minute (' + URL_COMMERCIAL + ')';

function SimpleGetMimeType(const AURI: String): String;
begin
  Result:= util1.MIMEByExt(AUri);
end;

procedure GetListOfElements(AElement: TxmlElement; AClass: TxmlElementClass; const AAttr: String; AResultList: TStrings);
var
  n: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
  a: TxmlAttribute;
begin
  // element and attributes
  if AElement is AClass then begin
    a:= AElement.Attributes.ItemByName[AAttr];
    if Assigned(a) and (a.AttrType = atHref) and (Length(a.Value) > 0) then begin
      AResultList.AddObject(a.Value, AElement);
    end;
  end;
  // check is nested elements exists
  if not AElement.IsEmpty then begin
    // have nested elements, replace last space to ">".
    // insert embedded elements
    for n:= 0 to AElement.NestedElements1Count - 1 do begin
      NestedElement:= AElement.GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        GetListOfElements(NestedElement, AClass, AAttr, AResultList);
      end;
    end;
  end;
end;

{ ExtractExternalLinks
    extract external links in ADoc wide strings, add found links to AResultList
  Parameters:
    AIEDownload pointer to IE download component
    ADocKind: edOEB or edXHTML
    ADepth -
      = -1 do not parse
      = 0  parse passed document only
      > 0  parse nested documents
    ANotify
      reserved
    AReserved
      reserved
  Return
    Result ?
    AResultList list of extenal links with object (lo)
      = 0 - texts
      = 1 - css
      = 2 - images
      = 3 - binaries
    high bits contains is set if this page solved
}
function ExtractExternalLinks(var ABaseURI: String; AElement: TxmlElement;
  ADepth: Integer; AResultList: TStrings; ANotify: Pointer; AReserved: Pointer): Integer;
var
  i: Integer;
  e: TxmlElement;
  sl: TStrings;
  s: String;
begin
  Result:= 0;
  if ADepth < 0
  then Exit;
  sl:= TStringList.Create;
  // create collection
  // find out base element if exists
  GetListOfElements(AElement, ToebBase, 'href', sl);
  // set base URI
  if sl.Count > 0
  then ABaseURI:= util1.httpConcatPath(ABaseURI, sl[0]); //?!!

  // find out text/css links if exists
  sl.Clear;
  GetListOfElements(AElement, ToebLink, 'href', sl);
  for i:= 0 to sl.Count - 1 do begin
    e:= TxmlElement(sl.Objects[i]);
    if CompareText(e.Attributes.ValueByName['type'], 'text/css') = 0 then begin
      s:= util1.httpConcatPath(ABaseURI, sl[i]);
      if AResultList.IndexOf(s) < 0
      then AResultList.AddObject(s, TObject(1));
      // sync name
      e.Attributes.ValueByName['href']:= s;
    end;
  end;

  // find out img elements if exists
  sl.Clear;
  GetListOfElements(AElement, ToebImg, 'src', sl);
  for i:= 0 to sl.Count - 1 do begin
    e:= TxmlElement(sl.Objects[i]);
    s:= util1.httpConcatPath(ABaseURI, sl[i]);
    if AResultList.IndexOf(s) < 0
    then AResultList.AddObject(s, TObject(2));
    // sync name
    e.Attributes.ValueByName['src']:= s;
  end;

  // prepare to recursion
  Dec(ADepth);
  if ADepth < 0
  then Exit;
  sl.Free;
end;

procedure RemoveElements(AElement: TxmlElement; AClass2Remove: TxmlElementClass);
var
  n: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
begin
  // element and attributes
  if AElement is AClass2Remove then begin
    AElement.Free;
    Exit;
  end;
  // check is nested elements exists
  if not AElement.IsEmpty then begin
    // have nested elements
    for n:= 0 to AElement.NestedElements1Count - 1 do begin
      NestedElement:= AElement.GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        RemoveElements(NestedElement, AClass2Remove);
      end;
    end;
  end;
end;

function GetPCDATAText(AElement: TxmlElement): WideString;
var
  n: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
begin
  if AElement is ToebPCData then begin
    Result:= AElement.Attributes.ValueByName['value'];
    Exit;
  end;
  Result:= '';
  // check is nested elements exists
  if not AElement.IsEmpty then begin
    // have nested elements
    for n:= 0 to AElement.NestedElements1Count - 1 do begin
      NestedElement:= AElement.GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        if (NestedElement is TOEBBr) or (NestedElement is TOEBP) or (NestedElement is TOEB_H) or
          (NestedElement is TOEBHr) or (NestedElement is TOEBTable) or (NestedElement is TOEBTr) or (NestedElement is TOEBDiv)
        then begin
          Result:= Result + '<br/>' + GetPCDATAText(NestedElement);
        end else begin
          Result:= Result + GetPCDATAText(NestedElement);
        end;
      end;
    end;
  end;
end;

procedure SimplifyBodyAsText(AElement: TxmlElement);
var
  n: Integer;
  c: TxmlElementCollection;
  ws: WideString;
  e: TxmlElement;
begin
  // element and attributes
  ws:= '<br/>' + GetPCDATAText(AElement);
  // delete doubled <br/>
  repeat
    n:= Pos('<br/><br/>', ws);
    if n <= 0
    then Break;
    Delete(ws, n, 5);
  until False;

  AElement.NestedElements.ClearNestedElements;
  c:= AElement.NestedElements.GetByClass(TOEBBr);
  if Assigned(c) then begin
    e:= c.Add;
    // e.Attributes.ValueByName['value']:= ws;
    xmlCompileText(ws, Nil, Nil, Nil, e, ToebContainer);
  end;
end;

procedure SimplifyTables(AElement: TxmlElement);
var
  n: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
  c: TxmlElementCollection;
  ws: WideString;
begin
  // check is nested elements exists
  if AElement is TOEBTable then begin
    n:= AElement.Attributes.IndexOf('width');
    if n >= 0
    then AElement.Attributes.Delete(n);
  end;

  if AElement is TOEBTr then begin
    // p:= AElement.ParentElement;
    n:= AElement.Attributes.IndexOf('rowspan');
    if n >= 0
    then AElement.Attributes.Delete(n);

    ws:= GetPCDATAText(AElement);
    // delete doubled <br/>
    repeat
      n:= Pos('<br/><br/>', ws);
      if n <= 0
      then Break;
      Delete(ws, n, 5);
    until False;

    AElement.NestedElements.ClearNestedElements;
    c:= AElement.NestedElements.GetByClass(TOEBTd);
    if Assigned(c) then begin
      NestedElement:= c.Add;
      NestedElement:= NestedElement.NestedElements.GetByClass(TOEBPCData).Add;
      xmlCompileText(ws, Nil, Nil, Nil, NestedElement, ToebContainer);
    end;
    Exit;
  end;

  if not AElement.IsEmpty then begin
    // have nested elements
    for n:= 0 to AElement.NestedElements1Count - 1 do begin
      NestedElement:= AElement.GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        SimplifyTables(NestedElement);
      end;
    end;
  end;
end;

procedure SimplifyRemoveTables(AElement: TxmlElement);
var
  n: Integer;
  NestedElementClass: TPersistentClass;
  p, NestedElement: TxmlElement;
  c: TxmlElementCollection;
  ws: WideString;
begin
  // check is nested elements exists
  if AElement is TOEBTable then begin
    p:= AElement.ParentElement;
    if not Assigned(p)
    then Exit;
    ws:= '<br/>' + GetPCDATAText(p);
    // delete doubled <br/>
    repeat
      n:= Pos('<br/><br/>', ws);
      if n <= 0
      then Break;
      Delete(ws, n, 5);
    until False;

    AElement.Free;
    c:= p.NestedElements.GetByClass(TOEBBr);
    if Assigned(c) then begin
      NestedElement:= c.Add;
      xmlCompileText(ws, Nil, Nil, Nil, NestedElement, ToebContainer);  // TOebBr
    end;
    Exit;
  end;
  if not AElement.IsEmpty then begin
    // have nested elements
    for n:= 0 to AElement.NestedElements1Count - 1 do begin
      NestedElement:= AElement.GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        SimplifyRemoveTables(NestedElement);
      end;
    end;
  end;
end;

procedure RemoveElementsKeepInner(AElement: TxmlElement; AClass2Remove: TxmlElementClass);
var
  n: Integer;
  NestedElementClass: TPersistentClass;
  p, NestedElement: TxmlElement;
  c: TxmlElementCollection;
  ws: WideString;
begin
  // check is nested elements exists
  if AElement is AClass2Remove then begin
    p:= AElement.ParentElement;
    if not Assigned(p)
    then Exit;
    ws:= GetPCDATAText(p);
    AElement.Free;

    c:= p.NestedElements.Items[0];
    if Assigned(c) then begin
      NestedElement:= c.Add;
      xmlCompileText(ws, Nil, Nil, Nil, NestedElement, ToebContainer);  // TOebBr
    end;
    Exit;
  end;
  if not AElement.IsEmpty then begin
    // have nested elements
    for n:= 0 to AElement.NestedElements1Count - 1 do begin
      NestedElement:= AElement.GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        RemoveElementsKeepInner(NestedElement, AClass2Remove);
      end;
    end;
  end;
end;

procedure SimplifySetTahomaFont(const AElement: TxmlElement);
var
  n, o: Integer;
  NestedElementClass: TPersistentClass;
  NestedElement: TxmlElement;
  c: TxmlElementCollection;
  p, sp: TxmlElement;
  ws: WideString;
  idx: Integer;
begin
  // check is nested elements exists
  if AElement is ToebPCData then begin
    p:= AElement.ParentElement;
    if Assigned(p) then begin
      o:= AElement.Order;
      ws:= AElement.Attributes.ValueByName['value'];
      AElement.Free;
      if (p is ToebFont) then begin
        p.Attributes.ValueByName['face']:= 'Tahoma';
        c:= p.NestedElements.GetByClass(TOEBPCData);
        if Assigned(c) then begin
          sp:= c.Add;
          sp.SetNewOrder(o);
          sp.Attributes.ValueByName['value']:= ws;
        end;
      end else begin
        c:= p.NestedElements.GetByClass(TOEBFont);
        if Assigned(c) then begin
          sp:= c.Add;
          sp.SetNewOrder(o);
          sp.Attributes.ValueByName['face']:= 'Tahoma';
          c:= sp.NestedElements.GetByClass(TOEBPCData);
          // o:= sp.Index;
          if Assigned(c) then begin
            sp:= c.Add;
            sp.Attributes.ValueByName['value']:= ws;
          end;
        end else begin
          p.Attributes.ValueByName['style']:= 'font-family: Tahoma';
          c:= p.NestedElements.GetByClass(TOEBPCData);
          if Assigned(c) then begin
            sp:= c.Add;
            sp.SetNewOrder(o);
            sp.Attributes.ValueByName['value']:= ws;
          end;
        end;
      end;
    end;
  end else begin
    AElement.Attributes.ValueByName['class']:= '';
    AElement.Attributes.ValueByName['style']:= '';
    if not AElement.IsEmpty then begin
      // have nested elements
      n:= 0;
      while n < AElement.NestedElements1Count do begin
        NestedElement:= AElement.GetNested1ElementByOrder(n, NestedElementClass);
        if Assigned(NestedElement) then begin
          SimplifySetTahomaFont(NestedElement);
        end;
        Inc(n);
      end;
    end;
  end;
end;

procedure SimplifySkipIndents(const AElement: TxmlElement);
begin
  RemoveElementsKeepInner(AElement, TOEBBlockQuote);
end;

// uses ForcedLanguage global variable
procedure SimplifyForceLanguage(AElement: TxmlElement);
begin
end;

procedure AddAds2Body(AElement: TxmlElement);
var
  n: Integer;
  NestedElementClass: TPersistentClass;
  // p: TxmlElement;
  NestedElement: TxmlElement;
  c: TxmlElementCollection;
begin
  // check is nested elements exists
  if AElement is TOEBBody then begin
    c:= AElement.NestedElements.GetByClass(TOEBHr);
    if Assigned(c) then begin
      NestedElement:= c.Add;
      c:= AElement.NestedElements.GetByClass(TOEBCenter);
      if Assigned(c) then begin
        NestedElement:= c.Add;
        c:= NestedElement.NestedElements.GetByClass(TOEBFont);
        if Assigned(c) then begin
          NestedElement:= c.Add;
          NestedElement.Attributes.ValueByName['face']:= 'Times New Roman';
          c:= NestedElement.NestedElements.GetByClass(TOEBPCData);
          if Assigned(c) then begin
            NestedElement:= c.Add;
            NestedElement.Attributes.ValueByName['value']:= MSG_COMMERCIAL;
          end;
        end;  
      end;
    end;
    Exit;
  end;
  if not AElement.IsEmpty then begin
    // have nested elements
    for n:= 0 to AElement.NestedElements1Count - 1 do begin
      NestedElement:= AElement.GetNested1ElementByOrder(n, NestedElementClass);
      if Assigned(NestedElement) then begin
        AddAds2Body(NestedElement);
      end;
    end;
  end;
end;

function RemoveAllTextLinksExcept1(AList: TStrings): Integer;
var
  i: Integer;
begin
  Result:= 0;
  // except element 0, so start with 1
  i:= 1;
  while i < AList.Count do begin
    if (Integer(AList.Objects[i]) in [0, 3])
    then AList.Delete(i)
    else Inc(i);
  end;
end;

function ExtractFolder(const AURI: String): String;
var
  p, pu, pd: Integer;
begin
  pu:= util1.PosBack('/', AUri);
  pd:= util1.PosBack('\', AUri);
  p:= Max(pu, pd);
  if p <= 0
  then p:= Length(AURI);
  Result:= Copy(AURI, 1, p);
end;

{--------------------- OEB package routines -----------------------------------}

function CreateDefaultPkgContainer(const AIdentifier, ATitle,
  ACreator, APublisher, ASource,
  ACoverImage, AThumbImage, ATitleImage: WideString; AManifestItems: TStrings): TxmlElementCollection;
var
  i: Integer;
  e, p, m, dc, dc1, pc, manifest, mi, spine, itemref, guide, ref: TxmlElement;
  Coll: TxmlElementCollection;
  CoverImage, CoverImagePocket, ThumbImage, ThumbImagePocket, TitleImage, AboutPage: WideString;
begin
  Result:= TxmlElementCollection.Create(TPkgContainer, Nil, wciOne);
  Result.Clear1;
  e:= Result[0];
  // get image files
  if (Pos('.', ACoverImage) <= 1) then begin
    CoverImage:= litconv.DEF_COVER_URL;
    CoverImagePocket:= litconv.DEF_COVER0_URL;
    AManifestItems.Add(CoverImage);
    AManifestItems.Add(CoverImagePocket);
  end else begin
    CoverImage:= ACoverImage;
    CoverImagePocket:= ACoverImage;
  end;
  if Pos('.', AThumbImage) <= 1 then begin
    ThumbImage:= litconv.DEF_THUMB_URL;
    ThumbImagePocket:= litconv.DEF_THUMB0_URL;
    AManifestItems.Add(ThumbImage);
    AManifestItems.Add(ThumbImagePocket);
  end else begin
    ThumbImage:= AThumbImage;
    ThumbImagePocket:= AThumbImage;
  end;
  if Pos('.', ATitleImage) <= 1 then begin
    TitleImage:= litconv.DEF_TITLE_URL;
    AManifestItems.Add(TitleImage);
  end else TitleImage:= ATitleImage;

  AboutPage:= litconv.DEF_ABOUT_URL;
  AManifestItems.Add(AboutPage);

  // package
  Coll:= e.NestedElements.GetByClass(ToebPackage);
  p:= Coll.Add;
  p.Attributes.ValueByName['unique-identifier']:= 'notisbn';
  // metadata
  Coll:= p.NestedElements.GetByClass(TPkgMetadata);
  m:= Coll.Add;
  // dc metadata
  Coll:= m.NestedElements.GetByClass(TPkgDCMetadata);
  dc:= Coll.Add;
  dc.Attributes.ValueByName['xmlns:dc']:= 'http://purl.org/metadata/dublin_core';
  dc.Attributes.ValueByName['xmlns:oebpackage']:= 'http://openebook.org/namespaces/oeb-package/1.0/';

  // dc:Title
  Coll:= dc.NestedElements.GetByClass(TPkgDCTitle);
  dc1:= Coll.Add;
  Coll:= dc1.NestedElements.GetByClass(TPkgPCData);
  pc:= Coll.Add;
  pc.Attributes.ValueByName['value']:= ATitle;

  // dc:Creator
  Coll:= dc.NestedElements.GetByClass(TPkgDCCreator);
  dc1:= Coll.Add;
  dc1.Attributes.ValueByName['role']:= 'aut';
  dc1.Attributes.ValueByName['file-as']:= ACreator;
  Coll:= dc1.NestedElements.GetByClass(TPkgPCData);
  pc:= Coll.Add;
  pc.Attributes.ValueByName['value']:= ACreator;

  // dc:Publisher
  Coll:= dc.NestedElements.GetByClass(TPkgDCPublisher);
  dc1:= Coll.Add;
  Coll:= dc1.NestedElements.GetByClass(TPkgPCData);
  pc:= Coll.Add;
  pc.Attributes.ValueByName['value']:= APublisher;

  // dc:Identifier
  Coll:= dc.NestedElements.GetByClass(TPkgDCIdentifier);
  dc1:= Coll.Add;
  dc1.Attributes.ValueByName['id']:= 'notisbn';
  Coll:= dc1.NestedElements.GetByClass(TPkgPCData);
  pc:= Coll.Add;
  pc.Attributes.ValueByName['value']:= AIdentifier;

  // dc:Source
  Coll:= dc.NestedElements.GetByClass(TPkgDCSource);
  dc1:= Coll.Add;
  Coll:= dc1.NestedElements.GetByClass(TPkgPCData);
  pc:= Coll.Add;
  pc.Attributes.ValueByName['value']:= ASource;

  // manifest
  Coll:= p.NestedElements.GetByClass(TPkgManifest);
  manifest:= Coll.Add;
  AManifestItems.Add(DEF_THUMB_URL);
  {
  AManifestItems.Add(DEF_COVER_URL);
  AManifestItems.Add(DEF_TITLE_URL);
  }
  // manifest items
  Coll:= manifest.NestedElements.GetByClass(TPkgItem);
  for i:= 0 to AManifestItems.Count - 1 do begin
    mi:= Coll.Add;
    with mi.Attributes do begin
      if i = 0
      then ValueByName['id']:= 'content'
      else ValueByName['id']:= 'item' + IntToStr(i);
      ValueByName['href']:= AManifestItems[i];
      ValueByName['media-type']:= SimpleGetMimeType(AManifestItems[i]);
    end;
  end;

  mi:= Coll.Add;
  with mi.Attributes do begin
    ValueByName['id']:= 'about';
    ValueByName['href']:= AboutPage;
    ValueByName['media-type']:= 'text/x-oeb1-document';
  end;

  // spine
  Coll:= p.NestedElements.GetByClass(TPkgSpine);
  spine:= Coll.Add;
  // spine item refs
  Coll:= spine.NestedElements.GetByClass(TPkgItemRef);
  itemref:= Coll.Add;
  itemref.Attributes.ValueByName['idref']:= 'content';
  {
  itemref:= Coll.Add;
  itemref.Attributes.ValueByName['idref']:= 'about';
  }
  // guide
  Coll:= p.NestedElements.GetByClass(TPkgGuide);
  guide:= Coll.Add;
  // references:
  // - This is the splash page and book cover that appears the first time a book is opened.
  Coll:= guide.NestedElements.GetByClass(TPkgReference);

  ref:= Coll.Add;
  with ref.Attributes do begin
    ValueByName['type']:= 'other.ms-copyright';
    ValueByName['title']:= 'About This Book';
    ValueByName['href']:= AboutPage;
  end;

  ref:= Coll.Add;
  with ref.Attributes do begin
    ValueByName['type']:= 'title-page';
    ValueByName['title']:= 'About';
    ValueByName['href']:= AboutPage;
  end;

  {
  ref:= Coll.Add;
  with ref.Attributes do begin
    ValueByName['type']:= 'other.ms-firstpage';  // set 'title-page' too
    ValueByName['title']:= 'First page';
    ValueByName['href']:= AboutPage;
  end;
  }

  if Length(CoverImage) > 0 then begin
    ref:= Coll.Add;
    with ref.Attributes do begin
      ValueByName['type']:= 'other.ms-coverimage-standard';  // PC version
      ValueByName['title']:= 'Book cover image';
      ValueByName['href']:= CoverImage;
    end;
  end;
  if Length(CoverImagePocket) > 0 then begin
    ref:= Coll.Add;
    with ref.Attributes do begin
      ValueByName['type']:= 'other.ms-coverimage';  // Pocket version
      ValueByName['title']:= 'Book cover image';
      ValueByName['href']:= CoverImagePocket;
    end;
  end;
  // - Thumbnails are used in the Library
  if Length(ThumbImage) > 0 then begin
    ref:= Coll.Add;
    with ref.Attributes do begin
      ValueByName['type']:= 'other.ms-thumbimage-standard';
      ValueByName['title']:= 'Thumbnail';
      ValueByName['href']:= ThumbImage;
    end;
  end;
  if Length(ThumbImagePocket) > 0 then begin
    ref:= Coll.Add;
    with ref.Attributes do begin
      ValueByName['type']:= 'other.ms-thumbimage';
      ValueByName['title']:= 'Thumbnail';
      ValueByName['href']:= ThumbImagePocket;
    end;
  end;

  // - The tall, narrow image found on the left side of the cover (title) page.
  if Length(TitleImage) > 0 then begin
    ref:= Coll.Add;
    with ref.Attributes do begin
      ValueByName['type']:= 'other.ms-titleimage-standard';
      ValueByName['title']:= 'Left-side title image';
      ValueByName['href']:= TitleImage;
    end;
  end;

  // skip others..
  // other.ms-coverimage. landscape Pocket PC cover graphic
  // other.ms-thumbimage. landscape Pocket PC thumbnail graphic
end;

procedure BuildImageList(AElement: TxmlElement; AImages: TStrings; AMaxImagesCount: Integer);
var
  i: Integer;
  e: TxmlElement;
  ws: WideString;
begin
  i:= 0;
  AImages.Clear;
  repeat
    e:= AElement.NestedElement[ToebImg, i];
    if (not Assigned(e)) or (i > AMaxImagesCount)
    then Break;
    ws:= e.Attributes.ValueByName['src'];
    if ws <> '' then begin
      AImages.AddObject(ws, Nil);
    end;
    Inc(i);
  until False;
  if AImages.Count = 0 then begin
    AImages.AddObject('', Nil);
  end;
end;

{ codepage to unicode conversion functions }

function Iso8859_1ToWS(const AStr: String): WideString;  // Latin-1
{
var
  i, len: Integer;
}
begin
  // len:= Length(AStr);
  Result:= AStr;
  {
  for i:= 1 to len do begin
    Result:= Result + AStr[i];
  end;
  }
end;

function Iso8859_2ToWS(const AStr: String): WideString; // Latin-2
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Word(AStr[i]) of
      $a1: Result[i]:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
      $a2: Result[i]:= #$02d8;  // BREVE
      $a3: Result[i]:= #$0141;  // LATIN CAPITAL LETTER L WITH STROKE
      $a5: Result[i]:= #$0132;  // LATIN CAPITAL LETTER L WITH CARON
      $a6: Result[i]:= #$015a;  // LATIN CAPITAL LETTER S WITH ACUTE
      $a9: Result[i]:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
      $aa: Result[i]:= #$015e;  // LATIN CAPITAL LETTER S WITH CEDILLA
      $ab: Result[i]:= #$0164;  // LATIN CAPITAL LETTER T WITH CARON
      $ac: Result[i]:= #$0179;  // LATIN CAPITAL LETTER Z WITH ACUTE
      $ae: Result[i]:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
      $af: Result[i]:= #$017b;  // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $b1: Result[i]:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
      $b2: Result[i]:= #$02db;  // OGONEK
      $b3: Result[i]:= #$0142;  // LATIN SMALL LETTER L WITH STROKE
      $b5: Result[i]:= #$013e;  // LATIN SMALL LETTER L WITH CARON
      $b6: Result[i]:= #$015b;  // LATIN SMALL LETTER S WITH ACUTE
      $b7: Result[i]:= #$02c7;  // CARON
      $b9: Result[i]:= #$0161;  // LATIN SMALL LETTER S WITH CARON
      $ba: Result[i]:= #$015f;  // LATIN SMALL LETTER S WITH CEDILLA
      $bb: Result[i]:= #$0165;  // LATIN SMALL LETTER T WITH CARON
      $bc: Result[i]:= #$017a;  // LATIN SMALL LETTER Z WITH ACUTE
      $bd: Result[i]:= #$02dd;  // DOUBLE ACUTE ACCENT
      $be: Result[i]:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
      $bf: Result[i]:= #$017c;  // LATIN SMALL LETTER Z WITH DOT ABOVE
      $c0: Result[i]:= #$0154;  // LATIN CAPITAL LETTER R WITH ACUTE
      $c3: Result[i]:= #$0102;  // LATIN CAPITAL LETTER A WITH BREVE
      $c5: Result[i]:= #$0139;  // LATIN CAPITAL LETTER L WITH ACUTE
      $c6: Result[i]:= #$0106;  // LATIN CAPITAL LETTER C WITH ACUTE
      $c8: Result[i]:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
      $ca: Result[i]:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
      $cc: Result[i]:= #$011a;  // LATIN CAPITAL LETTER E WITH CARON
      $cf: Result[i]:= #$010e;  // LATIN CAPITAL LETTER D WITH CARON
      $d0: Result[i]:= #$0110;  // LATIN CAPITAL LETTER D WITH STROKE
      $d1: Result[i]:= #$0143;  // LATIN CAPITAL LETTER N WITH ACUTE
      $d2: Result[i]:= #$0147;  // LATIN CAPITAL LETTER N WITH CARON
      $d5: Result[i]:= #$0150;  // LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
      $d8: Result[i]:= #$0158;  // LATIN CAPITAL LETTER R WITH CARON
      $d9: Result[i]:= #$016e;  // LATIN CAPITAL LETTER U WITH RING ABOVE
      $db: Result[i]:= #$0170;  // LATIN CAPITAL LETTER U WITH WITH DOUBLE ACUTE
      $de: Result[i]:= #$0162;  // LATIN CAPITAL LETTER T WITH CEDILLA
      $e0: Result[i]:= #$0155;  // LATIN SMALL LETTER R WITH ACUTE
      $e3: Result[i]:= #$0103;  // LATIN SMALL LETTER A WITH BREVE
      $e5: Result[i]:= #$013a;  // LATIN SMALL LETTER L WITH ACUTE
      $e6: Result[i]:= #$0107;  // LATIN SMALL LETTER C WITH ACUTE
      $e8: Result[i]:= #$010d;  // LATIN SMALL LETTER C WITH CARON
      $ea: Result[i]:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
      $ec: Result[i]:= #$011b;  // LATIN SMALL LETTER E WITH CARON
      $ef: Result[i]:= #$010f;  // LATIN SMALL LETTER D WITH CARON
      $f0: Result[i]:= #$0111;  // LATIN SMALL LETTER D WITH STROKE
      $f1: Result[i]:= #$0144;  // LATIN SMALL LETTER N WITH ACUTE
      $f2: Result[i]:= #$0148;  // LATIN SMALL LETTER N WITH CARON
      $f5: Result[i]:= #$0151;  // LATIN SMALL LETTER O WITH DOUBLE ACUTE
      $f8: Result[i]:= #$0159;  // LATIN SMALL LETTER R WITH CARON
      $f9: Result[i]:= #$016f;  // LATIN SMALL LETTER U WITH RING ABOVE
      $fb: Result[i]:= #$0171;  // LATIN SMALL LETTER U WITH WITH DOUBLE ACUTE
      $fe: Result[i]:= #$0163;  // LATIN SMALL LETTER T WITH CEDILLA
      $ff: Result[i]:= #$02d9;  // DOT ABOVE
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function Iso8859_3ToWS(const AStr: String): WideString; // Latin-3
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $a1: Result[i]:= #$0126;  // LATIN CAPITAL LETTER H WITH STROKE
      $a2: Result[i]:= #$02d8;  // BREVE
      $a5: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[AStr]);
      $a6: Result[i]:= #$0124;  // LATIN CAPITAL LETTER H WITH CIRCUMFLEX
      $a9: Result[i]:= #$0130;  // LATIN CAPITAL LETTER I WITH DOT ABOVE
      $aa: Result[i]:= #$015e;  // LATIN CAPITAL LETTER S WITH CEDILLA
      $ab: Result[i]:= #$011e;  // LATIN CAPITAL LETTER G WITH BREVE
      $ac: Result[i]:= #$0134;  // LATIN CAPITAL LETTER J WITH CIRCUMFLEX
      $ae: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[AStr]);
      $af: Result[i]:= #$017b;  // LATIN CAPITAL LETTER Z WITH DOT
      $b1: Result[i]:= #$0127;  // LATIN SMALL LETTER H WITH STROKE
      $b6: Result[i]:= #$0125;  // LATIN SMALL LETTER H WITH CIRCUMFLEX
      $b9: Result[i]:= #$0131;  // LATIN SMALL LETTER DOTLESS I
      $ba: Result[i]:= #$015f;  // LATIN SMALL LETTER S WITH CEDILLA
      $bb: Result[i]:= #$011f;  // LATIN SMALL LETTER G WITH BREVE
      $bc: Result[i]:= #$0135;  // LATIN SMALL LETTER J WITH CIRCUMFLEX
      $be: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[AStr]);
      $bf: Result[i]:= #$017c;  // LATIN SMALL LETTER Z WITH DOT
      $c3: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[AStr]);
      $c5: Result[i]:= #$010a;  // LATIN CAPITAL LETTER C WITH DOT ABOVE
      $c6: Result[i]:= #$0108;  // LATIN CAPITAL LETTER C WITH CIRCUMFLEX
      $d0: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[AStr]);
      $d5: Result[i]:= #$0120;  // LATIN CAPITAL LETTER G WITH DOT ABOVE
      $d8: Result[i]:= #$011c;  // LATIN CAPITAL LETTER G WITH CIRCUMFLEX
      $dd: Result[i]:= #$016c;  // LATIN CAPITAL LETTER U WITH BREVE
      $de: Result[i]:= #$015c;  // LATIN CAPITAL LETTER S WITH CIRCUMFLEX
      $e3: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[AStr]);
      $e5: Result[i]:= #$010b;  // LATIN SMALL LETTER C WITH DOT ABOVE
      $e6: Result[i]:= #$0109;  // LATIN SMALL LETTER C WITH CIRCUMFLEX
      $f0: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-3 sequence "%s"',[AStr]);
      $f5: Result[i]:= #$0121;  // LATIN SMALL LETTER G WITH DOT ABOVE
      $f8: Result[i]:= #$011d;  // LATIN SMALL LETTER G WITH CIRCUMFLEX
      $fd: Result[i]:= #$016d;  // LATIN SMALL LETTER U WITH BREVE
      $fe: Result[i]:= #$015d;  // LATIN SMALL LETTER S WITH CIRCUMFLEX
      $ff: Result[i]:= #$02d9;  // DOT ABOVE
    else
      Word(Result[i]):= Word(AStr[i]);
    end;
  end;
end;

function Iso8859_4ToWS(const AStr: String): WideString; // Latin-4
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    Word(Result[i]):= Word(AStr[i]);
    case Byte(AStr[i]) of
      $a1: Result[i]:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
      $a2: Result[i]:= #$0138;  // LATIN SMALL LETTER KRA
      $a3: Result[i]:= #$0156;  // LATIN CAPITAL LETTER R WITH CEDILLA
      $a5: Result[i]:= #$0128;  // LATIN CAPITAL LETTER I WITH TILDE
      $a6: Result[i]:= #$013b;  // LATIN CAPITAL LETTER L WITH CEDILLA
      $a9: Result[i]:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
      $aa: Result[i]:= #$0112;  // LATIN CAPITAL LETTER E WITH MACRON
      $ab: Result[i]:= #$0122;  // LATIN CAPITAL LETTER G WITH CEDILLA
      $ac: Result[i]:= #$0166;  // LATIN CAPITAL LETTER T WITH STROKE
      $ae: Result[i]:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
      $b1: Result[i]:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
      $b2: Result[i]:= #$02db;  // OGONEK
      $b3: Result[i]:= #$0157;  // LATIN SMALL LETTER R WITH CEDILLA
      $b5: Result[i]:= #$0129;  // LATIN SMALL LETTER I WITH TILDE
      $b6: Result[i]:= #$013c;  // LATIN SMALL LETTER L WITH CEDILLA
      $b7: Result[i]:= #$02c7;  // CARON
      $b9: Result[i]:= #$0161;  // LATIN SMALL LETTER S WITH CARON
      $ba: Result[i]:= #$0113;  // LATIN SMALL LETTER E WITH MACRON
      $bb: Result[i]:= #$0123;  // LATIN SMALL LETTER G WITH CEDILLA
      $bc: Result[i]:= #$0167;  // LATIN SMALL LETTER T WITH STROKE
      $bd: Result[i]:= #$014a;  // LATIN CAPITAL LETTER ENG
      $be: Result[i]:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
      $bf: Result[i]:= #$014b;  // LATIN SMALL LETTER ENG
      $c0: Result[i]:= #$0100;  // LATIN CAPITAL LETTER A WITH MACRON
      $c7: Result[i]:= #$012e;  // LATIN CAPITAL LETTER I WITH OGONEK
      $c8: Result[i]:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
      $ca: Result[i]:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
      $cc: Result[i]:= #$0116;  // LATIN CAPITAL LETTER E WITH DOT ABOVE
      $cf: Result[i]:= #$012a;  // LATIN CAPITAL LETTER I WITH MACRON
      $d0: Result[i]:= #$0110;  // LATIN CAPITAL LETTER D WITH STROKE
      $d1: Result[i]:= #$0145;  // LATIN CAPITAL LETTER N WITH CEDILLA
      $d2: Result[i]:= #$014c;  // LATIN CAPITAL LETTER O WITH MACRON
      $d3: Result[i]:= #$0136;  // LATIN CAPITAL LETTER K WITH CEDILLA
      $d9: Result[i]:= #$0172;  // LATIN CAPITAL LETTER U WITH OGONEK
      $dd: Result[i]:= #$0168;  // LATIN CAPITAL LETTER U WITH TILDE
      $de: Result[i]:= #$016a;  // LATIN CAPITAL LETTER U WITH MACRON
      $e0: Result[i]:= #$0101;  // LATIN SMALL LETTER A WITH MACRON
      $e7: Result[i]:= #$012f;  // LATIN SMALL LETTER I WITH OGONEK
      $e8: Result[i]:= #$010d;  // LATIN SMALL LETTER C WITH CARON
      $ea: Result[i]:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
      $ec: Result[i]:= #$0117;  // LATIN SMALL LETTER E WITH DOT ABOVE
      $ef: Result[i]:= #$012b;  // LATIN SMALL LETTER I WITH MACRON
      $f0: Result[i]:= #$0111;  // LATIN SMALL LETTER D WITH STROKE
      $f1: Result[i]:= #$0146;  // LATIN SMALL LETTER N WITH CEDILLA
      $f2: Result[i]:= #$014d;  // LATIN SMALL LETTER O WITH MACRON
      $f3: Result[i]:= #$0137;  // LATIN SMALL LETTER K WITH CEDILLA
      $f9: Result[i]:= #$0173;  // LATIN SMALL LETTER U WITH OGONEK
      $fd: Result[i]:= #$0169;  // LATIN SMALL LETTER U WITH TILDE
      $fe: Result[i]:= #$016b;  // LATIN SMALL LETTER U WITH MACRON
      $ff: Result[i]:= #$02d9;  // DOT ABOVE
    else
      Word(Result[i]):= Word(AStr[i]);
    end;
  end;
end;

function Iso8859_5ToWS(const AStr: String): WideString; // Cyrillic
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $00..$a0,$ad:
        Result[i]:= WideChar(AStr[i]);
      $f0: Result[i]:= #$2116;  // NUMERO SIGN
      $fd: Result[i]:= #$00a7;  // SECTION SIGN
    else
      Result[i]:= WideChar(Byte(AStr[i]) + $0360);
    end;
  end;
end;

function Iso8859_6ToWS(const AStr: String): WideString; // Arabic
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $00..$a0,$a4,$ad:
        Result[i]:= WideChar(AStr[i]);
      $ac,$bb,$bf,$c1..$da,$e0..$f2:
        Result[i]:= WideChar(Byte(AStr[i]) + $0580);
    else
      Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-6 sequence "%s"',[AStr]);
    end;
  end;
end;

function Iso8859_7ToWS(const AStr: String): WideString; // Greek
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $00..$a0,$a6..$a9,$ab..$ad,$b0..$b3,$b7,$bb,$bd:
        Result[i]:= WideChar(AStr[i]);
      $a1: Result[i]:= #$2018;  // LEFT SINGLE QUOTATION MARK
      $a2: Result[i]:= #$2019;  // RIGHT SINGLE QUOTATION MARK
      $af: Result[i]:= #$2015;  // HORIZONTAL BAR
      $d2,$ff: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-7 sequence "%s"',[AStr]);
    else
      Result[i]:= WideChar(Byte(AStr[i]) + $02d0);
    end;
  end;
end;

function Iso8859_8ToWS(const AStr: String): WideString; // Hebrew
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $00..$a0,$a2..$a9,$ab..$ae,$b0..$b9,$bb..$be:
        Result[i]:= WideChar(AStr[i]);
      $aa: Result[i]:= #$00d7;  // MULTIPLICATION SIGN
      $af: Result[i]:= #$203e;  // OVERLINE
      $ba: Result[i]:= #$00f7;  // DIVISION SIGN
      $df: Result[i]:= #$2017;  // DOUBLE LOW LINE
      $e0..$fa:
        Result[i]:= WideChar(Byte(AStr[i]) + $04e0);
    else
      Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-8 sequence "%s"',[AStr]);
    end;
  end;
end;

function Iso8859_9ToWS(const AStr: String): WideString; //
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $d0: Result[i]:= #$011e;  // LATIN CAPITAL LETTER G WITH BREVE
      $dd: Result[i]:= #$0130;  // LATIN CAPITAL LETTER I WITH DOT ABOVE
      $de: Result[i]:= #$015e;  // LATIN CAPITAL LETTER S WITH CEDILLA
      $f0: Result[i]:= #$011f;  // LATIN SMALL LETTER G WITH BREVE
      $fd: Result[i]:= #$0131;  // LATIN SMALL LETTER I WITH DOT ABOVE
      $fe: Result[i]:= #$015f;  // LATIN SMALL LETTER S WITH CEDILLA
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function Iso8859_10ToWS(const AStr: String): WideString; // Latin-6
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $a1: Result[i]:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
      $a2: Result[i]:= #$0112;  // LATIN CAPITAL LETTER E WITH MACRON
      $a3: Result[i]:= #$0122;  // LATIN CAPITAL LETTER G WITH CEDILLA
      $a4: Result[i]:= #$012a;  // LATIN CAPITAL LETTER I WITH MACRON
      $a5: Result[i]:= #$0128;  // LATIN CAPITAL LETTER I WITH TILDE
      $a6: Result[i]:= #$0136;  // LATIN CAPITAL LETTER K WITH CEDILLA
      $a8: Result[i]:= #$013b;  // LATIN CAPITAL LETTER L WITH CEDILLA
      $a9: Result[i]:= #$0110;  // LATIN CAPITAL LETTER D WITH STROKE
      $aa: Result[i]:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
      $ab: Result[i]:= #$0166;  // LATIN CAPITAL LETTER T WITH STROKE
      $ac: Result[i]:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
      $ae: Result[i]:= #$016a;  // LATIN CAPITAL LETTER U WITH MACRON
      $af: Result[i]:= #$014a;  // LATIN CAPITAL LETTER ENG
      $b1: Result[i]:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
      $b2: Result[i]:= #$0113;  // LATIN SMALL LETTER E WITH MACRON
      $b3: Result[i]:= #$0123;  // LATIN SMALL LETTER G WITH CEDILLA
      $b4: Result[i]:= #$012b;  // LATIN SMALL LETTER I WITH MACRON
      $b5: Result[i]:= #$0129;  // LATIN SMALL LETTER I WITH TILDE
      $b6: Result[i]:= #$0137;  // LATIN SMALL LETTER K WITH CEDILLA
      $b8: Result[i]:= #$013c;  // LATIN SMALL LETTER L WITH CEDILLA
      $b9: Result[i]:= #$0111;  // LATIN SMALL LETTER D WITH STROKE
      $ba: Result[i]:= #$0161;  // LATIN SMALL LETTER S WITH CARON
      $bb: Result[i]:= #$0167;  // LATIN SMALL LETTER T WITH STROKE
      $bc: Result[i]:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
      $bd: Result[i]:= #$2015;  // HORIZONTAL BAR
      $be: Result[i]:= #$016b;  // LATIN SMALL LETTER U WITH MACRON
      $bf: Result[i]:= #$014b;  // LATIN SMALL LETTER ENG
      $c0: Result[i]:= #$0100;  // LATIN CAPITAL LETTER A WITH MACRON
      $c7: Result[i]:= #$012e;  // LATIN CAPITAL LETTER I WITH OGONEK
      $c8: Result[i]:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
      $ca: Result[i]:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
      $cc: Result[i]:= #$0116;  // LATIN CAPITAL LETTER E WITH DOT ABOVE
      $d1: Result[i]:= #$0145;  // LATIN CAPITAL LETTER N WITH CEDILLA
      $d2: Result[i]:= #$014c;  // LATIN CAPITAL LETTER O WITH MACRON
      $d7: Result[i]:= #$0168;  // LATIN CAPITAL LETTER U WITH TILDE
      $d9: Result[i]:= #$0172;  // LATIN CAPITAL LETTER U WITH OGONEK
      $e0: Result[i]:= #$0101;  // LATIN SMALL LETTER A WITH MACRON
      $e7: Result[i]:= #$012f;  // LATIN SMALL LETTER I WITH OGONEK
      $e8: Result[i]:= #$010d;  // LATIN SMALL LETTER C WITH CARON
      $ea: Result[i]:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
      $ec: Result[i]:= #$0117;  // LATIN SMALL LETTER E WITH DOT ABOVE
      $f1: Result[i]:= #$0146;  // LATIN SMALL LETTER N WITH CEDILLA
      $f2: Result[i]:= #$014d;  // LATIN SMALL LETTER O WITH MACRON
      $f7: Result[i]:= #$0169;  // LATIN SMALL LETTER U WITH TILDE
      $f9: Result[i]:= #$0173;  // LATIN SMALL LETTER U WITH OGONEK
      $ff: Result[i]:= #$0138;  // LATIN SMALL LETTER KRA
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function Iso8859_13ToWS(const AStr: String): WideString; // Latin-7
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $a1: Result[i]:= #$201d;  // RIGHT DOUBLE QUOTATION MARK
      $a5: Result[i]:= #$201e;  // DOUBLE LOW-9 QUOTATION MARK
      $a8: Result[i]:= #$00d8;  // LATIN CAPITAL LETTER O WITH STROKE
      $aa: Result[i]:= #$0156;  // LATIN CAPITAL LETTER R WITH CEDILLA
      $af: Result[i]:= #$00c6;  // LATIN CAPITAL LETTER AE
      $b4: Result[i]:= #$201c;  // LEFT DOUBLE QUOTATION MARK
      $b8: Result[i]:= #$00f8;  // LATIN SMALL LETTER O WITH STROKE
      $ba: Result[i]:= #$0157;  // LATIN SMALL LETTER R WITH CEDILLA
      $bf: Result[i]:= #$00e6;  // LATIN SMALL LETTER AE
      $c0: Result[i]:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
      $c1: Result[i]:= #$012e;  // LATIN CAPITAL LETTER I WITH OGONEK
      $c2: Result[i]:= #$0100;  // LATIN CAPITAL LETTER A WITH MACRON
      $c3: Result[i]:= #$0106;  // LATIN CAPITAL LETTER C WITH ACUTE
      $c6: Result[i]:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
      $c7: Result[i]:= #$0112;  // LATIN CAPITAL LETTER E WITH MACRON
      $c8: Result[i]:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
      $ca: Result[i]:= #$0179;  // LATIN CAPITAL LETTER Z WITH ACUTE
      $cb: Result[i]:= #$0116;  // LATIN CAPITAL LETTER E WITH DOT ABOVE
      $cc: Result[i]:= #$0122;  // LATIN CAPITAL LETTER G WITH CEDILLA
      $cd: Result[i]:= #$0136;  // LATIN CAPITAL LETTER K WITH CEDILLA
      $ce: Result[i]:= #$012a;  // LATIN CAPITAL LETTER I WITH MACRON
      $cf: Result[i]:= #$013b;  // LATIN CAPITAL LETTER L WITH CEDILLA
      $d0: Result[i]:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
      $d1: Result[i]:= #$0143;  // LATIN CAPITAL LETTER N WITH ACUTE
      $d2: Result[i]:= #$0145;  // LATIN CAPITAL LETTER N WITH CEDILLA
      $d4: Result[i]:= #$014c;  // LATIN CAPITAL LETTER O WITH MACRON
      $d8: Result[i]:= #$0172;  // LATIN CAPITAL LETTER U WITH OGONEK
      $d9: Result[i]:= #$0141;  // LATIN CAPITAL LETTER L WITH STROKE
      $da: Result[i]:= #$015a;  // LATIN CAPITAL LETTER S WITH ACUTE
      $db: Result[i]:= #$016a;  // LATIN CAPITAL LETTER U WITH MACRON
      $dd: Result[i]:= #$017b;  // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $de: Result[i]:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
      $e0: Result[i]:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
      $e1: Result[i]:= #$012f;  // LATIN SMALL LETTER I WITH OGONEK
      $e2: Result[i]:= #$0101;  // LATIN SMALL LETTER A WITH MACRON
      $e3: Result[i]:= #$0107;  // LATIN SMALL LETTER C WITH ACUTE
      $e6: Result[i]:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
      $e7: Result[i]:= #$0113;  // LATIN SMALL LETTER E WITH MACRON
      $e8: Result[i]:= #$010d;  // LATIN SMALL LETTER C WITH CARON
      $ea: Result[i]:= #$017a;  // LATIN SMALL LETTER Z WITH ACUTE
      $eb: Result[i]:= #$0117;  // LATIN SMALL LETTER E WITH DOT ABOVE
      $ec: Result[i]:= #$0123;  // LATIN SMALL LETTER G WITH CEDILLA
      $ed: Result[i]:= #$0137;  // LATIN SMALL LETTER K WITH CEDILLA
      $ee: Result[i]:= #$012b;  // LATIN SMALL LETTER I WITH MACRON
      $ef: Result[i]:= #$013c;  // LATIN SMALL LETTER L WITH CEDILLA
      $f0: Result[i]:= #$0161;  // LATIN SMALL LETTER S WITH CARON
      $f1: Result[i]:= #$0144;  // LATIN SMALL LETTER N WITH ACUTE
      $f2: Result[i]:= #$0146;  // LATIN SMALL LETTER N WITH CEDILLA
      $f4: Result[i]:= #$014d;  // LATIN SMALL LETTER O WITH MACRON
      $f8: Result[i]:= #$0173;  // LATIN SMALL LETTER U WITH OGONEK
      $f9: Result[i]:= #$0142;  // LATIN SMALL LETTER L WITH STROKE
      $fa: Result[i]:= #$015b;  // LATIN SMALL LETTER S WITH ACUTE
      $fb: Result[i]:= #$016b;  // LATIN SMALL LETTER U WITH MACRON
      $fd: Result[i]:= #$017c;  // LATIN SMALL LETTER Z WITH DOT ABOVE
      $fe: Result[i]:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
      $ff: Result[i]:= #$2019;  // RIGHT SINGLE QUOTATION MARK
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function Iso8859_14ToWS(const AStr: String): WideString; // Latin-8
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $a1: Result[i]:= #$1e02;  // LATIN CAPITAL LETTER B WITH DOT ABOVE
      $a2: Result[i]:= #$1e03;  // LATIN SMALL LETTER B WITH DOT ABOVE
      $a4: Result[i]:= #$010a;  // LATIN CAPITAL LETTER C WITH DOT ABOVE
      $a5: Result[i]:= #$010b;  // LATIN SMALL LETTER C WITH DOT ABOVE
      $a6: Result[i]:= #$1e0a;  // LATIN CAPITAL LETTER D WITH DOT ABOVE
      $a8: Result[i]:= #$1e80;  // LATIN CAPITAL LETTER W WITH GRAVE
      $aa: Result[i]:= #$1e82;  // LATIN CAPITAL LETTER W WITH ACUTE
      $ab: Result[i]:= #$1e0b;  // LATIN SMALL LETTER D WITH DOT ABOVE
      $ac: Result[i]:= #$1ef2;  // LATIN CAPITAL LETTER Y WITH GRAVE
      $af: Result[i]:= #$0178;  // LATIN CAPITAL LETTER Y WITH DIAERESIS
      $b0: Result[i]:= #$1e1e;  // LATIN CAPITAL LETTER F WITH DOT ABOVE
      $b1: Result[i]:= #$1e1f;  // LATIN SMALL LETTER F WITH DOT ABOVE
      $b2: Result[i]:= #$0120;  // LATIN CAPITAL LETTER G WITH DOT ABOVE
      $b3: Result[i]:= #$0121;  // LATIN SMALL LETTER G WITH DOT ABOVE
      $b4: Result[i]:= #$1e40;  // LATIN CAPITAL LETTER M WITH DOT ABOVE
      $b5: Result[i]:= #$1e41;  // LATIN SMALL LETTER M WITH DOT ABOVE
      $b7: Result[i]:= #$1e56;  // LATIN CAPITAL LETTER P WITH DOT ABOVE
      $b8: Result[i]:= #$1e81;  // LATIN SMALL LETTER W WITH GRAVE
      $b9: Result[i]:= #$1e57;  // LATIN SMALL LETTER P WITH DOT ABOVE
      $ba: Result[i]:= #$1e83;  // LATIN SMALL LETTER W WITH ACUTE
      $bb: Result[i]:= #$1e60;  // LATIN CAPITAL LETTER S WITH DOT ABOVE
      $bc: Result[i]:= #$1ef3;  // LATIN SMALL LETTER Y WITH GRAVE
      $bd: Result[i]:= #$1e84;  // LATIN CAPITAL LETTER W WITH DIAERESIS
      $be: Result[i]:= #$1e85;  // LATIN SMALL LETTER W WITH DIAERESIS
      $bf: Result[i]:= #$1e61;  // LATIN SMALL LETTER S WITH DOT ABOVE
      $d0: Result[i]:= #$0174;  // LATIN CAPITAL LETTER W WITH CIRCUMFLEX
      $d7: Result[i]:= #$1e6a;  // LATIN CAPITAL LETTER T WITH DOT ABOVE
      $de: Result[i]:= #$0176;  // LATIN CAPITAL LETTER Y WITH CIRCUMFLEX
      $f0: Result[i]:= #$0175;  // LATIN SMALL LETTER W WITH CIRCUMFLEX
      $f7: Result[i]:= #$1e6b;  // LATIN SMALL LETTER T WITH DOT ABOVE
      $fe: Result[i]:= #$0177;  // LATIN SMALL LETTER Y WITH CIRCUMFLEX
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function Iso8859_15ToWS(const AStr: String): WideString; // Latin-9
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $a4: Result[i]:= #$20ac;  // EURO SIGN
      $a6: Result[i]:= #$00a6;  // LATIN CAPITAL LETTER S WITH CARON
      $a8: Result[i]:= #$0161;  // LATIN SMALL LETTER S WITH CARON
      $b4: Result[i]:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
      $b8: Result[i]:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
      $bc: Result[i]:= #$0152;  // LATIN CAPITAL LIGATURE OE
      $bd: Result[i]:= #$0153;  // LATIN SMALL LIGATURE OE
      $be: Result[i]:= #$0178;  // LATIN CAPITAL LETTER Y WITH DIAERESIS
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function KOI8_RToWS(const AStr: String): WideString; // KOI8-R
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $80: Result[i]:= #$2500;  // BOX DRAWINGS LIGHT HORIZONTAL
      $81: Result[i]:= #$2502;  // BOX DRAWINGS LIGHT VERTICAL
      $82: Result[i]:= #$250c;  // BOX DRAWINGS LIGHT DOWN AND RIGHT
      $83: Result[i]:= #$2510;  // BOX DRAWINGS LIGHT DOWN AND LEFT
      $84: Result[i]:= #$2514;  // BOX DRAWINGS LIGHT UP AND RIGHT
      $85: Result[i]:= #$2518;  // BOX DRAWINGS LIGHT UP AND LEFT
      $86: Result[i]:= #$251c;  // BOX DRAWINGS LIGHT VERTICAL AND RIGHT
      $87: Result[i]:= #$2524;  // BOX DRAWINGS LIGHT VERTICAL AND LEFT
      $88: Result[i]:= #$252c;  // BOX DRAWINGS LIGHT DOWN AND HORIZONTAL
      $89: Result[i]:= #$2534;  // BOX DRAWINGS LIGHT UP AND HORIZONTAL
      $8a: Result[i]:= #$253c;  // BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL
      $8b: Result[i]:= #$2580;  // UPPER HALF BLOCK
      $8c: Result[i]:= #$2584;  // LOWER HALF BLOCK
      $8d: Result[i]:= #$2588;  // FULL BLOCK
      $8e: Result[i]:= #$258c;  // LEFT HALF BLOCK
      $8f: Result[i]:= #$2590;  // RIGHT HALF BLOCK
      $90: Result[i]:= #$2591;  // LIGHT SHADE
      $91: Result[i]:= #$2592;  // MEDIUM SHADE
      $92: Result[i]:= #$2593;  // DARK SHADE
      $93: Result[i]:= #$2320;  // TOP HALF INTEGRAL
      $94: Result[i]:= #$25a0;  // BLACK SQUARE
      $95: Result[i]:= #$2219;  // BULLET OPERATOR
      $96: Result[i]:= #$221a;  // SQUARE ROOT
      $97: Result[i]:= #$2248;  // ALMOST EQUAL TO
      $98: Result[i]:= #$2264;  // LESS-THAN OR EQUAL TO
      $99: Result[i]:= #$2265;  // GREATER-THAN OR EQUAL TO
      $9a: Result[i]:= #$00a0;  // NO-BREAK SPACE
      $9b: Result[i]:= #$2321;  // BOTTOM HALF INTEGRAL
      $9c: Result[i]:= #$00b0;  // DEGREE SIGN
      $9d: Result[i]:= #$00b2;  // SUPERSCRIPT TWO
      $9e: Result[i]:= #$00b7;  // MIDDLE DOT
      $9f: Result[i]:= #$00f7;  // DIVISION SIGN
      $a0: Result[i]:= #$2550;  // BOX DRAWINGS DOUBLE HORIZONTAL
      $a1: Result[i]:= #$2551;  // BOX DRAWINGS DOUBLE VERTICAL
      $a2: Result[i]:= #$2552;  // BOX DRAWINGS DOWN SINGLE AND RIGHT DOUBLE
      $a3: Result[i]:= #$0451;  // CYRILLIC SMALL LETTER IO
      $a4: Result[i]:= #$2553;  // BOX DRAWINGS DOWN DOUBLE AND RIGHT SINGLE
      $a5: Result[i]:= #$2554;  // BOX DRAWINGS DOUBLE DOWN AND RIGHT
      $a6: Result[i]:= #$2555;  // BOX DRAWINGS DOWN SINGLE AND LEFT DOUBLE
      $a7: Result[i]:= #$2556;  // BOX DRAWINGS DOWN DOUBLE AND LEFT SINGLE
      $a8: Result[i]:= #$2557;  // BOX DRAWINGS DOUBLE DOWN AND LEFT
      $a9: Result[i]:= #$2558;  // BOX DRAWINGS UP SINGLE AND RIGHT DOUBLE
      $aa: Result[i]:= #$2559;  // BOX DRAWINGS UP DOUBLE AND RIGHT SINGLE
      $ab: Result[i]:= #$255a;  // BOX DRAWINGS DOUBLE UP AND RIGHT
      $ac: Result[i]:= #$255b;  // BOX DRAWINGS UP SINGLE AND LEFT DOUBLE
      $ad: Result[i]:= #$255c;  // BOX DRAWINGS UP DOUBLE AND LEFT SINGLE
      $ae: Result[i]:= #$255d;  // BOX DRAWINGS DOUBLE UP AND LEFT
      $af: Result[i]:= #$255e;  // BOX DRAWINGS VERTICAL SINGLE AND RIGHT DOUBLE
      $b0: Result[i]:= #$255f;  // BOX DRAWINGS VERTICAL DOUBLE AND RIGHT SINGLE
      $b1: Result[i]:= #$2560;  // BOX DRAWINGS DOUBLE VERTICAL AND RIGHT
      $b2: Result[i]:= #$2561;  // BOX DRAWINGS VERTICAL SINGLE AND LEFT DOUBLE
      $b3: Result[i]:= #$0401;  // CYRILLIC CAPITAL LETTER IO
      $b4: Result[i]:= #$2562;  // BOX DRAWINGS VERTICAL DOUBLE AND LEFT SINGLE
      $b5: Result[i]:= #$2563;  // BOX DRAWINGS DOUBLE VERTICAL AND LEFT
      $b6: Result[i]:= #$2564;  // BOX DRAWINGS DOWN SINGLE AND HORIZONTAL DOUBLE
      $b7: Result[i]:= #$2565;  // BOX DRAWINGS DOWN DOUBLE AND HORIZONTAL SINGLE
      $b8: Result[i]:= #$2566;  // BOX DRAWINGS DOUBLE DOWN AND HORIZONTAL
      $b9: Result[i]:= #$2567;  // BOX DRAWINGS UP SINGLE AND HORIZONTAL DOUBLE
      $ba: Result[i]:= #$2568;  // BOX DRAWINGS UP DOUBLE AND HORIZONTAL SINGLE
      $bb: Result[i]:= #$2569;  // BOX DRAWINGS DOUBLE UP AND HORIZONTAL
      $bc: Result[i]:= #$256a;  // BOX DRAWINGS VERTICAL SINGLE AND HORIZONTAL DOUBLE
      $bd: Result[i]:= #$256b;  // BOX DRAWINGS VERTICAL DOUBLE AND HORIZONTAL SINGLE
      $be: Result[i]:= #$256c;  // BOX DRAWINGS DOUBLE VERTICAL AND HORIZONTAL
      $bf: Result[i]:= #$00a9;  // COPYRIGHT SIGN
      $c0: Result[i]:= #$044e;  // CYRILLIC SMALL LETTER YU
      $c1: Result[i]:= #$0430;  // CYRILLIC SMALL LETTER A
      $c2: Result[i]:= #$0431;  // CYRILLIC SMALL LETTER BE
      $c3: Result[i]:= #$0446;  // CYRILLIC SMALL LETTER TSE
      $c4: Result[i]:= #$0434;  // CYRILLIC SMALL LETTER DE
      $c5: Result[i]:= #$0435;  // CYRILLIC SMALL LETTER IE
      $c6: Result[i]:= #$0444;  // CYRILLIC SMALL LETTER EF
      $c7: Result[i]:= #$0433;  // CYRILLIC SMALL LETTER GHE
      $c8: Result[i]:= #$0445;  // CYRILLIC SMALL LETTER HA
      $c9: Result[i]:= #$0438;  // CYRILLIC SMALL LETTER I
      $ca: Result[i]:= #$0439;  // CYRILLIC SMALL LETTER SHORT I
      $cb: Result[i]:= #$043a;  // CYRILLIC SMALL LETTER KA
      $cc: Result[i]:= #$043b;  // CYRILLIC SMALL LETTER EL
      $cd: Result[i]:= #$043c;  // CYRILLIC SMALL LETTER EM
      $ce: Result[i]:= #$043d;  // CYRILLIC SMALL LETTER EN
      $cf: Result[i]:= #$043e;  // CYRILLIC SMALL LETTER O
      $d0: Result[i]:= #$043f;  // CYRILLIC SMALL LETTER PE
      $d1: Result[i]:= #$044f;  // CYRILLIC SMALL LETTER YA
      $d2: Result[i]:= #$0440;  // CYRILLIC SMALL LETTER ER
      $d3: Result[i]:= #$0441;  // CYRILLIC SMALL LETTER ES
      $d4: Result[i]:= #$0442;  // CYRILLIC SMALL LETTER TE
      $d5: Result[i]:= #$0443;  // CYRILLIC SMALL LETTER U
      $d6: Result[i]:= #$0436;  // CYRILLIC SMALL LETTER ZHE
      $d7: Result[i]:= #$0432;  // CYRILLIC SMALL LETTER VE
      $d8: Result[i]:= #$044c;  // CYRILLIC SMALL LETTER SOFT SIGN
      $d9: Result[i]:= #$044b;  // CYRILLIC SMALL LETTER YERU
      $da: Result[i]:= #$0437;  // CYRILLIC SMALL LETTER ZE
      $db: Result[i]:= #$0448;  // CYRILLIC SMALL LETTER SHA
      $dc: Result[i]:= #$044d;  // CYRILLIC SMALL LETTER E
      $dd: Result[i]:= #$0449;  // CYRILLIC SMALL LETTER SHCHA
      $de: Result[i]:= #$0447;  // CYRILLIC SMALL LETTER CHE
      $df: Result[i]:= #$044a;  // CYRILLIC SMALL LETTER HARD SIGN
      $e0: Result[i]:= #$042e;  // CYRILLIC CAPITAL LETTER YU
      $e1: Result[i]:= #$0410;  // CYRILLIC CAPITAL LETTER A
      $e2: Result[i]:= #$0411;  // CYRILLIC CAPITAL LETTER BE
      $e3: Result[i]:= #$0426;  // CYRILLIC CAPITAL LETTER TSE
      $e4: Result[i]:= #$0414;  // CYRILLIC CAPITAL LETTER DE
      $e5: Result[i]:= #$0415;  // CYRILLIC CAPITAL LETTER IE
      $e6: Result[i]:= #$0424;  // CYRILLIC CAPITAL LETTER EF
      $e7: Result[i]:= #$0413;  // CYRILLIC CAPITAL LETTER GHE
      $e8: Result[i]:= #$0425;  // CYRILLIC CAPITAL LETTER HA
      $e9: Result[i]:= #$0418;  // CYRILLIC CAPITAL LETTER I
      $ea: Result[i]:= #$0419;  // CYRILLIC CAPITAL LETTER SHORT I
      $eb: Result[i]:= #$041a;  // CYRILLIC CAPITAL LETTER KA
      $ec: Result[i]:= #$041b;  // CYRILLIC CAPITAL LETTER EL
      $ed: Result[i]:= #$041c;  // CYRILLIC CAPITAL LETTER EM
      $ee: Result[i]:= #$041d;  // CYRILLIC CAPITAL LETTER EN
      $ef: Result[i]:= #$041e;  // CYRILLIC CAPITAL LETTER O
      $f0: Result[i]:= #$041f;  // CYRILLIC CAPITAL LETTER PE
      $f1: Result[i]:= #$042f;  // CYRILLIC CAPITAL LETTER YA
      $f2: Result[i]:= #$0420;  // CYRILLIC CAPITAL LETTER ER
      $f3: Result[i]:= #$0421;  // CYRILLIC CAPITAL LETTER ES
      $f4: Result[i]:= #$0422;  // CYRILLIC CAPITAL LETTER TE
      $f5: Result[i]:= #$0423;  // CYRILLIC CAPITAL LETTER U
      $f6: Result[i]:= #$0416;  // CYRILLIC CAPITAL LETTER ZHE
      $f7: Result[i]:= #$0412;  // CYRILLIC CAPITAL LETTER VE
      $f8: Result[i]:= #$042c;  // CYRILLIC CAPITAL LETTER SOFT SIGN
      $f9: Result[i]:= #$042b;  // CYRILLIC CAPITAL LETTER YERU
      $fa: Result[i]:= #$0417;  // CYRILLIC CAPITAL LETTER ZE
      $fb: Result[i]:= #$0428;  // CYRILLIC CAPITAL LETTER SHA
      $fc: Result[i]:= #$042d;  // CYRILLIC CAPITAL LETTER E
      $fd: Result[i]:= #$0429;  // CYRILLIC CAPITAL LETTER SHCHA
      $fe: Result[i]:= #$0427;  // CYRILLIC CAPITAL LETTER CHE
      $ff: Result[i]:= #$042a;  // CYRILLIC CAPITAL LETTER HARD SIGN
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function cp10000_MacRomanToWS(const AStr: String): WideString; // cp10000_MacRoman
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $80: Result[i]:= #$00c4;  // LATIN CAPITAL LETTER A WITH DIAERESIS
      $81: Result[i]:= #$00c5;  // LATIN CAPITAL LETTER A WITH RING ABOVE
      $82: Result[i]:= #$00c7;  // LATIN CAPITAL LETTER C WITH CEDILLA
      $83: Result[i]:= #$00c9;  // LATIN CAPITAL LETTER E WITH ACUTE
      $84: Result[i]:= #$00d1;  // LATIN CAPITAL LETTER N WITH TILDE
      $85: Result[i]:= #$00d6;  // LATIN CAPITAL LETTER O WITH DIAERESIS
      $86: Result[i]:= #$00dc;  // LATIN CAPITAL LETTER U WITH DIAERESIS
      $87: Result[i]:= #$00e1;  // LATIN SMALL LETTER A WITH ACUTE
      $88: Result[i]:= #$00e0;  // LATIN SMALL LETTER A WITH GRAVE
      $89: Result[i]:= #$00e2;  // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $8a: Result[i]:= #$00e4;  // LATIN SMALL LETTER A WITH DIAERESIS
      $8b: Result[i]:= #$00e3;  // LATIN SMALL LETTER A WITH TILDE
      $8c: Result[i]:= #$00e5;  // LATIN SMALL LETTER A WITH RING ABOVE
      $8d: Result[i]:= #$00e7;  // LATIN SMALL LETTER C WITH CEDILLA
      $8e: Result[i]:= #$00e9;  // LATIN SMALL LETTER E WITH ACUTE
      $8f: Result[i]:= #$00e8;  // LATIN SMALL LETTER E WITH GRAVE
      $90: Result[i]:= #$00ea;  // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $91: Result[i]:= #$00eb;  // LATIN SMALL LETTER E WITH DIAERESIS
      $92: Result[i]:= #$00ed;  // LATIN SMALL LETTER I WITH ACUTE
      $93: Result[i]:= #$00ec;  // LATIN SMALL LETTER I WITH GRAVE
      $94: Result[i]:= #$00ee;  // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $95: Result[i]:= #$00ef;  // LATIN SMALL LETTER I WITH DIAERESIS
      $96: Result[i]:= #$00f1;  // LATIN SMALL LETTER N WITH TILDE
      $97: Result[i]:= #$00f3;  // LATIN SMALL LETTER O WITH ACUTE
      $98: Result[i]:= #$00f2;  // LATIN SMALL LETTER O WITH GRAVE
      $99: Result[i]:= #$00f4;  // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $9a: Result[i]:= #$00f6;  // LATIN SMALL LETTER O WITH DIAERESIS
      $9b: Result[i]:= #$00f5;  // LATIN SMALL LETTER O WITH TILDE
      $9c: Result[i]:= #$00fa;  // LATIN SMALL LETTER U WITH ACUTE
      $9d: Result[i]:= #$00f9;  // LATIN SMALL LETTER U WITH GRAVE
      $9e: Result[i]:= #$00fb;  // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $9f: Result[i]:= #$00fc;  // LATIN SMALL LETTER U WITH DIAERESIS
      $a0: Result[i]:= #$2020;  // DAGGER
      $a1: Result[i]:= #$00b0;  // DEGREE SIGN
      $a4: Result[i]:= #$00a7;  // SECTION SIGN
      $a5: Result[i]:= #$2022;  // BULLET
      $a6: Result[i]:= #$00b6;  // PILCROW SIGN
      $a7: Result[i]:= #$00df;  // LATIN SMALL LETTER SHARP S
      $a8: Result[i]:= #$00ae;  // REGISTERED SIGN
      $aa: Result[i]:= #$2122;  // TRADE MARK SIGN
      $ab: Result[i]:= #$00b4;  // ACUTE ACCENT
      $ac: Result[i]:= #$00a8;  // DIAERESIS
      $ad: Result[i]:= #$2260;  // NOT EQUAL TO
      $ae: Result[i]:= #$00c6;  // LATIN CAPITAL LIGATURE AE
      $af: Result[i]:= #$00d8;  // LATIN CAPITAL LETTER O WITH STROKE
      $b0: Result[i]:= #$221e;  // INFINITY
      $b2: Result[i]:= #$2264;  // LESS-THAN OR EQUAL TO
      $b3: Result[i]:= #$2265;  // GREATER-THAN OR EQUAL TO
      $b4: Result[i]:= #$00a5;  // YEN SIGN
      $b6: Result[i]:= #$2202;  // PARTIAL DIFFERENTIAL
      $b7: Result[i]:= #$2211;  // N-ARY SUMMATION
      $b8: Result[i]:= #$220f;  // N-ARY PRODUCT
      $b9: Result[i]:= #$03c0;  // GREEK SMALL LETTER PI
      $ba: Result[i]:= #$222b;  // INTEGRAL
      $bb: Result[i]:= #$00aa;  // FEMININE ORDINAL INDICATOR
      $bc: Result[i]:= #$00ba;  // MASCULINE ORDINAL INDICATOR
      $bd: Result[i]:= #$2126;  // OHM SIGN
      $be: Result[i]:= #$00e6;  // LATIN SMALL LIGATURE AE
      $bf: Result[i]:= #$00f8;  // LATIN SMALL LETTER O WITH STROKE
      $c0: Result[i]:= #$00bf;  // INVERTED QUESTION MARK
      $c1: Result[i]:= #$00a1;  // INVERTED EXCLAMATION MARK
      $c2: Result[i]:= #$00ac;  // NOT SIGN
      $c3: Result[i]:= #$221a;  // SQUARE ROOT
      $c4: Result[i]:= #$0192;  // LATIN SMALL LETTER F WITH HOOK
      $c5: Result[i]:= #$2248;  // ALMOST EQUAL TO
      $c6: Result[i]:= #$2206;  // INCREMENT
      $c7: Result[i]:= #$00ab;  // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $c8: Result[i]:= #$00bb;  // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $c9: Result[i]:= #$2026;  // HORIZONTAL ELLIPSIS
      $ca: Result[i]:= #$00a0;  // NO-BREAK SPACE
      $cb: Result[i]:= #$00c0;  // LATIN CAPITAL LETTER A WITH GRAVE
      $cc: Result[i]:= #$00c3;  // LATIN CAPITAL LETTER A WITH TILDE
      $cd: Result[i]:= #$00d5;  // LATIN CAPITAL LETTER O WITH TILDE
      $ce: Result[i]:= #$0152;  // LATIN CAPITAL LIGATURE OE
      $cf: Result[i]:= #$0153;  // LATIN SMALL LIGATURE OE
      $d0: Result[i]:= #$2013;  // EN DASH
      $d1: Result[i]:= #$2014;  // EM DASH
      $d2: Result[i]:= #$201c;  // LEFT DOUBLE QUOTATION MARK
      $d3: Result[i]:= #$201d;  // RIGHT DOUBLE QUOTATION MARK
      $d4: Result[i]:= #$2018;  // LEFT SINGLE QUOTATION MARK
      $d5: Result[i]:= #$2019;  // RIGHT SINGLE QUOTATION MARK
      $d6: Result[i]:= #$00f7;  // DIVISION SIGN
      $d7: Result[i]:= #$25ca;  // LOZENGE
      $d8: Result[i]:= #$00ff;  // LATIN SMALL LETTER Y WITH DIAERESIS
      $d9: Result[i]:= #$0178;  // LATIN CAPITAL LETTER Y WITH DIAERESIS
      $da: Result[i]:= #$2044;  // FRACTION SLASH
      $db: Result[i]:= #$00a4;  // CURRENCY SIGN
      $dc: Result[i]:= #$2039;  // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $dd: Result[i]:= #$203a;  // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $de: Result[i]:= #$fb01;  // LATIN SMALL LIGATURE FI
      $df: Result[i]:= #$fb02;  // LATIN SMALL LIGATURE FL
      $e0: Result[i]:= #$2021;  // DOUBLE DAGGER
      $e1: Result[i]:= #$00b7;  // MIDDLE DOT
      $e2: Result[i]:= #$201a;  // SINGLE LOW-9 QUOTATION MARK
      $e3: Result[i]:= #$201e;  // DOUBLE LOW-9 QUOTATION MARK
      $e4: Result[i]:= #$2030;  // PER MILLE SIGN
      $e5: Result[i]:= #$00c2;  // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $e6: Result[i]:= #$00ca;  // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $e7: Result[i]:= #$00c1;  // LATIN CAPITAL LETTER A WITH ACUTE
      $e8: Result[i]:= #$00cb;  // LATIN CAPITAL LETTER E WITH DIAERESIS
      $e9: Result[i]:= #$00c8;  // LATIN CAPITAL LETTER E WITH GRAVE
      $ea: Result[i]:= #$00cd;  // LATIN CAPITAL LETTER I WITH ACUTE
      $eb: Result[i]:= #$00ce;  // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $ec: Result[i]:= #$00cf;  // LATIN CAPITAL LETTER I WITH DIAERESIS
      $ed: Result[i]:= #$00cc;  // LATIN CAPITAL LETTER I WITH GRAVE
      $ee: Result[i]:= #$00d3;  // LATIN CAPITAL LETTER O WITH ACUTE
      $ef: Result[i]:= #$00d4;  // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $f0: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid cp10000_MacRoman sequence "%s"',[AStr]);
      $f1: Result[i]:= #$00d2;  // LATIN CAPITAL LETTER O WITH GRAVE
      $f2: Result[i]:= #$00da;  // LATIN CAPITAL LETTER U WITH ACUTE
      $f3: Result[i]:= #$00db;  // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $f4: Result[i]:= #$00d9;  // LATIN CAPITAL LETTER U WITH GRAVE
      $f5: Result[i]:= #$0131;  // LATIN SMALL LETTER DOTLESS I
      $f6: Result[i]:= #$02c6;  // MODIFIER LETTER CIRCUMFLEX ACCENT
      $f7: Result[i]:= #$02dc;  // SMALL TILDE
      $f8: Result[i]:= #$00af;  // MACRON
      $f9: Result[i]:= #$02d8;  // BREVE
      $fa: Result[i]:= #$02d9;  // DOT ABOVE
      $fb: Result[i]:= #$02da;  // RING ABOVE
      $fc: Result[i]:= #$00b8;  // CEDILLA
      $fd: Result[i]:= #$02dd;  // DOUBLE ACUTE ACCENT
      $fe: Result[i]:= #$02db;  // OGONEK
      $ff: Result[i]:= #$02c7;  // CARON
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function cp1250ToWS(const AStr: String): WideString; // Windows-1250
// This function was provided by Miloslav Skácel
const
  sInvalidWindows1250Sequence = 'Invalid Windows-1250 sequence "%s"';
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      // NOT USED
      $80,$81,$83,$88,$90,$98:
        Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1250Sequence,[AStr]);
      $82: Result[i]:= #$201a;  // SINGLE LOW-9 QUOTATION MARK
      $84: Result[i]:= #$201e;  // DOUBLE LOW-9 QUOTATION MARK
      $85: Result[i]:= #$2026;  // HORIZONTAL ELLIPSIS
      $86: Result[i]:= #$2020;  // DAGGER
      $87: Result[i]:= #$2021;  // DOUBLE DAGGER
      $89: Result[i]:= #$2030;  // PER MILLE SIGN
      $8a: Result[i]:= #$0160;  // LATIN CAPITAL LETTER S WITH CARON
      $8b: Result[i]:= #$2039;  // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8c: Result[i]:= #$015a;  // LATIN CAPITAL LETTER S WITH ACUTE
      $8d: Result[i]:= #$0164;  // LATIN CAPITAL LETTER T WITH CARON
      $8e: Result[i]:= #$017d;  // LATIN CAPITAL LETTER Z WITH CARON
      $8f: Result[i]:= #$0179;  // LATIN CAPITAL LETTER Z WITH ACUTE
      $91: Result[i]:= #$2018;  // LEFT SINGLE QUOTATION MARK
      $92: Result[i]:= #$2019;  // RIGHT SINGLE QUOTATION MARK
      $93: Result[i]:= #$201c;  // LEFT DOUBLE QUOTATION MARK
      $94: Result[i]:= #$201d;  // RIGHT DOUBLE QUOTATION MARK
      $95: Result[i]:= #$2022;  // BULLET
      $96: Result[i]:= #$2013;  // EN-DASH
      $97: Result[i]:= #$2014;  // EM-DASH
      $99: Result[i]:= #$2122;  // TRADE MARK SIGN
      $9a: Result[i]:= #$0161;  // LATIN SMALL LETTER S WITH CARON
      $9b: Result[i]:= #$203a;  // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9c: Result[i]:= #$015b;  // LATIN SMALL LETTER S WITH ACUTE
      $9d: Result[i]:= #$0165;  // LATIN SMALL LETTER T WITH CARON
      $9e: Result[i]:= #$017e;  // LATIN SMALL LETTER Z WITH CARON
      $9f: Result[i]:= #$017a;  // LATIN SMALL LETTER Z WITH ACUTE
      $a0: Result[i]:= #$00a0;  // NO-BREAK SPACE
      $a1: Result[i]:= #$02c7;  // CARON
      $a2: Result[i]:= #$02d8;  // BREVE
      $a3: Result[i]:= #$0141;  // LATIN CAPITAL LETTER L WITH STROKE
      $a4: Result[i]:= #$00a4;  // CURRENCY SIGN
      $a5: Result[i]:= #$0104;  // LATIN CAPITAL LETTER A WITH OGONEK
      $a6: Result[i]:= #$00a6;  // BROKEN BAR
      $a7: Result[i]:= #$00a7;  // SECTION SIGN
      $a8: Result[i]:= #$00a8;  // DIAERESIS
      $a9: Result[i]:= #$00a9;  // COPYRIGHT SIGN
      $aa: Result[i]:= #$015e;  // LATIN CAPITAL LETTER S WITH CEDILLA
      $ab: Result[i]:= #$00ab;  // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $ac: Result[i]:= #$00ac;  // NOT SIGN
      $ad: Result[i]:= #$00ad;  // SOFT HYPHEN
      $ae: Result[i]:= #$00ae;  // REGISTERED SIGN
      $af: Result[i]:= #$017b;  // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $b0: Result[i]:= #$00b0;  // DEGREE SIGN
      $b1: Result[i]:= #$00b1;  // PLUS-MINUS SIGN
      $b2: Result[i]:= #$02db;  // OGONEK
      $b3: Result[i]:= #$0142;  // LATIN SMALL LETTER L WITH STROKE
      $b4: Result[i]:= #$00b4;  // ACUTE ACCENT
      $b5: Result[i]:= #$00b5;  // MIKRO SIGN
      $b6: Result[i]:= #$00b6;  // PILCROW SIGN
      $b7: Result[i]:= #$00b7;  // MIDDLE DOT
      $b8: Result[i]:= #$00b8;  // CEDILLA
      $b9: Result[i]:= #$0105;  // LATIN SMALL LETTER A WITH OGONEK
      $ba: Result[i]:= #$015f;  // LATIN SMALL LETTER S WITH CEDILLA
      $bb: Result[i]:= #$00bb;  // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $bc: Result[i]:= #$013d;  // LATIN CAPITAL LETTER L WITH CARON
      $bd: Result[i]:= #$02dd;  // DOUBLE ACUTE ACCENT
      $be: Result[i]:= #$013e;  // LATIN SMALL LETTER L WITH CARON
      $bf: Result[i]:= #$017c;  // LATIN SMALL LETTER Z WITH DOT ABOVE
      $c0: Result[i]:= #$0154;  // LATIN CAPITAL LETTER R WITH ACUTE
      $c1: Result[i]:= #$00c1;  // LATIN CAPITAL LETTER A WITH ACUTE
      $c2: Result[i]:= #$00c2;  // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $c3: Result[i]:= #$0102;  // LATIN CAPITAL LETTER A WITH BREVE
      $c4: Result[i]:= #$00c4;  // LATIN CAPITAL LETTER A WITH DIAERESIS
      $c5: Result[i]:= #$0139;  // LATIN CAPITAL LETTER L WITH ACUTE
      $c6: Result[i]:= #$0106;  // LATIN CAPITAL LETTER C WITH ACUTE
      $c7: Result[i]:= #$00c7;  // LATIN CAPITAL LETTER C WITH CEDILLA
      $c8: Result[i]:= #$010c;  // LATIN CAPITAL LETTER C WITH CARON
      $c9: Result[i]:= #$00c9;  // LATIN CAPITAL LETTER E WITH ACUTE
      $ca: Result[i]:= #$0118;  // LATIN CAPITAL LETTER E WITH OGONEK
      $cb: Result[i]:= #$00cb;  // LATIN CAPITAL LETTER E WITH DIAERESIS
      $cc: Result[i]:= #$011a;  // LATIN CAPITAL LETTER E WITH CARON
      $cd: Result[i]:= #$00cd;  // LATIN CAPITAL LETTER I WITH ACUTE
      $ce: Result[i]:= #$00ce;  // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $cf: Result[i]:= #$010e;  // LATIN CAPITAL LETTER D WITH CARON
      $d0: Result[i]:= #$0110;  // LATIN CAPITAL LETTER D WITH STROKE
      $d1: Result[i]:= #$0143;  // LATIN CAPITAL LETTER N WITH ACUTE
      $d2: Result[i]:= #$0147;  // LATIN CAPITAL LETTER N WITH CARON
      $d3: Result[i]:= #$00d3;  // LATIN CAPITAL LETTER O WITH ACUTE
      $d4: Result[i]:= #$00d4;  // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $d5: Result[i]:= #$0150;  // LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
      $d6: Result[i]:= #$00d6;  // LATIN CAPITAL LETTER O WITH DIAERESIS
      $d7: Result[i]:= #$00d7;  // MULTIPLICATION SIGN
      $d8: Result[i]:= #$0158;  // LATIN CAPITAL LETTER R WITH CARON
      $d9: Result[i]:= #$016e;  // LATIN CAPITAL LETTER U WITH RING ABOVE
      $da: Result[i]:= #$00da;  // LATIN CAPITAL LETTER U WITH ACUTE
      $db: Result[i]:= #$0170;  // LATIN CAPITAL LETTER U WITH WITH DOUBLE ACUTE
      $dc: Result[i]:= #$00dc;  // LATIN CAPITAL LETTER U WITH DIAERESIS
      $dd: Result[i]:= #$00dd;  // LATIN CAPITAL LETTER Y WITH ACUTE
      $de: Result[i]:= #$0162;  // LATIN CAPITAL LETTER T WITH CEDILLA
      $df: Result[i]:= #$00df;  // LATIN SMALL LETTER SHARP S
      $e0: Result[i]:= #$0155;  // LATIN SMALL LETTER R WITH ACUTE
      $e1: Result[i]:= #$00e1;  // LATIN SMALL LETTER A WITH ACUTE
      $e2: Result[i]:= #$00e2;  // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $e3: Result[i]:= #$0103;  // LATIN SMALL LETTER A WITH BREVE
      $e4: Result[i]:= #$00e4;  // LATIN SMALL LETTER A WITH DIAERESIS
      $e5: Result[i]:= #$013a;  // LATIN SMALL LETTER L WITH ACUTE
      $e6: Result[i]:= #$0107;  // LATIN SMALL LETTER C WITH ACUTE
      $e7: Result[i]:= #$00e7;  // LATIN SMALL LETTER C WITH CEDILLA
      $e8: Result[i]:= #$010d;  // LATIN SMALL LETTER C WITH CARON 100D
      $e9: Result[i]:= #$00e9;  // LATIN SMALL LETTER E WITH ACUTE
      $ea: Result[i]:= #$0119;  // LATIN SMALL LETTER E WITH OGONEK
      $eb: Result[i]:= #$00eb;  // LATIN SMALL LETTER E WITH DIAERESIS
      $ec: Result[i]:= #$011b;  // LATIN SMALL LETTER E WITH CARON
      $ed: Result[i]:= #$00ed;  // LATIN SMALL LETTER I WITH ACUTE
      $ee: Result[i]:= #$00ee;  // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $ef: Result[i]:= #$010f;  // LATIN SMALL LETTER D WITH CARON
      $f0: Result[i]:= #$0111;  // LATIN SMALL LETTER D WITH STROKE
      $f1: Result[i]:= #$0144;  // LATIN SMALL LETTER N WITH ACUTE
      $f2: Result[i]:= #$0148;  // LATIN SMALL LETTER N WITH CARON
      $f3: Result[i]:= #$00f3;  // LATIN SMALL LETTER O WITH ACUTE
      $f4: Result[i]:= #$00f4;  // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $f5: Result[i]:= #$0151;  // LATIN SMALL LETTER O WITH DOUBLE ACUTE
      $f6: Result[i]:= #$00f6;  // LATIN SMALL LETTER O WITH DIAERESIS
      $f7: Result[i]:= #$00f7;  // DIVISION SIGN
      $f8: Result[i]:= #$0159;  // LATIN SMALL LETTER R WITH CARON
      $f9: Result[i]:= #$016f;  // LATIN SMALL LETTER U WITH RING ABOVE
      $fa: Result[i]:= #$00fa;  // LATIN SMALL LETTER U WITH ACUTE
      $fb: Result[i]:= #$0171;  // LATIN SMALL LETTER U WITH WITH DOUBLE ACUTE
      $fc: Result[i]:= #$00fc;  // LATIN SMALL LETTER U WITH DIAERESIS
      $fd: Result[i]:= #$00fd;  // LATIN SMALL LETTER Y WITH ACUTE
      $fe: Result[i]:= #$0163;  // LATIN SMALL LETTER T WITH CEDILLA
      $ff: Result[i]:= #$02d9;  // DOT ABOVE
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function cp1251ToWS(const AStr: String): WideString; // Windows-1251
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $80: Result[i]:= #$0402;  // CYRILLIC CAPITAL LETTER DJE
      $81: Result[i]:= #$0403;  // CYRILLIC CAPITAL LETTER GJE
      $82: Result[i]:= #$201a;  // SINGLE LOW-9 QUOTATION MARK
      $83: Result[i]:= #$0453;  // CYRILLIC SMALL LETTER GJE
      $84: Result[i]:= #$201e;  // DOUBLE LOW-9 QUOTATION MARK
      $85: Result[i]:= #$2026;  // HORIZONTAL ELLIPSIS
      $86: Result[i]:= #$2020;  // DAGGER
      $87: Result[i]:= #$2021;  // DOUBLE DAGGER
      $88: Result[i]:= #$20ac;  // EURO SIGN
      $89: Result[i]:= #$2030;  // PER MILLE SIGN
      $8a: Result[i]:= #$0409;  // CYRILLIC CAPITAL LETTER LJE
      $8b: Result[i]:= #$2039;  // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8c: Result[i]:= #$040a;  // CYRILLIC CAPITAL LETTER NJE
      $8d: Result[i]:= #$040c;  // CYRILLIC CAPITAL LETTER KJE
      $8e: Result[i]:= #$040b;  // CYRILLIC CAPITAL LETTER TSHE
      $8f: Result[i]:= #$040f;  // CYRILLIC CAPITAL LETTER DZHE
      $90: Result[i]:= #$0452;  // CYRILLIC SMALL LETTER DJE
      $91: Result[i]:= #$2018;  // LEFT SINGLE QUOTATION MARK
      $92: Result[i]:= #$2019;  // RIGHT SINGLE QUOTATION MARK
      $93: Result[i]:= #$201c;  // LEFT DOUBLE QUOTATION MARK
      $94: Result[i]:= #$201d;  // RIGHT DOUBLE QUOTATION MARK
      $95: Result[i]:= #$2022;  // BULLET
      $96: Result[i]:= #$2013;  // EN DASH
      $97: Result[i]:= #$2014;  // EM DASH
      $98: Result[i]:= #$007C;  // similar to Vertical line // raise EConvertError.CreateFmt('Invalid cp1251 sequence "%s"',[AStr]);
      $99: Result[i]:= #$2122;  // TRADE MARK SIGN
      $9a: Result[i]:= #$0459;  // CYRILLIC SMALL LETTER LJE
      $9b: Result[i]:= #$203a;  // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9c: Result[i]:= #$045a;  // CYRILLIC SMALL LETTER NJE
      $9d: Result[i]:= #$045c;  // CYRILLIC SMALL LETTER KJE
      $9e: Result[i]:= #$045b;  // CYRILLIC SMALL LETTER TSHE
      $9f: Result[i]:= #$045f;  // CYRILLIC SMALL LETTER DZHE
      $a0: Result[i]:= #$00a0;  // NO-BREAK SPACE
      $a1: Result[i]:= #$040e;  // CYRILLIC CAPITAL LETTER SHORT U
      $a2: Result[i]:= #$045e;  // CYRILLIC SMALL LETTER SHORT U
      $a3: Result[i]:= #$0408;  // CYRILLIC CAPITAL LETTER JE
      $a4: Result[i]:= #$00a4;  // CURRENCY SIGN
      $a5: Result[i]:= #$0490;  // CYRILLIC CAPITAL LETTER GHE WITH UPTURN
      $a8: Result[i]:= #$0401;  // CYRILLIC CAPITAL LETTER IO
      $aa: Result[i]:= #$0404;  // CYRILLIC CAPITAL LETTER UKRAINIAN IE
      $af: Result[i]:= #$0407;  // CYRILLIC CAPITAL LETTER YI
      $b2: Result[i]:= #$0406;  // CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
      $b3: Result[i]:= #$0456;  // CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
      $b4: Result[i]:= #$0491;  // CYRILLIC SMALL LETTER GHE WITH UPTURN
      $b8: Result[i]:= #$0451;  // CYRILLIC SMALL LETTER IO
      $b9: Result[i]:= #$2116;  // NUMERO SIGN
      $ba: Result[i]:= #$0454;  // CYRILLIC SMALL LETTER UKRAINIAN IE
      $bc: Result[i]:= #$0458;  // CYRILLIC SMALL LETTER JE
      $bd: Result[i]:= #$0405;  // CYRILLIC CAPITAL LETTER DZE
      $be: Result[i]:= #$0455;  // CYRILLIC SMALL LETTER DZE
      $bf: Result[i]:= #$0457;  // CYRILLIC SMALL LETTER YI
      $c0..$ff:
        Result[i]:= WideChar(Byte(AStr[i]) + $350);
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

function cp1252ToWS(const AStr: String): WideString; // Windows-1252
// Provided by Olaf Lösken.
// Info taken from
// ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1252.TXT
const
  sInvalidWindows1252Sequence = 'Invalid Windows-1252 sequence "%s"';
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case Byte(AStr[i]) of
      $80 : Result[i]:= #$20AC; //EUROSIGN
      $81 : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      $82 : Result[i]:= #$201A; //SINGLE LOW-9 QUOTATION MARK
      $83 : Result[i]:= #$0192; //ATIN SMALL LETTER F WITH HOOK
      $84 : Result[i]:= #$201E; //DOUBLE LOW-9 QUOTATION MARK
      $85 : Result[i]:= #$2026; //HORIZONTAL ELLIPSIS
      $86 : Result[i]:= #$2020; //DAGGER
      $87 : Result[i]:= #$2021; //DOUBLE DAGGER
      $88 : Result[i]:= #$02C6; //MODIFIER LETTER CIRCUMFLEX ACCENT
      $89 : Result[i]:= #$2030; //PER MILLE SIGN
      $8A : Result[i]:= #$0160; //LATIN CAPITAL LETTER S WITH CARON
      $8B : Result[i]:= #$2039; //SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8C : Result[i]:= #$0152; //LATIN CAPITAL LIGATURE OE
      $8D : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      $8E : Result[i]:= #$017D; //LATIN CAPITAL LETTER Z WITH CARON
      $8F : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      $90 : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      $91 : Result[i]:= #$2018; //LEFT SINGLE QUOTATION MARK
      $92 : Result[i]:= #$2019; //RIGHT SINGLE QUOTATION MARK
      $93 : Result[i]:= #$201C; //LEFT DOUBLE QUOTATION MARK
      $94 : Result[i]:= #$201D; //RIGHT DOUBLE QUOTATION MARK
      $95 : Result[i]:= #$2022; //BULLET
      $96 : Result[i]:= #$2013; //EN DASH
      $97 : Result[i]:= #$2014; //EM DASH
      $98 : Result[i]:= #$02DC; //SMALL TILDE
      $99 : Result[i]:= #$2122; //TRADE MARK SIGN
      $9A : Result[i]:= #$0161; //LATIN SMALL LETTER S WITH CARON
      $9B : Result[i]:= #$203A; //SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9C : Result[i]:= #$0153; //LATIN SMALL LIGATURE OE
      $9D : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      $9E : Result[i]:= #$017E; //LATIN SMALL LETTER Z WITH CARON
      $9F : Result[i]:= #$0178; //LATIN CAPITAL LETTER Y WITH D
    else
      Result[i]:= WideChar(AStr[i]);
    end;
  end;
end;

// unicode to specific code page conversion functions

function WSTo_Iso8859_1(const AStr: WideString): String;  // Latin-1
{
var
  i, len: Integer;
}
begin
  // len:= Length(AStr);
  Result:= AStr;
  {
  for i:= 1 to len do begin
    Result:= Result + AStr[i];
  end;
  }
end;

function WSTo_Iso8859_2(const AStr: WideString): String;  // Latin-2
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
     #$0104: Result[i]:= #$a1;  // LATIN CAPITAL LETTER A WITH OGONEK
     #$02d8: Result[i]:= #$a2;  // BREVE
     #$0141: Result[i]:= #$a3;  // LATIN CAPITAL LETTER L WITH STROKE
     #$0132: Result[i]:= #$a5;  // LATIN CAPITAL LETTER L WITH CARON
     #$015a: Result[i]:= #$a6;  // LATIN CAPITAL LETTER S WITH ACUTE
     #$0160: Result[i]:= #$a9;  // LATIN CAPITAL LETTER S WITH CARON
     #$015e: Result[i]:= #$aa;  // LATIN CAPITAL LETTER S WITH CEDILLA
     #$0164: Result[i]:= #$ab;  // LATIN CAPITAL LETTER T WITH CARON
     #$0179: Result[i]:= #$ac;  // LATIN CAPITAL LETTER Z WITH ACUTE
     #$017d: Result[i]:= #$ae;  // LATIN CAPITAL LETTER Z WITH CARON
     #$017b: Result[i]:= #$af;  // LATIN CAPITAL LETTER Z WITH DOT ABOVE
     #$0105: Result[i]:= #$b1;  // LATIN SMALL LETTER A WITH OGONEK
     #$02db: Result[i]:= #$b2;  // OGONEK
     #$0142: Result[i]:= #$b3;  // LATIN SMALL LETTER L WITH STROKE
     #$013e: Result[i]:= #$b5;  // LATIN SMALL LETTER L WITH CARON
     #$015b: Result[i]:= #$b6;  // LATIN SMALL LETTER S WITH ACUTE
     #$02c7: Result[i]:= #$b7;  // CARON
     #$0161: Result[i]:= #$b9;  // LATIN SMALL LETTER S WITH CARON
     #$015f: Result[i]:= #$ba;  // LATIN SMALL LETTER S WITH CEDILLA
     #$0165: Result[i]:= #$bb;  // LATIN SMALL LETTER T WITH CARON
     #$017a: Result[i]:= #$bc;  // LATIN SMALL LETTER Z WITH ACUTE
     #$02dd: Result[i]:= #$bd;  // DOUBLE ACUTE ACCENT
     #$017e: Result[i]:= #$be;  // LATIN SMALL LETTER Z WITH CARON
     #$017c: Result[i]:= #$bf;  // LATIN SMALL LETTER Z WITH DOT ABOVE
     #$0154: Result[i]:= #$c0;  // LATIN CAPITAL LETTER R WITH ACUTE
     #$0102: Result[i]:= #$c3;  // LATIN CAPITAL LETTER A WITH BREVE
     #$0139: Result[i]:= #$c5;  // LATIN CAPITAL LETTER L WITH ACUTE
     #$0106: Result[i]:= #$c6;  // LATIN CAPITAL LETTER C WITH ACUTE
     #$010c: Result[i]:= #$c8;  // LATIN CAPITAL LETTER C WITH CARON
     #$0118: Result[i]:= #$ca;  // LATIN CAPITAL LETTER E WITH OGONEK
     #$011a: Result[i]:= #$cc;  // LATIN CAPITAL LETTER E WITH CARON
     #$010e: Result[i]:= #$cf;  // LATIN CAPITAL LETTER D WITH CARON
     #$0110: Result[i]:= #$d0;  // LATIN CAPITAL LETTER D WITH STROKE
     #$0143: Result[i]:= #$d1;  // LATIN CAPITAL LETTER N WITH ACUTE
     #$0147: Result[i]:= #$d2;  // LATIN CAPITAL LETTER N WITH CARON
     #$0150: Result[i]:= #$d5;  // LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
     #$0158: Result[i]:= #$d8;  // LATIN CAPITAL LETTER R WITH CARON
     #$016e: Result[i]:= #$d9;  // LATIN CAPITAL LETTER U WITH RING ABOVE
     #$0170: Result[i]:= #$db;  // LATIN CAPITAL LETTER U WITH WITH DOUBLE ACUTE
     #$0162: Result[i]:= #$de;  // LATIN CAPITAL LETTER T WITH CEDILLA
     #$0155: Result[i]:= #$e0;  // LATIN SMALL LETTER R WITH ACUTE
     #$0103: Result[i]:= #$e3;  // LATIN SMALL LETTER A WITH BREVE
     #$013a: Result[i]:= #$e5;  // LATIN SMALL LETTER L WITH ACUTE
     #$0107: Result[i]:= #$e6;  // LATIN SMALL LETTER C WITH ACUTE
     #$010d: Result[i]:= #$e8;  // LATIN SMALL LETTER C WITH CARON
     #$0119: Result[i]:= #$ea;  // LATIN SMALL LETTER E WITH OGONEK
     #$011b: Result[i]:= #$ec;  // LATIN SMALL LETTER E WITH CARON
     #$010f: Result[i]:= #$ef;  // LATIN SMALL LETTER D WITH CARON
     #$0111: Result[i]:= #$f0;  // LATIN SMALL LETTER D WITH STROKE
     #$0144: Result[i]:= #$f1;  // LATIN SMALL LETTER N WITH ACUTE
     #$0148: Result[i]:= #$f2;  // LATIN SMALL LETTER N WITH CARON
     #$0151: Result[i]:= #$f5;  // LATIN SMALL LETTER O WITH DOUBLE ACUTE
     #$0159: Result[i]:= #$f8;  // LATIN SMALL LETTER R WITH CARON
     #$016f: Result[i]:= #$f9;  // LATIN SMALL LETTER U WITH RING ABOVE
     #$0171: Result[i]:= #$fb;  // LATIN SMALL LETTER U WITH WITH DOUBLE ACUTE
     #$0163: Result[i]:= #$fe;  // LATIN SMALL LETTER T WITH CEDILLA
     #$02d9: Result[i]:= #$ff;  // DOT ABOVE
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_Iso8859_3(const AStr: WideString): String;  // Latin-3
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$0126: Result[i]:= #$a1;  // LATIN CAPITAL LETTER H WITH STROKE
      #$02d8: Result[i]:= #$a2;  // BREVE
      #$0124: Result[i]:= #$a6;  // LATIN CAPITAL LETTER H WITH CIRCUMFLEX
      #$0130: Result[i]:= #$a9;  // LATIN CAPITAL LETTER I WITH DOT ABOVE
      #$015e: Result[i]:= #$aa;  // LATIN CAPITAL LETTER S WITH CEDILLA
      #$011e: Result[i]:= #$ab;  // LATIN CAPITAL LETTER G WITH BREVE
      #$0134: Result[i]:= #$ac;  // LATIN CAPITAL LETTER J WITH CIRCUMFLEX
      #$017b: Result[i]:= #$af;  // LATIN CAPITAL LETTER Z WITH DOT
      #$0127: Result[i]:= #$b1;  // LATIN SMALL LETTER H WITH STROKE
      #$0125: Result[i]:= #$b6;  // LATIN SMALL LETTER H WITH CIRCUMFLEX
      #$0131: Result[i]:= #$b9;  // LATIN SMALL LETTER DOTLESS I
      #$015f: Result[i]:= #$ba;  // LATIN SMALL LETTER S WITH CEDILLA
      #$011f: Result[i]:= #$bb;  // LATIN SMALL LETTER G WITH BREVE
      #$0135: Result[i]:= #$bc;  // LATIN SMALL LETTER J WITH CIRCUMFLEX
      #$017c: Result[i]:= #$bf;  // LATIN SMALL LETTER Z WITH DOT
      #$010a: Result[i]:= #$c5;  // LATIN CAPITAL LETTER C WITH DOT ABOVE
      #$0108: Result[i]:= #$c6;  // LATIN CAPITAL LETTER C WITH CIRCUMFLEX
      #$0120: Result[i]:= #$d5;  // LATIN CAPITAL LETTER G WITH DOT ABOVE
      #$011c: Result[i]:= #$d8;  // LATIN CAPITAL LETTER G WITH CIRCUMFLEX
      #$016c: Result[i]:= #$dd;  // LATIN CAPITAL LETTER U WITH BREVE
      #$015c: Result[i]:= #$de;  // LATIN CAPITAL LETTER S WITH CIRCUMFLEX
      #$010b: Result[i]:= #$e5;  // LATIN SMALL LETTER C WITH DOT ABOVE
      #$0109: Result[i]:= #$e6;  // LATIN SMALL LETTER C WITH CIRCUMFLEX
      #$0121: Result[i]:= #$f5;  // LATIN SMALL LETTER G WITH DOT ABOVE
      #$011d: Result[i]:= #$f8;  // LATIN SMALL LETTER G WITH CIRCUMFLEX
      #$016d: Result[i]:= #$fd;  // LATIN SMALL LETTER U WITH BREVE
      #$015d: Result[i]:= #$fe;  // LATIN SMALL LETTER S WITH CIRCUMFLEX
      #$02d9: Result[i]:= #$ff;  // DOT ABOVE
      {
      $a5:
      $ae:
      $be:
      $c3:
      $d0:
      $e3:
      $f0:
      }
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_Iso8859_4(const AStr: WideString): String;  // Latin-4
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$0104: Result[i]:= #$a1;  // LATIN CAPITAL LETTER A WITH OGONEK
      #$0138: Result[i]:= #$a2;  // LATIN SMALL LETTER KRA
      #$0156: Result[i]:= #$a3;  // LATIN CAPITAL LETTER R WITH CEDILLA
      #$0128: Result[i]:= #$a5;  // LATIN CAPITAL LETTER I WITH TILDE
      #$013b: Result[i]:= #$a6;  // LATIN CAPITAL LETTER L WITH CEDILLA
      #$0160: Result[i]:= #$a9;  // LATIN CAPITAL LETTER S WITH CARON
      #$0112: Result[i]:= #$aa;  // LATIN CAPITAL LETTER E WITH MACRON
      #$0122: Result[i]:= #$ab;  // LATIN CAPITAL LETTER G WITH CEDILLA
      #$0166: Result[i]:= #$ac;  // LATIN CAPITAL LETTER T WITH STROKE
      #$017d: Result[i]:= #$ae;  // LATIN CAPITAL LETTER Z WITH CARON
      #$0105: Result[i]:= #$b1;  // LATIN SMALL LETTER A WITH OGONEK
      #$02db: Result[i]:= #$b2;  // OGONEK
      #$0157: Result[i]:= #$b3;  // LATIN SMALL LETTER R WITH CEDILLA
      #$0129: Result[i]:= #$b5;  // LATIN SMALL LETTER I WITH TILDE
      #$013c: Result[i]:= #$b6;  // LATIN SMALL LETTER L WITH CEDILLA
      #$02c7: Result[i]:= #$b7;  // CARON
      #$0161: Result[i]:= #$b9;  // LATIN SMALL LETTER S WITH CARON
      #$0113: Result[i]:= #$ba;  // LATIN SMALL LETTER E WITH MACRON
      #$0123: Result[i]:= #$bb;  // LATIN SMALL LETTER G WITH CEDILLA
      #$0167: Result[i]:= #$bc;  // LATIN SMALL LETTER T WITH STROKE
      #$014a: Result[i]:= #$bd;  // LATIN CAPITAL LETTER ENG
      #$017e: Result[i]:= #$be;  // LATIN SMALL LETTER Z WITH CARON
      #$014b: Result[i]:= #$bf;  // LATIN SMALL LETTER ENG
      #$0100: Result[i]:= #$c0;  // LATIN CAPITAL LETTER A WITH MACRON
      #$012e: Result[i]:= #$c7;  // LATIN CAPITAL LETTER I WITH OGONEK
      #$010c: Result[i]:= #$c8;  // LATIN CAPITAL LETTER C WITH CARON
      #$0118: Result[i]:= #$ca;  // LATIN CAPITAL LETTER E WITH OGONEK
      #$0116: Result[i]:= #$cc;  // LATIN CAPITAL LETTER E WITH DOT ABOVE
      #$012a: Result[i]:= #$cf;  // LATIN CAPITAL LETTER I WITH MACRON
      #$0110: Result[i]:= #$d0;  // LATIN CAPITAL LETTER D WITH STROKE
      #$0145: Result[i]:= #$d1;  // LATIN CAPITAL LETTER N WITH CEDILLA
      #$014c: Result[i]:= #$d2;  // LATIN CAPITAL LETTER O WITH MACRON
      #$0136: Result[i]:= #$d3;  // LATIN CAPITAL LETTER K WITH CEDILLA
      #$0172: Result[i]:= #$d9;  // LATIN CAPITAL LETTER U WITH OGONEK
      #$0168: Result[i]:= #$dd;  // LATIN CAPITAL LETTER U WITH TILDE
      #$016a: Result[i]:= #$de;  // LATIN CAPITAL LETTER U WITH MACRON
      #$0101: Result[i]:= #$e0;  // LATIN SMALL LETTER A WITH MACRON
      #$012f: Result[i]:= #$e7;  // LATIN SMALL LETTER I WITH OGONEK
      #$010d: Result[i]:= #$e8;  // LATIN SMALL LETTER C WITH CARON
      #$0119: Result[i]:= #$ea;  // LATIN SMALL LETTER E WITH OGONEK
      #$0117: Result[i]:= #$ec;  // LATIN SMALL LETTER E WITH DOT ABOVE
      #$012b: Result[i]:= #$ef;  // LATIN SMALL LETTER I WITH MACRON
      #$0111: Result[i]:= #$f0;  // LATIN SMALL LETTER D WITH STROKE
      #$0146: Result[i]:= #$f1;  // LATIN SMALL LETTER N WITH CEDILLA
      #$014d: Result[i]:= #$f2;  // LATIN SMALL LETTER O WITH MACRON
      #$0137: Result[i]:= #$f3;  // LATIN SMALL LETTER K WITH CEDILLA
      #$0173: Result[i]:= #$f9;  // LATIN SMALL LETTER U WITH OGONEK
      #$0169: Result[i]:= #$fd;  // LATIN SMALL LETTER U WITH TILDE
      #$016b: Result[i]:= #$fe;  // LATIN SMALL LETTER U WITH MACRON
      #$02d9: Result[i]:= #$ff;  // DOT ABOVE
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_Iso8859_5(const AStr: WideString): String;  // Cyrillic
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$00..#$a0, #$ad:
        Byte(Result[i]):= Byte(AStr[i]);
      #$2116: Result[i]:= #$f0;  // NUMERO SIGN
      #$00a7: Result[i]:= #$fd;  // SECTION SIGN
    else
      Result[i]:= Char(Word(AStr[i]) - $0360);  // Lo
    end;
  end;
end;

function WSTo_Iso8859_6(const AStr: WideString): String;  // Arabic
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$00..#$a0,#$a4,#$ad:
        Byte(Result[i]):= Byte(AStr[i]);
      WideChar($ac + $0580),
      WideChar($bb + $0580),
      WideChar($bf + $0580),
      WideChar($c1 + $0580)..WideChar($da + $0580),
      WideChar($e0 + $0580)..WideChar($f2 + $0580):
        Result[i]:= Char(Word(AStr[i]) - $0580);
    else
       Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-6 sequence "%s"',[AStr]);
    end;
  end;
end;

function WSTo_Iso8859_7(const AStr: WideString): String;  // Greek
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$00..#$a0,#$a6..#$a9,#$ab..#$ad,#$b0..#$b3,#$b7,#$bb,#$bd:
        Byte(Result[i]):= Byte(AStr[i]);
      #$2018: Result[i]:= #$a1;  // LEFT SINGLE QUOTATION MARK
      #$2019: Result[i]:= #$a2;  // RIGHT SINGLE QUOTATION MARK
      #$2015: Result[i]:= #$af;  // HORIZONTAL BAR
      {
      #$d2,#$ff: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-7 sequence "%s"',[AStr]);
      }
    else
      Result[i]:= Char(Word(AStr[i]) - $02d0);
    end;
  end;
end;

function WSTo_Iso8859_8(const AStr: WideString): String;  // Hebrew
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$00..#$a0,#$a2..#$a9,#$ab..#$ae,#$b0..#$b9,#$bb..#$be:
        Byte(Result[i]):= Byte(AStr[i]);
      #$00d7: Result[i]:= #$aa;  // MULTIPLICATION SIGN
      #$203e: Result[i]:= #$af;  // OVERLINE
      #$00f7: Result[i]:= #$ba;  // DIVISION SIGN
      #$2017: Result[i]:= #$df;  // DOUBLE LOW LINE
      WideChar($e0 + $04e0)..WideChar($fa + $04e0):
        Result[i]:= Char(Word(AStr[i]) - $04e0);
    else
      Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid ISO-8859-8 sequence "%s"',[AStr]);
    end;
  end;
end;

function WSTo_Iso8859_9(const AStr: WideString): String;  //
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$011e: Result[i]:= #$d0;  // LATIN CAPITAL LETTER G WITH BREVE
      #$0130: Result[i]:= #$dd;  // LATIN CAPITAL LETTER I WITH DOT ABOVE
      #$015e: Result[i]:= #$de;  // LATIN CAPITAL LETTER S WITH CEDILLA
      #$011f: Result[i]:= #$f0;  // LATIN SMALL LETTER G WITH BREVE
      #$0131: Result[i]:= #$fd;  // LATIN SMALL LETTER I WITH DOT ABOVE
      #$015f: Result[i]:= #$fe;  // LATIN SMALL LETTER S WITH CEDILLA
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_Iso8859_10(const AStr: WideString): String; // Latin-6
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$0104: Result[i]:= #$a1;  // LATIN CAPITAL LETTER A WITH OGONEK
      #$0112: Result[i]:= #$a2;  // LATIN CAPITAL LETTER E WITH MACRON
      #$0122: Result[i]:= #$a3;  // LATIN CAPITAL LETTER G WITH CEDILLA
      #$012a: Result[i]:= #$a4;  // LATIN CAPITAL LETTER I WITH MACRON
      #$0128: Result[i]:= #$a5;  // LATIN CAPITAL LETTER I WITH TILDE
      #$0136: Result[i]:= #$a6;  // LATIN CAPITAL LETTER K WITH CEDILLA
      #$013b: Result[i]:= #$a8;  // LATIN CAPITAL LETTER L WITH CEDILLA
      #$0110: Result[i]:= #$a9;  // LATIN CAPITAL LETTER D WITH STROKE
      #$0160: Result[i]:= #$aa;  // LATIN CAPITAL LETTER S WITH CARON
      #$0166: Result[i]:= #$ab;  // LATIN CAPITAL LETTER T WITH STROKE
      #$017d: Result[i]:= #$ac;  // LATIN CAPITAL LETTER Z WITH CARON
      #$016a: Result[i]:= #$ae;  // LATIN CAPITAL LETTER U WITH MACRON
      #$014a: Result[i]:= #$af;  // LATIN CAPITAL LETTER ENG
      #$0105: Result[i]:= #$b1;  // LATIN SMALL LETTER A WITH OGONEK
      #$0113: Result[i]:= #$b2;  // LATIN SMALL LETTER E WITH MACRON
      #$0123: Result[i]:= #$b3;  // LATIN SMALL LETTER G WITH CEDILLA
      #$012b: Result[i]:= #$b4;  // LATIN SMALL LETTER I WITH MACRON
      #$0129: Result[i]:= #$b5;  // LATIN SMALL LETTER I WITH TILDE
      #$0137: Result[i]:= #$b6;  // LATIN SMALL LETTER K WITH CEDILLA
      #$013c: Result[i]:= #$b8;  // LATIN SMALL LETTER L WITH CEDILLA
      #$0111: Result[i]:= #$b9;  // LATIN SMALL LETTER D WITH STROKE
      #$0161: Result[i]:= #$ba;  // LATIN SMALL LETTER S WITH CARON
      #$0167: Result[i]:= #$bb;  // LATIN SMALL LETTER T WITH STROKE
      #$017e: Result[i]:= #$bc;  // LATIN SMALL LETTER Z WITH CARON
      #$2015: Result[i]:= #$bd;  // HORIZONTAL BAR
      #$016b: Result[i]:= #$be;  // LATIN SMALL LETTER U WITH MACRON
      #$014b: Result[i]:= #$bf;  // LATIN SMALL LETTER ENG
      #$0100: Result[i]:= #$c0;  // LATIN CAPITAL LETTER A WITH MACRON
      #$012e: Result[i]:= #$c7;  // LATIN CAPITAL LETTER I WITH OGONEK
      #$010c: Result[i]:= #$c8;  // LATIN CAPITAL LETTER C WITH CARON
      #$0118: Result[i]:= #$ca;  // LATIN CAPITAL LETTER E WITH OGONEK
      #$0116: Result[i]:= #$cc;  // LATIN CAPITAL LETTER E WITH DOT ABOVE
      #$0145: Result[i]:= #$d1;  // LATIN CAPITAL LETTER N WITH CEDILLA
      #$014c: Result[i]:= #$d2;  // LATIN CAPITAL LETTER O WITH MACRON
      #$0168: Result[i]:= #$d7;  // LATIN CAPITAL LETTER U WITH TILDE
      #$0172: Result[i]:= #$d9;  // LATIN CAPITAL LETTER U WITH OGONEK
      #$0101: Result[i]:= #$e0;  // LATIN SMALL LETTER A WITH MACRON
      #$012f: Result[i]:= #$e7;  // LATIN SMALL LETTER I WITH OGONEK
      #$010d: Result[i]:= #$e8;  // LATIN SMALL LETTER C WITH CARON
      #$0119: Result[i]:= #$ea;  // LATIN SMALL LETTER E WITH OGONEK
      #$0117: Result[i]:= #$ec;  // LATIN SMALL LETTER E WITH DOT ABOVE
      #$0146: Result[i]:= #$f1;  // LATIN SMALL LETTER N WITH CEDILLA
      #$014d: Result[i]:= #$f2;  // LATIN SMALL LETTER O WITH MACRON
      #$0169: Result[i]:= #$f7;  // LATIN SMALL LETTER U WITH TILDE
      #$0173: Result[i]:= #$f9;  // LATIN SMALL LETTER U WITH OGONEK
      #$0138: Result[i]:= #$ff;  // LATIN SMALL LETTER KRA
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_Iso8859_13(const AStr: WideString): String; // Latin-7
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$201d: Result[i]:= #$a1;  // RIGHT DOUBLE QUOTATION MARK
      #$201e: Result[i]:= #$a5;  // DOUBLE LOW-9 QUOTATION MARK
      #$00d8: Result[i]:= #$a8;  // LATIN CAPITAL LETTER O WITH STROKE
      #$0156: Result[i]:= #$aa;  // LATIN CAPITAL LETTER R WITH CEDILLA
      #$00c6: Result[i]:= #$af;  // LATIN CAPITAL LETTER AE
      #$201c: Result[i]:= #$b4;  // LEFT DOUBLE QUOTATION MARK
      #$00f8: Result[i]:= #$b8;  // LATIN SMALL LETTER O WITH STROKE
      #$0157: Result[i]:= #$ba;  // LATIN SMALL LETTER R WITH CEDILLA
      #$00e6: Result[i]:= #$bf;  // LATIN SMALL LETTER AE
      #$0104: Result[i]:= #$c0;  // LATIN CAPITAL LETTER A WITH OGONEK
      #$012e: Result[i]:= #$c1;  // LATIN CAPITAL LETTER I WITH OGONEK
      #$0100: Result[i]:= #$c2;  // LATIN CAPITAL LETTER A WITH MACRON
      #$0106: Result[i]:= #$c3;  // LATIN CAPITAL LETTER C WITH ACUTE
      #$0118: Result[i]:= #$c6;  // LATIN CAPITAL LETTER E WITH OGONEK
      #$0112: Result[i]:= #$c7;  // LATIN CAPITAL LETTER E WITH MACRON
      #$010c: Result[i]:= #$c8;  // LATIN CAPITAL LETTER C WITH CARON
      #$0179: Result[i]:= #$ca;  // LATIN CAPITAL LETTER Z WITH ACUTE
      #$0116: Result[i]:= #$cb;  // LATIN CAPITAL LETTER E WITH DOT ABOVE
      #$0122: Result[i]:= #$cc;  // LATIN CAPITAL LETTER G WITH CEDILLA
      #$0136: Result[i]:= #$cd;  // LATIN CAPITAL LETTER K WITH CEDILLA
      #$012a: Result[i]:= #$ce;  // LATIN CAPITAL LETTER I WITH MACRON
      #$013b: Result[i]:= #$cf;  // LATIN CAPITAL LETTER L WITH CEDILLA
      #$0160: Result[i]:= #$d0;  // LATIN CAPITAL LETTER S WITH CARON
      #$0143: Result[i]:= #$d1;  // LATIN CAPITAL LETTER N WITH ACUTE
      #$0145: Result[i]:= #$d2;  // LATIN CAPITAL LETTER N WITH CEDILLA
      #$014c: Result[i]:= #$d4;  // LATIN CAPITAL LETTER O WITH MACRON
      #$0172: Result[i]:= #$d8;  // LATIN CAPITAL LETTER U WITH OGONEK
      #$0141: Result[i]:= #$d9;  // LATIN CAPITAL LETTER L WITH STROKE
      #$015a: Result[i]:= #$da;  // LATIN CAPITAL LETTER S WITH ACUTE
      #$016a: Result[i]:= #$db;  // LATIN CAPITAL LETTER U WITH MACRON
      #$017b: Result[i]:= #$dd;  // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      #$017d: Result[i]:= #$de;  // LATIN CAPITAL LETTER Z WITH CARON
      #$0105: Result[i]:= #$e0;  // LATIN SMALL LETTER A WITH OGONEK
      #$012f: Result[i]:= #$e1;  // LATIN SMALL LETTER I WITH OGONEK
      #$0101: Result[i]:= #$e2;  // LATIN SMALL LETTER A WITH MACRON
      #$0107: Result[i]:= #$e3;  // LATIN SMALL LETTER C WITH ACUTE
      #$0119: Result[i]:= #$e6;  // LATIN SMALL LETTER E WITH OGONEK
      #$0113: Result[i]:= #$e7;  // LATIN SMALL LETTER E WITH MACRON
      #$010d: Result[i]:= #$e8;  // LATIN SMALL LETTER C WITH CARON
      #$017a: Result[i]:= #$ea;  // LATIN SMALL LETTER Z WITH ACUTE
      #$0117: Result[i]:= #$eb;  // LATIN SMALL LETTER E WITH DOT ABOVE
      #$0123: Result[i]:= #$ec;  // LATIN SMALL LETTER G WITH CEDILLA
      #$0137: Result[i]:= #$ed;  // LATIN SMALL LETTER K WITH CEDILLA
      #$012b: Result[i]:= #$ee;  // LATIN SMALL LETTER I WITH MACRON
      #$013c: Result[i]:= #$ef;  // LATIN SMALL LETTER L WITH CEDILLA
      #$0161: Result[i]:= #$f0;  // LATIN SMALL LETTER S WITH CARON
      #$0144: Result[i]:= #$f1;  // LATIN SMALL LETTER N WITH ACUTE
      #$0146: Result[i]:= #$f2;  // LATIN SMALL LETTER N WITH CEDILLA
      #$014d: Result[i]:= #$f4;  // LATIN SMALL LETTER O WITH MACRON
      #$0173: Result[i]:= #$f8;  // LATIN SMALL LETTER U WITH OGONEK
      #$0142: Result[i]:= #$f9;  // LATIN SMALL LETTER L WITH STROKE
      #$015b: Result[i]:= #$fa;  // LATIN SMALL LETTER S WITH ACUTE
      #$016b: Result[i]:= #$fb;  // LATIN SMALL LETTER U WITH MACRON
      #$017c: Result[i]:= #$fd;  // LATIN SMALL LETTER Z WITH DOT ABOVE
      #$017e: Result[i]:= #$fe;  // LATIN SMALL LETTER Z WITH CARON
      #$2019: Result[i]:= #$ff;  // RIGHT SINGLE QUOTATION MARK
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_Iso8859_14(const AStr: WideString): String; // Latin-8
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$1e02: Result[i]:= #$a1;  // LATIN CAPITAL LETTER B WITH DOT ABOVE
      #$1e03: Result[i]:= #$a2;  // LATIN SMALL LETTER B WITH DOT ABOVE
      #$010a: Result[i]:= #$a4;  // LATIN CAPITAL LETTER C WITH DOT ABOVE
      #$010b: Result[i]:= #$a5;  // LATIN SMALL LETTER C WITH DOT ABOVE
      #$1e0a: Result[i]:= #$a6;  // LATIN CAPITAL LETTER D WITH DOT ABOVE
      #$1e80: Result[i]:= #$a8;  // LATIN CAPITAL LETTER W WITH GRAVE
      #$1e82: Result[i]:= #$aa;  // LATIN CAPITAL LETTER W WITH ACUTE
      #$1e0b: Result[i]:= #$ab;  // LATIN SMALL LETTER D WITH DOT ABOVE
      #$1ef2: Result[i]:= #$ac;  // LATIN CAPITAL LETTER Y WITH GRAVE
      #$0178: Result[i]:= #$af;  // LATIN CAPITAL LETTER Y WITH DIAERESIS
      #$1e1e: Result[i]:= #$b0;  // LATIN CAPITAL LETTER F WITH DOT ABOVE
      #$1e1f: Result[i]:= #$b1;  // LATIN SMALL LETTER F WITH DOT ABOVE
      #$0120: Result[i]:= #$b2;  // LATIN CAPITAL LETTER G WITH DOT ABOVE
      #$0121: Result[i]:= #$b3;  // LATIN SMALL LETTER G WITH DOT ABOVE
      #$1e40: Result[i]:= #$b4;  // LATIN CAPITAL LETTER M WITH DOT ABOVE
      #$1e41: Result[i]:= #$b5;  // LATIN SMALL LETTER M WITH DOT ABOVE
      #$1e56: Result[i]:= #$b7;  // LATIN CAPITAL LETTER P WITH DOT ABOVE
      #$1e81: Result[i]:= #$b8;  // LATIN SMALL LETTER W WITH GRAVE
      #$1e57: Result[i]:= #$b9;  // LATIN SMALL LETTER P WITH DOT ABOVE
      #$1e83: Result[i]:= #$ba;  // LATIN SMALL LETTER W WITH ACUTE
      #$1e60: Result[i]:= #$bb;  // LATIN CAPITAL LETTER S WITH DOT ABOVE
      #$1ef3: Result[i]:= #$bc;  // LATIN SMALL LETTER Y WITH GRAVE
      #$1e84: Result[i]:= #$bd;  // LATIN CAPITAL LETTER W WITH DIAERESIS
      #$1e85: Result[i]:= #$be;  // LATIN SMALL LETTER W WITH DIAERESIS
      #$1e61: Result[i]:= #$bf;  // LATIN SMALL LETTER S WITH DOT ABOVE
      #$0174: Result[i]:= #$d0;  // LATIN CAPITAL LETTER W WITH CIRCUMFLEX
      #$1e6a: Result[i]:= #$d7;  // LATIN CAPITAL LETTER T WITH DOT ABOVE
      #$0176: Result[i]:= #$de;  // LATIN CAPITAL LETTER Y WITH CIRCUMFLEX
      #$0175: Result[i]:= #$f0;  // LATIN SMALL LETTER W WITH CIRCUMFLEX
      #$1e6b: Result[i]:= #$f7;  // LATIN SMALL LETTER T WITH DOT ABOVE
      #$0177: Result[i]:= #$fe;  // LATIN SMALL LETTER Y WITH CIRCUMFLEX
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_Iso8859_15(const AStr: WideString): String; // Latin-9
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$20ac: Result[i]:= #$a4;  // EURO SIGN
      #$00a6: Result[i]:= #$a6;  // LATIN CAPITAL LETTER S WITH CARON
      #$0161: Result[i]:= #$a8;  // LATIN SMALL LETTER S WITH CARON
      #$017d: Result[i]:= #$b4;  // LATIN CAPITAL LETTER Z WITH CARON
      #$017e: Result[i]:= #$b8;  // LATIN SMALL LETTER Z WITH CARON
      #$0152: Result[i]:= #$bc;  // LATIN CAPITAL LIGATURE OE
      #$0153: Result[i]:= #$bd;  // LATIN SMALL LIGATURE OE
      #$0178: Result[i]:= #$be;  // LATIN CAPITAL LETTER Y WITH DIAERESIS
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_KOI8_R(const AStr: WideString): String;     // KOI8-R
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$2500: Result[i]:= #$80;  // BOX DRAWINGS LIGHT HORIZONTAL
      #$2502: Result[i]:= #$81;  // BOX DRAWINGS LIGHT VERTICAL
      #$250c: Result[i]:= #$82;  // BOX DRAWINGS LIGHT DOWN AND RIGHT
      #$2510: Result[i]:= #$83;  // BOX DRAWINGS LIGHT DOWN AND LEFT
      #$2514: Result[i]:= #$84;  // BOX DRAWINGS LIGHT UP AND RIGHT
      #$2518: Result[i]:= #$85;  // BOX DRAWINGS LIGHT UP AND LEFT
      #$251c: Result[i]:= #$86;  // BOX DRAWINGS LIGHT VERTICAL AND RIGHT
      #$2524: Result[i]:= #$87;  // BOX DRAWINGS LIGHT VERTICAL AND LEFT
      #$252c: Result[i]:= #$88;  // BOX DRAWINGS LIGHT DOWN AND HORIZONTAL
      #$2534: Result[i]:= #$89;  // BOX DRAWINGS LIGHT UP AND HORIZONTAL
      #$253c: Result[i]:= #$8a;  // BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL
      #$2580: Result[i]:= #$8b;  // UPPER HALF BLOCK
      #$2584: Result[i]:= #$8c;  // LOWER HALF BLOCK
      #$2588: Result[i]:= #$8d;  // FULL BLOCK
      #$258c: Result[i]:= #$8e;  // LEFT HALF BLOCK
      #$2590: Result[i]:= #$8f;  // RIGHT HALF BLOCK
      #$2591: Result[i]:= #$90;  // LIGHT SHADE
      #$2592: Result[i]:= #$91;  // MEDIUM SHADE
      #$2593: Result[i]:= #$92;  // DARK SHADE
      #$2320: Result[i]:= #$93;  // TOP HALF INTEGRAL
      #$25a0: Result[i]:= #$94;  // BLACK SQUARE
      #$2219: Result[i]:= #$95;  // BULLET OPERATOR
      #$221a: Result[i]:= #$96;  // SQUARE ROOT
      #$2248: Result[i]:= #$97;  // ALMOST EQUAL TO
      #$2264: Result[i]:= #$98;  // LESS-THAN OR EQUAL TO
      #$2265: Result[i]:= #$99;  // GREATER-THAN OR EQUAL TO
      #$00a0: Result[i]:= #$9a;  // NO-BREAK SPACE
      #$2321: Result[i]:= #$9b;  // BOTTOM HALF INTEGRAL
      #$00b0: Result[i]:= #$9c;  // DEGREE SIGN
      #$00b2: Result[i]:= #$9d;  // SUPERSCRIPT TWO
      #$00b7: Result[i]:= #$9e;  // MIDDLE DOT
      #$00f7: Result[i]:= #$9f;  // DIVISION SIGN
      #$2550: Result[i]:= #$a0;  // BOX DRAWINGS DOUBLE HORIZONTAL
      #$2551: Result[i]:= #$a1;  // BOX DRAWINGS DOUBLE VERTICAL
      #$2552: Result[i]:= #$a2;  // BOX DRAWINGS DOWN SINGLE AND RIGHT DOUBLE
      #$0451: Result[i]:= #$a3;  // CYRILLIC SMALL LETTER IO
      #$2553: Result[i]:= #$a4;  // BOX DRAWINGS DOWN DOUBLE AND RIGHT SINGLE
      #$2554: Result[i]:= #$a5;  // BOX DRAWINGS DOUBLE DOWN AND RIGHT
      #$2555: Result[i]:= #$a6;  // BOX DRAWINGS DOWN SINGLE AND LEFT DOUBLE
      #$2556: Result[i]:= #$a7;  // BOX DRAWINGS DOWN DOUBLE AND LEFT SINGLE
      #$2557: Result[i]:= #$a8;  // BOX DRAWINGS DOUBLE DOWN AND LEFT
      #$2558: Result[i]:= #$a9;  // BOX DRAWINGS UP SINGLE AND RIGHT DOUBLE
      #$2559: Result[i]:= #$aa;  // BOX DRAWINGS UP DOUBLE AND RIGHT SINGLE
      #$255a: Result[i]:= #$ab;  // BOX DRAWINGS DOUBLE UP AND RIGHT
      #$255b: Result[i]:= #$ac;  // BOX DRAWINGS UP SINGLE AND LEFT DOUBLE
      #$255c: Result[i]:= #$ad;  // BOX DRAWINGS UP DOUBLE AND LEFT SINGLE
      #$255d: Result[i]:= #$ae;  // BOX DRAWINGS DOUBLE UP AND LEFT
      #$255e: Result[i]:= #$af;  // BOX DRAWINGS VERTICAL SINGLE AND RIGHT DOUBLE
      #$255f: Result[i]:= #$b0;  // BOX DRAWINGS VERTICAL DOUBLE AND RIGHT SINGLE
      #$2560: Result[i]:= #$b1;  // BOX DRAWINGS DOUBLE VERTICAL AND RIGHT
      #$2561: Result[i]:= #$b2;  // BOX DRAWINGS VERTICAL SINGLE AND LEFT DOUBLE
      #$0401: Result[i]:= #$b3;  // CYRILLIC CAPITAL LETTER IO
      #$2562: Result[i]:= #$b4;  // BOX DRAWINGS VERTICAL DOUBLE AND LEFT SINGLE
      #$2563: Result[i]:= #$b5;  // BOX DRAWINGS DOUBLE VERTICAL AND LEFT
      #$2564: Result[i]:= #$b6;  // BOX DRAWINGS DOWN SINGLE AND HORIZONTAL DOUBLE
      #$2565: Result[i]:= #$b7;  // BOX DRAWINGS DOWN DOUBLE AND HORIZONTAL SINGLE
      #$2566: Result[i]:= #$b8;  // BOX DRAWINGS DOUBLE DOWN AND HORIZONTAL
      #$2567: Result[i]:= #$b9;  // BOX DRAWINGS UP SINGLE AND HORIZONTAL DOUBLE
      #$2568: Result[i]:= #$ba;  // BOX DRAWINGS UP DOUBLE AND HORIZONTAL SINGLE
      #$2569: Result[i]:= #$bb;  // BOX DRAWINGS DOUBLE UP AND HORIZONTAL
      #$256a: Result[i]:= #$bc;  // BOX DRAWINGS VERTICAL SINGLE AND HORIZONTAL DOUBLE
      #$256b: Result[i]:= #$bd;  // BOX DRAWINGS VERTICAL DOUBLE AND HORIZONTAL SINGLE
      #$256c: Result[i]:= #$be;  // BOX DRAWINGS DOUBLE VERTICAL AND HORIZONTAL
      #$00a9: Result[i]:= #$bf;  // COPYRIGHT SIGN
      #$044e: Result[i]:= #$c0;  // CYRILLIC SMALL LETTER YU
      #$0430: Result[i]:= #$c1;  // CYRILLIC SMALL LETTER A
      #$0431: Result[i]:= #$c2;  // CYRILLIC SMALL LETTER BE
      #$0446: Result[i]:= #$c3;  // CYRILLIC SMALL LETTER TSE
      #$0434: Result[i]:= #$c4;  // CYRILLIC SMALL LETTER DE
      #$0435: Result[i]:= #$c5;  // CYRILLIC SMALL LETTER IE
      #$0444: Result[i]:= #$c6;  // CYRILLIC SMALL LETTER EF
      #$0433: Result[i]:= #$c7;  // CYRILLIC SMALL LETTER GHE
      #$0445: Result[i]:= #$c8;  // CYRILLIC SMALL LETTER HA
      #$0438: Result[i]:= #$c9;  // CYRILLIC SMALL LETTER I
      #$0439: Result[i]:= #$ca;  // CYRILLIC SMALL LETTER SHORT I
      #$043a: Result[i]:= #$cb;  // CYRILLIC SMALL LETTER KA
      #$043b: Result[i]:= #$cc;  // CYRILLIC SMALL LETTER EL
      #$043c: Result[i]:= #$cd;  // CYRILLIC SMALL LETTER EM
      #$043d: Result[i]:= #$ce;  // CYRILLIC SMALL LETTER EN
      #$043e: Result[i]:= #$cf;  // CYRILLIC SMALL LETTER O
      #$043f: Result[i]:= #$d0;  // CYRILLIC SMALL LETTER PE
      #$044f: Result[i]:= #$d1;  // CYRILLIC SMALL LETTER YA
      #$0440: Result[i]:= #$d2;  // CYRILLIC SMALL LETTER ER
      #$0441: Result[i]:= #$d3;  // CYRILLIC SMALL LETTER ES
      #$0442: Result[i]:= #$d4;  // CYRILLIC SMALL LETTER TE
      #$0443: Result[i]:= #$d5;  // CYRILLIC SMALL LETTER U
      #$0436: Result[i]:= #$d6;  // CYRILLIC SMALL LETTER ZHE
      #$0432: Result[i]:= #$d7;  // CYRILLIC SMALL LETTER VE
      #$044c: Result[i]:= #$d8;  // CYRILLIC SMALL LETTER SOFT SIGN
      #$044b: Result[i]:= #$d9;  // CYRILLIC SMALL LETTER YERU
      #$0437: Result[i]:= #$da;  // CYRILLIC SMALL LETTER ZE
      #$0448: Result[i]:= #$db;  // CYRILLIC SMALL LETTER SHA
      #$044d: Result[i]:= #$dc;  // CYRILLIC SMALL LETTER E
      #$0449: Result[i]:= #$dd;  // CYRILLIC SMALL LETTER SHCHA
      #$0447: Result[i]:= #$de;  // CYRILLIC SMALL LETTER CHE
      #$044a: Result[i]:= #$df;  // CYRILLIC SMALL LETTER HARD SIGN
      #$042e: Result[i]:= #$e0;  // CYRILLIC CAPITAL LETTER YU
      #$0410: Result[i]:= #$e1;  // CYRILLIC CAPITAL LETTER A
      #$0411: Result[i]:= #$e2;  // CYRILLIC CAPITAL LETTER BE
      #$0426: Result[i]:= #$e3;  // CYRILLIC CAPITAL LETTER TSE
      #$0414: Result[i]:= #$e4;  // CYRILLIC CAPITAL LETTER DE
      #$0415: Result[i]:= #$e5;  // CYRILLIC CAPITAL LETTER IE
      #$0424: Result[i]:= #$e6;  // CYRILLIC CAPITAL LETTER EF
      #$0413: Result[i]:= #$e7;  // CYRILLIC CAPITAL LETTER GHE
      #$0425: Result[i]:= #$e8;  // CYRILLIC CAPITAL LETTER HA
      #$0418: Result[i]:= #$e9;  // CYRILLIC CAPITAL LETTER I
      #$0419: Result[i]:= #$ea;  // CYRILLIC CAPITAL LETTER SHORT I
      #$041a: Result[i]:= #$eb;  // CYRILLIC CAPITAL LETTER KA
      #$041b: Result[i]:= #$ec;  // CYRILLIC CAPITAL LETTER EL
      #$041c: Result[i]:= #$ed;  // CYRILLIC CAPITAL LETTER EM
      #$041d: Result[i]:= #$ee;  // CYRILLIC CAPITAL LETTER EN
      #$041e: Result[i]:= #$ef;  // CYRILLIC CAPITAL LETTER O
      #$041f: Result[i]:= #$f0;  // CYRILLIC CAPITAL LETTER PE
      #$042f: Result[i]:= #$f1;  // CYRILLIC CAPITAL LETTER YA
      #$0420: Result[i]:= #$f2;  // CYRILLIC CAPITAL LETTER ER
      #$0421: Result[i]:= #$f3;  // CYRILLIC CAPITAL LETTER ES
      #$0422: Result[i]:= #$f4;  // CYRILLIC CAPITAL LETTER TE
      #$0423: Result[i]:= #$f5;  // CYRILLIC CAPITAL LETTER U
      #$0416: Result[i]:= #$f6;  // CYRILLIC CAPITAL LETTER ZHE
      #$0412: Result[i]:= #$f7;  // CYRILLIC CAPITAL LETTER VE
      #$042c: Result[i]:= #$f8;  // CYRILLIC CAPITAL LETTER SOFT SIGN
      #$042b: Result[i]:= #$f9;  // CYRILLIC CAPITAL LETTER YERU
      #$0417: Result[i]:= #$fa;  // CYRILLIC CAPITAL LETTER ZE
      #$0428: Result[i]:= #$fb;  // CYRILLIC CAPITAL LETTER SHA
      #$042d: Result[i]:= #$fc;  // CYRILLIC CAPITAL LETTER E
      #$0429: Result[i]:= #$fd;  // CYRILLIC CAPITAL LETTER SHCHA
      #$0427: Result[i]:= #$fe;  // CYRILLIC CAPITAL LETTER CHE
      #$042a: Result[i]:= #$ff;  // CYRILLIC CAPITAL LETTER HARD SIGN
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_cp10000_MacRoman(const AStr: WideString): String;  // cp10000_MacRoman
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$00c4: Result[i]:= #$80;  // LATIN CAPITAL LETTER A WITH DIAERESIS
      #$00c5: Result[i]:= #$81;  // LATIN CAPITAL LETTER A WITH RING ABOVE
      #$00c7: Result[i]:= #$82;  // LATIN CAPITAL LETTER C WITH CEDILLA
      #$00c9: Result[i]:= #$83;  // LATIN CAPITAL LETTER E WITH ACUTE
      #$00d1: Result[i]:= #$84;  // LATIN CAPITAL LETTER N WITH TILDE
      #$00d6: Result[i]:= #$85;  // LATIN CAPITAL LETTER O WITH DIAERESIS
      #$00dc: Result[i]:= #$86;  // LATIN CAPITAL LETTER U WITH DIAERESIS
      #$00e1: Result[i]:= #$87;  // LATIN SMALL LETTER A WITH ACUTE
      #$00e0: Result[i]:= #$88;  // LATIN SMALL LETTER A WITH GRAVE
      #$00e2: Result[i]:= #$89;  // LATIN SMALL LETTER A WITH CIRCUMFLEX
      #$00e4: Result[i]:= #$8a;  // LATIN SMALL LETTER A WITH DIAERESIS
      #$00e3: Result[i]:= #$8b;  // LATIN SMALL LETTER A WITH TILDE
      #$00e5: Result[i]:= #$8c;  // LATIN SMALL LETTER A WITH RING ABOVE
      #$00e7: Result[i]:= #$8d;  // LATIN SMALL LETTER C WITH CEDILLA
      #$00e9: Result[i]:= #$8e;  // LATIN SMALL LETTER E WITH ACUTE
      #$00e8: Result[i]:= #$8f;  // LATIN SMALL LETTER E WITH GRAVE
      #$00ea: Result[i]:= #$90;  // LATIN SMALL LETTER E WITH CIRCUMFLEX
      #$00eb: Result[i]:= #$91;  // LATIN SMALL LETTER E WITH DIAERESIS
      #$00ed: Result[i]:= #$92;  // LATIN SMALL LETTER I WITH ACUTE
      #$00ec: Result[i]:= #$93;  // LATIN SMALL LETTER I WITH GRAVE
      #$00ee: Result[i]:= #$94;  // LATIN SMALL LETTER I WITH CIRCUMFLEX
      #$00ef: Result[i]:= #$95;  // LATIN SMALL LETTER I WITH DIAERESIS
      #$00f1: Result[i]:= #$96;  // LATIN SMALL LETTER N WITH TILDE
      #$00f3: Result[i]:= #$97;  // LATIN SMALL LETTER O WITH ACUTE
      #$00f2: Result[i]:= #$98;  // LATIN SMALL LETTER O WITH GRAVE
      #$00f4: Result[i]:= #$99;  // LATIN SMALL LETTER O WITH CIRCUMFLEX
      #$00f6: Result[i]:= #$9a;  // LATIN SMALL LETTER O WITH DIAERESIS
      #$00f5: Result[i]:= #$9b;  // LATIN SMALL LETTER O WITH TILDE
      #$00fa: Result[i]:= #$9c;  // LATIN SMALL LETTER U WITH ACUTE
      #$00f9: Result[i]:= #$9d;  // LATIN SMALL LETTER U WITH GRAVE
      #$00fb: Result[i]:= #$9e;  // LATIN SMALL LETTER U WITH CIRCUMFLEX
      #$00fc: Result[i]:= #$9f;  // LATIN SMALL LETTER U WITH DIAERESIS
      #$2020: Result[i]:= #$a0;  // DAGGER
      #$00b0: Result[i]:= #$a1;  // DEGREE SIGN
      #$00a7: Result[i]:= #$a4;  // SECTION SIGN
      #$2022: Result[i]:= #$a5;  // BULLET
      #$00b6: Result[i]:= #$a6;  // PILCROW SIGN
      #$00df: Result[i]:= #$a7;  // LATIN SMALL LETTER SHARP S
      #$00ae: Result[i]:= #$a8;  // REGISTERED SIGN
      #$2122: Result[i]:= #$aa;  // TRADE MARK SIGN
      #$00b4: Result[i]:= #$ab;  // ACUTE ACCENT
      #$00a8: Result[i]:= #$ac;  // DIAERESIS
      #$2260: Result[i]:= #$ad;  // NOT EQUAL TO
      #$00c6: Result[i]:= #$ae;  // LATIN CAPITAL LIGATURE AE
      #$00d8: Result[i]:= #$af;  // LATIN CAPITAL LETTER O WITH STROKE
      #$221e: Result[i]:= #$b0;  // INFINITY
      #$2264: Result[i]:= #$b2;  // LESS-THAN OR EQUAL TO
      #$2265: Result[i]:= #$b3;  // GREATER-THAN OR EQUAL TO
      #$00a5: Result[i]:= #$b4;  // YEN SIGN
      #$2202: Result[i]:= #$b6;  // PARTIAL DIFFERENTIAL
      #$2211: Result[i]:= #$b7;  // N-ARY SUMMATION
      #$220f: Result[i]:= #$b8;  // N-ARY PRODUCT
      #$03c0: Result[i]:= #$b9;  // GREEK SMALL LETTER PI
      #$222b: Result[i]:= #$ba;  // INTEGRAL
      #$00aa: Result[i]:= #$bb;  // FEMININE ORDINAL INDICATOR
      #$00ba: Result[i]:= #$bc;  // MASCULINE ORDINAL INDICATOR
      #$2126: Result[i]:= #$bd;  // OHM SIGN
      #$00e6: Result[i]:= #$be;  // LATIN SMALL LIGATURE AE
      #$00f8: Result[i]:= #$bf;  // LATIN SMALL LETTER O WITH STROKE
      #$00bf: Result[i]:= #$c0;  // INVERTED QUESTION MARK
      #$00a1: Result[i]:= #$c1;  // INVERTED EXCLAMATION MARK
      #$00ac: Result[i]:= #$c2;  // NOT SIGN
      #$221a: Result[i]:= #$c3;  // SQUARE ROOT
      #$0192: Result[i]:= #$c4;  // LATIN SMALL LETTER F WITH HOOK
      #$2248: Result[i]:= #$c5;  // ALMOST EQUAL TO
      #$2206: Result[i]:= #$c6;  // INCREMENT
      #$00ab: Result[i]:= #$c7;  // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      #$00bb: Result[i]:= #$c8;  // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      #$2026: Result[i]:= #$c9;  // HORIZONTAL ELLIPSIS
      #$00a0: Result[i]:= #$ca;  // NO-BREAK SPACE
      #$00c0: Result[i]:= #$cb;  // LATIN CAPITAL LETTER A WITH GRAVE
      #$00c3: Result[i]:= #$cc;  // LATIN CAPITAL LETTER A WITH TILDE
      #$00d5: Result[i]:= #$cd;  // LATIN CAPITAL LETTER O WITH TILDE
      #$0152: Result[i]:= #$ce;  // LATIN CAPITAL LIGATURE OE
      #$0153: Result[i]:= #$cf;  // LATIN SMALL LIGATURE OE
      #$2013: Result[i]:= #$d0;  // EN DASH
      #$2014: Result[i]:= #$d1;  // EM DASH
      #$201c: Result[i]:= #$d2;  // LEFT DOUBLE QUOTATION MARK
      #$201d: Result[i]:= #$d3;  // RIGHT DOUBLE QUOTATION MARK
      #$2018: Result[i]:= #$d4;  // LEFT SINGLE QUOTATION MARK
      #$2019: Result[i]:= #$d5;  // RIGHT SINGLE QUOTATION MARK
      #$00f7: Result[i]:= #$d6;  // DIVISION SIGN
      #$25ca: Result[i]:= #$d7;  // LOZENGE
      #$00ff: Result[i]:= #$d8;  // LATIN SMALL LETTER Y WITH DIAERESIS
      #$0178: Result[i]:= #$d9;  // LATIN CAPITAL LETTER Y WITH DIAERESIS
      #$2044: Result[i]:= #$da;  // FRACTION SLASH
      #$00a4: Result[i]:= #$db;  // CURRENCY SIGN
      #$2039: Result[i]:= #$dc;  // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      #$203a: Result[i]:= #$dd;  // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      #$fb01: Result[i]:= #$de;  // LATIN SMALL LIGATURE FI
      #$fb02: Result[i]:= #$df;  // LATIN SMALL LIGATURE FL
      #$2021: Result[i]:= #$e0;  // DOUBLE DAGGER
      #$00b7: Result[i]:= #$e1;  // MIDDLE DOT
      #$201a: Result[i]:= #$e2;  // SINGLE LOW-9 QUOTATION MARK
      #$201e: Result[i]:= #$e3;  // DOUBLE LOW-9 QUOTATION MARK
      #$2030: Result[i]:= #$e4;  // PER MILLE SIGN
      #$00c2: Result[i]:= #$e5;  // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      #$00ca: Result[i]:= #$e6;  // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      #$00c1: Result[i]:= #$e7;  // LATIN CAPITAL LETTER A WITH ACUTE
      #$00cb: Result[i]:= #$e8;  // LATIN CAPITAL LETTER E WITH DIAERESIS
      #$00c8: Result[i]:= #$e9;  // LATIN CAPITAL LETTER E WITH GRAVE
      #$00cd: Result[i]:= #$ea;  // LATIN CAPITAL LETTER I WITH ACUTE
      #$00ce: Result[i]:= #$eb;  // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      #$00cf: Result[i]:= #$ec;  // LATIN CAPITAL LETTER I WITH DIAERESIS
      #$00cc: Result[i]:= #$ed;  // LATIN CAPITAL LETTER I WITH GRAVE
      #$00d3: Result[i]:= #$ee;  // LATIN CAPITAL LETTER O WITH ACUTE
      #$00d4: Result[i]:= #$ef;  // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      #$00d2: Result[i]:= #$f1;  // LATIN CAPITAL LETTER O WITH GRAVE
      #$00da: Result[i]:= #$f2;  // LATIN CAPITAL LETTER U WITH ACUTE
      #$00db: Result[i]:= #$f3;  // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      #$00d9: Result[i]:= #$f4;  // LATIN CAPITAL LETTER U WITH GRAVE
      #$0131: Result[i]:= #$f5;  // LATIN SMALL LETTER DOTLESS I
      #$02c6: Result[i]:= #$f6;  // MODIFIER LETTER CIRCUMFLEX ACCENT
      #$02dc: Result[i]:= #$f7;  // SMALL TILDE
      #$00af: Result[i]:= #$f8;  // MACRON
      #$02d8: Result[i]:= #$f9;  // BREVE
      #$02d9: Result[i]:= #$fa;  // DOT ABOVE
      #$02da: Result[i]:= #$fb;  // RING ABOVE
      #$00b8: Result[i]:= #$fc;  // CEDILLA
      #$02dd: Result[i]:= #$fd;  // DOUBLE ACUTE ACCENT
      #$02db: Result[i]:= #$fe;  // OGONEK
      #$02c7: Result[i]:= #$ff;  // CARON
      {
      #$f0: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid cp10000_MacRoman sequence "%s"',[AStr]);
      }
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_cp1250(const AStr: WideString): String;     // Windows-1250
const
  sInvalidWindows1250Sequence = 'Invalid Windows-1250 sequence "%s"';
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      // NOT USED
      #$80,#$81,#$83,#$88,#$90,#$98:
        Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1250Sequence,[AStr]);
      #$201a: Result[i]:= #$82;  // SINGLE LOW-9 QUOTATION MARK
      #$201e: Result[i]:= #$84;  // DOUBLE LOW-9 QUOTATION MARK
      #$2026: Result[i]:= #$85;  // HORIZONTAL ELLIPSIS
      #$2020: Result[i]:= #$86;  // DAGGER
      #$2021: Result[i]:= #$87;  // DOUBLE DAGGER
      #$2030: Result[i]:= #$89;  // PER MILLE SIGN
      #$0160: Result[i]:= #$8a;  // LATIN CAPITAL LETTER S WITH CARON
      #$2039: Result[i]:= #$8b;  // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      #$015a: Result[i]:= #$8c;  // LATIN CAPITAL LETTER S WITH ACUTE
      #$0164: Result[i]:= #$8d;  // LATIN CAPITAL LETTER T WITH CARON
      #$017d: Result[i]:= #$8e;  // LATIN CAPITAL LETTER Z WITH CARON
      #$0179: Result[i]:= #$8f;  // LATIN CAPITAL LETTER Z WITH ACUTE
      #$2018: Result[i]:= #$91;  // LEFT SINGLE QUOTATION MARK
      #$2019: Result[i]:= #$92;  // RIGHT SINGLE QUOTATION MARK
      #$201c: Result[i]:= #$93;  // LEFT DOUBLE QUOTATION MARK
      #$201d: Result[i]:= #$94;  // RIGHT DOUBLE QUOTATION MARK
      #$2022: Result[i]:= #$95;  // BULLET
      #$2013: Result[i]:= #$96;  // EN-DASH
      #$2014: Result[i]:= #$97;  // EM-DASH
      #$2122: Result[i]:= #$99;  // TRADE MARK SIGN
      #$0161: Result[i]:= #$9a;  // LATIN SMALL LETTER S WITH CARON
      #$203a: Result[i]:= #$9b;  // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      #$015b: Result[i]:= #$9c;  // LATIN SMALL LETTER S WITH ACUTE
      #$0165: Result[i]:= #$9d;  // LATIN SMALL LETTER T WITH CARON
      #$017e: Result[i]:= #$9e;  // LATIN SMALL LETTER Z WITH CARON
      #$017a: Result[i]:= #$9f;  // LATIN SMALL LETTER Z WITH ACUTE
      #$00a0: Result[i]:= #$a0;  // NO-BREAK SPACE
      #$02c7: Result[i]:= #$a1;  // CARON
      #$02d8: Result[i]:= #$a2;  // BREVE
      #$0141: Result[i]:= #$a3;  // LATIN CAPITAL LETTER L WITH STROKE
      #$00a4: Result[i]:= #$a4;  // CURRENCY SIGN
      #$0104: Result[i]:= #$a5;  // LATIN CAPITAL LETTER A WITH OGONEK
      #$00a6: Result[i]:= #$a6;  // BROKEN BAR
      #$00a7: Result[i]:= #$a7;  // SECTION SIGN
      #$00a8: Result[i]:= #$a8;  // DIAERESIS
      #$00a9: Result[i]:= #$a9;  // COPYRIGHT SIGN
      #$015e: Result[i]:= #$aa;  // LATIN CAPITAL LETTER S WITH CEDILLA
      #$00ab: Result[i]:= #$ab;  // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      #$00ac: Result[i]:= #$ac;  // NOT SIGN
      #$00ad: Result[i]:= #$ad;  // SOFT HYPHEN
      #$00ae: Result[i]:= #$ae;  // REGISTERED SIGN
      #$017b: Result[i]:= #$af;  // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      #$00b0: Result[i]:= #$b0;  // DEGREE SIGN
      #$00b1: Result[i]:= #$b1;  // PLUS-MINUS SIGN
      #$02db: Result[i]:= #$b2;  // OGONEK
      #$0142: Result[i]:= #$b3;  // LATIN SMALL LETTER L WITH STROKE
      #$00b4: Result[i]:= #$b4;  // ACUTE ACCENT
      #$00b5: Result[i]:= #$b5;  // MIKRO SIGN
      #$00b6: Result[i]:= #$b6;  // PILCROW SIGN
      #$00b7: Result[i]:= #$b7;  // MIDDLE DOT
      #$00b8: Result[i]:= #$b8;  // CEDILLA
      #$0105: Result[i]:= #$b9;  // LATIN SMALL LETTER A WITH OGONEK
      #$015f: Result[i]:= #$ba;  // LATIN SMALL LETTER S WITH CEDILLA
      #$00bb: Result[i]:= #$bb;  // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      #$013d: Result[i]:= #$bc;  // LATIN CAPITAL LETTER L WITH CARON
      #$02dd: Result[i]:= #$bd;  // DOUBLE ACUTE ACCENT
      #$013e: Result[i]:= #$be;  // LATIN SMALL LETTER L WITH CARON
      #$017c: Result[i]:= #$bf;  // LATIN SMALL LETTER Z WITH DOT ABOVE
      #$0154: Result[i]:= #$c0;  // LATIN CAPITAL LETTER R WITH ACUTE
      #$00c1: Result[i]:= #$c1;  // LATIN CAPITAL LETTER A WITH ACUTE
      #$00c2: Result[i]:= #$c2;  // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      #$0102: Result[i]:= #$c3;  // LATIN CAPITAL LETTER A WITH BREVE
      #$00c4: Result[i]:= #$c4;  // LATIN CAPITAL LETTER A WITH DIAERESIS
      #$0139: Result[i]:= #$c5;  // LATIN CAPITAL LETTER L WITH ACUTE
      #$0106: Result[i]:= #$c6;  // LATIN CAPITAL LETTER C WITH ACUTE
      #$00c7: Result[i]:= #$c7;  // LATIN CAPITAL LETTER C WITH CEDILLA
      #$010c: Result[i]:= #$c8;  // LATIN CAPITAL LETTER C WITH CARON
      #$00c9: Result[i]:= #$c9;  // LATIN CAPITAL LETTER E WITH ACUTE
      #$0118: Result[i]:= #$ca;  // LATIN CAPITAL LETTER E WITH OGONEK
      #$00cb: Result[i]:= #$cb;  // LATIN CAPITAL LETTER E WITH DIAERESIS
      #$011a: Result[i]:= #$cc;  // LATIN CAPITAL LETTER E WITH CARON
      #$00cd: Result[i]:= #$cd;  // LATIN CAPITAL LETTER I WITH ACUTE
      #$00ce: Result[i]:= #$ce;  // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      #$010e: Result[i]:= #$cf;  // LATIN CAPITAL LETTER D WITH CARON
      #$0110: Result[i]:= #$d0;  // LATIN CAPITAL LETTER D WITH STROKE
      #$0143: Result[i]:= #$d1;  // LATIN CAPITAL LETTER N WITH ACUTE
      #$0147: Result[i]:= #$d2;  // LATIN CAPITAL LETTER N WITH CARON
      #$00d3: Result[i]:= #$d3;  // LATIN CAPITAL LETTER O WITH ACUTE
      #$00d4: Result[i]:= #$d4;  // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      #$0150: Result[i]:= #$d5;  // LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
      #$00d6: Result[i]:= #$d6;  // LATIN CAPITAL LETTER O WITH DIAERESIS
      #$00d7: Result[i]:= #$d7;  // MULTIPLICATION SIGN
      #$0158: Result[i]:= #$d8;  // LATIN CAPITAL LETTER R WITH CARON
      #$016e: Result[i]:= #$d9;  // LATIN CAPITAL LETTER U WITH RING ABOVE
      #$00da: Result[i]:= #$da;  // LATIN CAPITAL LETTER U WITH ACUTE
      #$0170: Result[i]:= #$db;  // LATIN CAPITAL LETTER U WITH WITH DOUBLE ACUTE
      #$00dc: Result[i]:= #$dc;  // LATIN CAPITAL LETTER U WITH DIAERESIS
      #$00dd: Result[i]:= #$dd;  // LATIN CAPITAL LETTER Y WITH ACUTE
      #$0162: Result[i]:= #$de;  // LATIN CAPITAL LETTER T WITH CEDILLA
      #$00df: Result[i]:= #$df;  // LATIN SMALL LETTER SHARP S
      #$0155: Result[i]:= #$e0;  // LATIN SMALL LETTER R WITH ACUTE
      #$00e1: Result[i]:= #$e1;  // LATIN SMALL LETTER A WITH ACUTE
      #$00e2: Result[i]:= #$e2;  // LATIN SMALL LETTER A WITH CIRCUMFLEX
      #$0103: Result[i]:= #$e3;  // LATIN SMALL LETTER A WITH BREVE
      #$00e4: Result[i]:= #$e4;  // LATIN SMALL LETTER A WITH DIAERESIS
      #$013a: Result[i]:= #$e5;  // LATIN SMALL LETTER L WITH ACUTE
      #$0107: Result[i]:= #$e6;  // LATIN SMALL LETTER C WITH ACUTE
      #$00e7: Result[i]:= #$e7;  // LATIN SMALL LETTER C WITH CEDILLA
      #$010d: Result[i]:= #$e8;  // LATIN SMALL LETTER C WITH CARON 100D
      #$00e9: Result[i]:= #$e9;  // LATIN SMALL LETTER E WITH ACUTE
      #$0119: Result[i]:= #$ea;  // LATIN SMALL LETTER E WITH OGONEK
      #$00eb: Result[i]:= #$eb;  // LATIN SMALL LETTER E WITH DIAERESIS
      #$011b: Result[i]:= #$ec;  // LATIN SMALL LETTER E WITH CARON
      #$00ed: Result[i]:= #$ed;  // LATIN SMALL LETTER I WITH ACUTE
      #$00ee: Result[i]:= #$ee;  // LATIN SMALL LETTER I WITH CIRCUMFLEX
      #$010f: Result[i]:= #$ef;  // LATIN SMALL LETTER D WITH CARON
      #$0111: Result[i]:= #$f0;  // LATIN SMALL LETTER D WITH STROKE
      #$0144: Result[i]:= #$f1;  // LATIN SMALL LETTER N WITH ACUTE
      #$0148: Result[i]:= #$f2;  // LATIN SMALL LETTER N WITH CARON
      #$00f3: Result[i]:= #$f3;  // LATIN SMALL LETTER O WITH ACUTE
      #$00f4: Result[i]:= #$f4;  // LATIN SMALL LETTER O WITH CIRCUMFLEX
      #$0151: Result[i]:= #$f5;  // LATIN SMALL LETTER O WITH DOUBLE ACUTE
      #$00f6: Result[i]:= #$f6;  // LATIN SMALL LETTER O WITH DIAERESIS
      #$00f7: Result[i]:= #$f7;  // DIVISION SIGN
      #$0159: Result[i]:= #$f8;  // LATIN SMALL LETTER R WITH CARON
      #$016f: Result[i]:= #$f9;  // LATIN SMALL LETTER U WITH RING ABOVE
      #$00fa: Result[i]:= #$fa;  // LATIN SMALL LETTER U WITH ACUTE
      #$0171: Result[i]:= #$fb;  // LATIN SMALL LETTER U WITH WITH DOUBLE ACUTE
      #$00fc: Result[i]:= #$fc;  // LATIN SMALL LETTER U WITH DIAERESIS
      #$00fd: Result[i]:= #$fd;  // LATIN SMALL LETTER Y WITH ACUTE
      #$0163: Result[i]:= #$fe;  // LATIN SMALL LETTER T WITH CEDILLA
      #$02d9: Result[i]:= #$ff;  // DOT ABOVE
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_cp1251(const AStr: WideString): String;     // Windows-1251
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$0402: Result[i]:= #$80;  // CYRILLIC CAPITAL LETTER DJE
      #$0403: Result[i]:= #$81;  // CYRILLIC CAPITAL LETTER GJE
      #$201a: Result[i]:= #$82;  // SINGLE LOW-9 QUOTATION MARK
      #$0453: Result[i]:= #$83;  // CYRILLIC SMALL LETTER GJE
      #$201e: Result[i]:= #$84;  // DOUBLE LOW-9 QUOTATION MARK
      #$2026: Result[i]:= #$85;  // HORIZONTAL ELLIPSIS
      #$2020: Result[i]:= #$86;  // DAGGER
      #$2021: Result[i]:= #$87;  // DOUBLE DAGGER
      #$20ac: Result[i]:= #$88;  // EURO SIGN
      #$2030: Result[i]:= #$89;  // PER MILLE SIGN
      #$0409: Result[i]:= #$8a;  // CYRILLIC CAPITAL LETTER LJE
      #$2039: Result[i]:= #$8b;  // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      #$040a: Result[i]:= #$8c;  // CYRILLIC CAPITAL LETTER NJE
      #$040c: Result[i]:= #$8d;  // CYRILLIC CAPITAL LETTER KJE
      #$040b: Result[i]:= #$8e;  // CYRILLIC CAPITAL LETTER TSHE
      #$040f: Result[i]:= #$8f;  // CYRILLIC CAPITAL LETTER DZHE
      #$0452: Result[i]:= #$90;  // CYRILLIC SMALL LETTER DJE
      #$2018: Result[i]:= #$91;  // LEFT SINGLE QUOTATION MARK
      #$2019: Result[i]:= #$92;  // RIGHT SINGLE QUOTATION MARK
      #$201c: Result[i]:= #$93;  // LEFT DOUBLE QUOTATION MARK
      #$201d: Result[i]:= #$94;  // RIGHT DOUBLE QUOTATION MARK
      #$2022: Result[i]:= #$95;  // BULLET
      #$2013: Result[i]:= #$96;  // EN DASH
      #$2014: Result[i]:= #$97;  // EM DASH
      #$2122: Result[i]:= #$99;  // TRADE MARK SIGN
      #$0459: Result[i]:= #$9a;  // CYRILLIC SMALL LETTER LJE
      #$203a: Result[i]:= #$9b;  // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      #$045a: Result[i]:= #$9c;  // CYRILLIC SMALL LETTER NJE
      #$045c: Result[i]:= #$9d;  // CYRILLIC SMALL LETTER KJE
      #$045b: Result[i]:= #$9e;  // CYRILLIC SMALL LETTER TSHE
      #$045f: Result[i]:= #$9f;  // CYRILLIC SMALL LETTER DZHE
      #$00a0: Result[i]:= #$a0;  // NO-BREAK SPACE
      #$040e: Result[i]:= #$a1;  // CYRILLIC CAPITAL LETTER SHORT U
      #$045e: Result[i]:= #$a2;  // CYRILLIC SMALL LETTER SHORT U
      #$0408: Result[i]:= #$a3;  // CYRILLIC CAPITAL LETTER JE
      #$00a4: Result[i]:= #$a4;  // CURRENCY SIGN
      #$0490: Result[i]:= #$a5;  // CYRILLIC CAPITAL LETTER GHE WITH UPTURN
      #$0401: Result[i]:= #$a8;  // CYRILLIC CAPITAL LETTER IO
      #$0404: Result[i]:= #$aa;  // CYRILLIC CAPITAL LETTER UKRAINIAN IE
      #$0407: Result[i]:= #$af;  // CYRILLIC CAPITAL LETTER YI
      #$0406: Result[i]:= #$b2;  // CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
      #$0456: Result[i]:= #$b3;  // CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
      #$0491: Result[i]:= #$b4;  // CYRILLIC SMALL LETTER GHE WITH UPTURN
      #$0451: Result[i]:= #$b8;  // CYRILLIC SMALL LETTER IO
      #$2116: Result[i]:= #$b9;  // NUMERO SIGN
      #$0454: Result[i]:= #$ba;  // CYRILLIC SMALL LETTER UKRAINIAN IE
      #$0458: Result[i]:= #$bc;  // CYRILLIC SMALL LETTER JE
      #$0405: Result[i]:= #$bd;  // CYRILLIC CAPITAL LETTER DZE
      #$0455: Result[i]:= #$be;  // CYRILLIC SMALL LETTER DZE
      #$0457: Result[i]:= #$bf;  // CYRILLIC SMALL LETTER YI
      WideChar($c0 + $350)..WideChar($ff + $350):
        Result[i]:= Char(Word(AStr[i]) - $350);
      {
      $98: Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt('Invalid cp1251 sequence "%s"',[AStr]);
      }
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

function WSTo_cp1252(const AStr: WideString): String;     // Windows-1251
const
  sInvalidWindows1252Sequence = 'Invalid Windows-1252 sequence "%s"';
var
  i, len: Integer;
begin
  len:= Length(AStr);
  SetLength(Result, len);
  for i:= 1 to len do begin
    case AStr[i] of
      #$20AC: Result[i]:= #$80; //EUROSIGN
      #$201A: Result[i]:= #$82; //SINGLE LOW-9 QUOTATION MARK
      #$0192: Result[i]:= #$83; //ATIN SMALL LETTER F WITH HOOK
      #$201E: Result[i]:= #$84; //DOUBLE LOW-9 QUOTATION MARK
      #$2026: Result[i]:= #$85; //HORIZONTAL ELLIPSIS
      #$2020: Result[i]:= #$86; //DAGGER
      #$2021: Result[i]:= #$87; //DOUBLE DAGGER
      #$02C6: Result[i]:= #$88; //MODIFIER LETTER CIRCUMFLEX ACCENT
      #$2030: Result[i]:= #$89; //PER MILLE SIGN
      #$0160: Result[i]:= #$8A; //LATIN CAPITAL LETTER S WITH CARON
      #$2039: Result[i]:= #$8B; //SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      #$0152: Result[i]:= #$8C; //LATIN CAPITAL LIGATURE OE
      #$017D: Result[i]:= #$8E; //LATIN CAPITAL LETTER Z WITH CARON
      #$2018: Result[i]:= #$91; //LEFT SINGLE QUOTATION MARK
      #$2019: Result[i]:= #$92; //RIGHT SINGLE QUOTATION MARK
      #$201C: Result[i]:= #$93; //LEFT DOUBLE QUOTATION MARK
      #$201D: Result[i]:= #$94; //RIGHT DOUBLE QUOTATION MARK
      #$2022: Result[i]:= #$95; //BULLET
      #$2013: Result[i]:= #$96; //EN DASH
      #$2014: Result[i]:= #$97; //EM DASH
      #$02DC: Result[i]:= #$98; //SMALL TILDE
      #$2122: Result[i]:= #$99; //TRADE MARK SIGN
      #$0161: Result[i]:= #$9A; //LATIN SMALL LETTER S WITH CARON
      #$203A: Result[i]:= #$9B; //SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      #$0153: Result[i]:= #$9C; //LATIN SMALL LIGATURE OE
      #$017E: Result[i]:= #$9E; //LATIN SMALL LETTER Z WITH CARON
      #$0178: Result[i]:= #$9F; //LATIN CAPITAL LETTER Y WITH D
      {
      $81 : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      $8D : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      $8F : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      $90 : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      $9D : Result[i]:= UCHAR_INVALID_CODE; // raise EConvertError.CreateFmt(sInvalidWindows1252Sequence,[AStr]);
      }
    else
      Byte(Result[i]):= Byte(AStr[i]);
    end;
  end;
end;

end.
