library ISAFilterScripting;
{$R *.res}
uses
  Windows, SysUtils, IniFiles, Isapi2, Classes, HTTPProd;

const
  MSG_FILT_DESC = 'ISAPI server side WML Db extensions filter';
  MSG_FILT_CONTEXT_INDICATOR = 'WMLREADY2DO';
    
type
  TPfcPageProducer = class(TPageProducer)
  public
    FilterContext: THTTP_FILTER_CONTEXT;
    procedure TagExpander(Sender: TObject; Tag: TTag; const TagString: String;
      TagParams: TStrings; var ReplaceText: String);
  end;

{ TMyPageProducer }

procedure TPfcPageProducer.TagExpander(Sender: TObject; Tag: TTag;
  const TagString: String; TagParams: TStrings; var ReplaceText: String);
var
  i: Integer;

  function NextCounter: Integer;
  const
    CounterFileName = 'c:\script.ini';
  begin
    with TIniFile.Create(CounterFileName) do
    try
      Result := ReadInteger('counter', 'count', 0);
      WriteInteger('counter', 'count', Succ(Result));
    finally
      UpdateFile;
      Free
    end
  end {NextCounter};

  function GetServerVariable(const Variable: PChar): String;
  var
    MaxLen: Cardinal;
  begin
    MaxLen := 255;
    SetLength(Result,MaxLen);
    if FilterContext.GetServerVariable(FilterContext, Variable, PChar(Result), MaxLen) then
      SetLength(Result,StrLen(PChar(Result)))
    else
      Result := ''
  end {GetServerVariable};

begin
  if TagString = 'time' then ReplaceText := TimeToStr(Now)
  else
  if TagString = 'date' then ReplaceText := DateToStr(Now)
  else
  if TagString = 'random' then
  begin
    i := StrToIntDef(TagParams.Values['max'],100);
    ReplaceText := IntToStr(Random(i))
  end
  else
  if TagString = 'counter' then
    ReplaceText := IntToStr(NextCounter)
  else
  if TagString = 'copyright' then
    ReplaceText := '<p><hr><font face="verdana"size=1><center>&copy; 2002 ' +
             'by Bob Swart (aka Dr.Bob - <a href="http://www.drbob42.com">' +
             'www.drbob42.com</a>). All Rights Reserved.</font></p>'
  else
    ReplaceText := GetServerVariable(PChar(UpperCase(TagString))) // empty if doesn't exist!
end {TagExpander};


procedure Log(const Message: String; NewLogFile: Boolean = False);
const
  LogFileName = 'c:\script42.log';
var
  LogFile: TextFile;
begin
  Assign(LogFile, LogFileName);
  {$I-}
  if NewLogFile then Rewrite(LogFile)
                else Append(LogFile);
  if IOResult = 0 then
  begin
    writeln(LogFile,TimeToStr(Now),': ',Message); // Requires SysUtils
    Close(LogFile)
  end
end {Log};

function GetFilterVersion(var Ver: THTTP_FILTER_VERSION): BOOL; stdcall;
begin
  Ver.lpszFilterDesc:= MSG_FILT_DESC;
  Ver.dwFilterVersion:= MakeLong(HSE_VERSION_MINOR, HSE_VERSION_MAJOR);
  Ver.dwFlags:=
    SF_NOTIFY_NONSECURE_PORT or SF_NOTIFY_SECURE_PORT or
    SF_NOTIFY_ORDER_DEFAULT  or SF_NOTIFY_URL_MAP or
    SF_NOTIFY_SEND_RAW_DATA;
Log(Ver.lpszFilterDesc+' loaded',True);
  Result:= True // Continue to Load Filter
end; { GetFilterVersion }

type
  PEFilterContext = ^TEFilterContext;
  TEFilterContext = record
    HeaderLength: Cardinal;
    Header: PChar;
    BodyLength: Cardinal;
    Body: PChar;
  end;

procedure DoFilter(var AData: String);
begin
  with TPfcPageProducer.Create(nil) do begin
    try
      OnHTMLTag:= TagExpander;
      HTMLDoc.Clear;
      HTMLDoc.Add(AData);
      AData:= Content
    finally
      Free;
    end;
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

Log(Format('Header: 200 OK - %d bytes for Body of %d bytes',[RawData.cbInData, FilterContext.BodyLength]));

    if StrLen(FilterContext.Header) <> FilterContext.HeaderLength then
Log(Format('Warning: StrLen %d <> %d HeaderLength', [StrLen(FilterContext.Header), FilterContext.HeaderLength]));
    pfc.PFilterContext:= FilterContext;
//    RawData.pvInData := nil;
    RawData.cbInData:= 0; // no header to be sent!
  end else begin
    // is not valid document (for example, gif image)
Log(Format('Header: %d bytes (ignored)',[RawData.cbInData]));
  end;
end { ProcessHeader };

{ ProcessBody
  get filter context filled by ProcessHeader
  accumulate chuncks of data of RawData
  After last chunk received, filtered data send to web server back
}

procedure ProcessBody(var pfc: THTTP_FILTER_CONTEXT;
  var RawData: PHTTP_FILTER_RAW_DATA);
var
  FilterContext: PEFilterContext;
  NewContent: String;
  OldBody: PChar;
  i: Cardinal;
begin
  FilterContext:= pfc.PFilterContext;
  if Assigned(FilterContext.Body)
  then i:= StrLen(FilterContext.Body)
  else i:= 0;
  Inc(i, RawData.cbInData);
  if i >= FilterContext.BodyLength then begin
    // All blocks done!
Log(Format('Final body: %d of %d bytes',[RawData.cbInData, FilterContext.BodyLength]));
    if Assigned(FilterContext.Body) then begin
      NewContent:= StrPas(FilterContext.Body);
      StrDispose(FilterContext.Body);
      FilterContext.Body:= nil;
    end else NewContent:= '';
    NewContent:= NewContent + StrPas(PChar(Copy(PChar(RawData.pvInData), 1, RawData.cbInData)));
Log('Content: '+IntToStr(FilterContext.BodyLength) + ' bytes');
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
Log('New Content: ' + IntToStr(FilterContext.BodyLength)+' bytes' { #13#10+NewContent } );
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
Log(Format('First Body: %d of %d bytes',[RawData.cbInData, FilterContext.BodyLength]));
      if StrLen(FilterContext.Body) <> RawData.cbInData then
Log(Format('Warning: StrLen %d <> %d BlockLength', [StrLen(FilterContext.Body), RawData.cbInData]));
  //    RawData.pvInData := nil;
      RawData.cbInData:= 0 // no body to be sent, yet!
    end else begin
      // additional block
      OldBody:= FilterContext.Body;
      FilterContext.Body:= StrNew(PChar(StrPas(OldBody) +
        StrPas(PChar(Copy(PChar(RawData.pvInData),1,RawData.cbInData)))));
      StrDispose(OldBody);
Log(Format('Next Body: %d of %d bytes',[RawData.cbInData,FilterContext.BodyLength]));
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
        if Pos('.HTM', UpperCase(UrlMap.pszURL)) > 0 then begin
          // start new URL
          pfc.PFilterContext:= StrNew(MSG_FILT_CONTEXT_INDICATOR);
        end;
      end;
    SF_NOTIFY_SEND_RAW_DATA: begin
        if Assigned(pfc.PFilterContext) then begin
          // URL
          RawData:= PHTTP_FILTER_RAW_DATA(pvNotification);
          if CompareText(PChar(pfc.PFilterContext), MSG_FILT_CONTEXT_INDICATOR) = 0 then begin
            // header
            ProcessHeader(pfc, RawData); // pfc.PEFilterContext nullified
          end else begin
            // pfc.PEFilterContext is null (header processed)
            ProcessBody(pfc, RawData);
          end;
        end;
      end;
  end; { case }
end; { HttpFilterProc }

exports
  GetFilterVersion,
  HttpFilterProc;

begin
  IsMultiThread:= True;
end.

