unit
  resWAPStrings;
(*##*)
(*******************************************************************
*                                                                 *
*   r  e  s  w  a  p  s  t  r  i  n  g  s                          *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   WAP help string resources                                     *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Apr 08 2002                                     *
*   Last fix     : Apr 08 2002                                    *
*   Lines        :                                                 *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

{-- capabilities ---}
resourcestring
  WAPCAPDESC_ALIASES =
   'A service user can use this capability to indicate the alternate addresses the ' +
   'peer may use to access the same service user instance that is using the current '+
   'session. The addresses are listed in a preference order, with the most preferred '+
   'alias first. This information can, for example, be used to facilitate a switch to a '+
   'new bearer, when a session is resumed.';

  WAPCAPDESC_CLIENT_SDU_SIZE =
    'The client use this capability to agree on the size of the largest '+
    'transaction service data unit, which may be sent to the client during the session.';

  WAPCAPDESC_SERVER_SDU_SIZE =
    'The server use this capability to agree on the size of the largest '+
    'transaction service data unit, which may be sent to the server during the session.';

  WAPCAPDESC_EXTENDEDMETHODS =
    'This capability is used to agree on the set of extended methods (beyond those '+
    'defined in HTTP/1.1), which are supported both by the client and the server peer, '+
    'and may be used subsequently during the session.';

  WAPCAPDESC_HEADERCODEPAGES =
    'This capability is used to agree on the set of extension header code pages, which '+
    'are supported both by the client and the server, and shall be used subsequently '+
    'during the session.';

  WAPCAPDESC_METHOD_MOR =
    'The client and server use this capability to agree on the maximum number of method '+
    'invocations, which can be active at the same time during the session.';

  WAPCAPDESC_PUSH_MOR =
    'The client and server use this capability to agree on the maximum number of confirmed '+
    'push invocations, which can be active at the same time during the session.';

  WAPCAPDESC_PROTOCOLOPTIONS =
    'This capability is used to enable the optional service facilities and features. '+
    'It may contain elements from the list: Push, Confirmed Push, Session Resume, '+
    'Acknowledgement Headers, Large Data Transfer. The presence of an element indicates '+
    'that use of the specific facility or feature is enabled.';

  WAPCAPDESC_CLIENT_MSG_SIZE =
    'The client use this capability to agree on the size of the largest '+
    'message, which may be sent to the client during the session. One message may '+
    'consist of multiple transaction service data units.';

  WAPCAPDESC_SERVER_MSG_SIZE =
    'The server use this capability to agree on the size of the largest '+
    'message, which may be sent to the client during the session. One message may '+
    'consist of multiple transaction service data units.';
    
implementation

function GetWAPCapabilitiesDesc(): String;
begin
end;

{ Decode header value, well-known field as code (ehsCode), or as text depending field name length:
  0 - 30 This octet is followed by the indicated number (0 –30) of data octets
  31 This octet is followed by a uintvar, which indicates the number of data octets after it
  32 - 127 The value is a text string, terminated by a zero octet (NUL character)
  128 - 255 It is an encoded 7-bit value; this header has no more data
}
{
function DecodeFieldValue(const AEncodedFieldValue: String; var AResult: String): Integer;
var
  i, L, f: Integer;
begin
  Result:= -1;
  AResult:= '';
  L:= Length(AEncodedFieldValue);
  if L = 0 then Exit;
  case Byte(AEncodedFieldValue[1]) of
  0..30:begin
      // endoded 0-30 octets
      AResult:= Copy(AEncodedFieldValue, 2, Byte(AEncodedFieldValue[1]));
      Result:= getHTTPHeaderFieldCode(AResult, AVersion);
    end;
  32..127:begin
      // endoded up to 95 octets plus NULL character
      for i:= 2 to 96 do begin
        if AEncodedFieldValue[i] = #0
        then Break;
        AResult:= AResult + AEncodedFieldValue[i];
      end;
      Result:= getHTTPHeaderFieldCode(AResult, AVersion);
    end;
  $80..$FF:begin
      // decode well-known field number
      Result:= Byte(AEncodedFieldValue[1]) and $7F;
      AResult:= getHTTPHeaderFieldName(Result);
    end;
  else begin
      // decode up to 2^32 octets
      L:= UintVar2UIntL(AEncodedFieldValue, 2, f);
      AResult:= Copy(AEncodedFieldValue, 2 + f, L);
      Result:= getHTTPHeaderFieldCode(AResult, AVersion);
    end;
  end; // case
end;
}
{ Encode header name, well-known field as code (ehsCode), or as text depending field name length:
  0 - 30 This octet is followed by the indicated number (0 –30) of data octets
  31 This octet is followed by a uintvar, which indicates the number of data octets after it
  32 - 127 The value is a text string, terminated by a zero octet (NUL character)
  128 - 255 It is an encoded 7-bit value; this header has no more data
}
{
function EncodeFieldValue(const AHeaderField: String): String;
var
  HeaderFieldNo: Integer;
  EncodeStyle: TEncodeHeaderNameStyle;
  HasValue: Boolean;
  p, L: Integer;
begin
  Result:= '';
  L:= Length(AHeaderField);
  if L = 0 then Exit;
  // get well-known field number. It means no value is provided
  // Field-name: Field-value
  //  Just-Field-name:
  //  in case of header field w/o value check is valãe is empty
  HasValue:= False;
  p:= Pos(':', AHeaderField);
  if p > 0 then begin
    L:= Length(AHeaderField);
    Inc(p);
    while p <= L do begin
      if AHeaderField[p] > #32 then begin
        // field value is not empty, value exists
        HasValue:= True;
      end;
    end;
    // strip ':'from header field and get field well-known number
    if not HasValue
    then HeaderFieldNo:= GetHTTPHeaderFieldCode(Copy(AHeaderField, 1, p - 1), AVersion)
    else HeaderFieldNo:= -1;
  end else begin
    // strange, but ':' not found. Let try get field well-known header field name number
    HeaderFieldNo:= GetHTTPHeaderFieldCode(AHeaderField, AVersion);
  end;

  if (HeaderFieldNo >= 0) then EncodeStyle:= ehsCode else begin
    // text encoding no wel-known header field
    if L <= 30 then EncodeStyle:= ehsTextLenDescriptor else
      if L <= 127 then EncodeStyle:= ehsNullTerminated else
        EncodeStyle:= ehsTextLenDescriptorUIVarFollow;
  end;
  case EncodeStyle of
  ehsCode:begin
      // encode well-known field name number (no more data)
      Result:= Char(HeaderFieldNo or $80);
    end;
  ehsTextLenDescriptor:begin
      // endode 0-30 octets
      Result:= Char(L) + AHeaderField;
    end;
  ehsNullTerminated:begin
      // endode up to 31-126 (95) octets plus NULL character
      Result:= Char(L + 1) + AHeaderField + #0;
    end;
  ehsTextLenDescriptorUIVarFollow:begin
      // endode up to 2^32 octets
      Result:= #31 + Uint2UIntVar(L) + AHeaderField;
    end;
  end; // case
end;
}

end.
