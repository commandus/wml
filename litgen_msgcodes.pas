unit
  litgen_msgcodes;
(*##*)
(*******************************************************************************
*                                                                             *
*   l  i  t  g  e  n  _  m  s  g  c  o  d  e  s                                *
*                                                                             *
*   Copyright © 2002, 2003 Andrei Ivanov. All rights reserved.                 *
*   Microsoft reader litgen.dll error codes                                   *
*                                                                              *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2002,                                                *
*   Last revision: Oct 29 2002                                                *
*   Lines        : 225                                                         *
*   History      : see todo file                                              *
*                                                                              *
*                                                                             *
*   Printed      :                                                             *
*                                                                             *
********************************************************************************)
(*##*)

interface

// Message codes are all four digits.  The first digit indicates the major class of the
// message.  The META, CONTENT, and CSS classes are messages that should probably be shown
// to the end-user.  The INT (internal) class should be useful only to tech support people
// ("no user-serviceable parts inside"); they are all things that theoretically can't happen,
// or can only happen under resource exhaustion (in which case you'll get E_OUTOFMEMORY back
// too).  The MISC class should be handled on a message-by-message basis.
//
// The second digit digit will be 5 or above for errors, or a "warning level" for warnings
// (1 being most severe and 4 being least severe).

const
  LITGEN_WARN_META_UNKNOWN_TAG         = 1101;
  LITGEN_WARN_META_UNKNOWN_ATTR        = 1102;
  LITGEN_WARN_META_UNKNOWN_MIME_TYPE   = 1103;
  LITGEN_WARN_META_UNKNOWN_FILE        = 1104;
  LITGEN_WARN_META_FALLBACK_NOTSUP     = 1105;
  LITGEN_WARN_META_RAPIER_FIND         = 1106;
  LITGEN_WARN_META_MISSING_FILEAS      = 1201;
  LITGEN_WARN_META_NONPORTABLE_IMAGE   = 1202;
  LITGEN_WARN_META_INCORRECT_CHILDREN  = 1203;
  LITGEN_WARN_META_MORE_CHILDREN_FOUND = 1204;
  LITGEN_WARN_META_TEXT_NOTALLOWED     = 1205;
  LITGEN_WARN_META_ATTR_MISSING        = 1206;
  LITGEN_WARN_META_UNIQUE_ATTR_MISSING = 1207;
  LITGEN_WARN_META_EMPTY_NOTALLOWED    = 1210;
  LITGEN_WARN_META_TEXT_MISSING        = 1211;
  LITGEN_WARN_META_TAG_MISPLACED       = 1212;
  LITGEN_WARN_META_PACKAGE_INROOTONLY  = 1213;
  LITGEN_WARN_META_ONLYPACKAGE_INROOT  = 1214;
  LITGEN_WARN_META_MISSING_CHILDREN    = 1215;
  LITGEN_WARN_META_WRONG_ATTRIBUTES    = 1216;
  LITGEN_WARN_META_NONOEB_NOFALLBACK   = 1217;
  LITGEN_WARN_META_XMLNS_OEBPACKAGE    = 1218;
  LITGEN_WARN_META_XMLNS_DC            = 1219;

  LITGEN_ERR_META_BAD_TAG_NESTING      = 1501;
  LITGEN_ERR_META_MISSING_CHILDREN     = 1502;
  // 1503 was removed, but should be reserved.
  LITGEN_ERR_META_INVALID_SPINE_TYPE   = 1504;
  LITGEN_ERR_META_ALREADY_IN_SPINE     = 1505;
  LITGEN_ERR_META_NO_SPINE             = 1506;
  LITGEN_ERR_META_NO_CONTENT_FILES     = 1507;
  LITGEN_ERR_META_MISMATCHED_TAGS      = 1508;
  LITGEN_ERR_META_UNCLOSED_TAGS        = 1509;
  LITGEN_ERR_META_EMPTY_HREF           = 1510;
  LITGEN_ERR_META_ATTR_MISSING         = 1511;
  LITGEN_ERR_META_NONOEB_IN_SPINE      = 1512;
  LITGEN_ERR_META_POUND_IN_ID          = 1513;
  LITGEN_ERR_META_POUND_IN_FILENAME    = 1514;
  LITGEN_ERR_META_DUPLICATE_ID         = 1515;
  LITGEN_ERR_META_FIRSTPAGE_OUTOFSPINE = 1516;
  LITGEN_ERR_META_EXTERNAL_COVERIMAGE  = 1517;

  LITGEN_WARN_CONTENT_UNKNOWN_TAG               = 2101;
  LITGEN_WARN_CONTENT_UNKNOWN_ATTR              = 2102;
  LITGEN_WARN_CONTENT_UNKNOWN_FILE              = 2103;
  LITGEN_WARN_CONTENT_STYLE_TOO_LATE            = 2104;
  LITGEN_WARN_CONTENT_NOHREF_LINK_IGNORED       = 2201;
  LITGEN_WARN_CONTENT_PAGEBREAK_OL              = 2202;
  LITGEN_WARN_CONTENT_ANSI_ENCODING             = 2203;
  LITGEN_WARN_CONTENT_NONOEB_LINK_IGNORED       = 2204;
  LITGEN_WARN_CONTENT_LINK_TYPE_MISMATCH        = 2205;
  LITGEN_WARN_CONTENT_NONSS_LINK_IGNORED        = 2206;
  // 2207 was removed, but should be reserved.
  LITGEN_WARN_CONTENT_PAGEBREAK_NONVISIBLEBLOCK = 2208;
  LITGEN_WARN_CONTENT_NONOEB_STYLE_IGNORED      = 2209;
  LITGEN_WARN_CONTENT_NONOEB_TAG                = 2210;
  LITGEN_WARN_CONTENT_NONOEB_ATTR               = 2211;
  LITGEN_WARN_CONTENT_NONOEB_STYLEATTR_IGNORED  = 2301;
  LITGEN_WARN_CONTENT_NONOEB_CLASSATTR_IGNORED  = 2302;
  LITGEN_WARN_CONTENT_NONOEB_LANGATTR_IGNORED   = 2303;

  LITGEN_ERR_CONTENT_WRONG_TYPE         = 2501;
  LITGEN_ERR_CONTENT_MISMATCHED_TAGS    = 2502;
  LITGEN_ERR_CONTENT_UNCLOSED_TAGS      = 2503;
  LITGEN_ERR_CONTENT_PAGEBREAK_IN_TABLE = 2504;

  LITGEN_WARN_CSS_UNBALANCED_BRACE   = 3101;
  LITGEN_WARN_CSS_UNEXPECTED_TOKEN   = 3102;
  LITGEN_WARN_CSS_UNEXPECTED_EOF     = 3103;
  LITGEN_WARN_CSS_EMPTY_VALUE        = 3104;
  // 3105 was removed, but should be reserved.
  LITGEN_WARN_CSS_NONOEB_PROPERTY    = 3106;

  // these are used only by the Rapier compatibility parser
  LITGEN_ERR_CSS_UNEXPECTED_EOF      = 3501;
  LITGEN_ERR_CSS_UNEXPECTED_TOKEN    = 3502;
  LITGEN_ERR_CSS_UNEXPECTED_VALUE    = 3503;
  LITGEN_ERR_CSS_UNEXPECTED_IDENT    = 3504;
  LITGEN_ERR_CSS_UNEXPECTED_CLASS    = 3505;
  LITGEN_ERR_CSS_UNRECOGNIZED_TEXT   = 3506;
  LITGEN_ERR_CSS_UNKNOWN_DIRECTIVE   = 3507;

  LITGEN_MSG_MISC_SUCCESS            = 4101;
  LITGEN_MSG_MISC_PAGEBREAKS         = 4201;
  LITGEN_ERR_MISC_OUTPUT_CORRUPT     = 4501;
  // 4502-4504 were removed, but should be reserved.
  LITGEN_ERR_MISC_PATH_NOT_FOUND     = 4505;

  LITGEN_ERR_INT_ADD_MANIFEST_ITEM   = 5501;
  LITGEN_ERR_INT_QUERY_ISTITEX_CONT  = 5502;
  LITGEN_ERR_INT_QUERY_ISTITEX_ROOT  = 5503;
  LITGEN_ERR_INT_QUERY_ISTITEX_DATA  = 5504;
  LITGEN_ERR_INT_CREATE_CONTENT_STRM = 5505;
  LITGEN_ERR_INT_GET_STREAM_POS_TAG  = 5506;
  LITGEN_ERR_INT_GET_STREAM_POS_PB   = 5507;
  LITGEN_ERR_INT_GET_STREAM_SIZE     = 5508;
  LITGEN_ERR_INT_GEN_ANCHOR_STREAMS  = 5509;
  LITGEN_ERR_INT_LOG_ANCHOR_DEST     = 5510;
  LITGEN_ERR_INT_CREATE_STREAM       = 5511;
  LITGEN_ERR_INT_ITSTORAGE_FACTORY   = 5512;
  LITGEN_ERR_INT_INSTANTIATE_ITSS    = 5513;
  LITGEN_ERR_INT_ITSS_CONTROL_DATA   = 5514;
  LITGEN_ERR_INT_CREATE_OUTPUT_FILE  = 5515;
  LITGEN_ERR_INT_STAMP_CLSID         = 5516;
  LITGEN_ERR_INT_CREATE_TMP_METASTRM = 5517;
  LITGEN_ERR_INT_GEN_SYMKEY          = 5518;
  LITGEN_ERR_INT_CREATE_DATASPACE    = 5519;
  LITGEN_ERR_INT_ATTACH_DRM          = 5520;
  LITGEN_ERR_INT_CREATE_SUBSTORAGE   = 5521;
  LITGEN_ERR_INT_SEAL                = 5522;
  LITGEN_ERR_INT_COMPACT             = 5523;
  LITGEN_ERR_INT_CREATE_IMAGE_STREAM = 5524;
  LITGEN_ERR_INT_CREATE_CSS_STREAM   = 5525;
  LITGEN_ERR_INT_QUERY_ISEQSTREAM    = 5526;
  LITGEN_ERR_INT_INSERT_STYLERULE    = 5527;
  LITGEN_ERR_INT_INSERT_CSS_TAG      = 5528;
  LITGEN_ERR_INT_INSERT_CSS_PROPERTY = 5529;
  LITGEN_ERR_INT_CSS_LEXER_ERROR     = 5530;

const
  DRMSOURCE: WideString              = 'APOO Publisher';

  LITCONV_ERRCODE_XMLCREATEDOM       = -1;
  LITCONV_ERRCODE_XMLLOAD            = -2;
  LITCONV_ERRCODE_CREATEWRITER       = -3;
  LITCONV_ERRCODE_WALKSETATTR        = -4;
  LITCONV_ERRCODE_WALKCLOSETAG       = -5;
  LITCONV_ERRCODE_WALKSENDTEXT       = -6;
  LITCONV_ERRCODE_WALKSETTAG         = -7;
  LITCONV_ERRCODE_OPENCSS            = -8;
  LITCONV_ERRCODE_COPYCSS            = -9;
  LITCONV_ERRCODE_OPENIMG            = -10;
  LITCONV_ERRCODE_LOADDLL            = -11;
  LITCONV_ERRCODE_GETENTRY           = -12;
  LITCONV_MSGCODE_THREADDONE         = -13;

resourcestring
  LITGENDLLPATH                      = 'litgen.dll';
  LITGENDLLENTRY                     = 'CreateWriter';
  { lit convertor functions error, hint and messages }
  LITCONV_FMT_THREADDONE             = '(%x): %S';
  LITCONV_FMT_MSG                    = '(%x): %S';
  LITCONV_FMT_ERR                    = '(%x): %S';
  LITCONV_FMT_WARN                   = '(%x): %S';

  LITCONV_MSG_THREADDONE             = 'Generating LIT done (%x), package: %S';
  LITCONV_MSG_FAILED                 = 'Generating LIT failed (%x), package: %S';
  LITCONV_MSG_COPYCSS                = 'Copying CSS file %s..';
  LITCONV_MSG_PROCESSCONTENT         = 'Processing content file %s..';
  LITCONV_MSG_COPYIMAGE              = 'Copying %s image file %s (id: %s)..';

  LITCONV_ERR_LOADDLL                = 'Error %x loading library %s.';
  LITCONV_ERR_GETENTRY               = 'Error %x getting LITGen entry point.';
  LITCONV_ERR_CREATEWRITER           = 'Error %x creating ILITWriter.';

  LITCONV_ERR_INITCOM                = 'Error %x initializing COM.';
  LITCONV_ERR_GETWRITER              = 'Error %x getting writer.';
  LITCONV_ERR_SETMSGCALLBACK         = 'Error %x setting message callback on writer.';
  LITCONV_ERR_CREATEOUTPUT           = 'Error %x creating output file %s.';
  LITCONV_ERR_GETPKG                 = 'Error %x getting package file host.';
  LITCONV_ERR_PARSEPKG               = 'Error %x parsing package file %s.';
  LITCONV_ERR_PROCESSPKG             = 'Error %x processing package file %s.';
  LITCONV_ERR_GETCSS                 = 'Error %x getting CSS host.';
  LITCONV_ERR_OPENCSS                = 'Error %x opening CSS file %s.';
  LITCONV_ERR_GETCSSFILENAME         = 'Error %x getting CSS filename.';
  LITCONV_ERR_COPYCSS                = 'Error %x copying CSS file %s.';
  LITCONV_ERR_FINISHCSS              = 'Error %x finishing CSS file %s host.';
  LITCONV_ERR_GETCONTENT             = 'Error %x getting content host.';
  LITCONV_ERR_GETCONTENTFILENAME     = 'Error %x getting content filename.';
  LITCONV_ERR_PROCESSCONTENT         = 'Error %x processing content file %s.';
  LITCONV_ERR_FINISHCONTENT          = 'Error %x processing OEB content %s.';
  LITCONV_ERR_GETIMAGE               = 'Error %x getting image host.';
  LITCONV_ERR_GETIMAGEFILENAME       = 'Error %x getting image filename.';
  LITCONV_ERR_OPENIMG                = 'Error %x opening image file %s.';
  LITCONV_ERR_COPYIMG                = 'Error %x copying image from %s.';
  LITCONV_ERR_RESNOTF_COPYIMG        = 'Error %x resource image %s not found';
  LITCONV_ERR_RESLOAD_COPYIMG        = 'Error %x loading resource image %s.';
  LITCONV_ERR_RESCOPY_COPYIMG        = 'Error %x copying resource image %s.';

  LITCONV_ERR_RESNOTF_COPYSRC        = 'Error %x resource file %s not found';
  LITCONV_ERR_RESLOAD_COPYSRC        = 'Error %x loading resource %s.';
  LITCONV_ERR_RESCOPY_COPYSRC        = 'Error %x copying resource %s: %s.';

  LITCONV_ERR_FINISHIMAGE            = 'Error %x storing image.';

  LITCONV_ERR_WALKSETTAG             = 'Error %x setting tag name %s.';
  LITCONV_ERR_WALKSETATTR            = 'Error %x setting tag attribute %s.';
  LITCONV_ERR_WALKCLOSETAG           = 'Error %x closing tag %s.';
  LITCONV_ERR_WALKSENDTEXT           = 'Error %x x sending text %s.';
  LITCONV_ERR_XMLCREATEDOM           = 'Error creating XML DOM document.';
  LITCONV_ERR_XMLGETELEMENT          = 'Error getting XML document.';  
  LITCONV_ERR_XMLLOAD                = 'Can not load %s, error %x at line %d: %s';

implementation

end.
