unit
  xmlsupported;
(*##*)
(*******************************************************************************
*                                                                             *
*   x  m  l  s  u  p  p  o  r  t  e  d                                         *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language classes                                          *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions:                                                                 *
*     Jul 2004 added $(var:singlequote:escape|unescape|noescape|singlequote)  *
*              suppress usage of MASK_VAR_ESCAPESINGLEQUOTE                    *
*     Jan 2006 added $(var:f[ormatblob]                                       *
*                                                                              *
*                                                                             *
*   Revisions    : Oct 25 2002                                                 *
*   Last fix     : May 15 2003                                                *
*   Lines        : 1175                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Classes, SysUtils, Windows,  Controls, StrUtils, jclUnicode,
  customxml,
{$IFDEF GENWML}
  wml,
{$ENDIF}
{$IFDEF GENXHTML}  
  xHTML,                           
{$ENDIF}
{$IFDEF GENOEB}
  oebdoc, oebpkg,
{$ENDIF}
{$IFDEF GENHHC}
  xhhc, xhhk,
{$ENDIF}
{$IFDEF GENAPP}
  bioTaxon, smit, rtc,
{$ENDIF}
{$IFDEF GENXML}
  generalxml,
{$ENDIF}
  util1;
const
  // lowercase file name suffix please
  DEFAULT_WML_FILEEXTENSION  = 'wml';
  DEFAULT_WMLC_FILEEXTENSION  = 'wmlc';
  DEFAULT_WMLT_FILEEXTENSION = 'wmlt';

  DEFAULT_HTM_FILEEXTENSION  = 'htm';
  DEFAULT_HTML_FILEEXTENSION = 'html';
  DEFAULT_TEXT_FILEEXTENSION = 'txt';
  DEFAULT_CSS_FILEEXTENSION  = 'css';
  DEFAULT_OEB_FILEEXTENSION  = 'oeb';  // 'htm, html'
  DEFAULT_OPF_FILEEXTENSION  = 'opf';
  DEFAULT_XHTML_FILEEXTENSION = 'xhtml';
  DEFAULT_XML_FILEEXTENSION  = 'xml';
  
  MASK_VAR_ASIS              = 0;
  MASK_VAR_ESCAPESINGLEQUOTE = $80;
  MASK_VAR_UTF8              = $100;
  MASK_VAR_EXPANDENTITY      = $200; // never used

// --------- functions and procedures  ---------

{ GetxmlClassDescByxxx
    Scan xmlClassDescs global var for
  Parameters:
    AxmlElementClass - element container class
    or
    ADocType - document type
  Return:
    Result - xml elements class description
}
function GetxmlClassDescByClass(AxmlElementClass: TClass; var R: TxmlClassDesc): Boolean;

function GetxmlClassDescByDoc(ADocType: TEditableDoc; var R: TxmlClassDesc): Boolean;

// similar to Classes.GetClass
// AName: TWMLHead, ...
function GetxmlClassByName(AxmlContainerClass: TClass; const AName: String): TPersistentClass;

// similar to GetxmlClassByName except no 'Txxx' prefix is not required
// AxmlElementName: wml, head, ..
function GetxmlClassByElementName(AxmlContainerClass: TClass; const AxmlElementName: String): TPersistentClass;
function GetxmlPCDATAClass(AxmlContainerClass: TClass): TPersistentClass;
function GetxmlDocDescClass(AxmlContainerClass: TClass): TPersistentClass;

{ GetListOfElements
    Return list of classes (names in Strings and class in Objects)
  Parameters:
    AxmlElementClass - Nil - return all of
                     - TxxxContainer - return elements
}
function GetListOfElements(AxmlContainerClass: TClass): TStrings;


// --------- image list index routines ---------

// return index of element class for image list
function GetBitmapIndexByClass(const AxmlElementClass: TClass): Integer;

// return index of element name for image list
function GetBitmapIndexByNameInContainer(AxmlContainerClass: TClass; const AName: String): Integer;

// return index of element name for image list
function GetBitmapIndexByName(const AName: String): Integer;

// return index of file name for image list
function GetBitmapIndexByFileName(const AName: String): Integer;

// return element class by bitmap index
function GetClassByBitmapIndex(AIndex: Integer): TPersistentClass;
// to do search faster you can use next function
function GetxmlClassByBitmapIndex(AxmlContainerClass: TClass; AIndex: Integer): TPersistentClass;

type
  TGetVarValueCallback = function(const AVarName: String; AEsc: Integer; var AValue: WideString): Boolean of object;

// --------- tag validators  ---------

// replace control chars to one space
function ValidPCData(const APCData: WideString): WideString;

function ValidCommentData(const APCData: WideString): WideString;

function ValidSSScriptData(const APCData: WideString): WideString;

// --------- other routines  ---------

function MkEscUnesc(AEsc: Integer; const S: WideString): WideString;

{ Evaluate GZ(x), G1(x), ABS,SQRT,SQR,SIN,COS,ARCTAN,LN,LOG,EXP,FACT;
    GZ return 0 if x < 0; G1 return 0 if x < 1
    Simple recursive expression parser based on the TCALC example of TP3
    Based on Lars Fosdal 1987 code, released to the public domain 1993
  Before calling Eval() you must call ExtractAndFillVars()
  Parameters:
    AFormula- Expression to be evaluated
    AValue  - Return AValue
  Return
    Result  - calculated value. If error occured, return 0.0
    AErrPos  - error position,  0 if no errors occured, > 0 position where error occured in AFormula
}
function Eval(AFormula: String; var AErrPos: Integer): Extended;
function EvalSafe(AFormula: WideString; var AErrPos: Integer): Extended;
function EvalSafeInt(AFormula: WideString; var AErrPos: Integer): Integer;

function ExtractAndFillVars(var AValue: WideString; AGetVarValueCallback: TGetVarValueCallback; AEscapeMask: Integer): Integer; overload;

function ExtractAndFillVars(var AValue: String; AGetVarValueCallback: TGetVarValueCallback; AEscapeMask: Integer): Integer; overload;

// return measure string

function MeasureStr(ASizeMeasure: TSizeMeasure): String;

// --------- measure extraction function  ---------

function GetMeasure(const AValue: String; var RValue: Integer): TSizeMeasure;

// --------- return document container type such edWML ---------

function getContainerClassByDoctype(ADocType: TEditableDoc): TClass;
function getDoctypeByContainerClass(AContainerClass: TClass): TEditableDoc;

// --------- return document type by file name extension ---------

// return edNone, edText, edWML, edHTML, edCSS, edOEB, edOPF, edXHTML, edTxn
function GetDocTypeByFileName(const AFileName: String): TEditableDoc;

// return short description string of document type: edText, edWML, edWMLTemplate, edWMLCompiled, edHTML, edCSS, edOEB, edOPF, edXHTML, edTxn
function GetDocTypeDesc(ADocType: TEditableDoc): String;

var
  HTMLColorNames: TStrings;

implementation

uses
  util_xml;

var
  xmlClassDescs: array of TxmlClassDesc;
  xmlClassDescCount: Integer;

function GetBitmapIndexByClass(const AxmlElementClass: TClass): Integer;
var
  i, c: Integer;
  dsc: TxmlClassDesc;
begin
  Result:= -1;
  for c:= Low(xmlClassDescs) to High(xmlClassDescs) do begin
    dsc:= xmlClassDescs[c];
    for i:= 0 to dsc.len - 1 do begin
      if dsc.classes[i] = AxmlElementClass then begin
        Result:= dsc.ofs + i ;
        Exit;
      end;
    end;  
  end;
end;

// return index of element name for image list
function GetBitmapIndexByNameInContainer(AxmlContainerClass: TClass; const AName: String): Integer;
var
  i: Integer;
  dsc: TxmlClassDesc;
begin
  Result:= -1;
  if not GetxmlClassDescByClass(AxmlContainerClass, dsc)
  then Exit;
  for i:= 0 to dsc.len - 1 do begin
    if CompareText(dsc.xmlElementClass.GetElementName, AName) = 0 then begin
      Result:= i;
      Exit;
    end;
  end;
end;

function GetBitmapIndexByName(const AName: String): Integer;
var
  c, i: Integer;
  dsc: TxmlClassDesc;
begin
  Result:= -1;
  for c:= Low(xmlClassDescs) to High(xmlClassDescs) do begin
    dsc:= xmlClassDescs[c];
    for i:= 0 to dsc.len - 1 do begin
      if CompareText(dsc.xmlElementClass.GetElementName, AName) = 0 then begin
        Result:= i;
        Exit;
      end;
    end;
  end;
end;


// return index of element name for image list
function GetBitmapIndexByFileName(const AName: String): Integer;
var
  dsc: TxmlClassDesc;
  d: TEditableDoc;
begin
  Result:= -1;
  d:= GetDocTypeByFileName(AName);
  if GetxmlClassDescByDoc(d, dsc)
  then Result:= dsc.deficon;
end;

function GetClassByBitmapIndex(AIndex: Integer): TPersistentClass;
var
  c: Integer;
  dsc: TxmlClassDesc;
begin
  Result:= Nil;
  for c:= Low(xmlClassDescs) to High(xmlClassDescs) do begin
    dsc:= xmlClassDescs[c];
    with dsc do begin
      if (AIndex >= ofs) and (Aindex < ofs + len) then begin
        Result:= classes[AIndex - ofs];
        Break;
      end;
    end;
  end;
end;

// to do search faster you can use functions:
function GetxmlClassByBitmapIndex(AxmlContainerClass: TClass; AIndex: Integer): TPersistentClass;
var
  dsc: TxmlClassDesc;
begin
  Result:= Nil;
  if not GetxmlClassDescByClass(AxmlContainerClass, dsc)
  then Exit;
  with dsc do begin
    if (ofs >= AIndex) and (ofs + len < AIndex) then begin
      Result:= classes[AIndex - ofs];
    end;
  end;
end;

// replace control chars to one space
function ValidPCData(const APCData: WideString): WideString;
var
  i, L: Integer;
begin
  Result:= '';
  {
  c:= False;  // False if space is allowed in the beginning
  for i:= 1 to Length(APCData) do begin
    case APCData[i]of
      #0..#32, WideLineSeparator, WideParagraphSeparator: begin
        if c
        then Continue;
        Result:= Result + #32;
        c:= True;
      end
      else begin
        Result:= Result + APCData[i]; // That's SLOW!
        c:= False;
      end;
    end;
  end;
  }
  // trimming
  Result:= WideTrim(APCData);
  L:= Length(Result);
  I:= 1;
  while (I <= L) do begin
    if UnicodeIsControl(UCS4(Result[I])) then begin
      Delete(Result, I, 1);
      Dec(L);
    end else Inc(I);
  end;
end;

function ValidCommentData(const APCData: WideString): WideString;
var
  c: Boolean;
  i, l, st, fin: Integer;
begin
  Result:= '';
  c:= False;
  // delete !-- and --
  st:= 1;
  fin:= Length(APCData);
  if fin >= 2 then begin
    if Pos('!', APCData) = 1
    then Inc(st);
    while (st < fin) and ((APCData[st] <= #32) or  (APCData[st] = '-') or
      (APCData[st] = WideLineSeparator) or (APCData[st]= WideParagraphSeparator))
    do Inc(st);

    if StrUtils.AnsiEndsStr('--', APCData)
    then Dec(fin, 2);
  end;
  // compress spaces and control chars
  for i:= st to fin do begin
    case APCData[i] of
    // #13#10 must be included because '//' in script is used to comment to end of line 
    #0..#9, #11, #12, #14..#32, WideLineSeparator, WideParagraphSeparator:  begin
      if c
        then Continue;
        Result:= Result + #32;
        c:= True;
      end else begin
        Result:= Result + APCData[i];
        c:= False;
      end;
    end; { case }
  end;
  // check last character
  l:= Length(Result);
  if (l > 0) and (Result[l] <= #32) then begin
    Delete(Result, l, 1);
  end;
end;

function ValidSSScriptData(const APCData: WideString): WideString;
var
  c: Boolean;
  i, l, st, fin: Integer;
begin
  Result:= '';
  c:= False;
  // delete % and %
  st:= 1;
  fin:= Length(APCData);
  if fin >= 2 then begin
    if Pos('%', APCData) = 1
    then Inc(st);
    while (st < fin) and ((APCData[st] <= #32) or
      (APCData[st] = WideLineSeparator) or (APCData[st]= WideParagraphSeparator))
    do Inc(st);

    if StrUtils.AnsiEndsStr('%', APCData)
    then Dec(fin, 2);
  end;
  // compress spaces and control chars
  for i:= st to fin do begin
    case APCData[i] of
    #0..#32, WideLineSeparator, WideParagraphSeparator:  begin
      if c
        then Continue;
        Result:= Result + #32;
        c:= True;
      end else begin
        Result:= Result + APCData[i];
        c:= False;
      end;
    end; { case }
  end;
  // check last character
  l:= Length(Result);
  if (l > 0) and (Result[l] <= #32) then begin
    Delete(Result, l, 1);
  end;
end;

// --------- measure extraction function  ---------

function GetMeasure(const AValue: String; var RValue: Integer): TSizeMeasure;
var
  FValue: String;
  p, L: Integer;
  charset: set of Char;
begin
  Result:= smNone;
  RValue:= 0;
  FValue:= Trim(AValue);
  L:= Length(FValue);
  if L <= 0
  then Exit;
  p:= 1;
  charset:= ['0'..'9'];
  if FValue[1] = '#' then begin
    FValue[1]:= '$';
    charset:= charset + ['A'..'F', 'a'..'f'];
  end;
  while (p <= L) and (FValue[p] in charset) do begin
    Inc(p);
  end;
  RValue:= StrToIntDef(Copy(FValue, 1, p - 1), 0);
  FValue:= LowerCase(Trim(Copy(FValue, p, MaxInt)));
  if FValue = ''
  then Result:= smUnit
  else if FValue = '%'
    then Result:= smPercent
    else if FValue = 'px'
      then Result:= smPixel
      else if FValue = 'pt'
        then Result:= smPoint
        else if FValue = 'in'
          then Result:= smInch
          else if FValue = 'cm'
            then Result:= smCM
            else if FValue = 'mm'
              then Result:= smMM
              else if FValue = 'pc'
                then Result:= smPica
                else if FValue = 'ex'
                  then Result:= smEX
                  else if FValue = 'em'
                   then Result:= smEM;
end;

// return measure string
function MeasureStr(ASizeMeasure: TSizeMeasure): String;
begin
  case ASizeMeasure of
    smUnit: Result:= '';
    smPercent: Result:= '%';
    smPixel: Result:= 'px';
    smPoint: Result:= 'pt';
    smInch: Result:= 'in';
    smCM: Result:= 'cm';
    smMM: Result:= 'mm';
    smPica: Result:= 'pc';
    smEX: Result:= 'ex';
    smEM: Result:= 'em';
  end; { case }
end; { MeasureStr }

function MkEscUnesc(AEsc: Integer; const S: WideString): WideString;
var
  i, L: Integer;
begin
  case (AEsc and $3) of
    0:begin { escape }
        //
        Result:= util1.httpEncode(S, (AEsc and MASK_VAR_UTF8) <> 0);
      end;
    1:begin { unescape }
        //
        Result:= util1.httpDecode(S, (AEsc and MASK_VAR_UTF8) <> 0);
      end;
    else begin
        // noesc, No transformation
        Result:= S;
      end;
  end;
  //
  if (AEsc and MASK_VAR_ESCAPESINGLEQUOTE) > 0 then begin
    i:= 1;
    L:= Length(Result);
    while i <=  L do begin
      if Result[i] = '''' then begin
        Insert('''', Result, i);
        Inc(L);
        Inc(i);
      end;
      Inc(i);
    end;
  end;
  {
  if (AEsc and MASK_VAR_EXPANDENTITY) > 0 then begin
    Result:= HTMLExtractEntityStr(Result);
  end;
  }
end;

function Eval(AFormula: String; var AErrPos: Integer): Extended;
const
  Digit: Set of Char = ['0'..'9'];
var
  Posn: Integer;   { Current position in AFormula}
  CurrChar: Char;  { character at Posn in AFormula }

  procedure ParseNext;
  begin
    repeat
      Inc(Posn);
      if Posn <= Length(AFormula)
      then CurrChar:= AFormula[Posn]
      else CurrChar:= #13;
    until CurrChar <> #32;
  end;

  function add_subt: Extended;
  var
    E: Extended;
    Opr: Char;

    function mult_DIV: Extended;
    var
      S: Extended;
      Opr: Char;

      function Power: Extended;
      var
        T: Extended;

        function SignedOp: Extended;

          function UnsignedOp: Extended;
          type
            StdFunc = (f0neg, f1neg, fabs, fsqrt, fsqr, fsin, fcos, farctan, fln, flog, fexp, ffact);
            StdFuncList = array[StdFunc] of String[6];
          const
            StdFuncName: StdFuncList = ('GZ', 'G1', 'ABS','SQRT','SQR','SIN','COS', 'ARCTAN','LN','LOG','EXP','FACT');
          var
            L, Start: Integer;
            Funnet: Boolean;
            F: Extended;
            Sf: StdFunc;

            function Fact(I: Integer): Extended;
            begin
              if I > 0 then begin Fact:=I*Fact(I-1); end
              else Fact:=1;
            end  { Fact };

          begin { function UnsignedOp }
            if CurrChar in Digit then begin
              Start:=Posn;
              repeat
                ParseNext
              until not (CurrChar in Digit);
              if CurrChar = '.'
              then repeat ParseNext until not (CurrChar in Digit);
              if CurrChar = 'E' then begin
                ParseNext;
                repeat ParseNext until not (CurrChar in Digit);
              end;
              Val(Copy(AFormula,Start,Posn-Start), F, AErrPos);
            end else
            if CurrChar = '(' then begin
              ParseNext;
              F:= add_subt;
              if CurrChar = ')'
              then ParseNext
              else AErrPos:= Posn;
            end else begin
              Funnet:= False;
              for sf:= Low(StdFunc) to High(StdFunc) do begin
                if not Funnet then begin
                  l:= Length(StdFuncName[sf]);
                  if Copy(AFormula, PosN, l) = StdFuncName[sf] then begin
                    Posn:= Posn + l - 1;
                    ParseNext;
                    f:= UnsignedOp;
                    case sf of
                      f0neg: if f < 0 then f:= 0;
                      f1neg: if f < 1 then f:= 1;
                      fabs: f:= abs(f);
                      fsqrt: f:= SqrT(f);
                      fsqr: f:= Sqr(f);
                      fsin: f:= Sin(f);
                      fcos: f:= Cos(f);
                      farctan: f:= ArcTan(f);
                      fln: f:= LN(f);
                      flog: f:= LN(f)/LN(10);
                      fexp: f:= Exp(f);
                      ffact: f:= fact(Trunc(f));
                    end;
                    Funnet:= True;
                  end;
                end;
              end; // for
              if not Funnet then begin
                f:= 0;
              end;
            end;
            UnsignedOp:= F;
          end { UnsignedOp};

        begin { SignedOp }
          if CurrChar = '-' then begin
            ParseNext; SignedOp:=-UnsignedOp;
          end else SignedOp:=UnsignedOp;
        end { SignedOp };

      begin { Power }
        T:=SignedOp;
        while CurrChar = '^' do begin
          ParseNext;
          if t<>0 then t:=EXP(LN(abs(t))*SignedOp) else t:=0;
        end;
        Power:= t;
      end { Power };

    begin { mult_DIV }
      s:= Power;
      while CurrChar in ['*', '/'] do begin
        Opr:=CurrChar; ParseNext;
        case Opr of
          '*': s:=s * Power;
          '/': s:=s / Power;
        end;
      end;
      mult_DIV:=s;
    end { mult_DIV };

  begin { add_subt }
    E:= mult_DIV;
    while CurrChar in ['+', '-'] do begin
      Opr:= CurrChar;
      ParseNext;
      case Opr of
        '+': e:= e + mult_DIV;
        '-': e:= e - mult_DIV;
      end;
    end;
    add_subt:= E;
  end { add_subt };

begin { Eval }
  {
  if AFormula[1] = '.'
  then AFormula:= '0' + AFormula;
  if AFormula[1] = '+'
  then Delete(AFormula, 1, 1);
  }
  // ExtractAndFillVars(AFormula, AGetVarValueCallback, AMask);
  AFormula:= Uppercase(AFormula);
  Posn:= 0;
  ParseNext;
  Result:= add_subt;
  if CurrChar = #13
  then AErrPos:= 0
  else AErrPos:= Posn;
end;

{ there are no reason to use widestring formula repesentation because in formula you can not
  use unicode characters and ASCII characters is only available
}
{
function Eval(AFormula: WideString; AGetVarValueCallback: TGetVarValueCallback; var AErrPos: Integer): Extended;
begin
  Result:= Eval(AFormula, AGetVarValueCallback, AErrPos);
end;
}
function EvalSafe(AFormula: WideString; var AErrPos: Integer): Extended;
begin
  try
    Result:= Eval(AFormula, AErrPos);
  except
    Result:= 0;
  end;
end;

function EvalSafeInt(AFormula: WideString; var AErrPos: Integer): Integer;
var
  v: Extended;
begin
  v:= EvalSafe(AFormula, AErrPos);
  if v >= MaxInt
  then Result:= MaxInt
  else if v < - MaxInt
    then Result:= - MaxInt
    else Result:= Round(v);
end;

{ search $var in AValue string
  Add found vars to the AVars.
    AVars.Objects = 0 - escape (wmlc.WMLG_EXT_I_0 = $40 )
                    1 - unesc  (wmlc.WMLG_EXT_I_1 = $41)
                    2 - noesc  (wmlc.WMLG_EXT_I_2 = $42)
    AEscapeMask     MASK_VAR_ESCAPESINGLE_QUOTE ($80) - replace ' to ''
  Returns
    Result      0- no replacement
                1.. replacement count
  calls AGetVarValueCallback(escape, 'dataset.var') for variable value
}
function ExtractAndFillVars(var AValue: WideString; AGetVarValueCallback: TGetVarValueCallback; AEscapeMask: Integer): Integer;
var
  // phase, phasecnt: Integer; // process extracting twice!
  lastPhaseCnt: Integer;
  i: Integer;
  textstarted,
  varStarted: Integer;
  varParenthesis: Integer; // actually 0 or >0 is used
  varVal: WideString;

  procedure AddTextOrVar;
  var
    comps: WideString;
    firstcolonpos, colonPos, scolonPos, L, newL, vlen: Integer;
    esc: Integer;
    externalBlobFormatFunc,
    supressQuoteEscape: Boolean;
  begin
    if varStarted <= 0  // text skipped
    then Exit;
    // get variable length
    L:= i - varstarted;
    // this to avoid recursion $var1=$var1 and so ones
    Inc(lastPhaseCnt);
    if lastPhaseCnt > $FF then begin
      lastPhaseCnt:= 0;
      Inc(i);
      Exit;
    end;

    // extract variable name only
    comps:= Copy(AValue, varstarted + 1, L - 1);
    // This is not required- variable name must be look good. //  DeleteDoubledSpaceStr(comps);
    // set default escape (noescape) and escape single quote or other masks (if specified)
    esc:= 2 or (AEscapeMask and (not $3));
    supressQuoteEscape:= False;
    externalBlobFormatFunc:= False;
    // last is take effect
    vlen:= Length(comps);
    firstcolonpos:= Pos(':', comps);
    colonPos:= firstcolonpos;
    while (colonPos > 0) and (colonPos < vlen) do begin  // Jun 28 2004
      // :escaped or :unesc or :n found
      case comps[colonpos + 1] of
        'E', 'e': esc:= 0;    // $40 $(var:escape). Escaped name of the variable is inline.
        'U', 'u': esc:= 1;    // $41 $(var:unesc). Unescaped name of the variable is inline.
        'S', 's': supressQuoteEscape:= True; // $(var:singlequote:escape|unescape|noescape). Do not replace single quote ' to pair of '' (force suppress SQL escaping) // Jun 28 2004
        'F', 'f': begin
            externalBlobFormatFunc:= True; // $(var[func@dllname?modifier]:formatblob)
            esc:= 4;  // request BLOB
          end;
      end; { case }
      // delete ':' and all others characters
      scolonPos:= PosFrom(colonpos + 1, ':', comps);
      if scolonPos = 0
      then scolonPos:= vlen + 1;
      // prepare to next
      colonPos:= scolonpos;
    end;
    // remove all ":" suffixes
    if (firstcolonpos > 0)
    then Delete(comps, firstcolonpos, MaxInt);
    // do not store variable with no name, for example in cases of '$ $' or '$'CRLF'$'
    if Length(comps) > 0 then begin
      Inc(Result);
      // Inc(phasecnt); it is not requred

      if supressQuoteEscape
      then esc:= esc and (not $80);

      if AGetVarValueCallback(comps, esc, varVal) then begin
        // replace variable to value if assigned
        if varParenthesis > 0 then begin
          Delete(AValue, varstarted - 1, L + 2);
          Dec(varstarted);
        end else begin
          Delete(AValue, varstarted, L);
        end;
        {
        newval:= MkEscUnesc(esc, varVal);     // Copy(varVal, Length(comps) + 2 , MaxInt)
        newL:= Length(newval);
        }
        newL:= Length(varval);
        // AVars.Objects[idx]:= TObject(esc);
        {
        if (esc and MASK_VAR_UTF8) > 0
        then varval:= UTF8Encode(varval);
        }
        Insert(varval, AValue, varstarted);
        if varParenthesis > 0 then begin
          i:= i + newL - (L + 2);
        end else begin
          i:= i + newL - L;
        end;
      end;
    end;
    // var flushed
    varStarted:= 0;
    if varParenthesis > 0
    then textStarted:= i + 1
    else textStarted:= i;
    varParenthesis:= 0;
  end;

begin
  Result:= 0;
  // phase:= 0; repeat phasecnt:= 0;   // you can try out ti set up external loop and increment position to find again
  // to avoid $var1=$var1 bug.
  // in case of ...$var1... where $var1=$var0;
  // BUGBUG!!! in case of $var1=$var1 it causes cyclic error. It is fixed by lsetting $FF limitation
  lastPhaseCnt:= 0;

  varStarted:= 0;
  textStarted:= 1;
  i:= 1;
  while i <= Length(AValue) do begin
    case WideChar(AValue[i]) of
      WideChar(#0)..WideChar('#'),WideChar('%')..WideChar(''''),
      WideChar('*')..WideChar('-'),WideChar('/'),WideChar(';')..WideChar('@'),
      WideChar('[')..WideChar('^'),WideChar('`'),WideChar('{')..WideChar(#255): begin { WideLineSeparator, WideParagraphSeparator }
          if (varStarted > 0) then begin
            if (varParenthesis = 0) then begin
              // store variable if not enclosed in parenthesis
              AddTextOrVar;
            end;
          end;
        end;
      WideChar('$'): begin
          if varStarted = 0 then begin
            // variable started
            if (i < Length(AValue)) and (AValue[i+1] = WideChar('$')) then begin
              // sign '$$' escaped. Skip next '$'
              Inc(i);
            end else begin
                // store previous variable
                AddTextOrVar;
                // new variable started
                varStarted:= i;
                // indicate that new varible is not enclosed in parenthesis yet
                varParenthesis:= 0;
                // clear name of variable
//?!!                v:= '';
            end;
          end;
        end;
      WideChar('('): begin
            if varStarted > 0 then begin
              if (varStarted + 1 = i) then begin
                // variable started with '('
                varParenthesis:= i;
                varstarted:= i;
              end else begin
                Inc(varStarted); // incorrect case: $var(1
              end;
            end;
        end;
      WideChar(')'): begin
            if (varStarted > 0) then begin
              // variable is enclosed with ')'
              // store variable
              AddTextOrVar;
            end else begin
              // incorrect case: $)var1
            end;
        end;
      else begin
        end;
    end; { case }
    Inc(i);
  end; { for }
  AddTextOrVar;
  // Inc(phase); until (phasecnt = 0) or (phase >= 1)
end;

function ExtractAndFillVars(var AValue: String; AGetVarValueCallback: TGetVarValueCallback; AEscapeMask: Integer): Integer;
var
  ws: WideString;
begin
  ws:= AValue;
  Result:= ExtractAndFillVars(ws, AGetVarValueCallback, AEscapeMask);
  AValue:= ws;
end;

{ GetxmlClassDescByxxx
    Scan xmlClassDescs global var for
  Parameters:
    AxmlElementClass - element container class
    or
    ADocType - document type
  Return:
    Result - xml elements class description
}
function GetxmlClassDescByClass(AxmlElementClass: TClass; var R: TxmlClassDesc): Boolean;
var
  i: Integer;
begin
  Result:= False;
  for i:= Low(xmlClassDescs) to High(xmlClassDescs) do begin
    if xmlClassDescs[i].xmlElementClass = AxmlElementClass then begin
      R:= xmlClassDescs[i];
      Result:= True;
      Break;
    end;
  end;
end;

function GetxmlClassDescByDoc(ADocType: TEditableDoc; var R: TxmlClassDesc): Boolean;
var
  i: Integer;
begin
  Result:= False;
  for i:= Low(xmlClassDescs) to High(xmlClassDescs) do begin
    if xmlClassDescs[i].DocType = ADocType then begin
      R:= xmlClassDescs[i];
      Result:= True;
      Break;
    end;
  end;
end;

// similar to Classes.GetClass
// AName: TWMLHead, ...
function GetxmlClassByName(AxmlContainerClass: TClass; const AName: String): TPersistentClass;
var
  i: Integer;
  dsc: TxmlClassDesc;
begin
  Result:= Nil;
  if not GetxmlClassDescByClass(AxmlContainerClass, dsc)
  then Exit;
  for i:= 0 to dsc.len - 1 do begin
    if CompareText(dsc.classes[i].ClassName, AName) = 0 then begin
      Result:= dsc.classes[i];
      Break;
    end;
  end;
end;

// similar to GetxmlClassByName except no 'Txxx' prefix is not required
// AxmlElementName: wml, head, ..
function GetxmlClassByElementName(AxmlContainerClass: TClass; const AxmlElementName: String): TPersistentClass;
var
  i: Integer;
  dsc: TxmlClassDesc;
begin
  Result:= Nil;
  // get containter
  if not GetxmlClassDescByClass(AxmlContainerClass, dsc)
  then Exit;
  // search element name in published elements FROM 0. Do not optimize! (therefore do not use FOR operator)
  i:= 0;
  while i < dsc.len do begin
    if dsc.classes[i].IsElementByName(AxmlElementName) then begin
      Result:= dsc.classes[i];
      Break;
    end;
    Inc(i);
  end;
end;

function GetxmlPCDATAClass(AxmlContainerClass: TClass): TPersistentClass;
var
  dsc: TxmlClassDesc;
begin
  Result:= TxmlPCData;
  if not GetxmlClassDescByClass(AxmlContainerClass, dsc)
  then Exit;
  Result:= dsc.xmlPCDataClass;
end;

function GetxmlDocDescClass(AxmlContainerClass: TClass): TPersistentClass;
var
  dsc: TxmlClassDesc;
begin
  Result:= TDocDesc;
  if not GetxmlClassDescByClass(AxmlContainerClass, dsc)
  then Exit;
  Result:= dsc.DocDescClass;
end;

// --------- return list of classes ---------

{ GetListOfElements
    Return list of classes (names in Strings and class in Objects)
  Parameters:
    AxmlElementClass - Nil - return all of
                     - TxxxContainer - return elements
}
function GetListOfElements(AxmlContainerClass: TClass): TStrings;
var
  c, i: Integer;
  dsc: TxmlClassDesc;
begin
  Result:= TStringList.Create;

  if AxmlContainerClass = Nil then begin
    // return all of registered
    for c:= Low(xmlClassDescs) to High(xmlClassDescs) do begin
      dsc:= xmlClassDescs[c];
      for i:= 0 to dsc.len - 1 do begin
        Result.AddObject(dsc.classes[i].GetElementName, TObject(dsc.classes[i])); // Sep 22 2004 -- replace Add to AddObject
      end;
    end;
  end else begin
    // return list of elements in container
    if not GetxmlClassDescByClass(AxmlContainerClass, dsc)
    then Exit;
    for i:= 0 to dsc.len - 1 do begin
      Result.AddObject(dsc.classes[i].GetElementName, TObject(dsc.classes[i])); // Sep 22 2004 -- replace Add to AddObject
    end;
  end;
end;

// --------- functions and procedures  ---------

// HTML color name codes are supported by Microsoft Reader

function CreateHTMLColorNames: TStrings;
begin
  Result:= TStringList.Create;
  with Result do begin
    Clear;
    AddObject('black',  TObject(RGB(0, 0, 0)));
    AddObject('white',  TObject(RGB(255, 255, 255)));
    AddObject('aqua',  TObject(RGB(0, 255, 255)));
    AddObject('blue',  TObject(RGB(0, 0, 255)));
    AddObject('fuchsia',  TObject(RGB(255, 0, 255)));
    AddObject('gray',  TObject(RGB(128, 128, 128)));
    AddObject('green',  TObject(RGB(0, 128, 0)));
    AddObject('lime',  TObject(RGB(0, 255, 0)));
    AddObject('maroon',  TObject(RGB(128, 0, 0)));
    AddObject('navy',  TObject(RGB(0, 0, 128)));
    AddObject('olive',  TObject(RGB(128, 128, 0)));
    AddObject('purple',  TObject(RGB(128, 0, 128)));
    AddObject('red',  TObject(RGB(255, 0, 0)));
    AddObject('silver',  TObject(RGB(192, 192, 192)));
    AddObject('teal',  TObject(RGB(0, 128, 128)));
    AddObject('yellow',  TObject(RGB(255, 255, 0)));
  end;
end;

function getContainerClassByDoctype(ADocType: TEditableDoc): TClass;
begin
 case ADocType of     
{$IFDEF GENWML}
   edWML, edWMLTemplate, edWMLCompiled: Result:= TWMLContainer;
{$ENDIF}
{$IFDEF GENXHTML}
   edXHTML: Result:= THTMContainer;
{$ENDIF}
{$IFDEF GENOEB}
   edOEB: Result:= TOEBContainer;
   edPkg: Result:= TPkgContainer;
{$ENDIF}
{$IFDEF GENHHC}
   edHHC: Result:= THHCContainer;
   edHHK: Result:= THHKContainer;
{$ENDIF}
{$IFDEF GENAPP}
   edTaxon: Result:= TTxnContainer;
   edSMIT: Result:= TSmtContainer;
   edRTC: Result:= TRTCContainer;
{$ENDIF}
{$IFDEF GENXML}
   edgenXML: Result:= TGENContainer;
{$ENDIF}
 else Result:= Nil;
 end;
end;

function getDoctypeByContainerClass(AContainerClass: TClass): TEditableDoc;
begin
  Result:= edUNKNOWN;
{$IFDEF GENWML}
  if (AContainerClass = TWMLContainer) or (AContainerClass = TWmlWml) then Result:= edWML;
{$ENDIF}
{$IFDEF GENXHTML}
  if (AContainerClass = THTMContainer) or (AContainerClass = THtmHtml) then Result:= edXHTML;
{$ENDIF}
{$IFDEF GENOEB}
  if (AContainerClass = TOEBContainer) or (AContainerClass = TOebHTML) then Result:= edOEB;
  if (AContainerClass = TPkgContainer) or (AContainerClass = TOebPackage) then Result:= edPkg;
{$ENDIF}
{$IFDEF GENHHC}
  if (AContainerClass = THHCContainer) or (AContainerClass = THHChtml) then Result:= edHHC;
  if (AContainerClass = THHKContainer) or (AContainerClass = THHKhtml) then Result:= edHHK;
{$ENDIF}
{$IFDEF GENAPP}
  if (AContainerClass = TTxnContainer) or (AContainerClass = TTxnTaxon) then Result:= edTaxon;
  if (AContainerClass = TSmtContainer) or (AContainerClass = TSmtMenu) then Result:= edSMIT;
  if (AContainerClass = TRTCContainer) or (AContainerClass = TRTCprovision) then Result:= edRTC;
{$ENDIF}
{$IFDEF GENXML}
  if (AContainerClass = TGENContainer) then Result:= edgenXML;
{$ENDIF}
end;

// return edNone, edText, edWML, edHTML, edCSS, edOEB, edOPF, edXHTML, edTxn
function GetDocTypeByFileName(const AFileName: String): TEditableDoc;
var
  p: Integer;
  ext: String;
  c: Integer;
  dsc: TxmlClassDesc;
begin
  Result:= edUNKNOWN;  // default
  if (Length(AFileName) < 2) // at least one character i.e. '.e'
  then Exit;

  p:= util1.PosBack('.', AFileName);
  if p <= 0
  then Exit;
  ext:= ANSILowercase(Copy(AFileName, p + 1, MaxInt)); // without dot

  for c:= Low(xmlClassDescs) to High(xmlClassDescs) do begin
    dsc:= xmlClassDescs[c];
    p:= 1;
    repeat
      p:= util1.PosFrom(p, ext, Lowercase(dsc.extensionlist));
      if p = 0 then Break;
      // check delimiters '|'
      if ((p > 1) and (dsc.extensionlist[p - 1] <> '|')) or
        ((p + Length(ext) < Length(dsc.extensionlist)) and (dsc.extensionlist[p + Length(ext)] <> '|'))
      then begin
        Inc(p, Length(ext));
        Continue;
      end;
      Result:= dsc.DocType;
      Exit;
    until False;
  end;

  // if not found, try predefined types
  if ext = DEFAULT_WMLC_FILEEXTENSION
  then Result:= edWMLCompiled;
  if ext = DEFAULT_WMLT_FILEEXTENSION
  then Result:= edWMLTemplate;
  // --- is there bug ? ---
  if (ext = DEFAULT_HTM_FILEEXTENSION) or (ext = DEFAULT_HTML_FILEEXTENSION)
  then Result:= edHTML;
  //
  if ext = DEFAULT_TEXT_FILEEXTENSION
  then Result:= edTEXT;
  if ext = DEFAULT_CSS_FILEEXTENSION
  then Result:= edCSS;
  if ext = DEFAULT_XML_FILEEXTENSION
  then Result:= edgenXML;
end;

// return short description string of document type: edText, edWML, edWMLTemplate, edWMLCompiled, edHTML, edCSS, edOEB, edOPF, edXHTML, edTxn
function GetDocTypeDesc(ADocType: TEditableDoc): String;
var
  c: Integer;
  dsc: TxmlClassDesc;
begin
  for c:= Low(xmlClassDescs) to High(xmlClassDescs) do begin
    dsc:= xmlClassDescs[c];
    if dsc.DocType = ADocType then begin
      Result:= dsc.desc;
      Exit;
    end;
  end;

  // if not found, try predefined types

  case ADocType of
    edText: Result:= 'Text document';
    edWMLTemplate: Result:= 'wml template';
    edWMLCompiled: Result:= 'wireless markup language compiled binary file';
    edHTML: Result:= 'HTML document';
    edCSS: Result:= 'CSS cascading style sheet';
    else begin
      Result:= 'unrecognized type of document';
    end;
  end; { case }
end;

initialization
  HTMLColorNames:= CreateHTMLColorNames;
  // get descriptions
  xmlClassDescCount:= 0;
{$IFDEF GENXML}
  Inc(xmlClassDescCount);
  SetLength(xmlClassDescs, xmlClassDescCount);
  generalXML.RegisterXML(xmlClassDescs[xmlClassDescCount - 1]);  // 9
{$ENDIF}
{$IFDEF GENWML}
  Inc(xmlClassDescCount);
  SetLength(xmlClassDescs, xmlClassDescCount);
  wml.RegisterXML(xmlClassDescs[xmlClassDescCount - 1]);  // 0
{$ENDIF}
{$IFDEF GENXHTML}
  Inc(xmlClassDescCount);
  SetLength(xmlClassDescs, xmlClassDescCount);
  xhtml.RegisterXML(xmlClassDescs[xmlClassDescCount - 1]);  //3
{$ENDIF}
{$IFDEF GENOEB}
  Inc(xmlClassDescCount, 2);
  SetLength(xmlClassDescs, xmlClassDescCount);
  oebDoc.RegisterXML(xmlClassDescs[xmlClassDescCount - 2]);  // 1
  oebPkg.RegisterXML(xmlClassDescs[xmlClassDescCount - 1]);  // 2
{$ENDIF}
{$IFDEF GENHHC}
  Inc(xmlClassDescCount, 2);
  SetLength(xmlClassDescs, xmlClassDescCount);
  xhhc.RegisterXML(xmlClassDescs[xmlClassDescCount - 2]);   // 6
  xhhk.RegisterXML(xmlClassDescs[xmlClassDescCount - 1]);   // 7
{$ENDIF}
{$IFDEF GENAPP}
  Inc(xmlClassDescCount, 3);
  SetLength(xmlClassDescs, xmlClassDescCount);
  bioTaxon.RegisterXML(xmlClassDescs[xmlClassDescCount - 3]);   // 4
  smit.RegisterXML(xmlClassDescs[xmlClassDescCount - 2]);       // 5
  RTC.RegisterXML(xmlClassDescs[xmlClassDescCount - 1]);        // 8
{$ENDIF}

finalization

  HTMLColorNames.Free;

end.


