unit
  util_dom;
(*##*)
(*******************************************************************************
*                                                                             *
*   u  t  i  l  _  D  O  M                                                     *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   This module is intended for separate routines uses MS DOM and SAX         *
*   implementations                                                            *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Nov 01 2003                                                 *
*   Last fix     : Nov 25 2003                                                *
*                  Nov 25 2003                                                 *
*                                                                             *
*   Lines        : 150                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Classes, Windows,
  ActiveX, msxmldom, msxml,  // MS DOM
  SAX, SAXMS, SAXComps,      // MS SAX
  ShDocVw,                   // MS IE web browser
  util_xml, jclUnicode;

function xmlTransform(const ASrcUrl, AxsltURL: WideString; var AResultStr: WideString): Boolean;
function xmlWSLTransform(const ASrc: TWideStrings; const AxsltURL: WideString; var AResultStr: WideString): Boolean;
function xmlWSTransform(const ASrc: WideString; const AxsltURL: WideString; var AResultStr: WideString): Boolean;

// function xmlTransform(const ASrc, AxsltURL: WideString; var AResultStr: WideString): Boolean;

function xmlXPath(const ASrcUrl, AQuery: WideString; var AResultList: IXMLDOMNodeList): Boolean;

// load content from stream to the IE browser

function LoadStream2Browser(ACopyFromStream: TStream; AWBPreview: TWebBrowser): Boolean;

implementation

function xmlTransform(const ASrcUrl, AxsltURL: WideString; var AResultStr: WideString): Boolean;
var
  NeedToUninitialize: Boolean;
  XMLDoc, XSLDoc: DOMDocument;
begin
  NeedToUninitialize:= Succeeded(CoInitialize(nil));
  try
    XMLDoc:= CoDomDocument.Create;
    with XMLDoc do begin
      Set_async(false);
      resolveExternals:= False;
      validateOnParse:= False;
      XMLDoc.load(ASrcUrl);
    end;

    XSLDoc:= CoDomDocument.Create;
    with XSLDoc do begin
      Set_async(false);
      resolveExternals:= False;
      validateOnParse:= False;
      Load(AxsltURL);
    end;

    // XMLDoc.transformNodeToObject(XSLDoc, ResultDoc);
    AResultStr:= XMLDoc.transformNode(XSLDoc);

    // AResultStr:= ResultDoc.Text;
  finally
    if NeedToUninitialize then CoUninitialize;
  end;
end;

function xmlWSTransform(const ASrc: WideString; const AxsltURL: WideString; var AResultStr: WideString): Boolean;
var
  NeedToUninitialize: Boolean;
  XMLDoc, XSLDoc: DOMDocument;
begin
  NeedToUninitialize:= Succeeded(CoInitialize(nil));
  try
    XMLDoc:= CoDomDocument.Create;
    with XMLDoc do begin
      Set_async(false);
      resolveExternals:= False;
      validateOnParse:= False;
      LoadXml(util_xml.WideString2CRLFString(ASrc));
    end;
    XSLDoc:= CoDomDocument.Create;
    with XSLDoc do begin
      Set_async(false);
      resolveExternals:= False;
      validateOnParse:= False;
      Load(AxsltURL);
    end;

    // XMLDoc.transformNodeToObject(XSLDoc, ResultDoc);
    AResultStr:= XMLDoc.transformNode(XSLDoc);

    // AResultStr:= ResultDoc.Text;
  finally
    if NeedToUninitialize then CoUninitialize;
  end;
end;

function xmlWSLTransform(const ASrc: TWideStrings; const AxsltURL: WideString; var AResultStr: WideString): Boolean;
var
  NeedToUninitialize: Boolean;
  XMLDoc, XSLDoc: DOMDocument;
begin
  NeedToUninitialize:= Succeeded(CoInitialize(nil));
  try
    XMLDoc:= CoDomDocument.Create;
    with XMLDoc do begin
      Set_async(false);
      resolveExternals:= False;
      validateOnParse:= False;
      LoadXml(util_xml.WideStrings2CRLFString(ASrc));
    end;
    XSLDoc:= CoDomDocument.Create;
    with XSLDoc do begin
      Set_async(false);
      resolveExternals:= False;
      validateOnParse:= False;
      Load(AxsltURL);
    end;

    // XMLDoc.transformNodeToObject(XSLDoc, ResultDoc);
    AResultStr:= XMLDoc.transformNode(XSLDoc);

    // AResultStr:= ResultDoc.Text;
  finally
    if NeedToUninitialize then CoUninitialize;
  end;
end;

{
function Tdm1.xmlTransform(const ASrc, AxsltURL: WideString; var AResultStr: WideString): Boolean;
var
  NeedToUninitialize: Boolean;
  XMLDoc, XSLDoc: DOMDocument;
begin
  NeedToUninitialize:= Succeeded(CoInitialize(nil));
  try
    XMLDoc:= CoDomDocument.Create;
    with XMLDoc do begin
      Set_async(false);
      resolveExternals:= False;
      validateOnParse:= False;
      XMLDoc. xml:= ASrc;
    end;

    XSLDoc:= CoDomDocument.Create;
    with XSLDoc do begin
      Set_async(false);
      resolveExternals:= False;
      validateOnParse:= False;
      Load(AxsltURL);
    end;

    // XMLDoc.transformNodeToObject(XSLDoc, ResultDoc);
    AResultStr:= XMLDoc.transformNode(XSLDoc);

    // AResultStr:= ResultDoc.Text;
  finally
    if NeedToUninitialize then CoUninitialize;
  end;
end;
}

function xmlXPath(const ASrcUrl, AQuery: WideString; var AResultList: IXMLDOMNodeList): Boolean;
var
  NeedToUninitialize: Boolean;
  XMLDoc, XSLDoc: DOMDocument;
begin
  NeedToUninitialize:= Succeeded(CoInitialize(nil));
  try
    XMLDoc:= CoDomDocument.Create;
    with XMLDoc do begin
      Set_async(false);
      resolveExternals:= False;
      validateOnParse:= False;
      XMLDoc.load(ASrcUrl);
      AResultList:= xmldoc.documentElement.selectNodes(AQuery);
    end;
  finally
    if NeedToUninitialize then CoUninitialize;
  end;
end;

function LoadStream2Browser(ACopyFromStream: TStream; AWBPreview: TWebBrowser): Boolean;
begin
  Result:= False;
  ACopyFromStream.Seek(0, soFromBeginning);
  (AWBPreview.Document as IPersistStreamInit).Load(TStreamAdapter.Create(ACopyFromStream));
  Result:= True;
end;

{
function SAXGetLines(ASrcUrl: String): Integer;
var
  NeedToUninitialize: Boolean;
  r: TSAXMSXMLVendor;
  ContentHandler: TSAXContentHandler;
  vendor: TSAXMSXMLVendor;
  inp: IInputSource;
  strm: TStream;
begin
  NeedToUninitialize:= Succeeded(CoInitialize(nil));

  Strm:= TFileStream.Create(ASrcUrl, fmOpenRead);
  Strm.Seek(0, 0);
  Inp:= TStreamInputSource.Create(Strm) as IStreamInputSource;
  try
    ContentHandler:= TSAXContentHandler.Create(Nil);
    vendor:= TSAXMSXMLVendor.Create;
    with vendor.XMLReader do begin
      setContentHandler(ContentHandler);
      // setErrorHandler(SAXErrorHandler1);
      // This time we send the InputSource we created
      parse(inp);
      Free;
    end;
    vendor.Free;
    ContentHandler.Free;
    Inp.Free;
    Strm.Free;
  finally
    if NeedToUninitialize then CoUninitialize;
  end;
end;
}

end.
