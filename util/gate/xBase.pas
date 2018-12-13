unit
  xBase;

interface

uses
  Classes, sysutils, Windows, WinSock;

const
  INVALID_FILE_ATTRIBUTES = INVALID_FILE_SIZE;
  INVALID_FILE_TIME       = INVALID_FILE_SIZE;
  INVALID_VALUE           = INVALID_HANDLE_VALUE;
  CHTTPServerThreadBufSize= $2000;
  SleepQuant1Min          = 1*60*1000; // 1 minute

{ Maximum TColl size }
  MaxCollSize = $20000 div SizeOf(Pointer);

type

  TGeneralHeader = class
    CacheControl,            // Section 14.9
    Connection,              // Section 14.10
    Date,                    // Section 14.19
    Pragma,                  // Section 14.32
    TransferEncoding,        // Section 14.40
    Upgrade,                 // Section 14.41
    Via : string;            // Section 14.44
    function Filter(const z, s: string): Boolean;
    function OutString: string;
  end;

  TResponseHeader = class
    Age,                    // Section 14.6
    Location,               // Section 14.30
    ProxyAuthenticate,      // Section 14.33
    Public_,                // Section 14.35
    RetryAfter,             // Section 14.38
    Server,                 // Section 14.39
    Vary,                   // Section 14.43
    Warning,                // Section 14.45
    WWWAuthenticate         // Section 14.46
      : string;
    function OutString: string;
  end;

  TRequestHeader = class
    Accept,                  // Section 14.1
    AcceptCharset,           // Section 14.2
    AcceptEncoding,          // Section 14.3
    AcceptLanguage,          // Section 14.4
    Authorization,           // Section 14.8
    From,                    // Section 14.22
    Host,                    // Section 14.23
    IfModifiedSince,         // Section 14.24
    IfMatch,                 // Section 14.25
    IfNoneMatch,             // Section 14.26
    IfRange,                 // Section 14.27
    IfUnmodifiedSince,       // Section 14.28
    MaxForwards,             // Section 14.31
    ProxyAuthorization,      // Section 14.34
    Range,                   // Section 14.36
    Referer,                 // Section 14.37
    UserAgent,               // Section 14.42
    Cookie: string;          // rfc-2109
    function Filter(const z, s: string): Boolean;
  end;

  TEntityHeader = class
    Allow,                   // Section 14.7
    ContentBase,             // Section 14.11
    ContentEncoding,         // Section 14.12
    ContentLanguage,         // Section 14.13
    ContentLength,           // Section 14.14
    ContentLocation,         // Section 14.15
    ContentMD5,              // Section 14.16
    ContentRange,            // Section 14.17
    ContentType,             // Section 14.18
    ETag,                    // Section 14.20
    Expires,                 // Section 14.21
    LastModified,            // Section 14.29
    EntityBody: string;
    EntityLength: Integer;
    SetCookie,
    CGIStatus,
    CGILocation: string;
    function Filter(const z, s: string): Boolean;
    // procedure CopyEntityBody(Collector: TCollector);
    procedure CopyEntityBodyS(const S: String);
    function OutString: string;
  end;

  TSocketOption = (soBroadcast, soDebug, soDontLinger,
    soDontRoute, soKeepAlive, soOOBInLine,
    soReuseAddr, soNoDelay, soBlocking, soAcceptConn);

  TSocketOptions = set of TSocketOption;

  TSocketClass = class of TSocket;

//  TColl = class (TCollectionItem);
  TResetterThread = class(TThread)
    TimeToSleep,
    FResetterSleep: DWORD;
    FSocketsColl: TCollection;
    FLock: TRTLCriticalSection;
    constructor Create(ASocketsColl: TCollection);
    procedure Execute; override;
    destructor Destroy; override;
    // procedure Terminate; override;
  end;

  TAdvCpObject = class
    function Copy: Pointer; virtual; abstract;
  end;

  PItemList = ^TItemList;
  TItemList = array[0..MaxCollSize - 1] of Pointer;
  TForEachProc = procedure(P: Pointer) of object;
  TListSortCompare = function (Item1, Item2: Pointer): Integer;
  TSocket = class(TCollectionItem)
  public
    Dead: Integer;
    FPort: DWORD;
    FAddr: DWORD;
    Handle: DWORD;
    Status: Integer;
    FResetterThread: TResetterThread;
    constructor Create(ASocketsColl: TCollection; AResetterThread: TResetterThread;
      AHandle: Winsock.TSocket; AAddr: TSockAddr); 
    destructor Destroy; override;
    function Read(var B; Size: DWORD): DWORD;
    function Write(const B; Size: DWORD): DWORD;
  end;

  TObjProc = procedure of object;

  PFileInfo = ^TFileInfo;
  TFileInfo = record
    Time: TDateTime;
    FStream: TStream;
    mime: String[250];
  end;

  TAbstractHttpResponseData = class
  end;

  THTTPData = class
    FRequest: String;
    FileDesc: TFileInfo;

    FStream: TStream;
    StatusCode,
    HTTPVersionHi,
    HTTPVersionLo: Integer;

    TransferFile,
    ReportError,
    KeepAlive: Boolean;

    ErrorMsg,
    Method, RequestURI, HTTPVersion, AuthUser, AuthPassword, AuthType,
    URIPath, URIParams, URIQuery, URIQueryParam : string;

    ResponceObjective: TAbstractHttpResponseData;

    RequestGeneralHeader: TGeneralHeader;
    RequestRequestHeader: TRequestHeader;
    RequestEntityHeader: TEntityHeader;

    ResponseGeneralHeader: TGeneralHeader;
    ResponseResponseHeader: TResponseHeader;
    ResponseEntityHeader: TEntityHeader;
    constructor Create;
    destructor Destroy; override;
  end;

  TuFindData = record
    Info: TFileInfo;
    FName: string;
  end;

procedure GetWrdStrict(var s,w:string);
procedure GetWrd(var s,w:string;c:char);
function  ProcessQuotes(var s: string): Boolean;

function  ClearHandle(var Handle: THandle): Boolean;
function  GetEnvVariable(const Name: string): string;
function  SysErrorMsg(ErrorCode: DWORD): string;

implementation

uses
  util1;

procedure GetWrd(var s,w:string;c:char);
begin
 w:=''; if s='' then Exit;
 if c = ' ' then
 util1.DeleteLeadTerminateSpaceStr(s);
 while (Length(s)>0) and (s[1]<>c) do begin
   w:= w+s[1];
   Delete(s, 1, 1);
 end;
 Delete(s, 1, 1);
end;

procedure GetWrdStrict(var s, w: String);
begin
  w:='';
  if s=''
  then Exit;
  while (Length(s)>0) and (s[1]<>' ') do begin
    w:= w + s[1];
    Delete(s, 1, 1);
  end;
  Delete(s, 1, 1);
end;

function MinD(A, B: DWORD): DWORD; assembler;
asm
  cmp  eax, edx
  jb   @@b
  xchg eax, edx
@@b:
end;

function ClearHandle(var Handle: DWORD): Boolean;
begin
  if Handle = INVALID_HANDLE_VALUE then Result := False else begin
    Result := CloseHandle(Handle);
    Handle := INVALID_HANDLE_VALUE;
  end;
end;

function SysErrorMsg(ErrorCode: DWORD): string;
var
  Len: Integer;
  Buffer: array[0..255] of Char;
begin
  Len := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or
    FORMAT_MESSAGE_ARGUMENT_ARRAY, nil, ErrorCode, 0, Buffer,
    SizeOf(Buffer), nil);
  while (Len > 0) and (Buffer[Len - 1] in [#0..#32, '.']) do Dec(Len);
  SetString(Result, Buffer, Len);
end;

function GetEnvVariable(const Name: string): string;
const
  BufSize = 128;
var
  Buf: array[0..BufSize] of Char;
  I: DWORD;
begin
  I := GetEnvironmentVariable(PChar(Name), Buf, BufSize);
  case I of
    1..BufSize:
      begin
        SetLength(Result, I);
        Move(Buf, Result[1], I);
      end;
    BufSize+1..MaxInt:
      begin
        SetLength(Result, I+1);
        GetEnvironmentVariable(PChar(Name), @Result[1], I);
        SetLength(Result, I);
      end;
    else
      begin
        Result := '';
      end;
   end;
end;

constructor TSocket.Create(ASocketsColl: TCollection; AResetterThread: TResetterThread;
  AHandle: Winsock.TSocket; AAddr: TSockAddr);
begin
  inherited Create(ASocketsColl);
  FResetterThread:= AResetterThread;
  Handle:= AHandle;
  FAddr:= AAddr.sin_addr.s_addr;
  FPort:= AAddr.sin_port;
end;

destructor TSocket.Destroy;
begin
  CloseSocket(Handle);
  if FResetterThread.FSocketsColl.Count = 0
  then FResetterThread.TimeToSleep:= INFINITE;
  // free
  inherited Destroy;
end;

function TSocket.Read(var B; Size: DWORD): DWORD;
var
  i: Integer;
begin
  i := recv(Handle, B, Size, 0);
  if (i = SOCKET_ERROR) or (I < 0) then begin
    Status := WSAGetLastError;
    Result := 0
  end else Result := i;
  Dead := 0;
end;

function TSocket.Write(const B; Size: DWORD): DWORD;
const
  cWrite = $4000;
var
  p: PByteArray;
  Written, Left, i, WriteNow: DWORD;
  cnt: Integer;
begin
  p:= @B;
  i := 0;
  Left := Size;
  while Left > 0 do begin
    WriteNow := MinD(Left, cWrite);
    cnt:= send(Handle, p^[i], WriteNow, 0);
    if (cnt = SOCKET_ERROR) or (cnt < 0) then begin
      Status := WSAGetLastError;
      Written:= 0
    end else Written:= I;
    Dead := 0;
    Inc(i, Written);
    Dec(Left, Written);
    if Written <> WriteNow then Break;
  end;
  Result := i;
end;

function ProcessQuotes(var s: string): Boolean;
var
  r: string;
  i: Integer;
  KVC: Boolean;
  c: Char;
begin
  Result := False;
  KVC := False;
  for i := 1 to Length(s) do
  begin
    c := s[i];
    case c of
      #0..#9, #11..#12, #14..#31 : Exit;
      '"' : begin KVC := not KVC; Continue end;
    end;
    if KVC then r := r + '%' + IntToHex(Byte(c), 2) else r := r + c;
  end;
  Result := not KVC;
  if Result then s := r;
end;

constructor TResetterThread.Create(ASocketsColl: TCollection);
begin
  inherited Create(False);
  FResetterSleep:= CreateEvent(nil, False, False, nil);
  TimeToSleep:= INFINITE;
  FSocketsColl:= ASocketsColl;
  InitializeCriticalSection(FLock);
end;

destructor TResetterThread.Destroy;
begin
  CloseHandle(FResetterSleep);
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure TResetterThread.Execute;
const
  KillQuants = 5; // Quants to shut down socket for inactivity
var
  i: Integer;
  s: TSocket;
begin
  repeat
    WaitForSingleObject(FResetterSleep, TimeToSleep);
    if Terminated then Break;
    EnterCriticalSection(FLock);
    for i:= 0 to FSocketsColl.Count - 1 do begin
      s:= TSocket(FSocketsColl.Items[i]);
      if s.Dead < 0 then Continue; // Already shut down
      Inc(s.Dead);
      if s.Dead <= KillQuants then Continue; // This one shows activity - let him live
      s.Dead := -1; // Mark
      shutdown(s.Handle, 2); // disables send or receive on a socket.
      // remove from collection
      FSocketsColl.Delete(s.Index);
    end;
    LeaveCriticalSection(FLock);
  until Terminated;
end;

function TGeneralHeader.Filter(const z, s: string): Boolean;
begin
  Result := True;
  if z = 'CACHE-CONTROL'       then CacheControl       := s else // Section 14.9
  if z = 'CONNECTION'          then Connection         := s else // Section 14.10
  if z = 'DATE'                then Date               := s else // Section 14.19
  if z = 'PRAGMA'              then Pragma             := s else // Section 14.32
  if z = 'TRANSFER-ENCODING'   then TransferEncoding   := s else // Section 14.40
  if z = 'UPGRADE'             then Upgrade            := s else // Section 14.41
  if z = 'VIA'                 then Via                := s else // Section 14.44
    Result := False;
end;

function TRequestHeader.Filter(const z, s: string): Boolean;
begin
  Result := True;
  if z = 'ACCEPT'              then Accept             := s else // Section 14.1
  if z = 'ACCEPT-CHARSET'      then AcceptCharset      := s else // Section 14.2
  if z = 'ACCEPT-ENCODING'     then AcceptEncoding     := s else // Section 14.3
  if z = 'ACCEPT-LANGUAGE'     then AcceptLanguage     := s else // Section 14.4
  if z = 'AUTHORIZATION'       then Authorization      := s else // Section 14.8
  if z = 'FROM'                then From               := s else // Section 14.22
  if z = 'HOST'                then Host               := s else // Section 14.23
  if z = 'IF-MODIFIED-SINCE'   then IfModifiedSince    := s else // Section 14.24
  if z = 'IF-MATCH'            then IfMatch            := s else // Section 14.25
  if z = 'IF-NONE-MATCH'       then IfNoneMatch        := s else // Section 14.26
  if z = 'IF-RANGE'            then IfRange            := s else // Section 14.27
  if z = 'IF-UNMODIFIED-SINCE' then IfUnmodifiedSince  := s else // Section 14.28
  if z = 'MAX-FORWARDS'        then MaxForwards        := s else // Section 14.31
  if z = 'PROXY-AUTHORIZATION' then ProxyAuthorization := s else // Section 14.34
  if z = 'RANGE'               then Range              := s else // Section 14.36
  if z = 'REFERER'             then Referer            := s else // Section 14.37
  if z = 'USER-AGENT'          then UserAgent          := s else // Section 14.42
  if z = 'COOKIE'              then Cookie             := s else
    Result := False
end;

procedure Add(var s, z: string; const a: string);
begin
  if z <> '' then s := s + a + ': '+z+#13#10;
end;

function TResponseHeader.OutString: string;
var
  s: string;
begin
  s := '';
  Add(s, Age,               'Age');                // Section 14.6
  Add(s, Location,          'Location');           // Section 14.30
  Add(s, ProxyAuthenticate, 'Proxy-Authenticate'); // Section 14.33
  Add(s, Public_,           'Public');             // Section 14.35
  Add(s, RetryAfter,        'Retry-After');        // Section 14.38
  Add(s, Server,            'Server');             // Section 14.39
  Add(s, Vary,              'Vary');               // Section 14.43
  Add(s, Warning,           'Warning');            // Section 14.45
  Add(s, WWWAuthenticate,   'WWW-Authenticate');   // Section 14.46
  Result := s;
end;

function TEntityHeader.OutString: string;
var
  s: string;
begin
  s := '';
  Add(s, Allow,           'Allow');             // Section 14.7
  Add(s, ContentBase,     'Content-Base');      // Section 14.11
  Add(s, ContentEncoding, 'Content-Encoding');  // Section 14.12
  Add(s, ContentLanguage, 'Content-Language');  // Section 14.13
  Add(s, ContentLength,   'Content-Length');    // Section 14.14
  Add(s, ContentLocation, 'Content-Location');  // Section 14.15
  Add(s, ContentMD5,      'Content-MD5');       // Section 14.16
  Add(s, ContentRange,    'Content-Range');     // Section 14.17
  Add(s, ContentType,     'Content-Type');      // Section 14.18
  Add(s, ETag,            'ETag');              // Section 14.20
  Add(s, Expires,         'Expires');           // Section 14.21
  Add(s, LastModified,    'Last-Modified');     // Section 14.29
  Add(s, SetCookie,       'Set-Cookie');
  Result := s;
end;

function TGeneralHeader.OutString: string;
var
  s: string;
begin
  s := '';
  Add(s, CacheControl,     'Cache-Control');     // Section 14.9
  Add(s, Connection,       'Connection');        // Section 14.10
  Add(s, Date,             'Date');              // Section 14.19
  Add(s, Pragma,           'Pragma');            // Section 14.32
  Add(s, TransferEncoding, 'Transfer-Encoding'); // Section 14.40
  Add(s, Upgrade,          'Upgrade');           // Section 14.41
  Add(s, Via,              'Via');               // Section 14.44
  Result := s;
end;

procedure TEntityHeader.CopyEntityBodyS(const S: String);
begin
  EntityLength := Length(S);
  ContentLength := IntToStr(EntityLength);
  EntityBody:= Copy(S, 1, EntityLength);
end;

function TEntityHeader.Filter(const z, s: string): Boolean;
begin
  Result := True;
  if z = 'ALLOW'            then Allow           := s else // 14.7
  if z = 'CONTENT-BASE'     then ContentBase     := s else // 14.11
  if z = 'CONTENT-ENCODING' then ContentEncoding := s else // 14.12
  if z = 'CONTENT-LANGUAGE' then ContentLanguage := s else // 14.13
  if z = 'CONTENT-LENGTH'   then ContentLength   := s else // 14.14
  if z = 'CONTENT-LOCATION' then ContentLocation := s else // 14.15
  if z = 'CONTENT-MD5'      then ContentMD5      := s else // 14.16
  if z = 'CONTENT-RANGE'    then ContentRange    := s else // 14.17
  if z = 'CONTENT-TYPE'     then ContentType     := s else // 14.18
  if z = 'ETAG'             then ETag            := s else // 14.20
  if z = 'EXPIRES'          then Expires         := s else // 14.21
  if z = 'LAST-MODIFIED'    then LastModified    := s else // 14.29
  if z = 'STATUS'           then
  CGIStatus       := s
  else
  if z = 'LOCATION'         then CGILocation     := s else
  if z = 'SET-COOKIE'       then SetCookie       := s else
    Result := False;
end;

constructor THTTPData.Create;
begin
  inherited Create;
  FRequest:= '';
  RequestGeneralHeader := TGeneralHeader.Create;
  RequestRequestHeader := TRequestHeader.Create;
  RequestEntityHeader := TEntityHeader.Create;
end;

destructor THTTPData.Destroy;
begin
  RequestGeneralHeader.Free;
  RequestRequestHeader.Free;
  RequestEntityHeader.Free;
  ResponseGeneralHeader.Free;
  ResponseResponseHeader.Free;
  ResponseEntityHeader.Free;
  inherited Destroy;
end;

end.
