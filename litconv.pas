unit
  litConv;
(*##*)
(*******************************************************************************
*                                                                             *
*   l  i  t  C  o  n  v                                                        *
*                                                                             *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                       *
*   Based on  MS Bookmaker copyright © 1998-2000  Microsoft Corporation       *
*   pascal driver code for .lit generation from OEB source                     *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2002,                                                *
*   Last revision: Oct 29 2002                                                *
*   Lines        : 644                                                         *
*   History      : see todo file                                              *
*                                                                              *
*                                                                             *
*   Printed      :                                                             *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  XMLIntf, msxml, msxmldom, mshtml,
  litgen, litgen_msgcodes,
  customXML, xmlSupported, xmlparse, util1;

const
  DEF_RES_PREFIX = 'd_e_f_a_u_l_t_';
  DEF_COVER_URL = DEF_RES_PREFIX + 'cover.gif';
  DEF_THUMB_URL = DEF_RES_PREFIX + 'thumb.gif';
  DEF_COVER0_URL = DEF_RES_PREFIX + 'cover0.gif';
  DEF_THUMB0_URL = DEF_RES_PREFIX + 'thumb0.gif';
  DEF_TITLE_URL = DEF_RES_PREFIX + 'title.gif';
  DEF_ABOUT_URL = DEF_RES_PREFIX + 'about.htm';
  DEF_CONTENT_URL = DEF_RES_PREFIX + 'content.htm';
var
  LITGENPATH: String = '';  // global variable points to the folder where LITGEN.DLL resides

type
  TGetxmlElementByFileNameCallback = function (const AFileName: String; ADocType: TEditableDoc): TxmlElement of object;
  TGetXmlDocByFileNameCallback = function (const AFileName: String): IUnknown of object; // IXMLDOMDocument or IHTMLDomNode

  { Parameters:
    AIType - message type (error or warning, usually)
      rlError     1  - error
      msgtWARNING 2  - warning
      rlHint      0 - message
    AIMessageCode - exact message number
  }

  TErrHandler = class(TInterfacedObject, ILITCallback)
  private
    m_lRef: Integer;
    FOnMessage: TReportEvent;
  public
    constructor Create(AOnMessage: TReportEvent);
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function Message(iType, iMessageCode: Integer; const pwszMessage: pwchar): HRESULT; stdcall;
  published
    property OnMessage: TReportEvent read FOnMessage write FOnMessage;
  end;

  function ProcessLit(const APackageFileName, AResultLITFileName: String;
    AGetXMLProc: TGetxmlElementByFileNameCallback; AOnMessage: TReportEvent): HRESULT; stdcall;

  function ProcessMSLit(const APackageFileName, AResultLITFileName: String;
    AGetDocProc: TGetXmlDocByFileNameCallback; AOnMessage: TReportEvent): HRESULT; stdcall;

//  function ReplaceSpecialCodes(const S: WideString): WideString;

  // start process lit generation in thread
  // when generation is done, thread call AOnMessage with rlFinishThread firat parameter
  // and free up thread
  // returns started thread. Be care to manage thread!
  function StartProcessLitThread(const APackageFileName, AResultLITFileName: String;
    AGetXMLProc: TGetxmlElementByFileNameCallback; AOnMessage: TReportEvent): TThread; stdcall;

  function StartProcessMSLitThread(const APackageFileName, AResultLITFileName: String;
    AGetDocProc: TGetXmlDocByFileNameCallback; AOnMessage: TReportEvent): TThread; stdcall;

  function LoadFile2String(AFileName: WideString; var ResultStr: String): Boolean;

implementation

uses
  urlmon;

const
  ole32    = 'ole32.dll';
  oleaut32 = 'oleaut32.dll';
  olepro32 = 'olepro32.dll';

  function CoInitialize(pvReserved: Pointer): HResult; stdcall; external ole32 name 'CoInitialize';
  procedure CoUninitialize; stdcall; external ole32 name 'CoUninitialize';

var
  DummyPoint: TPoint = (x:0; y:0);

constructor TErrHandler.Create(AOnMessage: TReportEvent);
begin
  inherited Create;
  FOnMessage:= AOnMessage;
  m_lRef:= 0;
end;

function TErrHandler.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if Integer(Obj) <> 0 then begin
    Result:= E_INVALIDARG;
    Exit;
  end;
  Integer(Obj):= 0;
  if GetInterface(ILITCallback, Obj) or GetInterface(IUnknown, Obj) then;
  if Integer(Obj) = 0 then begin
    Result:= E_NOINTERFACE;
    Exit;
  end;
  Result:= S_OK;
  ILITCallback(Obj)._AddRef;
end;

function TErrHandler._AddRef: Integer;
begin
  Result:= InterlockedIncrement(m_lRef);
end;

function TErrHandler._Release: Integer;
begin
  Result:= InterlockedDecrement(m_lRef);
  if (Result = 0)
  then Free;
end;

{ Message
  Description:    receives diagnostic messages from LITGen
  Parameters:     iType - message type (error or warning, usually)
                  iMessageCode - exact message number
                  wszText - message suitable (usually) for display to a user

}
function TErrHandler.Message(iType, iMessageCode: Integer; const pwszMessage: pwchar): HRESULT;
var
  Msg: WideString;
  cont: Boolean;
begin
  Result:= S_OK;
  if Assigned(FOnMessage) then begin
    cont:= True;
    Inc(iType); // in range of -1 .. 1 -> 0..
    case TReportLevel(iType) of
    rlFinishThread: begin
        Msg:= Format(LITCONV_FMT_THREADDONE, [iMessageCode]);
      end;
    rlHint:begin
        // LITGEN_MSG_MISC_PAGEBREAKS is a message that always follows the success
        // message.  In some situations, this is unimportant; we'll use it to show
        // how to selectively suppress messages.
        if (iMessageCode <> LITGEN_MSG_MISC_PAGEBREAKS) then begin
           Msg:= Format(LITCONV_FMT_MSG, [iMessageCode, pwszMessage]);
           FOnMessage(TReportLevel(IType), Nil, '', 0, DummyPoint, PWideChar(Msg), Cont, Nil);
        end;
        Exit;
      end;
    rlError:begin
        Msg:= Format(LITCONV_FMT_ERR, [iMessageCode, pwszMessage]);
      end;
    rlWarning:begin
        Msg:= Format(LITCONV_FMT_WARN, [iMessageCode, pwszMessage]);
      end;
    end; { case }
    DummyPoint.x:= iMessageCode;
    FOnMessage(TReportLevel(IType), Nil, '', 0, DummyPoint, PWideChar(Msg), Cont, Nil);
  end;
end;

function LoadFile2String(AFileName: WideString; var ResultStr: String): Boolean;
var
  strm: TStream;
  p, L: Integer;
  tmpfn: WideString;
  deltmp: Boolean;
begin
  Result:= False;
  deltmp:= False;
  p:= Pos('://', AFileName);
  tmpfn:= AFileName;

  if ((Pos('file://', Lowercase(tmpfn)) = 1) or (p = 0)) then begin
    // BUGBUG what about UNC ?!!
    // load file from local filesystem
    if p > 0
    then Delete(tmpfn, 1, Length('file://'));
    if not FileExists(tmpfn)
    then Exit;
  end else begin
    // load from internet
    if urlmon.IsValidURL(Nil, PWideChar(tmpfn), 0) = S_OK then begin
      // create file name to keep downloaded file
      if p > 0
      then Delete(tmpfn, 1, p + Length('://') - 1);
      // create temporary file name
      //
      tmpfn:= CreateTemporaryFileName(ExtractFileName(tmpfn));
      // download
      if urlmon.URLDownloadToFileW(Nil, PWideChar(AFileName), PWideChar(tmpfn), 0, Nil) <> S_OK then begin
        DeleteFile(tmpfn);
        Exit;
      end;
      deltmp:= True;
    end else Exit;
  end;

  // now load downloaded or existing local file to string
  try
    Strm:= TFileStream.Create(tmpfn, fmOpenRead + fmShareDenyNone);
    L:= Strm.Size;
    if L <= 0 then begin
      SetLength(ResultStr, 0);
    end else begin
      try
        SetLength(ResultStr, L);
        Strm.Read(ResultStr[1], L);
      except
      end;
    end;
  finally
    Strm.Free;
  end;

  if deltmp then begin
    try
      DeleteFile(tmpfn);
    except
    end;
  end;
  Result:= True;
end;

// incorrect
function LoadFile2WideString(AFileName: String; var ResultStr: WideString): Boolean;
var
  strm: TStream;
  L: Integer;
begin
  Result:= False;
  AFileName:= LowerCase(AFileName);
  if Pos('file://', AFileName) = 1
  then Delete(AFileName, 1, Length('file://'));
  if not FileExists(AFileName)
  then Exit;
  // GetEncoding(s, DefaultEncoding);
  // if IsValidURL(Nil,  PChar(FileName), 0) = S_OK then
  // urlmon.function URLDownloadToFile(Nil, PChar(URL), PChar(FileName), 0, Nil): S_OK or E_OUTOFMEMORY
  try
    Strm:= TFileStream.Create(AFileName, fmOpenRead + fmShareDenyNone);
    L:= Strm.Size;
    if L <= 0 then begin
      SetLength(ResultStr, 0);
      Exit;
    end;
    try
      SetLength(ResultStr, L);
      Strm.Read(ResultStr[1], L);
    except
    end;
  finally
    Strm.Free;
  end;
  Result:= True;
end;

{ CopyCSS
  Description:    LITGen will provide absolute paths to all files, in a degenerate URI
   form; the path will contain a protocol prefix, but any escaped
   characters will have been expanded.  For example, if the package
   stream contained "foo%20bar.css", the path we'd get here might be
   "file://C:\foo\foo bar.css".
   For this sample, we'll only support local files.  Strip off the
   file://, if present (otherwise, just let CreateFile() fail).
}
function CopyCSS(AFileName: WideString; AHost: ILITCSSHost; AOnMessage: TReportEvent): HResult;
var
  s: String;
  written: Cardinal;
  cont: Boolean;
  ws: WideString;
begin
  Result:= S_OK;
  if not LoadFile2String(AFileName, s) then begin
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      cont:= True;
      ws:= Format(LITCONV_ERR_OPENCSS, [Result, AFileName]);
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), Cont, Nil);
      s:= #32;
      Result:= AHost.Write(@(S[1]), 1, written);
      Exit;
    end else raise Exception.CreateFmt(LITCONV_ERR_OPENCSS, [Result, AFileName]);
{$ELSE}
  raise Exception.CreateFmt(LITCONV_ERR_OPENCSS, [Result, AFileName]);
{$ENDIF}
  end;

  try
    if Length(S) = 0
    then s:= #32;
    Result:= AHost.Write(@(S[1]), Length(S), written);
  except
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      cont:= True;
      ws:= Format(LITCONV_ERR_COPYCSS, [Result, AFileName]);
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), Cont, Nil);
      Exit;
    end else raise Exception.CreateFmt(LITCONV_ERR_COPYCSS, [Result, AFileName]);
{$ELSE}
  raise Exception.CreateFmt(LITCONV_ERR_COPYCSS, [Result, AFileName]);
{$ENDIF}

  end;
end;

{ CopyImg
  Description:    LITGen will provide absolute paths to all files, in a degenerate URI
   form; the path will contain a protocol prefix, but any escaped
   characters will have been expanded.  For example, if the package
   stream contained "foo%20bar.gif", the path we'd get here might be
   "file://C:\foo\foo bar.gif".
   For this sample, we'll only support local files.  Strip off the
   file://, if present (otherwise, just let CreateFile() fail).
}
function CopyImg(AFileName: WideString; AHost: ILITImageHost; AOnMessage: TReportEvent): HResult;
var
  s: String;
  written: Cardinal;
  ws: WideString;
  cont: Boolean;
  hm: HMODULE;
  h: HRSRC;
  g: HGLOBAL;
  p: Pointer;
  len: Cardinal;

  procedure ErrorLoadImg(const AFmt: String);
  begin
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(AFmt, [Result, AFileName]);
      cont:= True;
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end else raise Exception.CreateFmt(AFmt, [Result, AFileName]);
{$ELSE}
    raise Exception.CreateFmt(AFmt, [Result, AFileName]);
{$ENDIF}
  end;

begin
  Result:= S_OK;
  if Pos(DEF_RES_PREFIX, AFileName) > 0 then begin
    // find resource
    h:= 0;
    hm:= HInstance;
    if Pos(DEF_COVER_URL, AFileName) > 0
    then h:= FindResource(hm, 'cover', 'GIF');
    if Pos(DEF_THUMB_URL, AFileName) > 0
    then h:= FindResource(hm, 'thumb', 'GIF');
    if Pos(DEF_COVER0_URL, AFileName) > 0
    then h:= FindResource(hm, 'cover0', 'GIF');
    if Pos(DEF_THUMB0_URL, AFileName) > 0
    then h:= FindResource(hm, 'thumb0', 'GIF');
    if Pos(DEF_TITLE_URL, AFileName) > 0
    then h:= FindResource(hm, 'title', 'GIF');;
    if h = 0 then begin
      ErrorLoadImg(LITCONV_ERR_RESNOTF_COPYIMG);
      Exit;
    end;

    len:= SizeofResource(hm, h);
    // load resource
    g:= LoadResource(hm, h);
    if (g = 0) or (len = 0) then begin
      ErrorLoadImg(LITCONV_ERR_RESLOAD_COPYIMG);
      Exit;
    end;
    // lock resource
    p:= LockResource(g);
    // copy resource
    SetLength(s, len);
    Move(p^, s[1], len);
    try
      Result:= AHost.Write(@(S[1]), Length(S), written);
    except
      ErrorLoadImg(LITCONV_ERR_RESCOPY_COPYIMG);
      Exit;
    end;
    Exit;
  end;
  if not LoadFile2String(AFileName, s) then begin
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_ERR_OPENIMG, [Result, AFileName]);
      cont:= True;
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      Exit;
    end else raise Exception.CreateFmt(LITCONV_ERR_OPENIMG, [Result, AFileName]);
{$ELSE}
    raise Exception.CreateFmt(LITCONV_ERR_OPENIMG, [Result, AFileName]);
{$ENDIF}
  end;
  try
    Result:= AHost.Write(@(S[1]), Length(S), written);
  except
    ErrorLoadImg(LITCONV_ERR_COPYIMG);
    Exit;
  end;
end;

function HaveValuableChars(const S: WideString): Boolean;
var
  i: Integer;
begin
  Result:= True;
  for i:= 1 to Length(S) do begin
    if S[i] > #32
    then Exit;
  end;
  Result:= False;
end;

{ DOMWalkTree
  Description:    recursive helper for ParseXMLFile(); recursively walks the DOM
                  tree, pumping notifications into an ILITParserHost.
  Parameters:     pNode - pointer to a root in the DOM tree
                  pHost - LITGen parser host
}
function DOMWalkTree(ANode: IXMLDOMNode; AHost: ILITParserHost; AOnMessage: TReportEvent): HRESULT;
var
  Child: IXMLDOMNode;
  pUnk: PUnknown;
  Tag: ILITTag;
  Attrs: IXMLDOMNamedNodeMap;
  ws: WideString;
  Cont: Boolean;
begin
  Result:= S_OK;
  case ANode.NodeType of
  NODE_DOCUMENT: begin
      // The NODE_DOCUMENT node can have multiple children - e.g. the
      // DTD.  We only want the root element, which must be the only one
      // of type NODE_ELEMENT.
      Child:= ANode.firstChild;
      while Assigned(Child) do begin
        if Child.NodeType = NODE_ELEMENT
        then Break;
        Child:= Child.NextSibling;
      end;
      if (Assigned(Child))
      then DOMWalkTree(Child, AHost, AOnMessage);
    end;
  NODE_ELEMENT: begin
      // NODE_ELEMENT corresponds directly to a tag.
      // Get a new tag from LITGen:
      AHost.NewTag(punk);
      Tag:= ILitTag(pUnk);
      // Get the element name and set the tag name...
      ws:= ANode.NodeName;
      Result:= Tag.SetName(PWideChar(ws), Length(ws));
      if (Result <> S_OK) then begin
        if Assigned(AOnMessage) then begin
          ws:= Format(LITCONV_ERR_WALKSETTAG, [Result, ANode.NodeName]);
          cont:= True;
          AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
          Exit;
        end else raise Exception.CreateFmt(LITCONV_ERR_WALKSETTAG, [Result, ANode.NodeName]);
      end;
      // if we have attributes, loop through and add each one:
      Attrs:= ANode.attributes;
      if Assigned(Attrs) then begin
        while true do begin
          child:= Attrs.nextNode;
          if not Assigned(Child)
          then Break;
          if child.NodeType <> NODE_ATTRIBUTE
          then Continue;
          // BUGBUG: will this conversion do the right thing, even
          // in the presence of a DTD that results in other variant
          // types in the attribute value?
          ws:= child.nodeValue;
          Result:= Tag.AddAttribute(PWideChar(child.NodeName), Length(child.NodeName),
            PWideChar(ws), Length(ws));
          if (Result <> S_OK) then begin
            if Assigned(AOnMessage) then begin
              ws:= Format(LITCONV_ERR_WALKSETATTR, [Result, child.NodeName]);
              cont:= True;
              AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
              Exit;
            end else raise Exception.CreateFmt(LITCONV_ERR_WALKSETATTR, [Result, child.NodeName]);
          end;
        end;
      end;
      // Send the tag back to LITGen.  If the element has no children,
      // it's more efficient to say so in the Tag() call, so we'll find
      // that out first:
      child:= ANode.firstChild;  //
      AHost.Tag(Tag, Assigned(child) or HaveValuableChars(ANode.Text));

      // If we have children, loop through and handle each one...
      // Recurse for all the children of this tag..
      if Assigned(child) then begin
        while true do begin
          if not Assigned(child)
          then Break;
          DOMWalkTree(child, AHost, AOnMessage);
          child:= child.nextSibling;
        end;
        // After we send all children of a tag, we must call
        // EndChildren().  Note that we only do this if we sent TRUE
        // to Tag() above.
        Result:= AHost.EndChildren;
        if (Result <> S_OK) then begin
          if Assigned(AOnMessage) then begin
            ws:= Format(LITCONV_ERR_WALKCLOSETAG, [Result, ANode.NodeName]);
            cont:= True;
            AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
            Exit;
          end else raise Exception.CreateFmt(LITCONV_ERR_WALKCLOSETAG, [Result, ANode.NodeName]);
        end;
      end;
    end;
  NODE_TEXT,   // Each of these types is different in some irrelevant way - to us, they're all just text.
  NODE_CDATA_SECTION,
  NODE_ENTITY_REFERENCE: begin
      { fetch all the text and send it to the host. The node we're looking at may not be a leaf, but Gettext() will traverse a subtree if necessary to make it appear atomic. }
      // ws:= ReplaceSpecialCodes(ANode.Text);
      ws:= ANode.Text;
      if HaveValuableChars(ws) then begin
        Result:= AHost.Text(PWideChar(ws), Length(ws));
        if (Result <> S_OK) then begin
          if Assigned(AOnMessage) then begin
            ws:= Format(LITCONV_ERR_WALKSENDTEXT, [Result, ws]);
            cont:= True;
            AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
            Exit;
          end else raise Exception.CreateFmt(LITCONV_ERR_WALKSENDTEXT, [Result, ws]);
        end;
      end;
    end;
  end; { case }
end;

{ HTMLDOMWalkTree
  Description:    recursive helper for ParseXMLFile(); recursively walks the DOM
                  tree, pumping notifications into an ILITParserHost.
  Parameters:     pNode - pointer to a root in the DOM tree
                  pHost - LITGen parser host
}
function HTMLDOMWalkTree(ANode: IHTMLDOMNode; AHost: ILITParserHost; AOnMessage: TReportEvent): HRESULT;
var
  Child: IHTMLDOMNode;
  c: OleVariant;
  pUnk: PUnknown;
  Tag: ILITTag;
  Attrs: IHTMLAttributeCollection;
  n, v: WideString;
  Cont: Boolean;
begin
  Result:= S_OK;
  case ANode.NodeType of
  NODE_DOCUMENT: begin
      // The NODE_DOCUMENT node can have multiple children - e.g. the
      // DTD.  We only want the root element, which must be the only one
      // of type NODE_ELEMENT.
      Child:= ANode.firstChild;
      while Assigned(Child) do begin
        if Child.NodeType = NODE_ELEMENT
        then Break;
        Child:= Child.NextSibling;
      end;
      if (Assigned(Child))
      then HTMLDOMWalkTree(Child, AHost, AOnMessage);
    end;
  NODE_ELEMENT: begin
      // NODE_ELEMENT corresponds directly to a tag.
      // Get a new tag from LITGen:
      AHost.NewTag(punk);
      Tag:= ILitTag(pUnk);
      // Get the element name and set the tag name...
      n:= ANode.NodeName;
      Result:= Tag.SetName(PWideChar(n), Length(n));
      if (Result <> S_OK) then begin
        if Assigned(AOnMessage) then begin
          n:= Format(LITCONV_ERR_WALKSETTAG, [Result, ANode.NodeName]);
          cont:= True;
          AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(n), cont, Nil);
          Exit;
        end else raise Exception.CreateFmt(LITCONV_ERR_WALKSETTAG, [Result, ANode.NodeName]);
      end;
      // if we have attributes, loop through and add each one:
      Attrs:= ANode.attributes as IHTMLAttributeCollection;
      if Assigned(Attrs) then begin
        c:= 0;
        while c < Attrs.length do begin
          // BUGBUG: will this conversion do the right thing, even
          // in the presence of a DTD that results in other variant
          // types in the attribute value?
          with (Attrs.item(c) as IHTMLDomAttribute) do begin
            if specified then begin
              n:= nodename;
              v:= nodevalue;
              Result:= Tag.AddAttribute(PWideChar(n), Length(n), PWideChar(v), Length(v));
              if (Result <> S_OK) then begin
                if Assigned(AOnMessage) then begin
                  n:= Format(LITCONV_ERR_WALKSETATTR, [Result, n]);
                  cont:= True;
                  AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(n), cont, Nil);
                  Exit;
                end else raise Exception.CreateFmt(LITCONV_ERR_WALKSETATTR, [Result, n]);
              end;
            end;
          end;
          Inc(c);
        end;
      end;
      // Send the tag back to LITGen.  If the element has no children,
      // it's more efficient to say so in the Tag() call, so we'll find
      // that out first:
      child:= ANode.firstChild;  //
      AHost.Tag(Tag, Assigned(child)); // or HaveValuableChars(ANode.nodeValue) 

      // If we have children, loop through and handle each one...
      // Recurse for all the children of this tag..
      if Assigned(child) then begin
        while true do begin
          if not Assigned(child)
          then Break;
          HTMLDOMWalkTree(child, AHost, AOnMessage);
          child:= child.nextSibling;
        end;
        // After we send all children of a tag, we must call
        // EndChildren().  Note that we only do this if we sent TRUE
        // to Tag() above.
        Result:= AHost.EndChildren;
        if (Result <> S_OK) then begin
          if Assigned(AOnMessage) then begin
            n:= Format(LITCONV_ERR_WALKCLOSETAG, [Result, ANode.NodeName]);
            cont:= True;
            AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(n), cont, Nil);
            Exit;
          end else raise Exception.CreateFmt(LITCONV_ERR_WALKCLOSETAG, [Result, ANode.NodeName]);
        end;
      end;
    end;
  NODE_TEXT,   // Each of these types is different in some irrelevant way - to us, they're all just text.
  NODE_CDATA_SECTION,
  NODE_ENTITY_REFERENCE: begin
      { fetch all the text and send it to the host. The node we're looking at may not be a leaf, but Gettext() will traverse a subtree if necessary to make it appear atomic. }
      // ws:= ReplaceSpecialCodes(ANode.Text);
      n:= ANode.nodeValue;  // Text
      if HaveValuableChars(n) then begin
        Result:= AHost.Text(PWideChar(n), Length(n));
        if (Result <> S_OK) then begin
          if Assigned(AOnMessage) then begin
            n:= Format(LITCONV_ERR_WALKSENDTEXT, [Result, n]);
            cont:= True;
            AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(n), cont, Nil);
            Exit;
          end else raise Exception.CreateFmt(LITCONV_ERR_WALKSENDTEXT, [Result, n]);
        end;
      end;
    end;
  end; { case }
end;

{ ParseXMLDoc
  Description:    Loads an XML source document into a DOM document, then
                  feeding its content into the parser host.
  Parameters:     pwszURL - wide string holding the name of the file to open
                  pHost - parser host from LITGen
}
function ParseXMLDoc(ADoc: IUnknown; AHost: ILITParserHost; AOnMessage: TReportEvent): HRESULT; // IXMLDOMDocument or IHTMLDOMNode
var
  int: IUnknown;
begin
  ADoc.QueryInterface(IXMLDOMDocument, int);
  if (int <> Nil)
  then Result:= DOMWalkTree(ADoc as IXMLDOMDocument, AHost, AOnMessage)
  else Result:= HTMLDOMWalkTree(ADoc as IHTMLDOMNode, AHost, AOnMessage);
end;

{ ParseXMLFile
  Description:    Loads an XML source document into a DOM document, then
                  feeding its content into the parser host.
  Parameters:     pwszURL - wide string holding the name of the file to open
                  pHost - parser host from LITGen
}
function ParseXMLFile(const AFn: String; AHost: ILITParserHost; AOnMessage: TReportEvent): HRESULT;
var
  Doc: IXMLDOMDocument;
  ParseError: IXMLDOMParseError;
  ws: WideString;
  cont: Boolean;
begin
  // Create the XML DOM document...
  Doc:= msxmldom.CreateDOMDocument;
  if (not Assigned(Doc)) then begin
    if Assigned(AOnMessage) then begin
      ws:= LITCONV_ERR_XMLCREATEDOM;
      cont:= True;
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      Result:= E_FAIL;
      Exit;
    end else raise Exception.CreateFmt(LITCONV_ERR_XMLCREATEDOM, []);
  end;
  // We don't have any use for asynchronous load; just block for it.
  // We don't need to do XML-style validation (actually, OEB documents don't even have to be valid in the XML sense).
  Doc.async:= False;
  Doc.validateOnParse:= False;
  Doc.preserveWhiteSpace:= True;
  Doc.resolveExternals:= False;

  if not Doc.Load(AFn) then begin
    ParseError:= Doc.parseError;
    if Assigned(AOnMessage) then begin
      Result:= E_FAIL;
      ws:= Format(LITCONV_ERR_XMLLOAD, [AFn, ParseError.errorCode, ParseError.line, ParseError.Reason]);
      cont:= True;
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      Exit;
    end else raise Exception.CreateFmt(LITCONV_ERR_XMLLOAD,
        [AFn, ParseError.errorCode, ParseError.line, ParseError.Reason]);
  end;
  // we have a good load; recurse through the tree.
  Result:= ParseXMLDoc(Doc, AHost, AOnMessage);
end;

type
  TXML2LITWalker = class(TPersistent)
  private
    FHost: ILITParserHost;
    FOnMessage: TReportEvent;
  public
    constructor Create(AHost: ILITParserHost; AOnMessage: TReportEvent);
    procedure Element2LitCallback(var AWMLElement: TxmlElement);
    procedure EndElementCallback(var AWMLElement: TxmlElement);
  end;

constructor TXML2LITWalker.Create(AHost: ILITParserHost; AOnMessage: TReportEvent);
begin
  inherited Create;
  FHost:= AHost;
  FOnMessage:= AOnMessage;
end;

procedure TXML2LITWalker.Element2LitCallback(var AWMLElement: TxmlElement);
var
  pUnk: PUnknown;
  a: Integer;
  Tag: ILITTag;
  ws, attrname: WideString;
  cont: Boolean;
  HR: HResult;
begin
  if AWMLElement is TxmlContainer
  then Exit;

  if AWMLElement is TxmlPCDATA then begin
    // these types all just text to us
    // fetch all the text and send it to the host.
    ws:= AWMLElement.Attributes.ValueByNameEntity['value'];
    if True or HaveValuableChars(ws) then begin
      HR:= FHost.Text(PWideChar(ws), Length(ws));
      if (HR <> S_OK) then begin
        if Assigned(FOnMessage) then begin
          ws:= Format(LITCONV_ERR_WALKSENDTEXT, [HR, ws]);
          cont:= True;
          FOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
          Exit;
        end else raise Exception.CreateFmt(LITCONV_ERR_WALKSENDTEXT, [HR, ws]);
      end;
    end
  end else begin
    // NODE_ELEMENT corresponds directly to a tag.
    // Get a new tag from LITGen:
    FHost.NewTag(punk);
    Tag:= ILitTag(pUnk);
    // Get the element name and set the tag name...
    ws:= AWMLElement.GetElementName;
    HR:= Tag.SetName(PWideChar(ws), Length(ws));
    if (HR <> S_OK) then begin
      if Assigned(FOnMessage) then begin
        ws:= Format(LITCONV_ERR_WALKSETTAG, [HR, AWMLElement.GetElementName]);
        cont:= True;
        FOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
        Exit;
      end else raise Exception.CreateFmt(LITCONV_ERR_WALKSETTAG, [HR, AWMLElement.GetElementName]);
    end;
    // if we have attributes, loop through and add each one:
    if AWMLElement.Attributes.CountValuable > 0 then begin
      for a:= 0 to AWMLElement.Attributes.Count - 1 do begin
        ws:= AWMLElement.Attributes.Items[a].Value;
        if Length(ws) <= 0
        then Continue;
        attrname:= AWMLElement.Attributes.Items[a].Name;
        HR:= Tag.AddAttribute(PWideChar(attrname), Length(attrName),
          PWideChar(ws), Length(ws));
        if (HR <> S_OK) then begin
          if Assigned(FOnMessage) then begin
            ws:= Format(LITCONV_ERR_WALKSETATTR, [HR, AWMLElement.GetElementName]);
            cont:= True;
            FOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
            Exit;
          end else raise Exception.CreateFmt(LITCONV_ERR_WALKSETATTR, [HR, AWMLElement.GetElementName]);
        end;
      end;
    end;
    // Send the tag back to LITGen.  If the element has no children,
    // it's more efficient to say so in the Tag() call, so we'll find
    // that out first:
    FHost.Tag(Tag, AWMLElement.NestedElements1Count > 0);
  end; // ordinal element
end;

procedure TXML2LITWalker.EndElementCallback(var AWMLElement: TxmlElement);
var
  HR: HResult;
  cont: Boolean;
  ws: WideString;
begin
  // After we send all children of a tag, we must call
  // EndChildren().  Note that we only do this if we sent TRUE to Tag() above.
  if (AWMLElement.NestedElements1Count <= 0) or (AWMLElement is TxmlContainer)
  then Exit;
  HR:= FHost.EndChildren;
  if (HR <> S_OK) then begin
    if Assigned(FOnMessage) then begin
      ws:= Format(LITCONV_ERR_WALKCLOSETAG, [HR, AWMLElement.GetElementName]);
      cont:= True;
      FOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      Exit;
    end else raise Exception.CreateFmt(LITCONV_ERR_WALKCLOSETAG, [HR, AWMLElement.GetElementName]);
  end;
end;

{ ParseXMLElement
  Description:    Feeding its content into the parser host.
  Parameters:     pwszURL - wide string holding the name of the file to open
                  pHost - parser host from LITGen
}
function ParseXMLElement(const AxmlElement: TxmlElement; AHost: ILITParserHost; AOnMessage: TReportEvent): HRESULT;
var
  ws: WideString;
  cont: Boolean;
  xml2LitWalker: TXML2LITWalker;
begin
  // Check is element exists
  if (not Assigned(AxmlElement)) then begin
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= LITCONV_ERR_XMLGETELEMENT;
      cont:= True;
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      Result:= E_FAIL;
      Exit;
    end else raise Exception.CreateFmt(LITCONV_ERR_XMLGETELEMENT, []);
{$ELSE}
    raise Exception.CreateFmt(LITCONV_ERR_XMLGETELEMENT, []);
{$ENDIF}
  end;

  xml2LitWalker:= TXML2LITWalker.Create(AHost, AOnMessage);
  // recurse through the tree
  with xml2LitWalker do begin
    AxmlElement.ForEachInOut(Element2LitCallback, EndElementCallback);
  end;
  xml2LitWalker.Free;
  Result:= S_OK;
end;

var
  g_hLITGen: HINST = 0;

{ GetWriter
  Description:    helper routine to load LITGen and get the main object.
                  LITGen avoids using the COM instantiation to avoid
                  systemwide component registration and the resulting
                  versioning and compatibility headaches; the price we pay
                  for that is this rather messy instantiation routine.
}
{$OPTIMIZATION OFF}
function GetWriter(var AILITWriter: ILITWriter; AOnMessage: TReportEvent): HRESULT;
var
  szLitgenFilename: array [0..MAX_PATH] of Char;
  fn: String;
  UnkWriter: IUnknown;
  CreateWriter: TFuncCreateWriter;
  ws: WideString;
  Cont: Boolean;
begin
  AILITWriter:= Nil;
  Result:= E_FAIL;
  if (g_hLITGen = 0) then begin
    { most applications should install litgen.dll alongside the executable
     that loads it.  In this case, since this is an SDK sample, we'll
     load from a common location.  It's safest to always LoadLibrary()
     with the full path, though, regardless of where the DLL is.
    }
    if (Length(LITGENPATH) = 0) then begin
      GetModuleFileName(0, szLitgenFilename, MAX_PATH);
      fn:= ConcatPath(ExtractFilePath(szLitgenFilename), LITGENDLLPATH, '\');  // 'litgen.dll'
    end else begin
      fn:= ConcatPath(LITGENPATH, LITGENDLLPATH, '\');  // 'litgen.dll';
    end;
    g_hLITGen:= LoadLibrary(PChar(fn));
    if (g_hLITGen = 0) then begin
      // if not found,
      g_hLITGen:= LoadLibrary(PChar(LITGENDLLPATH));  // let try fond out in Windows default paths
    end;
  end;
  if (g_hLITGen = 0) then begin
    Result:= GetLastError;
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_ERR_LOADDLL, [Result, fn]);
      cont:= True;
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      Exit;
    end else begin
      raise Exception.CreateFmt(LITCONV_ERR_LOADDLL, [Result, fn]);
    end;
{$ELSE}
  raise Exception.CreateFmt(LITCONV_ERR_LOADDLL, [Result, fn]);
{$ENDIF}

  end;
  CreateWriter:= TFuncCreateWriter(GetProcAddress(g_hLITGen, PChar(LITGENDLLENTRY)));  // 'CreateWriter'
  if (not Assigned(CreateWriter)) then begin
    Result:= GetLastError;
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_ERR_GETENTRY, [Result]);
      cont:= True;
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      Exit;
    end else begin
      raise Exception.CreateFmt(LITCONV_ERR_GETENTRY, [Result]);
    end;
{$ELSE}
  raise Exception.CreateFmt(LITCONV_ERR_GETENTRY, [Result]);
{$ENDIF}
  end;
  Result:= CreateWriter(UnkWriter);
  if (Result <> S_OK) then begin
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_ERR_CREATEWRITER, [Result]);
      cont:= True;
      AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      Exit;
    end else raise Exception.CreateFmt(LITCONV_ERR_CREATEWRITER, [Result]);
{$ELSE}
  raise Exception.CreateFmt(LITCONV_ERR_CREATEWRITER, [Result]);
{$ENDIF}
  end;
  AILITWriter:= ILITWriter(UnkWriter);
end;
{$OPTIMIZATION ON}

{$OPTIMIZATION OFF}  // I hope it is not neccessary now. EBX is not destroyed in ProcessLIT itself,
// GetWriter() destroys EBX
function ProcessLit(const APackageFileName, AResultLITFileName: String;
  AGetXMLProc: TGetxmlElementByFileNameCallback; AOnMessage: TReportEvent): HRESULT;
label
  stop;
var
  NeedToUninitialize,
  Cont: Boolean;
  pUnk: PUnknown;
  Writer: ILITWriter;
  ParserHost: ILITParserHost;
  CSSHost: ILITCSSHost;
  ImageHost: ILITImageHost;
  ErrHandler: ILITCallback;
  FileName, PackageFn, LitFn, CSSFn,
  ImgFN, ImgMIME, ImgId, ws: WideString;

  function CheckHR(AHR: Integer; AFormat: String; AArg: array of const): Boolean;
  var
    ws: WideString;
    Cont: Boolean;
  begin
    Result:= AHR <> S_OK;
    if Result then begin
      // if Assigned(Writer) then Writer.Fail;
{$IFNDEF NOSENDMSG}
      if Assigned(AOnMessage) then begin
        ws:= Format(AFormat, AArg);
        cont:= True;
        AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      end else begin
        raise Exception.CreateFmt(AFormat, AArg);
      end;
{$ELSE}
      raise Exception.CreateFmt(AFormat, AArg);
{$ENDIF}
    end;
  end;

  function StopCSS: HResult;
  begin
    Result:= CSSHost.Finish;
    CheckHR(Result, LITCONV_ERR_FINISHCSS, [Result, PackageFn]);
    CSSHost._Release;
    CSSHost:= Nil;
  end;

  function StopContent: HResult;
  begin
    Result:= ParserHost.Finish;
    CheckHR(Result, LITCONV_ERR_FINISHCONTENT, [Result, PackageFn]);
    ParserHost._Release;
    ParserHost:= Nil;
  end;

  procedure StopImage;
  begin
    ImageHost._Release;
    ImageHost:= Nil;
  end;

begin
  NeedToUninitialize:= Succeeded(CoInitialize(nil));
  // if Result = S_FALSE then Result:= S_OK; // allready initialized
  // CheckHR(Result, LITCONV_ERR_INITCOM, [Result]);
  // resolve and widen filenames...
  PackageFn:= ExpandFileName(APackageFileName);
  LitFn:= ExpandFileName(AResultLITFileName);

  // Create a writer
  Result:= GetWriter(Writer, AOnMessage);
  if CheckHR(Result, LITCONV_ERR_GETWRITER, [Result]) then begin
    // Writer:= Null; // ?!! indicate that writer is not initialized. But assign Nil == destroy object
    goto stop;
  end;

  // Tell the writer about our callback
  ErrHandler:= TErrHandler.Create(AOnMessage);
  Result:= Writer.SetCallback(ErrHandler);
  if CheckHR(Result, LITCONV_ERR_SETMSGCALLBACK, [Result]) then begin
    goto stop;
  end;

  // do check is file allready opened and can not be opened to write
  // ...
  // it does not works actually and it is unneccessary - Reader does not locks file
  {
  h:= CreateFileW(PWideChar(LITFN), GENERIC_WRITE, 0, Nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if h = INVALID_HANDLE_VALUE then begin
    ws:= Format(LITCONV_ERR_CREATEOUTPUT, [GetLastError, LITFN]);
    cont:= True;
    AOnMessage(rlHint, Nil, '', DummyPoint, PWideChar(ws), cont);
    goto stop;
  end else CloseHandle(h);
  }
  //

  // Create the output file
  Result:= Writer.Create(PWideChar(LITFN), PWideChar(PackageFN), PWideChar(DRMSOURCE), 0);
  if CheckHR(Result, LITCONV_ERR_CREATEOUTPUT, [Result, AResultLITFileName]) then begin
    goto stop;
  end;


  // Get the package host...
  punk:= Nil;
  Result:= Writer.GetPackageHost(False, punk);
  if CheckHR(Result, LITCONV_ERR_GETPKG, [Result]) then begin
    goto stop;
  end;

  ParserHost:= ILitParserHost(punk);
  // Parse the package file at the package host...
  if FileExists(PackageFn) then begin
    Result:= ParseXMLFile(PackageFn, ParserHost, AOnMessage);
  end else begin
    if Assigned(AGetXMLProc)
    then Result:= ParseXMLElement(AGetXMLProc(PackageFn, edPkg), ParserHost, AOnMessage)
    else Result:= S_FALSE;
  end;

  if CheckHR(Result, LITCONV_ERR_PARSEPKG, [Result, PackageFn]) then begin
    // finish the host
    Result:= ParserHost.Finish;
    CheckHR(Result, LITCONV_ERR_PROCESSPKG, [Result, PackageFn]);
    goto stop;
  end;
  // ...and finish the host.
  Result:= ParserHost.Finish;
  if CheckHR(Result, LITCONV_ERR_PROCESSPKG, [Result, PackageFn]) then begin
    goto stop;
  end;
  // now loop through our content.  We loop through all CSS, then all content, then all images; the ILITWriter dictates the order.
  // CSS first:
  while True do begin
    // Get the next host.
    Result:= Writer.GetNextCSSHost(pUnk);
    // If there is no next host, we'll get S_FALSE; continue on to
    // content.
    if (Result = S_FALSE) or (pUnk = Nil)
    then Break;
    if CheckHR(Result, LITCONV_ERR_GETCSS, [Result]) then begin
      goto stop;
    end;
    // Get the real interface and release the old one.
    CSSHost:= ILITCSSHost(pUnk);

    // Fetch the filename for this CSS file...
    Result:= CSSHost.GetFilename(CSSFn);
    if CheckHR(Result, LITCONV_ERR_GETCSSFILENAME, [Result]) then begin
      StopCSS;
      goto stop;
    end;

{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_COPYCSS, [CSSFn]);
      cont:= True;
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$ENDIF}

    // Copy the CSS text...
{$IFNDEF NOSENDMSG}{$ENDIF}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_COPYCSS, [CSSFn]);
      cont:= True;
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$IFNDEF NOSENDMSG}{$ENDIF}
    Result:= CopyCSS(CSSFn, CSSHost, AOnMessage);
    if CheckHR(Result, LITCONV_ERR_COPYCSS, [Result, CSSFn]) then begin
      StopCSS;
      goto stop;
    end;
    // ...and finish the host.
    Result:= StopCSS;
  end;
  // The CSS is done, content
  while True do begin
    // Get the next host.
    Result:= Writer.GetNextContentHost(pUnk);
    if (Result = S_FALSE)
    then Break;  // no more text streams, must begin processing image streams
    if CheckHR(Result, LITCONV_ERR_GETCONTENT, [Result]) then begin
      goto stop;
    end;
    // If there is no next host, we'll get S_FALSE; continue on to
    // images.

    // Get the real interface and release the old one.
    ParserHost:= ILITParserHost(pUnk);

    // Fetch the filename for this content file...
    Result:= ParserHost.GetFilename(FileName);
    if CheckHR(Result, LITCONV_ERR_GETCONTENTFILENAME, [Result]) then begin
      StopContent;
      goto stop;
    end;

    // parse the content at the host...
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_PROCESSCONTENT, [FileName]);
      cont:= True;
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$ENDIF}
    if FileExists(FileName)
    then Result:= ParseXMLFile(FileName, ParserHost, AOnMessage)
    else begin
      if Assigned(AGetXMLProc)
      then Result:= ParseXMLElement(AGetXMLProc(FileName, edOEB), ParserHost, AOnMessage)
      else Result:= S_FALSE;
    end;

    if CheckHR(Result, LITCONV_ERR_PROCESSCONTENT, [Result, FileName]) then begin
      StopContent;
      goto stop;
    end;
    // ..and finish the host.
    Result:= StopContent;
  end;

  // Nothing left but images:
  pUnk:= Nil;
  while True do begin
    // Get the next host.
    Result:= Writer.GetNextImageHost(pUnk);
    if (Result = S_FALSE)
    then Break;
    if CheckHR(Result, LITCONV_ERR_GETIMAGE, [Result]) then begin
      goto stop;
    end;
    // If there is no next host, we'll get S_FALSE; we've written
    // everything.

    // Get the real interface and release the old one.
    ImageHost:= ILITImageHost(pUnk);

    // Fetch the filename for this image file...
    Result:= ImageHost.GetFilename(ImgFN);
    if CheckHR(Result, LITCONV_ERR_GETIMAGEFILENAME, [Result]) then begin
      StopImage;
      goto stop;
    end;
    // Copy the image stream...

    Result:= ImageHost.GetId(ImgId);
    Result:= ImageHost.GetMimeType(ImgMIME);
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_COPYIMAGE, [ImgMIME, ImgFN, ImgId]);
      cont:= True;
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$ENDIF}
    Result:= CopyImg(ImgFN, ImageHost, AOnMessage);
    if CheckHR(Result, LITCONV_ERR_FINISHIMAGE, [Result]) then begin
      StopImage;
      goto stop;
    end;
    // ...and we're done (image hosts don't get Finish(), for
    // historical reasons).
    StopImage;
  end;

  // Everything's done; finalize the file.
  Result:= Writer.Finish;
stop:
  if Result <> S_OK then begin
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_FAILED, [Result, PackageFn]);
      cont:= True;
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$ENDIF}
    if Assigned(Writer) then begin
      Writer.Fail;
    end;
  end;

  if Assigned(Writer) then begin
    Writer._Release;  // the same thing is Writer:= Nil; ?
    Writer:= Nil;     // it can cause AVE
  end;
  if NeedToUninitialize then CoUninitialize;

  // send done message to inform caller that conversion was done
  // be care- take a snap while thread will finished
  if Assigned(AOnMessage) then begin
    ws:= Format(LITCONV_MSG_THREADDONE, [Result, APackageFileName]);
    cont:= True;
    AOnMessage(rlFinishThread, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
  end;
end;

// GetWriter() destroys EBX
function ProcessMSLit(const APackageFileName, AResultLITFileName: String;
  AGetDocProc: TGetXmlDocByFileNameCallback; AOnMessage: TReportEvent): HRESULT;
label
  stop;
var
  NeedToUninitialize,
  Cont: Boolean;
  pUnk: PUnknown;
  Writer: ILITWriter;
  ParserHost: ILITParserHost;
  CSSHost: ILITCSSHost;
  ImageHost: ILITImageHost;
  ErrHandler: ILITCallback;
  FileName, PackageFn, LitFn, CSSFn,
  ImgFN, ImgMIME, ImgId, ws: WideString;

  function CheckHR(AHR: Integer; AFormat: String; AArg: array of const): Boolean;
  var
    ws: WideString;
    Cont: Boolean;
  begin
    Result:= AHR <> S_OK;
    if Result then begin
      // if Assigned(Writer) then Writer.Fail;
{$IFNDEF NOSENDMSG}
      if Assigned(AOnMessage) then begin
        ws:= Format(AFormat, AArg);
        cont:= True;
        AOnMessage(rlError, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
      end else begin
        raise Exception.CreateFmt(AFormat, AArg);
      end;
{$ELSE}
      raise Exception.CreateFmt(AFormat, AArg);
{$ENDIF}
    end;
  end;

  function StopCSS: HResult;
  begin
    Result:= CSSHost.Finish;
    CheckHR(Result, LITCONV_ERR_FINISHCSS, [Result, PackageFn]);
    CSSHost._Release;
    CSSHost:= Nil;
  end;

  function StopContent: HResult;
  begin
    Result:= ParserHost.Finish;
    CheckHR(Result, LITCONV_ERR_FINISHCONTENT, [Result, PackageFn]);
    ParserHost._Release;
    ParserHost:= Nil;
  end;

  procedure StopImage;
  begin
    ImageHost._Release;
    ImageHost:= Nil;
  end;

begin
  NeedToUninitialize:= Succeeded(CoInitialize(nil));
  // if Result = S_FALSE then Result:= S_OK; // allready initialized
  // CheckHR(Result, LITCONV_ERR_INITCOM, [Result]);
  // resolve and widen filenames...
  PackageFn:= ExpandFileName(APackageFileName);
  LitFn:= ExpandFileName(AResultLITFileName);

  // Create a writer
  Result:= GetWriter(Writer, AOnMessage);
  if CheckHR(Result, LITCONV_ERR_GETWRITER, [Result]) then begin
    // Writer:= Null; // ?!! indicate that writer is not initialized. But assign Nil == destroy object
    goto stop;
  end;

  // Tell the writer about our callback
  ErrHandler:= TErrHandler.Create(AOnMessage);
  Result:= Writer.SetCallback(ErrHandler);
  if CheckHR(Result, LITCONV_ERR_SETMSGCALLBACK, [Result]) then begin
    goto stop;
  end;

  // do check is file allready opened and can not be opened to write
  // ...
  // it does not works actually and it is unneccessary - Reader does not locks file
  {
  h:= CreateFileW(PWideChar(LITFN), GENERIC_WRITE, 0, Nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if h = INVALID_HANDLE_VALUE then begin
    ws:= Format(LITCONV_ERR_CREATEOUTPUT, [GetLastError, LITFN]);
    cont:= True;
    AOnMessage(rlHint, Nil, '', DummyPoint, PWideChar(ws), cont);
    goto stop;
  end else CloseHandle(h);
  }
  //

  // Create the output file
  Result:= Writer.Create(PWideChar(LITFN), PWideChar(PackageFN), PWideChar(DRMSOURCE), 0);
  if CheckHR(Result, LITCONV_ERR_CREATEOUTPUT, [Result, AResultLITFileName]) then begin
    goto stop;
  end;


  // Get the package host...
  punk:= Nil;
  Result:= Writer.GetPackageHost(False, punk);
  if CheckHR(Result, LITCONV_ERR_GETPKG, [Result]) then begin
    goto stop;
  end;

  ParserHost:= ILitParserHost(punk);
  // Parse the package file at the package host...
  if FileExists(PackageFn) then begin
    Result:= ParseXMLFile(PackageFn, ParserHost, AOnMessage);
  end else begin
    if Assigned(AGetDocProc)
    then Result:= ParseXMLDoc(AGetDocProc(PackageFn), ParserHost, AOnMessage)
    else Result:= S_FALSE;
  end;

  if CheckHR(Result, LITCONV_ERR_PARSEPKG, [Result, PackageFn]) then begin
    // finish the host
    Result:= ParserHost.Finish;
    CheckHR(Result, LITCONV_ERR_PROCESSPKG, [Result, PackageFn]);
    goto stop;
  end;
  // ...and finish the host.
  Result:= ParserHost.Finish;
  if CheckHR(Result, LITCONV_ERR_PROCESSPKG, [Result, PackageFn]) then begin
    goto stop;
  end;
  // now loop through our content.  We loop through all CSS, then all content, then all images; the ILITWriter dictates the order.
  // CSS first:
  while True do begin
    // Get the next host.
    Result:= Writer.GetNextCSSHost(pUnk);
    // If there is no next host, we'll get S_FALSE; continue on to
    // content.
    if (Result = S_FALSE) or (pUnk = Nil)
    then Break;
    if CheckHR(Result, LITCONV_ERR_GETCSS, [Result]) then begin
      goto stop;
    end;
    // Get the real interface and release the old one.
    CSSHost:= ILITCSSHost(pUnk);

    // Fetch the filename for this CSS file...
    Result:= CSSHost.GetFilename(CSSFn);
    if CheckHR(Result, LITCONV_ERR_GETCSSFILENAME, [Result]) then begin
      StopCSS;
      goto stop;
    end;

{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_COPYCSS, [CSSFn]);
      cont:= True;
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$ENDIF}

    // Copy the CSS text...
{$IFNDEF NOSENDMSG}{$ENDIF}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_COPYCSS, [CSSFn]);
      cont:= True;
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$IFNDEF NOSENDMSG}{$ENDIF}
    Result:= CopyCSS(CSSFn, CSSHost, AOnMessage);
    if CheckHR(Result, LITCONV_ERR_COPYCSS, [Result, CSSFn]) then begin
      StopCSS;
      goto stop;
    end;
    // ...and finish the host.
    Result:= StopCSS;
  end;
  // The CSS is done, content
  while True do begin
    // Get the next host.
    Result:= Writer.GetNextContentHost(pUnk);
    if (Result = S_FALSE)
    then Break;  // no more text streams, must begin processing image streams
    if CheckHR(Result, LITCONV_ERR_GETCONTENT, [Result]) then begin
      goto stop;
    end;
    // If there is no next host, we'll get S_FALSE; continue on to
    // images.

    // Get the real interface and release the old one.
    ParserHost:= ILITParserHost(pUnk);

    // Fetch the filename for this content file...
    Result:= ParserHost.GetFilename(FileName);
    if CheckHR(Result, LITCONV_ERR_GETCONTENTFILENAME, [Result]) then begin
      StopContent;
      goto stop;
    end;

    // parse the content at the host...
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_PROCESSCONTENT, [FileName]);
      cont:= True;            
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$ENDIF}
    if FileExists(FileName)
    then Result:= ParseXMLFile(FileName, ParserHost, AOnMessage)
    else begin
      if Assigned(AGetDocProc)
      then Result:= ParseXMLDoc(AGetDocProc(FileName), ParserHost, AOnMessage)
      else Result:= S_FALSE;
    end;

    if CheckHR(Result, LITCONV_ERR_PROCESSCONTENT, [Result, FileName]) then begin
      StopContent;
      goto stop;
    end;
    // ..and finish the host.
    Result:= StopContent;
  end;

  // Nothing left but images:
  pUnk:= Nil;
  while True do begin
    // Get the next host.
    Result:= Writer.GetNextImageHost(pUnk);
    if (Result = S_FALSE)
    then Break;
    if CheckHR(Result, LITCONV_ERR_GETIMAGE, [Result]) then begin
      goto stop;
    end;
    // If there is no next host, we'll get S_FALSE; we've written
    // everything.

    // Get the real interface and release the old one.
    ImageHost:= ILITImageHost(pUnk);

    // Fetch the filename for this image file...
    Result:= ImageHost.GetFilename(ImgFN);
    if CheckHR(Result, LITCONV_ERR_GETIMAGEFILENAME, [Result]) then begin
      StopImage;
      goto stop;
    end;
    // Copy the image stream...

    Result:= ImageHost.GetId(ImgId);
    Result:= ImageHost.GetMimeType(ImgMIME);
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_COPYIMAGE, [ImgMIME, ImgFN, ImgId]);
      cont:= True;
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$ENDIF}
    Result:= CopyImg(ImgFN, ImageHost, AOnMessage);
    if CheckHR(Result, LITCONV_ERR_FINISHIMAGE, [Result]) then begin
      StopImage;
      goto stop;
    end;
    // ...and we're done (image hosts don't get Finish(), for
    // historical reasons).
    StopImage;
  end;

  // Everything's done; finalize the file.
  Result:= Writer.Finish;
stop:
  if Result <> S_OK then begin
{$IFNDEF NOSENDMSG}
    if Assigned(AOnMessage) then begin
      ws:= Format(LITCONV_MSG_FAILED, [Result, PackageFn]);
      cont:= True;
      AOnMessage(rlHint, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
    end;
{$ENDIF}
    if Assigned(Writer) then begin
      Writer.Fail;
    end;
  end;

  if Assigned(Writer) then begin
    Writer._Release;  // the same thing is Writer:= Nil; ?
    Writer:= Nil;     // it can cause AVE
  end;
  if NeedToUninitialize then CoUninitialize;

  // send done message to inform caller that conversion was done
  // be care- take a snap while thread will finished
  if Assigned(AOnMessage) then begin
    ws:= Format(LITCONV_MSG_THREADDONE, [Result, APackageFileName]);
    cont:= True;
    AOnMessage(rlFinishThread, Nil, '', 0, DummyPoint, PWideChar(ws), cont, Nil);
  end;
end;

{$OPTIMIZATION ON}

{
function ReplaceSpecialCodes(const S: WideString): WideString;
var
  i, L: Integer;
begin
  i:= 1;
  L:= Length(S);
  Result:= '';
  while i <= L do begin
    case s[i] of
      '&':begin
        end;
      else Result:= Result + S[i];
    end; // case
    Inc(i);
  end;
end;
}
type
  TProcessLitThread = class(TThread)
  private
    FGetXMLProc: TGetxmlElementByFileNameCallback;
    FGetDocProc: TGetXmlDocByFileNameCallback;
    FConvResult: HRESULT;
    FPackageFileName: String;
    FResultLITFileName: String;
    FOnMessage: TReportEvent;
  public
    constructor Create(ACreateSuspended: Boolean; const APackageFileName, AResultLITFileName: String;
      AGetXMLProc: TGetxmlElementByFileNameCallback; AOnMessage: TReportEvent); virtual;
    constructor CreateMS(ACreateSuspended: Boolean; const APackageFileName, AResultLITFileName: String;
      AGetXMLProc: TGetXmlDocByFileNameCallback; AOnMessage: TReportEvent); virtual;
    procedure Execute; override;
  end;

constructor TProcessLitThread.Create(ACreateSuspended: Boolean; const APackageFileName, AResultLITFileName: String;
  AGetXMLProc: TGetxmlElementByFileNameCallback; AOnMessage: TReportEvent);
begin
  FConvResult:= S_OK;
  FGetXMLProc:= AGetXMLProc;
  FGetDocProc:= Nil;
  FPackageFileName:= APackageFileName;
  FResultLITFileName:= AResultLITFileName;
  FOnMessage:= AOnMessage;
  inherited Create(ACreateSuspended);
end;

constructor TProcessLitThread.CreateMS(ACreateSuspended: Boolean; const APackageFileName, AResultLITFileName: String;
  AGetXMLProc: TGetXmlDocByFileNameCallback; AOnMessage: TReportEvent);
begin
  FConvResult:= S_OK;
  FGetXMLProc:= Nil;
  FGetDocProc:= AGetXMLProc;
  FPackageFileName:= APackageFileName;
  FResultLITFileName:= AResultLITFileName;
  FOnMessage:= AOnMessage;
  inherited Create(ACreateSuspended);
end;

procedure TProcessLitThread.Execute;
begin
  if Assigned(FGetXMLProc)
  then FConvResult:= ProcessLit(FPackageFileName, FResultLITFileName,
    FGetXMLProc, FOnMessage)
  else FConvResult:= ProcessMSLit(FPackageFileName, FResultLITFileName,
    FGetDocProc, FOnMessage);
end;


function StartProcessLitThread(const APackageFileName, AResultLITFileName: String;
  AGetXMLProc: TGetxmlElementByFileNameCallback; AOnMessage: TReportEvent): TThread;
begin
  Result:= TProcessLitThread.Create(True, APackageFileName, AResultLITFileName,
    AGetXMLProc, AOnMessage);
  if Assigned(Result) then begin
    Result.FreeOnTerminate:= True;
    Result.Resume;
  end;
end;

function StartProcessMSLitThread(const APackageFileName, AResultLITFileName: String;
  AGetDocProc: TGetXmlDocByFileNameCallback; AOnMessage: TReportEvent): TThread; stdcall;
begin
  Result:= TProcessLitThread.CreateMS(True, APackageFileName, AResultLITFileName,
    AGetDocProc, AOnMessage);
  if Assigned(Result) then begin
    Result.FreeOnTerminate:= True;
    Result.Resume;
  end;
end;

end.
