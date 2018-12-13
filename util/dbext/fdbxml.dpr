library
  fdbxml;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  d  b  x  m  l                                                           *
*                                                                             *
*   IT DOES NOT WORK!                                                          *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   ISAPI server side extensions filter calls the db drivers dbxml            *
*                                                                              *
*   To create ISAPI filter, use wmdbxmlutil's global variables to keep        *
*     driver's array (load by LoadIni()) and then make calls of them           *
*     dbxmlint.TDBXMLDLLCalls declares calls                                  *
*                                                                              *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Dec 01 2002                                                 *
*   Last fix     : Dec 20 2002                                                *
*   Lines        : 283                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

uses
  SysUtils, ISAPI2, Windows,
  jclUnicode,
  customxml, xmlsupported, xmlParse,
  util1, util_xml, isutil1, utilISAPI, wmdbxmlutil, dbxmlint;

{$R *.RES}

const
  MSG_FILT_DESC = 'ISAPI server side WML Db extensions filter';
  MSG_FILT_CONTEXT_INDICATOR = 'WMLREADY2DO';

var
  SaveExit: Pointer;
type
  PEFilterContext = ^TEFilterContext;
  TEFilterContext = record
    HeaderLength: Cardinal;
    Header: PChar;
    BodyLength: Cardinal;
    Body: PChar;
  end;

procedure LibExit;
var
  d: Integer;
begin
  for d:= Low(DBXMLDLLCalls) to High(DBXMLDLLCalls) do with DBXMLDLLCalls[d] do begin
    if FHandle <> 0 then begin
      FClearThreadCache;
      FDone;
      FreeLibrary(FHandle);
    end;
  end;
  if Assigned(W3Aliases)
  then W3Aliases.Free;

  isutil1.StopLog(@LogFuncs);
  // restore exit procedure chain
  ExitProc:= SaveExit;
end;

function GetFilterVersion(var Ver: THTTP_FILTER_VERSION): BOOL; stdcall;
begin
  Ver.lpszFilterDesc:= MSG_FILT_DESC;
  Ver.dwFilterVersion:= MakeLong(HSE_VERSION_MINOR, HSE_VERSION_MAJOR);
  Ver.dwFlags:=
    SF_NOTIFY_NONSECURE_PORT or SF_NOTIFY_SECURE_PORT or
    SF_NOTIFY_ORDER_DEFAULT  or SF_NOTIFY_URL_MAP or
    SF_NOTIFY_SEND_RAW_DATA;
// Log(Ver.lpszFilterDesc+' loaded',True);
  Result:= True // Continue to Load Filter
end; { GetFilterVersion }

procedure DoFilter(var AData: String);
type
  TProcessState = (stWAIT, stDATAReady);
var
  fn: String;
  drvIdx: Integer;
  ws: WideString;
  vars: WideString;
  docType: TEditableDoc;
  FPState: TProcessState;
  FStateValue: String;
begin
  FPState:= stWAIT;
  FStateValue:= '';
DoLog(AData);  
  try
    ws:= '';
    vars:= ''; // GetQueryFields;
{
    fn:= Request.PathInfo;
    drvIdx:= GetDrvIdx(fn);
    fn:= util1.ConCatAliasPath(W3Aliases, FDllPath, fn);
// DoLog(Format('Path: %s [%d] fn: %s', [Request.PathInfo, drvIdx, fn]));
    // check have I permissions to open file
    // ... security hole here --BUGBUG
    //
    // return edNone, edText, edWML, edHTML, edCSS, edOEB, edOPF, edXHTML
    docType:= GetDocTypeByFileName(fn);
    if docType  = edHTML then begin
      doctype:= edXHTML;
    end;
    if docType in [edWML, edOEB, edPKG, edXHTML] then begin
      if not FileExists(fn) then begin
        FData:= '<html><body><h1>' + Request.PathInfo + ' does not exists.</h1></body></html>';
        Handled:= True;
        Response.StatusCode:= 404;
        Exit;
      end;
      ws:= util1.File2String(fn);
      DBXMLDLLCalls[drvIdx].FStartDbXMLParse(docType,
        PWideChar(ws), PWideChar(vars), OnReportEvent);
      Response.LogMessage:= Format(' %x[%d/%d]%d template %s',
        [Integer(Self), Application.ActiveCount, Application.InactiveCount,
        DBXMLDLLCalls[drvIdx].FGetThreadCount, fn]);

      case docType of
        edWML: Response.ContentType:= 'text/vnd.wap.wml';
        edOEB: Response.ContentType:= 'text/x-oeb1-document';
        edPKG: Response.ContentType:= 'text/x-oeb1-package'; // does not exists actually
        edXHTML: Response.ContentType:= 'text/html';  // it's more flexible you know
      end;

      // wait until
      repeat
        sleep(100);
      until FPState = stDATAReady;

      case FState of
      0:begin
          //Response.ContentEncoding:= 'utf-8';
          if Length(FData) = 0 then begin
            Response.ContentType:= 'text/plain';
            Response.Content:= FStateValue;
          end else begin
            if Length(FStateValue) > 0 then begin
              // util_xml.HTMLEntityStr(
              Response.Content:= FData + '<!-- ' + FStateValue + '-->';
            end else begin
              Response.Content:= FData;
            end;
          end;
          Handled:= True;
        end;
      else begin
          Response.StatusCode:= 301;
          Response.SendRedirect(FStateValue);
        end;
      end; // case

    end else begin
      Response.StatusCode:= 301;
      Response.SendRedirect(Request.PathInfo);
    end;
}
  finally
  end;
end;

{ ProcessHeader
  parse header and fill all fields of pfc.PEFilterContext except Body
  from RawData

  In this example no header to be sent (RawData nullified)
}
procedure ProcessHeader(var pfc: THTTP_FILTER_CONTEXT; var RawData: PHTTP_FILTER_RAW_DATA);
var
  FilterContext: PEFilterContext;
  i: Integer;
begin
  StrDispose(pfc.PFilterContext);
  pfc.PFilterContext:= nil;
  if (Pos('200 OK', PChar(RawData.pvInData)) in [1..20]) and
    (Pos('text/html', PChar(RawData.pvInData)) in [1..255]) then
  begin
    FilterContext:= New(PEFilterContext);
    FilterContext.Header:= StrNew(PChar(Copy(PChar(RawData.pvInData), 1, RawData.cbInData))); //!!
    FilterContext.HeaderLength:= RawData.cbInData;
    FilterContext.Body:= Nil;
    // get data length from Content-Length value if exists
    i:= Pos('Content-Length:', PChar(FilterContext.Header));
    if i > 0 then begin
      // if header fild exists
      repeat
        Inc(i)
      until FilterContext.Header[i] in ['1'..'9'];
      repeat
        FilterContext.BodyLength:= 10 * FilterContext.BodyLength +
          Ord(FilterContext.Header[i]) - Ord('0');
        Inc(i)
      until not (FilterContext.Header[i] in ['0'..'9'])
    end else FilterContext.BodyLength:= 0;

DoLog(Format('Header: 200 OK - %d bytes for Body of %d bytes',[RawData.cbInData, FilterContext.BodyLength]));

    if StrLen(FilterContext.Header) <> FilterContext.HeaderLength then
DoLog(Format('Warning: StrLen %d <> %d HeaderLength', [StrLen(FilterContext.Header), FilterContext.HeaderLength]));
    pfc.PFilterContext:= FilterContext;
//    RawData.pvInData := nil;
    RawData.cbInData:= 0; // no header to be sent!
  end else begin
    // is not valid document (for example, gif image)
DoLog(Format('Header: %d bytes (ignored)',[RawData.cbInData]));
  end;
end { ProcessHeader };

{ ProcessBody
  get filter context filled by ProcessHeader
  accumulate chuncks of data of RawData
  After last chunk received, filtered data send to web server back
}

procedure ProcessBody(var pfc: THTTP_FILTER_CONTEXT; var RawData: PHTTP_FILTER_RAW_DATA);
var
  FilterContext: PEFilterContext;
  NewContent: String;
  OldBody: PChar;
  i: Cardinal;
begin
DoLog('PROCESS BODY START');
  FilterContext:= pfc.PFilterContext;
  if Assigned(FilterContext.Body)
  then i:= StrLen(FilterContext.Body)
  else i:= 0;
DoLog(Format('PROCESS BODY START i: %d',[i]));
  Inc(i, RawData.cbInData);
  if i >= FilterContext.BodyLength then begin
    // All blocks done!
DoLog(Format('Final body: %d of %d bytes',[RawData.cbInData, FilterContext.BodyLength]));
    if Assigned(FilterContext.Body) then begin
      NewContent:= StrPas(FilterContext.Body);
      StrDispose(FilterContext.Body);
      FilterContext.Body:= nil;
    end else NewContent:= '';
    NewContent:= NewContent + StrPas(PChar(Copy(PChar(RawData.pvInData), 1, RawData.cbInData)));
DoLog('Content: '+IntToStr(FilterContext.BodyLength) + ' bytes');
//  FilterContext:= Pfc.pFilterContext; what for?
    DoFilter(NewContent);
    FilterContext.BodyLength := Length(NewContent); // new Content-Length;
    NewContent:= StrPas(FilterContext.Header) + NewContent;

    // set new value of content length if exists
    i:= Pos('Content-Length:', NewContent);
    if i > 0 then begin
      repeat Inc(i) until NewContent[i] in ['0'..'9'];
      repeat
        Delete(NewContent,i,1)
      until not (NewContent[i] in ['0'..'9']);
      Insert(IntToStr(FilterContext.BodyLength), NewContent,i);
    end;
DoLog('New Content: ' + IntToStr(FilterContext.BodyLength)+' bytes' { #13#10+NewContent } );
    StrDispose(FilterContext.Header);
    FilterContext.Header:= nil;
    Dispose(pfc.PFilterContext);

    RawData.pvInData := pfc.AllocMem(pfc, Length(NewContent)+1, 0);
    for i:= 1 to Length(NewContent)
    do PChar(RawData.pvInData)[i-1]:= NewContent[i];
    PChar(RawData.pvInData)[Length(NewContent)]:= #0;
    RawData.cbInBuffer := Length(NewContent) + 1;
    RawData.cbInData := Length(NewContent);
  end else begin
    // accumulate blocks
    if not Assigned(FilterContext.Body) then begin
      // first block
      FilterContext.Body:= StrNew(PChar(Copy(PChar(RawData.pvInData), 1, RawData.cbInData))); //!!
DoLog(Format('First Body: %d of %d bytes',[RawData.cbInData, FilterContext.BodyLength]));
      if StrLen(FilterContext.Body) <> RawData.cbInData then
DoLog(Format('Warning: StrLen %d <> %d BlockLength', [StrLen(FilterContext.Body), RawData.cbInData]));
  //    RawData.pvInData := nil;
      RawData.cbInData:= 0 // no body to be sent, yet!
    end else begin
      // additional block
      OldBody:= FilterContext.Body;
      FilterContext.Body:= StrNew(PChar(StrPas(OldBody) +
        StrPas(PChar(Copy(PChar(RawData.pvInData),1,RawData.cbInData)))));
      StrDispose(OldBody);
DoLog(Format('Next Body: %d of %d bytes',[RawData.cbInData,FilterContext.BodyLength]));
  //    RawData.pvInData:= nil;
      RawData.cbInData:= 0 // no body to be sent, yet!
    end
  end;
end; { ProcessBody }

function HttpFilterProc(var pfc: THTTP_FILTER_CONTEXT; NotificationType: DWORD;
  pvNotification: pointer): DWORD; stdcall;
var
  UrlMap: PHTTP_FILTER_URL_MAP;
  RawData: PHTTP_FILTER_RAW_DATA;
begin
  // Notify next Filter
  Result:= SF_STATUS_REQ_NEXT_NOTIFICATION;
  case NotificationType of
    SF_NOTIFY_URL_MAP: begin
        UrlMap:= PHTTP_FILTER_URL_MAP(pvNotification);
DoLog('URLMAP: '+ UrlMap.pszURL);
        if Pos('.htm', UrlMap.pszURL) > 0 then begin
          // start new URL
          pfc.PFilterContext:= StrNew(MSG_FILT_CONTEXT_INDICATOR);
        end;
      end;
    SF_NOTIFY_SEND_RAW_DATA: begin
        if Assigned(pfc.PFilterContext) then begin
          // URL
          RawData:= PHTTP_FILTER_RAW_DATA(pvNotification);
DoLog('Before SENDRAWDATA, rawdata: '+ PChar(pfc.PFilterContext));
          if CompareText(PChar(pfc.PFilterContext), MSG_FILT_CONTEXT_INDICATOR) = 0 then begin
            // header
DoLog('Before Header');
            ProcessHeader(pfc, RawData); // pfc.PEFilterContext nullified
DoLog('After Header');
          end else begin
DoLog('Before Body');
            // pfc.PEFilterContext is null (header processed)
            ProcessBody(pfc, RawData);
DoLog('After Body');
          end;
        end;
      end;
  end; { case }
end; { HttpFilterProc }

exports
  GetFilterVersion,
  HttpFilterProc;

begin
  // save exit procedure chain
  SaveExit:= ExitProc;
  // install LibExit exit procedure
  ExitProc:= @LibExit;

  SetLength(DBXMLDLLCalls, 0);
  // load db drivers DLLs into wmdbxmlutil.DBXMLDLLCalls, error list, log
DoLog('Before LoadIni');
  if LoadIni(GetDLLPath) then begin
    // wmdbxml.WebModule1.RecreateActions;
  end;
DoLog('After LoadIni');
  IsMultiThread:= True;
end.
