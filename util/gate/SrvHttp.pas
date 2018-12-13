unit
  SrvHttp;

interface

uses
  SysUtils,
  WinSock, Windows, HttpApp,
  util1, SrvLog, xbase,
{$IFDEF USECGI}
  xCGI,
{$ENDIF}
  Classes;

const
  CServerProductName = 'aehttpd 1.0';
  ERR_TERMINATE   = 0; // ok, no faults
  ERR_WSASSTARTUP = 1; // failed to startup windows sockets
  ERR_FAILSOCKET  = 2; // failed to create the socket
  ERR_BIND        = 3; // failed to bind the socket
type
  // create thread
  THTTPServ = class;
  THTTPServerThread = class(TThread)
  private
    FParentHTTPServ: THTTPServ; // parent
    Buffer: String;
  public
    Socket: TSocket;
    RemoteHost,
    RemoteAddr: string;

    constructor Create(AHTTPServ: THTTPServ; ASocket: TSocket);
    procedure PrepareResponse(d: THTTPData);
    procedure Execute; override;
    destructor Destroy; override;
  end;

  TDoLoopThread = class(TThread)
  private
    FParentHTTPServ: THTTPServ;
  public
    ServerSocketHandle: WinSock.TSocket;
    constructor Create(AParentHttpServ: THttpServ);
    procedure Execute; override;
    destructor Destroy; override;
  end;

  // event, try to open stream
  TRequestFileEvent = procedure (Sender: TObject; const AFileName: String;
    var AFileInfo: TFileInfo;
    var AHandled: Boolean) of object;

  THTTPServ = class
  private
    FLastError: Integer;
    FWSLastError: Integer;
    FTimeZoneBias: Integer;

    FHostCache: TStrings;
    FContentTypes: TStrings;
    FExecutableCache: TStrings;

    FSocketsColl: TCollection;
    FLogger: THttpCustomLogger;
    FResetterThread: TResetterThread;
    FDoLoopThread: TDoLoopThread;

    FBindPort: Integer;
    FBindAddr: Cardinal;
    FStarted: Boolean;

    FRequestFileEvent: TRequestFileEvent;
    FFN_ROOT: String;
    Fcgi_bin: String;
    // FCgiFile: String;
    function OpenRequestedFile(const AFName: string; thr: THttpServerThread; d: THttpData): TAbstractHttpResponseData;
    function GetHostNameByAddr(Addr: DWORD): string;
    procedure SetBindAddr(const AValue: String);
    function GetBindAddr: String;
    procedure SetStarted(AStarted: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run;
  published
    property fn_root: String read FFN_ROOT write FFN_ROOT;
    property cgibin: String read FCGI_BIN write FCGI_BIN;
    property BindIP: String read GetBindAddr write SetBindAddr;
    property BindPort: Integer read FBindPort write FBindPort;
    property Started: Boolean read FStarted write SetStarted;
    property logger: THttpCustomLogger read FLogger write FLogger;
    property ContentTypes: TStrings read FContentTypes write FContentTypes;
    property RequestFileEvent: TRequestFileEvent read FRequestFileEvent write FRequestFileEvent;
  end;

implementation

function GetLine(S: String; ANo: Integer): String; // Ano = 0..
var
  i, p, pp, cnt: Integer;
begin
  p:= 1;
  cnt:= 0;
  S:= S + #13;
  for i:= 1 to Length(S) do begin
    case S[i] of
    #13:
      begin
        pp:= i;
        Inc(cnt);
        if cnt > Ano then begin
          Result:= Copy(S, p, pp-p);
          Exit;
        end;
        p:= i+1;
      end;
    #10: Inc(p);
    end;
  end;
  Result:= '';
end;

const
  DEF_FNCGI_BIN = 'cgi-bin';
  MaxStatusCodeIdx = 36;
  StatusCodes : array[0..MaxStatusCodeIdx] of record Code: Integer; Msg: string end =
  ((Code:100; Msg:'Continue'),
   (Code:101; Msg:'Switching Protocols'),
   (Code:200; Msg:'OK'),
   (Code:201; Msg:'Created'),
   (Code:202; Msg:'Accepted'),
   (Code:203; Msg:'Non-Authoritative Information'),
   (Code:204; Msg:'No Content'),
   (Code:205; Msg:'Reset Content'),
   (Code:206; Msg:'Partial Content'),
   (Code:300; Msg:'Multiple Choices'),
   (Code:301; Msg:'Moved Permanently'),
   (Code:302; Msg:'Moved Temporarily'),
   (Code:303; Msg:'See Other'),
   (Code:304; Msg:'Not Modified'),
   (Code:305; Msg:'Use Proxy'),
   (Code:400; Msg:'Bad Request'),
   (Code:401; Msg:'Unauthorized'),
   (Code:402; Msg:'Payment Required'),
   (Code:403; Msg:'Forbidden'),
   (Code:404; Msg:'Not Found'),
   (Code:405; Msg:'Method Not Allowed'),
   (Code:406; Msg:'Not Acceptable'),
   (Code:407; Msg:'Proxy Authentication Required'),
   (Code:408; Msg:'Request Time-out'),
   (Code:409; Msg:'Conflict'),
   (Code:410; Msg:'Gone'),
   (Code:411; Msg:'Length Required'),
   (Code:412; Msg:'Precondition Failed'),
   (Code:413; Msg:'Request Entity Too Large'),
   (Code:414; Msg:'Request-URI Too Large'),
   (Code:415; Msg:'Unsupported Media Type'),
   (Code:500; Msg:'Internal Server Error'),
   (Code:501; Msg:'Not Implemented'),
   (Code:502; Msg:'Bad Gateway'),
   (Code:503; Msg:'Service Unavailable'),
   (Code:504; Msg:'Gateway Time-out'),
   (Code:505; Msg:'HTTP Version not supported'));

type
  THttpResponseDataFileHandle = class(TAbstractHttpResponseData)
    FStream: TStream;
    constructor Create(AStream: TStream);
  end;

  THttpResponseDataEntity = class(TAbstractHttpResponseData)
    FEntityHeader : TEntityHeader;
    constructor Create(AEntityHeader : TEntityHeader);
  end;

  THttpResponseErrorCode = class(TAbstractHttpResponseData)
    FErrorCode: Integer;
    constructor Create(AErrorCode: Integer);
  end;

const
  sDateFormat = '"%s", dd "%s" yyyy hh:mm:ss';
// 'Sunday, 17-May-98 18:44:23 GMT; length=4956'

constructor THTTPServerThread.Create(AHTTPServ: THTTPServ; ASocket: TSocket);
begin
  inherited Create(True);
  Socket:= ASocket;
  FParentHTTPServ:= AHTTPServ;
end;

destructor THTTPServerThread.Destroy;
begin
  Socket.Free;
  inherited Destroy;
end;

constructor TDoLoopThread.Create(AParentHttpServ: THttpServ);
begin
  inherited Create(False);
  FParentHttpServ:= AParentHttpServ;
end;

destructor TDoLoopThread.Destroy;
begin
  // FParentHTTPServ.Started:= False;
  inherited Destroy;
end;

procedure TDoLoopThread.Execute;
const
  KillQuants = 5; // Quants to shut down socket for inactivity
var
  J: Integer;
  FNewSocketHandle: winsock.TSocket;
  NewSocket: TSocket;
  NewThread: THTTPServerThread;
  WData: TWSAData;
  Addr: TSockAddr;
  s: string;
begin
  FParentHTTPServ.FLastError:= ERR_TERMINATE;  // no error
  FParentHTTPServ.FWSLastError:= WSAStartup(MakeWord(1,1), WData); // last windows socket error
  if FParentHTTPServ.FWSLastError <> 0 then begin
    if Assigned(FParentHTTPServ.FLogger) then begin
      S:= 'Failed to initialize WinSocket, error #'+IntToStr(FParentHTTPServ.FWSLastError);
      FParentHTTPServ.FLogger.AddLog(LOGERROR, [s]);
    end;
    FParentHTTPServ.FLastError:= ERR_WSASSTARTUP;
    Exit;
  end;
  ServerSocketHandle:= socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

  if ServerSocketHandle = INVALID_SOCKET then begin
    FParentHTTPServ.FWSLastError:= WSAGetLastError;
    if Assigned(FParentHTTPServ.FLogger) then begin
      s := 'Failed to create a socket, Error #'+IntToStr(WSAGetLastError);
      FParentHTTPServ.FLogger.AddLog(LOGERROR, [s]);
    end;
    FParentHTTPServ.FLastError:= ERR_FAILSOCKET;
    Exit;
  end;
  // J:= $00010001;  setsockopt(ServerSocketHandle, SOL_SOCKET, SO_LINGER, @J, SizeOf(J));
  // J:= 1; setsockopt(ServerSocketHandle, SOL_SOCKET, SO_REUSEADDR, @J, SizeOf(J));

  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(FParentHTTPServ.FBindPort);
  Addr.sin_addr.s_addr := FParentHTTPServ.FBindAddr;
  if bind(ServerSocketHandle, Addr, SizeOf(Addr)) = SOCKET_ERROR then begin
    FParentHTTPServ.FWSLastError:= WSAGetLastError;
    if Assigned(FParentHTTPServ.FLogger) then begin
      S:= 'Failed to bind the socket, error #'+IntToStr(WSAGetLastError)+
        'ip: '+FParentHTTPServ.BindIP+', port '+IntToStr(FParentHTTPServ.FBindPort)+'.';
      FParentHTTPServ.FLogger.AddLog(LOGERROR, [s]);
    end;
    FParentHTTPServ.FLastError:= ERR_BIND;
    CloseSocket(ServerSocketHandle);
    Exit;
  end;
  FParentHTTPServ.FSocketsColl:= TCollection.Create(TCollectionItem);
  FParentHTTPServ.FResetterThread:= TResetterThread.Create(FParentHTTPServ.FSocketsColl);
  FParentHTTPServ.FResetterThread.FreeOnTerminate:= True;
  listen(ServerSocketHandle, 5);
  repeat
    if Terminated then Break;
    J:= SizeOf(Addr);
    FNewSocketHandle:= winsock.accept(ServerSocketHandle, @Addr, @J); //Addr
    if FNewSocketHandle = INVALID_SOCKET then begin
      Continue;
    end;
    if Terminated then Break;
    if FNewSocketHandle = INVALID_SOCKET then Exit;
    NewSocket:= TSocket.Create(FParentHTTPServ.FSocketsColl, FParentHTTPServ.FResetterThread,
      FNewSocketHandle, Addr);
    // FParentHTTPServ.FSocketsColl.Enter;
    if FParentHTTPServ.FResetterThread.FSocketsColl.Count = 0 then begin // ?!! ---------------------------------------------------------------------------------------
      FParentHTTPServ.FResetterThread.TimeToSleep:= SleepQuant1Min;
      SetEvent(FParentHTTPServ.FResetterThread.FResetterSleep);
    end;
    // FParentHTTPServ.FSocketsColl.Leave;
    NewThread:= THTTPServerThread.Create(FParentHTTPServ, NewSocket);
    NewThread.FreeOnTerminate:= True;
    NewThread.Resume;
  until Terminated;
  CloseSocket(ServerSocketHandle);
  // WSACleanup;
end;

constructor THttpResponseDataEntity.Create(AEntityHeader : TEntityHeader);
begin
  inherited Create;
  FEntityHeader := AEntityHeader;
end;

constructor THttpResponseErrorCode.Create(AErrorCode: Integer);
begin
  inherited Create;
  FErrorCode := AErrorCode;
end;

constructor THttpResponseDataFileHandle.Create(AStream: TStream);
begin
  FStream:= AStream;
end;

constructor THttpServ.Create;
var
  fn: array[0..259] of Char;
begin
  inherited;
  FRequestFileEvent:= Nil;
  FStarted:= False;
  //--- Set Hight priority class
  //  SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS);
  //--- Initialize xBase Module
  FTimeZoneBias:= GetBias;
  FHostCache:= TStringList.Create;
  TStringList(FHostCache).Duplicates:= dupIgnore;
  TStringList(FHostCache).Sorted:= True;
  FExecutableCache:= TStringList.Create;
  {
  FExecutableCache.Enter;  FExecutableCache.Leave;
  }
  //--- Get and validate a home directory
  SetString(FFN_ROOT, FN, GetModuleFileName(hInstance, FN, SizeOf(FN)));
    FFN_ROOT:= ExtractFilePath(FFN_ROOT);
  if FFN_ROOT[Length(FFN_ROOT)] = '\'
  then Delete(FFN_ROOT, Length(FFN_ROOT), 1);
  // cgi-bin
  Fcgi_bin:= DEF_FNCGI_BIN;
  // server socket init failure error code or other fatal error
  FLastError:= 0;
  FWSLastError:= 0;
  // bind address
  FBindAddr:= winsock.INADDR_ANY;
  // port
  FBindPort:= 80;
  //--- Read content types from registry later
  FContentTypes:= Nil;
  // --- Open log files and initialize semaphores
  FLogger:= Nil;
  FSocketsColl:= Nil;
  FResetterThread:= Nil;
  // FCgiFile:= '';
  // FPathInfo:= '';
  FDoLoopThread:= Nil;
end;

destructor THttpServ.Destroy;
begin
  Started:= False;
  // do not! if Assigned(FSocketsColl) then FSocketsColl.Free;
  // do not! if Assigned(FContentTypes)then FContentTypes.Free;
  // do not! if Assigned(FLogger) then FLogger.Free;
  FExecutableCache.Free;
  FHostCache.Free;
  inherited;
end;

function THTTPServ.GetHostNameByAddr(Addr: DWORD): string;
type
  PDwordArray = ^TDwordArray;
  TDwordArray = array[0..(MaxLongInt div 4)-1] of DWORD;
var
  p: PHostEnt;
  idx: Integer;
  ok: Boolean;
  he: PHostEnt;
  HostName: string;
begin
  idx:= FHostCache.IndexOfName(IntToStr(Addr));
  if idx >= 0 then begin
    Result:= Copy(FHostCache[idx], Pos('=', FHostCache[idx])+1, MaxInt);
  end else begin
    p:= gethostbyaddr(@addr, 4, PF_INET);
    ok := False;
    if p <> nil then begin // host name got - now get address of this name
      HostName:= p^.h_name;
      he:= gethostbyname(PChar(HostName));
      if (he <> nil) and (he^.h_addr_list <> nil) then begin // address got - now compare it with the real one
        ok:= PDwordArray(he^.h_addr_list^)^[0] = Addr;
      end;
    end;
    if ok then Result := HostName else Result := IP2Str(Addr);
    FHostCache.Add(IntToStr(Addr) + '=' + HostName);
  end;
end;

procedure THTTPServ.SetBindAddr(const AValue: String);
begin
  FBindAddr:= winsock.inet_addr(PChar(AValue));
end;

function THTTPServ.GetBindAddr: String;
begin
  Result:= util1.IP2Str(FBindAddr);
end;

function THTTPServ.OpenRequestedFile(const AFName: string; thr: THttpServerThread; d: THttpData): TAbstractHttpResponseData;
var
  z: string;
  ct: TDateTime;
  Handled: Boolean;
begin
// Try to open Requested file
  z := LowerCase(AFName);
  {
  if Copy(z, 1, Length(FFN_ROOT)) <> LowerCase(FFN_ROOT) then begin
    Result := THttpResponseErrorCode.Create(403);
    Exit;
  end;
  if Copy(z, 1, Length(FFN_ROOT)+1+Length(Fcgi_bin)+1) = FFN_ROOT+'\'+(Fcgi_bin)+'\' then begin
    Result := THttpResponseErrorCode.Create(403);
    Exit;
  end;
  }
  Handled:= True;
  d.FileDesc.FStream:= Nil;
  z:= ExtractFileExt(AFName);
  z:= LowerCase(Copy(z, 2, Length(z)-2+1));
  if z <> ''
  then d.FileDesc.mime:= FContentTypes.Values[z];
  if d.FileDesc.mime = ''
  then d.FileDesc.mime:= 'text/plain';

  if Assigned(FRequestFileEvent)
  then FRequestFileEvent(Self, AFName, d.FileDesc, Handled);
  if Handled and Assigned(d.FileDesc.FStream) then begin
    d.ResponseEntityHeader:= TEntityHeader.Create;
    d.ResponseEntityHeader.ContentType:= d.FileDesc.mime;
    d.ResponseEntityHeader.EntityLength:= d.FileDesc.FStream.Size;
    d.ResponseEntityHeader.LastModified:=
      Format(FormatDateTime(sDateFormat + ' "GMT"', d.FileDesc.Time), [DayOfWeekStr(d.FileDesc.Time), MonthStr(d.FileDesc.Time)]);
    ct:= Now;
    d.ResponseGeneralHeader.Date :=
      Format(FormatDateTime(sDateFormat + ' "GMT"', ct), [DayOfWeekStr(ct), MonthStr(ct)]);
    Result:= THttpResponseDataFileHandle.Create(d.FileDesc.FStream);
  end else begin
    if Assigned(FLogger)
    then FLogger.AddLog(LOGERROR, ['access to '+AFName+' failed for '+thr.RemoteHost+', reason: '+SysErrorMsg(GetLastError)]);
    Result:= THttpResponseErrorCode.Create(404);
  end;
end;

function ReturnNewLocation(const ALocation: string; d: THTTPData): TAbstractHttpResponseData;
begin
  d.ResponseResponseHeader.Location:= ALocation;
  Result:= THttpResponseErrorCode.Create(302);
end;

function IsURL(const s: string): Boolean;
begin
  Result := Pos('://', s) > 0;
end;

procedure THTTPServerThread.PrepareResponse(d: THTTPData);
var
  r: TAbstractHttpResponseData;
  rf: THttpResponseDataFileHandle absolute r;
  re: THttpResponseDataEntity absolute r;
  rc: THttpResponseErrorCode absolute r;
begin
  r:= FParentHTTPServ.OpenRequestedFile(d.URIPath, Self, d);
  if r = nil
  then raise Exception.CreateFmt('http response is nil', [r]);
  if r is THttpResponseDataFileHandle then begin
    d.FStream:= rf.FStream;
    d.TransferFile:= True;
    d.ReportError:= False;
    d.StatusCode:= 200;
  end else
  if r is THttpResponseDataEntity then begin
    d.ResponseEntityHeader:= re.FEntityHeader;
    d.ReportError:= False;
    d.StatusCode:= 200;
  end else
  if r is THttpResponseErrorCode then begin
    d.StatusCode := rc.FErrorCode;
  end else raise Exception.CreateFmt('unknown http response code', [d]);
  r.Free;
end;

function ParseHTTPCmd(s: String; var Method, RequestURI, HTTPVersion: String): Boolean;
var
  p, l: Integer;
begin
  p:= 1;
  l:= Length(s);
  Method:= UpperCase(util1.ExtractToken(S, p));
  HTTPVersion:= UpperCase(util1.ExtractTokenBack(S, L));
  if Pos('HTTP', HTTPVersion) <> 1 then begin
     L:= Length(s);
     HTTPVersion:= 'HTTP/1.0';
  end else begin
  end;
  RequestURI:= '';
  repeat
    RequestURI:= RequestURI + #32 + util1.ExtractToken(S, p);
  until p >= L;
  Result:= True;
end;

procedure THTTPServerThread.Execute;
var
  FPOS: Integer;
  i, p, bytesread: Integer;
  s, z, k: string;
  d: THTTPData;
  AbortConnection: Boolean;
  HeaderParsedAllready: Boolean;
  Actually: Integer;
  reqContentLength: Integer;
begin
  if not Assigned(Socket) then begin
    raise Exception.CreateFmt('Socket is not assigned: %d', [Integer(Socket)]);
  end;
  RemoteAddr:= IP2Str(Socket.FAddr);
  RemoteHost:= FParentHTTPServ.GetHostNameByAddr(Socket.FAddr);
  HeaderParsedAllready:= False;
  AbortConnection:= False;
  repeat
    if Terminated then Break;
    AbortConnection:= False;
    d:= THTTPData.Create;
    d.StatusCode := 400;
    d.ReportError := True;
    d.ResponseGeneralHeader := TGeneralHeader.Create;
    if d.ResponseResponseHeader = nil
    then d.ResponseResponseHeader:= TResponseHeader.Create;
    s := '';
    with d do begin
      d.FRequest:= '';
      reqContentLength:= -1;
      repeat
        SetLength(Buffer, CHTTPServerThreadBufSize);
        bytesread:= Socket.Read(Buffer[1], CHTTPServerThreadBufSize);
        if (bytesread <= 0) or (Socket.Status <> 0)
        then Break;
        SetLength(Buffer, bytesread);
        d.FRequest:= d.FRequest + Buffer;
        // Parse the request

        if not HeaderParsedAllready then begin
          if Pos(#13#10, FRequest) <= 0
          then Continue;
          s:= GetLine(FRequest, 0);  // bytesread > 0
          // if not ProcessQuotes(s) then Break;
          ParseHTTPCmd(s, Method, RequestURI, HTTPVersion);
          s:= '';
          z:= '';
          i:= 1; // first line parsed
          repeat
            s:= GetLine(FRequest, i);
            if Length(s) = 0 then begin
              HeaderParsedAllready:= True;
              reqContentLength:= StrToIntDef(RequestEntityHeader.ContentLength, -1);
              Break;  // header finished
            end;
            GetWrdStrict(s, z);
            z:= UpperCase(s);
            Delete(z, Length(z), 1);
            if not RequestGeneralHeader.Filter(z, s) and
               not RequestRequestHeader.Filter(z, s) and
               not RequestEntityHeader.Filter(z, s) then begin
              // New Feature !!!
            end;
            s:= '';
            z:= '';
            Inc(i);
          until False;
        end else begin
          if reqContentLength <= -1
          then Break;
          if Length(FRequest) < reqContentLength
          then Continue;
        end;

        // process entity body
        RequestEntityHeader.CopyEntityBodyS(FRequest);

        // FRequestSL.Free;
        KeepAlive := UpperCase(RequestGeneralHeader.Connection) = 'KEEP-ALIVE';

        if (Method <> 'GET') and (Method <> 'POST') and (Method <> 'HEAD') then begin
          StatusCode:= 403;
          Break;
        end else begin
          // Parse URI
          {
          s:= RequestURI;
          p:= Pos('?', s);
          if p > 0 then begin
            URIQuery := Copy(S, p+1, Length(S)-p-1+1);
            Delete(s, p, MaxInt);
            if Pos('=', URIQuery) = 0 then begin
              URIQueryParam:= util1.HTTPParameterDecode(URIQuery);
            end;
          end;
          p:= Pos(';', s);
          if p > 0 then begin
            URIParams := Copy(s, p+1, Length(s)-p-1+1);
            Delete(s, p, MaxInt);
          end;
          }
          URIPath:= util1.HTTPParameterDecode(RequestURI);
          with FParentHTTPServ do if Assigned(FLogger) then begin
            FLogger.AddLog(LOGREFERER, [d.RequestRequestHeader.Referer, d.URIPath]);
            FLogger.AddLog(LOGAGENT, d.RequestRequestHeader.UserAgent);
          end;
          PrepareResponse(d);
          Break;
        end;
      until False;

      // Send a response
      if ResponseEntityHeader = nil
      then ResponseEntityHeader:= TEntityHeader.Create;

      s:= ResponseEntityHeader.CGIStatus;
      if s <> '' then begin
	k := s;
	GetWrd(k, z, ' ');
        Val(z, StatusCode, p);
	if StatusCode <> 200
        then ReportError := True;
      end else begin
        // Get Status Line
        for i:= 0 to MaxStatusCodeIdx do if StatusCode = StatusCodes[i].Code then begin
          s := StatusCodes[i].Msg;
          Break;
        end;
        if s = '' then raise Exception.CreateFmt('unknown status code: %d', [StatusCode]);
        if ErrorMsg = '' then ErrorMsg := s;
        s := IntToStr(StatusCode)+ ' '+ s;
      end;
      if not Assigned(FStream) then begin
        ReportError:= True;
        TransferFile:= False;
        s:= '204 No content is available now';
        ErrorMsg:= s;
      end;
      if ReportError then begin
        KeepAlive := False;
        if ResponseEntityHeader.ContentType = '' then ResponseEntityHeader.ContentType := 'text/html';
        if ResponseEntityHeader.EntityBody = '' then ResponseEntityHeader.EntityBody :=
          '<HTML>' + '<TITLE>'+s+'</TITLE>'+ '<BODY><H1>'+ErrorMsg+'</H1></BODY>'+'</HTML>';
        ResponseEntityHeader.EntityLength := Length(ResponseEntityHeader.EntityBody);
      end;

      ResponseEntityHeader.ContentLength := IntToStr(ResponseEntityHeader.EntityLength);

      if KeepAlive then ResponseGeneralHeader.Connection := 'Keep-Alive';

      ResponseResponseHeader.Server := CServerProductName;

      if ReportError
      then p:= -1
      else p:= ResponseEntityHeader.EntityLength;
      if Assigned(FParentHTTPServ.FLogger)
      then FParentHTTPServ.FLogger.AddLog(LOGACCESS, [RemoteHost,
        Method + ' ' + URIPath, HTTPVersion, d.AuthUser, IntToStr(StatusCode),  IntToStr(p)]);
      s := 'HTTP/1.0 '+ s + #13#10+
        ResponseGeneralHeader.OutString+ ResponseResponseHeader.OutString+
        ResponseEntityHeader.OutString+#13#10;

      if TransferFile then begin
        Socket.Write(s[1], Length(s));
        FPOS := 0;
        repeat
          SetLength(Buffer, CHTTPServerThreadBufSize);
          Actually:= FStream.Read(Buffer[1], CHTTPServerThreadBufSize);
          SetLength(Buffer, Actually);
          Inc(FPOS, Actually);
          if FPOS > FileDesc.FStream.Size then Break;
          if Actually = 0 then Break;
          Actually := Socket.Write(Buffer[1], Actually);
        until (FPOS = FileDesc.Fstream.Size) or (Actually < CHTTPServerThreadBufSize) or (Socket.Status <> 0);
        AbortConnection := FPOS <> FileDesc.FStream.Size;
        FStream.Free;
      end else begin
        s:= s + ResponseEntityHeader.EntityBody;
        Socket.Write(s[1], Length(s));
      end;
      AbortConnection := AbortConnection or not KeepAlive;
    end;
    d.Free;
  until AbortConnection
end;

procedure THttpServ.SetStarted(AStarted: Boolean);
var
  i: Integer;
  FStopSocketHandle: winsock.TSocket;
  Addr: TSockAddr;
  S: String;
begin
  if AStarted then begin
    if FStarted or Assigned(FDoLoopThread) // if started allready
    then Exit;
    FDoLoopThread:= TDoLoopThread.Create(Self);
    FDoLoopThread.FreeOnTerminate:= True;
    FStarted:= True;
  end else begin
    if not FStarted  // if stopped allready
    then Exit;
    if Assigned(FResetterThread) then begin
      SetEvent(FResetterThread.FResetterSleep);
      for i:= 0 to FSocketsColl.Count - 1 do begin
        shutdown(TSocket(FSocketsColl.Items[i]).Handle, 2); // disables send or receive on a socket.
      end;
      FSocketsColl.Free;
      while FSocketsColl.Count > 0
      do Sleep(1000);
      FResetterThread.TimeToSleep:= SleepQuant1Min;
      FResetterThread.Terminate;
      SetEvent(FResetterThread.FResetterSleep);
      FResetterThread:= Nil;
      // wake up resetter thread
    end;
    if Assigned(FDoLoopThread) then begin
      FDoLoopThread.Terminate;

      // wake up do loop thread (send to socket to accept in execute)
      FStopSocketHandle:= socket(PF_INET, SOCK_STREAM, IPPROTO_IP); //AF_UNIX

      if FStopSocketHandle = INVALID_SOCKET then begin
        FWSLastError:= WSAGetLastError;
        if Assigned(FLogger) then begin
          s := 'Failed to create a socket, Error #'+IntToStr(WSAGetLastError);
          FLogger.AddLog(LOGERROR, [s]);
        end;
        FLastError:= ERR_FAILSOCKET;
      end;


      Addr.sin_family:= AF_INET; //AF_UNIX
      Addr.sin_port:= htons(FBindPort);
      Addr.sin_addr.s_addr:= INADDR_LOOPBACK;

      if winsock.connect(FStopSocketHandle, Addr, Sizeof(Addr)) <> 0 then begin
        FWSLastError:= WSAGetLastError;
        if Assigned(FLogger) then begin
          S:= 'Failed to bind the socket, error #'+IntToStr(WSAGetLastError)+
            'ip: '+BindIP+', port '+IntToStr(FBindPort)+'.';
          FLogger.AddLog(LOGERROR, [s]);
        end;
        FLastError:= ERR_BIND;
        CloseSocket(FStopSocketHandle);
      end;
      FDoLoopThread:= Nil;
    end;
    FStarted:= False;
  end;
end;

procedure THTTPServ.Run;
const
  KillQuants = 5; // Quants to shut down socket for inactivity
var
  J: Integer;
  ServerSocketHandle: WinSock.TSocket;
  NewSocket: TSocket;
  NewThread: THTTPServerThread;
  NewSocketHandle: winsock.TSocket;  
  WData: TWSAData;
  Addr: TSockAddr;
  s: string;
begin
  FLastError:= ERR_TERMINATE;  // no error
  FWSLastError:= WSAStartup(MakeWord(1,1), WData); // last windows socket error
  if FWSLastError <> 0 then begin
    if Assigned(FLogger) then begin
      S:= 'Failed to initialize WinSocket, error #'+IntToStr(FWSLastError);
      FLogger.AddLog(LOGERROR, [s]);
    end;
    FLastError:= ERR_WSASSTARTUP;
    Exit;
  end;
  ServerSocketHandle:= socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  if ServerSocketHandle = INVALID_SOCKET then begin
    FWSLastError:= WSAGetLastError;
    if Assigned(FLogger) then begin
      s := 'Failed to create a socket, Error #'+IntToStr(WSAGetLastError);
      FLogger.AddLog(LOGERROR, [s]);
    end;
    FLastError:= ERR_FAILSOCKET;
    Exit;
  end;

  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(FBindPort);
  Addr.sin_addr.s_addr := FBindAddr;
  if bind(ServerSocketHandle, Addr, SizeOf(Addr)) = SOCKET_ERROR then begin
    FWSLastError:= WSAGetLastError;
    if Assigned(FLogger) then begin
      S:= 'Failed to bind the socket, error #'+IntToStr(WSAGetLastError)+
        'ip: '+BindIP+', port '+IntToStr(FBindPort)+'.';
      FLogger.AddLog(LOGERROR, [s]);
    end;
    FLastError:= ERR_BIND;
    CloseSocket(ServerSocketHandle);
    Exit;
  end;
  FSocketsColl:= TCollection.Create(TSocket);
  FResetterThread:= TResetterThread.Create(FSocketsColl);

  listen(ServerSocketHandle, 5);
  repeat
    J:= SizeOf(Addr);
    NewSocketHandle:= winsock.accept(ServerSocketHandle, @Addr, @J); //Addr
    if NewSocketHandle = INVALID_SOCKET then Exit;
    NewSocket:= TSocket.Create(FSocketsColl, FResetterThread,
      NewSocketHandle, Addr);
    if FResetterThread.FSocketsColl.Count = 0 then begin // ?!! ---------------------------------------------------------------------------------------
      FResetterThread.TimeToSleep := SleepQuant1Min;
      SetEvent(FResetterThread.FResetterSleep);
    end;
    NewThread:= THTTPServerThread.Create(Self, NewSocket);
    NewThread.FreeOnTerminate:= True;
    NewThread.Resume;
  until False;
  CloseSocket(ServerSocketHandle);
end;

end.
