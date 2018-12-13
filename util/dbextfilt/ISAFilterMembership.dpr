library ISAFilterMembership;
{$R *.res}
uses
  Windows, SysUtils, IniFiles, Isapi2;

procedure Log(const Message: String; NewLogFile: Boolean = False);
const
  LogFileName = 'c:\member42.log';
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
end;

function GetFilterVersion(var Ver: THTTP_FILTER_VERSION): BOOL; stdcall;
begin
  Ver.lpszFilterDesc := 'Delphi 6.02 ISAPI Membership Login Filter';
  Ver.dwFilterVersion := MakeLong(HSE_VERSION_MINOR, HSE_VERSION_MAJOR);
  Ver.dwFlags := SF_NOTIFY_NONSECURE_PORT or SF_NOTIFY_SECURE_PORT or
                 SF_NOTIFY_ORDER_DEFAULT or
                 SF_NOTIFY_AUTHENTICATION or
                 SF_NOTIFY_ACCESS_DENIED;
  Log(Ver.lpszFilterDesc+' Loaded',True);
  Result := True // Continue to Load Filter
end;

function HttpFilterProc(var pfc: THTTP_FILTER_CONTEXT;
  NotificationType: DWORD; pvNotification: pointer): DWORD; stdcall;
const
  MemberUserName = 'member';
  MemberPassword = 'geheim';
var
  Authentication: PHTTP_FILTER_AUTHENT;
  UserName: String;
  Password: String;

  function GetServerVariable(const Variable: PChar): String;
  var
    MaxLen: Cardinal;
  begin
    MaxLen := 255;
    SetLength(Result,MaxLen);
    if pfc.GetServerVariable(pfc, Variable, PChar(Result), MaxLen) then
      SetLength(Result,StrLen(PChar(Result)))
    else
      Result := ''
  end {GetServerVariable};

  function GetUserNamePassword(const UserName: String): String;
  const
    PasswdFileName = 'c:\passwd.ini';
  begin
    with TIniFile.Create(PasswdFileName) do
    try
      Result := ReadString(UserName,'password','')
    finally
      Free
    end
  end {GetUserNamePassword};

  procedure ShowAccessDenied;
  const
    ErrorHeader: PChar = '401 Access Denied'#13#10'content-type: text/html';
    Error: PChar = '<h1>Access Denied!</h1>' +
      '<hr>Sorry, this area is only available to members!';
  var
    Size: Cardinal;
  begin
    Size := Length(ErrorHeader);
    pfc.ServerSupportFunction(pfc, SF_REQ_SEND_RESPONSE_HEADER, ErrorHeader, 0, Size);
    Size := Length(Error);
    pfc.WriteClient(pfc, Error, Size, 0)
  end {AccessDenied};

begin
  Result := SF_STATUS_REQ_NEXT_NOTIFICATION; // Notify next Filter
  if NotificationType = SF_NOTIFY_AUTHENTICATION then
  begin
    Authentication := PHTTP_FILTER_AUTHENT(pvNotification);
    UserName := Authentication.pszUser;
    if UserName <> '' then
    begin
      Password := Authentication.pszPassword;
      if (Password <> '') and (Password = GetUserNamePassword(UserName)) then
      begin
        Log('Member login ' + UserName +
            ' at ' + GetServerVariable('REMOTE_ADDR') +
            ' using ' + GetServerVariable('HTTP_USER_AGENT'));
        strcopy(Authentication.pszUser,MemberUserName);
        strcopy(Authentication.pszPassword,MemberPassword);
//      Authentication.cbPasswordBuff := strlen(Authentication.pszPassword);
      end
      else
        strcopy(Authentication.pszUser,'');
//    Authentication.cbUserBuff := strlen(Authentication.pszUser);
      Result := SF_STATUS_REQ_HANDLED_NOTIFICATION
    end
  end
  else
    if NotificationType = SF_NOTIFY_ACCESS_DENIED then
    begin
      Log('Access Denied of ' + GetServerVariable('REMOTE_ADDR') +
          ' using ' + GetServerVariable('HTTP_USER_AGENT'));
      ShowAccessDenied;
      Result := SF_STATUS_REQ_FINISHED
    end
end;

exports
  GetFilterVersion,
  HttpFilterProc;

begin
  IsMultiThread := True
end.

