unit pluginHTTP;

interface

uses
  Windows, Classes, SysUtils, WinSock,
  util1;

const
  ERR_TERMINATE   = 0; // ok, no faults
  ERR_WSASSTARTUP = 1; // failed to startup windows sockets
  ERR_FAILSOCKET  = 2; // failed to create the socket
  ERR_BIND        = 3; // failed to bind the socket
type
  TResetterThread = class(TThread)
    TimeToSleep,
    FResetterSleep: DWORD;
    FSocketsColl: TCollection;
    FLock: TRTLCriticalSection;
    constructor Create(ASocketsColl: TCollection);
    procedure Execute; override;
    destructor Destroy; override;
  end;

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

  // create thread
  THTTPClient = class;

  THTTPClientThread = class(TThread)
  private
    FParentHTTPClient: THTTPClient; // parent
  public
    Socket: TSocket;
    URL: String;
    Buffer: String;
    constructor Create(AHTTPServ: THTTPClient; ASocket: TSocket);
    procedure Execute; override;
    destructor Destroy; override;
  end;

  TDoLoopThread = class(TThread)
  private
    FParentHTTPClient: THTTPClient;
  public
    ServerSocketHandle: WinSock.TSocket;
    constructor Create(AParentHttpServ: THTTPClient);
    procedure Execute; override;
    destructor Destroy; override;
  end;

  // event, try to open stream
  TRequestStartEvent = procedure (Sender: TObject; const AFileName: String;
    var AHandled: Boolean) of object;

  THTTPClient = class
  private
    FLastError: Integer;
    FWSLastError: Integer;

    FSocketsColl: TCollection;
    FDoLoopThread: TDoLoopThread;
    FResetterThread: TResetterThread;

    FOnRequestStart: TRequestStartEvent;

    FBindPort: Integer;
    FBindAddr: Cardinal;

    FStarted: Boolean;
    procedure SetStarted(AStarted: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    property Started: Boolean read FStarted write SetStarted;
  published
    property OnRequestStart: TRequestStartEvent read FOnRequestStart write FOnRequestStart;
  end;

implementation

const
  SleepQuant1Min           = 1*60*1000; // 1 minute
  CHTTPServerThreadBufSize = $2000;
{--- utility ---}

function MinD(A, B: DWORD): DWORD; assembler;
asm
  cmp  eax, edx
  jb   @@b
  xchg eax, edx
@@b:
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
      if s.Dead <= KillQuants
      then Continue; // This one shows activity - let him live
      s.Dead := -1; // Mark
      shutdown(s.Handle, 2); // disables send or receive on a socket.
      // remove from collection
      FSocketsColl.Delete(s.Index);
    end;
    LeaveCriticalSection(FLock);
  until Terminated;
end;

{-- TSocket ---}

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
  i:= recv(Handle, B, Size, 0);
  if (i = SOCKET_ERROR) or (I < 0) then begin
    Status:= WSAGetLastError;
    Result:= 0
  end else Result := i;
  Dead:= 0;
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
  i:= 0;
  Left:= Size;
  while Left > 0 do begin
    WriteNow := MinD(Left, cWrite);
    cnt:= send(Handle, p^[i], WriteNow, 0);
    if (cnt = SOCKET_ERROR) or (cnt < 0) then begin
      Status:= WSAGetLastError;
      Written:= 0
    end else Written:= I;
    Dead := 0;
    Inc(i, Written);
    Dec(Left, Written);
    if Written <> WriteNow then Break;
  end;
  Result:= i;
end;

constructor THTTPClientThread.Create(AHTTPServ: THTTPClient; ASocket: TSocket);
begin
  inherited Create(True);
  Socket:= ASocket;
  FParentHTTPClient:= AHTTPServ;
end;

destructor THTTPClientThread.Destroy;
begin
  Socket.Free;
  inherited Destroy;
end;

constructor TDoLoopThread.Create(AParentHttpServ: THTTPClient);
begin
  inherited Create(False);
  FParentHTTPClient:= AParentHttpServ;
end;

destructor TDoLoopThread.Destroy;
begin
  // FParentHTTPClient.Started:= False;
  inherited Destroy;
end;

procedure TDoLoopThread.Execute;
const
  KillQuants = 5; // Quants to shut down socket for inactivity
var
  J: Integer;
  FNewSocketHandle: winsock.TSocket;
  NewSocket: TSocket;
  NewThread: THTTPClientThread;
  WData: TWSAData;
  Addr: TSockAddr;
begin
  FParentHTTPClient.FLastError:= ERR_TERMINATE;  // no error
  FParentHTTPClient.FWSLastError:= WSAStartup(MakeWord(1,1), WData); // last windows socket error
  if FParentHTTPClient.FWSLastError <> 0 then begin
    FParentHTTPClient.FLastError:= ERR_WSASSTARTUP;
    Exit;
  end;
  ServerSocketHandle:= socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

  if ServerSocketHandle = INVALID_SOCKET then begin
    FParentHTTPClient.FWSLastError:= WSAGetLastError;
    FParentHTTPClient.FLastError:= ERR_FAILSOCKET;
    Exit;
  end;
  // J:= $00010001;  setsockopt(ServerSocketHandle, SOL_SOCKET, SO_LINGER, @J, SizeOf(J));
  // J:= 1; setsockopt(ServerSocketHandle, SOL_SOCKET, SO_REUSEADDR, @J, SizeOf(J));

  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(FParentHTTPClient.FBindPort);
  Addr.sin_addr.s_addr := FParentHTTPClient.FBindAddr;
  if bind(ServerSocketHandle, Addr, SizeOf(Addr)) = SOCKET_ERROR then begin
    FParentHTTPClient.FWSLastError:= WSAGetLastError;
    FParentHTTPClient.FLastError:= ERR_BIND;
    CloseSocket(ServerSocketHandle);
    Exit;
  end;
  FParentHTTPClient.FSocketsColl:= TCollection.Create(TCollectionItem);
  FParentHTTPClient.FResetterThread:= TResetterThread.Create(FParentHTTPClient.FSocketsColl);
  FParentHTTPClient.FResetterThread.FreeOnTerminate:= True;
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
    NewSocket:= TSocket.Create(FParentHTTPClient.FSocketsColl, FParentHTTPClient.FResetterThread,
      FNewSocketHandle, Addr);
    // FParentHTTPClient.FSocketsColl.Enter;
    if FParentHTTPClient.FResetterThread.FSocketsColl.Count = 0 then begin // ?!! ---------------------------------------------------------------------------------------
      FParentHTTPClient.FResetterThread.TimeToSleep:= SleepQuant1Min;
      SetEvent(FParentHTTPClient.FResetterThread.FResetterSleep);
    end;
    // FParentHTTPClient.FSocketsColl.Leave;
    NewThread:= THTTPClientThread.Create(FParentHTTPClient, NewSocket);
    NewThread.FreeOnTerminate:= True;
    NewThread.Resume;
  until Terminated;
  CloseSocket(ServerSocketHandle);
  // WSACleanup;
end;

constructor THTTPClient.Create;
begin
  inherited;
  FOnRequestStart:= Nil;
  // server socket init failure error code or other fatal error
  FLastError:= 0;
  FWSLastError:= 0;
  // bind address
  FBindAddr:= winsock.INADDR_ANY;
  // port
  FBindPort:= 80;
  // --- Open log files and initialize semaphores
  FSocketsColl:= Nil;
  FResetterThread:= Nil;
  FDoLoopThread:= Nil;
end;

destructor THTTPClient.Destroy;
begin
  inherited;
end;

procedure THTTPClientThread.Execute;
var
  bytesread: Integer;
  AbortConnection: Boolean;
begin
  if not Assigned(Socket) then begin
    raise Exception.CreateFmt('Socket is not assigned: %d', [Integer(Socket)]);
  end;
  AbortConnection:= False;
  repeat
    if Terminated then Break;
    AbortConnection:= False;
    repeat
      SetLength(Buffer, CHTTPServerThreadBufSize);
      bytesread:= Socket.Read(Buffer[1], CHTTPServerThreadBufSize);
      if (bytesread <= 0) or (Socket.Status <> 0)
      then Break;
      SetLength(Buffer, bytesread);
    until False;
  until AbortConnection
end;

procedure THTTPClient.SetStarted(AStarted: Boolean);
var
  i: Integer;
  FStopSocketHandle: winsock.TSocket;
  Addr: TSockAddr;
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
        FLastError:= ERR_FAILSOCKET;
      end;

      Addr.sin_family:= AF_INET; //AF_UNIX
      Addr.sin_port:= htons(FBindPort);
      Addr.sin_addr.s_addr:= INADDR_LOOPBACK;

      if winsock.connect(FStopSocketHandle, Addr, Sizeof(Addr)) <> 0 then begin
        FWSLastError:= WSAGetLastError;
        FLastError:= ERR_BIND;
        CloseSocket(FStopSocketHandle);
      end;
      FDoLoopThread:= Nil;
    end;
    FStarted:= False;
  end;
end;

end.
