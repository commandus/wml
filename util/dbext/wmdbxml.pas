unit
  wmdbxml;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  m  d  b  x  m  l                                                        *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   web datamodule                                                            *
*   Use wmdbxmlutil.DBXMLDLLCalls external var to make calls to the db driver  *
*     DLLs                                                                    *
*   Before use TWebModule1 you must call wmdbxmlutil.LoadIni() to setup this   *
*     this array of db drivers first, W3Aliases and LogFuncs                  *
*   Part of wdbxml project (web gateway to database)                           *
*                                                                             *
*   Request-related variables:_url _host _scriptname _pathinfo _serverport     *
*     _useragent                                                              *
*                                                                              *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Dec 01 2002                                                 *
*                  Sep 21 2003 add _XXX variables to the query variables list *
*                                                                              *
*   Last fix     : Dec 20 2002                                                *
*   Lines        : 283                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  SysUtils, Classes, HTTPApp, Types, WebBroker, SyncObjs,
  customxml, xmlsupported, xmlParse,
  util1, util_xml, isutil1, utilISAPI, wmdbxmlutil, wmlurl,
  dbxmlint,
  // ReqMulti,  // Parse a multipart form data request which may contain uploaded files.  This is register this parser.
  jclUnicode;

type
  TProcessState = (stWAIT, stDATAReady);

  TWebModule1 = class(TWebModule)
    procedure WebModule1waDefaultAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
    procedure WebModule1waInfoAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
    ContentPassed: TPassContentSet;

    FEvent: TEvent;
    FDllPath: String; // dll path
    FPState: TProcessState;
    FFullContent: TStrings;  // keep loaded data
    FData: ANSIString;
    FContentType: ANSIString;
    FState: Integer; // 0- process, 1- action=move:...
    FStateValue: WideString;  // accumulate error descriptions
    FPCookies: PWideChar; // cookie to set up
    procedure OnReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
      const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
      var AContinueParse: Boolean; AEnv: Pointer);
    function FullContent: TStrings;  // retrieve all of posted data
    function GetQueryFields: WideString;  // return comma-delimited wide string of query parameteres
    function GetCookieFields: WideString;  // return comma-delimited cookies
    procedure SetCookieFields(ACookies: WideString);  // comma-delimited
    procedure DoSetCookies(const ACookies: PWideChar); // ACookies are comma-delimited list of cookies
    // function ProcessDBError(E: Exception): Boolean;
  public
    { Public declarations }
    // procedure RecreateActions;
  end;

var
  WebModule1: TWebModule1;

implementation

{$R *.DFM}
uses
  MIMEHelper, wmlc;

const
  MAXCONTENTLEN  = MAXINT div 2; { about 2Gb /2 Content length limit (POST chunks) }

procedure TWebModule1.OnReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
  const ASrc: PWideChar; ALen: Cardinal; AWhere: TPoint; const ADesc: PWideChar;
  var AContinueParse: Boolean; AEnv: Pointer);
var
  dummyWide: WideString;
  i: Integer;
begin
  if ALevel = rlFinishThread then begin
    FPState:= stDATAReady;

    if wmdbxmlutil.useUtf8 and (pcParse in ContentPassed) //
    then begin
      {
      if dbCodepageIsUTF8
      then FData:= ASrc
      else
      }
      FData:= WideString2EncodedString(convPCDATA, csUTF8, ASrc, []); // utf8Encode(ASrc+#13#10)
    end else begin
      // can not do simple assignment FData:= ASrc because it can contain #0
      // can not do simple assignment FData:= ASrc because it can contain #0

      SetLength(dummyWide, ALen);
      Move(ASrc^, dummyWide[1], ALen * 2);
      FData:= dummyWide;
      {
      SetLength(FData, ALen);
      for i:= 1 to ALen do FData[i]:= Char(Lo(Word(ASrc[i-1])));
      }
    end;
    FState:= AWhere.x;
    if FState > 0
    then FStateValue:= ADesc;
    // in AxmlElement dbxml.dll returns cookie to set up, NO xml element!
    FPCookies:= PWideChar(AxmlElement);
    FContentType:= ADesc;
    {
    case FState of
    0:begin
        //Response.ContentEncoding:= 'utf-8';
        Response.Content:= FData;
        Response.SendResponse;
      end;
    else begin
        Response.StatusCode:= 301;
        Response.SendRedirect(FStateValue);
      end;
    end;
    }

    FEvent.SetEvent; //
  end else begin
    FStateValue:= FStateValue + #32 + ADesc;
    // Format('%s: %s(%d,%d): %s', [ReportLevelStr[ALevel], ASrc, AWhere.x + 1, AWhere.y + 1, ADesc]);
  end;
end;

{ retrieve all of posted data
  read ContentLength value and compare to the actualy loaded
  then call ReadStringSmallPortions if
  Used FFullContent to keep data
}
function TWebModule1.FullContent: TStrings;
var
  Bytes2Read: Integer;
  S: String;
begin
  with Request do begin
    Result:= ContentFields;  // read entire content
  end;
end;

{ return fields in the order:
  query   (GET)
  request related (generic)
  content (POST)
}
function TWebModule1.GetQueryFields: WideString;  // comma-delimited
var
  i: Integer;
  s, v: WideString;
  sl: TStrings;
begin
  with Request do begin
    sl:= QueryFields;
    // remove all request-related variables (started with '_' underscore symbol)
    i:= 0;
    while i < sl.Count do begin
      if Pos('_', sl.Names[i]) = 1
      then sl.Delete(i)
      else Inc(i);
    end;

    // add important request-related variables
    // url
    sl.Add('_url=' +  url);
    // host
    sl.Add('_host=' +  Host);
    // server port
    sl.Add('_serverport=' +  IntToStr(ServerPort));
    // script name
    sl.Add('_scriptname=' +  ScriptName);
    // path info
    sl.Add('_pathinfo=' +  PathInfo);
    // user agent
    sl.Add('_useragent=' +  UserAgent);
    {
    // query
    sl.Add('_query=' +  Query);
    // content
    sl.Add('_content=' +  Content);
    // path
    sl.Add('_path=' +  Host + ':'+ IntToStr(ServerPort) + Scriptname + Pathinfo);
    }

    // add posted fields
    if MethodType = mtPost then begin
      i:= sl.Count;
      sl.AddStrings(FullContent);
      // remove all request-related posted variables (started with '_' underscore symbol)
      while i < sl.Count do begin
        if Pos('_', sl.Names[i]) = 1
        then sl.Delete(i)
        else Inc(i);
      end;
    end;
  end;
  Result:= '';
  for i:= 0 to sl.Count - 1 do begin
    {
    //wsv:= UTF8Decode(sl.ValueFromIndex[i])
    // s:= UTF8Decode(sl.Names[i]) + '=' + '';
    v:= CharSet2WideString(csUTF8, sl.ValueFromIndex[i], [convEnEntity2Char]);
    if Length(v) = 0 then begin
      v:= PWideChar(sl.ValueFromIndex[i]);
    end;
    s:= sl.Names[i] + '=' + v;
    }
    s:= UTF8Decode(sl[i]);
    if Length(s) = 0
    then Result:= Result + WideQuotedStr(sl[i], '"') + ','
    else begin
      Result:= Result + WideQuotedStr(s, '"') + ',';
    end;
  end;
  if Length(Result) > 0
  then Delete(Result, Length(Result), 1);
end;

function TWebModule1.GetCookieFields: WideString;  // comma-delimited
var
  i: Integer;
  ws: String;
begin
  Result:= '';
  with Request do for i:= 0 to CookieFields.Count - 1 do begin
    ws:= UTF8Decode(CookieFields[i]);
    if Length(ws) = 0
    then Result:= Result + WideQuotedStr(CookieFields[i], '"') + ','
    else Result:= Result + WideQuotedStr(ws, '"') + ',';
  end;
  if Length(Result) > 0
  then Delete(Result, Length(Result), 1);
end;

// BUGBUG -- it works only with ANSI characters
procedure TWebModule1.SetCookieFields(ACookies: WideString);  // comma-delimited
begin
  with Request do begin
    CookieFields.CommaText:= ACookies;
  end;
end;

// http://localhost/scripts/wdbxml.dll

// ACookies are comma-delimited list of cookies
procedure TWebModule1.DoSetCookies(const ACookies: PWideChar);
var
  i, p: Integer;
  sl: TStrings;
  s: String;
begin
  if Length(ACookies) = 0
  then Exit;
  sl:= TStringList.Create;
  sl.CommaText:= ACookies;
  for i:= 0 to sl.Count - 1 do begin
    with Response.Cookies.Add do begin
      s:= sl[i];
      p:= Pos('=', s);
      if p = 0 then begin
        Name:= s;
        // Value:= '';
      end else begin
        Name:= Copy(s, 1, p - 1);
        Value:= Copy(s, p + 1, MaxInt);
      end;
      Expires:= Now + 1;  // 1 day for all cookies
    end;
  end;
  sl.Free;
end;

function GetMimeType(const AUrl: String): String;
begin
  Result:= MIMEByExt(AUrl);
end;


procedure TWebModule1.WebModule1waDefaultAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
const
  DEFAULTENCODING = csUTF8;
var
  fn: String;
  drvIdx: Integer;
  s, bookmark: String;
  ws: WideString;
  vars: WideString;
  cookies: WideString;
  docType: TEditableDoc;
  i, Encoding: Integer;
  EncodingName: String;
begin
  ws:= '';
  FPState:= stWAIT;
  FStateValue:= '';
  try
    vars:= GetQueryFields;
    cookies:= GetCookieFields;
    fn:= Request.PathInfo;
    drvIdx:= GetDrvIdx(fn);
    // parse alias if no use database content
    if not wmdbxmlutil.forceUseDBContent
    then fn:= util1.ConCatAliasPath(W3Aliases, FDllPath, fn);
// DoLog(Format('Path: %s [%d] fn: %s', [Request.PathInfo, drvIdx, fn]));
    // check have I permissions to open file
    // ... security hole here --BUGBUG
    //
    // return edNone, edText, edWML, edHTML, edCSS, edOEB, edOPF, edXHTML, edTaxon, edSMIT
    docType:= GetDocTypeByFileName(fn);
    if docType = edHTML then begin
      // fix html to xhtml
      doctype:= edXHTML;
    end;
    if docType in [edWML, edOEB, edPKG, edXHTML, edTaxon, edSMIT, edgenXML] then begin  // edxHHC, edxHHK
      ContentPassed:= [pcParse];
      if (not wmdbxmlutil.forceUseDBContent) and FileExists(fn) then begin
        // load document from file
        if wmlurl.GetSrcFromURI(fn, ws, bookmark, Encoding) = wmlurl.umOK then begin
        end;
        {  this code replaced with GetSrcFromURI Feb 22 2006
        s:= util1.File2String(fn);
        EncodingName:= GetEncodingName(s);
        Encoding:= CharSetName2Code(EncodingName);
        if Encoding < 0 then begin
          Encoding:= DEFAULTENCODING;
          EncodingName:= 'utf-8'
        end;
        ws:= util_xml.CharSet2WideStringLine(Encoding, s, []);
        }
      end else begin
        Include(ContentPassed, pcUrl);
        Encoding:= DEFAULTENCODING;
        EncodingName:= 'utf-8';
        {
        FData:= '<html><body><h1>' + Request.PathInfo + ' does not exists.</h1></body></html>';
        Handled:= True;
        Response.StatusCode:= 404;
        Exit;
        }
        // pass file name to the dbparser
        ws:= fn;
      end;

      FEvent.ResetEvent; { clear the event before launching the threads }

      DBXMLDLLCalls[drvIdx].FStartDbXMLParse(docType,
        PWideChar(ws), PWideChar(vars), PWideChar(cookies), OnReportEvent, ContentPassed, Self);

      // wait until
      if FEvent.WaitFor(12 * 60*1000) <> wrSignaled then begin // 2 minutes
        // raise Exception;
        FData:= FData + #13#10'Time out'; // wrTimeOut	wrAbandoned	wrError
      end;
      Response.LogMessage:= Format(' %x[%d/%d]%d} template %s',
        [Integer(Self), Application.ActiveCount, Application.InactiveCount,
        DBXMLDLLCalls[drvIdx].FGetThreadCount, fn]);

      case docType of
        edWML: Response.ContentType:= 'text/vnd.wap.wml';
        edOEB: Response.ContentType:= 'text/x-oeb1-document';
        edPKG: Response.ContentType:= 'text/x-oeb1-package'; // does not exists actually
        edXHTML: Response.ContentType:= 'text/html';  // it's more flexible you know
        edTaxon: Response.ContentType:= 'text/application-taxon';  // ?!!
        edSMIT: Response.ContentType:= 'text/application-smit';  // ?!!
        edgenXML: Response.ContentType:= 'text/xml';  // ?!!
        else Response.ContentType:= GetMimeType(fn); // it is impossible
      end;

      Response.ContentEncoding:= EncodingName;
      case FState of
      0:begin
          // process cookies
          DoSetCookies(FPCookies);

          // Response.Cookies
          // BUGBUG -- not implemented yet
          if Length(FData) = 0 then begin
            // no data was returned, return error description
            Response.ContentType:= 'text/plain';
            Response.Content:= FStateValue;
          end else begin
            if Length(FStateValue) > 0 then begin
              // some errors occured
              // util_xml.HTMLEntityStr(
              FData:= FData + '<!-- ' + FStateValue + '-->';
            end else begin
              // anything is fine
            end;
            Response.Content:= FData;
          end;
          Handled:= True;
        end;
      else begin
          Response.StatusCode:= 301;
          Response.Location:= ws;
          Response.SendRedirect(ws); // do not http encode // was FStateValue 18.12.2006
        end;
      end; // case
    end else begin
      // it is not parseble, but if it is in database we need to load
      if (wmdbxmlutil.forceUseDBContent) then begin
        //
        ContentPassed:= [pcUrl];
        // pass file name to the dbparser
        ws:= fn;
        FEvent.ResetEvent; { clear the event before launching the threads }

        DBXMLDLLCalls[drvIdx].FStartDbXMLParse(docType,
          PWideChar(ws), PWideChar(vars), PWideChar(cookies), OnReportEvent, ContentPassed, Self);
        // wait until
        if FEvent.WaitFor(2 * 60*1000) <> wrSignaled then begin // 2 minutes
          // raise Exception;
        end;
        Response.LogMessage:= Format(' %x[%d/%d]%d} document %s',
          [Integer(Self), Application.ActiveCount, Application.InactiveCount,
          DBXMLDLLCalls[drvIdx].FGetThreadCount, fn]);

        if Length(FData) = 0 then begin
          // else redirect to the other resource location
          Response.ContentType:= 'text/plain';
          Response.Content:= 'N/D';
          Response.SendRedirect(Request.PathInfo); // it does not work
        end else begin
          if Length(FContentType) = 0
          then Response.ContentType:= GetMimeType(fn)
          else Response.ContentType:= FContentType;
          Response.Content:= FData;
        end;
        Handled:= True;
      end else begin
        if FileExists(fn) then begin
          Response.ContentType:= GetMimeType(fn);
          Response.Content:= util1.LoadString(fn);
        end else begin
          // else redirect to the other resource location
          Response.Content:= 'N/D';
          Response.SendRedirect(Request.PathInfo); // actually it does not work because it is called from SendResponse
        end;
      end;
    end;
  finally
  end;
end;

procedure TWebModule1.WebModuleCreate(Sender: TObject);
var
  eventName: String;
begin
  //
  eventName:= Format('%x', [Cardinal(Self)]);
  FEvent:= TEvent.Create(Nil, True, False, eventName);
  FFullContent:= Nil;
  FData:= '';
  FState:= 0;
  FStateValue:= '';
  FDllPath:= GetDllPath();
  FPState:= stDATAReady;
DoLog(Format('web module thread %s created from "%s".', [eventName, FDllPath]));
end;

function DlmtList(const ADelimiter: String; AStrings: TStrings): String;
var
  i: Integer;
begin
  Result:= '';
  for i:= 0 to AStrings.Count - 1 do begin
    Result:= Result + AStrings[i] + ADelimiter;
  end;
end;

{ Return list of db driver DLLs
  Used by Info Action
}
function DbDrvList(const ADelimiter: String): String;
var
  d, L: Integer;
begin
  Result:= '';
  d:= Low(DBXMLDLLCalls);
  while d <= High(DBXMLDLLCalls) do begin
    Result:= Result + IntToHex(DBXMLDLLCalls[d].FHandle, 8) + ' ' + DBXMLDLLCalls[d].FPath + ADelimiter;
    Inc(d);
  end;
end;

{
function TWebModule1.ProcessDBError(E: Exception): Boolean;
var
  i: Integer;
  S: String;
  ErrDesc: String;
begin
  Result:= True;
  ErrDesc:= Copy(E.Message, 1, 255);
  util1.DeleteControlsStr(ErrDesc);
  for i:= 0 to ReconnectErrorList.Count - 1 do begin
    S:= ReconnectErrorList[i];
    if (Length(S) > 0) and (Pos(S, ErrDesc) > 0) then begin
      // close database
      // Database0.Close;
      Break;
    end;
  end;
  // log error
DoLog('Error: ' + ErrDesc);
end;
}

procedure TWebModule1.WebModuleDestroy(Sender: TObject);
begin
  //
  FEvent.Free;
//DoLog(Format('web module thread %x destroyed.', [Integer(Self)]));
end;

const
  MSG_INFO = '<html><body><br/>Path: %s<p>db drivers:<br/>%s--<br/>%d</p>'+
  '<p>Aliases:<br>%s</p></body></html>';

procedure TWebModule1.WebModule1waInfoAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
//DoLog(Format('info requested (%x)', [Integer(Self)]));
  Response.ContentType:= 'text/html';
  Response.ContentEncoding:= 'utf-8';
  Response.Content:= Format(MSG_INFO, [FDLLPath, DbDrvList('<br/>'), Length(DBXMLDLLCalls), DlmtList('<br/>', W3Aliases)]);
  Handled:= True;
  Response.LogMessage:= Response.LogMessage + Format(' [%x] info requested', [Integer(Self)]);
end;

// it does not work!!!
{
procedure TWebModule1.RecreateActions;
var
  d: Integer;
  wa: TWebActionItem;
begin
  // delete non-persist actions

  for d:= 2 to Actions.Count - 1 do begin
    Actions.Delete(2);
  end;

  // add new ones
  for d:= Low(DBXMLDLLCalls) to High(DBXMLDLLCalls) do begin
    if DBXMLDLLCalls[d].FPath <> '/' then begin
      wa:= Actions.Add;
      with wa do begin
        MethodType:= mtAny;
        Name:= 'wa' + DBXMLDLLCalls[d].FPath;
        PathInfo:= DBXMLDLLCalls[d].FPath;
        OnAction:= WebModule1waDefaultAction;
        Enabled:= True;
      end;
    end;
  end;
end;
}

end.
