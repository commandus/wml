unit
  litgen;
(*##*)
(*******************************************************************************
*                                                                             *
*   l  i  t  g  e  n                                                           *
*                                                                             *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                       *
*   Partially copyrights:                                                     *
*   sample implementation of ILITCallback, stream copying routines             *
*     Nate Lewis (nlewis@microsoft.com) Copyright © 1998-2000 Microsoft Corp. *
*   litgen.idl pascal header conversion                                        *
*     M van der Honing (mvdhoning@noeska.com)                                 *
*   interface definitions for LIT generator component (litgen.dll)             *

*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2002,                                                *
*   Last revision: Oct 29 2002                                                *
*   Lines        : 627                                                         *
*   History      : see todo file                                              *
*                                                                              *
*                                                                             *
*   Printed      :                                                             *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows;

type
  TFuncCreateWriter = function (out AInterface: IUnknown): HRESULT; stdcall;

//+-----------------------------------------------------------------------
//  Interfaces: ILITCallback
//              ILITTag
//              ILITParserHost
//              ILITCSSHost
//              ILITImageHost
//              ILITWriter
//
//  Notes:      See the interface documentation on ILITWriter for a top-level
//              overview of how to use litgen.
//              Every interface pointer that crosses these interfaces is an
//              IUnknown; this is to force the receiver to query for the
//              interface IID they need, since mismatches are possible when
//              relying on the type name alone.
//------------------------------------------------------------------------

//import "unknwn.idl";

const
 UUID_ILITCallback: TGUID = '{6BC62165-B91C-4993-8002-5BC30B2D1196}';
 UUID_ILITTag: TGUID = '{D655ECEB-829A-11d3-929B-00C04F68FC0F}';
 UUID_ILITHost: TGUID = '{65E8FC16-8661-11d3-929C-00C04F68FC0F}';
 UUID_ILITParserHost: TGUID = '{607A85B7-59C1-4b22-B873-A36334740661}';
 UUID_ILITCSSHost: TGUID = '{D7426056-FA2D-4d14-B36C-34D49A20D237}';
 UUID_ILITImageHost: TGUID = '{D655ECEE-829A-11d3-929B-00C04F68FC0F}';
 UUID_ILITWriter: TGUID = '{9EC81687-D4F9-4b20-969A-222BC00CE50A}';

type
 ILITCallback = interface;
 ILITTag = interface;
 ILITHost = interface;
 ILITParserHost = interface;
 ILITCSSHost = interface;
 ILITImageHost = interface;
 ILITWriter = interface;

//+-----------------------------------------------------------------------
//
//  Interface: ILITCallback
//
//  Summary:   Simple interface for receiving text messages.  The litgen
//             client implements this and passes it to ILITWriter::SetCallback();
//             Message() will be called at various times during content prep.
//
//             Message codes correspond 1:1 to the stringtable entries used to create the text
//             messages sent through ILITCallback.  They are intended to allow a client to
//             distinguish classes of codes, to allow more advanced behavior than simply
//             bailing out, and to allow filtering of certain messages if desired.  (Hiding
//             warnings from the user without giving them a choice about it is strongly
//             discouraged, however; we suggest a Details>>-style foldup dialog.)
//
//             In most cases, LITGen has no contextual sense to report in an error; LITGen
//             can't know what line of the source document it's on, for example.  The
//             implementation of ILITCallback should retrieve file and line information from
//             the parser, and present it along with the error message that comes from litgen.
//
//             The message codes are structured; see the comments in litgen_msgcodes.h.
//
//------------------------------------------------------------------------

 ILITCallback = interface(IUnknown)
   ['{6BC62165-B91C-4993-8002-5BC30B2D1196}']
    //+-----------------------------------------------------------------------
    //
    //  Function:       Message
    //  Description:    receives a warning, error, or informational message
    //  Parameters:     iType - message type indicator:
    //                       0: fatal error
    //                       1: warning
    //                      -1: informational message
    //                  iMessageCode - see above
    //                  pwszMessage - null-terminated message text
    //  Returns:        S_OK
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT Message([in] int iType, [in] int iMessageCode,
    //                [in, string] const wchar_t* pwszMessage);
    function Message(iType, iMessageCode: Integer; const pwszMessage: pwchar): HRESULT; stdcall;
end;

//+-----------------------------------------------------------------------
//
//  Interface: ILITTag
//
//  Summary:   Write-only interface to a tag.  litgen clients should ask
//             ILITParserHost for a blank tag, populate its name and attributes
//             through this interface, then give it back to the host, with Tag().
//
//------------------------------------------------------------------------

 ILITTag = interface(IUnknown)
   ['{D655ECEB-829A-11d3-929B-00C04F68FC0F}']
    //+-----------------------------------------------------------------------
    //
    //  Function:       SetName
    //  Description:    sets the name of a new tag
    //  Parameters:     pwchName, cwchName - pointer to and size of tag name
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_FAIL
    //  Notes:          pwchName need not be terminated.
    //
    //------------------------------------------------------------------------
    //HRESULT SetName([in, size_is(cwchName)] const wchar_t* pwchName, [in] ULONG cwchName);
    function SetName(pwchName: pwchar; cwchName: ULong): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       AddAttribute
    //  Description:    adds an attribute to a new tag
    //  Parameters:     pwchName, cwchName - pointer to and size of attribute name
    //                  pwchValue, cwchValue - pointer to and size of attribute value
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_FAIL
    //  Notes:          pwchName and pwchValue need not be terminated.
    //
    //------------------------------------------------------------------------
    //HRESULT AddAttribute([in, size_is(cwchName)] const wchar_t* pwchName, [in] ULONG cwchName,
    //                    [in, size_is(cwchValue)] const wchar_t* pwchValue, [in] ULONG cwchValue);
    function AddAttribute(const pwchName: pwchar; cwchName: ULong; const pwchValue: pwchar; cwchValue: ULong): HRESULT; stdcall;
end;

//+-----------------------------------------------------------------------
//
//  Interface: ILITHost
//
//  Summary:   Common interface to the three 'identity' properties implemented on
//             all hosts.
//
//------------------------------------------------------------------------

 ILITHost = interface(IUnknown)
   ['{65E8FC16-8661-11d3-929C-00C04F68FC0F}']
    //+-----------------------------------------------------------------------
    //
    //  Function:       GetId
    //  Description:    returns the manifest ID of the item being parsed
    //  Parameters:     pbstr - pointer to BSTR to receive the string
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:          caller must SysFreeString().
    //
    //------------------------------------------------------------------------
    //HRESULT GetId([out, retval] BSTR* pbstrId);
    function GetId(out pbstrId: WideString{bstr}): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       GetFilename
    //  Description:    returns the filename of the item being parsed
    //  Parameters:     pbstr - pointer to BSTR to receive the string
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:          caller must SysFreeString().
    //
    //------------------------------------------------------------------------
    //HRESULT GetFilename([out, retval] BSTR* pbstrFilename);
    function GetFileName(out pbstrFileName: widestring{bstr}): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       GetMimeType
    //  Description:    returns the mime type of the item being parsed
    //  Parameters:     pbstr - pointer to BSTR to receive the string
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:          caller must SysFreeString().
    //
    //------------------------------------------------------------------------
    //HRESULT GetMimeType([out, retval] BSTR* pbstrMimeType);
    function GetMimeType(out pbstrMimeType: WideString{bstr}): HRESULT; stdcall;
end;

//+-----------------------------------------------------------------------
//
//  Interface: ILITParserHost
//
//  Summary:   Host to a content parser.  Both content files and metadata must
//             be parsed by the litgen client, and fed to this interface as a
//             stream of Tag, Text, and EndChildren notifications.
//
//------------------------------------------------------------------------


 ILITParserHost = interface(ILITHost)
   ['{607A85B7-59C1-4b22-B873-A36334740661}']
    //+-----------------------------------------------------------------------
    //
    //  Function:       NewTag
    //  Description:    Creates a new, empty tag.
    //  Parameters:     ppTag - pointer to interface pointer
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_FAIL
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT NewTag([out, retval] IUnknown** ppTag);
    function NewTag(out ppTag: PUnknown): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       Tag
    //  Description:    Accepts notification of a tag in the content stream.
    //  Parameters:     pTag - the populated tag
    //                  fChildren - this should be true if the tag has children
    //                      (either text or nested tags within the tag).
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:          If fChildren is true, a matching EndChildren() will be
    //                  required; if fChildren is false, EndChildren() must not
    //                  be called for this tag.
    //
    //------------------------------------------------------------------------
    //HRESULT Tag([in] IUnknown* pTag, [in] BOOL fChildren);
    function Tag(pTag: IUnknown; fChildren: Bool): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       Text
    //  Description:    Accepts notification of text in the content stream.
    //  Parameters:     pwchText, cwchText - pointer to and length of the text.
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:          Text need not be null-terminated, nor complete; a text
    //                  run can be broken up into several sequential calls to
    //                  Text(), if necessary.
    //
    //------------------------------------------------------------------------
    //HRESULT Text([in] const wchar_t* pwchText, [in] ULONG cwchText);
    function Text(const pwchText: PWChar; cwchText: ULong): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       EndChildren
    //  Description:    Accepts notification of the end of a tag's children.
    //  Parameters:
    //  Returns:        S_OK
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT EndChildren();
    function EndChildren: HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       ExternalStylesheet
    //  Description:    Accepts notification of an external stylesheet that is
    //                  specified more or less independently from the document
    //                  structure - for example, the <?xml-stylesheet?> PI in
    //                  OEB documents.
    //  Parameters:     pTag - a tag populated as if it were a <link> tag
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:          Internally, such stylesheets are actually handled as
    //                  <link> tags; this means that they will be held until
    //                  a <head> is found (or synthesized for this purpose).
    //                  As a result, any warnings arising from this call may
    //                  not be sent to the callback immediately.
    //
    //------------------------------------------------------------------------
    //HRESULT ExternalStylesheet([in] IUnknown* pTag);
    function ExternalStylesheet(pTag: IUnknown): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       Finish
    //  Description:    Finalizes the content
    //  Parameters:
    //  Returns:        S_OK
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT Finish();
    function Finish: HRESULT; stdcall;

end;

//+-----------------------------------------------------------------------
//
//  Interface: ILITCSSHost
//
//  Summary:   Host for receiving CSS stylesheet data.  UTF8 and both forms of
//             UTF16 are supported.
//
//------------------------------------------------------------------------

 ILITCSSHost = interface(ILITHost)
   ['{D7426056-FA2D-4d14-B36C-34D49A20D237}']
    //+-----------------------------------------------------------------------
    //
    //  Function:       Write
    //  Description:    receives the text of the stylesheet
    //  Parameters:     pb, cb - pointer to and size of the data
    //                  pcbWritten - optional pointer to ULONG to receive the
    //                      count of bytes actually written
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT Write([in, size_is(cb)] const BYTE* pb, [in] ULONG cb, [out] ULONG* pcbWritten);
    function Write(const pb: PByte; cb: ULong; out pcbWritten: ULong): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       Finish
    //  Description:    Finalizes the CSS stream
    //  Parameters:
    //  Returns:        S_OK
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:          The CSS is actually parsed during Finish().
    //
    //------------------------------------------------------------------------
    //HRESULT Finish();
    function Finish: HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       GetCurrentLine
    //  Description:    In case of error during Finish(), returns the current
    //                  line of the parser
    //  Parameters:
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_FAIL
    //                  E_NOTIMPL
    //  Notes:          Parse warnings and errors are sent during Finish(), when
    //                  the client may be looking at </style>, for example; this
    //                  method gives the offset in lines from the beginning of
    //                  the CSS data.  The line number is not always available.
    //
    //------------------------------------------------------------------------
    //HRESULT GetCurrentLine([out, retval] ULONG* pcLine);
    function GetCurrenLine(out pcLine: ULong): HRESULT; stdcall;
end;

//+-----------------------------------------------------------------------
//
//  Interface: ILITImageHost
//
//  Summary:   Host for receiving raw image file data.  Image files can be copied
//             verbatim into this host.
//
//------------------------------------------------------------------------

 ILITImageHost = interface(ILITHost)
   ['{D655ECEE-829A-11d3-929B-00C04F68FC0F}']
    //+-----------------------------------------------------------------------
    //
    //  Function:       Write
    //  Description:    receives the raw bytes of the image file
    //  Parameters:     pb, cb - pointer to and size of the data
    //                  pcbWritten - optional pointer to ULONG to receive the
    //                      count of bytes actually written
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_FAIL
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT Write([in, size_is(cb)] const BYTE* pb, [in] ULONG cb, [out] ULONG* pcbWritten);
    function Write(const pb: PByte; cb: ULong; out pcbWritten: ULong): HRESULT; stdcall;
    
end;

//+-----------------------------------------------------------------------
//
//  Interface: ILITWriter
//
//  Summary:   This is the main interface to litgen.  The client should
//             essentially call these methods in order.  The GetNext*Host()
//             methods should be called repeatedly to get hosts for the input
//             files of each type, one at a time.  Each host should be released
//             as soon as it has received all its content.  The filenames are
//             gathered during the parsing of the package file; litgen will
//             choose the file ordering, and each host returned from the
//             GetNext*Host() methods can be asked what file it is meant to
//             receive.
//
//------------------------------------------------------------------------

 ILITWriter = interface(IUnknown)
   ['{9EC81687-D4F9-4b20-969A-222BC00CE50A}']
    //+-----------------------------------------------------------------------
    //
    //  Function:       SetCallback
    //  Description:    receives a pointer to a client-implemented callback interface
    //  Parameters:     pCallback - the interface to receive text messages during
    //                      content preparation
    //  Returns:        S_OK
    //                  E_INVALIDARG - pCallback is not an ILITCallback
    //  Notes:          This call is optional.
    //
    //------------------------------------------------------------------------
    //HRESULT SetCallback([in] IUnknown* pCallback);
    function SetCallback(pCallback: IUnknown): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       Create
    //  Description:    Create a new .LIT file.
    //  Parameters:     pwszLitFile - the output filename
    //                  pwszSourceBasePath - the base path to resolve relative
    //                      links from
    //                  pwszSource - DRM source (optional)
    //                      free text, usually publisher or author name
    //                  iMinimumReaderVersion - one of the following values:
    //                      0 - run on all versions
    //                      1 - run on all versions except the first Pocket PC
    //                          ROM release
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  CO_E_NOTINITIALIZED
    //                  E_FAIL
    //  Notes:          iMinimumReaderVersion can be used to prevent older
    //                  readers from attempting to open books that are known
    //                  to render badly or cause other problems.  For example,
    //                  the Pocket PC reader contained a much weaker CSS parser
    //                  than more recent versions; some CSS constructs,
    //                  particularly invalid CSS, could cause that version to
    //                  fail completely.  As a result, LITGen will refuse to
    //                  build a book containing such constructs, unless this
    //                  value is 1 or above.
    //
    //------------------------------------------------------------------------
    //HRESULT Create([in, string] const wchar_t* pwszLitFile,
    //               [in, string] const wchar_t* pwszSourceBasePath,
    //               [in, string] const wchar_t* pwszSource,
    //               [in] int iMinimumReaderVersion);
    function Create(const pwszLitFile, pwszSourceBasePath, pwszSource: pwchar; iMinimumReaderVersion: Integer): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       GetPackageHost
    //  Description:    returns a parser host to receive the parsed package file
    //  Parameters:     fEnforceOEB - whether errors should be thrown for non-OEB content
    //                  ppHost - pointer to interface pointer of new host
    //  Returns:        S_OK
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED
    //                  E_FAIL
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT GetPackageHost([in] BOOL fEnforceOEB, [out, retval] IUnknown** ppHost);
    function GetPackageHost(fEnforceOEB: Bool; out ppHost: PUnknown): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       GetNextCSSHost
    //  Description:    returns a CSS host to receive the stylesheet text
    //  Parameters:     ppHost - pointer to interface pointer of new host
    //  Returns:        S_OK
    //                  S_FALSE - all CSS has been written, move on to content
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED - package file wasn't done
    //                  E_FAIL
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT GetNextCSSHost([out, retval] IUnknown** ppHost);
    function GetNextCSSHost(out ppHost: PUnknown): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       GetNextContentHost
    //  Description:    returns a parser host to receive the parsed content file
    //  Parameters:     ppHost - pointer to interface pointer of new host
    //  Returns:        S_OK
    //                  S_FALSE - all content has been written, move on to images
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED - not all CSS files were handled
    //                  E_FAIL
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT GetNextContentHost([out, retval] IUnknown** ppHost);
    function GetNextContentHost(out ppHost: PUnknown): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       GetNextImageHost
    //  Description:    returns an image host to receive the raw image file bytes
    //  Parameters:     ppHost - pointer to interface pointer of new host
    //  Returns:        S_OK
    //                  S_FALSE - everything's been written.
    //                  E_INVALIDARG
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED - not all content files were handled
    //                  E_FAIL
    //  Notes:
    //
    //------------------------------------------------------------------------
    //HRESULT GetNextImageHost([out, retval] IUnknown** ppHost);
    function GetNextImageHost(out ppHost: PUnknown): HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       Finish
    //  Description:    Wraps and ties the finished file
    //  Parameters:
    //  Returns:        S_OK
    //                  E_OUTOFMEMORY
    //                  E_UNEXPECTED - not all input files were handled
    //                  E_FAIL
    //  Notes:          This must be called when all content has been written.
    //
    //------------------------------------------------------------------------
    //HRESULT Finish();
    function Finish: HRESULT; stdcall;

    //+-----------------------------------------------------------------------
    //
    //  Function:       Fail
    //  Description:    Cleans up after a failure during content preparation
    //  Parameters:
    //  Returns:        S_OK
    //  Notes:          Call this after any failure to abort and clean up.
    //
    //------------------------------------------------------------------------
    //HRESULT Fail();
    function Fail: HRESULT; stdcall;

end;

//[
//    uuid(1450F9AF-3997-4fc6-B60C-973CAF37D729),
//    helpstring("LITGen Type Library"),
//    lcid(0x0409)
//]
//library LITGen
{
    interface ILITCallback;
    interface ILITTag;
    interface ILITCSSHost;
    interface ILITImageHost;
    interface ILITWriter;
    interface ILITParserHost;
}//;

implementation

end.
