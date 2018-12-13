/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 * 
 * The Original Code is the wmlbrowser extension.
 * 
 * The Initial Developer of the Original Code is Matthew Wilson
 * <matthew@mjwilson.demon.co.uk>. Portions created by the Initial Developer
 * are Copyright (C) 2004 the Initial Developer. All Rights Reserved.
 * 
 * Contributor(s): 
 *
 * This file contains the content handler for converting content of type
 * text/vnd.wap.wml (WMLStreamConverter)
 */

/* components defined in this file */

const WMLSTREAM_CONVERT_CONVERSION =
    "?from=text/vnd.wap.wml&to=*/*";
const WMLSTREAM_CONVERTER_CONTRACTID =
    "@mozilla.org/streamconv;1" + WMLSTREAM_CONVERT_CONVERSION;
const WMLSTREAM_CONVERTER_CID =
    Components.ID("{51427b76-8626-4a72-bd5f-2ac0ce5d101a}");

/* text/vnd.wap.wml -> text/html stream converter */
function WMLStreamConverter ()
{
    this.logger = Components.classes['@mozilla.org/consoleservice;1']
        .getService(Components.interfaces.nsIConsoleService);
}

WMLStreamConverter.prototype.QueryInterface =
function (iid) {

    if (iid.equals(Components.interfaces.nsISupports) ||
        iid.equals(Components.interfaces.nsIStreamConverter) ||
        iid.equals(Components.interfaces.nsIStreamListener) ||
        iid.equals(Components.interfaces.nsIRequestObserver))
        return this;

    throw Components.results.NS_ERROR_NO_INTERFACE;

}

// nsIRequestObserver methods
WMLStreamConverter.prototype.onStartRequest =
function (aRequest, aContext) {

    this.data = '';

    this.uri = aRequest.QueryInterface (Components.interfaces.nsIChannel).URI.spec;

    // Sets the charset if it is available. (For documents loaded from the
    // filesystem, this is not set.)
    this.charset =
       aRequest.QueryInterface (Components.interfaces.nsIChannel)
           .contentCharset;

    this.channel = aRequest;
    this.channel.contentType = "text/html";
    // All our data will be coerced to UTF-8
    this.channel.contentCharset = "UTF-8";

    this.listener.onStartRequest (this.channel, aContext);

};

WMLStreamConverter.prototype.onStopRequest =
function (aRequest, aContext, aStatusCode) {

    //this.logger.logStringMessage (this.data);

    // Strip leading whitespace
    this.data = this.data.replace (/^\s+/,'');

    // Parse the content into an XMLDocument
    // (NB 'new DOMParser()' doesn't work from within a component it seems)
    var parser =
        Components.classes['@mozilla.org/xmlextras/domparser;1']
             .getService(Components.interfaces.nsIDOMParser);
    var originalDoc = parser.parseFromString(this.data, "text/xml");

    // Default XSLT stylesheet
    var xslt = "chrome://wmlbrowser/content/wml.xsl";

    var roottag = originalDoc.documentElement;
    if ((roottag.tagName == "parserError") ||
        (roottag.namespaceURI == "http://www.mozilla.org/newlayout/xml/parsererror.xml")){
        // Use error stylesheet
        var xslt = "chrome://wmlbrowser/content/errors.xsl";
    }

    // Find out what interface we need to use for document transformation
    // (earlier builds used text/xsl)
    var transformerType;
    if (Components.classes["@mozilla.org/document-transformer;1?type=xslt"]) {
        transformerType = "xslt";
    } else {
        transformerType = "text/xsl";
    }
    var processor = Components.classes["@mozilla.org/document-transformer;1?type=" + transformerType]
        .createInstance(Components.interfaces.nsIXSLTProcessor);

    // Use an XMLHttpRequest object to load our own stylesheet.
    //var styleLoad = new XMLHttpRequest();
    var styleLoad =
        Components.classes["@mozilla.org/xmlextras/xmlhttprequest;1"]
        .createInstance(Components.interfaces.nsIXMLHttpRequest);
    styleLoad.open ("GET", xslt, false); // synchronous load
    styleLoad.overrideMimeType("text/xml");
    styleLoad.send(undefined);
    processor.importStylesheet (styleLoad.responseXML.documentElement);

    // Get the transformed document
    var transformedDocument = processor.transformToDocument (originalDoc);
    var serializer =
        Components.classes["@mozilla.org/xmlextras/xmlserializer;1"]
        .createInstance (Components.interfaces.nsIDOMSerializer);

    // and serialize it to XML
    // This is a BIG HACK
    var str = Components.classes["@mozilla.org/supports-string;1"].
                   createInstance(Components.interfaces.nsISupportsString);
    str.data = '';
    var outputStream = {
        write: function(buf, count) {
           str.data += buf.substring(0,count);
           return count;
       }
    };
    serializer.serializeToStream (transformedDocument, outputStream, "UTF-8");
    var targetDocument = str.data;

    //this.logger.logStringMessage (targetDocument);

    var sis =
        Components.classes["@mozilla.org/io/string-input-stream;1"]
        .createInstance(Components.interfaces.nsIStringInputStream);
    sis.setData (targetDocument, targetDocument.length);

    // Pass the data to the main content listener
    this.listener.onDataAvailable (this.channel, aContext, sis, 0, targetDocument.length);

    this.listener.onStopRequest (this.channel, aContext, aStatusCode);

};

// nsIStreamListener methods
WMLStreamConverter.prototype.onDataAvailable =
function (aRequest, aContext, aInputStream, aOffset, aCount) {

    // TODO For more recent Mozilla versions, we can use the
    // 'convertFromByteArray' methods.  Creating a string first leaves us with
    // the risk of problems, eg 0 bytes indicating the end of a string
    var si = Components.classes["@mozilla.org/scriptableinputstream;1"].createInstance();
    si = si.QueryInterface(Components.interfaces.nsIScriptableInputStream);
    si.init(aInputStream);
    // This is basically a string containing a UTF-16 character for each
    // byte of the original data
    var unencoded = si.read (aCount);

    // Try and detect the XML encoding if declared in the file and not
    // already known. This will fail with UTF-16 etc I think.
    if ((this.charset == undefined || this.charset == '') && 
         unencoded.match (/<?xml\s+version\s*=\s*["']1.0['"]\s+encoding\s*=\s*["'](.*?)["']/)) {
        //this.logger.logStringMessage ("got encoding match " + RegExp.$1);

        this.charset = RegExp.$1;
    } else {
        //this.logger.logStringMessage ("No encoding match found (or already got charset: " + this.charset + ")");
    }

    // Default charset
    if (this.charset == undefined || this.charset == '') {
       this.charset = 'UTF-8';
    }

    // Now convert it to Unicode, suitable for representation in a Javascript
    // string
    var converter = Components
        .classes["@mozilla.org/intl/scriptableunicodeconverter"]
        .createInstance(Components.interfaces.nsIScriptableUnicodeConverter);
    converter.charset = this.charset;

    try {
        var encoded = converter.ConvertToUnicode (unencoded);
        this.data += encoded;
    } catch (failure) {
        this.logger.logStringMessage ("wmlbrowser: Failure converting unicode using charset " + this.charset);
        this.logger.logStringMessage (failure);
        this.data += unencoded;
    }
}

// nsIStreamConverter methods
// old name (before bug 242184)...
WMLStreamConverter.prototype.AsyncConvertData =
function (aFromType, aToType, aListener, aCtxt) {
    this.asyncConvertData (aFromType, aToType, aListener, aCtxt);
}

// renamed to...
WMLStreamConverter.prototype.asyncConvertData =
function (aFromType, aToType, aListener, aCtxt) {
    // Store the listener passed to us
    this.listener = aListener;
}

// Old name (before bug 242184):
WMLStreamConverter.prototype.Convert =
function (aFromStream, aFromType, aToType, aCtxt) {
    return this.convert (aFromStream, aFromType, aToType, aCtxt);
}

// renamed to...
WMLStreamConverter.prototype.convert =
function (aFromStream, aFromType, aToType, aCtxt) {
    return aFromStream;
}

/* stream converter factory object (WMLStreamConverter) */
var WMLStreamConverterFactory = new Object();

WMLStreamConverterFactory.createInstance =
function (outer, iid) {
    if (outer != null)
        throw Components.results.NS_ERROR_NO_AGGREGATION;

    if (iid.equals(Components.interfaces.nsISupports) ||
        iid.equals(Components.interfaces.nsIStreamConverter) ||
        iid.equals(Components.interfaces.nsIStreamListener) ||
        iid.equals(Components.interfaces.nsIRequestObserver))

        return new WMLStreamConverter();

    throw Components.results.NS_ERROR_INVALID_ARG;

}

var WMLBrowserModule = new Object();

WMLBrowserModule.registerSelf =
function (compMgr, fileSpec, location, type)
{

    var compMgr = compMgr.QueryInterface(Components.interfaces.nsIComponentRegistrar);

    compMgr.registerFactoryLocation(WMLSTREAM_CONVERTER_CID,
                                    "WML Stream Converter",
                                    WMLSTREAM_CONVERTER_CONTRACTID, 
                                    fileSpec,
                                    location, 
                                    type);

    var catman = Components.classes["@mozilla.org/categorymanager;1"]
                     .getService(Components.interfaces.nsICategoryManager);
    catman.addCategoryEntry("@mozilla.org/streamconv;1",
                            WMLSTREAM_CONVERT_CONVERSION,
                            "WML to HTML stream converter",
                            true, true);
};

WMLBrowserModule.unregisterSelf =
function(compMgr, fileSpec, location)
{
}

WMLBrowserModule.getClassObject =
function (compMgr, cid, iid) {

    if (cid.equals(WMLSTREAM_CONVERTER_CID))
        return WMLStreamConverterFactory;

    if (!iid.equals(Components.interfaces.nsIFactory))
        throw Components.results.NS_ERROR_NOT_IMPLEMENTED;

    throw Components.results.NS_ERROR_NO_INTERFACE;
    
}

WMLBrowserModule.canUnload =
function(compMgr)
{
    return true;
}

/* entrypoint */
function NSGetModule(compMgr, fileSpec) {
    return WMLBrowserModule;
}