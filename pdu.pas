unit pdu;
(*##*)
(*******************************************************************************
*                                                                             *
*   p  d  u                                                                    *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*   wireless markup language classes                                          *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Mar 05 2002                                                 *
*   Last revision: Apr 06 2002                                                *
*   Lines        : 3024                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Classes, SysUtils, Windows, WinSock, ScktComp,
  util1, util_xml, wmlc;

type
  uint8 = Byte;
  uint16 = Word;
  uint32 = Cardinal;
//  uintvar = String[5];  // 5

type
  TEncodeHeaderNameStyle = (ehsCode, ehsTextLenDescriptor, ehsTextLenDescriptorUIVarFollow, ehsNullTerminated);
{ Value Interpretation of First Octet
  0 - 30 This octet is followed by the indicated number (0 –30) of data octets
  31 This octet is followed by a uintvar, which indicates the number of data octets after it
  32 - 127 The value is a text string, terminated by a zero octet (NUL character)
  128 - 255 It is an encoded 7-bit value; this header has no more data
}
const
  DEFAULTHEADERNAMEENCODESTYLE = ehsCode;

type
  TCustomPDU = class(TObject)
  private
    FTid: uint8;
    FPDUType: uint8;
    FConnectionless: Boolean;
    FParameter: String;
    FHeadersPtr: TStrings;  // pointer to
    function GetPDUType: uint8;
    procedure SetPDUType(const AValue: uint8);
    function GetPDUTypeName: String;
    procedure SetPDUTypeName(const AValue: String);  // wmlc.PDUTypeTable
    procedure SetHeadersPtr(AValue: TStrings);
  protected
    FContent: String;

    function IsValidPDUTypes(const AValue: uint8): Boolean;
    // producers
  public
    constructor Create; overload;
    constructor Create(AConnectionless: Boolean; ATid: uint8; APDUType: uint8;
      const AParameter: String; AHeadersPtr: TStrings); overload;
    destructor Destroy; override;
    function Produce: String; overload;
    function Produce(AConnectionless: Boolean; ATid: uint8; APDUType: uint8;
      const AParameter: String; AHeadersPtr: TStrings): String; overload;
  published
    property Connectionless: Boolean read FConnectionless write FConnectionless;
    property PDUType: uint8 read GetPDUType write SetPDUType;
    property PDUTypeName: String read GetPDUTypeName write SetPDUTypeName;
    property HeadersPtr: TStrings read FHeadersPtr write SetHeadersPtr;
    property Parameter: String read FParameter write FParameter;    
  end;

{ decode connection-less mode request
  Parameters
    ARequest    request string
  Return
    Result      TID- connection-less transaction identifier
      0..255    TID
      -1        bad request (zero length)
    APDUType    i.e. $40- GET
      -1        bad request
    APar        usually requested URI
    AHeaders:   headers
}

function DecodeConnectionLessRequest(const ARequest: String; var APDUType: Integer;
  var APar: String; var AHeaders, ACapabilities: TStrings): Integer;

function ConnectionLessRequestAndReply(const ARequest: String; var APDUType: Integer;
  var APar: String; var AHeaders, ACapabilities: TStrings;
  const AVersion: String = DEFAULT_WMLC_ENCODING_VERSION): String;

type
  TVersionArray = array of Byte;

{----------------------------  utility functions  -----------------------------}

{ convert multi-byte encoded integer AValue to unsigned 32
}
function UIntVar2Uint(const AValue: String): Cardinal;
function UIntVar2UintL(const AValue: String; var ANextPos: Integer): Cardinal;
{ convert unsigned 32 AValue to multi-byte encoded integer
}
function Uint2UIntVar(AValue: Cardinal): String;

{ Integer-value = Short-Integer | Short-length 1*30 octet
  Delta-seconds-value = Integer-value
  first byte=#1..#30 multi-octet integer
             #80..#255 short-integer
}
function EncodeInteger(AValue: Cardinal): String;
function DecodeInteger(const AValue: String): Cardinal;
function DecodeIntegerL(const AValue: String; var ANextPos: Integer): Cardinal;

{ WSP 8.4.4.2 Length
  Encode length indicator is used to indicate the length of the value to follow
  Value-length = Short-length | (Length-quote Length)
  Short-length = <Any octet 0-30>
  Length-quote = <Octet 31>
  Length = Uintvar-integer
}
function EncodeLengthIndicator(ALen: Cardinal): String;
function DecodeLengthIndicator(AValue: String): Cardinal;

{
Version-value = Short-integer | Text-string
  The three most significant bits of the Short-integer value are interpreted to encode a major
  version number in the range 1-7, and the four least significant bits contain a minor version
  number in the range 0-14. If there is only a major version number, this is encoded by
  placing the value 15 in the four least significant bits. If the version to be encoded fits these
  constraints, a Short-integer must be used, otherwise a Text-string shall be used.
  Bit 7 6 5 4 3 2 1 0
      1 H H H L L L L  H-major L-minor. Bit 7 - short integer indicator
}
{ most significant version number first }
function EncodeVersionValue(AVersion: TVersionArray): String;
function DecodeVersionValue(AVersionStr: String): TVersionArray;
function DecodeVersionValueL(AVersionStr: String; var ANextPos: Integer): TVersionArray;

function VersionText2Array(const AVersionStr: String; var ANextPos: Integer): TVersionArray;

{ date & time
}
function EncodeDateTimeValue(ADateTime: TDateTime): String;
function DecodeDateTimeValue(AVersionStr: String): TDateTime;
function DecodeDateTimeValueL(AVersionStr: String; var ANextPos: Integer): TDateTime;

{ quoted string
}
function EncodeQuotedStrValue(AValue: String): String;
function DecodeQuotedStrValue(AValue: String): String;

{ text string
}
function EncodeTextStrValue(AValue: String): String;
function DecodeTextStrValue(AValue: String): String;

{ Q-value = 1*2 OCTET
  The encoding is the same as in Uintvar-integer, but with restricted size. When quality factor 0
  and quality factors with one or two decimal digits are encoded, they shall be multiplied by 100
  and incremented by one, so that they encode as a one-octet value in range 1-100,
  ie, 0.1 is encoded as 11 (0x0B) and 0.99 encoded as 100 (0x64). Three decimal quality
  factors shall be multiplied with 1000 and incremented by 100, and the result shall be encoded
  as a one-octet or two-octet uintvar, eg, 0.333 shall be encoded as 0x83 0x31.
  Quality factor 1 is the default value and shall never be sent.
}
function EncodeQValue(AQualityFactor: Byte; AValue: Extended): String;
function DecodeQValue(AValue: Char): Extended;

{ encode header shift (code page), see WSP 8.4.2.6 Header
  Note: bit 7 = 1 - header field name short integer number.
              = 0 - header page shift
  1, default header code page, including HTTP/1.1 headers and headers specified by the WAP Forum
  2-15, reserved for header code pages specified by the WAP Forum
  16-127, reserved for application specific code pages (string)
  128-255, reserved for future use
}
function EncodeHeaderShift(APage: Byte): String;

{ Constrained-encoding = Extension-Media | Short-integer
  This encoding is used for token values, which have no well-known binary encoding, or when
  the assigned number of the well-known encoding is small enough to fit into Short-integer.
  Extension-media = *TEXT End-of-string
  Theese functions works for code page 1 only
}
function EncodeConstrainedEncoding(const AContentType: String): String;
function DecodeConstrainedEncoding(AValue: String): String;

{ Parameter = Typed-parameter | Untyped-parameter
  Typed-parameter = Well-known-parameter-token Typed-value
    the actual expected type of the value is implied by the well-known parameter
  Well-known-parameter-token = Integer-value
    the code values used for parameters are specified in the Assigned Numbers appendix
  Typed-value = Compact-value | Text-value
  Compact-value = Integer-value | Date-value | Delta-seconds-value | Q-value | Version-value | Uri-value
  Untyped-parameter = Token-text Untyped-value
   the type of the value is unknown, but it shall be encoded as an integer, if that is possible.
  Untyped-value = Integer-value | Text-value
}
function EncodeParameterValue(const AParameter, AValue: String; const AVersion: String = DEFAULT_WMLC_ENCODING_VERSION): String;

function DecodeParameterValues(const ACodedValue: String; ASt: Integer; const ADelimiter: String): String;
{
}
function EncodeHeaderValue(const AHeaderString: String; const AVersion: String): String;
function EncodeHeadersValue(AHeaders: TStrings; const AVersion: String = DEFAULT_WMLC_ENCODING_VERSION): String;

{ utility
}

function ParseHTTPResponse(var AData: String; AHeaders: TStrings): Integer;

implementation

{----------------------------  utility functions  -----------------------------}

function Str2Float(const S: String): Extended;
var
  saveDS: Char;
begin
  saveDS:= DecimalSeparator;
  DecimalSeparator:= '.';
  try
    Result:= StrToFloat(s);
  except
    Result:= 0.0;
  end;
  DecimalSeparator:= saveDS;
end;

{ convert multi-byte encoded integer AValue to unsigned 32
}
function UIntVar2Uint(const AValue: String): Cardinal;
var
  i, len: Integer;
begin
  Result:= 0;
  i:= 1;
  len:= Length(AValue);
  while (i <= len) do begin
    Result:= (Result shl 7) or (Byte(AValue[i]) and $7f);
    if (Byte(AValue[i]) and $80) = 0
    then Break;
    Inc(i);
  end;
end;

function UIntVar2UintL(const AValue: String; var ANextPos: Integer): Cardinal;
var
  len: Integer;
begin
  Result:= 0;
  len:= Length(AValue);
  while (ANextPos <= len) do begin
    Result:= (Result shl 7) or (Byte(AValue[ANextPos]) and $7f);
    if (Byte(AValue[ANextPos]) and $80) = 0
    then Break;
    Inc(ANextPos);
  end;
  Inc(ANextPos);
end;

{ convert unsigned 32 AValue to multi-byte encoded integer
}
function Uint2UIntVar(AValue: Cardinal): String;
var
  c: Byte;
begin
  Result:= '';
  c:= 1;
  repeat
    Result:= Char((AValue and $7F) or $80) + Result;
    AValue:= AValue shr 7;
    Inc(c);
    // if c > 5 then Break;
  until AValue = 0;
  Byte(Result[c-1]):= Byte(Result[c-1]) and $7F; // skip bit 7
end;

{--------------------------------  TCustomPDU  --------------------------------}

constructor TCustomPDU.Create;
begin
  inherited Create;
  FTid:= 0;
  FPDUType:= 0;
  FParameter:= '';
  FHeadersPtr:= Nil;
  FConnectionless:= True;
end;

constructor TCustomPDU.Create(AConnectionless: Boolean; ATid: uint8; APDUType: uint8;
  const AParameter: String; AHeadersPtr: TStrings);
begin
  inherited Create;
  FTid:= ATid;
  FPDUType:= APDUType;
  FParameter:= AParameter;
  FHeadersPtr:= AHeadersPtr;
  FConnectionless:= AConnectionless;
end;

destructor TCustomPDU.Destroy;
begin
  inherited Destroy;
end;

function TCustomPDU.IsValidPDUTypes(const AValue: uint8): Boolean;
var
  i: Integer;
begin
  Result:= False;
  for i:= Low(wmlc.PDUTypeTable) to High(wmlc.PDUTypeTable) do begin
    if wmlc.PDUTypeTable[i].c = AValue then begin
      Result:= True;
      Exit;
    end;
  end;
end;

function TCustomPDU.Produce: String;
begin
  if FConnectionless
  then FContent:= Char(FTid)
  else FContent:= '';
  FContent:= FContent + Char(FPDUType);
  case FPDUType of
  $01: begin      //  Connect
    end;
  $02: begin      //  ConnectReply
    end;
  $03: begin      //  Redirect
    end;
  $04: begin      //  Reply
      { Status uint8 S-MethodResult.req::Status or S-Disconnect.req::Reason Codeor S-Unit-MethodResult.req::Status
        HeadersLen uintvar Length of the ContentType and Headers fields combined
        ContentType = Constrained-media | Content-general-form
          Content-general-form = Value-length Media-type
          Media-type = (Well-known-media | Extension-Media) *(Parameter)
        Headers (HeadersLen – length of ContentType) octets
        Data multiple octets
      }
    end;
  $05: begin      //  Disconnect
    end;
  $06: begin      //  Push
    end;
  $07: begin      //  ConfirmedPush
    end;
  $08: begin      //  Suspend
    end;
  $09: begin      //  Resume
    end;
  $40: begin      //  Get
      // 1. URILen uintvar Length of the URI field
      // 2. URI URILen octets S-MethodInvoke.req::Request URI or S-Unit-MethodInvoke.req::Request URI
      // 3. Headers
      FContent:= FContent + Uint2UIntVar(Length(FParameter)) + FParameter + EncodeHeadersValue(FHeadersPtr);  // EncodeLengthIndicator
    end;
  $41: begin      //  Options
    end;
  $42: begin      //  Head
    end;
  $43: begin      //  Delete
    end;
  $44: begin      //  Trace
    end;
  $60: begin      //  Post
    end;
  $61: begin      //  Put
    end;
  $80: begin      //  Data Fragment PDU
    end;
  end;
  Result:= FContent;
end;

function TCustomPDU.Produce(AConnectionless: Boolean; ATid: uint8; APDUType: uint8;
  const AParameter: String; AHeadersPtr: TStrings): String;
begin
  FTid:= ATid;
  FPDUType:= APDUType;
  FParameter:= AParameter;
  FHeadersPtr:= AHeadersPtr;
  FConnectionless:= AConnectionless;
  Result:= Produce;
end;

function TCustomPDU.GetPDUType: uint8;
begin
  Result:= FPDUType;
end;

procedure TCustomPDU.SetPDUType(const AValue: uint8);
begin
  if not IsValidPDUTypes(AValue) then begin
    raise Exception.CreateFmt('Invalid PDU type number %x', [AValue]);
  end;
  FPDUType:= AValue;
end;

function TCustomPDU.GetPDUTypeName: String;
begin
  Result:= wmlc.getPDUTypeName(FPDUType);
end;

procedure TCustomPDU.SetPDUTypeName(const AValue: String);  // wmlc.PDUTypeTable
var
  c: Integer;
begin
  c:= wmlc.getPDUTypeCode(AValue);
  if c < 0 then begin
    // FPDUType:= 0;
    raise Exception.CreateFmt('Invalid PDU type %s', [AValue]);
  end else FPDUType:= c;
end;

procedure TCustomPDU.SetHeadersPtr(AValue: TStrings);
begin
  FHeadersPtr:= AValue;
end;

{ encode short-integer:     $80-$FF -> 0..127
      or multibyte integer: (len=#0..#30)len octets
  Parameters:
    AValue      short-integer, multibyte integer, uintvar
  Return:
    Result      uint
}
function EncodeInteger(AValue: Cardinal): String;
var
  c: Byte;
begin
  if AValue <= 127
  then Result:= Char(Byte(AValue) or $80)  // short integer
  else begin   // multi-octet integer 1..30 octets
    c:= 0;
    repeat
      Result:= Char(AValue and $FF) + Result;
      AValue:= AValue shr 8;
      Inc(c);
      // if c > 30 then Break; - what for? 4 bytes is less 30 octets anyway
    until AValue = 0;
    // set length descriptor, first byte
    Insert(Char(c), Result, 1);
  end;
end;

{ decode short-integer:     $80-$FF -> 0..127
         multibyte integer: (len=#0..#30)len octets
         uintvar            #31 uintvarval
  Parameters:
    AValue:     short-integer, multibyte integer, uintvar
  Return:
    Result      uint
}
function DecodeInteger(const AValue: String): Cardinal;
var
  L, fl: Byte;
  i: Integer;
begin
  fl:= Length(AValue);
  if fl = 0 then begin
    // raise Exception.CreateFmt('', [AValue]);
    Result:= 0;
    Exit;
  end;
  L:= Byte(AValue[1]);
  case L of
    0..30:begin    // multi-octet integer 1..30 octets
      Result:= 0;
      i:= 2;
      Inc(L);
      while (i <= L) and (i <= fl) do begin
        Result:= (Result shl 8) or Byte(AValue[i]);
        Inc(i);
      end;
    end;
  31:begin         // uintvar
      Result:= UIntVar2Uint(AValue);
      Exit;
    end;
  else begin   // $80..$FF: short integer
      Result:= L and $7F;
    end;
  end;
end;

{ decode short-integer:     $80-$FF -> 0..127
         multibyte integer: (len=#0..#30)len octets
         uintvar            #31 uintvarval
  Parameters:
    AValue      short-integer, multibyte integer, uintvar
    AFr         start position in AValue
  Return:
    Result      uint
    ANextPos    AFr + length of AValue. 1 if length is zero
  Notes:
    return length of AValue greater 0 to avoid infinite loop in parser
}
function DecodeIntegerL(const AValue: String; var ANextPos: Integer): Cardinal;
var
  fl, L: Integer;
begin
  fl:= Length(AValue);
  if (ANextPos > fl) then begin
    // Inc(ANextPos); // go to the next octet to avoid infinite loop
    Result:= 0;
    Exit;
  end;
  L:= Byte(AValue[ANextPos]);
  case L of
  0..30:begin      // multi-octet integer 1..30 octets
      Result:= 0;
      Inc(ANextPos);
      L:= L + ANextPos;  // point to the last
      while (ANextPos < L) and (ANextPos <= fl) do begin
        Result:= (Result shl 8) or Byte(AValue[ANextPos]);
        Inc(ANextPos);
      end;
    end;
  31:begin         // uintvar
      Result:= UIntVar2UintL(AValue, ANextPos);
    end;
  else begin   // $80..$FF: short integer
      Result:= L and $7F;
      Inc(ANextPos); // go to the next octet
    end;
  end; { case }
end;

{ WSP 8.4.4.2 Length
  Encode length indicator is used to indicate the length of the value to follow
  Value-length = Short-length | (Length-quote Length)
  Short-length = <Any octet 0-30>
  Length-quote = <Octet 31>
  Length = Uintvar-integer
}
function EncodeLengthIndicator(ALen: Cardinal): String;
begin
// if ALen < 0 then Result:= '' else
  if ALen <=30
  then Result:= Char(ALen and $7F)                  // 0..30 short length
  else Result:= #31 + Uint2UIntVar(Cardinal(ALen))  // #31 length quote; uintvar
end;

function DecodeLengthIndicator(AValue: String): Cardinal;
begin
  if Length(AValue) = 0 then Result:= 0 else begin
    if AValue[1] <= #30
    then Result:= Byte(AValue[1])                         // 0..30 short length
    else Result:= UIntVar2Uint(Copy(AValue, 2, MaxInt));  // #31 length quote; uintvar
  end;
end;

{
Q-value = 1*2 OCTET
  The encoding is the same as in Uintvar-integer, but with restricted size. When quality factor 0
  and quality factors with one or two decimal digits are encoded, they shall be multiplied by 100
  and incremented by one, so that they encode as a one-octet value in range 1-100,
  ie, 0.1 is encoded as 11 (0x0B) and 0.99 encoded as 100 (0x64). Three decimal quality
  factors shall be multiplied with 1000 and incremented by 100, and the result shall be encoded
  as a one-octet or two-octet uintvar, eg, 0.333 shall be encoded as 0x83 0x31.
  Quality factor 1 is the default value and shall never be sent.
}

{
Version-value = Short-integer | Text-string
  The three most significant bits of the Short-integer value are interpreted to encode a major
  version number in the range 1-7, and the four least significant bits contain a minor version
  number in the range 0-14. If there is only a major version number, this is encoded by
  placing the value 15 in the four least significant bits. If the version to be encoded fits these
  constraints, a Short-integer must be used, otherwise a Text-string shall be used.
  Bit 7 6 5 4 3 2 1 0
      1 H H H L L L L  H-major L-minor. Bit 7 - short integer indicator
}
{ most significant version number first }

function EncodeVersionAsText(AVersion: TVersionArray): String;
var
  i, L: Integer;
begin
  // Text-string = [Quote] *TEXT End-of-string
  //   If the first character in the TEXT is in the range of 128-255, a Quote character must precede it.
  //   Otherwise the Quote character must be omitted. The Quote is not part of the contents.
  Result:= '';
  L:= Length(AVersion);
  for i:= 0 to L - 1 do begin
    Result:= Result + IntToStr(AVersion[i]) + '.';
  end;
  Delete(Result, Length(Result), 1);
  // Result[Length(Result)]:= #0; // delete last dot '.', set End-of-string
end;


function EncodeVersionValue(AVersion: TVersionArray): String;
var
  L: Integer;
begin
  L:= Length(AVersion);
  case L of
  0: Result:= '';
  1: if (AVersion[0] in [1..7])
     then Result:= Char((AVersion[0] shl 4) or $8F)  // set bits 7 and 3,2,1,0 to 1
     else Result:= EncodeVersionAsText(AVersion) + #0;
  2: if (AVersion[0] in [1..7]) and (AVersion[1] <= 14)
     then Result:= Char((AVersion[0] shl 4) or (AVersion[1]) or $80) // set bit 7, major and minor versions
     else Result:= EncodeVersionAsText(AVersion) + #0;
  else Result:= EncodeVersionAsText(AVersion) + #0;
  end; { case }
end;

function DecodeVersionValueAsShortInt(const AByte: Byte): TVersionArray;
var
  b: Byte;
begin
  // b:= AByte and $7F;
  b:= AByte;
  if (b and $F) = $F then begin
    // major only
    SetLength(Result, 1);
    Result[0]:= b shr 4;
  end else begin
    // major, minor
    SetLength(Result, 2);
    Result[0]:= (b shr 4);  // major number 1..7
    Result[1]:= b and $F;  // minor 0..14 exists
  end;
end;

function DecodeVersionValue(AVersionStr: String): TVersionArray;
var
  i, c, L, st: Integer;
begin
  if Length(AVersionStr) = 0 then begin
    SetLength(Result, 0);
    Exit;
  end;
  if Byte(AVersionStr[1]) >= $80 then begin
    // short integer
    Result:= DecodeVersionValueAsShortInt(Byte(AVersionStr[1]));
  end else begin
    // text representation
    // ...
    SetLength(Result, 0);
    L:= Length(AVersionStr);
    st:= 1;
    c:= 0;
    if AVersionStr[1] = '"'
    then i:= 2
    else i:= 1;
    while i <= L do begin  // last is #0, do not skip
      case AVersionStr[i] of
      // '0'..'9':;
      #0, '.':begin
          // store version
          Inc(c);
          SetLength(Result, c);
          Result[c-1]:= StrToIntDef(Copy(AVersionStr, st, i - st), 0);  // raise ?!!
          st:= i + 1;
        end;
      end; { case }
    end;
  end;
end;

function DecodeVersionValueL(AVersionStr: String; var ANextPos: Integer): TVersionArray;
var
  c, L, st: Integer;
begin
  if ANextPos > Length(AVersionStr) then begin
    SetLength(Result, 0);
    Exit;
  end;
  if Byte(AVersionStr[ANextPos]) >= $80 then begin
    // short integer
    Result:= DecodeVersionValueAsShortInt(Byte(AVersionStr[ANextPos]));
    Inc(ANextPos);
  end else begin
    // text representation
    // ...
    SetLength(Result, 0);
    L:= Length(AVersionStr);
    st:= ANextPos;
    c:= 0;
    if AVersionStr[ANextPos] = '"'
    then Inc(ANextPos);
    while ANextPos <= L do begin  // last is #0, do not skip
      case AVersionStr[ANextPos] of
      // '0'..'9':;
      #0, '.':begin
          // store version
          Inc(c);
          SetLength(Result, c);
          Result[c-1]:= StrToIntDef(Copy(AVersionStr, st, ANextPos - st), 0);  // raise ?!!
          st:= ANextPos + 1;
          if AVersionStr[ANextPos] = #0
          then Break;
        end;
      end; { case }
    end; { while }
    Inc(ANextPos);
  end;
end;

{ convert '1.2' to version array
}
function VersionText2Array(const AVersionStr: String; var ANextPos: Integer): TVersionArray;
var
  st, c, L: Integer;
begin
  SetLength(Result, 0);    // clear array
  L:= Length(AVersionStr);
  if ANextPos > L then begin
    Exit;
  end;

  c:= 0;
  if AVersionStr[ANextPos] = '"'
  then Inc(ANextPos);
  st:= ANextPos;
  while ANextPos <= L do begin  // last is #0, do not skip
    case AVersionStr[ANextPos] of
    // '0'..'9':;
    #0, '.':begin
        // store version
        Inc(c);
        SetLength(Result, c);
        Result[c-1]:= StrToIntDef(Copy(AVersionStr, st, ANextPos - st), 0);  // raise ?!!
        st:= ANextPos + 1;
        if AVersionStr[ANextPos] = #0
        then Break;
      end;
    end; { case }
  end;
  Inc(ANextPos);
end;

{ date & time
}
function EncodeDateTimeValue(ADateTime: TDateTime): String;
var
  vl: Cardinal;
  c: Byte;
begin
// UnixDateDelta 25569 is number of days between December 31, 1899 and January 1 1970
// for converting date-time values between TDateTime and TIME_T
// 25569 days * 86400 = 2209161600 secs
  vl:= SecsPerDay * Trunc(ADateTime - UnixDateDelta);
  // long integer, multi-octet integer 1..30 octets
  Result:= '0';  // reserve length descriptor, first byte
  c:= 0;
  repeat
    Result:= Char(vl and $FF) + Result;
    vl:= vl shr 8;
    Inc(c);
    // if c > 30 then Break;
  until vl = 0;
  Result[1]:= Char(c)
end;

function DecodeDateTimeValue(AVersionStr: String): TDateTime;
var
  p: Integer;
begin
  p:= 1;
  Result:= DecodeDateTimeValueL(AVersionStr, p);
end;

function DecodeDateTimeValueL(AVersionStr: String; var ANextPos: Integer): TDateTime;
var
  b: Cardinal;
begin
  // multi-octet integer 1..30 octets
  b:= DecodeIntegerL(AVersionStr, ANextPos);  // secs since 1970-1-1, 00:00:00 GMT
  // UnixDateDelta 25569 is number of days between December 31, 1899 and January 1 1970
  // for converting date-time values between TDateTime and TIME_T
  // 25569 days * 86400 = 2209161600 secs
  Result:= UnixDateDelta + (b / SecsPerDay);  // days and time after 1970 + 1970
end;

{ text string
}
function EncodeTextStrValue(AValue: String): String;
begin
  if (Length(AValue) > 0) and (AValue[1] < #128)
  then Result:= '"' + AValue + #0
  else Result:= AValue + #0;
end;

function DecodeTextStrValue(AValue: String): String;
var
  L: Integer;
begin
  L:= Length(AValue);
  if L = 0 then begin
    Result:= '';  // raise, #0 expected
    Exit;
  end;
  if AValue[L] = #0
  then Dec(L);
  if AValue[1] = '"'
  then Result:= Copy(AValue, 2, L - 1)
  else Result:= Copy(AValue, 1, L)
end;

{ quoted string
}
function EncodeQuotedStrValue(AValue: String): String;
begin
  Result:= '"' + AValue + #0;
end;

function DecodeQuotedStrValue(AValue: String): String;
var
  L: Integer;
begin
  L:= Length(AValue);
  if L = 0 then begin
    Result:= ''; // raise, #0 expected
    Exit;
  end;
  if AValue[L] = #0
  then Dec(L);
  if AValue[1] = '"'
  then Result:= Copy(AValue, 2, L - 1)
  else Result:= Copy(AValue, 1, L)
end;

{ Q-value = 1*2 OCTET
  The encoding is the same as in Uintvar-integer, but with restricted size. When quality factor 0
  and quality factors with one or two decimal digits are encoded, they shall be multiplied by 100
  and incremented by one, so that they encode as a one-octet value in range 1-100,
  ie, 0.1 is encoded as 11 (0x0B) and 0.99 encoded as 100 (0x64). Three decimal quality
  factors shall be multiplied with 1000 and incremented by 100, and the result shall be encoded
  as a one-octet or two-octet uintvar, eg, 0.333 shall be encoded as 0x83 0x31.
  Quality factor 1 is the default value and shall never be sent.
}
function EncodeQValue(AQualityFactor: Byte; AValue: Extended): String;
var
  b: Byte;
  w: Word;
begin
  case AQualityFactor of
  0, 1, 2: begin
      // 0.0..0.99
      b:= Trunc((AValue * 100) + 1);
      Result:= Char(b and $7F);  // just be sure bit 7 is 0
    end;
  3: begin
      w:= Trunc((AValue * 1000) + 100);
      Result:= Uint2UintVar(w);
    end;
  else begin
      Result:= '';
      // raise
    end;
  end;
end;

function DecodeQValue(AValue: Char): Extended;
var
  L: Integer;
begin
  L:= Length(AValue);
  if L = 0 then begin
    Result:= 0.0;
    // raise
    Exit;
  end;
  if (Byte(AValue) and $80) > 0 then begin
    // quality factor 3
    Result:= (UintVar2Uint(AValue) - 100 )/ 1000;
  end else begin
    // quality factors 0, 1, 2
    if L <> 1 then begin
      Result:= 0.0;
      // raise
      Exit;
    end;
    Result:= (Byte(AValue) - 1) / 100;
  end;
end;

{
  8.4.2.6 Header
  Note: bit 7 = 1 - header field name short integer number.
              = 0 - header page shift
  1, default header code page, including HTTP/1.1 headers and headers specified by the WAP Forum
  2-15, reserved for header code pages specified by the WAP Forum
  16-127, reserved for application specific code pages (string)
  128-255, reserved for future use
}
function EncodeHeaderShift(APage: Byte): String;
begin
  case APage of
  1..31: Result:= Char(APage);         // Short-cut-shift-delimiter
  32..255: Result:= #$7F + Char(APage); // Shift-delimiter + page octet
  else Result:= ''                     // no page 0 exists
  end;
end;

{ Constrained-encoding = Extension-Media | Short-integer
  This encoding is used for token values, which have no well-known binary encoding, or when
  the assigned number of the well-known encoding is small enough to fit into Short-integer.
  Extension-media = *TEXT End-of-string

  Theese functions works for code page 1 only
}
function EncodeConstrainedEncoding(const AContentType: String): String;
var
  c: Integer;
begin
  c:= GetHTTPContentTypeCode(AContentType);
  if c >= 0
  then Result:= Uint2UIntVar(c)
  else Result:= AContentType + #0;
end;

function DecodeConstrainedEncoding(AValue: String): String;
var
  L: Integer;
begin
  if Length(AValue) = 0 then begin
    // raise
    Result:= '';
    Exit;
  end;
  if (Byte(AValue[1]) and $80) > 0 then begin
    Result:= getHTTPContentTypeName(UintVar2Uint(AValue[1]));
  end else begin
    // delete last #0
    Result:= AValue;
    L:= Length(Result);
    if (L > 0) and (Result[L] = #0) then begin
      Delete(Result, L, 1);
    end;
  end;
end;

{ Parameter = Typed-parameter | Untyped-parameter
  Typed-parameter = Well-known-parameter-token Typed-value
    the actual expected type of the value is implied by the well-known parameter
  Well-known-parameter-token = Integer-value
    the code values used for parameters are specified in the Assigned Numbers appendix
  Typed-value = Compact-value | Text-value
  Compact-value = Integer-value | Date-value | Delta-seconds-value | Q-value | Version-value | Uri-value
  Untyped-parameter = Token-text Untyped-value
   the type of the value is unknown, but it shall be encoded as an integer, if that is possible.
  Untyped-value = Integer-value | Text-value
}
function EncodeParameterValue(const AParameter, AValue: String; const AVersion: String = DEFAULT_WMLC_ENCODING_VERSION): String;
var
  p, c: Integer;
  q: Byte;
  ext: Extended;
  ok: Boolean;
  dt: TDateTime;
begin
  c:= getParameterCode(AParameter);
  if c >= 0
  then Result:= Uint2UIntVar(c)
  else Result:= AParameter + #0;
  // value
  p:= 1;
  case c of
  -1: begin
        // unknown parameter. Code value as text string
        Result:= Result + EncodeTextStrValue(AValue);
      end;
  $00:begin  // q-value
        ext:= Str2Float(AValue);
        q:= Length(AValue) - Pos('.', AValue);
        if q > 3
        then q:= 3;
        Result:= Result + EncodeQValue(q, ext);  // q-value
      end;
  $01:begin  // Well-known-charset
        Result:= Result + EncodeInteger(CharSetName2Code(AValue));
      end;
  $02:begin  // Version-value
        Result:= Result + EncodeVersionValue(VersionText2Array(AValue, p));
      end;
  $08,$11:begin  // Short-Integer. Limit to 128
        Result:= Result + EncodeInteger(StrToIntDef(AValue, 0) and $7F);
      end;
  $0E,    // Delta-seconds-value
  $03,$16:begin  // Integer-value
        Result:= Result + EncodeInteger(StrToIntDef(AValue, 0));
      end;
  $12, $17..$1D, // text-value
  $05, $06, $0A..$0D, $0F:begin  // Text-string
        if (Length(AValue) > 0) and (AValue[1] > #127)
        then Result:= Result + '"' + AValue + #0
        else Result:= Result + AValue + #0;
      end;
  $07:begin  // Field-name
        c:= GetHTTPHeaderFieldCode(AValue, AVersion);
        if c >= 0
        then Result:= Result + EncodeInteger(c)
        else Result:= Result + AValue + #0;
      end;
  $09:begin   // Constrained-encoding
        // it can be short integer or constrained-encoding
        c:= GetHTTPContentTypeCode(AValue);
        if (c >= 0) and (c <= 127)
        then Result:= Result + Char(Byte(c) or $80)
        else Result:= Result + AValue + #0;
      end;
  $10:begin;  // secure parameter, no value
        // Result:= Result + #0;
      end;
  $13..$15:begin // date-value
        dt:= ParseDate(AValue, ok);
        if ok
        then Result:= Result + EncodeDateTimeValue(dt)
        else Result:= '';
      end;
  end;
end;

function DecodeParameterValues(const ACodedValue: String; ASt: Integer; const ADelimiter: String): String;
var
  i, c, p, L: Integer;
  ext: Extended;
  SaveDecimalSeparator: Char;
  dt: TDateTime;

  function GetTextVal: String;
  begin
    if ACodedValue[i] = '"'
    then Inc(i);
    p:= i;
    while (i <= L) and (ACodedValue[i] <> #0)
    do Inc(i);
    Result:= Copy(ACodedValue, p, i - p);
    Inc(i);
  end;

begin
  Result:= '';
  i:= ASt;
  L:= Length(ACodedValue);
  while i <= L do begin
    // get parameter code or text
    if Length(Result) > 0
    then Result:= Result + ADelimiter  // delimit previous parameter
    else Result:= #32;           // delimit first parameter

    // is integer?
    if (ACodedValue[i] < #$20) or (ACodedValue[i] >= #$80) then begin
      // get code
      c:= DecodeIntegerL(ACodedValue, i);
      Result:= Result + getParameterName(c);
    end else begin
      c:= -1;  // not well-known parameter name
      // get text, skip quote if exists
      Result:= Result + GetTextVal;
    end;
    Result:= Result + '=';

    if (i > L) then Break;  // check is stream finished

    // empty parameter, skip
    if ACodedValue[i] = #0 then begin
      Inc(i);
      Continue;
    end;

    if (ACodedValue[i] >= #$20) or (ACodedValue[i] < #$80) then begin
      // get text value
      Result:= Result + GetTextVal;
      Continue;
    end;

    if (c = -1) then begin
      { no well-known parameter or coded as text
        ?!! - if it is text, it parsed as text (see above)
      }
      Inc(i);   // just in case
      Continue; // just in case
    end;

    if (ACodedValue[i] < #$20) or (ACodedValue[i] >= #$80) then begin
      // get parameter integer value.
      c:= DecodeIntegerL(ACodedValue, i);
      Result:= Result + IntToStr(c);
      Continue;
    end;

    { no integer, no text. It is compact value }
    case c of
    $00:begin  // q-value
          ext:= DecodeQValue(ACodedValue[i]);
          SaveDecimalSeparator:= DecimalSeparator;
          DecimalSeparator:= '.';
          Result:= Result + FloatToStrF(ext, ffGeneral, 1, 2);
          DecimalSeparator:= SaveDecimalSeparator;
        end;
    $01:begin  // Well-known-charset
          c:= DecodeIntegerL(ACodedValue, i);
          Result:= Result + CharSetCode2Name(c);
        end;
    $02:begin  // Version-value
          Result:= Result + EncodeVersionAsText(VersionText2Array(ACodedValue, i));
        end;
    $08,$11, // Integer-value
    $0E,     // Delta-seconds-value
    $03,$16:begin  // Short-Integer. Limit to 128
          Result:= Result + IntToStr(DecodeIntegerL(ACodedValue, i));
        end;
    $07:begin  // Field-name
          c:= DecodeIntegerL(ACodedValue, i);
          Result:= Result + getHTTPHeaderFieldName(c);
        end;
    $09:begin   // Constrained-encoding
          c:= DecodeIntegerL(ACodedValue, i);
          Result:= Result + getHTTPContentTypeName(c);
        end;
    $13..$15:begin // date-value
          dt:= DecodeDateTimeValueL(ACodedValue, i);
          Result:= Result + GetDateTimeStamp(dt);
        end;
    else begin;  // $10 secure parameter, no value
          // ACodedValue = 0
          Inc(i);
        end;
    end; { case }
  end;
end;

{
wmlc.HTTPHeaderFieldNameTable
Basic
Text-string = [Quote] *TEXT End-of-string.
  If the first character in the TEXT is in the range of 128-255, a Quote character must precede it.
  Otherwise the Quote character must be omitted. The Quote is not part of the contents.
Token-text = Token End-of-string
Quoted-string = <Octet 34> *TEXT End-of-string
  The TEXT encodes an RFC2616 Quoted-string with the enclosing quotation-marks <"> removed
Extension-media = *TEXT End-of-string
  This encoding is used for media values, which have no well-known binary encoding
Short-integer = OCTET
  Integers in range 0-127 shall be encoded as a one octet value with the most significant bit set
  to one (1xxx xxxx) and with the value in the remaining least significant bits.
Long-integer = Short-length Multi-octet-integer
  The Short-length indicates the length of the Multi-octet-integer
Multi-octet-integer = 1*30 OCTET
  The content octets shall be an unsigned integer value
  with the most significant octet encoded first (big-endian representation).
  The minimum number of octets must be used to encode the value.
Uintvar-integer = 1*5 OCTET or 1*30 OCTET
  The encoding is the same as the one defined for uintvar in Section 8.1.2.
Constrained-encoding = Extension-Media | Short-integer
  This encoding is used for token values, which have no well-known binary encoding, or when
  the assigned number of the well-known encoding is small enough to fit into Short-integer.
Quote = <Octet 127>
End-of-string = <Octet 0>

Length
Value-length = Short-length | (Length-quote Length)
  Value length is used to indicate the length of the value to follow
Short-length = <Any octet 0-30>
Length-quote = <Octet 31>
Length = Uintvar-integer

Parameter values
No-value = <Octet 0>
  Used to indicate that the parameter actually has no value,
  eg, as the parameter "bar" in ";foo=xxx; bar; baz=xyzzy".
Text-value = No-value | Token-text | Quoted-string
Integer-Value = Short-integer | Long-integer
Date-value = Long-integer
  The encoding of dates shall be done in number of seconds from 1970-01-01, 00:00:00 GMT.
Delta-seconds-value = Integer-value
Q-value = 1*2 OCTET
  The encoding is the same as in Uintvar-integer, but with restricted size. When quality factor 0
  and quality factors with one or two decimal digits are encoded, they shall be multiplied by 100
  and incremented by one, so that they encode as a one-octet value in range 1-100,
  ie, 0.1 is encoded as 11 (0x0B) and 0.99 encoded as 100 (0x64). Three decimal quality
  factors shall be multiplied with 1000 and incremented by 100, and the result shall be encoded
  as a one-octet or two-octet uintvar, eg, 0.333 shall be encoded as 0x83 0x31.
  Quality factor 1 is the default value and shall never be sent.
Version-value = Short-integer | Text-string
  The three most significant bits of the Short-integer value are interpreted to encode a major
  version number in the range 1-7, and the four least significant bits contain a minor version
  number in the range 0-14. If there is only a major version number, this is encoded by
  placing the value 15 in the four least significant bits. If the version to be encoded fits these
  constraints, a Short-integer must be used, otherwise a Text-string shall be used.
}
type
  TGetCodeByName = function (const AStr: String): Integer;
  TGetNameByCode = function (ACode: Integer): String;

function EncodeHeaderValue(const AHeaderString: String; const AVersion: String): String;
var
  HeaderField: String;
  HeaderFieldNo: Integer;
  pars, ext: TStrings;
  i, c, L, p: Integer;
  s1, s2: String;
  dt: TDateTime;
  v: Boolean;
  phdr: PChar;
  versionarray: TVersionArray;

  function CreateCredentials: String;
  var
    i, j: Integer;
    sa: array of ShortString;
    spacecontinue: Boolean;
  begin
    Result:= '';
    i:= 0;
    j:= 0;
    spacecontinue:= False;
    while phdr[i] <> #0 do begin
      case phdr[i] of
      '"', '''', '=':;
      #0..#32: begin
          if spacecontinue
          then Continue;
          Inc(j);
          SetLength(sa, j);
          sa[j]:= '';
          spacecontinue:= True;
        end;
      else begin
          if Length(sa[j]) < 255
          then sa[j]:= sa[j] + phdr[i];
        end;
      end;
    end;

    // validate method, user and password
    case Length(sa) of
      0: Exit;
      1:begin
          SetLength(sa, 3);
          sa[1]:= '';
          sa[2]:= '';
        end;
      2:begin
          SetLength(sa, 3);
          sa[2]:= '';
        end;
    end; { case }
    if CompareText(sa[0], 'basic') = 0 then begin
      // basic
      Result:= #128 + sa[1] + #0 + sa[2] + #0
    end else begin
      // authentification scheme
      for i:= 0 to Length(sa) - 1 do begin
        Result:= Result + sa[i] + #0;
      end;
    end;
    // free up
    SetLength(sa, 0);
  end;

  function CreateWarn: String;
  var
    i, j: Integer;
    sa: array of ShortString;
    spacecontinue: Boolean;
  begin
    Result:= '';
    i:= 0;
    j:= 0;
    spacecontinue:= False;
    while phdr[i] <> #0 do begin
      case phdr[i] of
      '"', '''', '=':;
      #0..#32: begin
          if spacecontinue
          then Continue;
          Inc(j);
          SetLength(sa, j);
          sa[j]:= '';
          spacecontinue:= True;
        end;
      else begin
          if Length(sa[j]) < 255
          then sa[j]:= sa[j] + phdr[i];
        end;
      end;
    end;

    // validate
    case Length(sa) of
      0: Exit;
      1:begin
          c:= GetWarning2Code(StrToIntDef(sa[0], 0));
          if c >= 0
          then Result:= Char($80 or c);
          Exit;
        end;
      2:begin
          SetLength(sa, 3);
          sa[2]:= '';
        end;
    end; { case }
    // short integer code
    c:= GetWarning2Code(StrToIntDef(sa[0], 0));
    if c >= 0 then begin
      s1:= Char($80 or c) + sa[1] + #0;
      // encode dates
      for i:= 2 to Length(sa) - 1 do begin
        dt:= util_xml.ParseDate(sa[i], v);
        if v
        then s1:= s1 + EncodeDateTimeValue(dt)
        else Break;
      end;
      Result:= EncodeLengthIndicator(Length(s1)) + s1;
    end;
    // free up
    SetLength(sa, 0);
  end;

  { Warn-code | (Value-length Warn-code Warn-target *Warn-date)
    Warn-code = Short-integer
      assigned value Warning code (see [CCPPEx])
      0x10 100; 0x11 101; 0x12 102; 0x20 200; 0x21 201; 0x22 202; 0x23 203
    Warn-target = Uri-value | host [ “ :” port ]
    Warn-date = Date-value
}
  function CreateWarnProfile: String;
  var
    i, j: Integer;
    sa: array of ShortString;
    spacecontinue: Boolean;
  begin
    Result:= '';
    i:= 0;
    j:= 0;
    spacecontinue:= False;
    while phdr[i] <> #0 do begin
      case phdr[i] of
      '"', '''', '=':;
      #0..#32: begin
          if spacecontinue
          then Continue;
          Inc(j);
          SetLength(sa, j);
          sa[j]:= '';
          spacecontinue:= True;
        end;
      else begin
          if Length(sa[j]) < 255
          then sa[j]:= sa[j] + phdr[i];
        end;
      end;
    end;

    // validate
    case Length(sa) of
      0: Exit;
      1:begin
          c:= GetProfileWarning2Code(StrToIntDef(sa[0], 0));
          if c >= 0
          then Result:= Char($80 or c);  // else field is invalid, Result = ''
          Exit;
        end;
      2:begin
          SetLength(sa, 3);
          sa[2]:= '';
        end;
    end; { case }
    // short integer code
    c:= GetProfileWarning2Code(StrToIntDef(sa[0], 0));
    if c >= 0 then begin
      s1:= Char($80 or c) + sa[1] + #0 + sa[2] + #0;
      Result:= EncodeLengthIndicator(Length(s1)) + s1;
    end; // else field is invalid, Result = ''
    // free up
    SetLength(sa, 0);
  end;

  function CreateShortIntOrText(AFldNo: Integer; AGetCodeByName: TGetCodeByName): String;
  begin
    c:= AGetCodeByName(AHeaderString);
    if c >= 0
    then Result:= Char($80 or AFldNo) + Char(c)
    else Result:= Char($80 or AFldNo) + AHeaderString + #0;
  end;

  function CreateQList(AFldNo: Integer; AGetCodeByName: TGetCodeByName): String;
  var
    i: Integer;
  begin
    ExtractHeaderExtFields(PChar(AHeaderString), pars, ext);
    Result:= '';
    for i:= 0 to pars.Count - 1 do begin
      c:= AGetCodeByName(pars[i]);
      s2:= GetHeaderExt(i, 'q', pars, ext);
      if c >= 0
      then s1:= EncodeInteger(c)
      else s1:= pars[i] + #0;  // possible bug, skip quote
      if (c >= 0) and (Length(s2) = 0) then begin
        s1:= Char($80 or AFldNo) + s1;
        // code
        Result:= Result + Char($80 or AFldNo) + EncodeInteger(c);
      end else begin
        if (Length(s2) > 0)
        then s1:= s1 + #128 + EncodeQValue(1, Str2Float(s2));
        // list of accept
        Result:= Result + Char($80 or AFldNo) + EncodeLengthIndicator(Length(s1)) + s1;
      end;
    end;
  end;

begin
  pars:= TStringList.Create;
  ext:= TStringList.Create;
  phdr:= PChar(AHeaderString);
  HeaderField:= GetHeaderName(phdr);
  HeaderFieldNo:= GetHTTPHeaderFieldCode(HeaderField, AVersion);
  if phdr = #0 then begin
    Result:= '';
    Exit;
  end;
  Result:= Char($80 or HeaderFieldNo);
  case HeaderFieldNo of
  $00:begin  { * Accept }
        { i.e Accept: text/plain; q=0.5, text/html, text/x-dvi; q=0.8, text/x-c }
        Result:= CreateQList(0, @GetHTTPContentTypeCode);
      end;
  $01,$3B:begin  { * Accept-charset, code 1 deprecated }
        { i.e Accept-Charset: iso-8859-5, unicode-1-1;q=0.8 }
        Result:= CreateQList(1, @CharSetName2Code);
      end;
  $02,$3C:begin  { * Accept-encoding, code 2 deprecated }
        { Accept-encoding-value = Content-encoding-value | Accept-encoding-general-form
          Accept-encoding-general-form = Value-length ( Content-encoding-value | Any-encoding ) [Q-value]
          Content-encoding-value = (Gzip | Compress | Deflate | Token-text)
          Gzip = <Octet 128>
          Compress = <Octet 129>
          Deflate = <Octet 130>
          Any-encoding = <Octet 131>
        }
        Result:= CreateQList(2, @GetContentEncodingCode);
      end;
  $03:begin  { * Accept-language }
        { i.e Accept-Language: da, en-gb;q=0.8, en;q=0.7
          Accept-language-value = Constrained-language | Accept-language-general-form
          Accept-language-general-form = Value-length (Well-known-language | Text-string) [Q-value]
          Constrained-language = Any-language | Constrained-encoding
          Well-known-language = Any-language | Integer-value
          Both are encoded using values from Character Set Assignments table in Assigned Numbers
        }
        Result:= CreateQList(3, @LangShortName2Code);
      end;
  $04:begin  { + Accept-ranges }
        { i.e. Accept-Ranges: bytes
          Accept-ranges-value = (None | Bytes | Token-text)
          None = <Octet 128>
          Bytes = <Octet 129>
        }
        Result:= CreateShortIntOrText(4, @GetAcceptRange2Code);
      end;
  $05:begin  { + Age-value }
        Result:= Result + EncodeInteger(StrToIntDef(phdr, 0));
      end;
  $06,$22:begin  { + Allow + Public }
        { Well-known-method | Token-text
          Any well-known method or extended method in the range of 0x40-0x7F
        }
        c:= getPDUTypeCode(phdr);
        if c >= 0
        then Result:= Result + EncodeInteger(c)  // 0x40-0x7F
        else Result:= '';
      end;
  $07:begin  { Authorization i.e. : Basic realm="area"}
        { Credentials = ( Basic Basic-cookie ) | ( Authentication-scheme *Auth-param )
          Basic = <Octet 128>
          Basic-cookie = User-id Password
          User-id = Text-string
          Password = Text-string
            Note user identity and password shall not be base 64 encoded.
          Authentication-scheme = Token-text
          Auth-param = Parameter
          Challenge = ( Basic Realm-value ) | ( Authentication-scheme Realm-value *Auth-param )
          Realm-value = Text-string
            shall be encoded without the quote characters <"> in the corresponding RFC2616 Quoted-string
        }
        Result:= Result + CreateCredentials;  // ?!!
        { next opertors looks much better
        s1:= CreateCredentials;
        Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
        }
      end;
  $08,$3D,$47:begin  { + Cache-control codes $08, $3D deprecated }
        //
        p:= Pos(#32, phdr);
        if p = 0 then begin
          // control
          c:= GetCacheControl2Code(phdr);
          case c of
            -1: Result:= Result + phdr + #0;    // unknown (new) as text-token
            128..255: Result:= Result + Char(c);  // well-known cache control
          end;
        end else begin
          // cache directive
          s1:= Copy(phdr, 1, p - 1);
          s2:= Copy(phdr, p + 1, MaxInt);
          if CompareText(s1, 'No-cache') = 0 then begin
            // get just first field, skip others
            c:= GetHTTPHeaderFieldCode(s2, AVersion);
            if c >= 0
            then s1:= #128 + Char($80 or c)
            else s1:= #128 + s2 + #0;
          end else begin
            if CompareText(s1, 'Private') = 0 then begin
              // get just first field, skip others
              c:= GetHTTPHeaderFieldCode(s2, AVersion);
              if c >= 0
              then s1:= #135 + Char($80 or c)
              else s1:= #135 + s2 + #0;
            end else begin
              c:= GetCacheControl2Code(s1);
              case c of
              130, 131, 132, 139: s1:= Char(c) + EncodeInteger(StrToIntDef(s2, 0)); // delta-seconds Max-age Max-stale Min-fresh S-maxage
              else begin
                  // Cache-extension Untyped-value
                  s1:= s1 + #0 + EncodeQuotedStrValue(s2);
                end;
              end; { case }
            end;
          end;
          if Length(s1) = 0
          then Result:= ''  // impossible!
          else Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
        end;
      end;
  $09:begin  { + Connection }
        if CompareText(phdr, 'close') = 0
        then Result:= Result + #128
        else Result:= Result + phdr + #0;
      end;
  $0A:begin  { + Content-Base is deprecated }
        Result:= '';
      end;
  $0B:begin  { + Content-encoding }
        { Content-encoding-value = (Gzip | Compress | Deflate | Token-text)
          Gzip #128 Compress #129 Deflate #130
        }
        // do not Result:= CreateShortIntOrText($0B, @GetContentEncodingCode);
        c:= GetContentEncodingCode(phdr);
        if c >= 0
        then Result:= Result + Char(c)
        else Result:= '';
      end;
  $0C:begin  { + Content-language }
        { Well-known-language | Token-text }
        c:= LangShortName2Code(Copy(phdr, 1, 2));
        if c >= 0
        then Result:= Result + EncodeInteger(c)
        else Result:= Result + phdr + #0;
      end;
  $0D,$1E,$33:begin  { + Content-length Max-forwards Bearer-indication } { Integer-value }
        { Content-length used in response to HEAD }
        Result:= Result + EncodeInteger(StrToIntDef(phdr, 0));
      end;
  $0E,$1C,$24,$30,$31,$35:begin  { + Content-location Location Referer X-Wap-Content-URI X-Wap-Initiator-URI Profile }
        { Uri-value }
        Result:= Result + phdr + #0;
      end;
  $0F:begin  { + Content-MD5-value }
        // MUST be 16 octets length
        Result:= Result + EncodeLengthIndicator(Length(phdr)) + phdr;
      end;
  $10,$3E:begin  { + Content-range, code $10 deprecated }
        { Value-length Uintvar Entity-length
        Entity-length = 128(unknown) | Uintvar-integer
        Content-range: bytes 0-499/1025
        }
        L:= Length(phdr);
        p:= 0;
        while (p < L) and (not (phdr[p] in ['0'..'9'])) do Inc(p);
        c:= p;
        while (p < L) and (phdr[c] <> '/') do Inc(c);
        s1:= Copy(phdr, p, c - p + 1);
        p:= Pos('-', s1);
        if p > 0 then begin
          s2:= Copy(s1, p + 1, MaxInt);  // in this order!
          s1:= Copy(s1, 1, p - 1);
        end else begin
          s1:= phdr;
          s2:= '';
        end;
        if Length(s2) > 0 then begin
          // 0-123
          s1:= Uint2UintVar(StrToIntDef(s1, 0)) + Uint2UintVar(StrToIntDef(s2, 0));
          Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
        end else begin
          // 0-
          s1:= Uint2UintVar(StrToIntDef(s1, 0)) + #128;
          Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
        end;
      end;
  $11:begin  { + Content-type }
        p:= Pos(#32, phdr);
        if p > 0 then begin
          s1:= Copy(phdr, 1, p - 1);
          s2:= Copy(phdr, p + 1, MaxInt);
        end else begin
          s1:= phdr;
        end;
        c:= GetHTTPContentTypeCode(s1);
        if (c >= 0) and (p = 0)
        then Result:= Result + Char($80 or c)
        else begin
          if c >= 0 then begin
            // well-known content-type
            s1:= Char($80 or c);
          end else begin
            // unknown content-type
            s1:= s1 + #0;
          end;
          if Length(s2) > 0 then begin
            c:= getParameterCode(s1);
            if c >= 0
            then s2:= Char($80 or c)  // well-known parameter
            else s2:= s2 + #0
          end else s2:= '';
          Result:= Result + EncodeLengthIndicator(Length(s1) + Length(s2)) + s1 + s2;
        end;
      end;
  $12,$14,$17,$1B,$1D,$3F:begin  { + Date + Expires + If-modified-since + If-unmodified-since + X-Wap-Tod }
        try
          Result:= Result +  EncodeDateTimeValue(util_xml.ParseDate(phdr, v));
        except
          Result:= Result +  EncodeDateTimeValue(Now);
        end;
      end;
  $13,$15,$16,$18,$19,$26,$28,$29,$2B:begin
        { Etag From Host If-match If-none-match Server Upgrade User-Agent Via
          i.e. Server: CERN/3.0 libwww/2.17
               User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)
          Etag, If-match, If-none-match, Server, User-Agent, Via [RFC2616]
        }
        if (Length(phdr) >= 1) and (phdr[0] >= #128)
        then Result:= Result + '"' + phdr + #0
        else  Result:= Result + phdr + #0;
      end;
  $1A:begin  { + If-range }
        { Text-string | Date-value  [RFC2616]}
        dt:= util_xml.ParseDate(phdr, v);
        if v
        then Result:= Result + EncodeDateTimeValue(dt)
        else if (Length(phdr) >= 1) and (phdr[0] >= #128)
          then Result:= Result + '"' + phdr + #0
          else  Result:= Result + phdr + #0;
      end;
  $1F:begin  { Pragma-value of Pragma }
        { Pragma-value = No-cache | (Value-length Parameter) }
        if CompareText(phdr, 'No-cache') = 0
        then Result:= Result + #128
        else begin
          // store parameter
        end;
      end;
  $20,$21,$2D:begin  { Proxy-authenticate Proxy-authorization WWW-authenticate }
        { Proxy-authorization-value = Value-length Credentials
          Credentials = ( Basic Basic-cookie ) | ( Authentication-scheme *Auth-param )
          Basic = <Octet 128>
          Basic-cookie = User-id Password
          User-id = Text-string
          Password = Text-string
            Note user identity and password shall not be base 64 encoded.
          Authentication-scheme = Token-text
          Auth-param = Parameter
          Challenge = ( Basic Realm-value ) | ( Authentication-scheme Realm-value *Auth-param )
          Realm-value = Text-string
            shall be encoded without the quote characters <"> in the corresponding RFC2616 Quoted-string
        }
        s1:= CreateCredentials;
        Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
      end;
  $23:begin  { + Range }
        { i.e. bytes=23-  ; bytes=100-200
          Range-value = Value-Length (Byte-range-spec | Suffix-byte-range-spec)
          Byte-range-spec = Byte-range First-byte-pos [ Last-byte-Pos ]
          Suffix-byte-range-spec = Suffix-byte-range Suffix-length
          First-byte-pos = Uintvar-integer
          Last-byte-pos = Uintvar-integer
          Suffix-length = Uintvar-integer
          Byte-range = <Octet 128>
          Suffix-byte-range = <Octet 129>
        }

        L:= Length(phdr);
        p:= 0;
        while (p < L) and (not (phdr[p] in ['0'..'9'])) do Inc(p);
        c:= p;
        while (p < L) and (phdr[c] in ['-', '0'..'9']) do Inc(c);
        s1:= Copy(phdr, p, c - p + 1);
        p:= Pos('-', s1);
        if p > 0 then begin
          s2:= Copy(s1, p + 1, MaxInt);  // in this order!
          s1:= Copy(s1, 1, p - 1);
        end else begin
          s1:= phdr;
          s2:= '';
        end;
        if Length(s2) > 0 then begin
          if Length(s1) > 0
          then Result:= Result + #128 + Uint2UintVar(StrToIntDef(s1, 0)) + Uint2UintVar(StrToIntDef(s2, 0))  // 0-122
          else Result:= Result + #129 + Uint2UintVar(StrToIntDef(s2, 0));  // suffix length
        end else begin
          // 0-
          Result:= Result + #128 + Uint2UintVar(StrToIntDef(s1, 0));
        end;
      end;
  $25:begin  { + Retry-after }
        { i.e. Retry-After: Fri, 31 Dec 1999 23:59:59 GMT
               Retry-After: 120           (120 sec=2 minutes)
          Value-length (Retry-date-value | Retry-delta-seconds)
          Retry-date-value = Absolute-time Date-value
          Retry-delta-seconds = Relative-time Delta-seconds-value
          Absolute-time = <Octet 128>
          Relative-time = <Octet 129>
        }
        dt:= util_xml.ParseDate(phdr, v);
        if v then begin
          // absolute time
          Result:= Result + #128 + EncodeDateTimeValue(dt);
        end else begin
          // relative
          Result:= Result + #129 + EncodeInteger(StrToIntDef(phdr, 0));
        end;
      end;
  $27:begin  { + Transfer-encoding }
        { i.e. Transfer-Encoding: chunked
          Chunked | Token-text
          Chunked = <Octet 128>
        }
        if CompareText('chunked', phdr) = 0
        then Result:= Result + #128
        else Result:= Result + phdr + #0;
      end;
  $2A:begin  { + Vary }
        { field }
        c:= GetHTTPHeaderFieldCode(phdr, AVersion);
        if c >= 0
        then Result:= Result + Char($80 or c)
        else Result:= Result + phdr + #0;
      end;
  $2C:begin  { + Warning }
        { Warning: warn-code warn-agent warn-text [warn-date]

          Warn-code | Warning-value
          Warning-value = Value-length Warn-code Warn-agent Warn-text
          Warn-code = Short-integer
            The code values used for warning codes are specified in the Assigned Numbers appendix
          Warn-agent = Text-string
            The value shall be encoded as per [RFC2616]
          Warn-text = Text-string
        }
        Result:= Result + CreateWarn;
      end;
  $2E,$45:begin  { + Content-disposition, code $2E deprecated }
        {  i.e. Content-Disposition: attachment; filename="fname.ext"
           Value-length Disposition *(Parameter)
           Disposition = Form-data | Attachment | Inline | Token-text
           Form-data = <Octet 128>
           Attachment = <Octet 129>
           Inline = <Octet 130>
        }
        ExtractHeaderExtFields(PChar(AHeaderString), pars, ext);
        if pars.Count = 0 then begin
          Result:= '';
          Exit;
        end;

        // disposition code or token-text
        c:= GetContentDisposition2Code(pars[0]);
        if c >= 0
        then s1:= Char(c)
        else s1:= pars[0] + #0;

        // *(Parameter), text
        for i:= 0 to ext.Count - 1 do begin
          c:= getParameterCode(ext.Names[i]);
          if c >= 0
          then s1:= s1 + Char($80 or c)
          else s1:= s1 + ext.Names[i] + #0;
          s1:= s1 + ext.Values[ext.Names[i]] + #0;
        end;
        Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
      end;
  $2F:begin  { + Application-id }
        { Uri-value | App-assigned-code
          App-assigned-code = Integer-value
          Uri-value=Text-string
        }
        c:= StrToIntDef(phdr, -1);
        if c = -1
        then Result:= Result + phdr + #0
        else Result:= Result + EncodeInteger(c);
      end;
  $32:begin  { + Accept-application }
        { Accept-application-value = Any-application | Application-id-value
          lists of Application Id values encoded using multiple Accept-application headers
          Any-application = <Octet 128> ; encoding for "*"
          Application-id-value = Uri-value | App-assigned-code
          App-assigned-code = Integer-value
        }
        if CompareText(phdr, '*') = 0
        then Result:= Result + #128
        else begin
          c:= StrToIntDef(phdr, -1);
          if c = -1
          then Result:= Result + phdr + #0
          else Result:= Result + EncodeInteger(c);
        end;
      end;
  $34:begin  { Push-flag }
        { RFC 2616 havent push-flag }
        c:= StrToIntDef(phdr, -1);
        if c = -1
        then Result:= ''
        else Result:= Result + Char(c or $80);
      end;
  $36:begin  { Profile-diff }
        { RFC 2616 havent Profile-diff
          Uri-value
        }
        Result:= Result + phdr + #0;
      end;
  $37,$44:begin  { + Profile-warning, code $37 deprecated }
        { RFC 2616 havent Profile-warning
          Warn-code | (Value-length Warn-code Warn-target *Warn-date)
          Warn-code = Short-integer
            assigned value Warning code (see [CCPPEx])
            0x10 100; 0x11 101; 0x12 102; 0x20 200; 0x21 201; 0x22 202; 0x23 203
          Warn-target = Uri-value | host [ “ :” port ]
          Warn-date = Date-value
        }
        Result:= Result + CreateWarnProfile;
      end;
  $38:begin  { + Expect }
        { 100-continue | Expect-expression
          Expect-expression = Value-length Expression-var Expression-Value
          Expression-var = Token-text
          Expression-value = (Token-text | Quoted-string) *Expect-params
          Expect-params = Token-text Expect-param-value
          Expect-param-value = Token-text | Quoted-string
          100-continue = <Octet 128>
        }
        if CompareText(phdr, '100-continue') = 0 then begin
          Result:= Result + #128;
          Exit;
        end;
        ExtractHeaderExtFields(PChar(AHeaderString), pars, ext);
        if pars.Count = 0 then begin
          Result:= '';
          Exit;
        end;

        // var&value
        s1:= pars.Names[0] + #0 + pars.Values[pars.Names[0]] + #0;

        // *(Parameter), text
        for i:= 0 to ext.Count - 1 do begin
          c:= getParameterCode(ext.Names[i]);
          if c >= 0
          then s1:= s1 + Char($80 or c)
          else s1:= s1 + ext.Names[i] + #0;
          s1:= s1 + ext.Values[ext.Names[i]] + #0;
        end;
        Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
      end;
  $39:begin  { + TE }
        { i.e. TE: trailers, deflate;q=0.5
          Trailers | TE-General-Form
          TE-General-Form = Value-length (Well-known-TE | Token-text) [Q-Parameter]
          Q-Parameter = Q-token Q-value
          Well-known-TE = (Chunked | Identity | Gzip | Compress | Deflate)
          Q-token = #128 Trailers = #129 Chunked = #130 Identity = #131 Gzip = #132 Compress = #133 Deflate = #134
        }
        { Value-length (Well-known-TE | Token-text) [Q-Parameter] }
        Result:= CreateQList($39, GetTE2Code);
      end;
  $3A:begin  { + Trailer }
        { Trailer-value = (Well-known-header-field | Token-text)
          Well-known-header-field = Integer-value
            Encoded using values from Header Field Name Assignments table in Assigned Numbers
        }
        c:= GetHTTPHeaderFieldCode(phdr, AVersion);
        if c >= 0
        then Result:= Result + Char($80 or c)
        else Result:= Result + phdr + #0;
      end;
  $40:begin  { + Content-ID }
        Result:= Result + EncodeQuotedStrValue(phdr);
      end;
  $41:begin  { + Set-Cookie }
        { i.e name=value; path=/
          Bug: I dont know about cookie version
          Value-length Cookie-version Cookie-name Cookie-val *Parameter
          Cookie-version = Version-value
          Cookie-name = Text-string
          Cookie-val = Text-string
        }
        ExtractHeaderExtFields(PChar(AHeaderString), pars, ext);
        if pars.Count = 0 then begin
          Result:= '';
          Exit;
        end;

        // var&value
        SetLength(versionarray, 2);
        versionarray[0]:= 1;
        versionarray[1]:= 0;
        s1:= EncodeVersionValue(versionarray) + pars.Names[0] + #0 + pars.Values[pars.Names[0]] + #0;
        SetLength(versionarray, 0);

        // *(Parameter), text
        for i:= 0 to ext.Count - 1 do begin
          c:= getParameterCode(ext.Names[i]);
          if c >= 0
          then s1:= s1 + Char($80 or c)
          else s1:= s1 + ext.Names[i] + #0;
          s1:= s1 + ext.Values[ext.Names[i]] + #0;
        end;
        Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
      end;
  $42:begin  { + Cookie }
        { Value-length Cookie-version *Cookie
          Cookie = Cookie-length Cookie-name Cookie-val [Cookie-parameters]
          Cookie-length = Uintvar-integer
          Cookie-parameters = Path [Domain]
          Path = Text-string
            if path is an empty string, it indicates that there is no path value present
          Domain = Text-string
        }
        ExtractHeaderExtFields(PChar(AHeaderString), pars, ext);
        if pars.Count = 0 then begin
          Result:= '';
          Exit;
        end;
        // cookie version
        SetLength(versionarray, 2);
        versionarray[0]:= 1;
        versionarray[1]:= 0;
        s1:= EncodeVersionValue(versionarray);
        SetLength(versionarray, 0);
        // cookies
        for i:= 0 to pars.Count - 1 do begin
          // cookie
          s1:= pars.Names[0] + #0 + pars.Values[pars.Names[0]] + #0;
          // parameters path, domain
          s2:= GetHeaderExt(i, 'path', pars, ext);
          if Length(s2) > 0 then begin
            s1:= s1 + s2 + #0;
            s2:= GetHeaderExt(i, 'domain', pars, ext);
            if Length(s2) > 0 then begin
              s1:= s1 + s2 + #0;
            end;
          end;
          s1:= EncodeLengthIndicator(Length(s1)) + s1;
        end;
        Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
      end;
  $43:begin  { Encoding-Version }
        { my text representation: 1.2; code-page=1 }
        { Version-value | Value-length Code-page [Version-value]
            encoded using values from tables in the Assigned Numbers Appendix or from an extended header code page.
          Code-page = Short-integer
            Identity of the extended header code page which the encoding applies for. If the
            Code-page is omitted, the version value refers to the header code pages reserved for headers specified by WAP Forum
        }
        ExtractHeaderExtFields(PChar(AHeaderString), pars, ext);
        if pars.Count = 0 then begin
          Result:= '';
          Exit;
        end;
        p:= 1;
        versionarray:= VersionText2Array(pars[0], p);
        // bug, version can be omitted (code-page only)
        if Length(versionarray) = 0 then begin
          Result:= '';
          Exit;
        end;

        s1:= EncodeVersionValue(versionarray);
        s2:= GetHeaderExt(0, 'code-page', pars, ext);
        if Length(s2) > 0 then begin
          s1:= Char($80 or (StrToIntDef(s2, 0))) + s1;
          Result:= Result + EncodeLengthIndicator(Length(s1)) + s1;
        end else begin
          Result:= Result + s1;
        end;
      end;
  $46:begin  { X-WAP-Security }
        { Close-subordinate = #128
        }
        Result:= Result + #128;
      end;
  end; { case }
  ext.Free;
  pars.Free;
end;

function EncodeHeadersValue(AHeaders: TStrings; const AVersion: String = DEFAULT_WMLC_ENCODING_VERSION): String;
var
  i: Integer;
begin
  Result:= '';
  for i:= 0 to AHeaders.Count - 1 do begin
    Result:= Result + EncodeHeaderValue(AHeaders[i], AVersion);
  end;
end;

{  DecodeHeaderValue0 decode null-terminated pchar header value
   Parameters:
     AHeaderFldNo       Field number (in any code page)
     AFldCodedValue     coded value (with last #0 char)
     ANextPos           start position in AFldCodedValue string
     ALast              last position in AFldCodedValue string (length of string)
   Return:
     Result             header field value
     AResultFldName     header field name
     ANextPos           next position in string to parse
   Note: does not matter what code page is
}
function DecodeHeaderValue0(const AHeaderFldNo: Byte; const AFldCodedValue: String;
  ALast: Integer; var ANextPos: Integer): String;
var
  L, st: Integer;
  nullfound: Boolean;
begin
  // skip last null terminator
  nullfound:= False;
  st:= ANextPos; // remember start position
  while (ANextPos <= ALast) do begin
    // check last #0
    if AFldCodedValue[ANextPos] = #0 then begin
      nullfound:= True;
      Break;
    end;
    Inc(ANextPos);
  end;
  Inc(ANextPos);
  L:= ANextPos - st;
  if nullfound
  then Dec(L);
  // check is text is '"'
  if (L > 0) and (AFldCodedValue[st] = '"') then begin
    Inc(st);
    Dec(L);
  end;
  Result:= Copy(AFldCodedValue, st, L);
end;

{  DecodeHeaderValue1 decode short-integer or multi-byte integer header value
   Parameters:
     AHeaderFldNo       Field number in code page 1
     AFldValueCode      header field value
   Return:
     Result             header field value
     AResultFldName     header field name
   Limitations:
     Multibyte integer is limited by 4 octets, not 30
     code page must be 1 (default)
}
function DecodeHeaderValue1(const AHeaderFldNo: Byte; const AFldValueCode: Cardinal): String;
begin
  case AHeaderFldNo of
  $00:begin  { Accept }
        Result:= getHTTPContentTypeName(AFldValueCode);
      end;
  $01,$3B:begin  { * Accept-charset, code 1 deprecated }
        { i.e Accept-Charset: iso-8859-5, unicode-1-1;q=0.8 }
        Result:= CharSetCode2Name(AFldValueCode);
      end;
  $02,$3C:begin  { * Accept-encoding, code 2 deprecated }
        { Accept-encoding-value = Content-encoding-value | Accept-encoding-general-form
          Content-encoding-value = (Gzip | Compress | Deflate | Token-text)
          Gzip = <Octet 128>
          Compress = <Octet 129>
          Deflate = <Octet 130>
          Any-encoding = <Octet 131>
        }
        Result:= GetContentEncodingName(AFldValueCode);
      end;
  $03:begin  { * Accept-language }
        { i.e Accept-Language: da, en-gb;q=0.8, en;q=0.7
          Accept-language-value = Constrained-language | Accept-language-general-form
          Constrained-language = Any-language | Constrained-encoding
        }
        Result:= LangCode2ShortName(AFldValueCode);
      end;
  $04:begin  { + Accept-ranges }
        { i.e. Accept-Ranges: bytes
          Accept-ranges-value = (None | Bytes | Token-text)
          None = <Octet 128>
          Bytes = <Octet 129>
        }
        Result:= GetAcceptRange2Name(AFldValueCode);  // do not 'and $7F'
      end;
  $05:begin  { + Age-value, short-integer }
        Result:= IntToStr(AFldValueCode);
      end;
  $06,$22:begin  { + Allow + Public }
        { Well-known-method | Token-text
          Any well-known method or extended method in the range of 0x40-0x7F
        }
        Result:= getPDUTypeName(AFldValueCode);
      end;
  $07:begin  { Authorization i.e. : Basic realm="area"}
        { Credentials = ( Basic Basic-cookie ) | ( Authentication-scheme *Auth-param )
          Basic = <Octet 128>
          Basic-cookie = User-id Password
          User-id = Text-string
          Password = Text-string
            Note user identity and password shall not be base 64 encoded.
          Authentication-scheme = Token-text
          Auth-param = Parameter
          Challenge = ( Basic Realm-value ) | ( Authentication-scheme Realm-value *Auth-param )
          Realm-value = Text-string
            shall be encoded without the quote characters <"> in the corresponding RFC2616 Quoted-string
        }
        // is not complete and invalid
        if AFldValueCode = 0
        then Result:= 'Basic';
      end;
  $08,$3D,$47:begin  { + Cache-control codes $08, $3D deprecated }
        { just in case }
        Result:= GetCacheControl2Name(AFldValueCode);
      end;
  $09:begin  { + Connection }
        if AFldValueCode = 0
        then Result:= 'close';
      end;
  $0A:begin  { + Content-Base is deprecated }
      end;
  $0B:begin  { + Content-encoding }
        { Content-encoding-value = (Gzip | Compress | Deflate | Token-text)
          Gzip #128 Compress #129 Deflate #130
        }
        Result:= GetContentEncodingName(AFldValueCode);
      end;
  $0C:begin  { + Content-language }
        { Well-known-language | Token-text }
        Result:= LangCode2ShortName(AFldValueCode);
      end;
  $0D,$1E,$33:begin  { + Content-length Max-forwards Bearer-indication } { Integer-value }
        { Content-length used in response to HEAD }
        Result:= IntToStr(AFldValueCode);
      end;
  $0E,$1C,$24,$30,$31,$35:begin  { + Content-location Location Referer X-Wap-Content-URI X-Wap-Initiator-URI Profile }
        { Uri value cannot coded by short or multibyte integer }
      end;
  $0F:begin  { + Content-MD5-value }
        { Content-MD5 value cannot coded by short or multibyte integer }
      end;
  $10,$3E:begin  { + Content-range, code $10 deprecated }
        { Content-range value cannot coded by short or multibyte integer }
      end;
  $11:begin  { + Content-type }
        Result:= getHTTPContentTypeName(AFldValueCode);
      end;
  $12,$14,$17,$1B,$1D,$3F:begin  { + Date + Expires + If-modified-since + If-unmodified-since + X-Wap-Tod }
        { date value coded by short or multibyte integer }
        Result:= GetDateTimeStamp(UnixDateDelta + (AFldValueCode / SecsPerDay));
      end;
  $13,$15,$16,$18,$19,$26,$28,$29,$2B:begin
        { Etag From Host If-match If-none-match Server Upgrade User-Agent Via
            i.e. 'Server: CERN/3.0 libwww/2.17' or 'User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'
          cannot coded by short or multibyte integer }
      end;
  $1A:begin  { + If-range }
        { Text-string | Date-value  [RFC2616]}
        { date value coded by multibyte integer, others cannot coded by short or multibyte integer }
        Result:= GetDateTimeStamp(UnixDateDelta + (AFldValueCode / SecsPerDay));
      end;
  $1F:begin  { Pragma-value of Pragma }
        { Pragma-value = No-cache | (Value-length Parameter) }
        if AFldValueCode = 0
        then Result:= 'No-cache';
      end;
  $20,$21,$2D:begin  { Proxy-authenticate Proxy-authorization WWW-authenticate }
        { Proxy-authorization-value = Value-length Credentials
          Credentials = ( Basic Basic-cookie ) | ( Authentication-scheme *Auth-param )
          Basic = <Octet 128>
          Basic-cookie = User-id Password
          User-id = Text-string
          Password = Text-string
            Note user identity and password shall not be base 64 encoded.
          Authentication-scheme = Token-text
          Auth-param = Parameter
          Challenge = ( Basic Realm-value ) | ( Authentication-scheme Realm-value *Auth-param )
          Realm-value = Text-string
            shall be encoded without the quote characters <"> in the corresponding RFC2616 Quoted-string
          value cannot coded by short or multibyte integer }
        if AFldValueCode = 0
        then Result:= 'Basic';  // this is wrong, incomplete and invalid
      end;
  $23:begin  { + Range }
        { i.e. bytes=23-  ; bytes=100-200
          Range-value = Value-Length (Byte-range-spec | Suffix-byte-range-spec)
          Byte-range-spec = Byte-range First-byte-pos [ Last-byte-Pos ]
          Suffix-byte-range-spec = Suffix-byte-range Suffix-length
          First-byte-pos = Uintvar-integer
          Last-byte-pos = Uintvar-integer
          Suffix-length = Uintvar-integer
          Byte-range = <Octet 128>
          Suffix-byte-range = <Octet 129>
          value cannot coded by short or multibyte integer }
      end;
  $25:begin  { + Retry-after }
        { i.e. Retry-After: Fri, 31 Dec 1999 23:59:59 GMT
               Retry-After: 120           (120 sec=2 minutes)
          Value-length (Retry-date-value | Retry-delta-seconds)
          Retry-date-value = Absolute-time Date-value
          Retry-delta-seconds = Relative-time Delta-seconds-value
          Absolute-time = <Octet 128>
          Relative-time = <Octet 129>
          value cannot coded by short or multibyte integer }
        { date value coded by multibyte integer, others cannot coded by short or multibyte integer }
        Result:= GetDateTimeStamp(UnixDateDelta + (AFldValueCode / SecsPerDay));
      end;
  $27:begin  { + Transfer-encoding }
        { i.e. Transfer-Encoding: chunked
          Chunked | Token-text
          Chunked = <Octet 128>
        }
        if AFldValueCode = 0
        then Result:= 'chunked';
      end;
  $2A:begin  { + Vary }
        { field }
        Result:= getHTTPHeaderFieldName(AFldValueCode);
      end;
  $2C:begin  { + Warning }
        { Warning: warn-code warn-agent warn-text [warn-date]
          Warn-code | Warning-value
          Warning-value = Value-length Warn-code Warn-agent Warn-text
          Warn-code = Short-integer
            The code values used for warning codes are specified in the Assigned Numbers appendix
          Warn-agent = Text-string
            The value shall be encoded as per [RFC2616]
          Warn-text = Text-string
        }
        Result:= IntToStr(GetWarningCode2Val(AFldValueCode));
      end;
  $2E,$45:begin  { + Content-disposition, code $2E deprecated }
        {  i.e. Content-Disposition: attachment; filename="fname.ext"
           Value-length Disposition *(Parameter)
           Disposition = Form-data | Attachment | Inline | Token-text
           Form-data = <Octet 128>
           Attachment = <Octet 129>
           Inline = <Octet 130>
           value cannot coded by short or multibyte integer }
      end;
  $2F:begin  { + Application-id }
        { Uri-value | App-assigned-code
          App-assigned-code = Integer-value
          Uri-value=Text-string
        }
        Result:= IntToStr(AFldValueCode);  // short-integer case
      end;
  $32:begin  { + Accept-application }
        { Accept-application-value = Any-application | Application-id-value
          lists of Application Id values encoded using multiple Accept-application headers
          Any-application = <Octet 128> ; encoding for "*"
          Application-id-value = Uri-value | App-assigned-code
          App-assigned-code = Integer-value
        }
        if AFldValueCode = 0
        then Result:= '*'  // any application
        else Result:= IntToStr(AFldValueCode);  // short-integer case
      end;
  $34:begin  { Push-flag }
        { RFC 2616 havent push-flag }
        Result:= IntToStr(AFldValueCode);  // short-integer case
      end;
  $36:begin  { Profile-diff }
        { RFC 2616 havent Profile-diff
          Uri-value
          value cannot coded by short or multibyte integer }
      end;
  $37,$44:begin  { + Profile-warning, code $37 deprecated }
        { RFC 2616 havent Profile-warning
          Warn-code | (Value-length Warn-code Warn-target *Warn-date)
          Warn-code = Short-integer
            assigned value Warning code (see [CCPPEx])
            0x10 100; 0x11 101; 0x12 102; 0x20 200; 0x21 201; 0x22 202; 0x23 203
          Warn-target = Uri-value | host [ “ :” port ]
          Warn-date = Date-value
        }
        Result:= IntToStr(GetProfileWarning2Val(AFldValueCode));
      end;
  $38:begin  { + Expect }
        { 100-continue | Expect-expression
          Expect-expression = Value-length Expression-var Expression-Value
          Expression-var = Token-text
          Expression-value = (Token-text | Quoted-string) *Expect-params
          Expect-params = Token-text Expect-param-value
          Expect-param-value = Token-text | Quoted-string
          100-continue = <Octet 128>
        }
        if AFldValueCode = 0
        then Result:= '100-continue';
      end;
  $39:begin  { + TE }
        { i.e. TE: trailers, deflate;q=0.5
          Trailers | TE-General-Form
          Trailers = #129
        }
        if AFldValueCode = 1
        then Result:= 'trailers';
      end;
  $3A:begin  { + Trailer }
        { Trailer-value = (Well-known-header-field | Token-text)
          Well-known-header-field = Integer-value
            Encoded using values from Header Field Name Assignments table in Assigned Numbers
        }
        Result:= getHTTPHeaderFieldName(AFldValueCode);
      end;
  $40:begin  { + Content-ID }
        { value cannot coded by short or multibyte integer }
      end;
  $41:begin  { + Set-Cookie }
        { i.e name=value; path=/
          Bug: I dont know about cookie version
          Value-length Cookie-version Cookie-name Cookie-val *Parameter
          Cookie-version = Version-value
          Cookie-name = Text-string
          Cookie-val = Text-string
          value cannot coded by short or multibyte integer }
      end;
  $42:begin  { + Cookie }
        { Value-length Cookie-version *Cookie
          Cookie = Cookie-length Cookie-name Cookie-val [Cookie-parameters]
          Cookie-length = Uintvar-integer
          Cookie-parameters = Path [Domain]
          Path = Text-string
            if path is an empty string, it indicates that there is no path value present
          Domain = Text-string
          value cannot coded by short or multibyte integer }
      end;
  $43:begin  { Encoding-Version }
        { my text representation: 1.2; code-page=1 }
        { Version-value | Value-length Code-page [Version-value]
            encoded using values from tables in the Assigned Numbers Appendix or from an extended header code page.
          Code-page = Short-integer
            Identity of the extended header code page which the encoding applies for. If the
            Code-page is omitted, the version value refers to the header code pages reserved for headers specified by WAP Forum
        }
        Result:= EncodeVersionValue(DecodeVersionValueAsShortInt(AFldValueCode));
      end;
  $46:begin  { X-WAP-Security }
        { Close-subordinate = #128 }
        if AFldValueCode = 0
        then Result:= 'Close-subordinate';
      end;
  end; { case }
end;

{ get code or text from coded
  Parameters
    AStr
    AFr
  AGetNameByCode: TGetNameByCode
  Return
    ANextPos
    ACode       code of name coded in AStr as short integer or multibyte integer
      -1        no code specified, used text
}
// TGetNameByCode = function (ACode: Byte): String;
function GetCodeOrText(AStr: String; var ANextPos: Integer; var ACode: Integer;
  AGetNameByCode: TGetNameByCode): String;
var
  i, L: Integer;
begin
  Result:= '';
  ACode:= -1;
  L:= Length(AStr);
  if ANextPos > L
  then Exit;
  case AStr[ANextPos] of
    #128..#255: begin
      // well-known coded as short integer
      ACode:= DecodeIntegerL(AStr, ANextPos);
      if Assigned (AGetNameByCode)
      then Result:= AGetNameByCode(ACode);
    end;
    #0..#30: begin
      // short-length, follows 0..30 multi-octet integer
      Result:= Copy(AStr, ANextPos + 1, Byte(AStr[ANextPos]));
      ANextPos:= ANextPos + Byte(AStr[ANextPos]) + 1;
      ACode:= DecodeInteger(Result);
      if Assigned (AGetNameByCode)
      then Result:= AGetNameByCode(ACode);
    end;
    #31: begin
      // Field value coded as uintvar octets
      i:= UIntVar2UintL(AStr, ANextPos);
      Result:= Copy(AStr, ANextPos, i);
      Inc(ANextPos, i);
    end;
    else begin
      // coded as text
      i:= ANextPos;  // remember
      while ANextPos <= L do begin
        if AStr[ANextPos] = #0
        then Break;
        Inc(ANextPos);
      end;
      if AStr[i] = '"'
      then Inc(i);
      Result:= Copy(AStr, i, ANextPos - i);
      Inc(ANextPos);
    end; { else }
  end; { case }
end;

function DecodeHeaderValueGeneral(const AHeaderFldNo: Byte; const AFldValue: String): String;
var
  i, c, code, L, p, len: Integer;
  s1: String;
  dt: TDateTime;
begin
  Result:= '';
  L:= Length(AFldValue);
  if L = 0
  then Exit;
  p:= 1;
  case AHeaderFldNo of
  $00:begin  { Accept }
        { Accept-general-form = Value-length Media-range [Accept-parameters]
          Media-range = (Well-known-media | Extension-Media) *(Parameter)
          Accept-parameters = Q-token Q-value *(Accept-extension)
          Accept-extension = Parameter
          Constrained-media = Constrained-encoding
          Well-known-media = Integer-value
            Both are encoded using values from Content Type Assignments table in Assigned Numbers
          Q-token = <Octet 128>
        }
        // Media-range
        Result:= GetCodeOrText(AFldValue, p, code, getHTTPContentTypeName);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $01,$3B:begin  { * Accept-charset, code 1 deprecated }
        { i.e Accept-Charset: iso-8859-5, unicode-1-1;q=0.8
          Value-length (Well-known-charset | Token-text) [Q-value]
          Constrained-charset = Any-charset | Constrained-encoding
          Well-known-charset = Any-charset | Integer-value
          Any-charset = <Octet 128>
        }
        Result:= GetCodeOrText(AFldValue, p, code, CharSetCode2Name);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $02,$3C:begin  { * Accept-encoding, code 2 deprecated }
        { Value-length ( Content-encoding-value | Any-encoding ) [Q-value]
          Content-encoding-value = (Gzip | Compress | Deflate | Token-text)
          Gzip = <Octet 128>
          Compress = <Octet 129>
          Deflate = <Octet 130>
          Any-encoding = <Octet 131>
        }
        Result:= GetCodeOrText(AFldValue, p, code, GetContentEncodingName);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $03:begin  { * Accept-language }
        { i.e Accept-Language: da, en-gb;q=0.8, en;q=0.7
          Accept-language-value = Constrained-language | Accept-language-general-form
          Accept-language-general-form = Value-length (Well-known-language | Text-string) [Q-value]
          Constrained-language = Any-language | Constrained-encoding
          Well-known-language = Any-language | Integer-value
          Both are encoded using values from Character Set Assignments table in Assigned Numbers
        }
        Result:= GetCodeOrText(AFldValue, p, code, LangCode2ShortName);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $04:begin  { + Accept-ranges }
        { i.e. Accept-Ranges: bytes
          Accept-ranges-value = (None | Bytes | Token-text)
          None = <Octet 128>
          Bytes = <Octet 129>
        }
        { this field has no general form. Just in case }
        Result:= GetCodeOrText(AFldValue, p, code, GetAcceptRange2Name);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $05:begin  { + Age-value, short-integer }
        { this field has no general form }
      end;
  $06,$22:begin  { + Allow + Public }
        { Well-known-method | Token-text
          Any well-known method or extended method in the range of 0x40-0x7F }
        { this field has no general form. Just in case }
        Result:= GetCodeOrText(AFldValue, p, code, getPDUTypeName);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $07:begin  { Authorization i.e. : Basic realm="area"}
        { Credentials = ( Basic Basic-cookie ) | ( Authentication-scheme *Auth-param )
          Basic = <Octet 128>
          Basic-cookie = User-id Password
          User-id = Text-string
          Password = Text-string
            Note user identity and password shall not be base 64 encoded.
          Authentication-scheme = Token-text
          Auth-param = Parameter
          Challenge = ( Basic Realm-value ) | ( Authentication-scheme Realm-value *Auth-param )
          Realm-value = Text-string
            shall be encoded without the quote characters <"> in the corresponding RFC2616 Quoted-string
        }
        if AFldValue[1] = #128 then begin
          // basic, get user-id
          p:= 2;
          Result:= 'Basic ' + GetCodeOrText(AFldValue, p, code, Nil) + #32;
          // get password
          Result:= Result + GetCodeOrText(AFldValue, p, code, Nil);
        end else begin
          // authentification scheme
          Result:= GetCodeOrText(AFldValue, p, code, Nil) + #32;
          // get realm
          Result:= Result + GetCodeOrText(AFldValue, p, code, Nil) + #32;
          // get *Auth-param if exists
          Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
        end;
      end;
  $08,$3D,$47:begin  { + Cache-control codes $08, $3D deprecated }
        { Value-length Cache-directive
          Cache-directive = No-cache 1*(Field-name) |
          Max-age Delta-second-value |
          Max-stale Delta-second-value |
          Min-fresh Delta-second-value |
          Private 1*(Field-name) |
          S-maxage Delta-second-value |
          Cache-extension Untyped-value
        }
        Result:= GetCacheControl2Name(Byte(AFldValue[1]));
        case Byte(AFldValue[1]) of
        130, 131, 132, 139: begin// delta-seconds Max-age Max-stale Min-fresh S-maxage
          p:= 2;
          Result:= Result + IntToStr(DecodeIntegerL(AFldValue, p));
        end else begin
          // Cache-extension Untyped-value
          Result:= Result + GetCodeOrText(AFldValue, p, code, Nil) + #32;
          // get field name if exists
          Result:= Result + GetCodeOrText(AFldValue, p, code, Nil);
          end;
        end; { case }
      end;
  $09:begin  { + Connection }
        { this field has no general form }
      end;
  $0A:begin  { + Content-Base is deprecated }
      end;
  $0B:begin  { + Content-encoding }
        { Content-encoding-value = (Gzip | Compress | Deflate | Token-text)
          Gzip #128 Compress #129 Deflate #130 }
        { this field has no general form. Just in case  }
        Result:= GetCodeOrText(AFldValue, p, code, GetContentEncodingName);
      end;
  $0C:begin  { + Content-language }
        { Well-known-language | Token-text }
        { this field has no general form. Just in case  }
        Result:= GetCodeOrText(AFldValue, p, code, LangCode2ShortName);
      end;
  $0D,$1E,$33:begin  { + Content-length Max-forwards Bearer-indication } { Integer-value }
        { Content-length used in response to HEAD }
        { this field has no general form }
      end;
  $0E,$1C,$24,$30,$31,$35:begin  { + Content-location Location Referer X-Wap-Content-URI X-Wap-Initiator-URI Profile }
        { this field has no general form }
      end;
  $0F:begin  { + Content-MD5-value }
        { Content-MD5 value Content-MD5-value = Value-length Digest
          128-bit MD5 digest as per [RFC1864]. Note the digest shall not be base-64 encoded.
          Digest = 16*16 OCTET
        }
        Result:= AFldValue;
      end;
  $10,$3E:begin  { + Content-range, code $10 deprecated }
        { i.e. Content-range: bytes 0-499/1025
          Value-length First-byte-pos Entity-length
          First-byte-pos = Uintvar-integer
          Entity-length = Unknown-length | Uintvar-integer
          Unknown-length = <Octet 128> }
        c:= UIntVar2UintL(AFldValue, p);
        if (p <= L) and (AFldValue[p] = #128)
        then Result:= Format('bytes %d-*', [c])
        else begin
          i:= UIntVar2UintL(AFldValue, p);
          Result:= Format('bytes %d-%d', [c, i]);
        end;
      end;
  $11:begin  { + Content-type }
        { Value-length Media-type
          Media-type = (Well-known-media | Extension-Media) *(Parameter) }
        Result:= GetCodeOrText(AFldValue, p, code, getHTTPContentTypeName);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $12,$14,$17,$1B,$1D,$3F:begin  { + Date + Expires + If-modified-since + If-unmodified-since + X-Wap-Tod }
        { this field has no general form }
      end;
  $13,$15,$16,$18,$19,$26,$28,$29,$2B:begin
        { Etag From Host If-match If-none-match Server Upgrade User-Agent Via
            i.e. 'Server: CERN/3.0 libwww/2.17' or 'User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)' }
        { this field has no general form }
      end;
  $1A:begin  { + If-range }
        { Text-string | Date-value  [RFC2616]}
        { this field has no general form }
      end;
  $1F:begin  { Pragma }
        { Pragma-value = No-cache | (Value-length Parameter) }
        if AFldValue[1] = #128
        then Result:= 'No-cache'
        else Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $20,$21,$2D:begin  { Proxy-authenticate Proxy-authorization WWW-authenticate }
        { Proxy-authorization-value = Value-length Credentials
          Credentials = ( Basic Basic-cookie ) | ( Authentication-scheme *Auth-param )
          Basic = <Octet 128>
          Basic-cookie = User-id Password
          User-id = Text-string
          Password = Text-string
            Note user identity and password shall not be base 64 encoded.
          Authentication-scheme = Token-text
          Auth-param = Parameter
          Challenge = ( Basic Realm-value ) | ( Authentication-scheme Realm-value *Auth-param )
          Realm-value = Text-string
            shall be encoded without the quote characters <"> in the corresponding RFC2616 Quoted-string
        }
        if AFldValue[1] = #128 then begin
          // basic, get user-id
          p:= 2;
          Result:= 'Basic ' + GetCodeOrText(AFldValue, p, code, Nil) + #32;
          // get password
          Result:= Result + GetCodeOrText(AFldValue, p, code, Nil);
        end else begin
          // authentification scheme
          Result:= GetCodeOrText(AFldValue, p, code, Nil) + #32;
          // get realm
          Result:= Result + GetCodeOrText(AFldValue, p, code, Nil);
          // get *Auth-param if exists
          Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
        end;
      end;
  $23:begin  { + Range }
        { i.e. bytes=23-  ; bytes=100-200
          Range-value = Value-Length (Byte-range-spec | Suffix-byte-range-spec)
          Byte-range-spec = Byte-range First-byte-pos [ Last-byte-Pos ]
          Suffix-byte-range-spec = Suffix-byte-range Suffix-length
          First-byte-pos = Uintvar-integer
          Last-byte-pos = Uintvar-integer
          Suffix-length = Uintvar-integer
          Byte-range = <Octet 128>
          Suffix-byte-range = <Octet 129>
        }
        case AFldValue[1] of
        #128:begin
            // byte-range
            c:= UIntVar2UintL(AFldValue, p);
            i:= UIntVar2UintL(AFldValue ,p);
            Result:= Format('bytes %d-%d', [c, i]);
          end;
        #129:begin
            // suffix byte-range
            c:= UIntVar2UintL(AFldValue, p);
            Result:= Format('bytes %d-', [c]);
          end;
        else begin
          end;
        end; { case }
      end;
  $25:begin  { + Retry-after }
        { i.e. Retry-After: Fri, 31 Dec 1999 23:59:59 GMT
               Retry-After: 120           (120 sec=2 minutes)
          Value-length (Retry-date-value | Retry-delta-seconds)
          Retry-date-value = Absolute-time Date-value
          Retry-delta-seconds = Relative-time Delta-seconds-value
          Absolute-time = <Octet 128>
          Relative-time = <Octet 129>
          value cannot coded by one octet }
        case AFldValue[1] of
        #128:begin
            // absolute time
            dt:= DecodeDateTimeValueL(AFldValue, p);
            Result:= GetDateTimeStamp(dt);
          end;
        #129:begin
            // relative time
            Result:= IntToStr(DecodeIntegerL(AFldValue, p));
          end;
        else begin
          end;
        end; { case }
      end;
  $27:begin  { + Transfer-encoding }
        { i.e. Transfer-Encoding: chunked
          Chunked | Token-text
          Chunked = <Octet 128> }
        { this field has no general form }
      end;
  $2A:begin  { + Vary }
        { field }
        { this field has no general form. Just in case }
        Result:= GetCodeOrText(AFldValue, p, code, getHTTPHeaderFieldName);
      end;
  $2C:begin  { + Warning }
        { Warning: warn-code warn-agent warn-text [warn-date]
          Warn-code | Warning-value
          Warning-value = Value-length Warn-code Warn-agent Warn-text
          Warn-code = Short-integer
            The code values used for warning codes are specified in the Assigned Numbers appendix
          Warn-agent = Text-string
            The value shall be encoded as per [RFC2616]
          Warn-text = Text-string
        }
        c:= GetWarningCode2Val(Byte(AFldValue[1]) and $7F);
        Result:= IntToStr(c) + #32;
        // get warn-agent
        p:= 2;
        Result:= Result + GetCodeOrText(AFldValue, p, code, Nil) + #32;
        // get warn-text
        Result:= Result + GetCodeOrText(AFldValue, p, code, Nil) + #32;
        // get warn-date if exists
        if p < L then begin
          dt:= DecodeDateTimeValueL(AFldValue, p);
          Result:= Result + GetDateTimeStamp(dt);
        end;
      end;
  $2E,$45:begin  { + Content-disposition, code $2E deprecated }
        { i.e. Content-Disposition: attachment; filename="fname.ext"
          Value-length Disposition *(Parameter)
          Disposition = Form-data | Attachment | Inline | Token-text
          Form-data = <Octet 128>
          Attachment = <Octet 129>
          Inline = <Octet 130> }
        p:= 2;
        Result:= GetCodeOrText(AFldValue, p, code, GetContentDisposition2Name);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $2F:begin  { + Application-id }
        { Uri-value | App-assigned-code
          App-assigned-code = Integer-value
          Uri-value=Text-string }
        { this field has no general form }
      end;
  $32:begin  { + Accept-application }
        { Accept-application-value = Any-application | Application-id-value
          lists of Application Id values encoded using multiple Accept-application headers
          Any-application = <Octet 128> ; encoding for "*"
          Application-id-value = Uri-value | App-assigned-code
          App-assigned-code = Integer-value }
        { this field has no general form }
      end;
  $34:begin  { Push-flag }
        { RFC 2616 havent push-flag }
        { this field has no general form }
      end;
  $36:begin  { Profile-diff }
        { RFC 2616 havent Profile-diff
          value-length CCPP-profile
          CCPP-profile = *OCTET ; encoded in WBXML form – see [WBXML]
        }
        Result:= AFldValue;
      end;
  $37,$44:begin  { + Profile-warning, code $37 deprecated }
        { RFC 2616 havent Profile-warning
          Value-length Warn-code Warn-target *Warn-date
          Warn-code = Short-integer
            assigned value Warning code (see [CCPPEx])
            0x10 100; 0x11 101; 0x12 102; 0x20 200; 0x21 201; 0x22 202; 0x23 203
          Warn-target = Uri-value | host [ “ :” port ]
          Warn-date = Date-value
        }
        Result:= IntToStr(GetProfileWarning2Val(Byte(AFldValue[1]) and $7F));
        // get warn-target
        p:= 2;
        Result:= Result + GetCodeOrText(AFldValue, p, code, Nil) + #32;
        // get warn-date if exists
        while p < L do begin
          dt:= DecodeDateTimeValueL(AFldValue, p);
          Result:= Result + GetDateTimeStamp(dt) + #32;
        end;
      end;
  $38:begin  { + Expect }
        { Value-length Expression-var Expression-Value
          Expression-var = Token-text
          Expression-value = (Token-text | Quoted-string) *Expect-params
          Expect-params = Token-text Expect-param-value
          Expect-param-value = Token-text | Quoted-string
          100-continue = <Octet 128>
        }
        // expression-var
        Result:= GetCodeOrText(AFldValue, p, code, Nil) + #32;
        // expression-value
        Result:= Result + GetCodeOrText(AFldValue, p, code, Nil);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $39:begin  { + TE }
        { i.e. TE: trailers, deflate;q=0.5
          Value-length (Well-known-TE | Token-text) [Q-Parameter]
          Q-Parameter = Q-token Q-value
          Well-known-TE = (Chunked | Identity | Gzip | Compress | Deflate)
          Q-token = #128 Trailers = #129 Chunked = #130 Identity = #131 Gzip = #132 Compress = #133 Deflate = #134
        }
        Result:= GetCodeOrText(AFldValue, p, code, GetTE2Name);
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $3A:begin  { + Trailer }
        { Trailer-value = (Well-known-header-field | Token-text)
          Well-known-header-field = Integer-value
          Encoded using values from Header Field Name Assignments table in Assigned Numbers }
        { this field has no general form. Just in case }
        Result:= GetCodeOrText(AFldValue, p, code, getHTTPHeaderFieldName);
      end;
  $40:begin  { + Content-ID }
        { this field has no general form. Just in case }
      end;
  $41:begin  { + Set-Cookie }
        { i.e name=value; path=/
          Bug: I dont know about cookie version
          Value-length Cookie-version Cookie-name Cookie-val *Parameter
          Cookie-version = Version-value
          Cookie-name = Text-string
          Cookie-val = Text-string
        }
        // skip cookie version
        DecodeVersionValueL(AFldValue, p);
        // cookie name
        Result:= GetCodeOrText(AFldValue, p, code, Nil) + '=';
        // cookie value
        Result:= Result + GetCodeOrText(AFldValue, p, code, Nil) + #32;
        // parameters if exists
        Result:= Result + DecodeParameterValues(AFldValue, p, '; ');
      end;
  $42:begin  { + Cookie }
        { Value-length Cookie-version *Cookie
          Cookie = Cookie-length Cookie-name Cookie-val [Cookie-parameters]
          Cookie-length = Uintvar-integer
          Cookie-parameters = Path [Domain]
          Path = Text-string
            if path is an empty string, it indicates that there is no path value present
          Domain = Text-string }
        // skip cookie version
        DecodeVersionValueL(AFldValue, p);
        while p < L do begin
          // cookie length
          len:= UintVar2UintL(AFldValue, p);
          c:= p;
          // cookie name
          Result:= Result + GetCodeOrText(AFldValue, c, code, Nil) + '=';
          // cookie value
          Result:= Result + GetCodeOrText(AFldValue, c, code, Nil);

          // extract cookie parameters
          s1:= Copy(AFldValue, p, len - (c - p));
          // parameters path [domain] if exists add, use space as delimiter. ';' used to delimit cookies
          Result:= Result + DecodeParameterValues(s1, 1, ' ');
          Inc(p, len);
          // separate next cookie
          Result:= Result + '; ';
        end;
      end;
  $43:begin  { Encoding-Version }
        { my text representation: 1.2; code-page=1 }
        { Version-value | Value-length Code-page [Version-value]
            encoded using values from tables in the Assigned Numbers Appendix or from an extended header code page.
          Code-page = Short-integer
            Identity of the extended header code page which the encoding applies for. If the
            Code-page is omitted, the version value refers to the header code pages reserved for headers specified by WAP Forum
        }
        c:= DecodeIntegerL(AFldValue, p);
        Result:= EncodeVersionAsText(DecodeVersionValueL(AFldValue, p)) + '; code-page=' +
          IntToStr(c);
      end;
  $46:begin  { X-WAP-Security }
        { Close-subordinate = #128 }
        { this field has no general form. Just in case }
      end;
  end; { case }
end;

procedure DecodeHeadersValue(const AHeaders: String; var ANextPos: Integer; const ATo: Integer; var AResult: TStrings);
var
  p, ll: Integer;
  fldno: Integer;
  cp: Byte;  // current page, default 1
  fldname: String;

  procedure AddResult(const AFieldValue: String);
  var
    idx: Integer;
  begin
    idx:= AResult.IndexOfName(FldName);
    if idx >= 0 then begin
      AResult[idx]:= AResult[idx] + ', ' + AFieldValue;
    end else begin
      AResult.Add(FldName + '=' + AFieldValue);
    end;
  end;

begin
  {}
  cp:= 1;  // default page is 1
  while ANextPos <= ATo do begin
    case AHeaders[ANextPos] of
    #1..#31: begin // short-cut delimiter
        cp:= Byte(AHeaders[ANextPos]);
        Inc(ANextPos);
      end;
    #127: begin  // shift delimiter
        // page identity 1..255
        Inc(ANextPos);
        if ANextPos <= ATo
        then cp:= Byte(AHeaders[ANextPos]);
      end;
    else begin // message header
      // field name and field value
      fldName:= GetCodeOrText(AHeaders, ANextPos, fldno, GetHTTPHeaderFieldName);
      if fldno < 0
      then fldno:= GetHTTPHeaderFieldCode(fldName);
      if ANextPos > ATo
      then Break;
      case AHeaders[ANextPos] of
      #$80..#$FF: begin
          // field value code itself
          if (cp = 1) and (ANextPos + 1 <= ATo)
          then AddResult(DecodeHeaderValue1(fldno, Byte(AHeaders[ANextPos]) and $7F));
          Inc(ANextPos);
        end;
      #31: begin
          // uintvar octets indicates using general form
          ll:= UIntVar2UintL(AHeaders, ANextPos);
          if (cp = 1)
          then AddResult(DecodeHeaderValueGeneral(fldno, Copy(AHeaders, ANextPos, ll)));
          Inc(ANextPos, ll);
        end;
      #0..#30:begin
          // 0..30 octets. multibyte integer?
          p:= DecodeIntegerL(AHeaders, ANextPos);
          if (cp = 1) then begin
            AddResult(DecodeHeaderValue1(fldno, p));
          end;
        end;
      #32..#127:begin
          // null- terminated
          if (cp = 1) then begin
            AddResult(DecodeHeaderValue0(fldno, AHeaders, ATo, ANextPos));
          end;
        end;
      end; { case }
    end; { else case }
    end; { case }
  end; { while }
end;

{ Length uintvar Length of the Identifier and Parameters fields combined
  Capability identifier = Token-text | Well-known-field-name (Short-integer)
  Capability-specific parameters (Length – length of Identifier octets)
  Parameters
    ACodedCapability    input string
    AFrom               start position in ACodedCapability
    ATo                 last position in ACodedCapability
  Return
    Result              capability name
    ACapabilityCode     capability code
    AResultN or|and AResultStr  integer or|and string(octets) value
  }
function DecodeCapability(const ACodedCapability: String; var AFrom: Integer; ATo: Integer;
  var ACapabilityCode: Integer; var AResultN: Cardinal; var AResultStr: String): String;
var
  L, len, c, st: Integer;
begin
  Result:= '';
  L:= Length(ACodedCapability);
  // check range
  if (AFrom > L)
  then Exit;
  if ATo > L
  then ATo:= L;
  // get identifier name & parameter length
  len:= uintvar2uintL(ACodedCapability, AFrom);
  st:= AFrom;
  AFrom:= AFrom + len;  // next position include length descriptor
  // get capability identifier
  Result:= GetCodeOrText(ACodedCapability, st, ACapabilityCode, getCapabilityName);
  if ACapabilityCode < 0 // if encoded as text
  then ACapabilityCode:= getCapabilityCode(Result);  // get capability code

  // check at least 1 octet exists
  if st > L
  then Exit;
  case ACapabilityCode of
    WAPCAP_CLIENT_SDU_SIZE, WAPCAP_SERVER_SDU_SIZE,
    WAPCAP_CLIENT_MSG_SIZE, WAPCAP_SERVER_MSG_SIZE:
      begin  // 0, 1, 8, 9
        // Maximum Size uintvar
        AResultN:= uintvar2uintL(ACodedCapability, st);
      end;
    WAPCAP_PROTOCOLOPTIONS:
      begin  // 2- Protocol Options
        //
        { 0x80 Confirmed Push Facility
          0x40 Push Facility
          0x20 Session Resume Facility
          0x10 Acknowledgement Headers
          0x08 Large Data Transfer
        }
        // uint8 flag, others bits ignored in current version
        AResultN:= Byte(ACodedCapability[AFrom]);
      end;
    WAPCAP_METHOD_MOR, WAPCAP_PUSH_MOR:
      begin  // 3, 4  (MOR-Maximum Outstanding Requests)
        // uint8
        AResultN:= Byte(ACodedCapability[AFrom]);
      end;
    WAPCAP_EXTENDEDMETHODS, WAPCAP_HEADERCODEPAGES:begin  // 5, 6- Extended Methods | Header Code Pages
        // get PDU type|code page code
        AResultN:= Byte(ACodedCapability[AFrom]);
        Inc(AFrom);
        // get method name | code page name
        AResultStr:= GetCodeOrText(ACodedCapability, AFrom, c, Nil);
      end;
    WAPCAP_ALIASES:begin  // 7- Aliases
        // get address octets. Address is bearer-specific WSP 8.2.2.3
        AResultStr:= Copy(ACodedCapability, AFrom, ATo - AFrom + 1);
      end;
  end; { case }
end;

procedure DecodeCapabilities(const ACodedCapabilities: String; const AFrom, ATo: Integer; var AResult: TStrings);
var
  L, p, CapabilityCode: Integer;
  ResultN: Cardinal;
  ResultStr: String;
begin
  AResult.Clear;
  p:= AFrom;
  L:= Length(ACodedCapabilities);
  if ATo < L
  then L:= ATo;
  while p <= L do begin
    DecodeCapability(ACodedCapabilities, p, L, CapabilityCode, ResultN, ResultStr);
    AResult.AddObject(IntToStr(CapabilityCode) + '=' + ResultStr, TObject(ResultN));
    Inc(p);
  end;
end;

{ decode wsp protocol capabilities to TWapCapabilities object }
procedure DecodeCapabilities2(const ACodedCapabilities: String; const AFrom, ATo: Integer;
  AWapCapabilities: TWapCapabilities);
var
  L, p, CapabilityCode: Integer;
  ResultN: Cardinal;
  ResultStr: String;
begin
  AWapCapabilities.Clear;
  p:= AFrom;
  L:= Length(ACodedCapabilities);
  if ATo < L
  then L:= ATo;
  while p <= L do begin
    DecodeCapability(ACodedCapabilities, p, L, CapabilityCode, ResultN, ResultStr);
    AWapCapabilities.AddByCode(CapabilityCode, ResultN, ResultStr);
    Inc(p);
  end;
end;

{ decode connection-less mode request
  Parameters
    ARequest    request string
  Return
    Result      TID- connection-less transaction identifier
      0..255    TID
      -1        bad request (zero length)
    APDUType    i.e. $40- GET
    APar        usually requested URI
    AHeaders:   headers
}
function DecodeConnectionLessRequest(const ARequest: String; var APDUType: Integer;
  var APar: String; var AHeaders, ACapabilities: TStrings): Integer;
var
  L: Integer;
  p, c, len, len1: Integer;
  s, errorStr: String;
  encoding, wbxmlver, publicid: Integer;
begin
  AHeaders.Clear;
  APar:= '';
  APDUType:= -1;
  Result:= -1;
  L:= Length(ARequest);
  if L < 2
  then Exit;
  Result:= Byte(ARequest[1]);
  APDUType:= Byte(ARequest[2]);
  // make sure we have at least 1 more byte
  if L < 3
  then Exit;
  case APDUType of
  $01: begin      //  Connect
      { Version uint8 WSP protocol version
        CapabilitiesLen uintvar Length of the Capabilities field
        HeadersLen uintvar Length of the Headers field
        Capabilities CapabilitiesLen octets
        Headers HeadersLen octets }
      // get version
      APar:= IntToStr(Byte(ARequest[3]) shr 4) + '.' + IntToStr(Byte(ARequest[3]) and $F);
      // get capabilities len
      p:= 4;
      len:= UintVar2UIntL(ARequest, p);
      // get headers len
      len1:= UintVar2UIntL(ARequest, p);
      // get capabilities
      DecodeCapabilities(ARequest, p, p + len - 1, ACapabilities);
      DecodeHeadersValue(ARequest, p, p + len1 - 1, AHeaders);
    end;
  $02: begin      //  ConnectReply
    end;
  $03: begin      //  Redirect
    end;
  $04: begin      //  Reply
        { Status uint8 S-MethodResult.req::Status or S-Disconnect.req::Reason Codeor S-Unit-MethodResult.req::Status
        HeadersLen uintvar Length of the ContentType and Headers fields combined
        ContentType = Constrained-media | Content-general-form
          Content-general-form = Value-length Media-type
          Media-type = (Well-known-media | Extension-Media) *(Parameter)
        Headers (HeadersLen – length of ContentType) octets
        Data multiple octets
      }
      // get status code
      p:= getHTTPStatus(Byte(ARequest[3]));
      // get length of content-type & headers combined
      p:= 4;
      len:= uintvar2uintL(ARequest, p);
      // get length of body - noir necessary
      // len1:= Length(ARequest) -  p - len + 1;

      // get content-type value
      len1:= p;
      s:= GetCodeOrText(ARequest, p, c, getHTTPContentTypeName);
      len:= len - (p - len1) - 1;
      // get headers
      AHeaders.Clear;
      DecodeHeadersValue(ARequest, p, p + len, AHeaders);
      // get body
      DecompileWMLCString(Copy(ARequest, p, MaxInt), 2, errorStr, encoding, wbxmlver, publicid);
    end;
  $05: begin      //  Disconnect
    end;
  $06: begin      //  Push
      { UriLen uintvar Length of the URI field
        HeadersLen uintvar Length of the ContentType and Headers fields
        combined
        Uri UriLen octets S-MethodInvoke.req::Request URI or
        S-Unit-MethodInvoke.req::Request URI
        ContentType multiple octets S-MethodInvoke.req::Request Headers or
        S-Unit-MethodInvoke.req::Request Headers
        Headers (HeadersLen – length of
        ContentType) octets
        S-MethodInvoke.req::Request Headers or
        S-Unit-MethodInvoke.req::Request Headers
        Data multiple octets S-MethodInvoke.req::Request Body or
        S-Unit-MethodInvoke.req::Request Body
      }
      { ALL THIS INCORRECT }
      // get uri len
      p:= 3;
      len:= uintvar2uintL(ARequest, p);
      // get headers len
      len1:= uintvar2uintL(ARequest, p);
      // get uri
      // get content-type value
      len1:= p;
      s:= GetCodeOrText(ARequest, p, c, getHTTPContentTypeName);
      len:= len - (p - len1) - 1;
      // get headers
      AHeaders.Clear;
      DecodeHeadersValue(ARequest, p, p + len, AHeaders);
      // get data
      DecompileWMLCString(Copy(ARequest, p, MaxInt), 2, errorStr, encoding, wbxmlver, publicid);
    end;
  $07: begin      //  ConfirmedPush
    end;
  $08: begin      //  Suspend
    end;
  $09: begin      //  Resume
    end;
  $40: begin      //  Get
      // get uintvar length of the URI field
      p:= 3;
      len:= UintVar2UIntL(ARequest, p);
      APar:= Copy(ARequest, p, len);
      Inc(p, len);
      DecodeHeadersValue(ARequest, p, L, AHeaders);
    end;
  $41: begin      //  Options
    end;
  $42: begin      //  Head
    end;
  $43: begin      //  Delete
    end;
  $44: begin      //  Trace
    end;
  $60: begin      //  Post
    end;
  $61: begin      //  Put
    end;
  $80: begin      //  Data Fragment PDU
    end;
  end;
end;

{ search AName header field name like 'Content-Type: ' or 'Content-Type='
  and move up or down
}
function SetHeaderStringsOrder(AHeaders: TStrings; const AName: String; const AValue: String; AOrder: Integer): Integer;
var
  i, L: Integer;
begin
  Result:= 0;
  L:= Length(AName);
  for i:= 0 to AHeaders.Count - 1 do begin
    if CompareText(AName, Copy(AHeaders[i], 1, L)) = 0 then begin
      AHeaders.Exchange(i, AOrder);
      Result:= 1;
      Exit;
    end;
  end;
  AHeaders.Insert(AOrder, AName + ': ' + AValue);
end;

function EncodeConnectionLessResponce(APDUType: Integer; ATId: Integer;
  const AContentTypeIdx: Integer; const AStatus: Integer; const AData: String; const AHeaders: TStrings;
  const AVersion: String = DEFAULT_WMLC_ENCODING_VERSION): String;
var
  ct, h: String;
begin
  Result:= Char(ATId) + Char(APDUType);
  case APDUType of
  $01: begin      //  Connect
      { Version uint8 WSP protocol version
        CapabilitiesLen uintvar Length of the Capabilities field
        HeadersLen uintvar Length of the Headers field
        Capabilities CapabilitiesLen octets
        Headers HeadersLen octets }
    end;
  $02: begin      //  ConnectReply
    end;
  $03: begin      //  Redirect
    end;
  $04: begin      //  Reply
        { Status uint8 S-MethodResult.req::Status or S-Disconnect.req::Reason Codeor S-Unit-MethodResult.req::Status 6.4.2.2
        HeadersLen uintvar Length of the ContentType and Headers fields combined
        ContentType = Constrained-media | Content-general-form
          Content-general-form = Value-length Media-type
          Media-type = (Well-known-media | Extension-Media) *(Parameter)
        Headers (HeadersLen – length of ContentType) octets
        Data multiple octets
      }
      // encode Content-type such 'application/vnd.wap.wmlc'
      // encode Content-Type and other headers
      h:= EncodeHeadersValue(AHeaders, AVersion);
      ct:= EncodeInteger(AContentTypeIdx);
      Result:= Result + Char(getHTTPStatusCode(AStatus)) + uint2uintvar(Length(ct) + Length(h)) +
        ct + h + AData;
    end;
  $05: begin      //  Disconnect
    end;
  $06: begin      //  Push
      { UriLen uintvar Length of the URI field
        HeadersLen uintvar Length of the ContentType and Headers fields
        combined
        Uri UriLen octets S-MethodInvoke.req::Request URI or
        S-Unit-MethodInvoke.req::Request URI
        ContentType multiple octets S-MethodInvoke.req::Request Headers or
        S-Unit-MethodInvoke.req::Request Headers
        Headers (HeadersLen – length of
        ContentType) octets
        S-MethodInvoke.req::Request Headers or
        S-Unit-MethodInvoke.req::Request Headers
        Data multiple octets S-MethodInvoke.req::Request Body or
        S-Unit-MethodInvoke.req::Request Body
      }
    end;
  $07: begin      //  ConfirmedPush
    end;
  $08: begin      //  Suspend
    end;
  $09: begin      //  Resume
    end;
  $40: begin      //  Get
    end;
  $41: begin      //  Options
    end;
  $42: begin      //  Head
    end;
  $43: begin      //  Delete
    end;
  $44: begin      //  Trace
    end;
  $60: begin      //  Post
    end;
  $61: begin      //  Put
    end;
  $80: begin      //  Data Fragment PDU
    end;
  end;
end;

{
  Return http code like 200
}
function ParseHTTPResponse(var AData: String; AHeaders: TStrings): Integer;
var
  L, p, p0, p1, p2: Integer;
  s: String;
// CharSetEncoding: Integer;
begin
  // e.g. HTTP/1.1 403 Access Forbidden
  L:= Length(AData);
  if (L < 4) or (CompareText('HTTP', Copy(AData, 1, 4)) <> 0) then begin
    // no header sent
    AHeaders.Clear;
    Result:= 200;
    Exit;
  end;

  p1:= Pos('/', AData);
  p1:= PosFrom(p1, #32, AData);
  Inc(p1);
  while (p1 <= L) do begin
    if AData[p1] in ['0'..'9'] then Break;
    Inc(p1);
  end;
  p2:= p1;
  while (p2 <= L) do begin
    if not (AData[p2] in ['0'..'9'])
    then Break;
    Inc(p2);
  end;
  Result:= StrToIntDef(Copy(AData, p1, p2 - p1), 500);
  // search end of first string
  while (p2 <= L) do begin
    if AData[p2] = #10
    then Break;
    Inc(p2);
  end;
  // search end of headers
  p1:= Pos(#13#10#13#10, AData);
  if p1 <= 0
  then p1:= L;
  AHeaders.Text:= Copy(AData, p2 + 1, p1 - p2 - 1);
  // replace ':' to '='
  for p2:= 0 to AHeaders.Count - 1 do begin
    s:= AHeaders[p2];
    p:= Pos(':', s);
    if p > 0 then begin
      s[p]:= '=';
      L:= p + 1;
      while L <= Length(s) do begin
        if s[L] > #32
        then Break;
        Inc(L);
      end;
      Delete(s, p+1, L - p - 1);
      AHeaders[p2]:= s;
    end;
  end;
  // what for? CharSetEncoding:= util_xml.GetEncoding(ASrc, wmlc.csUTF8);
  // copy body
  Delete(AData, 1, p1 + 4 - 1);
end;

function WriteAndReadSocket(const AHost, AAddress, AService: String;
  const APort: Integer; AValue: String; var ErrorDesc: String): String;
var
  Terminated: Boolean;
  Stream: TWinSocketStream;
  ClientSocket: TClientWinSocket;
  L, r: Integer;
  Buffer: array [0..1023] of Char;
begin
  Result:= '';
  ErrorDesc:= '';
  ClientSocket:= Nil;
  Stream:= Nil;

  try try
    { make sure connection is active }
    ClientSocket:= TClientWinSocket.Create(INVALID_SOCKET);
    ClientSocket.ClientType:= ctBlocking;
    ClientSocket.Open(AHost, AAddress, AService, APort);
    ClientSocket.SendText(AValue);

    Stream:= TWinSocketStream.Create(ClientSocket, 60000);
    Terminated:= False;
    while (not Terminated) and ClientSocket.Connected do begin
      try
        { give the server 60 seconds }
        if Stream.WaitForData(60000) then begin
          r:= Stream.Read(Buffer, SizeOf(Buffer));
          if r = 0   { if can’t read in 60 seconds, close the connection }
          then ClientSocket.Close else begin
            L:= Length(Result);
            SetLength(Result, L + r);
            Move(Buffer, Result[L+1], r);
          end;
        end else ClientSocket.Close; { if server doesn’t start, close }
      finally
      end;
    end;
  except
    on E: Exception do ErrorDesc:= E.Message
  end;
  finally
    if Assigned(Stream)
    then Stream.Free;
    if Assigned(ClientSocket)
    then ClientSocket.Free;
  end;
end;

function ConnectionLessRequestAndReply(const ARequest: String;
  var APDUType: Integer; var APar: String; var AHeaders, ACapabilities: TStrings;
  const AVersion: String = DEFAULT_WMLC_ENCODING_VERSION): String;
var
  Status: Integer;
  errdesc, Data: String;
  tid: Integer;
  protocol, host, IPaddress, fn, bookmark: String;
  cti, idx,
  port: Integer;
begin
  tid:= DecodeConnectionLessRequest(ARequest, APDUType, APar, AHeaders, ACapabilities);

  if util1.ParseUrl(APar, protocol, host, IPaddress, fn, bookmark, port, 'http', 80)
  then APar:= fn+bookmark;
  if Length(APar) = 0
  then APar:= '/';
  APar:= getPDUTypeName(APDUType)+ #32 + APar + #13#10#13#10 + AHeaders.Text;
  Data:= WriteAndReadSocket(host + IPAddress, '', '', 80, APar, errdesc);
  if Length(errdesc) > 0 then begin
    Data:= '<wml><card title="Error"><p><do type="prev" name="Back"><prev/></do>' + errdesc + '</p></card></wml>';
  end;
  Status:= ParseHTTPResponse(Data, AHeaders);

  idx:= AHeaders.IndexOfName('Content-type');
  if idx < 0 then begin
    // let try determine by file extension
    if CompareText('.wbmp', ExtractFileExt(fn)) = 0
    then cti:= WML_HTTPCONTENTTYPE_image_vnd_wap_wbmp
    else if CompareText('.wml', ExtractFileExt(fn)) = 0
      then cti:= WML_HTTPCONTENTTYPE_text_vnd_wap_wml
      else cti:= WML_HTTPCONTENTTYPE_text_plain;
  end else begin
    cti:= (GetHTTPContentTypeCode(AHeaders.Values['Content-type']));
    // remove content-type from headers
    AHeaders.Delete(idx);
  end;
  // AHeaders.Clear;
  // add gateway headers
  AHeaders.Add('Encoding-version=' + AVersion);

  case cti of
    WML_HTTPCONTENTTYPE_text..WML_HTTPCONTENTTYPE_text_vnd_wap_wml - 1,
    WML_HTTPCONTENTTYPE_text_vnd_wap_wml + 1 .. WML_HTTPCONTENTTYPE_text_last:begin
        // some sort of text, not wmlc
        Data:= '<wml><card title="Error"><p><do type="prev" name="Back"><prev/></do>Wrong content type returned</p></card></wml>';
        Data:= wmlc.CompileWMLCString(0, Data, Nil);
        cti:= WML_HTTPCONTENTTYPE_application_vnd_wap_wmlc;
      end;
    WML_HTTPCONTENTTYPE_text_vnd_wap_wml:begin
        Data:= wmlc.CompileWMLCString(0, Data, Nil);
        cti:= WML_HTTPCONTENTTYPE_application_vnd_wap_wmlc;
      end;
    WML_HTTPCONTENTTYPE_application..WML_HTTPCONTENTTYPE_MAX:;  // nothing to do
  end; { case }

  Result:= EncodeConnectionLessResponce(4, tid, cti, Status, Data, AHeaders, AVersion);
end;

end.
