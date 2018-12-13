unit
  xmlidx;
(*##*)
(*******************************************************************************
*                                                                             *
*   X  M  L  I  D  X                                                           *
*                                                                             *
*   Copyright © 2001- 2003 Andrei Ivanov. All rights reserved.                 *
*   Part of apooed                                                            *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Oct 29 2003                                                 *
*   Last revision: Oct 29 2003                                                *
*   Lines        : 842                                                         *
*   History      :                                                            *
*                                                                              *
*                                                                             *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)
{$BOOLEVAL OFF}
{$DEFINE XML_IDX}
interface

uses
  Classes, SysUtils, strutils,
  jclUnicode, IdxStruct;

// ----------------------- Index builder thread --------------------------------

const
  MAX_CYCLES = 1024 * $10;

type
  TTagAttrProc = procedure(const ATag: ShortString; const AAttr: WideString; var AValue: WideString) of object;
  TOnTag = procedure(ATerminated, ATerminal: Boolean) of object;
  TDictStrings = TStrings;
  TDictStringList = TStringList;
  TxmlIndexateCustomThread = class(TCustomProgressThread)
  private
    FstrmFinalWrd, { output stream, must be opened }
    FstrmFinalFld,
    FstrmFinalLoc,
    FstrmFinalKey,
    FstrmFinalTag: TStream;

    FDel2OftenWords,
    FDel2ShortWord,
    FDel2LongDigit: Integer;

    FRecNo: Cardinal;
    FRec: WideString;
    FCurTime: TDateTime;
    FReportProc: TReportProc;
    FWordCallback: TTagAttrProc;

    FFilesList: TStrings;

    procedure AddValue2Words(const ATag: ShortString; const AAttr: WideString; var AValue: WideString);
    procedure AddValue2Locs(const ATag: ShortString; const AAttr: WideString; var AValue: WideString);
  protected
    procedure DoRecords; virtual;
    procedure Execute; override;
  public
    SLWord: THashWordList;
    SLTag: THashWordList;
    WF2Loc: TWordFld2LocFileList; // TWordFld2LocCustomList TWordFld2LocFileList TWordFld2LocMemoryList

    constructor Create(ASuspended: Boolean; ADel2OftenWords, ADel2ShortWord, ADel2LongDigit: Integer;
      AFiles: TStrings;
      AstrmFinalWrd, AstrmFinalFld, AstrmFinalLoc, AstrmFinalKey, AstrmFinalTag: TStream; AReportProc: TReportProc);
    destructor Destroy; override;
  end;

  TxmlIndexateFileListThread = class(TxmlIndexateCustomThread)
  public
    constructor Create(ASuspended: Boolean; ADel2OftenWords, ADel2ShortWord, ADel2LongDigit: Integer;
      const AFileList: String;
      AstrmFinalWrd, AstrmFinalFld, AstrmFinalLoc, AstrmFinalKey, AstrmFinalTag: TStream; AReportProc: TReportProc);
  end;

  TxmlIndexateFilesThread = class(TxmlIndexateCustomThread)
  public
    constructor Create(ASuspended: Boolean; ADel2OftenWords, ADel2ShortWord, ADel2LongDigit: Integer;
      const AMaskList: String;
      AstrmFinalWrd, AstrmFinalFld, AstrmFinalLoc, AstrmFinalKey, AstrmFinalTag: TStream; AReportProc: TReportProc);
  end;

  // ---------------------- TxmlPhraseThread -------------------------------------

  TxmlPhraseThread = class(TCustomProgressThread)
  private
    FstrmFinalPhrase: TStream; { output stream, must be opened }
    FSkipAttributes: Boolean;
    FSkipElements: TStrings;
    FOutputUnicode: Boolean;
    FCurTime: TDateTime;
    FReportProc: TReportProc;
    FFilesList: TStrings;
    FDefault_EmptyStr: WideString;
    procedure AddValue2Phrase(const ATag: ShortString; const AAttr: WideString; var AValue: WideString);
  protected
    SLPhrase: TPersistent; // TWordList; TWideWordList;
    procedure Execute; override;
  public
    constructor Create(ASuspended: Boolean; ACaseSensitive, AOutputUnicode, ASkipAttributes: Boolean;
      ASkipElements: TStrings; const AXMLUrlList: String;
      AFstrmFinalPhrase: TStream; AReportProc: TReportProc;
      ADefault_EmptyStr: WideString);
    destructor Destroy; override;
  end;

  // ---------------------- TxmlPhraseReplaceThread ----------------------------

  TxmlPhraseReplaceThread = class(TCustomProgressThread)
  private
    FCurTime: TDateTime;
    FSkipAttributes: Boolean;
    FSkipElements: TStrings;
    FReportProc: TReportProc;
    FFilesList: TStrings;
    FDefault_EmptyStr: WideString;
    procedure ReplacePhrase(const ATag: ShortString; const AAttr: WideString; var AValue: WideString);
  protected
    FSLPhraseTemplate,
    FSLPhraseReplace: TDictStrings;
    procedure Execute; override;
  public
    Rslt: WideString;
    constructor Create(ASuspended: Boolean; ACaseSensitive, AOutputUnicode, ASkipAttributes: Boolean;
      ASkipElements: TStrings;
      const AXMLUrlList: String; ASLPhraseTemplate, ASLPhraseReplace: TDictStrings;
      AReportProc: TReportProc);
    destructor Destroy; override;
  end;

// ---------------------- Search component -------------------------------------

const
  MINSRCHWORDLEN     = 2;          { chars in one word to search }
  TILDCHAR           = '~';
  TILDLIKECHARSET    = ['*', '?']; { chars replaced with "~" }
  DELIMITERS         = [#0..')','+'..'/',':'..'>','@','['..'`','{'..'}'];

type
  { alg select }
  TSelectLevel = LongInt;
  TAlgRec = record
    o: TLocRec;
    l: TSelectLevel;
  end;
  TAlgRecArray = array [0..15] of TAlgRec;

  TSelectedRecs = class (TObject)
  private
    FEmptyRec: TAlgRec;
    FRecAllocStep: Integer;
    FCount: Integer;
    FAlloc: Integer;
    FAlgRecArray: ^TAlgRecArray;
    FCurRec: ^TAlgRec;
    function AllocSpace: Boolean;
    procedure AlgrecQuickSort(L, R: Integer);
    function  FGetLevel(recofs: Integer): TSelectLevel;  { return TSelectLevel (0 if not) }
    procedure FSetLevel(recofs: Integer; level: TSelectLevel);
    function  FGetByOrd(ind: Integer): TAlgRec;
    procedure FSetByOrd(ind: Integer; newrec: TAlgRec);
    function FCountLevel(AlevelMask: TSelectLevel): Integer;
  public
    MaxSize: Integer;
    ExtraRecords: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(recofs: Integer);
    procedure Mul(recofs: Integer; Level: TSelectLevel); { or Level }
    procedure Sort;
    procedure DeleteDups; // after Sort!!
    property  Count: Integer read FCount;
    property  CountLevel[mask: TSelectLevel]: Integer read FCountLevel;
    property  Level[ind: Integer]: TSelectLevel read FGetLevel write FSetLevel;
    property  RecByOrd[ind: Integer]: TAlgRec read FGetByOrd write FSetByOrd;
  end;

  TFldsArray = array[0..0] of idxStruct.TWordFld2LocItemFld;
  PSearchContext = ^TSearchContext;
  TSearchContext = record
    FWord: String[32];
    FWilds: Word;
    FldCount: Word;
    Flds: TFldsArray;
  end;

  TSearchWords = class (TObject)
  private
    FSearchContextPtrs: array of PSearchContext;
    procedure QuickSort(L, R: Integer);
  protected
    function GetLen: Integer;
    function GetSearchContextPtr(AIndex: Integer): PSearchContext;
    { function GetWord(AIndex: Integer): String; }
  public
    property Count: Integer read GetLen;
    property SearchContextPtr [Idx: Integer]: PSearchContext read GetSearchContextPtr;
    // property Words [Idx: Integer]: String read GetWord;
    constructor Create;
    destructor Destroy; override;
    function Add(AWord: String; AWilds: Integer; AField: TWordFld2LocItemFld): Integer;
    procedure Delete(AIndex: Integer);
    procedure Sort;
    procedure Clear;
  end;

  TInvSearch = class(TComponent)
  private
    FMinWordLen,
    FMaxWords: Integer;
    FFileList: TStrings;
    strmWRD,
    strmFLD,
    strmLOC: TFileStream;
    FFldSort, // field and subfield to sort
    FCurSearchWord: String;
    FWordBuf: ANSIString;
    FSearchWords: TSearchWords;

    Status: Integer;
    SelectedRecs: TSelectedRecs;
    FFoundCount,
    FoundLevels: Integer;

    procedure SetMinWordLen(const AMinWordLen: Integer);
    procedure SetMaxWords(const AMaxWords: Integer);

    function  GetWordsAllFields: String;
    procedure SetWordsAllFields(Srch: String);
    function GetXMLRecord(no: Integer): WideString;
    function GetXMLUrl(no: Integer): String;

    procedure QuickSort(L, R: Integer);
    procedure ReleaseStreams;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadIndex(const AIndexName: String);
    procedure ClearFieldWords;

    function  GetFieldWords(AField: TWordFld2LocItemFld): WideString;
    procedure SetFieldWords(AField: TWordFld2LocItemFld; const ASrch: WideString);

    property FieldWords[Field: TWordFld2LocItemFld]: WideString read GetFieldWords write SetFieldWords;
    procedure Search;
    property FoundCount: Integer read FFoundCount;
    property Records[no: Integer]: WideString read GetXMLRecord;
    property Urls[no: Integer]: String read GetXMLUrl;
    // Field = -1 - all fields
    procedure Sort;
  published
    property WordsAllFields: String read GetWordsAllFields write SetWordsAllFields;
    property MinWordLen: Integer read FMinWordLen write SetMinWordLen;    // MINWORDLEN..
    property MaxWords: Integer read FMaxWords write SetMaxWords;          // 8..256
    property FldSort: String read FFldSort write FFldSort;
  end;

function LoadListOfFiles(const AFileName: String): TStrings;

procedure Register;

implementation

uses
  Windows,
  util1, util_xml, wmlc,
  // dfmparse,
  wmlurl;

const
  WORDLENMAX = 32;

resourcestring
  STRRES_WORD_START = 'Creating words list...';
  STRRES_WORD_FINISH = 'Words list created (%d words, %d records, %.1f words per minute)';
  STRRES_LOC_START   = 'Creating locations..';
  STRRES_LOC_FINISH  = 'Locations created';  //  '—писок локаций создан'
  STRRES_SORT_START  = 'Sort %d locations, starts at %s ..';
  STRRES_SORT_FINISH = 'Locations sorted, finished at %s';
  STRRES_RMDUP_START  = 'Delete duplicated locations, starts at %s ..';
  STRRES_RMDUP_FINISH = '%d duplicated location(s) deleted, finished at %s';

  STRRES_FLT_START   = 'Filter records..';   // '”даление шумовых слов..'
  STRRES_FLT_FINISH  = 'Filtering done.';
  STRRES_LOC_STORE   = 'Locations store..'; // '«апись loc..'
  STRRES_LOC_STORED  = 'Locations stored.'; // '«апись loc..'
  STRRES_LOC_ZERO    = 'No locations found.'; // '«апись loc..'

  STRRES_PHRASE_FILE = 'File %s done.';
  STRRES_PHRASE_FINISH = 'Phrase list created (%d documents, %.1f words per minute)';
  ERRRES_PHRASE_FILE  = 'Error: %s while storing (%d documents, %.1f words per minute)';

const
  PS_NAME        = 0;
  PS_WAITVALUE   = 1;
  PS_VALUE       = 2;
  PS_QUOTEDVALUE = 3;
  PS_SINGLE_QUOTE= 4;
  PS_NEXTPARAM   = 5;
  PS_SPACEAFTERNAME = 6;

type
  TToken = (etEnd, etPCData, etxmlTag, etComment, etssScript, etXML, etDocType);

function GetSource(const fn: String; var Src: WideString; var bookmark: string; var AEncoding: Integer): Integer;
var
  strmtxt,
  strm: TStream;
  wr: TWriter;
  h: Byte;
  sz: Cardinal;
  s: String;
begin
  Result:= umOK;
  
  if CompareText('.DFM', Copy(fn, Length(fn) - 3, MaxInt)) <> 0 then begin
    Result:= wmlurl.GetSrcFromURI(fn, src, bookmark, AEncoding);
    Exit;
  end;
  strm:= TFileStream.Create(fn, fmOpenRead);
  strm.Read(h, 1);
  strm.Position:= 0;
  if (h and $F0) = $F0 then begin
    raise Exception.Create('Error! DFM must be in text!');
    strmtxt:= TMemoryStream.Create;
    {
    wr:= TWriter.Create(strm, 1024);
    wr.UseQualifiedNames:= False;
    wr.WriteDescendent(f, Nil);
    wr.Free;
    strm.Position:= 0;
    }
    ObjectBinaryToText(strm, strmtxt);   
    src:= TStringStream(strmtxt).DataString;
    strmtxt.Free;
  end else begin
    sz:= strm.Size;
    SetLength(s, sz);
    strm.Read(s[1], sz);
    Src:= s;
  end;
  bookmark:= '';
  AEncoding:= csUTF8;
  strm.Free;
end;


function ParseDfm(const ASrc: WideString; ATransProc: TTagAttrProc; const AResult: PWideString): Boolean;
var
  FTokenString: WideString;
  spaces, p, L: Integer;
  sP: PWideChar;
  tok: TToken;
  s, nm: String;
  // v: String;
  vl: WideString;
  isstr: Boolean;

  procedure NextToken;
  var
    POld: PWideChar;
  begin
    FTokenString:= '';
    // skip first empty
    POld:= sP; // keep to remember spaces before PCDATA to add space
    while (sP^ <> #0) and (sP^ <> #13)
    do Inc(sP);

    SetString(FTokenString, POld, sP - POld);

    if sP^ = #0 then  tok:= etEnd
    else begin
      tok:= etPCData;
      Inc(sP, 2);
    end;
  end;


begin
  Result:= True;
  if Length(ASrc) = 0
  then Exit;
  sp:= PWideChar(ASrc);
  while True do begin
    NextToken;
    case tok of
      etPCData: begin
        spaces:= 1;
        L:= Length(FTokenString);
        while (spaces <= L) and (FTokenString[spaces] = #32) do begin
          Inc(spaces);
        end;

        s:= Trim(FTokenString);
        p:= Pos('=', s);
        if p > 0 then begin
          nm:= Trim(Copy(s, 1, p - 1));
          vl:= util1.PascalString2WideString(Trim(Copy(s, p + 1, MaxInt)), isstr);
          if isstr then begin
            if (CompareText(nm, 'HINT') = 0) or
            (CompareText(nm, 'CAPTION') = 0) or
            (CompareText(nm, 'TEXT') = 0)
              then ATransProc('', '', vl);
            if Assigned(AResult) then begin
              s:= util1.WideString2PascalString(vl);
              AResult^:= AResult^ + strutils.DupeString(#32, spaces - 1) + nm + ' = ' + s + #13#10
            end;
          end else begin
            if Assigned(AResult) then begin
              AResult^:= AResult^ + FTokenString + #13#10;
            end;
          end;
        end else begin
          if Assigned(AResult) then begin
            AResult^:= AResult^ + FTokenString + #13#10;
          end;
        end;
      end;
      etEnd: Break;
    end; // case
  end; // while
end;


//function ParseDfm(const ASrc: WideString; ATransProc: TTagAttrProc; const AResult: PWideString): Boolean;
//var
//  i: Integer;
//begin
//  //
//  dfmparse.LoadDFMFile(
//end;

function ParseXml(const ASrc: WideString;
  ATagProc: TTagAttrProc; AAttrProc: TTagAttrProc; const AResult: PWideString): Boolean;

const
  PCDATA_ATTR = '';

var
  FTokenString: WideString;
  // WhereTagStart, WhereTagFinish: PWideChar;
  i, p, L, tlen: Integer;
  sP: PWideChar;
  st, fn,
  pstate: Integer;  // PS_NAME=0- name, ...
  TagName: ShortString;
  tok: TToken;
  vl: String;
  ContinueParse: Boolean;
  TerminalTag: Boolean;   // </element>
  TerminatedTag: Boolean; // <element ../>

  procedure NextToken;
  var
    TokenStart, POld: PWideChar;
  begin
    FTokenString:= '';
    // skip first empty
    POld:= sP; // keep to remember spaces before PCDATA to add space
    while ((sP^ <> #0) and (sP^ <= #32)) or (sP^ = WideLineSeparator) or (sP^ = WideParagraphSeparator)
    do Inc(sP);

    // FTokenPtr:= sP;
    case sP^ of
    #0: begin
        tok:= etEnd;
        end;
    '<':begin
      // WhereTagStart:= sp;
      Inc(sP);
      TokenStart:= sP;
      while (sP^ <> #0) and (sP^ <> '>') 
      do Inc(sP);
      // WhereTagFinish:= sp;
      SetString(FTokenString, TokenStart, sP - TokenStart);
      // default tag
      tok:= etxmlTag;
      // look for special tags: !DOCTYPE
      if Length(FTokenString) > 1 then begin
        case FTokenString[1] of
        '?':tok:= etXML;
        '!':begin
              if Pos('DOCTYPE', UpperCase(FTokenString)) = 2 then begin
                tok:= etDocType;
              end else begin
                tok:= etComment;
                // in comments > is allowed, so check is it  -->
                while (sP^ <> #0) and ((sP - 1)^ <> '-') do begin
                  Inc(sP);
                  while (sP^ <> #0) and (sP^ <> '>')
                  do Inc(sP);
                end;
                // 2008/08/05
                SetString(FTokenString, TokenStart, sP - TokenStart);
              end;
            end;
        '%':begin
              tok:= etssScript;
              // in comments > is allowed, so check is it  %>
              while (sP - 1)^ <> '%' do begin
                case  sP^ of
                  #0,
                  '>': Break;
                  else Inc(sP);
                end;
              end;
            end;
        end; { case }
      end;
      Inc(sP);
    end;
    else begin
      TokenStart:= POld;  // kept spaces before PCDATA to add space
      // WhereTagStart:= sp;
      while (sP^ <> #0) and (sP^ <> '<')
      do Inc(sP);
      // WhereTagFinish:= sp;
      // Dec(WhereTagFinish); // except last '<'. if eof?
      tok:= etPCData;
      SetString(FTokenString, TokenStart, sP - TokenStart);
    end;
    end;
  end;

  procedure AddAttribute(ALen: Integer);
  var
    attrval: WideString;
  begin
    attrval:= Copy(FTokenString, st, ALen);
    if Assigned(AAttrProc)
    then AAttrProc(tagname, vl, attrval);
    if Assigned(AResult) then AResult^:= AResult^ + vl + '="' + attrval + '" ';
  end;

  procedure ParseAttributes; // i points to start position. L indicates length of FTokenString
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
               AddAttribute(fn - st + 1);
               st:= i;
               pstate:= PS_NEXTPARAM;
             end else begin
               if pstate = PS_NAME
               then pstate:= PS_SPACEAFTERNAME;
             end;
           end;
      '=': begin
             if pstate in [PS_NAME, PS_SPACEAFTERNAME] then begin
               vl:= Copy(FTokenString, st, fn - st + 1);
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
        AddAttribute(i - st);
      end;
    PS_NAME, PS_SPACEAFTERNAME: begin
        // in case of ... par>
        if (fn > st + 1) then begin
          vl:= Copy(FTokenString, st, fn-st+1);
          AddAttribute(0);  // no value, just attribute name
        end;
      end;
    end;
  end;

begin
  Result:= True;
  ContinueParse:= True;
  if Length(ASrc) = 0
  then Exit;
  // sp:= @(ASrc[1]);
  sp:= PWideChar(ASrc);
  while ContinueParse do begin
    NextToken;
    case tok of
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
      // extract tag name
      TagName:= Copy(FTokenString, p, tlen);

      if TerminalTag then begin  // e.g. </element>
        if Assigned(AResult) then AResult^:= AResult^ + '</' + TagName+ '>'#13#10;
      end else begin
        if Assigned(AResult) then AResult^:= AResult^ + '<' + TagName + ' ';
        // add attributes
        ParseAttributes;
        if Assigned(AResult) then begin
          if TerminatedTag
          then AResult^:= AResult^ + '/>'#13#10
          else AResult^:= AResult^ + '>'#13#10;
        end;
      end;

    end; { etxmlTag }
    etComment, etDocType, etssScript, etXML: begin
      // ATagProc(TagName, PCDATA_ATTR, FTokenString);
      if Assigned(AResult) then AResult^:= AResult^ + '<' + FTokenString + '>'#13#10;
    end;
    etPCData: begin
       // add PCData element
       ATagProc(TagName, PCDATA_ATTR, FTokenString);
       if Assigned(AResult) then AResult^:= AResult^ + FTokenString;
    end;
    etEnd: Break;
    end; { case }
  end; { while }
end;

// ----------------------- Index builder thread --------------------------------

constructor TxmlIndexateCustomThread.Create(ASuspended: Boolean; ADel2OftenWords, ADel2ShortWord, ADel2LongDigit: Integer;
  AFiles: TStrings;
  AstrmFinalWrd, AstrmFinalFld, AstrmFinalLoc, AstrmFinalKey, AstrmFinalTag: TStream; AReportProc: TReportProc);
begin
  FreeOnTerminate:= True;
  FReportProc:= AReportProc;

  FDel2OftenWords:= ADel2OftenWords;
  FDel2ShortWord:= ADel2ShortWord;
  FDel2LongDigit:= ADel2LongDigit;
  // FReserved:= AReserved;


  if Assigned(AFiles) then begin
    FFilesList:= TStringList.Create;
    FFilesList.Assign(AFiles);
  end;
  
  FstrmFinalWrd:= AstrmFinalWrd;  { output stream, must be opened }
  FstrmFinalFld:= AstrmFinalFld;
  FstrmFinalLoc:= AstrmFinalLoc;
  FstrmFinalTag:= AstrmFinalTag;
  FstrmFinalKey:= AstrmFinalKey;
  SLWord:= THashWordList.Create;
  SLTag:= THashWordList.Create;

  WF2Loc:= TWordFld2LocFileList.Create; //TWordFld2LocMemoryList.Create;

  inherited Create(ASuspended, AReportProc);
end;

destructor TxmlIndexateCustomThread.Destroy;
begin
  WF2Loc.Free;
  SLTag.Free;
  SLWord.Free;
  FFilesList.Free;
  inherited Destroy;
end;

function GetWord(var ASrc: PWideChar): WideString;
var
  sP: PWideChar;
  len: Integer;
begin
  { slow!
  while (ASrc^ <> #0) and (not jclUnicode.UnicodeIsAlphaNum(Cardinal(ASrc^)))
  do Inc(ASrc);
  sp:= ASrc;
  while (ASrc^ <> #0) and jclUnicode.UnicodeIsAlphaNum(Cardinal(ASrc^))
  do Inc(ASrc);
  Result:= jclUnicode.WideLowerCase(Copy(sp, 1, ASrc - sp));
  }
  while (ASrc^ > #0) and ((ASrc^ < '0') or
    ((ASrc^ > '9') and (ASrc^ < 'A')) or
    ((ASrc^ > 'Z') and (ASrc^ < 'a')) or
    ((ASrc^ > 'z') and (ASrc^ < #$BC)))
  do Inc(ASrc);
  sp:= ASrc;

  while (ASrc^ >= '0') and (
    (ASrc^ <= '9') or
    ((ASrc^ >= 'A') and (ASrc^ <= 'Z')) or
    ((ASrc^ >= 'a') and (ASrc^ <= 'z')) or
    (ASrc^ >= #$BC)
    )
  do Inc(ASrc);
  len:= ASrc - sp;
  SetLength(Result, len);
  Move(sp^, Result[1], len * SizeOf(WideChar));
end;

function GetWordPWideChar(var ASrc: PWideChar; var AWord: PWideChar): Integer; // length
begin
  while (ASrc^ > #0) and (ASrc^ <= #32)
  do Inc(ASrc);
  AWord:= ASrc;
  while (ASrc^ > #32)
  do Inc(ASrc);
  Result:= ASrc - AWord;
end;

{ just words }

procedure TxmlIndexateCustomThread.AddValue2Words(const ATag: ShortString; const AAttr: WideString; var AValue: WideString);
var
  pc: PWideChar;
  vl: WideString;
begin
  // if Length(AValue) = 0 then Exit;
  pc:= PWideChar(AValue);
  SLTag.AddNewWordOrd(UpperCase(ATag));
  {
  // wrong but faster. And problem with "" ?!!
  repeat
    cnt:= GetWordPWideChar(pc, wc);
    if cnt = 0
    then Exit;
    Windows.CharUpperBuffW(wc, cnt);
    if cnt > 32
    then cnt:= 32;
    SLWord.AddNewWord(jclUnicode.WideStringToUTF8(jclUnicode.StrLCopyW(@buf, wc, cnt)));
  until False;
  }
  // correct but slow
  repeat
    vl:= GetWord(pc);
    if Length(vl) = 0
    then Exit;
    SLWord.AddNewWord(jclUnicode.WideStringToUTF8(jclUnicode.WideUpperCase(vl)));
  until False;
end;

{ just  locations. First look in words }
{ Srch          - word
    -> idx of word
  FElementName - field name, like '100'
  FRecOfs       - record offset
}
procedure TxmlIndexateCustomThread.AddValue2Locs(const ATag: ShortString; const AAttr: WideString; var AValue: WideString);
var
  idx: Integer;
  it: TWordFld2LocItem;
  pc: PWideChar;
  vl: WideString;
begin
  pc:= PWideChar(AValue);
{$IFDEF XML_IDX}
{$ELSE}
  l:= Length(ATag);
  sz:= SizeOf(TWordFld2LocItemFld);
  if l > sz
  then l:= sz;
{$ENDIF}
  repeat
    vl:= GetWord(pc);
    if Length(vl) = 0 then Break;
    if SLWord.Find(jclUnicode.WideStringToUTF8(jclUnicode.WideUpperCase(vl)), idx) then begin  // must be True!
      with it do begin
        Wrd:= idx;
{$IFDEF XML_IDX}
        Fld:= TWordFld2LocItemFld(SLTag.Data[ATag]);
{$ELSE}
        strLcopy(it.Fld, PChar(@ATag[1]), l);
        if l < sz
        then FillChar(fld[l], sz - l, #0);
{$ENDIF}
        loc:= FRecNo;
      end;
      { if pair does not exist, add }
      // DM.WF2Loc.Add(it)
      WF2Loc.DirectAddItem(it);
    end;
  until False;
end;

{
  FstrmLDB- input stream
  for each record (to FLastRecordNo - last record (started with 0)) do next steps:
    1.  set FElementName - field name, like '100'
    2.  set FRecOfs       - record offset
    3a. (opt) if FAllFields or FFieldList.IndexOfName(field)>=0 do next step
    3.  call FWordCallback(Word) callback
    4.  (opt) reflect FActualRecordCount
}
procedure TxmlIndexateCustomThread.DoRecords;
var
  Len: Word;
  { field }
  cnt: Cardinal;
  bookmark: String;
  encoding: Integer;
  fn: String;
begin
  cnt:= FFilesList.Count;
  FRecNo:= 0;
  while FRecNo < cnt do begin;
    if Terminated
    then Exit;
    Progress:= FRecNo;
    ProgressCount:= cnt;
    // read xml file
    if GetSource(fn, FRec, bookmark, encoding) = umOK then begin
      ProgressState:= fn;

      len:= Length(FRec);
FRec:= FRec + #0;
      if (len > 0)
        then if CompareText('.DFM', Copy(fn, Length(fn) - 3, MaxInt)) = 0
          then ParseDfm(FRec, FWordCallback, Nil)
          else ParseXml(FRec, FWordCallback, FWordCallback, Nil);
    end;
    Inc(FRecNo);
  end;
end;

function PerMin(ACount: Integer; ADiffDateTime: TDateTime): Extended;
begin
  if Abs(ADiffDateTime) <= 1 / SecsPerDay
  then Result:= ACount
  else Result:= ACount / (MinsPerDay * ADiffDateTime);
end;

procedure TxmlIndexateCustomThread.Execute;
var
  // optimize
  WordCount,
  // store index
  wrdrec, oldwrdrec, L, Fldcount: Integer;
  // delete too often words start-finish loc
  locst, locfin: Integer;
  fld, oldfld: TWordFld2LocItemFld;
  CurWord: ShortString;
  locIdx: Integer;
  it: TWordFld2LocItem;
  cnt: Cardinal;
begin
  FCurTime:= Now;
  cnt:= FFilesList.Count;

  // fill index
  ProgressState:= STRRES_WORD_START;
  Report(Progress, ProgressCount, ProgressState);

  // expected count of records of 0.5K each

  FWordCallback:= AddValue2Words;
  ProgressState:= 'Creating words list';
  Report(Progress, ProgressCount, ProgressState);
  DoRecords;

  ProgressState:= 'Order words list';
  Report(Progress, ProgressCount, ProgressState);
  SLWord.CheckSortList;

  ProgressState:= Format(STRRES_WORD_FINISH, [SLWord.Count, cnt,
    PerMin(SLWord.Count, Now - FCurTime)]);
  Report(Progress, ProgressCount, ProgressState);

  FCurTime:= Now;
  if Terminated
  then Exit;

  ProgressState:= STRRES_LOC_START;
  Report(Progress, ProgressCount, ProgressState);

  FWordCallback:= AddValue2Locs;
  ProgressState:= 'Creating locations list';
  Report(Progress, ProgressCount, ProgressState);
  DoRecords;

  // sort
  ProgressState:= Format(STRRES_SORT_START, [WF2Loc.Count, TimeToStr(Now)]);
  Report(Progress, ProgressCount, ProgressState);

//  util1.String2File('0dbg.txt', DM.WF2Loc.GetText(DM.SLWord));
  ProgressState:= 'Sort locations list';
  Report(Progress, ProgressCount, ProgressState);
  WF2Loc.Sort;
  ProgressState:= Format(STRRES_SORT_FINISH, [TimeToStr(Now)]);
  Report(Progress, ProgressCount, ProgressState);

  // if FReserved then begin
  // remove duplicates
  ProgressState:= Format(STRRES_RMDUP_START, [TimeToStr(Now)]);
  Report(Progress, ProgressCount, ProgressState);

  L:= WF2Loc.RmDuplicates;
  ProgressState:= Format(STRRES_RMDUP_FINISH, [L, TimeToStr(Now)]);
  Report(Progress, ProgressCount, ProgressState);

  ProgressState:= STRRES_LOC_FINISH;
  Report(Progress, ProgressCount, ProgressState);

  FCurTime:= Now;
  if Terminated
  then Exit;

  // optimize ---------
  ProgressState:= 'Optimize';
  Report(Progress, ProgressCount, ProgressState);

  FRecNo:= 0;
  with SLWord do begin
    ProgressCount:= Count;
    for L:= 0 to Count - 1 do begin
      WordCount:= WordOccurances[L];
      if WordCount >= FDel2OftenWords then begin
        // delete too often words
        with it do begin
          Wrd:= L;
          FillChar(Fld, SizeOf(TWordFld2LocItemFld), 0);
          Loc:= 0;
        end;

        // loop required because Find can return not a first occurance
        repeat
          // try to find some word positions in locations
          WF2Loc.Find(it, locIdx);
          // if not found, exit
          if WF2Loc[locIdx].Wrd <> L
          then Break;
          locst:= locidx;
          // try to delete all following records
          repeat
            // DM.WF2Loc.Delete(locIdx);
            Inc(locIdx);
          until (locidx >= WF2Loc.Count) or (WF2Loc[locIdx].Wrd <> L);
          if (locidx - 1) > locst then begin
            WF2Loc.DeleteRange(locst, locIdx - 1);
          end;
        until False;
        Inc(FRecNo, WordCount);
        // indicate that all word occuancied has been deleted
        SLWord.WordOccurances[L]:= 0;
      end;
      Progress:= L;

      if Terminated
      then Exit;
    end;
  end;

  // store index ---------
  FCurTime:= Now;
  Fldcount:= 0; { field stored in flds.ind file counter }
  { store beginning of word list - start offset }
  L:= 0;
  FStrmFinalWrd.WriteBuffer(L, 4);                                //--wrd

  { store locations first, just 4-byte offsets of marc records }
  FRecNo:= 0;

  ProgressState:= 'Store Index';
  Report(Progress, ProgressCount, ProgressState);

  with WF2Loc do begin
    if Count <= 0 then begin
      ProgressState:= STRRES_LOC_ZERO;
      Report(Progress, ProgressCount, ProgressState);
      Exit;
    end;
    L:= Items[0].Loc;
    FStrmFinalLoc.WriteBuffer(L, 4);                                //--loc
    oldwrdrec:= Items[0].Wrd;
    oldfld:= Items[0].Fld;
    { store beginning of the first pair fld-start-finish }
    FStrmFinalFld.WriteBuffer(oldfld, SizeOf(TWordFld2LocItemFld)); //--fld
    L:= 0; { ActualRecordCount }
    FStrmFinalFld.WriteBuffer(L, 4);                                //--fld

    ProgressCount:= Count;
    for locIdx:= 1 to Count - 1 do begin
      wrdrec:= Items[locIdx].Wrd;
      FRecNo:= Items[locIdx].Loc;

      fld:= Items[locIdx].Fld;
      if (wrdrec <> oldwrdrec) or (fld <> oldfld) then begin
        { store tail of previous, current offset in locations file }
        L:= (locIdx - 1) * 4; { 1. Its previous 2.Its count up from 1 }
        FStrmFinalFld.WriteBuffer(L, 4);                            //--fld
        { begin new record (following, +4)}
        FStrmFinalFld.WriteBuffer(fld, SizeOf(TWordFld2LocItemFld));//--fld Word
        Inc(L, 4);
        FStrmFinalFld.WriteBuffer(L, 4);                            //--fld
        { store tail of word and start new one }
        if wrdrec <> oldwrdrec then begin
          L:= Fldcount * SizeOf(TWordFld2LocItem);
          FStrmFinalWrd.WriteBuffer(L, 4);                        //--wrd
          { get name from specified word number }
          // search word by number
          CurWord:= SLWord.WordUp[oldwrdrec];
          FStrmFinalWrd.WriteBuffer(CurWord[0], Length(CurWord) + 1); //--wrd
          Inc(L, SizeOf(TWordFld2LocItem));
          FStrmFinalWrd.WriteBuffer(L, 4);                             //--wrd
        end;
        Inc(Fldcount);
        oldfld:= fld;
        oldwrdrec:= wrdrec;
      end;
      FStrmFinalLoc.WriteBuffer(FRecNo, 4);                           //--loc
      Progress:= LocIdx;
      if Terminated
      then Exit;
    end;
    { store tail of last (allways uncompleted) }
    L:= (Count - 1) * 4;
    FStrmFinalFld.WriteBuffer(L, 4);                         //--fld
    { store tail of word and start new one }
    L:= Fldcount * SizeOf(TWordFld2LocItem);
    FStrmFinalWrd.WriteBuffer(L, 4);                                   //--wrd
    { get name from specified word number }
    // search word by number
    CurWord:= SLWord.WordUp[oldwrdrec];
    FStrmFinalWrd.WriteBuffer(CurWord[0], Byte(CurWord[0]) + 1);       //--wrd

    ProgressState:= STRRES_LOC_STORED;
    Report(Progress, ProgressCount, ProgressState);
  end;
  // store used tags as hash
  SLTag.SaveToStream(FstrmFinalTag);
  // store file list as key
  // FFilesList.SaveToStream(FstrmFinalKey);
  StoreOfsList(FFilesList, FstrmFinalKey);
end;

// ---------------------- TxmlIndexateFileListThread ---------------------------

constructor TxmlIndexateFileListThread.Create(ASuspended: Boolean; ADel2OftenWords, ADel2ShortWord, ADel2LongDigit: Integer;
  const AFileList: String;
  AstrmFinalWrd, AstrmFinalFld, AstrmFinalLoc, AstrmFinalKey, AstrmFinalTag: TStream; AReportProc: TReportProc);
var
  fl: TStrings;
begin
  fl:= TStringList.Create;
  with fl do begin
    Delimiter:= ';';
    DelimitedText:= AFileList;
  end;

  inherited Create(ASuspended, ADel2OftenWords, ADel2ShortWord, ADel2LongDigit,
    fl,
    AstrmFinalWrd, AstrmFinalFld, AstrmFinalLoc, AstrmFinalKey, AstrmFinalTag, AReportProc);
  fl.Free;
end;

// ---------------------- TxmlIndexateFilesThread ------------------------------

function ProcessFile(const FN: String; AEnv: TObject = Nil): Boolean;
begin
  TStrings(AEnv).Add(fn);
  Result:= True;
end;

constructor TxmlIndexateFilesThread.Create(ASuspended: Boolean; ADel2OftenWords, ADel2ShortWord, ADel2LongDigit: Integer;
  const AMaskList: String;
  AstrmFinalWrd, AstrmFinalFld, AstrmFinalLoc, AstrmFinalKey, AstrmFinalTag: TStream; AReportProc: TReportProc);
var
  sl: TStrings;
  f: Integer;
begin
  FFilesList:= TStringList.Create;

  sl:= TStringList.Create;
  with sl do begin
    Delimiter:= ';';
    DelimitedText:= AMaskList;
  end;

  for f:= 0 to sl.Count - 1 do begin
    if DirectoryExists(sl[f]) then begin
      // directory
      Walk_Tree('*.*', sl[f], faAnyFile, True, ProcessFile, FFilesList);
    end else begin
      if (util1.IsFileMask(sl[f])) then begin
        Walk_Tree(ExtractFileName(sl[f]), ExtractFilePath(sl[f]),
          faAnyFile, True, ProcessFile, FFilesList);
      end else begin
        if FileExists(sl[f]) then begin
          // ordinal file (or filemask- excluded)
          ProcessFile(sl[f], FFilesList);
        end else begin
          // some kind of mask ?
          Walk_Tree(ExtractFileName(sl[f]),
            ExtractFilePath(sl[f]), faAnyFile, True, ProcessFile, FFilesList);
        end;
      end;
    end;
  end;
  sl.Free;

  inherited Create(ASuspended, ADel2OftenWords, ADel2ShortWord, ADel2LongDigit,
    Nil, AstrmFinalWrd, AstrmFinalFld, AstrmFinalLoc, AstrmFinalKey, AstrmFinalTag, AReportProc);
end;

// ---------------------- Search component -------------------------------------

// ------ index search component implementation

const
  rtExact  = 1;
  rtFirst  = 2;
  rtLast   = 4;
  rtMiddle = 8;
  rtNo     = 0;

  flFirst  = rtFirst + rtExact;
  flLast   = rtLast + rtExact;
  flMiddle = rtMiddle + rtFirst + rtLast + rtExact;
  flExact  = rtExact;
  flNo     = rtNo;

constructor TSelectedRecs.Create;
begin
  {}
  FRecAllocStep:= 256;
  FCount:= 0;
  FAlloc:= 0;
  FAlgRecArray:= Nil;
  FEmptyRec.l:= 0;
  FEmptyRec.o:= 0;
  FCurRec:= @FEmptyRec;
  MaxSize:= MAX_CYCLES;
end;

function TSelectedRecs.AllocSpace: Boolean;
begin
  {}
  AllocSpace:= False;
  if FCount >= MaxSize then begin
    Inc(ExtraRecords);
  end else begin
    Inc(FCount);
    if FCount > FAlloc then begin
      Inc(FAlloc, FRecAllocStep);
      try
        ReallocMem(FAlgRecArray, FAlloc * SizeOf(TAlgRec));
      except
        Exit;
      end;
    end;
    AllocSpace:= True;
  end;
end;

destructor TSelectedRecs. Destroy;
begin
  {}
  Clear;
  inherited Destroy;
end;

procedure TSelectedRecs.Add(recofs: Integer);
begin
  {}
  if AllocSpace then begin
    with FAlgRecArray^[FCount-1] do begin
      l:= 1;
      o:= recofs;
    end;
  end;
end;

procedure TSelectedRecs.Clear;
begin
  {}
  if (FAlloc > 0) and (FAlgRecArray <> Nil) then begin
    ReallocMem(FAlgRecArray, 0);
  end;
  FAlgRecArray:= Nil;
  FAlloc:= 0;
  FCount:= 0;
end;

procedure TSelectedRecs.DeleteDups; // after Sort!
var
  i: Integer;
  sz: Cardinal;
  lr: TLocRec;
begin
  if FCount <= 1
  then Exit;
  lr:= not FAlgRecArray^[0].o;
  i:= 0;
  while i < FCount do with FAlgRecArray^[i] do begin
    if o = lr then begin
      // delete element
      sz:= (FCount - i - 2) * SizeOf(TAlgRec);
      if sz > 0 // if more than 2 elements were
      then Move(FAlgRecArray^[i + 1], FAlgRecArray^[i], sz);
      // decrease size
      Dec(FCount);
      FAlloc:= FCount;
      ReallocMem(FAlgRecArray, FCount * SizeOf(TAlgRec));
    end else begin
      lr:= o;
      Inc(i);
    end;
  end;
end;

procedure TSelectedRecs.Sort;
begin
  if FCount > 1
  then AlgrecQuickSort(0, FCount - 1);
end;

procedure TSelectedRecs.AlgrecQuickSort(L, R: Integer);
var
  I, J: Integer;
  T: TAlgrec;
  P: Integer;
begin
  repeat
    I:= L;
    J:= R;
    P:= FAlgRecArray^[(L + R) shr 1].o;
    repeat
      while FAlgRecArray^[i].o < P do Inc(i);
      while FAlgRecArray^[j].o > P do Dec(j);
      if I <= J then begin
        { exchange }
        T:= FAlgRecArray^[j];
        FAlgRecArray^[j]:= FAlgRecArray^[i];
        FAlgRecArray^[i]:= T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then begin
      AlgrecQuickSort(L, J);
    end;
    L:= I;
  until (I >= R);
end;

function  TSelectedRecs.FGetLevel(recofs: Integer): TSelectLevel;  { return TSelectLevel (0 if not) }
var
  L, H, I: Integer;
begin
  Result:= 0;
  L:= 0;
  H:= FCount - 1;
  while L <= H do begin
    I:= (L + H) shr 1;
    if FAlgRecArray^[I].o < recofs then L:= I + 1 else begin
      H:= I - 1;
      if FAlgRecArray^[I].o = recofs then begin
        FCurRec:= @(FAlgRecArray^[I]);
        Result:= FCurRec^.l;
      end;
    end;
  end;
end;

procedure TSelectedRecs.FSetLevel(recofs: Integer; level: TSelectLevel);
begin
  if FGetLevel(recofs) > 0
  then FCurRec^.l:= level;
end;

function  TSelectedRecs. FGetByOrd(ind: Integer): TAlgRec;  { return TSelectLevel (0 if not) }
begin
  if ind < FCount
  then FGetByOrd:= FAlgRecArray^[ind]
  else FGetByOrd:= FEmptyRec;
end;

procedure TSelectedRecs.FSetByOrd(ind: Integer; newrec: TAlgRec);
begin
  if ind < FCount
  then FAlgRecArray^[ind]:= newrec;
end;

procedure TSelectedRecs.Mul(recofs: Integer; Level: TSelectLevel);
begin
  if FGetLevel(recofs) > 0
  then FCurRec^.l:= FCurRec^.l or Level;
end;

function TSelectedRecs.FCountLevel(AlevelMask: TSelectLevel): Integer;
var
  r: LongInt;
  RecsF: Integer;
begin
  FCountLevel:= 0;
  RecsF:= 0;
  if FCount <= 0
  then Exit;
  r:= 0;
  while r < FCount do begin
    if (AlevelMask and RecByOrd[r].l) = AlevelMask then begin
      Inc(RecsF);
    end;
    Inc(r);
  end;
  FCountLevel:= RecsF;
end;

// ---------------------- Search component -------------------------------------

constructor TSearchWords.Create;
begin
  inherited Create;
  SetLength(FSearchContextPtrs, 0); { array of PSearchContext; }
end;

destructor TSearchWords.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TSearchWords.GetLen: Integer;
begin
  Result:= Length(FSearchContextPtrs);
end;

procedure TSearchWords.Clear;
var
  p: Integer;
begin
  for p:= 0 to Length(FSearchContextPtrs) - 1 do begin
    FreeMem(FSearchContextPtrs[p]);
  end;
  SetLength(FSearchContextPtrs, 0); // array of PSearchContext;
end;

function TSearchWords.GetSearchContextPtr(AIndex: Integer): PSearchContext;
begin
  if (AIndex < 0) or (AIndex >= Length(FSearchContextPtrs)) then begin
    Result:= Nil;
  end else begin
    Result:= FSearchContextPtrs[AIndex];
  end;
end;

procedure TSearchWords.Delete(AIndex: Integer);
var
  p: Integer;
begin
  if (AIndex < 0) or (AIndex >= Length(FSearchContextPtrs)) then begin
  end else begin
    FreeMem(FSearchContextPtrs[AIndex]);
    // shift all pointers
    for p:= AIndex to Length(FSearchContextPtrs) - 2 do begin
      FSearchContextPtrs[p]:= FSearchContextPtrs[p+1];
    end;
    // delete last
    p:= Length(FSearchContextPtrs);
    //if p > 0 then                    // allways geater than zero
    SetLength(FSearchContextPtrs, p - 1);
  end;
end;

procedure TSearchWords.QuickSort(L, R: Integer);
var
  I, J: Integer;
  P, T: Pointer;

function SCompare(P1, P2: PSearchContext): Integer;
begin
  Result:= - Length(p1^.FWord) + Length(p2^.FWord);
end;

begin
  repeat
    I:= L;
    J:= R;
    P:= FSearchContextPtrs[(L + R) shr 1];
    repeat
      while SCompare(FSearchContextPtrs[I], P) < 0
      do Inc(I);
      while SCompare(FSearchContextPtrs[J], P) > 0
      do Dec(J);
      if I <= J then begin
        T:= FSearchContextPtrs[I];
        FSearchContextPtrs[I]:= FSearchContextPtrs[J];
        FSearchContextPtrs[J]:= T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J
    then QuickSort(L, J);
    L:= I;
  until I >= R;
end;

// re- order words by length of words descendant
procedure TSearchWords.Sort;
var
  Len: Integer;
begin
  Len:= Length(FSearchContextPtrs);
  if (Len > 0)
  then QuickSort(0, Len - 1);
end;

function TSearchWords.Add(AWord: String; AWilds: Integer; AField: TWordFld2LocItemFld): Integer;
var
  p, l, i: Integer;
  wordexistsno: Integer;
begin
  // try to search word in list
  wordexistsno:= -1;
  for p:= 0 to Length(FSearchContextPtrs) - 1 do begin
    if AWord = FSearchContextPtrs[p]^.FWord then begin
      wordexistsno:= p;
      Break;
    end;
  end;
  if wordexistsno >= 0 then begin
    // word exists
    Result:= p;
{$IFDEF XML_IDX}
    if AField = EMPTY_FLD then begin
{$ELSE}
    if AField[0] = EMPTY_FLD then begin
{$ENDIF}
      // delete all previous assigned fields- all fields
      ReallocMem(FSearchContextPtrs[p],  SizeOf(TSearchContext) - SizeOf(Word));
      FSearchContextPtrs[p]^.FldCount:= 0;
    end else begin
      L:= FSearchContextPtrs[p]^.FldCount;
      // modify word entry, if field doesn't exists
      for i:= 0 to L - 1 do begin
        if FSearchContextPtrs[p]^.Flds[i] = AField then begin
          Exit;
        end;
      end;

      { add new field }
      ReallocMem(FSearchContextPtrs[p],  SizeOf(TSearchContext) + L * SizeOf(Word));
      FSearchContextPtrs[p]^.Flds[L]:= AField;
      Inc(FSearchContextPtrs[p]^.FldCount);
      { FSearchContextPtrs[p]^.FldCount }
    end;
  end else begin
    // add new word entry
    p:= Length(FSearchContextPtrs);
    Result:= p;
    SetLength(FSearchContextPtrs, p + 1);
{$IFDEF XML_IDX}
    if AField = EMPTY_FLD
{$ELSE}
    if AField[0] = EMPTY_FLD
{$ENDIF}
    then L:= 0
    else L:= 1;
    GetMem(FSearchContextPtrs[p], SizeOf(TSearchContext) + (L - 1) * SizeOf(Word));
    with FSearchContextPtrs[p]^ do begin
      FWord:= AWord;
      FWilds:= AWilds;
      FldCount:= L;
{$IFDEF XML_IDX}
      if AField <> EMPTY_FLD
{$ELSE}
      if AField[0] <> EMPTY_FLD
{$ENDIF}
      then Flds[0]:= AField;
    end;
  end;
end;

{----------------------------------------------------------------------------}

function isFldCorrect(const B): Boolean;
var
  i: Word;
begin
  isFldCorrect:= False;
  if TWordRec(B).h.fs > TWordRec(B).h.ff
  then Exit;
  for i:= 1 to Byte(TWordRec(B).w[0]) do begin
    if TWordRec(B).w[i] < #32
    then Exit;
  end;
  isFldCorrect:= True;
end;

function ScanWordRecordStart(var Position2Align: Cardinal; const AWordBuf: String): Boolean;
var
  i, p, Fr: Cardinal;
begin
  ScanWordRecordStart:= False;
  p:= Position2Align;
  if p > SizeOf(TWHdrRec)
  then Dec(p, SizeOf(TWHdrRec));
  if p < 32+10 { was +1 }
  then Fr:= 0
  else Fr:= p - 32-10; { was -1 }
  for i:= p downto Fr do begin
    if (AWordBuf[i + SizeOf(TWHdrRec)+1] <= #32) and (AWordBuf[i+SizeOf(TWHdrRec)+1] > #0) then begin
      if isFldCorrect(AWordBuf[i+1]) then begin
        Position2Align:= i;
        ScanWordRecordStart:= True;
        Exit;
      end;
    end;
  end;
end;

function GetMatch(var W: TWordRec; const AWordBufStr: String; var RtWrd: Integer): Boolean;
var
  wLen, RecLen: Word;
  p: Integer;
begin
  GetMatch:= False;
  RtWrd:= rtNo;
  if not ScanWordRecordStart(W.h.fs, AWordBufStr) then begin
    Exit;
  end;
  wLen:= Byte(AWordBufStr[W.h.fs+SizeOf(TWHdrRec)+1]);
  RecLen:= SizeOf(TWHdrRec) + 1 + wLen;
  if (W.h.fs + RecLen > Length(AWordBufStr))
  then Exit;

  p:= Pos(W.w, TWordRec((@AWordBufStr[W.h.fs+1])^).W);
  if p > 0 then begin      { record contains word }
    GetMatch:= True;
    if p = 1 then begin
      if wLen = Byte(W.W[0]) then begin
        RtWrd:= rtExact;   { exactly }
      end else begin
        RtWrd:= rtFirst;   { first characters      (prefix) }
      end;
    end else begin
      if Byte(W.W[0]) + p - 1 = wLen then begin
        RtWrd:= rtLast;    { last characters       (suffix) }
      end else begin
        RtWrd:= rtMiddle;  { in the middle of word (root)   }
      end;
    end;
  end;
  Move(AWordBufStr[W.h.fs+1], W, RecLen);
end;

function SearchAndType(Level: Integer; const ASearchWord: ANSIString; ArtWrd: Integer;
  const AWordBuf: ANSIString; AstrmFLD, AstrmLOC: TStream; ASelRecs: TSelectedRecs): Integer;
var
  CurWrd: TWordRec;
  p,
  occuredRtWrd,
  L: Integer;
  fofs,
  lofs: Longint;
  fldr: TFldRec;
  Algrec: TAlgRec;
begin
  Result:= 0;
  L:= Length(AWordBuf);
  p:= 1;
  repeat
    p:= Scan32(AWordBuf, L, p, ASearchWord);
    if p = -1
    then Break;
    CurWrd.w:= ASearchWord;
    CurWrd.h.fs:= p;
    if GetMatch(CurWrd, AWordBuf, occuredRtWrd) and
        ((occuredRtWrd and ArtWrd) > 0) then begin
      Inc(Result);
      { lookup fields start at w.h.fs to w.h.ff in FLDS.IND }
      fofs:= CurWrd.h.fs;
      AstrmFLD.Position:= fofs;
      while fofs <= CurWrd.h.ff do begin
        AstrmFLD.Read(fldr, SizeOf(TFldRec));
        { lookup locations start at fldr.ls to fldr.lf in FLDS.IND }
        lofs:= fldr.ls;
        AstrmLOC.Position:= fldr.ls;
        while lofs <= fldr.lf do begin
          AstrmLOC.Read(AlgRec.o, SizeOf(TLocRec));
          if Level = 1
          then ASelRecs.Add(AlgRec.o)
          else ASelRecs.Mul(AlgRec.o, Level);
          Inc(lofs, SizeOf(TLocRec));
        end;
        Inc(fofs, SizeOf(TFldRec));
      end;
    end;
    Inc(p); { next one }
  until p >= L;
  if Level = 1 then begin
    ASelRecs.Sort;
    ASelRecs.DeleteDups;
  end;
end;

function SearchAndTypeFld(Level: Integer; const ASearchWord: ANSIString; ArtWrd: Integer;
  AFldCount: Integer; const AFlds: TFldsArray;
  const AWordBuf: ANSIString; AstrmFLD, AstrmLOC: TStream; ASelRecs: TSelectedRecs): Integer;
var
  fldexists: Boolean;
  CurWrd: TWordRec;
  curfld,
  p,
  occuredRtWrd,
  L: Integer;
  fofs,
  lofs: Longint;
  fldr: TFldRec;
  Algrec: TAlgRec;
begin
  Result:= 0;
  L:= Length(AWordBuf);
  p:= 1;
  repeat
    p:= Scan32(AWordBuf, L, p, ASearchWord);
    if p = -1
    then Break;
    CurWrd.w:= ASearchWord;
    CurWrd.h.fs:= p;
    if GetMatch(CurWrd, AWordBuf, occuredRtWrd) and
        ((occuredRtWrd and ArtWrd) > 0) then begin
      Inc(Result);
      { lookup fields start at w.h.fs to w.h.ff in FLDS.IND }
      fofs:= CurWrd.h.fs;
      AstrmFLD.Position:= fofs;
      while fofs <= CurWrd.h.ff do begin
        AstrmFLD.Read(fldr, SizeOf(TFldRec));
        // check is field in list of fields
        fldexists:= False;
        for curfld:= 0 to AFldCount - 1 do begin
          if fldr.fld = AFlds[curfld] then begin
            fldexists:= True;
            Break;
          end;
        end;
        if not fldexists then begin
          Inc(fofs, SizeOf(TFldRec));
          Continue;
        end;  
        { lookup locations start at fldr.ls to fldr.lf in FLDS.IND }
        lofs:= fldr.ls;
        AstrmLOC.Position:= fldr.ls;
        while lofs <= fldr.lf do begin
          AstrmLOC.Read(AlgRec.o, SizeOf(TLocRec));
          if Level = 1
          then ASelRecs.Add(AlgRec.o)
          else ASelRecs.Mul(AlgRec.o, Level);
          Inc(lofs, SizeOf(TLocRec));
        end;
        Inc(fofs, SizeOf(TFldRec));
      end;
    end;
    Inc(p); { next one }
  until p >= L;
  if Level = 1 then begin
    ASelRecs.Sort;
    ASelRecs.DeleteDups;
  end;
end;

constructor TInvSearch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Status:= -1;
  FFoundCount:= 0;
  FoundLevels:= 0;

  FFldSort:= ''; // do not sort
  FWordBuf:= '';
  FMinWordLen:= MINSRCHWORDLEN;
  FMaxWords:= 64;
  FSearchWords:= TSearchWords.Create;
  FFileList:= Nil;
  strmWRD:= Nil;
  strmFLD:= Nil;
  strmLOC:= Nil;
  SelectedRecs:= TSelectedRecs.Create;
end;

destructor TInvSearch.Destroy;
begin
  ReleaseStreams;
  FSearchWords.Free;
  SelectedRecs.Free;
  inherited Destroy;
end;

procedure TInvSearch.SetMinWordLen(const AMinWordLen: Integer);
begin
  FMinWordLen:= AMinWordLen;
  if FMinWordLen < MINSRCHWORDLEN
  then FMinWordLen:= MINSRCHWORDLEN;
end;

procedure TInvSearch.SetMaxWords(const AMaxWords: Integer);
begin
  FMaxWords:= AMaxWords;
  if FMaxWords < 8
  then FMaxWords:= 8;
  if FMaxWords > 256
  then FMaxWords:= 256;
end;

procedure TInvSearch.ReleaseStreams;
begin
  if Assigned(FFileList)
  then FreeAndNil(FFileList);
  if strmWRD <> Nil then FreeAndNil(strmWRD);
  if strmFLD <> Nil then FreeAndNil(strmFLD);
  if strmLOC <> Nil then FreeAndNil(strmLOC);
end;

procedure TInvSearch.LoadIndex(const AIndexName: String);
var
  fn1, fn2, fn3, fn4: String;
  WordBufLen: Integer;
begin
  Status:= -1;
  ReleaseStreams;
  if AIndexName = ''
  then Exit;
  fn1:= ReplaceExt('lst', AIndexName);
  fn2:= ReplaceExt('wrd', AIndexName);
  fn3:= ReplaceExt('fld', AIndexName);
  fn4:= ReplaceExt('loc', AIndexName);
  if FileExists(fn1) and FileExists(fn2) and FileExists(fn3) and FileExists(fn4) then begin
    try
      FFileList:= LoadListOfFiles(fn1);
      strmWRD:= TFileStream.Create(fn2, fmOpenRead+fmShareDenyNone);
      WordBufLen:= strmWRD.Size;
      SetString(FWordBuf, Nil, WordBufLen);
      // .. и читаем пр€мо в FWordbuf
      strmWRD.Read(Pointer(FWordBuf)^, WordBufLen);
      FreeAndNil(strmWRD);

      strmFLD:= TFileStream.Create(fn3, fmOpenRead + fmShareDenyNone);
      strmLOC:= TFileStream.Create(fn4, fmOpenRead + fmShareDenyNone);
      Status:= 0;
    except
      ReleaseStreams;
      Exit;
    end;
  end;
end;

function  TInvSearch.GetWordsAllFields: String;
var
  i: Integer;
  wild: Word;
  S: String;
begin
  Result:= '';
  if FSearchWords.Count <= 0
  then Exit;
  { это невозможно: if FLongestWordIndex >= FSearchWords.Count then Exit; }
  for i:= 0 to FSearchWords.Count - 1 do begin
    wild:= FSearchWords.FSearchContextPtrs[i]^.FWilds;
    S:= FSearchWords.FSearchContextPtrs[i]^.FWord;

    // передн€€ тильда
    if (rtLast and wild) = rtLast
    then Result:= TILDCHAR + Result;

    Result:= Result + S;

    // задн€€ тильда
    if (rtFirst and wild) = rtFirst
    then Result:= Result + TILDCHAR;

    { разделитель слов }
    Result:= Result + #32;
  end;
end;

procedure TInvSearch.SetWordsAllFields(Srch: String);
begin
  FSearchWords.Clear;
  Self.SetFieldWords(EMPTY_FLD, Srch);
end;

procedure TInvSearch.ClearFieldWords;
begin
  FSearchWords.Clear;
end;

function  TInvSearch.GetFieldWords(AField: TWordFld2LocItemFld): WideString;
var
  fldexists: Boolean;
  curfld, cnt, i: Integer;
  wild: Word;
  S: WideString;
begin
  Result:= '';
  if FSearchWords.Count <= 0
  then Exit;
  { это невозможно: if FLongestWordIndex >= FSearchWords.Count then Exit; }
  for i:= 0 to FSearchWords.Count - 1 do begin
    wild:= FSearchWords.FSearchContextPtrs[i]^.FWilds;
{$IFDEF XML_IDX}
    if AField <> EMPTY_FLD
{$ELSE}
    if AField[0] <> EMPTY_FLD
{$ENDIF}
    then begin // search all fields
      cnt:= FSearchWords.FSearchContextPtrs[i]^.FldCount;
      if cnt <> 0 then begin // word all fields
        // check is field in list of fields
        fldexists:= False;
        for curfld:= 0 to cnt - 1 do begin
          if FSearchWords.FSearchContextPtrs[i]^.Flds[curfld] = AField then begin
            fldexists:= True;
            Break;
          end;
        end;
        if not fldexists
        then Continue;
      end;
    end;
    s:= jclUnicode.Utf8ToWideString(FSearchWords.FSearchContextPtrs[i]^.FWord);

    // передн€€ тильда
    if (rtLast and wild) = rtLast
    then Result:= TILDCHAR + Result;

    Result:= Result + S;

    // задн€€ тильда
    if (rtFirst and wild) = rtFirst
    then Result:= Result + TILDCHAR;

    { разделитель слов }
    Result:= Result + #32;
  end;
end;

procedure TInvSearch.SetFieldWords(AField: TWordFld2LocItemFld; const ASrch: WideString);
var
  i: Integer;
  DEL, TILDS: set of char;
  wild: Integer;
  srch: String;
begin
  if ASrch = ''
  then Exit;
  DEL:= DELIMITERS;
  TILDS:= TILDLIKECHARSET;
  // преобразовать в верхний регистр и кодовую страницу
  // ASrch:= ANSILowercase(ASrch);
  Srch:= jclUnicode.WideStringToUTF8(jclUnicode.WideUpperCase(ASrch));

  // заменить все управл€ющие символы на пробелы
  ReplaceChars(DEL, #32, Srch);
  // заменить символы '.', '*', '?' на тильду '~'
  ReplaceChars(TILDS, TILDCHAR, Srch);
  // заменить символы '.', ',', ';' на пробелы.

  // удалить все двойные пробелы, а также лидирующие и терминирующие
  DeleteLeadTerminateDoubledSpaceStr(Srch);

  // добавл€ем все в список строк
  i:= 1;
  repeat
    FCurSearchWord:= GetToken(i, #32, Srch);
    if Length(FCurSearchWord) >= FMinWordLen then begin
      { добавить слово }
      wild:= flExact;
      if Pos(TILDCHAR, FCurSearchWord) = 1 then begin
        wild:= flLast;
        Delete(FCurSearchWord, 1, 1);
      end;
      if Pos(TILDCHAR, FCurSearchWord) = Length(FCurSearchWord) then begin
        if (wild and flLast) = flLast
        then wild:= flMiddle
        else wild:= wild or flFirst;
        Delete(FCurSearchWord, Length(FCurSearchWord), 1);
      end;
      FSearchWords.Add(FCurSearchWord, wild, AField);
      if FSearchWords.Count > FMaxWords  // не больше лимита слов
      then Break;
    end;
    Inc(i);
  until FCurSearchWord = '';

  // найдем индекс и длину макcимально длинного слова сортировкой
  FSearchWords.Sort;
end;

procedure TInvSearch.Search;
var
  ind, AlgLevel: Integer;
  flds, wild: Integer;
begin
  if Status < 0
  then Exit;
  Status:= -1;
  FFoundCount:= 0;
  FoundLevels:= 0;
  AlgLevel:= -1;
  if FSearchWords.Count <= 0
  then Exit;

  SelectedRecs.ExtraRecords:= 0;  { число записей, больших допустимого размера буфера MaxSize }
  for ind:= 0 to FSearchWords.Count - 1 do begin
    FCurSearchWord:= FSearchWords.FSearchContextPtrs[ind]^.FWord;
    wild:= FSearchWords.FSearchContextPtrs[ind]^.FWilds;
    flds:= FSearchWords.FSearchContextPtrs[ind]^.FldCount;
    if FCurSearchWord = ''
    then Break
    else Inc(AlgLevel);
    if AlgLevel = 0
    then SelectedRecs.Clear;
    if flds <= 0
    then SearchAndType(1 shl AlgLevel, FCurSearchWord, wild, FWordBuf, strmFLD, strmLOC, SelectedRecs)
    else SearchAndTypeFld(1 shl AlgLevel, FCurSearchWord, wild,
      flds, FSearchWords.FSearchContextPtrs[ind]^.Flds,
      FWordBuf, strmFLD, strmLOC, SelectedRecs);
  end;

  FoundLevels:= AlgLevel;
  FFoundCount:= SelectedRecs.CountLevel[(1 shl (FoundLevels+1)) - 1];
  Status:= 0;
end;

procedure TInvSearch.Sort;
var
  c: Integer;
  SortFld, SortSfld: Integer;

begin
  c:= SelectedRecs.Count;
  // truncate others - only 1 field is to sort (i.e. 100a-z)
  FFldSort:= Copy(Trim(FFldSort), 1, 32);
  if (Length(FFldSort) > 0) and (c > 0) then begin
    QuickSort(0, c - 1);
  end;
end;

// compare based on field value
procedure TInvSearch.QuickSort(L, R: Integer);
var
  I, J: Integer;
  P: Integer;
  AR: TAlgrec;

  function RecCompare(R1, R2: Integer): Integer;
  var
    fn1, fn2: String;
  begin
    fn1:= FFileList[SelectedRecs.FAlgRecArray^[R1].o];
    fn2:= FFileList[SelectedRecs.FAlgRecArray^[R2].o];
    // read xml file
    // memo:= EMemos.Load2NewMemo(srFile, fn1);
    // r1:= memo.Lines.Text;
    // memo.Free;
    Result:= AnsiStrIComp(PAnsiChar(fn1), PAnsiChar(fn2));
  end;

begin
  with SelectedRecs do repeat
    I:= L;
    J:= R;
    P:= (L + R) shr 1;
    repeat
      while RecCompare(I, P) < 0
      do Inc(I);
      while RecCompare(J, P) > 0
      do Dec(J);
      if I <= J then begin
        { exchange }
        AR:= FAlgRecArray^[j];
        FAlgRecArray^[j]:= FAlgRecArray^[i];
        FAlgRecArray^[i]:= AR;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then begin
      QuickSort(L, J);
    end;
    L:= I;
  until (I >= R);
end;

function TInvSearch.GetXMLUrl(no: Integer): String;
var
  cnt,
  r: LongInt;
  AlgRec: TAlgRec;
  LevelMask: TSelectLevel;
begin
  Result:= '';
  LevelMask:= (1 shl (FoundLevels+1)) - 1;
  if SelectedRecs.Count <= 0 then begin
    Exit;
  end;
  r:= 0;
  cnt:= 0;
  while r < SelectedRecs.Count do begin
    AlgRec:= SelectedRecs.RecByOrd[r];
    if (LevelMask and AlgRec.l) = LevelMask then begin
      if cnt = No then begin
        Result:= FFileList[AlgRec.o];
        Break;
      end;
      Inc(cnt);
    end;
    Inc(r);
  end;
end;

function TInvSearch.GetXMLRecord(no: Integer): WideString;
var
  bookmark: String;
  encoding: Integer;
begin
  if GetSource(GetXMLUrl(no), Result, bookmark, encoding) = umOK then begin
  end else Result:= '';
end;

procedure Register;
begin
  RegisterComponents('Marc', [TInvSearch]);
end;

function LoadListOfFiles(const AFileName: String): TStrings;
var
  cnt, i: Integer;
begin
  Result:= TStringList.Create;
  Result.LoadFromFile(AFileName);
  cnt:= Result.Count;
  if cnt = 0
  then Exit;

  Result.Delete(0);
  Dec(cnt);

  for i:= 0 to cnt - 1 do begin
    Result[i]:= util1.GetToken(2, #9, Result[i]);
  end;
end;

// ---------------------- TxmlPhraseThread -------------------------------------

constructor TxmlPhraseThread.Create(ASuspended: Boolean; ACaseSensitive, AOutputUnicode, ASkipAttributes: Boolean;
  ASkipElements: TStrings; const AXMLUrlList: String; AFstrmFinalPhrase: TStream; AReportProc: TReportProc;
  ADefault_EmptyStr: WideString);
var
  fp: Int64;
begin
  FreeOnTerminate:= True;
  FReportProc:= AReportProc;

  FFilesList:= TStringList.Create;
  FFilesList.CommaText:= AXMLUrlList;
  FDefault_EmptyStr:= ADefault_EmptyStr;
  FstrmFinalPhrase:= AFstrmFinalPhrase;  { output stream, must be opened }
  fp:= FstrmFinalPhrase.Position;
  if fp > 0 then begin
    FstrmFinalPhrase.Seek(0, soFromBeginning);
  end;

  FOutputUnicode:= AOutputUnicode;
  FSkipAttributes:= ASkipAttributes;
  FSkipElements:= ASkipElements;
  
  // create dictionary and load previously created words dictionary
  if AOutputUnicode then begin
    SLPhrase:= TWideWordList.Create;
    with TWideWordList(SLPhrase) do begin
      if fp > 0 then begin
        LoadFromStream(FstrmFinalPhrase);
      end;
      Duplicates:= dupIgnore;
      Sorted:= True;
    end;
  end else begin
    SLPhrase:= TWordList.Create;
    with TWordList(SLPhrase) do begin
      if fp > 0 then begin
        LoadFromStream(FstrmFinalPhrase);
      end;
      CaseSensitive:= ACaseSensitive;
      Duplicates:= dupIgnore;
      Sorted:= True;
    end;
  end;
  if fp > 0 then begin
    FstrmFinalPhrase.Seek(0, soFromBeginning);
  end;
  inherited Create(ASuspended, AReportProc);
end;

destructor TxmlPhraseThread.Destroy;
begin
  SLPhrase.Free;
  FFilesList.Free;
  inherited Destroy;
end;

procedure TxmlPhraseThread.AddValue2Phrase(const ATag: ShortString; const AAttr: WideString; var AValue: WideString);
var
  cnt: Integer;
  idx: Integer;
  vl: WideString;
begin
  if Length(AValue) = 0 then Exit;
  // do not process skipped elements
  if Assigned(FSkipElements) and (FSkipElements.IndexOf(ATag) >= 0)
  then Exit;
  
  vl:= AValue;
  util1.DeleteLeadTerminateDoubledSpaceStr(vl);
  if FOutputUnicode then begin
    with TWideWordList(SLPhrase) do begin
      if Find(vl, idx) then begin
        cnt:= Integer(Objects[idx]);
        Inc(cnt);
        Objects[idx]:= Pointer(cnt);
      end else begin
        Insert(idx, vl);
        Objects[idx]:= Pointer(1);
      end;
    end;
  end else begin
    with TWordList(SLPhrase) do begin
      if Find(vl, idx) then begin
        cnt:= Integer(Objects[idx]);
        Inc(cnt);
        Objects[idx]:= Pointer(cnt);
      end else begin
        Insert(idx, vl);
        Objects[idx]:= Pointer(1);
      end;
    end;
  end;
end;

procedure TxmlPhraseThread.Execute;
var
  Len: Word;
  p: Word;
  S: ShortString; { + #0 }
  cnt: Cardinal;
  encoding,
  recno: Integer;
  bookmark,
  oututf8: String;
  rec: WideString;
  fn: String;
begin
  FCurTime:= Now;
  cnt:= FFilesList.Count;

  // fill index
  ProgressState:= STRRES_WORD_START;
  Report(Progress, ProgressCount, ProgressState);

  // expected count of records of 0.5K each

  cnt:= FFilesList.Count;
  RecNo:= 0;
  ProgressCount:= cnt;
  while (RecNo < cnt) and (not Terminated) do begin;
    Progress:= RecNo;
    ProgressState:= Format(STRRES_PHRASE_FILE, [FFilesList[RecNo]]);
    // read xml file
    fn:= FFilesList[RecNo];
    if GetSource(fn, Rec, bookmark, encoding) = umOK then begin
      len:= Length(Rec);
//Rec:= Rec + #0;
      if (len > 0) then begin
        if CompareText('.DFM', Copy(fn, Length(fn) - 3, MaxInt)) = 0
          then ParseDfm(Rec, AddValue2Phrase, Nil)
          else begin
            if FSkipAttributes
            then ParseXml(Rec, AddValue2Phrase, Nil, Nil)
            else ParseXml(Rec, AddValue2Phrase, AddValue2Phrase, Nil);
          end;
      end;
    end;
    Inc(RecNo);
  end;
  try
    if FOutputUnicode then begin
      oututf8:= util_xml.WideString2EncodedString(convPCDATA, wmlc.csUTF8, TWideWordList(SLPhrase), []);
      FstrmFinalPhrase.Write(oututf8[1], Length(oututf8));
    end else begin
      with TWordList(SLPhrase) do begin
        SaveToStream(FstrmFinalPhrase);
      end;
    end;

    ProgressState:= Format(STRRES_PHRASE_FINISH, [cnt, PerMin(cnt, Now - FCurTime)]);
    Report(Progress, ProgressCount, ProgressState);

  except
    on E: Exception do begin
      ProgressState:= Format(ERRRES_PHRASE_FILE, [E.Message, cnt, PerMin(cnt, Now - FCurTime)]);
      Report(Progress, ProgressCount, ProgressState);
    end;
  end;
end;

// ---------------------- TxmlPhraseReplaceThread ------------------------------

constructor TxmlPhraseReplaceThread.Create(ASuspended: Boolean; ACaseSensitive, AOutputUnicode, ASkipAttributes: Boolean;
  ASkipElements: TStrings; 
  const AXMLUrlList: String; ASLPhraseTemplate, ASLPhraseReplace: TDictStrings;
  AReportProc: TReportProc);
var
  i, c: Integer;
begin
  FreeOnTerminate:= True;
  FReportProc:= AReportProc;
  FSkipAttributes:= ASkipAttributes;
  FSkipElements:= ASkipElements;  

  FFilesList:= TStringList.Create;
  FFilesList.CommaText:= AXMLUrlList;

  FSLPhraseTemplate:= ASLPhraseTemplate;
  FSLPhraseReplace:= ASLPhraseReplace;

  // align
  c:= FSLPhraseTemplate.Count;
  if FSLPhraseReplace.Count < c
  then c:= FSLPhraseReplace.Count;

  while c < FSLPhraseTemplate.Count do begin
    FSLPhraseTemplate.Delete(c);
  end;
  while c < FSLPhraseReplace.Count do begin
    FSLPhraseReplace.Delete(c);
  end;

  // delete non-translated phrases
  i:= 0;
  while i < FSLPhraseTemplate.Count do begin
    if FSLPhraseTemplate[i] = FSLPhraseReplace[i] then begin
      FSLPhraseTemplate.Delete(i);
      FSLPhraseReplace.Delete(i);
    end else Inc(i);
  end;

  inherited Create(ASuspended, AReportProc);
end;

destructor TxmlPhraseReplaceThread.Destroy;
begin
  {
  FSLPhraseReplace.Free;
  FSLPhraseTemplate.Free;
  }
  FFilesList.Free;
  inherited Destroy;
end;

const
  ALL_NO_CHAR = [ccOtherControl, ccOtherFormat,
    ccWhiteSpace, ccSegmentSeparator, ccSeparatorSpace, ccSpaceOther,
    ccPunctuationConnector, ccPunctuationDash, ccPunctuationOpen, ccPunctuationClose,
    ccPunctuationOther, ccPunctuationInitialQuote, ccPunctuationFinalQuote, ccPunctuationOther];

  DELIMITERS_1         = [#0..'/',':'..'@','['..'^','`', '{'..'~'];

function IsNotVar(const vl: WideString; AFrom, ATo: Integer): Boolean;
var
  p, b, sp, cm, Len: Integer;

begin
  Result:= True;
  b:= util1.PosBackFrom(AFrom - 1, '$', vl);
  if b <= 0
  then Exit;

  Len:= Length(vl);
  if vl[b + 1] = '(' then begin
    cm:= PosFrom(b + 2, ')', vl);
    Result:= cm < AFrom;
    Exit;
  end;
  cm:= PosFrom(b + 1, #32, vl);
  Result:= cm < AFrom;
  Exit;
end;

function IsPartVar(const AValue: WideString; AFrom: Integer; ALen: Integer): Boolean;
var
  i, spaces, oparen, cparen, dollar: Integer;
begin
  Result:= False;
  oparen:= 0;
  cparen:= 0;
  dollar:= 0;
  spaces:= 0;
  for i:= AFrom - 1 downto 1 do begin
    if AValue[i] = '(' then begin
      Inc(oparen);
    end else begin
      if AValue[i] = ')' then begin
        Inc(cparen);
      end else begin
        if AValue[i] = '$' then begin
          Inc(dollar);
          Break;
        end else begin
          if AValue[i] = '_' then begin
            // special case to eleminate it from ALL_NO_CHAR
          end else begin
            if jclUnicode.CategoryLookup(Cardinal(AValue[i]), ALL_NO_CHAR)  then begin
              Inc(spaces);
            end;
          end;
        end;
      end;
    end;
  end;
  if dollar >= 1 then begin
    if spaces = 0 then begin
      Result:= True;
    end else begin
      if oparen > cparen then begin
        Result:= True;
      end;
    end;
  end;
end;

procedure TxmlPhraseReplaceThread.ReplacePhrase(const ATag: ShortString; const AAttr: WideString; var AValue: WideString);
var
  cnt: Integer;
  idx, l: Integer;
  ws, vl, vlu,fv: WideString;
  p, maxPos, maxIdx, maxLen, vlLen, wsLen, replaces: Integer;
begin
  if Length(AValue) = 0 then Exit;
  // do not process skipped elements
  if Assigned(FSkipElements) and (FSkipElements.IndexOf(ATag) >= 0)
  then Exit;

  vl:= AValue;
  util1.DeleteLeadTerminateDoubledSpaceStr(vl);

  if Length(vl) = 0 then Exit;

  { I don't know how to do this }
  idx:= FSLPhraseTemplate.IndexOf(vl);
  if idx >= 0 then begin
    // exact phrase found
    // cnt:= Integer(Objects[idx]);
    fv:= FSLPhraseReplace[idx];
    // 2008/08/04
    if Length(fv) > 0 then begin
      AValue:= fv;
    end else begin
      if Length(FDefault_EmptyStr) > 0 then begin
        AValue:= FDefault_EmptyStr;
      end;
    end;
  end else begin
    // let try to find out parts
    replaces:= 0;
    with FSLPhraseTemplate do repeat
      vlu:= WideUpperCase(vl);

      vlLen:= Length(vlu);
      maxIdx:= -1;
      maxLen:= 0;
      for idx:= 0 to Count - 1 do begin
        ws:= WideUpperCase(Strings[idx]);
        wsLen:= Length(ws);
        p:= Pos(ws, vlu);
        if p > 0 then begin
          // check is it phrase
          L:= p + wsLen;
          if ((p = 1) or (jclUnicode.CategoryLookup(Cardinal(vlu[p - 1]), ALL_NO_CHAR))) and
            ((L > vlLen) or (jclUnicode.CategoryLookup(Cardinal(vlu[L]), ALL_NO_CHAR))) and IsNotVar(vl, p, L)
          then begin
            // check is it alone variable (such as $() or $)?
            if IsPartVar(vl, p, wsLen)
            then Continue;
            if (wsLen > maxLen) then begin // better than previously found
              if (ANSICompareText(Copy(vl, p, wsLen), FSLPhraseReplace[Idx]) <> 0) then begin
                MaxPos:= p;
                MaxLen:= wsLen;
                MaxIdx:= idx;
              end;
            end;
          end;
        end;
      end;
      if maxIdx >= 0 then begin
        // ToDo: There are ANSI but Wide version is required
        {
        if (ANSICompareText(Copy(vl, MaxPos, maxLen), FSLPhraseReplace[MaxIdx]) = 0) then begin
          Writeln('Error: Duplicate ' + FSLPhraseReplace[MaxIdx]);
          Break;
        end;
        }
        // longest phrase was found, replace
        System.Delete(vl, MaxPos, maxLen);
        System.Insert(FSLPhraseReplace[MaxIdx], vl, MaxPos);
      end else Break;
      Inc(replaces);
      if replaces > MAX_CYCLES then begin
        Writeln('Too many replacements, max is : ' + IntToStr(MAX_CYCLES));
        Break;
      end;
    until False;
    AValue:= vl;
  end;
end;

procedure TxmlPhraseReplaceThread.Execute;
var
  Len: Word;
  p: Word;
  cnt: Cardinal;
  encoding, recno: Integer;
  fn,
  bookmark,
  oututf8: String;
  rec: WideString;
begin
  FCurTime:= Now;
  cnt:= FFilesList.Count;

  // fill index
  ProgressState:= STRRES_WORD_START;
  Report(Progress, ProgressCount, ProgressState);

  cnt:= FFilesList.Count;
  RecNo:= 0;
  ProgressCount:= Cnt;
  while (RecNo < cnt) and (not Terminated) do begin;
    Progress:= RecNo;
    // read xml file
    fn:= FFilesList[RecNo];
    if GetSource(fn, Rec, bookmark, encoding) = umOK then begin
      len:= Length(Rec);
//Rec:= Rec + #0;
      if (len > 0) then begin
        if CompareText('.DFM', Copy(fn, Length(fn) - 3, MaxInt)) = 0
          then ParseDfm(Rec, ReplacePhrase, @Rslt)
          else begin
            if FSkipAttributes
            then ParseXml(Rec, ReplacePhrase, Nil, @Rslt)
            else ParseXml(Rec, ReplacePhrase, ReplacePhrase, @Rslt);
          end;
      end;
    end;

    ProgressState:= Format(STRRES_PHRASE_FILE, [FFilesList[RecNo]]);
    Report(Progress, ProgressCount, ProgressState);

    Inc(RecNo);
  end;
  try
    ProgressState:= Format(STRRES_PHRASE_FINISH, [cnt, PerMin(cnt, Now - FCurTime)]);
    Report(Progress, ProgressCount, ProgressState);
  except
    on E: Exception do begin
      ProgressState:= Format(ERRRES_PHRASE_FILE, [E.Message, cnt, PerMin(cnt, Now - FCurTime)]);
      Report(Progress, ProgressCount, ProgressState);
    end;
  end;
end;

end.
