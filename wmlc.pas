unit
  wmlc;
(*##*)
(*******************************************************************
*                                                                 *
*   w  m  l  c                                                     *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   wireless markup language classes                              *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Nov 28 2001                                     *
*   Last fix     : Apr 06 2002                                    *
*   Lines        : 2786                                            *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface
uses
  Classes, SysUtils, StrUtils, Types,
  jclUnicode,
  customxml, wml, util_xml, xmlParse,
  util1;

  { Bit:
    7           6        5  4  3  2  1  0
    Mask:
    80          40       20
    Attributes  Content
  }

const
  DEFAULT_WMLC_ENCODING_VERSION = '1.2'; // last known is 1.4

  // Global extension token assignments
  WMLG_SWITCHPAGE  = $00;  // Change the code page for the current token state.
                           // Followed by a single u_int8 indicating the new code page number.
                           // not used
  WMLTC_END        = $01;  // Indicates the end of an attribute list or the end of an element.
  WMLTC_CHARACTER  = $02;  // A character entity. Followed by a mb_u_int32 encoding the character entity number.
                           // not used
  WMLG_STR_I       = $03;  // inline null-terminated string follows
  WMLG_LITERAL     = $04;
  // Variable substitution
  WMLG_EXT_I_0     = $40;  // $(var:escape). Name of the variable is inline. Escaped.
  WMLG_EXT_I_1     = $41;  // $(var:unesc).Unescaped
  WMLG_EXT_I_2     = $42;  // $(var:noesc). No transformation
  WMLG_PI          = $43;  // Processing instruction.
                           // not used
  WMLG_LITERAL_C   = $44;  // An unknown tag posessing content but no attributes.
                           // not used
  WMLG_EXT_T_0     = $80;  // Variable name encoded as a reference into the string table. Escaped.
  WMLG_EXT_T_1     = $81;  // Unescaped
  WMLG_EXT_T_2     = $82;  // No transformation
  WMLG_STR_T       = $83;  // ?!! No in wml 1.3
  WMLG_LITERAL_A   = $84;  // An unknown tag posessing attributes but no content.
                           // not used
  WMLG_EXT_0       = $C0;  // Reserved
  WMLG_EXT_1       = $C1;  // Reserved
  WMLG_EXT_2       = $C2;  // Reserved

{ Tag tokens }

  WMLT_A          = $1C;
  WMLT_ANCHOR     = $22;
  WMLT_ACCESS     = $23;
  WMLT_B          = $24;
  WMLT_BIG        = $25;
  WMLT_BR         = $26; { no closure tag }
  WMLT_CARD       = $27;
  WMLT_DO         = $28;
  WMLT_EM         = $29;
  WMLT_FIELDSET   = $2A;
  WMLT_GO         = $2B;
  WMLT_HEAD       = $2C;
  WMLT_I          = $2D;
  WMLT_IMG        = $2E; { no closure tag }
  WMLT_INPUT      = $2F;
  WMLT_META       = $30; { no closure tag }
  WMLT_NOOP       = $31; { no closure tag }
  WMLT_P          = $20;
  WMLT_POSTFIELD  = $21;
  WMLT_PRE        = $1B; { wml 1.3 }
  WMLT_PREV       = $32; { ?!! no closure tag }
  WMLT_ONEVENT    = $33;
  WMLT_OPTGROUP   = $34;
  WMLT_OPTION     = $35;
  WMLT_REFRESH    = $36;
  WMLT_SELECT     = $37;
  WMLT_SETVAR     = $3E; { no closure tag }
  WMLT_SMALL      = $38;
  WMLT_STRONG     = $39;
  WMLT_TABLE      = $1F;
  WMLT_TD         = $1D;
  WMLT_TEMPLATE   = $3B;
  WMLT_TIMER      = $3C; { no closure tag }
  WMLT_TR         = $1E;
  WMLT_U          = $3D;
  WMLT_WML        = $3F;

  WMLTC_ATTRIBUTES = $80; { element has attributes bit }
  WMLTC_CONTENT    = $40; { element has content (include other tags) bit }
  WMLTC_TAG_VALUE  = ( not (WMLTC_ATTRIBUTES or WMLTC_CONTENT) );  { FFFFFF 3F mask }

{ Attribute start tokens }

  WMLS_ACCEPT_CHARSET          = $05;
  WMLS_ACCESSKEY               = $5E;
  WMLS_ALIGN                   = $52;
  WMLS_ALIGN_BOTTOM            = $06;
  WMLS_ALIGN_CENTER            = $07;
  WMLS_ALIGN_LEFT              = $08;
  WMLS_ALIGN_MIDDLE            = $09;
  WMLS_ALIGN_RIGHT             = $0A;
  WMLS_ALIGN_TOP               = $0B;
  WMLS_ALT                     = $0C;
  WMLS_CACHECONTROL            = $64; { 1.3 }
  WMLS_CLASS                   = $54;
  WMLS_COLUMNS                 = $53;
  WMLS_CONTENT                 = $0D;
  WMLS_CONTENT_WMLC            = $5C;
  WMLS_DOMAIN                  = $0F;
  WMLS_EMPTYOK_FALSE           = $10;
  WMLS_EMPTYOK_TRUE            = $11;
  WMLS_ENCTYPE                 = $5F;
  WMLS_ENCTYPE_URLENCODED      = $60;
  WMLS_ENCTYPE_MULTIPART       = $61;
  WMLS_FORMAT                  = $12;
  WMLS_FORUA_FALSE             = $56;
  WMLS_FORUA_TRUE              = $57;
  WMLS_HEIGHT                  = $13;
  WMLS_HREF                    = $4A;
  WMLS_HREF_HTTP               = $4B;
  WMLS_HREF_HTTPS              = $4C;
  WMLS_HSPACE                  = $14;
  WMLS_HTTP_EQUIV              = $5A;
  WMLS_HTTP_EQUIV_CONTENT_TYPE = $5B;
  WMLS_HTTP_EQUIV_EXPIRES      = $5D;
  WMLS_ID                      = $55;
  WMLS_IVALUE                  = $15;
  WMLS_INAME                   = $16;
  WMLS_LABEL                   = $18;
  WMLS_LOCALSRC                = $19;
  WMLS_MAXLENGTH               = $1A;
  WMLS_METHOD_GET              = $1B;
  WMLS_METHOD_POST             = $1C;
  WMLS_MODE_NOWRAP             = $1D;
  WMLS_MODE_WRAP               = $1E;
  WMLS_MULTIPLE_FALSE          = $1F;
  WMLS_MULTIPLE_TRUE           = $20;
  WMLS_NAME                    = $21;
  WMLS_NEWCONTEXT_FALSE        = $22;
  WMLS_NEWCONTEXT_TRUE         = $23;
  WMLS_ONENTERBACKWARD         = $25;
  WMLS_ONENTERFORWARD          = $26;
  WMLS_ONPICK                  = $24;
  WMLS_ONTIMER                 = $27;
  WMLS_OPTIONAL_FALSE          = $28;
  WMLS_OPTIONAL_TRUE           = $29;
  WMLS_PATH                    = $2A;
  WMLS_SCHEME                  = $2E;
  WMLS_SENDREFERER_FALSE       = $2F;
  WMLS_SENDREFERER_TRUE        = $30;
  WMLS_SIZE                    = $31;
  WMLS_SRC                     = $32;
  WMLS_SRC_HTTP                = $58;
  WMLS_SRC_HTTPS               = $59;
  WMLS_ORDERED_TRUE            = $33;
  WMLS_ORDERED_FALSE           = $34;
  WMLS_TABINDEX                = $35;
  WMLS_TITLE                   = $36;
  WMLS_TYPE                    = $37;
  WMLS_TYPE_ACCEPT             = $38;
  WMLS_TYPE_DELETE             = $39;
  WMLS_TYPE_HELP               = $3A;
  WMLS_TYPE_PASSWORD           = $3B;
  WMLS_TYPE_ONPICK             = $3C;
  WMLS_TYPE_ONENTERBACKWARD    = $3D;
  WMLS_TYPE_ONENTERFORWARD     = $3E;
  WMLS_TYPE_ONTIMER            = $3F;
  WMLS_TYPE_OPTIONS            = $45;
  WMLS_TYPE_PREV               = $46;
  WMLS_TYPE_RESET              = $47;
  WMLS_TYPE_TEXT               = $48;
  WMLS_TYPE_VND                = $49;
  WMLS_VALUE                   = $4D;
  WMLS_VSPACE                  = $4E;
  WMLS_WIDTH                   = $4F;
  WMLS_XML_LANG                = $50;
  WMLS_XML_SPACE_PRESERVE      = $62;
  WMLS_XML_SPACE_DEFAULT       = $63;

{ Attribute value tokens }

  WMLA_COM              = $85;
  WMLA_EDU              = $86;
  WMLA_NET              = $87;
  WMLA_ORG              = $88;
  WMLA_ACCEPT           = $89;
  WMLA_BOTTOM           = $8A;
  WMLA_CLEAR            = $8B;
  WMLA_DELETE           = $8C;
  WMLA_HELP             = $8D;
  WMLA_HTTP             = $8E;
  WMLA_HTTP_WWW         = $8F;
  WMLA_HTTPS            = $90;
  WMLA_HTTPS_WWW        = $91;
  WMLA_MIDDLE           = $93;
  WMLA_NOWRAP           = $94;
  WMLA_ONENTERBACKWARD  = $96;
  WMLA_ONENTERFORWARD   = $97;
  WMLA_ONPICK           = $95;
  WMLA_ONTIMER          = $98;
  WMLA_OPTIONS          = $99;
  WMLA_PASSWORD         = $9A;
  WMLA_RESET            = $9B;
  WMLA_TEXT             = $9D;
  WMLA_TOP              = $9E;
  WMLA_UNKNOWN          = $9F;
  WMLA_WRAP             = $A0;
  WMLA_WWW              = $A1;

{ Misc }

  WMLC_INLINE_STRING     = $03;
  WMLC_INLINE_STRING_END = $00;

{
static int wml_no_closure_tags[] = WMLT_BR, WMLT_NOOP, WMLT_PREV, WMLT_IMG, WMLT_META, WMLT_TIMER, WMLT_SETVAR, -1
}

  WML_TAGS_MIN           = WMLT_PRE;
  WML_TAGS_MAX           = WMLT_WML;

const
  wml_tags: array [WML_TAGS_MIN..WML_TAGS_MAX] of String[9] = (
{ $1B } 'pre',
{ $1C } 'a',
{ $1D } 'td',
{ $1E } 'tr',
{ $1F } 'table',
{ $20 } 'p',
{ $21 } 'postfield',
{ $22 } 'anchor',
{ $23 } 'access',
{ $24 } 'b',
{ $25 } 'big',
{ $26 } 'br',
{ $27 } 'card',
{ $28 } 'do',
{ $29 } 'em',
{ $2A } 'fieldset',
{ $2B } 'go',
{ $2C } 'head',
{ $2D } 'i',
{ $2E } 'img',
{ $2F } 'input',
{ $30 } 'meta',
{ $31 } 'noop',
{ $32 } 'prev',
{ $33 } 'onevent',
{ $34 } 'optgroup',
{ $35 } 'option',
{ $36 } 'refresh',
{ $37 } 'select',
{ $38 } 'small',
{ $39 } 'strong',
{ $3A } '',
{ $3B } 'template',
{ $3C } 'timer',
{ $3D } 'u',
{ $3E } 'setvar',
{ $3F } 'wml');

  WML_SATTR_MIN = WMLS_ACCEPT_CHARSET;
  WML_SATTR_MAX = WMLS_CACHECONTROL;
  wml_start_attributes: array [WML_SATTR_MIN..WML_SATTR_MAX] of String[43]= (
{ $05 } 'accept-charset',
{ $06 } 'align="bottom"',
{ $07 } 'align="center"',
{ $08 } 'align="left"',
{ $09 } 'align="middle"',
{ $0A } 'align="right"',
{ $0B } 'align="top"',
{ $0C } 'alt',
{ $0D } 'content',
{ $0E } '',
{ $0F } 'domain',
{ $10 } 'emptyok="false"',
{ $11 } 'emptyok="true"',
{ $12 } 'format',
{ $13 } 'height',
{ $14 } 'hspace',
{ $15 } 'ivalue',
{ $16 } 'iname',
{ $17 } '',
{ $18 } 'label',
{ $19 } 'localsrc',
{ $1A } 'maxlength',
{ $1B } 'method="get"',
{ $1C } 'method="post"',
{ $1D } 'mode="nowrap"',
{ $1E } 'mode="wrap"',
{ $1F } 'multiple="false"',
{ $20 } 'multiple="true"',
{ $21 } 'name',
{ $22 } 'newcontext="false"',
{ $23 } 'newcontext="true"',
{ $24 } 'onpick',
{ $25 } 'onenterbackward',
{ $26 } 'onenterforward',
{ $27 } 'ontimer',
{ $28 } 'optional="false"',
{ $29 } 'optional="true"',
{ $2A } 'path',
{ $2B } '',
{ $2C } '',
{ $2D } '',
{ $2E } 'scheme',
{ $2F } 'sendreferer="false"',
{ $30 } 'sendreferer="true"',
{ $31 } 'size',
{ $32 } 'src',
{ $33 } 'ordered="true"',
{ $34 } 'ordered="false"',
{ $35 } 'tabindex',
{ $36 } 'title',
{ $37 } 'type',
{ $38 } 'type="accept"',
{ $39 } 'type="delete"',
{ $3A } 'type="help"',
{ $3B } 'type="password"',
{ $3C } 'type="onpick"',
{ $3D } 'type="onenterbackward"',
{ $3E } 'type="onenterforward"',
{ $3F } 'type="ontimer"',
{ $40 } '',
{ $41 } '',
{ $42 } '',
{ $43 } '',
{ $44 } '',
{ $45 } 'type="options"',
{ $46 } 'type="prev"',
{ $47 } 'type="reset"',
{ $48 } 'type="text"',
{ $49 } 'type="vnd."', { '"vnd"'}
{ $4A } 'href',
{ $4B } 'href="http://',
{ $4C } 'href="https://',
{ $4D } 'value',
{ $4E } 'vspace',
{ $4F } 'width',
{ $50 } 'xml:lang',
{ $51 } '',
{ $52 } 'align',
{ $53 } 'columns',
{ $54 } 'class',
{ $55 } 'id',
{ $56 } 'forua="false"',
{ $57 } 'forua="true"',
{ $58 } 'src="http://',
{ $59 } 'src="https://',
{ $5A } 'http-equiv',
{ $5B } 'http-equiv="Content-Type"',
{ $5C } 'content="application/vnd.wap.wmlc;charset=',
{ $5D } 'http-equiv="Expires"',
{ $5E } 'accesskey',
{ $5F } 'enctype',
{ $60 } 'enctype="application/x-www-form-urlencoded"',
{ $61 } 'enctype="multipart/form-data"',
{ $62 } 'xml:space="preserve"',
{ $63 } 'xml:space="default"',
{ $64 } 'cache-control="no-cache"'
);

{ attribute value tokens }
  WML_VATTR_MIN = WMLA_COM;
  WML_VATTR_MAX = WMLA_WWW;

  wml_value_attributes: array[WML_VATTR_MIN..WML_VATTR_MAX] of String[15]= (
{ $85 } '.com/',
{ $86 } '.edu/',
{ $87 } '.net/',
{ $88 } '.org/',
{ $89 } 'accept',
{ $8A } 'bottom',
{ $8B } 'clear',
{ $8C } 'delete',
{ $8D } 'help',
{ $8E } 'http://',
{ $8F } 'http://www.',
{ $90 } 'https://',
{ $91 } 'https://www.',
{ $92 } '',
{ $93 } 'middle',
{ $94 } 'nowrap',
{ $95 } 'onpick',
{ $96 } 'onenterbackward',
{ $97 } 'onenterforward',
{ $98 } 'ontimer',
{ $99 } 'options',
{ $9A } 'password',
{ $9B } 'reset',
{ $9C } '',
{ $9D } 'text',
{ $9E } 'top',
{ $9F } 'unknown',
{ $A0 } 'wrap',
{ $A1 } 'www.'); { 'Www.'}

{---- In conformance to WAP WSP, Appendix A, Table 34. PDU type assignments ---}

type
  TPDUType = packed record
    c: Byte;        // PDU type number
    n: String[17];  // PDU type name
  end;

  TPDUTypeTable = array [0..16] of TPDUType;

const
  PDUTypeTable: TPDUTypeTable = (
    (c: $01; n: 'Connect'),
    (c: $02; n: 'ConnectReply'),
    (c: $03; n: 'Redirect'),
    (c: $04; n: 'Reply'),
    (c: $05; n: 'Disconnect'),
    (c: $06; n: 'Push'),
    (c: $07; n: 'ConfirmedPush'),
    (c: $08; n: 'Suspend'),
    (c: $09; n: 'Resume'),
{ Unassigned $10–$3F }
    (c: $40; n: 'GET'),
    (c: $41; n: 'OPTIONS'),
    (c: $42; n: 'HEAD'),
    (c: $43; n: 'DELETE'),
    (c: $44; n: 'TRACE'),
{ Unassigned $45-$4F, extended $50-$5F }
    (c: $60; n: 'POST'),
    (c: $61; n: 'PUT'),
{ Unassigned $62-$6F, extended $70-$7F }
    (c: $80; n: 'Data Fragment PDU')
{ Reserved $81-$FF }
);

{ In conformance to WAP WSP, Appendix A, Table 36. HTTP status code assignments }

type
  THTTPStatusCode = packed record
    h: Word;    // HTTP status code
    c: Byte;    // code
  end;

  THTTPStatusCodeTable = array [0..40] of THTTPStatusCode;

const
  HTTPStatusCode: THTTPStatusCodeTable = (
  (h: 100; c: $10), { Continue }
  (h: 101; c: $11), { Switching Protocols }
  (h: 200; c: $20), { OK, Success }
  (h: 201; c: $21), { Created }
  (h: 202; c: $22), { Accepted }
  (h: 203; c: $23), { Non-Authoritative Information }
  (h: 204; c: $24), { No Content }
  (h: 205; c: $25), { Reset Content }
  (h: 206; c: $26), { Partial Content }
  (h: 300; c: $30), { Multiple Choices }
  (h: 301; c: $31), { Moved Permanently }
  (h: 302; c: $32), { Moved temporarily }
  (h: 303; c: $33), { See Other }
  (h: 304; c: $34), { Not modified }
  (h: 305; c: $35), { Use Proxy }
  (h: 306; c: $36), { (reserved) }
  (h: 307; c: $37), { Temporary Redirect }
  (h: 400; c: $40), { Bad Request - server could not understand request }
  (h: 401; c: $41), { Unauthorized }
  (h: 402; c: $42), { Payment required }
  (h: 403; c: $43), { Forbidden – operation is understood but refused }
  (h: 404; c: $44), { Not Found }
  (h: 405; c: $45), { Method not allowed }
  (h: 406; c: $46), { Not Acceptable }
  (h: 407; c: $47), { Proxy Authentication required }
  (h: 408; c: $48), { Request Timeout }
  (h: 409; c: $49), { Conflict }
  (h: 410; c: $4A), { Gone }
  (h: 411; c: $4B), { Length Required }
  (h: 412; c: $4C), { Precondition failed }
  (h: 413; c: $4D), { Request entity too large }
  (h: 414; c: $4E), { Request-URI too large }
  (h: 415; c: $4F), { Unsupported media type }
  (h: 416; c: $50), { Requested Range Not Satisfiable }
  (h: 417; c: $51), { Expectation Failed }
  (h: 500; c: $60), { Internal Server Error }
  (h: 501; c: $61), { Not Implemented }
  (h: 502; c: $62), { Bad Gateway }
  (h: 503; c: $63), { Service Unavailable }
  (h: 504; c: $64), { Gateway Timeout }
  (h: 505; c: $65)  { HTTP version not supported }
);

{ In conformance to WAP WSP Capability Encoding, Appendix A, Table 37. Capability Assignments }
const
  WAP_CAPABILITY_MIN = 0;
  WAPCAP_CLIENT_SDU_SIZE = 0;
  WAPCAP_SERVER_SDU_SIZE = 1;
  WAPCAP_PROTOCOLOPTIONS = 2;
  WAPCAP_METHOD_MOR      = 3;
  WAPCAP_PUSH_MOR        = 4;
  WAPCAP_EXTENDEDMETHODS = 5;
  WAPCAP_HEADERCODEPAGES = 6;
  WAPCAP_ALIASES         = 7;
  WAPCAP_CLIENT_MSG_SIZE = 8;
  WAPCAP_SERVER_MSG_SIZE = 9;
  WAP_CAPABILITY_MAX = $09;

  WAPCapabilityTable: array[WAP_CAPABILITY_MIN..WAP_CAPABILITY_MAX] of String[19] = (
    'Client-SDU-Size', 'Server-SDU-Size', 'Protocol Options', 'Method-MOR', 'Push-MOR',
    'Extended Methods', 'Header Code Pages', 'Aliases', 'Client-Message-Size',
    'Server-Message-Size');

const
{ In conformance to WAP WSP, Appendix A, Table 38. Well-Known Parameter Assignments }

{ Header field name names, no mnemonic provided yet }
  WAP_HTTPPARAMETERNAME_MIN = 0;
  WAP_HTTPPARAMETERNAME_MAX = $1D;

  { Marked with
    *1 : These numbers have been deprecated and should not be used.
  }
  WAPParameterNameTable: array[WAP_HTTPPARAMETERNAME_MIN..WAP_HTTPPARAMETERNAME_MAX] of String[17] = (
{ ver 1.1 }
  'Q',            // Q-value
  'Charset',      // Well-known-charset
  'Level',        // Version-value
  'Type',         //  Integer-value
  '',
  'Name',         // *1 Text-string
  'Filename',     // *1 Text-string
  'Differences',  // Field-name
  'Padding',      // Short-integer
{ ver 1.2 }
  'Type',         //  when used as parameter of Content-Type: 'multipart/related' Constrained-encoding
  'Start',        // *1 (with 'multipart/related) Text-string
  'Start-info',   // *1 (with 'multipart/related) Text-string
{ ver 1.3 }
  'Comment',      // *1 Text-string
  'Domain',       // *1 Text-string
  'Max-Age',      // Delta-seconds-value
  'Path',         // *1 Text-string
  'Secure',       // No-value
{ ver 1.4 }
  'SEC',          // (when used as parameter of Content-Type: Application/vnd.wap.connectivity-wbxml Short-integer
  'MAC',          // (when used as parameter of Content-Type: Application/vnd.wap.connectivity-wbxml) Text-value
  'Creation-date',// Date-value
  'Modification-date',    //Date-value
  'Read-date',    // Date-value
  'Size',         // Integer-value
  'Name',         // Text-value
  'Filename',     // Text-value
  'Start',        // (with multipart/related) Text-value
  'Start-info',   // (with multipart/related) Text-value
  'Comment',      // Text-value
  'Domain',       // Text-value
  'Path'          // Text-value
);

{ In conformance to WAP WSP, Appendix A, Table 39. Header Field Name Assignments }

{ Header field name names, no mnemonic provided yet }
  WML_HTTPHEADERFIELD_MIN = 0;
  WML_HTTPHEADERFIELD_MAX = $47;

  WML_HTTPHEADERFIELD_LAST_VER_11 = $2E;
  WML_HTTPHEADERFIELD_LAST_VER_12 = $37;
  WML_HTTPHEADERFIELD_LAST_VER_13 = $43;
  WML_HTTPHEADERFIELD_LAST_VER_14 = WML_HTTPHEADERFIELD_MAX;
  { Marked with
    *1 : These numbers have been deprecated and should only be supported for backward compatibility purpose
  }
  HTTPHeaderFieldNameTable: array[WML_HTTPHEADERFIELD_MIN..WML_HTTPHEADERFIELD_MAX] of String[20] = (
{ version 1.1+ }
    'Accept', 'Accept-Charset', { *1 } 'Accept-Encoding', { *1 } 'Accept-Language',
    'Accept-Ranges', 'Age', 'Allow', 'Authorization',
    'Cache-Control', { *1 } 'Connection', 'Content-Base', { *1 } 'Content-Encoding',
    'Content-Language', 'Content-Length', 'Content-Location', 'Content-MD5',
    'Content-Range', { *1 } 'Content-Type', 'Date', 'Etag', 'Expires', 'From',
    'Host', 'If-Modified-Since', 'If-Match', 'If-None-Match', 'If-Range',
    'If-Unmodified-Since', 'Location', 'Last-Modified', 'Max-Forwards',
    'Pragma', 'Proxy-Authenticate', 'Proxy-Authorization', 'Public',
    'Range', 'Referer', 'Retry-After', 'Server', 'Transfer-Encoding',
    'Upgrade', 'User-Agent', 'Vary', 'Via', 'Warning', 'WWW-Authenticate',
    'Content-Disposition', { *1 }
{ version 1.2+ }
    'X-Wap-Application-Id', 'X-Wap-Content-URI',
    'X-Wap-Initiator-URI', 'Accept-Application', 'Bearer-Indication',
    'Push-Flag', 'Profile', 'Profile-Diff', 'Profile-Warning', { *1 }
{ version 1.3+ }
    'Expect', 'TE', 'Trailer', 'Accept-Charset', 'Accept-Encoding', 'Cache-Control', { *1 }
    'Content-Range', 'X-Wap-Tod', 'Content-ID', 'Set-Cookie', 'Cookie', 'Encoding-Version',
{ version 1.4+ }
    'Profile-Warning', 'Content-Disposition', 'X-WAP-Security', 'Cache-Control'
);

{------- In conformance to WAP WSP, Appendix A, Table 40 ----------------------}
{  Note: WAP-230-WSP-20010705-a, this table is managed by the WAP Forum Naming Authority (WINA).
   Please refer to http://www.wapforum.org/wina for more details.
}
{ HTTP Content type names, no mnemonic provided yet }
  WML_HTTPCONTENTTYPE_MIN = 0;
  WML_HTTPCONTENTTYPE_text_plain = 3;
  WML_HTTPCONTENTTYPE_text_vnd_wap_wml = 8;
  WML_HTTPCONTENTTYPE_application_vnd_wap_wmlc = 20;
  WML_HTTPCONTENTTYPE_image_vnd_wap_wbmp = 33;
  WML_HTTPCONTENTTYPE_text = 1;
  WML_HTTPCONTENTTYPE_text_last = 10;
  WML_HTTPCONTENTTYPE_application = 16;
  WML_HTTPCONTENTTYPE_MAX = $34;

  HTTPContentTypeTable: array[WML_HTTPCONTENTTYPE_MIN..WML_HTTPCONTENTTYPE_MAX] of String[50] = (
    '*/*', 'text/*', 'text/html', 'text/plain',
    'text/x-hdml', 'text/x-ttml', 'text/x-vCalender',
    'text/x-vCard', 'text/vnd.wap.wml', 'text/vnd.wap.wmlscript',
    'text/vnd.wap.channel',
{11}'Multipart/*', 'Multipart/mixed',
    'Multipart/form-data', 'Multipart/byteranges', 'multipart/alternative',
{16}'application/*', 'application/java-vm',
    'application/x-www-form-urlencoded', 'application/x-hdmlc',
    'application/vnd.wap.wmlc',
    'application/vnd.wap.wmlscriptc', 'application/vnd.wap.channelc',
    'application/vnd.wap.uaprof',
    'application/vnd.wap.wtls-ca-certificate',
    'application/vnd.wap.wtls-user-certificate',
    'application/x-x509-ca-cert', 'application/x-x509-user-cert',
    'image/*', 'image/gif', 'image/jpeg', 'image/tiff', 'image/png',
    'image/vnd.wap.wbmp', 'application/vnd.wap.multipart.*',
    'application/vnd.wap.multipart.mixed',
    'application/vnd.wap.multipart.form-data',
    'application/vnd.wap.multipart.byteranges',
    'application/vnd.wap.multipart.alternative', 'application/xml',
    'text/xml', 'application/vnd.wap.wbxml',
    'application/x-x968-cross-cert', 'application/x-x968-ca-cert',
    'application/x-user-cert', 'text/vnd.wap.si',
    'application/vnd.wap.sic', 'text/vnd.wap.sl',
    'application/vnd.wap.slc', 'text/vnd.wap.co',
    'application/vnd.wap.coc',
    'application/vnd.wap.multipart.related',
    'application/vnd.wap.sia');

{-------  WAP-230-WSP-20010705-a, Table 41. ISO 639 Language Assignments ------}

const
  LANGDEF_FIRST    = 0;  { note: 0 and $80 numbers are reserved in new wml versions }
  LANGDEF_LAST     = $8C;

type
  // ISO 639 language codes, ISO Language name (full language name), domain (short language name)
  TLangDef = packed record
    d: String[2];
    n: String[14];
  end;

  TLangDefs = array [LANGDEF_FIRST..LANGDEF_LAST] of TLangDef;

const
  LangDef: TLangDefs = (
{ $00} (d: ''; n: ''), { shifted in new wml to bangla, no language associated with 0 }
{ $01} (d: 'aa'; n: 'Afar'),
{ $02} (d: 'ab'; n: 'Abkhazian'),
{ $03} (d: 'af'; n: 'Afrikaans'),
{ $04} (d: 'am'; n: 'Amharic'),
{ $05} (d: 'ar'; n: 'Arabic'),
{ $06} (d: 'as'; n: 'Assamese'),
{ $07} (d: 'ay'; n: 'Aymara'),
{ $08} (d: 'az'; n: 'Azerbaijani'),
{ $09} (d: 'ba'; n: 'Bashkir'),
{ $0A} (d: 'be'; n: 'Byelorussian'),
{ $0B} (d: 'bg'; n: 'Bulgarian'),
{ $0C} (d: 'bh'; n: 'Bihari'),
{ $0D} (d: 'bi'; n: 'Bislama'),
{ $0E} (d: 'bn'; n: 'Bengali;Bangla'),
{ $0F} (d: 'bo'; n: 'Tibetan'),
{ $10} (d: 'br'; n: 'Breton'),
{ $11} (d: 'ca'; n: 'Catalan'),
{ $12} (d: 'co'; n: 'Corsican'),
{ $13} (d: 'cs'; n: 'Czech'),
{ $14} (d: 'cy'; n: 'Welsh'),
{ $15} (d: 'da'; n: 'Danish'),
{ $16} (d: 'de'; n: 'German'),
{ $17} (d: 'dz'; n: 'Bhutani'),
{ $18} (d: 'el'; n: 'Greek'),
{ $19} (d: 'en'; n: 'English'),
{ $1A} (d: 'eo'; n: 'Esperanto'),
{ $1B} (d: 'es'; n: 'Spanish'),
{ $1C} (d: 'et'; n: 'Estonian'),
{ $1D} (d: 'eu'; n: 'Basque'),
{ $1E} (d: 'fa'; n: 'Persian'),
{ $1F} (d: 'fi'; n: 'Finnish'),
{ $20} (d: 'fj'; n: 'Fiji'),
{ $21} (d: 'ur'; n: 'Urdu'),
{ $22} (d: 'fr'; n: 'French'),
{ $23} (d: 'uz'; n: 'Uzbek'),
{ $24} (d: 'ga'; n: 'Irish'),
{ $25} (d: 'gd'; n: 'ScotsGaelic'),
{ $26} (d: 'gl'; n: 'Galician'),
{ $27} (d: 'gn'; n: 'Guarani'),
{ $28} (d: 'gu'; n: 'Gujarati'),
{ $29} (d: 'ha'; n: 'Hausa'),
{ $2A} (d: 'he'; n: 'Hebrew'),
{ $2B} (d: 'hi'; n: 'Hindi'),
{ $2C} (d: 'hr'; n: 'Croatian'),
{ $2D} (d: 'hu'; n: 'Hungarian'),
{ $2E} (d: 'hy'; n: 'Armenian'),
{ $2F} (d: 'vi'; n: 'Vietnamese'),
{ $30} (d: 'id'; n: 'Indonesian'),
{ $31} (d: 'wo'; n: 'Wolof'),
{ $32} (d: 'xh'; n: 'Xhosa'),
{ $33} (d: 'is'; n: 'Icelandic'),
{ $34} (d: 'it'; n: 'Italian'),
{ $35} (d: 'yo'; n: 'Yoruba'),
{ $36} (d: 'ja'; n: 'Japanese'),
{ $37} (d: 'jw'; n: 'Javanese'),
{ $38} (d: 'ka'; n: 'Georgian'),
{ $39} (d: 'kk'; n: 'Kazakh'),
{ $3A} (d: 'za'; n: 'Zhuang'),
{ $3B} (d: 'km'; n: 'Cambodian'),
{ $3C} (d: 'kn'; n: 'Kannada'),
{ $3D} (d: 'ko'; n: 'Korean'),
{ $3E} (d: 'ks'; n: 'Kashmiri'),
{ $3F} (d: 'ku'; n: 'Kurdish'),
{ $40} (d: 'ky'; n: 'Kirghiz'),
{ $41} (d: 'zh'; n: 'Chinese'),
{ $42} (d: 'ln'; n: 'Lingala'),
{ $43} (d: 'lo'; n: 'Laothian'),
{ $44} (d: 'lt'; n: 'Lithuanian'),
{ $45} (d: 'lv'; n: 'Latvian'),  { ,Lettish }
{ $46} (d: 'mg'; n: 'Malagasy'),
{ $47} (d: 'mi'; n: 'Maori'),
{ $48} (d: 'mk'; n: 'Macedonian'),
{ $49} (d: 'ml'; n: 'Malayalam'),
{ $4A} (d: 'mn'; n: 'Mongolian'),
{ $4B} (d: 'mo'; n: 'Moldavian'),
{ $4C} (d: 'mr'; n: 'Marathi'),
{ $4D} (d: 'ms'; n: 'Malay'),
{ $4E} (d: 'mt'; n: 'Maltese'),
{ $4F} (d: 'my'; n: 'Burmese'),
{ $50} (d: 'uk'; n: 'Ukrainian'),
{ $51} (d: 'ne'; n: 'Nepali'),
{ $52} (d: 'nl'; n: 'Dutch'),
{ $53} (d: 'no'; n: 'Norwegian'),
{ $54} (d: 'oc'; n: 'Occitan'),
{ $55} (d: 'om'; n: '(Afan)Oromo'),
{ $56} (d: 'or'; n: 'Oriya'),
{ $57} (d: 'pa'; n: 'Punjabi'),
{ $58} (d: 'po'; n: 'Polish'),
{ $59} (d: 'ps'; n: 'Pashto,Pushto'),
{ $5A} (d: 'pt'; n: 'Portuguese'),
{ $5B} (d: 'qu'; n: 'Quechua'),
{ $5C} (d: 'zu'; n: 'Zulu'),
{ $5D} (d: 'rn'; n: 'Kirundi'),
{ $5E} (d: 'ro'; n: 'Romanian'),
{ $5F} (d: 'ru'; n: 'Russian'),
{ $60} (d: 'rw'; n: 'Kinyarwanda'),
{ $61} (d: 'sa'; n: 'Sanskrit'),
{ $62} (d: 'sd'; n: 'Sindhi'),
{ $63} (d: 'sg'; n: 'Sangho'),
{ $64} (d: 'sh'; n: 'Serbo-Croatian'),
{ $65} (d: 'si'; n: 'Sinhalese'),
{ $66} (d: 'sk'; n: 'Slovak'),
{ $67} (d: 'sl'; n: 'Slovenian'),
{ $68} (d: 'sm'; n: 'Samoan'),
{ $69} (d: 'sn'; n: 'Shona'),
{ $6A} (d: 'so'; n: 'Somali'),
{ $6B} (d: 'sq'; n: 'Albanian'),
{ $6C} (d: 'sr'; n: 'Serbian'),
{ $6D} (d: 'ss'; n: 'Siswati'),
{ $6E} (d: 'st'; n: 'Sesotho'),
{ $6F} (d: 'su'; n: 'Sundanese'),
{ $70} (d: 'sv'; n: 'Swedish'),
{ $71} (d: 'sw'; n: 'Swahili'),
{ $72} (d: 'ta'; n: 'Tamil'),
{ $73} (d: 'te'; n: 'Telugu'),
{ $74} (d: 'tg'; n: 'Tajik'),
{ $75} (d: 'th'; n: 'Thai'),
{ $76} (d: 'ti'; n: 'Tigrinya'),
{ $77} (d: 'tk'; n: 'Turkmen'),
{ $78} (d: 'tl'; n: 'Tagalog'),
{ $79} (d: 'tn'; n: 'Setswana'),
{ $7A} (d: 'to'; n: 'Tonga'),
{ $7B} (d: 'tr'; n: 'Turkish'),
{ $7C} (d: 'ts'; n: 'Tsonga'),
{ $7D} (d: 'tt'; n: 'Tatar'),
{ $7E} (d: 'tw'; n: 'Twi'),
{ $7F} (d: 'ug'; n: 'Uighur'),
{ $80} (d: ''; n: ''), { special case, reserved }
{ $81} (d: 'na'; n: 'Nauru'),
{ $82} (d: 'fo'; n: 'Faeroese'),
{ $83} (d: 'fy'; n: 'Frisian'),
{ $84} (d: 'ia'; n: 'Interlingua'),
{ $85} (d: 'vo'; n: 'Volapuk'),
{ $86} (d: 'ie'; n: 'Interlingue'),
{ $87} (d: 'ik'; n: 'Inupiak'),
{ $88} (d: 'yi'; n: 'Yiddish'),
{ $89} (d: 'iu'; n: 'Inuktitut'),
{ $8A} (d: 'kl'; n: 'Greenlandic'),
{ $8B} (d: 'la'; n: 'Latin'),
{ $8C} (d: 'rm'; n: 'Rhaeto-Romance')
);

{--------  WAP-230-WSP-20010705-a, Table 42. Character Set Assignment ---------}
{ Full set: ftp://ftp.isi.edu/in-notes/iana/assignments/character-sets }
const
  CHARSETDEF_FIRST = 0;
  CHARSETDEF_LAST  = 14 + 9;  // 15 standard and 9 non-standard (24)

type
  // ISO Language charset code and description
  TCharSetDef = packed record
    c: Word;
    n: String[16];
  end;

  TCharsetDefs = array [CHARSETDEF_FIRST..CHARSETDEF_LAST] of TCharSetDef;

const
  csusascii         = $3;
  csiso8859_1       = $4;  // Latin-1
  csiso8859_2       = $5;  // Latin-2
  csiso8859_3       = $6;  // Latin-3
  csiso8859_4       = $7;  // Latin-4
  csiso8859_5       = $8;  // Cyrillic
  csiso8859_6       = $9;  // Arabic
  csiso8859_7       = $A;  // Greek
  csiso8859_8       = $B;  // Hebrew
  csiso8859_9       = $C;  // Latin-6
{ Sep 2004, added 9 non-standard codes }
  csiso8859_10      = $D;  // Latin-6
  csiso8859_13      = $E;  // Latin-7
  csiso8859_14      = $F;  // Latin-8
  csiso8859_15      = $10; // Latin-9
  csKOI8R           = $80; // KOI8-R
  cs10000_MacRoman  = $81; // cp10000_MacRoman
  csWindows1250     = $82; // Windows-1250
  csWindows1251     = $83; // Windows-1251
  csWindows1252     = $84; // Windows-1252
{}
  csshift_JIS       = $11;
  csiso10646_ucs_2  = 1000;
  csbig5            = 2026;
  csUTF8            = $6A;

  CharSetDef: TCharsetDefs = (
  (c: $07EA; n: 'big5'),            { IANA MIBEnum value 2026 }
  (c: $03E8; n: 'iso-10646-ucs-2'), { IANA MIBEnum value 1000 }
  (c: $3;   n: 'us-ascii'),
  (c: $4;   n: 'iso-8859-1'),
  (c: $5;   n: 'iso-8859-2'),
  (c: $6;   n: 'iso-8859-3'),
  (c: $7;   n: 'iso-8859-4'),
  (c: $8;   n: 'iso-8859-5'),
  (c: $9;   n: 'iso-8859-6'),
  (c: $A;   n: 'iso-8859-7'),
  (c: $B;   n: 'iso-8859-8'),
  (c: $C;   n: 'iso-8859-9'),
{ Sep 2004, added 9 non-standard codes }
  (c: $D;   n: 'iso-8859-10'),      // Latin-6
  (c: $E;   n: 'iso-8859-13'),      // Latin-7
  (c: $F;   n: 'iso-8859-14'),      // Latin-8
  (c: $10;  n: 'iso-8859-15'),      // Latin-9

  (c: $80;  n: 'KOI8-R'),           // KOI8-R
  (c: $81;  n: 'cp10000_MacRoman'), // cp10000_MacRoman
  (c: $82;  n: 'Windows-1250'),     // Windows-1250
  (c: $83;  n: 'Windows-1251'),     // Windows-1251
  (c: $84;  n: 'Windows-1252'),     // Windows-1252
{}
  (c: $11;  n: 'shift_JIS'),

  (c: $6A;  n: 'utf-8'),            // default
  (c: 0; n: '*')                  { 128 add-one, any character set }
  );

{
function cp1252ToUTF16Char(const P: Char): WideChar;     //

}
{--------  WAP-230-WSP-20010705-a, Table 43. Warning Code Assignments ---------}
{ The warning code encodings are chosen to be compatible with older specifications of the HTTP protocol. If a gateway
  receives two-digit warning codes from a server that follows an older specification, it MAY use them directly without
  referring to this table.
}
  // ISO Language charset code and description
type
  TWarningCodeDef = packed record
    c: Word;
    b: Byte;
    // n: String[16];
  end;

  TWarningCodeDefs = array [0..6] of TWarningCodeDef;

const
  WarningCodeDefs: TWarningCodeDefs = (
  (c: 110; b: 10),            { Response is stale }
  (c: 111; b: 11),            { Revalidation failed }
  (c: 112; b: 12),            { Disconnected operation }
  (c: 113; b: 10),            { Heuristic expiration }
  (c: 199; b: 99),            { Miscellaneous warning }
  (c: 214; b: 14),            { Transformation applied }
  (c: 299; b: 99));           { Miscellaneous persistent warning }
{Codes 199 and 299 have the same assigned number in order to maintain compatibility with previous specifications. }

type
  TWMLCustomParser = class (TPersistent)
  private
    FLevel: Integer;
    FInStream,
    FOutStream: TStream;
    function ReadMB: Integer;
    // function WriteB(AValue: Byte): Integer;
    function WriteMB(AValue: Integer): Integer;  // return bytes written
    procedure BlockIndent;
    function GetStringByRef(ARef: Integer): WideString;
    function DecodeCharSet(const S: String): WideString;
  protected
    FxmlVersion,
    FVersion,
    FPublicId,
    FEncodingCharsetCode: Integer;
    FstringTable: String;
    FOnError: TReportEvent;
    procedure Execute; virtual; abstract;  // recursive
  public
    constructor Create(AInStream, AOutStream: TStream);
    destructor Destroy; override;
    procedure Start; virtual;
    property OutStream: TStream read FOutStream;
    property OnError: TReportEvent read FOnError write FOnError;
  end;

  // some of FOnError: TParseErrorEvent useful implementations
  // abstract class
  TParseErrorHandler = class(TPersistent)
  public
    procedure ErrorHandler(ALevel: TReportLevel; AxmlElement: TxmlElement;
      const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar; var AContinueParse: Boolean;
      AEnv: Pointer); virtual; abstract;
  end;

  TErrorHandlerInStrings = class(TParseErrorHandler)
  private
    FStrings: TWideStrings;
  public
    procedure ErrorHandler(ALevel: TReportLevel; AxmlElement: TxmlElement;
      const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar; var AContinueParse: Boolean;
      AEnv: Pointer); override;
    constructor Create;
    destructor Destroy; override;
    property ErrorList: TWideStrings read FStrings;
  end;

  { parse compiled wmlc
  }
  TWMLCParser = class (TWMLCustomParser)
  private
    FInFlow: Boolean;
    procedure parseAttributes;
    procedure parseValueAttributes;
    procedure parseString;
  protected
    FIndentSpaces: Integer;
    FWideBuf: WideString;
    procedure Execute; override; // recursive
  public
    constructor Create(AInStream, AOutStream: TStream; AIndentSpaces: Integer);
    destructor Destroy; override;
    procedure Start; override;
    property Version: Integer read FVersion;
    property PublicId: Integer read FPublicId;
    property EncodingCharsetCode: Integer read FEncodingCharsetCode;
  end;

function WML_TAG_DESC(a: Integer): String;
function WML_SATTR_DESC(a: Integer): String;
function WML_VATTR_DESC(a: Integer): String;

{ DecompileWMLCString parse compiled wml Awmlc and return wml source text
  Parameters:
    Awmlc        - compiled wmlc
    ABlockIndent - block indent in spaces
    AErrorsDesc  returns description of errors or '' if no errors was detected
}
function DecompileWMLCString(const Awmlc: String; ABlockIndent: Integer;
  var AErrorsDesc: String; var AEncoding, AWBXMLVersion, APublicId: Integer): WideString;

type

  TWMLCCompiler = class (TWMLCustomParser)
  private
    FInternalWMLObject: Boolean;
    procedure compileAttributes(AxmlElement: TxmlElement);
    procedure compileString(const AValue: WideString);
    procedure CompileTagStart(var AxmlElement: TxmlElement); // recursive
    procedure CompileTagFinish(var AxmlElement: TxmlElement); // recursive
  protected
    FxmlCollection: TxmlElementCollection;
    FBuf: String;
    procedure Execute; override; // this method in TWMLCCompiler never used
  public
    // AWBXMLVersion < 0 - set to appropriate WBXML version to wml version used in collection
    constructor Create(AWBXMLVersion: Integer; AxmlCollection: TxmlElementCollection; AOutStream: TStream); overload;
    constructor Create(AWBXMLVersion: Integer; ASrc: WideString; AOutStream: TStream); overload;
    destructor Destroy; override;
    procedure Start; override;
    property Version: Integer write FVersion;
    property PublicId: Integer write FPublicId;
    property EncodingCharsetCode: Integer write FEncodingCharsetCode;
  end;

{ CompileWMLC compile wmlc from wml object
  Parameters:
    AWBXMLVersion: 0, 1, 2, 3. <0- set wbxml version according to wml version
    AWMLCollection - wml object to compile
    AErrorsDesc  returns description of errors or '' if no errors was detected
}
function CompileWMLC(AWBXMLVersion: Integer; AxmlCollection: TxmlElementCollection; AErrorsDesc: TWideStrings): String;

{ CompileWMLCString compile wmlc from wml source text
  Parameters:
    AWBXMLVersion: 0, 1, 2, 3. <0- set wbxml version according to wml version
    AWML           - wml source (unicode) to compile
    AErrorsDesc      returns description of errors or '' if no errors was detected
}
function CompileWMLCString(AWBXMLVersion: Integer; const Awml: WideString; AErrorsDesc: TWideStrings): String;

resourcestring
  MSG_UNKOWNATTRIBUTE = '[wbxml] unknown attribute "%s" (or value) in element <%s>: %s';
  MSG_UNKNOWNTAG      = '[wbxml] unknown element %s';
  MSG_PARSING_INTERRUPTED = '[process interrupted with errors]';

{------------------------- WBXML public id routines ---------------------------}

{ GetPublicIdByWMLVersionStr
  Parameters:
    AWMLVersion: wml version string '1.0', '1.1', '1.2', '1.3'
  Return:
    WBXML public id: 2- wml1.0 4- wml1.1 9-wml1.2 A- wml1.3  0- special string identifier
}
function GetPublicIdByWMLVersionStr(const AWMLVersion: String): Integer;

{------------------ string with variables compiker routines -------------------}

{ compile string and var
  Parameters:
    AEncodingCharsetCode: encoding charset code
    AValue: string to compile
  Return:
    compiled string with inline variable
}
function compileVString(AEncodingCharsetCode: Integer; const AValue: WideString): String;

{----------------- HTTP Content Type WAP byte code routines -------------------}

{ Translates between HTTP Content type and WAP code.
  Parameters:
    AContentTypeName: HTTP Content type (case-sensitive)
  Return:
    encoded WAP Content type, -1 if error
}
function GetHTTPContentTypeCode(const AContentTypeName: String): Integer;

{------------------ WSP protocol capabilities routines ------------------------}
type
  TWSPProtocolOption = (wsppConfirmedPushFacility, wsppPushFacility,
    wsppSessionResumeFacility, wsppAcknowledgementHeaders, wsppLargeDataTransfer);
  TWSPProtocolOptions = set of TWSPProtocolOption;

function WSPProtocolOptions2Set(AFlags: Cardinal): TWSPProtocolOptions;
function WSPSet2ProtocolOptions(AWSPProtocolOptions: TWSPProtocolOptions): Cardinal;

type
  TExtendedMethods = TStringList;
  THeaderCodePages = TStringList;

  TWapCapabilities = class(TPersistent)
  private
    FClientSDUSize: Integer;
    FServerSDUSize: Integer;
    FProtocolOptions: TWSPProtocolOptions;
    FMethodMOR: Integer;
    FPushMOR: Integer;
    FExtendedMethods: TExtendedMethods;
    FHeaderCodePages: THeaderCodePages;
    FAliases: TStrings;
    FClientMsgSize: Integer;
    FServerMsgSize: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddByCode(ACode: Integer; const AValueN: Cardinal; const AValueS: String);
    procedure Clear;
  published
    property ClientSDUSize: Integer read FClientSDUSize write FClientSDUSize;
    property ServerSDUSize: Integer read FServerSDUSize write FServerSDUSize;
    property ProtocolOptions: TWSPProtocolOptions read FProtocolOptions write FProtocolOptions;
    property MethodMOR: Integer read FMethodMOR write FMethodMOR ;
    property PushMOR: Integer read FPushMOR write FPushMOR;
    property ExtendedMethods: TExtendedMethods read FExtendedMethods;
    property HeaderCodePages: THeaderCodePages read FHeaderCodePages;
    property Aliases: TStrings read FAliases;
    property ClientMsgSize: Integer read FClientMsgSize write FClientMsgSize;
    property ServerMsgSize: Integer read FServerMsgSize write FServerMsgSize;
  end;

{ Parameters:
    ACapabilityCode: code
  Return
    capability string, empty string if error.
 }
function getCapabilityName(ACapabilityCode: Integer): String;

{ Parameters:
    ACapabilityName: name of capability
  Return:
    encoded capability code, -1 if error
}
function GetCapabilityCode(const ACapabilityName: String): Integer;

{ Translates between WAP encoded header and HTTP header.
  Parameters:
    AHTTPContentTypeWAPCode: Encoded WAP Content type.
  Return
    HTTP Content type, empty string if error.
 }
function getHTTPContentTypeName(AHTTPContentTypeWAPCode: Integer): String;

{-------- HTTP header field name conversion to WAP byte code routines ---------}

{ Translates between HTTP Content type and WAP code.
  Parameters:
    AHeaderFieldName: HTTP header field name (case-sensitive)
  Return:
    WAP header field number, -1 if error
}
function GetHTTPHeaderFieldCode(const AHeaderFieldName: String; const AVersion: String = DEFAULT_WMLC_ENCODING_VERSION): Integer;

{ Translates between WAP encoded header and HTTP header.
  Parameters:
    AHTTPHeaderFieldWAPCode: WAP header field number
  Return
    header field name, empty string if error.
 }
function getHTTPHeaderFieldName(AHTTPHeaderFieldWAPCode: Integer): String;

{----- ISO  639 Language assignments conversion to WAP byte code routines -----}

{ Translates between WAP encoded language ISO 639 number to full name of language
  Parameters:
    ALangCode: WAP language number
  Return
    full english name of language by ISO 639 code,
    '' if not defined
 }
function LangCode2Name(ALangCode: Integer): String;

{ Translates between full name of language to WAP encoded ISO 639 number of language
  Parameters:
    ALangName: full english name of language
  Return
    ISO 639 language code
    -1 if not defined
 }
function LangName2Code(const ALangName: String): Integer;

{ Translates between WAP encoded language ISO 639 number to short name of language
  Parameters:
    ALangCode: WAP language number
  Return
    short english name of language by ISO 639 code,
    '' if not defined
 }
function LangCode2ShortName(ALangCode: Integer): String;

{ Translates between short name of language to WAP encoded ISO 639 number of language
  Parameters:
    ALangShortName: short english name of language
  Return
    ISO 639 language code
    '' if not defined
 }
function LangShortName2Code(const ALangShortName: String): Integer;

{------------------- IANA encoding character set code routines ----------------}

{ Translates between name of encoding character set to WAP encoded IANA number of character set
  Parameters:
    ACharsetCode: charset number (IANA number of character set)
  Return
    charatcer set name
 }
function CharSetCode2Name(ACharsetCode: Integer): String;

{ Translates between name of encoding character set to WAP encoded IANA number of character set
  Parameters:
    ACharsetName: encoding charatcer set name
  Return
    charset number (IANA number of character set)

    -1 if not defined
 }
function CharSetName2Code(const ACharsetName: String): Integer;

{------------------- HTTP header parameter name code routines -----------------}

{ Translates between name of HTTP header parameter to number of parameter name
  Parameters:
    AParameterNameCode: number of parameter name
  Return
    name of HTTP header parameter
 }
function getParameterName(AParameterNameCode: Integer): String;

{ Translates between number of parameter name to name of HTTP header parameter
  Parameters:
    AParameterName: name of HTTP header parameter
  Return
    number of parameter name
    -1 if not defined
 }
function getParameterCode(const AParameterName: String): Integer;

{------------------- HTTP header parameter name code routines -----------------}

{ Translates between name PDU type number to name
  Parameters:
    APDUTypeCode: number of parameter name
  Return
    name of PDU type
 }
function getPDUTypeName(APDUTypeCode: Integer): String;

{ Translates between number of PDU name to number
  Parameters:
    APDUTypeName: name PDU type
  Return
    number of PDU type
    -1 if not defined
 }
function getPDUTypeCode(const APDUTypeName: String): Integer;


{------------------- HTTP status code routines -----------------}

{ Translates between number to http status code
  Parameters:
    ACode: number of http status
  Return
    HTTP status (200 - OK, etc.)
 }
function getHTTPStatus(ACode: Byte): Integer;

{ Translates between number of PDU name to number
  Parameters:
    AStatus: HTTP status (200 - OK, etc.)
  Return
    number status code
    0- none( reserved) if not defined
 }
function getHTTPStatusCode(const AStatus: Integer): Byte;

{ Content-encoding-value = (Gzip | Compress | Deflate | Token-text)
  Gzip =     #128
  Compress = #129
  Deflate =  #130
  *       =  #131
}
function GetContentEncodingCode(const AContentEncodingStr: String): Integer;
function GetContentEncodingName(AContentEncodingCode: Integer): String;

{ i.e. Accept-Ranges: bytes
  Accept-ranges-value = (None | Bytes | Token-text)
  None = <Octet 128>
  Bytes = <Octet 129>
}
function GetAcceptRange2Code(const AAcceptRangeStr: String): Integer;
function GetAcceptRange2Name(AAcceptRangeCode: Integer): String;

function GetCacheControl2Code(const ACacheControlStr: String): Integer;
function GetCacheControl2Name(ACacheControlCode: Integer): String;

function GetWarning2Code(const AWarningValue: Word): Integer;
function GetWarningCode2Val(AWarningCode: Byte): Integer;


function GetContentDisposition2Code(const AContentDispositionStr: String): Integer;
function GetContentDisposition2Name(AContentDispositionCode: Integer): String;

function GetProfileWarning2Code(AProfileWarningVal: Integer): Integer;
function GetProfileWarning2Val(AProfileWarningCode: Byte): Integer;

function GetTE2Code(const ATEStr: String): Integer;
function GetTE2Name(ATECode: Integer): String;

implementation

type
  BA = packed array [0..1] of Char;

resourcestring
  STR_VAR_ESCAPE = ':escape';
  STR_VAR_UNESCAPE = ':unesc';
  STR_VAR_NOESCAPE = ':noesc';

// Read multibyte value from string, returns value and index to rest of string.
function GetMB(const ABuf; var APosition: Integer; Len: Integer): Integer;
var
  ch: Byte;
begin
  Result:= 0;
  while APosition < Len do begin
    ch:= Byte(BA(ABuf)[APosition]);
    Result:= (Result shl 7) or (ch and $7f);
    Inc(APosition);
    if (ch and $80) = 0
    then Break;
  end;
end;

// Convert value to a multi-byte encoded string.
function MkMb(AValue: Integer): String;
var
  o: Integer;
begin
  Result:= '';
  o:= 1;
  repeat
    Result:= Char((AValue and $7F) or $80) + Result;
    AValue:= AValue shr 7;
    Inc(o);
  until AValue = 0;
  Byte(Result[o-1]):= Byte(Result[o-1]) and $7F; // skip bit 7
end;

function WML_TAG_DESC(a: Integer): String;
begin
  if ((a >= WML_TAGS_MIN) and (a <= WML_TAGS_MAX))
  then Result:= wml_tags[a]
  else Result:= '';
end;

function WML_SATTR_DESC(a: Integer): String;
begin
  if ((a >= WML_SATTR_MIN) and (a <= WML_SATTR_MAX))
  then Result:= wml_start_attributes[a]
  else Result:= ''
end;

function WML_VATTR_DESC(a: Integer): String;
begin
  if ((a >= WML_VATTR_MIN) and (a <= WML_VATTR_MAX))
  then Result:= wml_value_attributes[a]
  else Result:= '';
end;

{ --- TWMLCustomParser implementation --- }

constructor TWMLCustomParser.Create(AInStream, AOutStream: TStream);
begin
  inherited Create;
  FLevel:= 0;
  FOnError:= Nil;
  FInStream:= AInStream;
  FOutStream:= AOutStream;
  FxmlVersion:= 1;
  FVersion:= 1;    // WBXML 1.1
  FPublicId:= 4;   // "-//WAPFORUM//DTD WML 1.1//EN" (WML 1.1)
  FEncodingCharsetCode:= csUTF8;
end;

destructor TWMLCustomParser.Destroy;
begin
  inherited Destroy;
end;

function TWMLCustomParser.DecodeCharSet(const S: String): WideString;
begin
  Result:= CharSet2WideString(FEncodingCharsetCode, S, []);
end;

procedure TWMLCustomParser.BlockIndent;
var
  buf: WideString;
begin
  buf:= DupeString(#32, FLevel);
  FOutStream.Write(buf[1], Length(buf));
end;

function TWMLCustomParser.GetStringByRef(ARef: Integer): WideString;
var
  p: Integer;
begin
  if (Aref < Length(FstringTable)) then begin
    Result:= Copy(FstringTable, Aref + 1, MaxInt);
    p:= Pos(#0, Result);
    if p > 0 then begin
      Dec(p);
      SetLength(Result, p);
    end;
    Result:= DecodeCharSet(Result);
  end else begin
    Result:= '';
  end;
end;

function TWMLCustomParser.ReadMB: Integer;
var
  ch: Byte;
begin
  Result:= 0;
  while (FInStream.Position < FInStream.Size) do begin
    FInStream.ReadBuffer(ch, 1);  // SizeOf(inputchar)
    Result:= (Result shl 7) or (ch and $7f);
    if (ch and $80) = 0
    then Break;
  end;
end;

{ write multi-byte encoded integer AValue to FOutStream
  return bytes written
}
function TWMLCustomParser.WriteMB(AValue: Integer): Integer;
var
  s: String[8];
begin
  s:= '';
  Result:= 1;
  repeat
    s:= Char((AValue and $7F) or $80) + s;
    AValue:= AValue shr 7;
    Inc(Result);
  until AValue = 0;
  Byte(s[Result-1]):= Byte(s[Result-1]) and $7F; // skip bit 7
  FOutStream.WriteBuffer(s[1], Length(s));
end;

{
function TWMLCustomParser.WriteB(AValue: Byte): Integer;
begin
  FOutStream.WriteBuffer(AValue, 1);
  Result:= 1;
end;
}

procedure TWMLCustomParser.Start;
begin
  FstringTable:= '';
end;

{ --- TParseErrorHandler abstract class implementation --- }

{ --- TErrorHandlerInStrings implementation --- }

constructor TErrorHandlerInStrings.Create;
begin
  inherited Create;
  FStrings:= TWideStringList.Create;
end;

destructor TErrorHandlerInStrings.Destroy;
begin
  FStrings.Free;
  inherited Destroy;
end;

procedure TErrorHandlerInStrings.ErrorHandler(ALevel: TReportLevel; AxmlElement: TxmlElement;
  const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar; var AContinueParse: Boolean;
  AEnv: Pointer);
begin
  // skip APosition
  FStrings.AddObject(ADesc, AxmlElement)
end;

{ --- TWMLCParser implementation --- }

constructor TWMLCParser.Create(AInStream, AOutStream: TStream; AIndentSpaces: Integer);
begin
  inherited Create(AInStream, AOutStream);
  FIndentSpaces:= AIndentSpaces;
  FWideBuf:= '';
end;

destructor TWMLCParser.Destroy;
begin
  inherited Destroy;
end;

procedure TWMLCParser.parseString;
var
  ch: Byte;
  buf: String;
  wbuf: WideString;
begin
  buf:= '';
  while (FInStream.Position < FInStream.Size) do begin
    FInStream.ReadBuffer(ch, 1);  // SizeOf(inputchar)
    if ch = WMLC_INLINE_STRING_END
    then Break;
    buf:= buf + Char(ch);
  end;
  wbuf:= DecodeCharSet(buf);
  if Length(wbuf) > 0
  then FOutStream.Write(wbuf[1], Length(wbuf));
end;

procedure TWMLCParser.parseAttributes;
var
  ch: Byte;
  ref: Integer;
  attr, buf: WideString;
begin
  while (FInStream.Position < FInStream.Size) do begin
    FInStream.ReadBuffer(ch, 1);  // SizeOf(inputchar)
    case ch of
      WMLTC_END: begin
          Break;
        end;
      WMLG_STR_T: begin
            ref:= ReadMB;
            buf:= GetStringByRef(ref);
            if Length(buf) > 0 then begin
              FOutStream.Write(buf[1], Length(buf))
            end else begin
              raise Exception.CreateFmt('wmlc parse error: attribute string table entry %d referenced but invalid.',
                [ref]);
            end;
          end;
      else begin
        attr:= WML_SATTR_DESC(ch);
        if Length(attr) = 0 then begin
          raise Exception.CreateFmt('wmlc parse error: expected attribute, got %xh.',
            [ch]);
        end;
        if Pos('"', attr) = 0 then begin
          buf:= Format(' %s="', [attr]);
          FOutStream.Write(buf[1], Length(buf));
          parseValueAttributes;
          buf:= '"';
          FOutStream.Write(buf[1], Length(buf))
        end else begin
          buf:= Format(' %s', [attr]);
          FOutStream.Write(buf[1], Length(buf));
          if (attr[Length(attr)] <> '"') then begin
            parseValueAttributes;
            buf:= '"';
            FOutStream.Write(buf[1], Length(buf))
          end;
        end;
      end; { else case }
    end; { case }
  end; { while }
end; { proc }

function VarEscapeStrSuffix(Ch: Byte): String;
begin
  case (ch and 3) of
    0: Result:= STR_VAR_ESCAPE;
    1: Result:= STR_VAR_UNESCAPE;
    2: Result:= STR_VAR_NOESCAPE;
    else Result:= '';
  end;
end;

procedure TWMLCParser.parseValueAttributes;
var
  ref: Integer;
  ch: Byte;
  buf: WideString;
begin
  while True do begin
    FInStream.ReadBuffer(ch, 1);  // SizeOf(inputchar)
    case ch of
      WMLG_STR_T: begin
          ref:= ReadMB;
          buf:= GetStringByRef(ref);
          if Length(buf) > 0 then begin
            FOutStream.Write(buf[1], Length(buf));
          end else begin
            raise Exception.CreateFmt('wmlc parse error: value attribute string table entry %d referenced but invalid.',
              [ref]);
          end;
        end;
      WMLG_EXT_T_0,  WMLG_EXT_T_1, WMLG_EXT_T_2: begin
          ref:= ReadMB;
          buf:= GetStringByRef(ref);
          if Length(buf) > 0 then begin
            buf:= '$(' + buf;
            FOutStream.Write(buf[1], Length(buf));
            buf:= VarEscapeStrSuffix(ch);
            FOutStream.Write(buf[1], Length(buf));
            buf:= ')';
            FOutStream.Write(buf[1], Length(buf));
          end else begin
            raise Exception.CreateFmt('wmlc parse error: value attribute string table entry %d referenced but invalid.',
              [ref]);
          end;
        end;
      WMLG_EXT_I_0, WMLG_EXT_I_1, WMLG_EXT_I_2: begin
          buf:= '$(';
          FOutStream.Write(buf[1], Length(buf));
          parseString;
          buf:= VarEscapeStrSuffix(ch);
          FOutStream.Write(buf[1], Length(buf));
          buf:= ')';
          FOutStream.Write(buf[1], Length(buf));
        end;
      WMLC_INLINE_STRING: begin
          parseString;
        end;
      else begin
        buf:= WML_VATTR_DESC(ch);
        if Length(buf) > 0 then begin
          FOutStream.Write(buf[1], Length(buf));
        end else begin
          FInStream.Position:= FInStream.Position - 1;
          Exit;
        end;
      end; { else case }
    end; { case }
  end; { while }
end; { proc }

procedure TWMLCParser.Start;
var
  FStringTableLength: Integer;
begin
  inherited Start;
  FInFlow:= False;
  if FInStream.Size - FInStream.Position < 2
  then Exit;
  // read WBXML version (1- WBXML1.1 2- WBXML1.2 3- WBXML1.3)
  FInStream.ReadBuffer(FVersion, 1);  // wbxml version uint8
  // read publicId 4- wml1.1 9-wml1.2 A- wml1.3
  FPublicId:= ReadMB;                 // 1-D; E-7F reserved; see WAP-192-WBXML-20010725-a, Version 1.3,
  if (FPublicId = 0)                  // 0 is special string identifier
  then ReadMB;                        // string table index follows
  if (FVersion < 0) or (FPublicId > $7F) then begin
    // wrong versions
    Exit;
  end;

  FEncodingCharsetCode:= ReadMB;  // AInStream.ReadBuffer(charsetcode, 1); // 6Ah - utf-8

  FstringTableLength:= ReadMB;  //
  if (FstringTableLength > 0) then begin
    SetLength(FstringTable, FstringTableLength);
    FInStream.ReadBuffer(FstringTable[1], FstringTableLength);  // read string table
  end;

  FWideBuf:= Format('<?xml version="%d.0"?>' + WideCRLF, [FxmlVersion]);
  FOutStream.Write(FWideBuf[1], Length(FWideBuf));
  FWideBuf:= Format('<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML %s//EN" "http://www.wapforum.org/DTD/wml_%s.xml">'+WideCRLF,
    ['1.1', '1.1']);
  FOutStream.Write(FWideBuf[1], Length(FWideBuf));
  Execute;
end;

// recursive

procedure TWMLCParser.Execute;
var
  inputchar: Byte;
  isFlowTag: Boolean;
  ref: Integer;
  tag, content, attributes: Integer;
begin
  while (FInStream.Position < FInStream.Size) do begin
    FInStream.ReadBuffer(inputchar, 1);  // SizeOf(inputchar)
  { Codes we can come across at this point could be:
    WMLC_INLINE_STRING - Inline strings
    WMLG_STR_T - String table references
    WMLG_EXT_T_? - Inline variables, a bit like environment variables I think
    WMLG_EXT_I_? - Inline variables but named as inline strings
    Tags
  }
    case inputchar of
      WMLC_INLINE_STRING: begin
          { An inline string. Just print it out. }
//        BlockIndent;
          parseString;
          FInFlow:= True;
        end;
      WMLG_STR_T: begin
          { A string table reference. Find it and print it. }
          ref:= ReadMB;
          if (ref < Length(FstringTable)) then begin
//          BlockIndent;
            FWideBuf:= GetStringByRef(ref);
            FOutStream.Write(FWideBuf[1], Length(FWideBuf));
          end else begin
            raise Exception.CreateFmt('wmlc parse error: string table entry %d referenced but invalid.',
              [ref]);
          end;
          FInFlow:= True;
        end;
      WMLG_EXT_T_0, WMLG_EXT_T_1, WMLG_EXT_T_2: begin
          { A variable reference from the string table. Find, format and print. }
          ref:= ReadMB;
          if (ref < Length(FstringTable)) then begin
//          BlockIndent;
            FWideBuf:= Format('$(%s', [GetStringByRef(ref)]);
            FOutStream.Write(FWideBuf[1], Length(FWideBuf));
            FWideBuf:= VarEscapeStrSuffix(inputchar);
            FOutStream.Write(FWideBuf[1], Length(FWideBuf));
            FWideBuf:= ')';
            FOutStream.Write(FWideBuf[1], Length(FWideBuf));
          end else begin
            raise Exception.CreateFmt('wmlc parse error: string table entry %d referenced but invalid.',
              [ref]);
          end;
          FInFlow:= True;
        end;
      WMLG_EXT_I_0, WMLG_EXT_I_1, WMLG_EXT_I_2: begin
          { A variable reference as an inline string. Format and print. }
//        BlockIndent;
          FWideBuf:= '$(';
          FOutStream.Write(FWideBuf[1], Length(FWideBuf));
          parseString;
          FWideBuf:= VarEscapeStrSuffix(inputchar);
          FOutStream.Write(FWideBuf[1], Length(FWideBuf));
          FWideBuf:= ')';
          FOutStream.Write(FWideBuf[1], Length(FWideBuf));
          FInFlow:= True;
        end;
      else begin
        { A tag. Find out what one and decode. }
        tag:= inputchar and WMLTC_TAG_VALUE;
        content:= inputchar and WMLTC_CONTENT;
        attributes:= inputchar and WMLTC_ATTRIBUTES;

        isFlowTag:= tag in [WMLT_U, WMLT_I, WMLT_B, WMLT_BIG, WMLT_SMALL, WMLT_EM, WMLT_IMG, WMLT_A, WMLT_ANCHOR];

        if inputchar = WMLTC_END
        then Exit;
        if FInFlow and (not isFlowTag) then begin
          FWideBuf:= WideCRLF;
          FOutStream.Write(FWideBuf[1], Length(FWideBuf));
        end;

        FWideBuf:= WML_TAG_DESC(tag);
        if (Length(FWideBuf) = 0) then begin
          raise Exception.CreateFmt('wmlc parse error: expected tag %xh, got %xh.', [inputchar, tag]);
        end;
        if not isFlowTag
        then BlockIndent;
        FWideBuf:= '<' + FWideBuf;
        FOutStream.Write(FWideBuf[1], Length(FWideBuf));
        if (attributes <> 0) then begin
          parseAttributes;
        end;
        // before recirsive call execute
        FInFlow:= isFlowTag;
        if (content <> 0) then begin
          FWideBuf:= '>';
          if not isFlowTag
          then FWideBuf:= FWideBuf + WideCRLF;
          FOutStream.Write(FWideBuf[1], Length(FWideBuf));
          Inc(FLevel, FIndentSpaces);
          Execute;
          Dec(FLevel, FIndentSpaces);
          if not isFlowTag
          then BlockIndent;
          FWideBuf:= Format('</%s>', [WML_TAG_DESC(tag)]);
          if not isFlowTag
          then FWideBuf:= FWideBuf + WideCRLF;

          FOutStream.Write(FWideBuf[1], Length(FWideBuf));
        end else begin
          FWideBuf:= '/>';
          if not isFlowTag then FWideBuf:= FWideBuf + WideCRLF;
          FOutStream.Write(FWideBuf[1], Length(FWideBuf));
        end;
      end; { else case }
    end; { case }
  end; { while }
end;

{ --- TWMLCCompiler implementation --- }

{ search wml_start_attributes for attrStart
  and return index.
  len   - length of returned attribute
}
function getStartAttrIdx(const attr: WideString): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= WML_SATTR_MIN to WML_SATTR_MAX do begin
    if CompareText(wml_start_attributes[i], attr) = 0 then begin
      Result:= i;
      Exit;
    end;
  end;
end;

{ This is rather nasty. There are many attribute tags, but some
can only ever have two values or so and these only exist for
those values. We need to check for those first.
There also tags which take the start portion of an attribute
and follow it with an inline string, such as WMLA_HREF_HTTP
which expands to href="http:// and should be followed by
the rest of the url.

There also many ways of doing things here. Say your attribute
reads: href="http://www.site.com/"
You could compile this to :
WMLS_HREF WMLC_INLINE_STRING "http://www.site.com/" WMLC_INLINE_STRING_END
WMLS_HREF_HTTP WMLC_INLINE_STRING "www.site.com" WMLC_INLINE_STRING_END
WMLS_HREF WMLA_HTTP_WWW WMLC_INLINE_STRING "site.com" WMLC_INLINE_STRING_END
WMLS_HREF WMLA_HTTP_WWW WMLC_INLINE_STRING "site" WMLC_INLINE_STRING_END WMLA_COM
and all are valid. However, we should be aiming for the shortest
bytecode, which is the last option.
At the moment we assume one code for the full attribute or the
attribute name and an inline string as that at least lets it all
compile, even if it's not the most efficient.
}

procedure TWMLCCompiler.compileAttributes(AxmlElement: TxmlElement);
var
  sattrNum: Integer;
  buffer, errs: WideString;
  n, vl: String;
  a: Integer;
  cont: Boolean;
begin
  for a:= 0 to AxmlElement.Attributes.Count - 1 do begin
    n:= AxmlElement.Attributes[a].Name;
    if Length(AxmlElement.Attributes[a].Value) = 0
    then Continue;
    vl:= Unicode2CharSet(FEncodingCharsetCode, AxmlElement.Attributes[a].Value, []);
    // try to find attribute name="value" occurance
    buffer:= Format('%s="%s"', [n, vl]);
    sattrNum:= getStartAttrIdx(buffer);
    if (sattrNum >= 0) then begin
      FBuf:= FBuf + Char(sattrNum);
    end else begin
      // no name="value" occurance, store attribute index and value
      sattrNum:= getStartAttrIdx(n);
      if (sattrNum >= 0) then begin
        FBuf:= FBuf + Char(sattrNum);
	compileString(vl);
      end else begin
        // attribute must have a code
        if Assigned(FOnError) then begin
          cont:= True;
          errs:= Format(MSG_UNKOWNATTRIBUTE, [n, AxmlElement.GetElementName, buffer]);
          FOnError(rlError, AxmlElement, PWideChar(buffer), Length(Buffer), AxmlElement.DrawProperties.TagXYStart,
            PWideChar(errs), cont, Nil);
          if not cont
          then raise Exception.CreateFmt(MSG_PARSING_INTERRUPTED, []);
        end else begin
          raise Exception.CreateFmt(MSG_UNKOWNATTRIBUTE, [n, AxmlElement.GetElementName, buffer]);
        end;
      end;
    end;
  end;
  FBuf:= FBuf + Char(WMLTC_END);
end;

// Writes a variable to the wmlc document
//   varString is the variables string without any $ or parenthesis
function mkVariable(const AvarString: String): String;
var
  colonIndex: Integer;
begin
  Result:= '';
  // add correct global token
  colonIndex:= Pos(':', AvarString);
  // no transformation in cases $(var) or $(var:) (no or wrong character after ':')
  Result:= Char(WMLG_EXT_I_2);
  if (colonIndex > Length(AvarString)) then begin
    case AvarString[colonIndex + 1] of
      'E', 'e': begin
        // escaped, $(var:escape)
        Result:= Char(WMLG_EXT_I_0);
      end;
      'U', 'u': begin
        // unescaped, $(var:unesc)
        Result:= Char(WMLG_EXT_I_1);
      end;
      // 'N', 'n': allready WMLG_EXT_I_2
    end;
  end;
  Result:= Result + AVarString + Char(WMLC_INLINE_STRING_END);
end;

{------------------ string with variables compiler routines -------------------}

{ compile string and var
  Parameters:
    AEncodingCharsetCode: encoding charset code
    AValue: string to compile
  Return:
    compiled string with inline variable
}

function compileVString(AEncodingCharsetCode: Integer; const AValue: WideString): String;
var
  s: String;
  v: string;
  i: Integer;
  textstarted,
  varStarted: Integer;
  varParenthesis: Byte; // 0, 1

  procedure FlushTextOrVar;
  var
    esc: Byte;
    comps: String;
    ci, cL, colonPos: Integer;
  begin
    if varStarted > 0 then begin
      comps:= Copy(s, varstarted + 1, i - varstarted - 1);
      // This is not required- variable name must be look good.
      DeleteDoubledSpaceStr(comps);
      esc:= WMLG_EXT_I_2;
      colonPos:= Pos(':', comps);
      if colonpos > 0 then begin
        // :escaped or :unesc or :n found
        if Length(comps) > colonPos then begin
          case comps[colonpos+1] of
            'E', 'e': esc:= WMLG_EXT_I_0;  // $40 $(var:escape). Escaped name of the variable is inline.
            'U', 'u': esc:= WMLG_EXT_I_1;  // $41 $(var:unesc). Unscaped name of the variable is inline.
          end; { case }
          // delete ':' and all others characters
          Delete(comps, colonPos, MaxInt);
        end;
      end;
      // do not store variable with no name, for example in cases of '$ $' or '$'CRLF'$'
      if Length(comps) > 0 then begin
        Result:= Result + Char(esc) +
          comps +
          Char(WMLC_INLINE_STRING_END);
      end;
      // var flushed
      varStarted:= 0;
      if varParenthesis > 0
      then textStarted:= i + 1
      else textStarted:= i;
      varParenthesis:= 0;
    end else begin
      if (i > textStarted) then begin
        comps:= Copy(s, textstarted, i - textstarted);
        // compact text, delete '$$'
        cL:= Length(comps);
        ci:= 1;
        while (ci <= cL) do begin
          if (comps[ci] <= #32) and (ci + 1 <= cL) and ((comps[ci + 1] <= #32)) then begin
            comps[ci]:= #32;
            Delete(comps, ci + 1, 1);
            Dec(cL);
          end else begin
            if (comps[ci] = '$') and (ci + 1 <= cL) and ((comps[ci + 1] = '$')) then begin
              comps[i]:= '$';
              Delete(comps, ci + 1, 1);
              Dec(cL);
            end else begin
              Inc(ci);
            end;
          end;
        end;

        if (Length(comps) > 0) then begin  // and ( not ((Length(comps) = 1) and (comps[1]<=#32)))
          // do not store none/one space
          Result:= Result + Char(WMLC_INLINE_STRING) + comps + Char(WMLC_INLINE_STRING_END);
        end;
        // text flushed
        textStarted:= i + 1;
      end;
    end;
  end;

begin
  Result:= '';
  varStarted:= 0;
  textStarted:= 1;
  s:= Unicode2CharSet(AEncodingCharsetCode, AValue, []); // + #0; // ?!!
  i:= 1;
  while i <= Length(S) do begin
    case s[i] of
      #0..'#','%'..'''', '*'..'-','/',';'..'@','['..'^','`','{'..#255:
      begin { WideLineSeparator, WideParagraphSeparator }
          if (varStarted > 0) then begin
            if (varParenthesis = 0) then begin
              // store variable if not enclosed in parenthesis
              FlushTextOrVar;
            end;
          end;
        end;
      '$': begin
          if varStarted = 0 then begin
            // variable started
            if (i < Length(s)) and (s[i+1] = '$') then begin
              // sign '$$' escaped. Skip next '$'
              Inc(i);
            end else begin
              // store previous variable not text
              if (varParenthesis = 1) then begin
                // incorrect case: $(var1$var2)-
                // raise no parenthesis ')' found
                // Error: variable name cannot contains '$' sign
              end else begin
                // case of $var1$var2
                // store previous variable
                FlushTextOrVar;
                // new variable started
                varStarted:= i;
                // indicate that new varible is not enclosed in parenthesis yet
                varParenthesis:= 0;
                // clear name of variable
                v:= '';
              end;
            end;
          end;
        end;
      '(': begin
            if (varStarted + 1 = i) then begin
              // variable started with '('
              varParenthesis:= i;
              varstarted:= i;
            end else begin
              if varStarted = 0
              then // Inc(textStarted) // text contains '('
              else Inc(varStarted); // incorrect case: $var(1
            end;
        end;
      ')': begin
            if (varStarted > 0) then begin
              // variable is enclosed with ')'
              // store variable
              FlushTextOrVar;
            end else begin
              // incorrect case: $)var1
            end;
        end;
      else begin
        end;
    end; { case }
    Inc(i);
  end; { for }
  FlushTextOrVar;
end;

procedure TWMLCCompiler.compileString(const AValue: WideString);
begin
  FBuf:= FBuf + compileVString(FEncodingCharsetCode, AValue);
end;

// constructor takes wml elements collection
constructor TWMLCCompiler.Create(AWBXMLVersion: Integer; AxmlCollection: TxmlElementCollection; AOutStream: TStream);
begin
  FInternalWMLObject:= False;
  inherited Create(Nil, AOutStream);
  FxmlCollection:= AxmlCollection;
  // Set publicId 2- wml1.0 4- wml1.1 9-wml1.2 A- wml1.3  0- special string identifier
  if AxmlCollection.Count > 0 then begin
    FPublicID:= GetPublicIdByWMLVersionStr(AxmlCollection.Items[0].DTDVersion)
  end else FPublicID:= 0;

  // Set the WBXML version number (1- WBXML1.1 2- WBXML1.2 3- WBXML1.3)
  if AWBXMLVersion < 0 then begin
    // try to set appropriate wbxml version according to wml version
    case FPublicID of
      2: FVersion:= 0;
      4: FVersion:= 1;
      9: FVersion:= 2;
      $A: FVersion:= 3;
      else FVersion:= 3;
    end;
  end else begin
    FVersion:= AWBXMLVersion;
  end;
  FEncodingCharsetCode:=  csUTF8;
end;

// constructor takes wml source text, parse to wml element collection, then call prevoius constrictor
constructor TWMLCCompiler.Create(AWBXMLVersion: Integer; ASrc: WideString; AOutStream: TStream);
begin
  FxmlCollection:= TxmlElementCollection.Create(TwmlContainer, Nil, wciOne);
  with FxmlCollection.Add.DrawProperties.TagXYStart do begin
    x:= 0;
    y:= 1;
  end;
  xmlparse.xmlCompileText(ASrc, Nil, Nil, Nil, FxmlCollection.Items[0], TWMLContainer);
  Create(AWBXMLVersion, FxmlCollection, AOutStream);
  // override FInternalWMLObject value
  FInternalWMLObject:= True;
end;

destructor TWMLCCompiler.Destroy;
begin
  // destroy internal object
  if FInternalWMLObject
  then FxmlCollection.Free;
  inherited Destroy;
end;

// this method in TWMLCCompiler never used. Decalred just to disable compiler warnings

procedure TWMLCCompiler.Execute;
begin

end;

procedure TWMLCCompiler.Start;
var
  l: Integer;
begin
  inherited Start;
  WriteMB(FVersion);

  WriteMB(FPublicId);  // 2- wml1.0 4- wml1.1 9-wml1.2 A- wml1.3
  if FPublicId = 0     // 0- special string identifier
  then WriteMB(0);     // ?!! this is wrong. Must be index of string table entry
  WriteMB(FEncodingCharsetCode);  // default is csUTF8
  FxmlCollection.Items[0].ForEachInOut(CompileTagStart, CompileTagFinish);
  // write string table

  l:= Length(FstringTable);
  WriteMB(l);                              // write length descriptor
  if l > 0
  then FOutStream.WriteBuffer(FstringTable[1], l); // write string table buffer
  FOutStream.WriteBuffer(FBuf[1], Length(FBuf));                 // write compiled buffer
end;

procedure TWMLCCompiler.CompileTagStart(var AxmlElement: TxmlElement);
var
  tagVal,
  tagNum: Integer;
  n: String;
  cont: Boolean;
  ValuableAttributesCount: Integer;
  errs: WideString;
begin
  n:= AxmlElement.GetElementName;
  // tagNum:= -1;
  // skip comments, xml tags, extension (server side) tag
  if (AxmlElement is TxmlContainer) or (AxmlElement is TxmlComment) or (AxmlElement is TXMLDesc) or
    (AxmlElement is TDocDesc) or (AxmlElement is TServerSide) then begin
    Exit;
  end;
  if (AxmlElement is TxmlPCData) then begin
    compileString(AxmlElement.Attributes.ValueByName['value']);
    Exit;
  end;

  tagNum:= AxmlElement.BinCode;
  if (tagNum = NOBINCODE) then begin
    if Assigned(FOnError) then begin
      cont:= True;
      errs:= Format(MSG_UNKNOWNTAG, [AxmlElement.ElementName]);
      FOnError(rlError, AxmlElement, '', 0, AxmlElement.DrawProperties.TagXYStart,
        PWideChar(errs), cont, Nil);
      if not cont
      then raise Exception.CreateFmt(MSG_PARSING_INTERRUPTED, []);
    end else begin
      raise Exception.CreateFmt(MSG_UNKNOWNTAG, [AxmlElement.ElementName]);
    end;
  end;
  tagVal:= tagNum;
  // write valuable attributes. Do not skip default values (just in case)
  ValuableAttributesCount:= AxmlElement.Attributes.CountValuable;  // GetCountValuableNoDefault
  // set flag WMLTC_ATTRIBUTES if attributes exists
  if (ValuableAttributesCount > 0)
  then tagVal:= tagVal or WMLTC_ATTRIBUTES;
  // set flag WMLTC_CONTENT if element contains other tags or pcdata
  if (AxmlElement.NestedElements1Count > 0)
  then tagVal:= tagVal or WMLTC_CONTENT;
  FBuf:= FBuf + Char(tagVal);
  if (ValuableAttributesCount > 0)
  then compileAttributes(AxmlElement);
end;

procedure TWMLCCompiler.CompileTagFinish(var AxmlElement: TxmlElement);
var
  n: String;
begin
  n:= AxmlElement.GetElementName;
  // skip comments, xml tags, extension (server side) tag
  if (AxmlElement is TxmlContainer) or (AxmlElement is TxmlComment) or (AxmlElement is TXMLDesc) or
    (AxmlElement is TDocDesc) or (AxmlElement is TServerSide) or (AxmlElement is TWMLBr) or
    (AxmlElement is TWMLNoop)or (AxmlElement is TWMLImg) or (AxmlElement is TWMLMeta) or
    (AxmlElement is TWMLSetvar) or (AxmlElement is TxmlPCData) or (AxmlElement is TWMLInput)
  then Exit;
  if (AxmlElement.NestedElements1Count > 0)
  then FBuf:= FBuf + Char(WMLTC_END);
end;

function DecompileWMLCString(const Awmlc: String; ABlockIndent: Integer;
  var AErrorsDesc: String; var AEncoding, AWBXMLVersion, APublicId: Integer): WideString;
var
  WMLCParser: TWMLCParser;
  InStream, OutStream: TStream;
begin
  OutStream:= TWideStringStream.Create('');
  try
    InStream:= TStringStream.Create(Awmlc);
    WMLCParser:= TWMLCParser.Create(InStream, OutStream, ABlockIndent);
    with WMLCParser do begin
      Start;
      AEncoding:= EncodingCharsetCode;
      AWBXMLVersion:= Version;
      APublicId:= WMLCParser.PublicId;
      Free;
    end;
    Result:= TWideStringStream(OutStream).DataString;
    OutStream.Free;
    InStream.Free;
    AErrorsDesc:= '';
  except
    on E: Exception do begin
      Result:= TWideStringStream(OutStream).DataString;
      AErrorsDesc:= E.Message;
    end;
  end;
end;

{ CompileWMLC compile wmlc from wml object
  Parameters:
    AWMLCollection - wml object to compile
    AErrorsDesc  returns description of errors or '' if no errors was detected
}
function CompileWMLC(AWBXMLVersion: Integer; AxmlCollection: TxmlElementCollection; AErrorsDesc: TWideStrings): String;
var
  wmlcc: TWMLCCompiler;
  OutStream: TStream;
  errHandler: TErrorHandlerInStrings;
begin
  errHandler:= TErrorHandlerInStrings.Create;
  OutStream:= TStringStream.Create('');
  try
    wmlcc:= TWMLCCompiler.Create(AWBXMLVersion, AxmlCollection, OutStream);
    with wmlcc do begin
      OnError:= errHandler.ErrorHandler;
      Start;
      Free;
    end;
    Result:= TStringStream(OutStream).DataString;
    OutStream.Free;
    if Assigned(AErrorsDesc)
    then AErrorsDesc.Assign(errHandler.ErrorList);
  except
    on E: Exception do begin
      Result:= TStringStream(OutStream).DataString;
      if Assigned(AErrorsDesc)
      then AErrorsDesc.Add(E.Message);
    end;
  end;
  errHandler.Free;
end;

{ CompileWMLCString compile wmlc from wml source text
  Parameters:
    AWML           - wml source (unicode) to compile
    AErrorsDesc      returns description of errors or '' if no errors was detected
                     can be Nil
}

function CompileWMLCString(AWBXMLVersion: Integer; const Awml: WideString; AErrorsDesc: TWideStrings): String;
var
  wmlcc: TWMLCCompiler;
  OutStream: TStream;
  errHandler: TErrorHandlerInStrings;
begin
  errHandler:= TErrorHandlerInStrings.Create;
  OutStream:= TStringStream.Create('');
  try
    wmlcc:= TWMLCCompiler.Create(AWBXMLVersion, Awml, OutStream);
    with wmlcc do begin
      wmlcc.OnError:= errHandler.ErrorHandler;
      Start;
      Free;
    end;
    Result:= TStringStream(OutStream).DataString;
    OutStream.Free;
    if Assigned(AErrorsDesc)
    then AErrorsDesc.Assign(errHandler.ErrorList);
  except
    on E: Exception do begin
      Result:= TStringStream(OutStream).DataString;
      if Assigned(AErrorsDesc)
      then AErrorsDesc.Add(E.Message);
    end;
  end;
  errHandler.Free;
end;

{------------------------- WBXML public id routines ---------------------------}

{ GetPublicIdByWMLVersionStr
  Parameters:
    AWMLVersion: wml version string '1.0', '1.1', '1.2', '1.3'
  Return:
    WBXML public id: 2- wml1.0 4- wml1.1 9-wml1.2 A- wml1.3  0- special string identifier
}

function GetPublicIdByWMLVersionStr(const AWMLVersion: String): Integer;
begin
  if AWMLVersion = '1.0' then Result:= 2 else
    if AWMLVersion = '1.1' then Result:= 4 else
      if AWMLVersion = '1.2' then Result:= 9 else
        if AWMLVersion = '1.3' then Result:= $A else
          Result:= 0;
end;

{----------------- HTTP Content Type WAP byte code routines -------------------}

{ Translates between HTTP Content type and WAP code.
  Parameters:
    AContentTypeName: HTTP Content type (case-sensitive)
  Return:
    encoded WAP Content type, -1 if error
}
function GetHTTPContentTypeCode(const AContentTypeName: String): Integer;
var
  i: Integer;
begin
  for i:= Low(HTTPContentTypeTable) to High(HTTPContentTypeTable) do begin
    if (CompareText(AContentTypeName, HTTPContentTypeTable[i]) = 0) then begin
      Result:= i;
      Exit;
    end;
  end;
  // Content type does not recognized
  Result:= -1;
end;

{ Translates between WAP encoded header and HTTP header.
  Parameters:
    AHTTPContentTypeWAPCode: Encoded WAP Content type.
  Return
    HTTP Content type, empty string if error.
 }
function getHTTPContentTypeName(AHTTPContentTypeWAPCode: Integer): String;
begin
  if (AHTTPContentTypeWAPCode < Low(HTTPContentTypeTable)) or
    (AHTTPContentTypeWAPCode > High(HTTPContentTypeTable))
  then begin
    // Content type not recognized
    Result:= '';
  end else begin
    Result:= HTTPContentTypeTable[AHTTPContentTypeWAPCode];
  end;
end;

{-------------------------- TWapCapabilities ----------------------------------}

constructor TWapCapabilities.Create;
begin
  inherited Create;
  { create list }
  FExtendedMethods:= TExtendedMethods.Create;
  FHeaderCodePages:= THeaderCodePages.Create;
  FAliases:= TStringList.Create;
  { set defaults }
  Clear;
end;

procedure TWapCapabilities.Clear;
begin
  { Capability defaults WSP 8.3.3 }
  FClientSDUSize:= 1400;
  FServerSDUSize:= 1400;
  FProtocolOptions:= [];
  FMethodMOR:= 1;
  FPushMOR:= 1;
  FClientMsgSize:= 1400;
  FServerMsgSize:= 1400;
  FAliases.Clear;
  FHeaderCodePages.Clear;
  FExtendedMethods.Clear;
end;

function WSPProtocolOptions2Set(AFlags: Cardinal): TWSPProtocolOptions;
begin
  Result:= [];
  if (AFlags and $80) > 0
  then Include(Result, wsppConfirmedPushFacility);
  if (AFlags and $40) > 0
  then Include(Result, wsppPushFacility);
  if (AFlags and $20) > 0
  then Include(Result, wsppSessionResumeFacility);
  if (AFlags and $10) > 0
  then Include(Result, wsppAcknowledgementHeaders);
  if (AFlags and $8) > 0
  then Include(Result, wsppLargeDataTransfer);
end;

function WSPSet2ProtocolOptions(AWSPProtocolOptions: TWSPProtocolOptions): Cardinal;
begin
  Result:= 0;
  if wsppConfirmedPushFacility in AWSPProtocolOptions then Result:= Result or $80;
  if wsppPushFacility in AWSPProtocolOptions then Result:= Result or $40;
  if wsppSessionResumeFacility in AWSPProtocolOptions then Result:= Result or $20;
  if wsppAcknowledgementHeaders in AWSPProtocolOptions then Result:= Result or $10;
  if wsppLargeDataTransfer in AWSPProtocolOptions then Result:= Result or $8;
end;

procedure TWapCapabilities.AddByCode(ACode: Integer; const AValueN: Cardinal; const AValueS: String);
begin
  case ACode of
    WAPCAP_CLIENT_SDU_SIZE:begin
        FClientSDUSize:= AValueN;
      end;
    WAPCAP_SERVER_SDU_SIZE:begin
        FServerSDUSize:= AValueN;
      end;
    WAPCAP_PROTOCOLOPTIONS:begin
        FProtocolOptions:= WSPProtocolOptions2Set(AValueN);
      end;
    WAPCAP_METHOD_MOR:begin
        FMethodMOR:= AValueN;
      end;
    WAPCAP_PUSH_MOR:begin
        FPushMOR:= AValueN;
      end;
    WAPCAP_EXTENDEDMETHODS:begin
        FExtendedMethods.AddObject(AValueS,  TObject(AValueN));
      end;
    WAPCAP_HEADERCODEPAGES:begin
        FHeaderCodePages.AddObject(AValueS,  TObject(AValueN));
      end;
    WAPCAP_ALIASES:begin
      FAliases.AddObject(AValueS,  Nil);
      end;
    WAPCAP_CLIENT_MSG_SIZE:begin
        FClientMsgSize:= AValueN;
      end;
    WAPCAP_SERVER_MSG_SIZE:begin
        FServerMsgSize:= AValueN;
      end;
  end; { case }
end;

destructor TWapCapabilities.Destroy;
begin
  FAliases.Free;
  FHeaderCodePages.Free;
  FExtendedMethods.Free;
  inherited Destroy;
end;

{ Parameters:
    ACapabilityCode: code
  Return
    capability string, empty string if error.
 }
function getCapabilityName(ACapabilityCode: Integer): String;
begin
  if (ACapabilityCode < Low(WAPCapabilityTable)) or
    (ACapabilityCode > High(WAPCapabilityTable))
  then begin
    // capability not recognized
    Result:= '';
  end else begin
    Result:= WAPCapabilityTable[ACapabilityCode];
  end;
end;

{ Parameters:
    ACapabilityName: name of capability
  Return:
    encoded capability code, -1 if error
}
function GetCapabilityCode(const ACapabilityName: String): Integer;
var
  i: Integer;
begin
  for i:= Low(WAPCapabilityTable) to High(WAPCapabilityTable) do begin
    if (CompareText(ACapabilityName, WAPCapabilityTable[i]) = 0) then begin
      Result:= i;
      Exit;
    end;
  end;
  // capability does not recognized
  Result:= -1;
end;

{-------- HTTP header field name conversion to WAP byte code routines ---------}

{ Translates between HTTP Content type and WAP code.
  Parameters:
    AHeaderFieldName: HTTP header field name (case-sensitive)
  Return:
    WAP header field number, -1 if error
}
function GetHTTPHeaderFieldCode(const AHeaderFieldName: String; const AVersion: String = DEFAULT_WMLC_ENCODING_VERSION): Integer;
var
  i: Integer;
  l: Integer;
begin
  { descending order to use new code instead deprecated codes.
    It is possible incorrect for old device.
  }
  if AVersion = '1.1' then l:= WML_HTTPHEADERFIELD_LAST_VER_11 else
    if AVersion = '1.2' then l:= WML_HTTPHEADERFIELD_LAST_VER_12 else
      if AVersion = '1.3' then l:= WML_HTTPHEADERFIELD_LAST_VER_13 else
        l:= WML_HTTPHEADERFIELD_MAX; // if AVersion = '1.4' then l:= WML_HTTPHEADERFIELD_LAST_VER_14 else
  for i:= l downto Low(HTTPHeaderFieldNameTable) do begin
    if (CompareText(AHeaderFieldName, HTTPHeaderFieldNameTable[i]) = 0) then begin
      Result:= i;
      Exit;
    end;
  end;
  // header field does not recognized
  Result:= -1;
end;

{ Translates between WAP encoded header and HTTP header.
  Parameters:
    AHTTPHeaderFieldWAPCode: WAP header field number
  Return
    header field name, empty string if error.
 }
function getHTTPHeaderFieldName(AHTTPHeaderFieldWAPCode: Integer): String;
begin
  if (AHTTPHeaderFieldWAPCode < Low(HTTPHeaderFieldNameTable)) or
    (AHTTPHeaderFieldWAPCode > High(HTTPHeaderFieldNameTable))
  then begin
    // header not recognized
    Result:= '';
  end else begin
    Result:= HTTPHeaderFieldNameTable[AHTTPHeaderFieldWAPCode];
  end;
end;

{----- ISO 639 Language assignments conversion to WAP byte code routines -----}

{ Translates between WAP encoded language ISO 639 number to full name of language
  Parameters:
    ALangCode: WAP language number
  Return
    full english name of language by ISO 639 code,
    '' if not defined
 }
function LangCode2Name(ALangCode: Integer): String;
begin
  if (ALangCode < Low(LangDef)) or (ALangCode > High(LangDef))
  then begin
    // lang not recognized
    Result:= '';
  end else begin
    Result:= LangDef[ALangCode].n;
  end;
end;

{ Translates between WAP encoded language ISO 639 number to short name of language
  Parameters:
    ALangCode: WAP language number
  Return
    short english name of language by ISO 639 code,
    '' if not defined
 }
function LangCode2ShortName(ALangCode: Integer): String;
begin
  if (ALangCode < Low(LangDef)) or (ALangCode > High(LangDef))
  then begin
    // lang not recognized
    Result:= '';
  end else begin
    Result:= LangDef[ALangCode].d;
  end;
end;

{ Translates between full name of language to WAP encoded ISO 639 number of language
  Parameters:
    ALangName: full english name of language
  Return
    ISO 639 language code
    -1 if not defined
 }
function LangName2Code(const ALangName: String): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= Low(LangDef) to High(LangDef) do begin
    if CompareText(LangDef[i].n, ALangName) = 0 then begin
      Result:= i;
      Exit;
    end;
  end;
end;

{ Translates between short name of language to WAP encoded ISO 639 number of language
  Parameters:
    ALangShortName: short english name of language
  Return
    ISO 639 language code
    -1 if not defined
 }
function LangShortName2Code(const ALangShortName: String): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= Low(LangDef) to High(LangDef) do begin
    if CompareText(LangDef[i].d, ALangShortName) = 0 then begin
      Result:= i;
      Exit;
    end;
  end;
end;

{------------------- IANA encoding character set code routines ----------------}

{ Translates between name of encoding character set to WAP encoded IANA number of character set
  Parameters:
    ACharsetCode: charset number (IANA number of character set)
  Return
    charatcer set name
 }
function CharSetCode2Name(ACharsetCode: Integer): String;
var
  i: Integer;
begin
  Result:= '';
  for i:= Low(CharSetDef) to High(CharSetDef) do begin
    if CharSetDef[i].c = ACharsetCode then begin
      Result:= CharSetDef[i].n;
      Exit;
    end;
  end;
end;

{ Translates between name of encoding character set to WAP encoded IANA number of character set
  Parameters:
    ACharsetName: encoding charatcer set name
  Return
    charset number (IANA number of character set)

    -1 if not defined
 }
function CharSetName2Code(const ACharsetName: String): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= Low(CharSetDef) to High(CharSetDef) do begin
    if CompareText(CharSetDef[i].n, ACharsetName) = 0 then begin
      Result:= CharSetDef[i].c;
      Exit;
    end;
  end;
end;

{------------------- HTTP header parameter name code routines -----------------}

{ Translates between name of HTTP header parameter to number of parameter name
  Parameters:
    AParameterNameCode: number of parameter name
  Return
    name of HTTP header parameter
 }
function getParameterName(AParameterNameCode: Integer): String;
begin
  if (AParameterNameCode < Low(WAPParameterNameTable)) or (AParameterNameCode > High(WAPParameterNameTable))
  then begin
    // parameter does not recognized
    Result:= '';
  end else begin
    Result:= WAPParameterNameTable[AParameterNameCode];
  end;
end;
{ Translates between number of parameter name to name of HTTP header parameter
  Parameters:
    AParameterName: name of HTTP header parameter
  Return
    number of parameter name
    -1 if not defined
 }
function getParameterCode(const AParameterName: String): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= Low(WAPParameterNameTable) to High(WAPParameterNameTable) do begin
    if CompareText(WAPParameterNameTable[i], AParameterName) = 0 then begin
      Result:= i;
      Exit;
    end;
  end;
end;

{------------------- HTTP header parameter name code routines -----------------}

{ Translates between name PDU type number to name
  Parameters:
    APDUTypeCode: number of parameter name
  Return
    name of PDU type
 }
function getPDUTypeName(APDUTypeCode: Integer): String;
var
  i: Integer;
begin
  Result:= '';
  for i:= Low(PDUTypeTable) to High(PDUTypeTable) do begin
    if PDUTypeTable[i].c = APDUTypeCode then begin
      Result:= PDUTypeTable[i].n;
      Exit;
    end;
  end;
end;

{ Translates between number of PDU name to number
  Parameters:
    APDUTypeName: name PDU type
  Return
    number of PDU type
    -1 if not defined
 }
function getPDUTypeCode(const APDUTypeName: String): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= Low(PDUTypeTable) to High(PDUTypeTable) do begin
    if CompareText(PDUTypeTable[i].n, APDUTypeName) = 0 then begin
      Result:= PDUTypeTable[i].c;
      Exit;
    end;
  end;
end;

{------------------- HTTP status code routines -----------------}

{ Translates between number to http status code
  Parameters:
    ACode: number of http status
  Return
    HTTP status (200 - OK, etc.)
 }
function getHTTPStatus(ACode: Byte): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= Low(HTTPStatusCode) to High(HTTPStatusCode) do begin
    if HTTPStatusCode[i].c = ACode then begin
      Result:= HTTPStatusCode[i].h;
      Exit;
    end;
  end;
end;

{ Translates between number of PDU name to number
  Parameters:
    AStatus: HTTP status (200 - OK, etc.)
  Return
    number status code
    0 (node, reserved) if not defined
 }
function getHTTPStatusCode(const AStatus: Integer): Byte;
var
  i: Integer;
begin
  Result:= 0;
  for i:= Low(HTTPStatusCode) to High(HTTPStatusCode) do begin
    if HTTPStatusCode[i].h = AStatus then begin
      Result:= HTTPStatusCode[i].c;
      Exit;
    end;
  end;
end;

{ Content-encoding-value = (Gzip | Compress | Deflate | Token-text)
  Gzip =     #128
  Compress = #129
  Deflate =  #130
  *       =  #131
}
function GetContentEncodingCode(const AContentEncodingStr: String): Integer;
begin
  if CompareText(AContentEncodingStr, 'gzip') = 0
  then Result:= 0 // 128
  else if CompareText(AContentEncodingStr, 'compress') = 0
    then Result:= 1 // 129
    else if CompareText(AContentEncodingStr, 'deflate') = 0
      then Result:= 2 // 130
      else if CompareText(AContentEncodingStr, '*') = 0
        then Result:= 3 // 131
        else Result:= -1;
end;

function GetContentEncodingName(AContentEncodingCode: Integer): String;
begin
  case AContentEncodingCode of
    0: Result:= 'gzip';       // 128
    1: Result:= 'compress';   // 129
    2: Result:= 'deflate';    // 130
    3: Result:= '*';          // 131
    else Result:= '';
  end; { case }
end;

{ i.e. Accept-Ranges: bytes
  Accept-ranges-value = (None | Bytes | Token-text)
  None = <Octet 128>
  Bytes = <Octet 129>
}
function GetAcceptRange2Code(const AAcceptRangeStr: String): Integer;
begin
  if CompareText(AAcceptRangeStr, 'none') = 0
  then Result:= 0     // 128
  else if CompareText(AAcceptRangeStr, 'bytes') = 0
    then Result:= 1   // 129
    else Result:= -1;
end;

function GetAcceptRange2Name(AAcceptRangeCode: Integer): String;
begin
  case AAcceptRangeCode of
    0: Result:= 'none';  // 128
    1: Result:= 'bytes'; // 129
    else Result:= '';
  end; { case }
end;

function GetCacheControl2Code(const ACacheControlStr: String): Integer;
begin
  if CompareText(ACacheControlStr, 'No-cache') = 0
  then Result:= 0 else  // 128
    if CompareText(ACacheControlStr, 'No-store') = 0
    then Result:= 1 else  // 129
      if CompareText(ACacheControlStr, 'Max-age') = 0
      then Result:= 2 else  // 130
        if CompareText(ACacheControlStr, 'Max-stale') = 0
        then Result:= 3 else  // 131
          if CompareText(ACacheControlStr, 'Min-fresh') = 0
          then Result:= 4 else  // 132
            if CompareText(ACacheControlStr, 'Only-if-cached') = 0
            then Result:= 5 else  // 133
              if CompareText(ACacheControlStr, 'Public') = 0
              then Result:= 6 else  //  134
                if CompareText(ACacheControlStr, 'Private') = 0
                then Result:= 7 else  //  135
                  if CompareText(ACacheControlStr, 'No-transform') = 0
                  then Result:= 8 else  //  136
                    if CompareText(ACacheControlStr, 'Must-revalidate') = 0
                    then Result:= 9 else  //  137
                      if CompareText(ACacheControlStr, 'Proxy-revalidate') = 0
                      then Result:= 10  //  138
                      else if CompareText(ACacheControlStr, 'S-maxage') = 0
                        then Result:= 11  //  139
                        else Result:= -1;
end;

function GetCacheControl2Name(ACacheControlCode: Integer): String;
begin
  case ACacheControlCode of
  0: Result:= 'No-cache';         // 128
  1: Result:= 'No-store';         // 129
    2: Result:= 'Max-age';        // 130
  3: Result:= 'Max-stale';        // 131
    4: Result:= 'Min-fresh';      // 132
  5: Result:= 'Only-if-cached';   // 133
  6: Result:= 'Public';           // 134
  7: Result:= 'Private';          // 135
  8: Result:= 'No-transform';     // 136
  9: Result:= 'Must-revalidate';  // 137
  10: Result:= 'Proxy-revalidate'; // 138
  11: Result:= 'S-maxage';       // 139
  else Result:= '';
  end; { case }
end;

function GetWarning2Code(const AWarningValue: Word): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= Low(WarningCodeDefs) to High(WarningCodeDefs) do begin
    if WarningCodeDefs[i].c = AWarningValue then begin
      Result:= WarningCodeDefs[i].b;
      Exit;
    end;
  end;
end;

function GetWarningCode2Val(AWarningCode: Byte): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= Low(WarningCodeDefs) to High(WarningCodeDefs) do begin
    if WarningCodeDefs[i].b = AWarningCode then begin
      Result:= WarningCodeDefs[i].c;
      Exit;
    end;
  end;
end;

function GetContentDisposition2Code(const AContentDispositionStr: String): Integer;
begin
  if CompareText(AContentDispositionStr, 'Form-data') = 0
  then Result:= 0 else  // 128
    if CompareText(AContentDispositionStr, 'Attachment') = 0
    then Result:= 1 else  //  129
      if CompareText(AContentDispositionStr, 'Inline') = 0
      then Result:= 2 else Result:= -1;  // 130
end;

function GetContentDisposition2Name(AContentDispositionCode: Integer): String;
begin
  case AContentDispositionCode of
  0: Result:= 'Form-data';  // 128
  1: Result:= 'Attachment'; // 129
  2: Result:= 'Inline';     // 130
  else Result:= '';
  end; { case }
end;

function GetProfileWarning2Code(AProfileWarningVal: Integer): Integer;
begin
  case AProfileWarningVal of
  100: Result:= $10;
  101: Result:= $11;
  102: Result:= $12;
  200: Result:= $20;
  201: Result:= $21;
  202: Result:= $22;
  203: Result:= $23;
  else Result:= -1;
  end; { case }
end;

function GetProfileWarning2Val(AProfileWarningCode: Byte): Integer;
begin
  case AProfileWarningCode of
  $10: Result:= 100;
  $11: Result:= 101;
  $12: Result:= 102;
  $20: Result:= 200;
  $21: Result:= 201;
  $22: Result:= 202;
  $23: Result:= 203;
  else Result:= -1;
  end; { case }
end;

function GetTE2Code(const ATEStr: String): Integer;
begin
  if CompareText(ATEStr, 'Q-token') = 0
  then Result:= 0 else  // 128
    if CompareText(ATEStr, 'Trailers') = 0
    then Result:= 1 else  // 129
      if CompareText(ATEStr, 'Chunked') = 0
      then Result:= 2 else  // 130
        if CompareText(ATEStr, 'Identity') = 0
        then Result:= 3 else // 131
          if CompareText(ATEStr, 'Gzip') = 0
          then Result:= 4 else // 132
            if CompareText(ATEStr, 'Compress') = 0
            then Result:= 5 else // 133
              if CompareText(ATEStr, 'Deflate') = 0
              then Result:= 6 else Result:= -1;  // 134

end;

function GetTE2Name(ATECode: Integer): String;
begin
  case ATECode of
  0: Result:= 'Q-token';  // 128
  1: Result:= 'Trailers'; // 129
  2: Result:= 'Chunked';  // 130
  3: Result:= 'Identity'; // 131
  4: Result:= 'Gzip';     // 132
  5: Result:= 'Compress'; // 133
  6: Result:= 'Deflate';  // 134
  else Result:= '';
  end; { case }
end;

end.
