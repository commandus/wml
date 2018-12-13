unit
  xmlparse;
(*##*)
(*******************************************************************************
*                                                                             *
*   x  m  l  p  a  r  s  e                                                     *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language parser                                           *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 19 2001                                                 *
*   Last fix     : Jul 29 2001                                                *
*   Lines        : 1827                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)
{$DEFINE GENXML}
interface
uses
  Classes, Windows, SysUtils, Contnrs, Controls, ComCtrls,
  customxml, xmlsupported, jclUnicode,
{$IFDEF GENXML}
  generalxml,
{$ENDIF}
  ImgList;

type
  TParsersOptionSet = set of (poNone);

  TwmlpString = WideString;
  TwmlpPChar = PWideChar;

  TToken = (etEnd, etPCData, etxmlTag, etComment, etssScript, etXML, etDocType);
  // compatible with litgen error code (-1, 0, 1) by shift (increment)
  TReportLevel = (rlHint = 0, rlError = 1, rlWarning = 2, rlSearch = 3, rlInternal = 4, rlFinishThread = 5);
  // rlFinishThread used by external procedures to inform that element was parsed successefully
{
resourcestring
  INFOMSG_HINT = 'Hint';
  INFOMSG_WARNING = 'Warning';
  INFOMSG_ERROR = 'Error';
  INFOMSG_SEARCH = 'Search';
}
const
  ReportLevelStr: array[TReportLevel] of string[8] = (
    'Hint', 'Error', 'Warning', 'Search', 'Internal', 'Finished');

type

  TCaseSensitive = (csNone, csUppercase, csLowercase);

  TReportEvent = procedure (ALevel: TReportLevel; AxmlElement: TxmlElement;
    const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar; var AContinueParse: Boolean;
      AEnv: Pointer) of object;

  TOnProcessTemplateAttributesEvent = function (AxmlElement: TxmlElement;
    const AAttribute, AValue: String): Boolean of object;
    // used in finfo
  TOnShowSourceEvent = procedure (ANo: Integer; const ADesc: String; AxmlElement: TxmlElement) of object;
  TSourceKind = (skNone, skPchar, skStrings);
  TNextTokenProc = procedure of object;

  // used in wml parser, called to process template in loader
  TOnProcessTemplateEvent = procedure(Sender: TObject; var ATemplate: WideString) of object;

  // TOnButtonClick = procedure (Sender: TObject) of object;
  // TNotifyEvent

  TOnElementChange = procedure (ANewElement: TxmlElement) of object;

  TxmlParser = class(TPersistent)
  private
    FIsStringsOrPChar: TSourceKind;
    FSourcePtrStart: TwmlpPChar;
    FSourceStrings: TStrings;
    FWhere,           // x- line number y- char position
    FWhereTagStart,
    FWhereTagFinish,
    FSourceStringsXY: TPoint;
    FSourcePtr: TwmlpPChar;
    FTokenString: TwmlpString;
    FToken: TToken;
    FCaseSensitive: TCaseSensitive;
    FOnReport: TReportEvent;
    FOnProcessTemplateAttributes: TOnProcessTemplateAttributesEvent;
    FCompiledXMLClass: TClass; // class of compiled source: TwmlElement
    FStopAtTerminalElement: TxmlElementClass;
    function GetText: TwmlpString;
    procedure SetText(const NewString: TwmlpString);
    function GetStrings: TStrings;
    procedure SetStrings(AStrings: TStrings);
    procedure StartParse(AxmlElement: TxmlElement);
  protected
    NextToken: TNextTokenProc;
    procedure NextTokenPChar;
    procedure NextTokenStrings;
    function ParseDocType(const ATokenStr: WideString; var ACompiledDocTypeVer: String): String;
  public
    StripHTTPHeader: Boolean; { set StripHTTPHeader before assign Text or Lines property }
    constructor Create;
    destructor Destroy; override;
    function Parse2xml(AxmlElement: TxmlElement; AEnv: Pointer): Boolean;  // set CompiledXMLClass
    property CompiledXMLClass: TClass read FCompiledXMLClass write FCompiledXMLClass;
  published
    property Text: TwmlpString read GetText write SetText;
    property Lines: TStrings read GetStrings write SetStrings;
    property CaseSensitive: TCaseSensitive read FCaseSensitive write FCaseSensitive;
    property StopAtTerminalElement: TxmlElementClass read FStopAtTerminalElement write FStopAtTerminalElement; // set element to stop compiling. Default Nil - non-stop
    property OnReport: TReportEvent read FOnReport write FOnReport;
    property OnProcessTemplateAttributes: TOnProcessTemplateAttributesEvent read FOnProcessTemplateAttributes write FOnProcessTemplateAttributes;
  end;

// compile text
function xmlCompileText(const ASrc: TwmlpString; AReportEvent: TReportEvent; AOnProcessTemplateAttributesEvent: TOnProcessTemplateAttributesEvent;
  ATreeViewElements: TTreeView; AResultElement: TxmlElement; ADefaultCompiledXMLClass: TClass;
  AStopAtTerminalElement: TxmlElementClass = Nil; AEnv: Pointer = Nil): TClass;

procedure NestedElements2ToolButtons(AxmlElement: TxmlElement; AToolBar: TToolBar;
  AButtonNewClick: TNotifyEvent);

function AddxmlElement2TreeNode(AxmlElement: TxmlElement; ATreeNode: TTreeNode): Boolean;

function AddxmlElement2Panel(AxmlElement: TxmlElement; APanel: TWinControl;
  AButtonImages: TCustomImageList;
  AOnElementChange: TOnElementChange;
  AOnSelectClick: TNotifyEvent;
  AToolButtonNewClick: TNotifyEvent): Boolean;

function InsertxmlElement2Panel(AxmlElement: TxmlElement; ATopElement: TWinControl;
  AButtonImages: TCustomImageList;
  AOnElementChange: TOnElementChange; AToolButtonNewClick: TNotifyEvent): Boolean;

// search position of attribute position
function SearchAttributePosition(const ATag, AAttribute: TwmlpString; AValueOnly: Boolean;
  var AStartPos, ALen: Integer; var EQSignRequried: Boolean): Boolean;

function Valid_WML_N_ScriptURL(AUri: String): Boolean;

implementation

uses
  StdCtrls,
  util1, util_xml, cpcoll, wml, oebdoc, oebpkg, xhtml, EMemo;

resourcestring
  WMLERR_INTERNALERROR                = 'Parser internal error %s';
  WMLERR_INVALID_ATTRIBUTE            = 'Invalid attribute "%s" of <%s> element';
  WMLERR_ATTRIBUTE_ISNT_NUMBER        = 'Attribute "%s" of <%s> element is not a number';
  WMLERR_ATTRIBUTE_ISNT_URL           = 'Attribute "%s" of <%s> element is not a valid url';
  WMLERR_ATTRIBUTE_ISNT_LENGTH        = 'Attribute "%s" of <%s> element is not a valid number or percent';
  WMLERR_ATTRIBUTE_ISNT_LIST          = 'Attribute "%s" of <%s> element has invalid value "%s", correct values are: (%s)';
  WMLERR_ELEMENT_NONAME               = 'Element has no name';
  WMLERR_ELEMENT2LONG                 = 'Too long element (%d), truncated';
  WMLERR_ELEMENT_TERMIMATOR2          = 'Element </%s> contains "/>"';
  WMLERR_ELEMENT_TERMIMATORATTR       = 'Element </%s> contains attributes (%s)';
  WMLERR_ELEMENT_WRONGTERMIMATOR      = 'Expecting </%s> but </%s> found';
  WMLERR_ELEMENT_TERMIMATOR_INTERNAL  = '?!! Unexpected element </%s> (element allready closed)'; // ?!!
  WMLERR_ELEMENT_XMLTAG_INTERNAL      = 'Internal error while parsing xml tag %s'; // ?!!
  WMLERR_TEXT_NOT_ALLOWED             = 'No text is allowed here';
  WMLERR_COMMENT_NOT_ALLOWED          = 'No comments is allowed here';
  WMLERR_SSSCRIPT_NOT_ALLOWED         = 'No server side scripts is allowed here';
  WMLERR_XMLDECL_NOT_ALLOWED          = 'No xml declaration is allowed here';
  WMLERR_ELEMENT_NOEXISTS             = 'Invalid element <%s>';
  WMLERR_1ELEMENT2MANY                = 'First unique element <%s> redeclared';
  WMLERR_1ELEMENT_AFTERTAIL           = 'Expecting <%s> element after end of <%s> element';
  WMLERR_ELEMENT_BADINHERITANCE       = 'Element <%s> can''t contain <%s> element';
  WMLERR_NESTEDELEMENT_1ORNONE        = 'Element <%s> can contain none or 1 <%s> element';
  WMLERR_NESTEDELEMENT_1              = 'Element <%s> must contain exactly 1 <%s> element';
  WMLERR_ALLNESTEDELEMENT_1ORNONE     = 'Element <%s> can contain none or 1 nested element';
  WMLERR_ALLNESTEDELEMENT_1           = 'Element <%s> must contain exactly 1 nested element';
  WMLERR_ATTRIBUTE_MISSEDREQUIRED     = 'Missing required attribute "%s" of <%s> element';
  WMLERR_ELEMENT_NOTERMINATED         = 'Expecting "/>" (element <%s> haven''t nested elements)';
  WMLERR_ELEMENT_NOTERMINAL           = 'Closure element closed with "/>" but element <%s> can contains nested tags';
  WMLERR_1ELEMENT_NOEND               = 'Unexpected "</%s>"';

const
  FEmptyString: String = '';
  WORDCHARS   = [#0..#255] - [#0..'@', '['..'`', '{'..#127];
  DELIMITERS1 = [#1..';', '='..'@', '['..'`', '{'..#127];
  INVALIDFNCHARS     = [#32, '@', '!'..',', ';'..'?', '['..'^', '{'..'}'];
  INVALIDFN_CGICHARS = [' '..'$','&'..'*',',',';'..'<','>','@','['..'^','{'..'}'];

constructor TxmlParser.Create;
begin
  FOnReport:= Nil;
  FOnProcessTemplateAttributes:= Nil;
  FSourceStrings:= Nil;
  StripHTTPHeader:= False;
  FCompiledXMLClass:= Nil;
  FStopAtTerminalElement:= Nil; // do not stop at </tag>
  SetText(FEmptyString);
end;

destructor TxmlParser.Destroy;
begin
  inherited Destroy;
end;

procedure TxmlParser.StartParse(AxmlElement: TxmlElement);
begin
  // clear element's stack
  FSourcePtr:= FSourcePtrStart;
  FSourceStringsXY.x:= 0;
  FSourceStringsXY.y:= 1;
end;

procedure TxmlParser.SetText(const NewString: TwmlpString);
var
  st: Integer;
begin
  FSourcePtr:= TwmlpPChar(NewString);
  if StripHTTPHeader then begin
    { search header delimiter (pair of CRLF) }
    st:= Pos(#13#10#13#10, NewString);
    if st > 0
    then Inc(FSourcePtr, st + 4 - 1);
  end;
  FSourcePtrStart:= FSourcePtr;
  FIsStringsOrPChar:= skPChar;
  NextToken:= NextTokenPChar;
end;

function TxmlParser.GetText: TwmlpString;
begin
  Result:= '';
  case FIsStringsOrPChar of
  skNone: ;
  skPchar:begin
      Result:= FSourcePtrStart;
    end;
  skStrings:begin
      if Assigned(FSourceStrings)
      then Result:= FSourceStrings.GetText;
    end;
  end;
end;

procedure TxmlParser.SetStrings(AStrings: TStrings);
var
  i, p: Integer;
begin
  FSourceStrings:= AStrings;
  if StripHTTPHeader then begin
    { search header delimiter (pair of CRLF) }
    p:= FSourceStrings.IndexOf('');
    for i:= 0 to p do begin
      FSourceStrings.Delete(0);
    end;
  end;
  FIsStringsOrPChar:= skStrings;
  NextToken:= NextTokenStrings;
end;

function TxmlParser.GetStrings: TStrings;
begin
  Result:= Nil;
  case FIsStringsOrPChar of
  skNone: ;
  skPchar:begin
    end;
  skStrings:begin
      Result:= FSourceStrings;
    end;
  end;
end;

procedure TxmlParser.NextTokenPchar;
var
  P, TokenStart, POld: TwmlpPChar;

  procedure NextPosition;
  begin
    Inc(P);
    case P^ of
    WideLineSeparator, WideParagraphSeparator
    : begin
        Inc(FWhere.x);
        FWhere.y:= 0;
        p^:= #32; // Mar 02 2007
      end;
    #10
    : begin
        Inc(FWhere.x);
        FWhere.y:= 0;
      end;
    #13: begin
  // do not set to zero here (for parser) FWhere.y:= 0;
      end
    else begin
      Inc(FWhere.y);
    end;
    end; { case }
  end;

begin
  FTokenString:= '';
  // skip first empty
  P:= FSourcePtr;
  POld:= P; // keep to remember spaces before PCDATA to add space
  while ((P^ <> #0) and (P^ <= #32)) or (P^ = WideLineSeparator) or (P^ = WideParagraphSeparator)
  do NextPosition;

  // FTokenPtr:= P;
  case P^ of
  #0: begin
      FToken:= etEnd;
      end;
  '<':begin
    FWhereTagStart:= FWhere;
    NextPosition;
    TokenStart:= P;
    while (P^ <> '>') and (P^ <> #0)
    do NextPosition;
    FWhereTagFinish:= FWhere;
    SetString(FTokenString, TokenStart, P - TokenStart);
    // default tag
    FToken:= etxmlTag;
    // look for special tags: !DOCTYPE
    if Length(FTokenString) > 1 then begin
      case FTokenString[1] of
      '?':FToken:= etXML;
      '!':begin
            if Pos('DOCTYPE', UpperCase(FTokenString)) = 2 then begin
              Delete(FTokenString, 1, 8);
              FToken:= etDocType;
            end else begin
              FToken:= etComment;
              // in comments > is allowed, so check is it  -->
              while ((P - 1)^ <> '-') and (P^ <> #0) do begin // and (P^ <> #0) -- Nov 26 2003
                Inc(P);
                while (P^ <> '>') and (P^ <> #0)
                do NextPosition;
              end;
              SetString(FTokenString, TokenStart, P - TokenStart); // added Dec 26 2006
            end;
          end;
      '%':begin
            FToken:= etssScript;
            // in comments > is allowed, so check is it  %>
            while (P - 1)^ <> '%' do begin
              Inc(P);
              while (P^ <> '>') and (P^ <> #0)
              do NextPosition;
            end;
          end;
      end; { case }
    end;
    NextPosition;
  end;
  else begin
    TokenStart:= POld;  // kept spaces before PCDATA to add space
    FWhereTagStart:= FWhere;
    while (P^ <> #0) and (P^ <> '<')
    do NextPosition;
    FWhereTagFinish:= FWhere;
    Dec(FWhereTagFinish.Y); // except last '<'. if eof?
    FToken:= etPCData;
    SetString(FTokenString, TokenStart, P - TokenStart);
  end;
  end;
  FSourcePtr:= P;
end;

function SetStringFromStrings(AStrings: TStrings; AStart, AFinish: TPoint): String;
var
  y: Integer;
begin
  if AFinish.y>=AStrings.Count then begin
    AFinish.y:= AStrings.Count - 1;
    AFinish.x:= Length(AStrings[AFinish.y])+1;
    if AStart.y>=AStrings.Count then begin
      AStart.y:= AFinish.y;
      AStart.x:= Length(AStrings[AStart.y])+1;
    end;
  end;
  if AFinish.y > AStart.y then begin
    Result:= Copy(AStrings[AStart.y], AStart.x, MaxInt);
    for y:= AStart.y + 1 to AFinish.y - 1 do begin
      Result:= Result + #13#10 + AStrings[y];
    end;
    Result:= Result + #13#10 + Copy(AStrings[AFinish.y], 1, AFinish.x - 1);
  end else begin
    Result:= Copy(AStrings[AStart.y], AStart.x, AFinish.x - AStart.x);
  end;
end;

procedure TxmlParser.NextTokenStrings;
var
  TokenStart: TPoint;
  ch: Char;
  fch: Char;

  procedure GoNextPosition;
  begin
    if (FSourceStringsXY.x >= FSourceStrings.Count) then begin
      Exit;
    end;
    if FSourceStringsXY.y >= Length(FSourceStrings[FSourceStringsXY.x]) then begin
      // go to the next line
      Inc(FSourceStringsXY.x);
      if FSourceStringsXY.x >= FSourceStrings.Count then begin
        // lines count exceeded
        Exit;
      end else begin
        FSourceStringsXY.y:= 1;
        // recursively go to the next line if line is empty
        if Length(FSourceStrings[FSourceStringsXY.x]) = 0
        then GoNextPosition; // go to the next line
      end;
    end else begin
      // go to the next char
      Inc(FSourceStringsXY.y);
    end;
    FWhere.x:= FSourceStringsXY.x - 1;
    FWhere.y:= FSourceStringsXY.y - 1;
  end;

  // return #0 if eof, FToken:= etEnd;
  procedure GetCharAtPosition;
  begin
    if (FSourceStringsXY.x >= FSourceStrings.Count) then begin
      ch:= #0;
      Exit;
    end;
    ch:= FSourceStrings[FSourceStringsXY.x][FSourceStringsXY.y];
  end;

begin
  // skip first empty
  repeat
    GetCharAtPosition;
    if ch = #0
    then Break;
    GoNextPosition;
  until ch > #32;
  case ch of
  #0: begin
        FToken:= etEnd;
      end;
  '<':begin
    TokenStart:= FSourceStringsXY;
    FToken:= etxmlTag;
    repeat
      if ch=#0
      then Break;
      GoNextPosition;
      GetCharAtPosition;
    until ch = '>';
    FTokenString:= SetStringFromStrings(FSourceStrings, TokenStart, FSourceStringsXY);
    GoNextPosition;
  end;
  else begin
    fch:= ch; // there is possible bug, spaces before first non-space character in PCDATA omitted
    TokenStart:= FSourceStringsXY;
    FToken:= etPCData;
    repeat
      GoNextPosition;
      GetCharAtPosition;
      if (ch = #0) or (ch = '<')
      then Break;
    until False;
    FTokenString:= fch + SetStringFromStrings(FSourceStrings, TokenStart, FSourceStringsXY);
  end;
  end;
end;

// e.g. ' wml PUBLIC "-//WAPFORUM//DTD WML 1.2//EN" "http://www.wapforum.org/DTD/wml1.2.dtd"
// e.g. 'html PUBLIC "+//ISBN 0-9673008-1-9//DTD OEB 1.0.1 Document//EN" "http://openebook.org/dtds/oeb-1.0.1/oebdoc101.dtd">',
function TxmlParser.ParseDocType(const ATokenStr: WideString; var ACompiledDocTypeVer: String): String;
var
  i, p, s0, s1, L: Integer;
  IsPublic, desc, doct, docname, uri, dtd: String;
  OParen: Boolean;
  WTokenStr: WideString;
  TokenStr: String;
begin
  Result:= '';
  ACompiledDocTypeVer:= '';
  WTokenStr:= ATokenStr;
  util1.DeleteControlsStrCRLF2Space(WTokenStr);
  TokenStr:= Trim(WTokenStr) + #32;
  s0:= 0;
  p:= 0;
  i:= 1;
  doct:= '';
  L:= Length(TokenStr);
  OParen:= False;
  while i <= L do begin
    case TokenStr[i] of
    #0..#32: begin
      if not OParen then begin
        s1:= i;
        if (s0 > 0) then begin
          case p of
            1: begin
              Result:= Copy(TokenStr, s0, s1 - s0);
              s0:= i;
              p:= 2;
            end;
            3: begin
              IsPublic:= Copy(TokenStr, s0, s1 - s0);
              s0:= i;
              p:= 4;
            end;
            5: begin
              desc:= Copy(TokenStr, s0, s1 - s0 - 1);  // '-//WAPFORUM//DTD WML 1.2//EN'
              // ACompiledDocTypeVer
              dtd:= GetToken(3, '//', desc);
              doct:= GetToken(2, #32, dtd);
              ACompiledDocTypeVer:= GetToken(3, #32, dtd);
              docname:= GetToken(4, #32, dtd);
              
              s0:= Length(ACompiledDocTypeVer);
              while s0 > 0 do begin
                if (ACompiledDocTypeVer[s0] in ['0'..'9', '.']) then begin
                  Break;
                end else begin
                  Delete(ACompiledDocTypeVer, s0, 1);
                  Dec(s0);
                end;
              end;
              s0:= i;
              p:= 6;
            end;
            7: begin
              uri:= Copy(TokenStr, s0, s1 - s0 - 1);  // skip
              s0:= i;
              p:= 8;
            end;
          end;
          s0:= 0;
        end;
      end;
    end;
    '"': begin
        OParen:= not OParen;
      end
    else begin
        case p of
          0, 2, 4, 6, 8: begin
            Inc(p);
            s0:= i;
          end;
        end;
      end;
    end;
    Inc(i);
  end;

  if Length(doct) = 0 then begin
    doct:= Result;
  end else begin
  end;

//  set CompiledXMLClass

  if CompareText(doct, 'wml') = 0
  then CompiledXMLClass:= TwmlContainer;

  if CompareText(doct, 'oeb') = 0 then begin
    if CompareText(docname, 'Document') = 0
    then CompiledXMLClass:= ToebContainer
    else if CompareText(docname, 'Package') = 0
      then CompiledXMLClass:= TPkgContainer;
  end;
  
  if CompareText(doct, 'opf') = 0
  then CompiledXMLClass:= TPkgContainer;

  if (CompareText(Copy(doct, 1, 2), 'ht') = 0) then begin
    if CompiledXMLClass = TOEBContainer then begin
      doct:= 'oeb';
    end else begin;
      CompiledXMLClass:= THtmContainer;
    end;
  end;
  Result:= LowerCase(doct);
end;

const
  PS_NAME        = 0;
  PS_WAITVALUE   = 1;
  PS_VALUE       = 2;
  PS_QUOTEDVALUE = 3;
  PS_SINGLE_QUOTE= 4;
  PS_NEXTPARAM   = 5;
  PS_SPACEAFTERNAME = 6;

// set FCompiledXMLClass to TWMLElementClass or TOEBElementClass

function TxmlParser.Parse2xml(AxmlElement: TxmlElement; AEnv: Pointer): Boolean;
var
  i, p, L, tlen: Integer;
  st, fn,
  pstate: Integer;  // PS_NAME=0- name, ...
  TagName: ShortString;
  vl: String;
  ContinueParse: Boolean;
  e: TxmlElement;
  ElementCollection: TxmlElementCollection;
  xmlClass: TPersistentClass;
  TerminalTag: Boolean;   // </element>
  TerminatedTag: Boolean; // <element ../>
  FirstElement: Boolean; // True- first element exists and ready to fill
  CompiledDocType,
  CompiledDocTypeVer: String;

  procedure Error(ALevel: TReportLevel; const AMsg: WideString);
  begin
    if Assigned(FOnReport) then begin
      FOnReport(ALevel, e, '', 0, FWhere, PWideChar(AMsg), ContinueParse, AEnv);
    end;
  end;

  procedure AddAttribute(ALen: Integer);
  var
    idx: Integer;
    avalLen: Integer;
    aval: String;
  begin
    idx:= e.Attributes.IndexOf(vl);
    aval:= Copy(FTokenString, st, ALen);
    if idx >= 0 then begin
      e.Attributes[idx].Value:= aval;
    end else begin
      if Assigned(FOnProcessTemplateAttributes) then begin
        if not FOnProcessTemplateAttributes(e, vl, aval)
        then Error(rlError, Format(WMLERR_INVALID_ATTRIBUTE, [vl, TagName]));
        Exit;
      end else begin
        Error(rlError, Format(WMLERR_INVALID_ATTRIBUTE, [vl, TagName]));
        Exit;
      end;
    end;
    // validate attribute
    case e.Attributes[idx].AttrType of
    atVData:begin
      end;
    atCData:begin
      end;
    atNumber:begin
        if not util1.isDecimal(aval) then begin
          Error(rlWarning, Format(WMLERR_ATTRIBUTE_ISNT_NUMBER, [vl, TagName]));
          Exit;
        end;
      end;
    atHref:begin
        // do not use util1.IsValidURL- url can contains script function calls like
        if not Valid_WML_N_ScriptURL(aval) then begin
          Error(rlWarning, Format(WMLERR_ATTRIBUTE_ISNT_URL, [vl, TagName]));
          Exit;
        end;
      end;
    atLength:begin
        avalLen:= Length(aval);
        if (avalLen > 0) and (aval[avalLen] = '%') then begin
          Delete(aval, avalLen, 1);
          // do Trim? 100 % => 100% ?!!
          // aval:= Trim(Aval);
        end;
        if not util1.IsDecimal(aval) then begin
          Error(rlWarning, Format(WMLERR_ATTRIBUTE_ISNT_LENGTH, [vl, TagName]));
          Exit;
        end;
      end;
    atNMToken:begin
      end;
    atID:begin
      end;
    atNoStrictList:begin
      end;
    atList:begin
        if e.Attributes[idx].List.IndexOf(aval) < 0 then begin
          Error(rlError, Format(WMLERR_ATTRIBUTE_ISNT_LIST, [vl, TagName, aval, e.Attributes[idx].List.CommaText]));
          Exit;
        end;
      end;
    end; { case }
  end;

  procedure AddElement;
  begin
    e:= ElementCollection.Add;
    with e.DrawProperties do begin
      TagXYStart:= FWhereTagStart;
      TagXYFinish:= FWhereTagFinish;
      // this values will overrides in case <tag>  </tag> when terminal tag occurs
      TagXYTerminatorStart:= FWhereTagFinish;
      TagXYTerminatorFinish:= FWhereTagFinish;
    end;
{$IFDEF GENXML}
    if e is TgenXMLElement then begin
      TgenXMLElement(e).SetElementName(TagName);
    end;
{$ENDIF}
  end;

  procedure ParseAttributes; // i points to start position. L indicates length of FTokenString
  var
    v: Integer;
  begin
    { states: 0- name, ... }
    fn:= 0;
    pstate:= PS_NEXTPARAM;
    while i <= L do begin
      if pstate = PS_NEXTPARAM then begin
        { skip spaces before parameter pair start }
        while i < L do begin
          if (FTokenString[i] > #32) and (FTokenString[i] <> WideLineSeparator)
          then Break;
          Inc(i);
        end;
        st:= i;
        pstate:= PS_NAME;
      end;
      case FTokenString[i] of
      #1..#32, WideLineSeparator, WideParagraphSeparator
      : begin
             if pstate = PS_VALUE then begin
               AddAttribute(fn-st+1);
               st:= i;
               pstate:= PS_NEXTPARAM;
             end else begin
               if pstate = PS_NAME
               then pstate:= PS_SPACEAFTERNAME;
             end;
           end;
      '=': begin
             if pstate in [PS_NAME, PS_SPACEAFTERNAME] then begin
               vl:= Copy(FTokenString, st, fn-st+1);
               st:= i + 1;
               pstate:= PS_WAITVALUE;
             end;
           end;
      '"': begin  // ' single quote is not acceptable
             case pstate of
             PS_WAITVALUE:begin
                 pstate:= PS_QUOTEDVALUE;
                 st:= i + 1;
               end;
             PS_QUOTEDVALUE:begin
                 // element's attribute
                 AddAttribute(i-st);
                 pstate:= PS_NEXTPARAM;
               end;
             end;
           end;
      '''': begin  // but it happens...
             case pstate of
             PS_WAITVALUE:begin
                 pstate:= PS_SINGLE_QUOTE;
                 st:= i + 1;
               end;
             PS_SINGLE_QUOTE:begin
                 // element's attribute
                 AddAttribute(i-st);
                 pstate:= PS_NEXTPARAM;
               end;
             end;
           end;
        else begin
          case pstate of
          PS_WAITVALUE: begin
              pstate:= PS_VALUE;
              st:= i;
            end;
          PS_SPACEAFTERNAME: begin
              vl:= Copy(FTokenString, st, fn-st+1);
              AddAttribute(0);  // add attribute w/o value
              pstate:= PS_NEXTPARAM;
              Dec(i);  // return one char backward
            end;
          end;
          fn:= i;
        end; { else case }
      end; { case  attributes }
      Inc(i);
    end; { while, attributes }
    // last attribute
    case pstate of
    PS_VALUE: begin
        // in case of ... par=value> w/o quotes and spaces
        AddAttribute(i-st);
      end;
    PS_NAME, PS_SPACEAFTERNAME: begin
        // in case of ... par>
        if (fn > st + 1) then begin
          vl:= Copy(FTokenString, st, fn-st+1);
          AddAttribute(0);  // no value, just attribute name
        end;
      end;
    end;

    // validate required attributes
    for v:= 0 to e.Attributes.Count - 1 do begin
      if e.Attributes[v].Required then begin
        if Length(e.Attributes[v].Value) <= 0 then begin
          Error(rlError, Format(WMLERR_ATTRIBUTE_MISSEDREQUIRED, [e.Attributes[v].Name, e.GetElementName]));
        end;
      end;
    end;
  end;

begin
  Result:= True;
  if not Assigned(AxmlElement)
  then Exit;  // just for safe

  FirstElement:= not (AxmlElement is TxmlContainer);

  with AxmlElement.DrawProperties do begin
    FWhere:= TagXYStart;
  end;

  ContinueParse:= True;
  xmlClass:= Nil;
  e:= AxmlElement;
  StartParse(e);
  while ContinueParse do begin
    NextToken;
    case FToken of
    etxmlTag: begin
{-------------------}
      i:= 1;
      L:= Length(FTokenString);
      { skip forward spaces }
      while i <= L do begin
        if FTokenString[i] > #32
        then Break;
        Inc(i);
      end;
      // check terminal "</" and terminated tag "/>" cases
      // check element is terminal element (</)
      TerminalTag:= (L > 0) and (FTokenString[1] = '/');
      // delete "/" if exists
      if TerminalTag then begin
        Delete(FTokenString, 1, 1);
        Dec(L);
      end;
      // check is /> exists
      TerminatedTag:= (L > 0) and (FTokenString[L] = '/');
      // delete "/" if exists
      if TerminatedTag then begin
        Delete(FTokenString, L, 1);
        Dec(L);
      end;
      // extract tag name
      p:= i;
      while i <= L do begin
        if FTokenString[i] <= #32
        then Break;
        Inc(i);
      end;
      // check tag name length
      tlen:= i - p;
      if (tlen = 0)
      then Error(rlError, Format(WMLERR_ELEMENT_NONAME, [tlen]));
      if (tlen > 255) then begin
        Error(rlError, Format(WMLERR_ELEMENT2LONG, [tlen]));
        tlen:= 255;
      end;
      // extract tag name
      TagName:= Copy(FTokenString, p, tlen);
      if TerminalTag then begin  // e.g. </element>
        if TerminatedTag then begin
          // just in case of </element .. />
          Error(rlError, Format(WMLERR_ELEMENT_TERMIMATOR2, [tagname]));
          // Continue;
        end;
        // check- no parameters
        vl:= Trim(Copy(FTokenString, i, MaxInt));
        if Length(vl) > 0 then begin
          Error(rlError, Format(WMLERR_ELEMENT_TERMIMATORATTR, [TagName, vl]));
        end;

        // check - stop compiling
        if e is FStopAtTerminalElement then begin
          ContinueParse:= False;
        end;

        // return to parent element
        if CompareText(e.GetElementName, TagName) <> 0 then begin
          Error(rlError, Format(WMLERR_ELEMENT_WRONGTERMIMATOR, [e.GetElementName, TagName]));
          // Continue; // -- Nov 07 2002
          // check is elemment is not closed properly
          if Assigned(e.ParentElement) then begin   // -- Nov 14 2002
            // if parent element can contain element,
            // it is mean missed closure element
            ElementCollection:= e.ParentElement.NestedElements.GetByClass(xmlClass);
            if Assigned(ElementCollection) then begin
              e:= e.ParentElement;
              AddElement;
            end else begin
              // nothing to do
              Continue;
            end;                                    // -- Nov 14 2002
          end else Continue;
        end;
        // terminal tag  <tag>  </tag>
        // override terminal tag positions created by AddElement
        with e.DrawProperties do begin
          TagXYTerminatorStart:= FWhereTagStart;
          TagXYTerminatorFinish:= FWhereTagFinish;
        end;
        if not (e is AxmlElement.ClassType) then begin
          if Assigned(e.ParentElement) then begin
            e:= e.ParentElement;
          end else begin
            Error(rlError, Format(WMLERR_ELEMENT_TERMIMATOR_INTERNAL, [TagName]));
          end;
        end;
      end else begin
        // non- terminal tag
        // get new element class
{--------- Determine wml, oeb or other ------------}
        xmlClass:= xmlsupported.GetxmlClassByElementName(FCompiledXMLClass, TagName);
{--------------------------------------------------}
        if (not Assigned(xmlClass)) then begin
          Error(rlError, Format(WMLERR_ELEMENT_NOEXISTS, [TagName]));
          Continue;
        end;
        // create new nested element or check is it first (parent) element
        // Parent element usually <wml> but may be different
        // Using pre-created parent element is valuable in case of remarks
        if FirstElement then begin
          FirstElement:= False;
          // do not add existing element, just validate text positions
          with e.DrawProperties do begin
            TagXYStart:= FWhereTagStart;
            TagXYFinish:= FWhereTagFinish;
            // this values override in case <tag>  </tag> when terminal tag occurs
            TagXYTerminatorStart:= FWhereTagFinish;
            TagXYTerminatorFinish:= FWhereTagFinish;
          end;
        end else begin
          //
          ElementCollection:= e.NestedElements.GetByClass(xmlClass);
          if (not Assigned(ElementCollection)) then begin
            Error(rlError, Format(WMLERR_ELEMENT_BADINHERITANCE, [e.GetElementName, TagName]));
            // check is elemment is not closed properly
            if Assigned(e.ParentElement) then begin
              // if parent element can contain element,
              // it is mean missed closure element
              ElementCollection:= e.ParentElement.NestedElements.GetByClass(xmlClass);
              if Assigned(ElementCollection) then begin
                e:= e.ParentElement;
//                AddElement;
              end else begin
                // nothing to do
                Continue;
              end;
            end else Continue;
          end;
          case ElementCollection.QtyLimit of
          wciAny:;
          wciOneOrNone: begin
              if ElementCollection.Count >= 1 then begin
                Error(rlError, Format(WMLERR_NESTEDELEMENT_1ORNONE, [e.GetElementName, TagName]));
                Continue;
              end;
            end;
          wciOne: begin
              if ElementCollection.Count >= 1 then begin
                Error(rlError, Format(WMLERR_NESTEDELEMENT_1, [e.GetElementName, TagName]));
                Continue;
              end;
            end;
          wciOneOrMore:;  // must be checked later
          end;

          tlen:= e.NestedElements1Count;
          case e.NestedElements.Cooperative of
          wciAny:;
          wciOneOrNone: begin
              if not e.IsEmpty then begin
                Error(rlError, Format(WMLERR_ALLNESTEDELEMENT_1ORNONE, [e.GetElementName]));
                Continue;
              end;
            end;
          wciOne: begin
              if ElementCollection.Count >= 1 then begin
                Error(rlError, Format(WMLERR_ALLNESTEDELEMENT_1, [e.GetElementName]));
                Continue;
              end;
            end;
          wciOneOrMore:;  // must be checked later
          end;
          // add element
          if Assigned(ElementCollection) then begin
            // add element
            AddElement;
          end else begin
            // collection doesn't have TWmlPCData item
            Error(rlError, Format(WMLERR_TEXT_NOT_ALLOWED, [TagName]));
            Continue; // -- Nov 07 2002
          end;
        end;

        // add attributes
        ParseAttributes;

        // validate must have nested elements, if no, check "/>" tag terminator
        if e.IsEmpty then begin
          // no nested elements are available, can be closed with "/>"
          if not TerminatedTag then begin
            Error(rlHint, Format(WMLERR_ELEMENT_NOTERMINATED, [e.GetElementName]));
          end;
        end else begin
          if TerminatedTag then begin
            // Do not show hint- closing empty tag is not an error
            // Error(rlHint, Format(WMLERR_ELEMENT_NOTERMINAL, [e.GetElementName]));
          end;
        end;
        // validate parent element integrity
        if TerminatedTag then begin
          {
          if not e.IsEmpty
          then Error(rlHint, Format(WMLERR_ELEMENT_NOTERMINATED, [e.GetElementName]));
          }
          // Terminated tag starts where tag started
          e.DrawProperties.TagXYTerminatorStart:= FWhereTagStart;
          e.DrawProperties.TagXYTerminatorFinish:= FWhereTagFinish;
          // return to parent element
          if CompareText(e.GetElementName, TagName) <> 0 then begin
            Error(rlError, Format(WMLERR_ELEMENT_WRONGTERMIMATOR, [e.GetElementName, TagName]));
            // Continue; // -- Nov 07 2002
            // check is elemment is not closed properly
            if Assigned(e.ParentElement) then begin   // -- Nov 14 2002
              // if parent element can contain element,
              // it is mean missed closure element
              ElementCollection:= e.ParentElement.NestedElements.GetByClass(xmlClass);
              if Assigned(ElementCollection) then begin
                e:= e.ParentElement;
                AddElement;
              end else begin
                // nothing to do
                Continue;
              end;                                    // -- Nov 14 2002
            end else Continue;

          end;
          if not (e is AxmlElement.ClassType) then begin
            if Assigned(e.ParentElement) then begin
              e:= e.ParentElement;
            end else begin
              Error(rlError, Format(WMLERR_ELEMENT_TERMIMATOR_INTERNAL, [TagName]));
            end;
          end;
        end else begin
          // validate must have nested elements, if no, check "/>" tag terminator
          // no nested elements are available, must be closed with "/>"
          if e.IsEmpty then begin
            Error(rlWarning, Format(WMLERR_ELEMENT_NOTERMINATED, [e.GetElementName]));
            if Assigned(e.ParentElement) then begin // added Jan 06 2008
              e:= e.ParentElement;
            end
          end;
        end;
      end; { else }
    end; { etxmlTag }
    etPCData: begin
      if FirstElement then begin
        FirstElement:= False;
        // do not add existing element, just validate text positions
        with e.DrawProperties do begin
          TagXYStart:= FWhereTagStart;
          TagXYFinish:= FWhereTagFinish;
          TagXYTerminatorStart:= FWhereTagFinish;
          TagXYTerminatorFinish:= FWhereTagFinish;
        end;
      end else begin
{--------- Determine wml, oeb or other ------------}
        xmlClass:= GetxmlPCDATAClass(FCompiledXMLClass);   // default is TxmlPCData;
{--------------------------------------------------}
        ElementCollection:= e.NestedElements.GetByClass(xmlClass);
        if Assigned(ElementCollection) then begin
          // add PCData element
          AddElement;
        end else begin
          // collection doesn't have TxmlPCData item
          Error(rlError, Format(WMLERR_TEXT_NOT_ALLOWED, [TagName]));
          // check is elemment is not closed properly
          if Assigned(e.ParentElement) then begin   // -- Nov 11 2002
            // if parent element can contain element,
            // it is mean missed closure element
            ElementCollection:= e.ParentElement.NestedElements.GetByClass(xmlClass);
            if Assigned(ElementCollection) then begin
              e:= e.ParentElement;
              AddElement;
            end else begin
              // nothing to do
              Continue;
            end;                                    // -- Nov 11 2002
          end else Continue;
        end;
      end;
      with e do begin
        i:= e.Attributes.IndexOf('value');
        if i >= 0
        then Attributes.Items[i].Value:= FTokenString // ValidPCData(FTokenString)
        else Error(rlError, Format(WMLERR_ELEMENT_XMLTAG_INTERNAL, ['pcdata: ' +
          System.Copy(ValidPCData(FTokenString), 1, 32) + '...']));
      end;
      if Assigned(e.ParentElement) then begin
        e:= e.ParentElement;
      end else begin
        Error(rlError, Format(WMLERR_ELEMENT_TERMIMATOR_INTERNAL, [TagName]));
      end;
    end;
    etComment: begin
      //
      if FirstElement then begin
        FirstElement:= False;
        // do not add existing element, just validate text positions
        with e.DrawProperties do begin
          TagXYStart:= FWhereTagStart;
          TagXYFinish:= FWhereTagFinish;
          TagXYTerminatorStart:= FWhereTagFinish;
          TagXYTerminatorFinish:= FWhereTagFinish;
        end;
      end else begin
        xmlClass:= TxmlComment;
        ElementCollection:= e.NestedElements.GetByClass(xmlClass);
        if Assigned(ElementCollection) then begin
          // add comment element
          AddElement;
        end else begin
          // collection doesn't have comment item
          Error(rlError, Format(WMLERR_COMMENT_NOT_ALLOWED, [TagName]));
        end;
      end;
      with e do begin
        i:= Attributes.IndexOf('value');
        if i >= 0
        then Attributes.Items[i].Value:= ValidCommentData(FTokenString);
      end;
      if Assigned(e.ParentElement) then begin
        e:= e.ParentElement;
      end else begin
        Error(rlError, Format(WMLERR_ELEMENT_TERMIMATOR_INTERNAL, [TagName]));
      end;
    end;
    etssScript: begin // Apr 19 2003
      //
      if FirstElement then begin
        FirstElement:= False;
        // do not add existing element, just validate text positions
        with e.DrawProperties do begin
          TagXYStart:= FWhereTagStart;
          TagXYFinish:= FWhereTagFinish;
          TagXYTerminatorStart:= FWhereTagFinish;
          TagXYTerminatorFinish:= FWhereTagFinish;
        end;
      end else begin
        xmlClass:= TxmlssScript;
        ElementCollection:= e.NestedElements.GetByClass(xmlClass);
        if Assigned(ElementCollection) then begin
          // add comment element
          AddElement;
        end else begin
          // collection doesn't have comment item
          Error(rlError, Format(WMLERR_SSSCRIPT_NOT_ALLOWED, [TagName]));
        end;
      end;
      with e do begin
        i:= Attributes.IndexOf('value');
        if i >= 0
        then Attributes.Items[i].Value:= ValidSSScriptData(FTokenString);
      end;
      if Assigned(e.ParentElement) then begin
        e:= e.ParentElement;
      end else begin
        Error(rlError, Format(WMLERR_ELEMENT_TERMIMATOR_INTERNAL, [TagName]));
      end;
    end;
    etXML: begin
      // '?xml ... ?'. Parse xml tag name as parameter?
      Delete(FTokenString, 1, 1); // delete first '?'
      if FTokenString[Length(FTokenString)] = '?'
      then Delete(FTokenString, Length(FTokenString), 1); // delete last '?'
      if FirstElement then begin
        FirstElement:= False;
        // do not add existing element, just validate text positions
        with e.DrawProperties do begin
          TagXYStart:= FWhereTagStart;
          TagXYFinish:= FWhereTagFinish;
          TagXYTerminatorStart:= FWhereTagFinish;
          TagXYTerminatorFinish:= FWhereTagFinish;
        end;
      end else begin
        xmlClass:= TXMLDesc;
        ElementCollection:= e.NestedElements.GetByClass(xmlClass);
        // add xml description tag
        if Assigned(ElementCollection) then begin
          // add xml description tag
          AddElement;
        end else begin
          // collection doesn't have TWmlPCData item
          Error(rlError, Format(WMLERR_XMLDECL_NOT_ALLOWED, [TagName]));
        end;
      end;
      // i point to start position
      i:= Pos(#32, FTokenString) + 1; // skip 'xml '
      L:= Length(FTokenString);
      ParseAttributes;
      if Assigned(e.ParentElement) then begin
        e:= e.ParentElement;
      end else begin
        Error(rlError, Format(WMLERR_ELEMENT_XMLTAG_INTERNAL, [TagName]));
      end;
    end;
    etDocType: begin
      //
      CompiledDocType:= ParseDocType(FTokenString, CompiledDocTypeVer);  // set CompiledXMLClass too
      if FirstElement then begin
        FirstElement:= False;
        // do not add existing element, just validate text positions
        with e.DrawProperties do begin
          TagXYStart:= FWhereTagStart;
          TagXYFinish:= FWhereTagFinish;
          TagXYTerminatorStart:= FWhereTagFinish;
          TagXYTerminatorFinish:= FWhereTagFinish;
        end;
        // i m not sure
        with e do begin
          i:= Attributes.IndexOf('version');
          if i >= 0
          then Attributes.Items[i].Value:= CompiledDocTypeVer;
          DTDVersion:= CompiledDocTypeVer;          
        end;
      end else begin
{--------- Determine wml, oeb or other ------------}
        xmlClass:= GetxmlDocDescClass(FCompiledXMLClass);   // default is TDocDesc;
{--------------------------------------------------}
        ElementCollection:= e.NestedElements.GetByClass(xmlClass);
        // if not Assigned(ElementCollection) then Continue;  // fatal error
        // add document description tag
        if Assigned(ElementCollection) then begin
          // add element
          AddElement;
          with e do begin
            i:= Attributes.IndexOf('version');
            if i >= 0
            then Attributes.Items[i].Value:= CompiledDocTypeVer;
            DTDVersion:= CompiledDocTypeVer;
          end;
          if Assigned(e.ParentElement) then begin
            e:= e.ParentElement;
          end else begin
            Error(rlError, Format(WMLERR_ELEMENT_XMLTAG_INTERNAL, [TagName]));
          end;
        end else begin
          // collection doesn't have TWmlPCData item
          Error(rlError, Format(WMLERR_TEXT_NOT_ALLOWED, [TagName]));
          Continue; // -- Nov 07 2002
        end;
      end;
    end;
    etEnd: begin
      with AxmlElement.DrawProperties do begin
        // this values override in case <tag>  </tag> when terminal tag occurs
        // do not that! TagXYTerminatorStart:= FWhere; TagXYTerminatorFinish:= FWhere;
      end;
      Break;
    end;
    end; { case }
  end; { while }
  if not (e is AxmlElement.ClassType) then begin
    Error(rlError, Format(WMLERR_1ELEMENT_NOEND, [AxmlElement.GetElementName]));
  end;
end;

// utility functions implementation --------------------------------------------

function xmlCompileText(const ASrc: TwmlpString; AReportEvent: TReportEvent;
  AOnProcessTemplateAttributesEvent: TOnProcessTemplateAttributesEvent;
  ATreeViewElements: TTreeView;
  AResultElement: TxmlElement; ADefaultCompiledXMLClass: TClass;
  AStopAtTerminalElement: TxmlElementClass = Nil; AEnv: Pointer = Nil): TClass;
var
  xmlParser: TxmlParser;
  SaveChange: TTVChangedEvent;
begin
  if not Assigned(AResultElement) then begin // for safe
    Result:= Nil;
    Exit;
  end;

  xmlParser:= TxmlParser.Create;
  with xmlParser do begin
    OnProcessTemplateAttributes:= AOnProcessTemplateAttributesEvent;
    StopAtTerminalElement:= AStopAtTerminalElement;
    Text:= ASrc;
    OnReport:= AReportEvent;
    xmlParser.CompiledXMLClass:= ADefaultCompiledXMLClass;
    Parse2xml(AResultElement, AEnv);
  end;
  if Assigned(ATreeViewElements) then with ATreeViewElements do begin
    Items.BeginUpdate;
    SaveChange:= OnChange;
    OnChange:= Nil;
    Items.Clear;
    Items.AddObject(Nil, AResultElement.Name, AResultElement);
    TopItem.ImageIndex:= 0;
    TopItem.SelectedIndex:= 0;
    AddxmlElement2TreeNode(AResultElement, TopItem);
    OnChange:= SaveChange;
    Items.EndUpdate;
  end;
  Result:= xmlParser.CompiledXMLClass;
  xmlParser.Free;
end;

function AddxmlElement2TreeNode(AxmlElement: TxmlElement; ATreeNode: TTreeNode): Boolean;
var
  o: Integer;
  n: TTreeNode;
  e: TxmlElement;
  PersistentClass: TPersistentClass;
begin
  Result:= True;
  with AxmlElement do begin
    for o:= 0 to NestedElements1Count - 1 do begin
      e:= GetNested1ElementByOrder(o, PersistentClass);
      // if not Assigned(e) then raise;
      n:= TTreeView(ATreeNode.TreeView).Items.AddChildObject(ATreeNode, e.name, e);
      // n.ImageIndex:= xmlsupported.GetBitmapIndexByName(e.GetElementName);
      n.ImageIndex:= GetBitmapIndexByClass(e.ClassType);
      n.SelectedIndex:= n.ImageIndex;
      // call itself recursively
      AddxmlElement2TreeNode(e, n);
    end;
  end;
end;

procedure NestedElements2ToolButtons(AxmlElement: TxmlElement; AToolBar: TToolBar;
  AButtonNewClick: TNotifyEvent);
var
  e: Integer;
  b: TToolButton;
begin
  AToolBar.Visible:= False;
  // delete previously created buttons
  e:= 0;
  while e < AToolBar.ComponentCount do begin
    if (AToolBar.Components[e] is TToolButton) then begin
      AToolBar.Components[e].Free;
    end else Inc(e);
  end;


  if not Assigned(AxmlElement) then begin
    AToolBar.Visible:= True;
    Exit;
  end;

  // add new buttons
  for e:= 0 to AxmlElement.NestedElements.Count - 1 do begin
    // check if element can be inserted
    if AxmlElement.CanInsertElement(AxmlElement.NestedElements[e].ItemClass) then begin
      b:= TToolButton.Create(AToolBar);
      with b do begin
        // AutoSize:= True;
        Hint:= AxmlElement.NestedElements[e].ElementName;
        ShowHint:= True;
        OnClick:= AButtonNewClick;
        Parent:= TWinControl(AToolBar);
        ImageIndex:= GetBitmapIndexByClass(AxmlElement.NestedElements[e].ItemClass);
        b.Tag:= Integer(AxmlElement);
      end;
    end;
  end;
  AToolBar.Visible:= True;
end;

const
  BLOCK_INDENT = 8;

type
  TElementAttributeMemo = class(TEMemo)
    FElement: TxmlElement;
    FxmlAttribute: TxmlAttribute;
  private
    procedure OnModified2Attr(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AElement: TxmlElement; AAttribute: TxmlAttribute; AOnSelectClick: TNotifyEvent);
    destructor Destroy; override;
  end;

constructor TElementAttributeMemo.Create(AOwner: TComponent; AElement: TxmlElement; AAttribute: TxmlAttribute; AOnSelectClick: TNotifyEvent);
begin
  inherited Create(AOwner);
  FElement:= AElement;
  FxmlAttribute:= AAttribute;
  OnModified:= OnModified2Attr;
  if Assigned(FxmlAttribute)
  then TextInCharacterset[convNone]:= FxmlAttribute.Value;
  Tag:= Integer(FElement);
  OnEnter:= AOnSelectClick;
end;

destructor TElementAttributeMemo.Destroy;
begin
  inherited Destroy;
end;

procedure TElementAttributeMemo.OnModified2Attr(Sender: TObject);
begin
  if Assigned(FxmlAttribute)
  then FxmlAttribute.Value:= Self.Lines.Text;
end;

function AddxmlElement2Panel(AxmlElement: TxmlElement; APanel: TWinControl;
  AButtonImages: TCustomImageList;
  AOnElementChange: TOnElementChange;
  AOnSelectClick: TNotifyEvent;
  AToolButtonNewClick: TNotifyEvent): Boolean;
var
  TopEl: TWinControl;
  y: Integer;

  function AddEl(AxmlElement: TxmlElement; APanel: TWinControl; ALevel: Integer): Boolean;
  var
    o: Integer;
    n: TWinControl;
    e: TxmlElement;
    PersistentClass: TPersistentClass;
    ToolbarElements: TToolBar;
    b: TToolButton;
    ps: TPageScroller;
    m: TECustomMemo;
    x: Integer;
    MaxHeight: Integer;
  begin
    Result:= True;
    with AxmlElement do begin
      for o:= 0 to NestedElements1Count - 1 do begin
        x:= ALevel * BLOCK_INDENT;
        e:= GetNested1ElementByOrder(o, PersistentClass);

        ps:= TPageScroller.Create(APanel);
        with ps do begin
          Parent:= TopEl;
          Left:= x;
          Top:= y;
          Width:= 48; //TopEl.Width - X - n.Width;
          Height:= 22;
          if Height > MaxHeight
          then MaxHeight:= Height;
        end;

        ToolbarElements:= TToolBar.Create(APanel);
        ps.Control:= ToolbarElements;
        with ToolbarElements do begin
          EdgeBorders:= [];
          Flat:= True;
          Parent:= ps;
          Images:= AButtonImages;
          Align:= alLeft;
          Autosize:= True;
          // add buttons


          b:= TToolButton.Create(ToolbarElements);
          with b do begin
            // AutoSize:= True;
            Hint:= e.GetElementName;
            Caption:= Hint;
            ShowHint:= True;
            OnClick:= AOnSelectClick;;
            Parent:= TWinControl(ToolbarElements);
            ImageIndex:= GetBitmapIndexByClass(e.ClassType);
            b.Tag:= Integer(e);
          end;

          Left:= 0;
          Top:= 0;
        end;

        if e is TxmlPCData then begin
          m:= TElementAttributeMemo.Create(APanel, e, e.Attributes[0], AOnSelectClick);
          with m do begin
            Parent:= TopEl;
            Left:= x + ps.Width;
            Top:= y;
            Width:= 228;// TopEl.Width - X - n.Width;
            Height:= 68;
            MaxHeight:= Height;
          end;
        end else begin
          n:= TButton.Create(TopEl);
          with TButton(n) do begin
            Tag:= Integer(e);
            Parent:= TopEl;
            Caption:= e.GetElementName;
            Left:= x + ps.Width;
            Top:= y;
            OnClick:= AOnSelectClick;
          end;
          MaxHeight:= n.Height;
        end;
        Inc(Y, MaxHeight);
        // call itself recursively
        AddEl(e, n, ALevel + 1);
      end;
    end;
  end;

begin
  with APanel do begin
   // clear up panel
   Visible:= False;
   DestroyComponents;
  end;

  TopEl:= APanel;
  Y:= 0;
  AddEl(AxmlElement, APanel, 0);
  APanel.Height:= Y;
  {
  if APanel.Width < X
  then APanel.Width:= X;
  }
  APanel.Visible:= True;
end;

function FindElementGroup(AxmlElement: TxmlElement; APanel: TWinControl;
  var AControl: TWinControl; var ALastControl: TWinControl): Boolean;
var
  i, e: Integer;
  c: TWinControl;
begin
  i:= 0;
  Result:= False;
  if AxmlElement = Nil
  then Exit;
  while i < APanel.ComponentCount do begin
    if APanel.Components[i].Tag = Integer(AxmlElement) then begin
      AControl:= TWinControl(APanel.Components[i]);
      ALastControl:= AControl;
      e:= 0;
      while e < APanel.ComponentCount do begin
        c:= TWinControl(APanel.Components[e]);
        if c.Top > TWinControl(ALastControl).Top
        then ALastControl:= c;
        Inc(e);
      end;
      Result:= True;
      Break;
    end;
    Inc(i);
  end;
end;

procedure MoveControls(APanel: TWinControl; AFrom: TPoint; AInc: TPoint);
var
  i: Integer;
  y: Integer;
begin
  i:= 0;
  if AInc.Y > 0 then begin
    while i < APanel.ComponentCount do begin
      y:= TWinControl(APanel.Components[i]).Top;
      if (y > AFrom.Y) then begin
        TWinControl(APanel.Components[i]).Top:= y + AInc.Y;
      end;
      Inc(i);
    end;
  end else begin
    while i < APanel.ComponentCount do begin
      y:= TWinControl(APanel.Components[i]).Top;
      if (y < AFrom.Y) then begin
        TWinControl(APanel.Components[i]).Top:= y + AInc.Y;
      end;
      Inc(i);
    end;
  end;
  APanel.Height:= APanel.Height + AInc.Y 
end;

function InsertxmlElement2Panel(AxmlElement: TxmlElement;
  ATopElement: TWinControl;
  AButtonImages: TCustomImageList;
  AOnElementChange: TOnElementChange;
  AToolButtonNewClick: TNotifyEvent): Boolean;
var
  pp, p: TPoint;
  c: TWinControl;
  n: TWinControl;
  PersistentClass: TPersistentClass;
  LastControl: TWinControl;
  ToolbarElements: TToolBar;
  ps: TPageScroller;
begin
  Result:= False;
  if not FindElementGroup(AxmlElement.ParentElement, ATopElement, c, LastControl)
  then Exit;
  pp.x:= c.Left;
  pp.y:= LastControl.Top;
  p:= pp;
  Inc(p.Y, 24);
  Inc(p.X, BLOCK_INDENT);
  with AxmlElement do begin
    n:= TButton.Create(ATopElement);
    with TButton(n) do begin
      Tag:= Integer(AxmlElement);
      Caption:= AxmlElement.GetElementName;
      Left:= p.x;
      Top:= p.y;
      Parent:= ATopElement;
    end;

    ps:= TPageScroller.Create(ATopElement);
    with ps do begin
      Left:= p.x + n.Width;
      Top:= p.y;
      Width:= ATopElement.Width - p.X - n.Width;
      Height:= 22;
      Parent:= ATopElement;
    end;

    ToolbarElements:= TToolBar.Create(ATopElement);
    ps.Control:= ToolbarElements;
    with ToolbarElements do begin
      EdgeBorders:= [];
      Flat:= True;
      Parent:= ps;
      Images:= AButtonImages;
      Align:= alLeft;
      Autosize:= True;
      NestedElements2ToolButtons(AxmlElement, ToolbarElements, AToolButtonNewClick);
      Left:= 0;
      Top:= 0;
    end;

    Inc(p.Y, n.Height + 8);
  end;
  MoveControls(ATopElement, pp, Point(0, 24));
end;

// like windex.wmls#calculate('$(height)', '$(weight)')
function Valid_WML_N_ScriptURL(AUri: String): Boolean;
begin
  Result:= True;
end;

function SearchAttributePosition(const ATag, AAttribute: TwmlpString; AValueOnly: Boolean; var AStartPos, ALen: Integer;
  var EQSignRequried: Boolean): Boolean;
var
  i, st, stname, fn: Integer;
  pstate: Integer;  // states: 0- name, 1-wait_value 2-value 3-value with " 4- next parameter
  vl: String;
  L: Integer;

  function CheckAttribute(atrlen: Integer): Boolean;
  begin
    Result:= False;
    if CompareText(AAttribute, vl) <> 0
    then Exit;
    if AValueOnly then begin
      AStartPos:= st;
      ALen:= atrlen;
    end else begin
      AStartPos:= stname;
      ALen:= st - stname + atrlen;
    end;
    Result:= True;
  end;

begin
  // search atrributes
  Result:= True;
  EQSignRequried:= False;
  // prepare to search
  i:= 1;
  // skip tag name
  while i <= Length(ATag) do begin
    if (ATag[i] <= #32) or (ATag[i] = '>') or (ATag[i] = WideLineSeparator)
    then Break;
    Inc(i);
  end;
  pstate:= PS_NEXTPARAM;
  L:= Length(ATag);
  // skip last '>' and '/>' chars
  if (L > 0) and (ATag[L] = '>') then begin
    Dec(L);
    if (L > 0) and (ATag[L] = '/')
    then Dec(L);
  end;

  fn:= 0;  // just supress compiler warning
  while i <= L do begin
    if pstate = PS_NEXTPARAM then begin
      { skip spaces before parameter pair start }
      while i < Length(ATag) do begin
        if ((ATag[i] > #32) and (ATag[i] <> WideLineSeparator)) or (ATag[i] = '>')
        then Break;
        Inc(i);
      end;
      st:= i;
      fn:= st-1;
      stname:= i;
      pstate:= PS_NAME;
    end;
    case ATag[i] of
    #1..#32, WideLineSeparator, WideParagraphSeparator
    :begin
           case pstate of
           PS_VALUE: begin
               if CheckAttribute(fn-st+1)
               then Exit;
               st:= i;
               pstate:= PS_NEXTPARAM;  // 4
             end;
           PS_NAME: begin
               pstate:= PS_SPACEAFTERNAME;
             end;
           end;
         end;
    '=': begin
           if pstate in [PS_NAME, PS_SPACEAFTERNAME] then begin  // 0
             vl:= Copy(ATag, st, fn-st+1);
             st:= i + 1;
             pstate:= PS_WAITVALUE;  // 1
           end;
         end;
    '"': begin  // ' single quote is not acceptable
           case pstate of
           PS_WAITVALUE:begin
               pstate:= PS_QUOTEDVALUE;
               st:= i;
             end;
           PS_QUOTEDVALUE:begin
             // element's attribute
             if CheckAttribute(i-st+1)
             then Exit;
             pstate:= PS_NEXTPARAM;  // 4
             end;
           end;
         end;
    '''': begin  // but it happens...
           case pstate of
           PS_WAITVALUE:begin
               pstate:= PS_SINGLE_QUOTE;
               st:= i;
             end;
           PS_SINGLE_QUOTE:begin
               // element's attribute
               if CheckAttribute(i-st+1)
               then Exit;
               pstate:= PS_NEXTPARAM;  // 4
             end;
           end; { case }
         end;
    '>': begin
           case pstate of
           PS_WAITVALUE:begin  // 1
               pstate:= PS_NEXTPARAM;
               if CheckAttribute(i-st)
               then Exit;
             end;
           PS_NAME:begin  // 3
               vl:= Copy(ATag, st, fn-st+1);
               st:= i;
               // pstate:= PS_NEXTPARAM; // it does not matter
               if CheckAttribute(0) then begin
                 EQSignRequried:= True;
               end else begin
                 //  end of tag found, exit
                 AStartPos:= i;
                 ALen:= 0;
                 Result:= False;
               end;
               Exit;
             end;
           end;
         end;
      else begin
        case pstate of
        PS_WAITVALUE: begin
            pstate:= PS_VALUE;
            st:= i;
          end;
        PS_SPACEAFTERNAME: begin
            vl:= Copy(ATag, st, fn-st+1);
            st:= i - 1;
            if CheckAttribute(0) then begin
              EQSignRequried:= True;
              Exit;
            end;
            pstate:= PS_NEXTPARAM;
          end;
        end;
        fn:= i;
      end; { else case }
    end; { case  attributes }
    Inc(i);
  end; { while, attributes }

  // last attribute
  case pstate of
  PS_VALUE: begin
      if CheckAttribute(i-st)
      then Exit;
    end;
  PS_NAME, PS_SPACEAFTERNAME: begin
      // in case of ... par>
      vl:= Copy(ATag, st, fn-st+1);
      st:= i;
      if CheckAttribute(0) then begin
        EQSignRequried:= True;
        Exit;
      end;
    end;
  end;

  // look for tag finish to return place where to add new attribute
  AStartPos:= Length(ATag);
  if AStartPos > 2 then begin
    // check for terminator
    if ATag[AStartPos - 1] = '/' // - 1 added. 09 Oct 2003
    then Dec(AStartPos);
  end;
  // length
  ALen:= 0;
  Result:= False;
end;

end.
