unit dm;
(*##*)
(*******************************************************************************
*                                                                             *
*   d  m                                                                       *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*   wml editor data module                                                    *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Aug 15 2001, Oct 11 2001                                    *
*   Last revision: Mar 29 2002                                                *
*   Lines        : 85                                                          *
*   History      : see todo file                                              *
*                                                                              *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, SysUtils, Classes, Dialogs, ImgList, Controls, DdeMan, ExtDlgs, Graphics,
  ActiveX, wbmpExtDlg, wmleditutil, utilHttp, wbmpImage,
{$IFNDEF NO_FTP}
  WinInet,
{$ENDIF}
{$IFNDEF NO_LDAP}
  WinLDAP, { LinLdap, }
{$ENDIF}
  util1, IdExplicitTLSClientServerBase,
  rtcShellHelper, rtcFolderTree;

type
  Tdm1 = class(TDataModule)
    OpenDialog1: TOpenDialog;
    ImageListMenu: TImageList;
    ImageList24: TImageList;
    ImageList16: TImageList;
    FontDialog1: TFontDialog;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FOSVersionInfo: Windows.TOSVersionInfo;
    FInetRoot: HINTERNET;
    FInetConnect: HINTERNET;

    FProxyHost,
    FProxyUserName,
    FProxyPassword: String;
    FProxyPort: Integer;
    FProxyType: Integer;

    procedure Connect(AProtocol: Integer; const AHost: String; APort: Integer; AUserName, APassword: String);
    procedure Disconnect();
  public
    { Public declarations }
    WOpenPictureDialog0: TWOpenPictureDialog;
    WSavePictureDialog0: TWSavePictureDialog;
    procedure edOnListStorageSites(AFolderType: TFolderType; ASiteList: TStrings);
    procedure edOnStorageFolderList(ASender: TObject; AFolderType: TFolderType; const AURL: String; AFolderList: TStrings);
{$IFNDEF NO_FTP}
    function OnGetStorageFile(AFolderType: TFolderType; const AURL: String): String;
    function OnPutStorageFile(AFolderType: TFolderType; const AURL, AData: String): Integer;
    procedure SetStorageProxy(AFolderType: TFolderType; const AProxyUrl: String);
    function GetStorageProxy(AFolderType: TFolderType): String;
{$ENDIF}
    property OSVersionInfo: TOSVersionInfo read FOSVersionInfo;
    property ProxyHost: String read FProxyHost write FProxyHost;
    property ProxyUserName: String read FProxyUserName write FProxyUserName;
    property ProxyPassword: String read FProxyPassword write FProxyPassword;
    property ProxyPort: Integer read FProxyPort write FProxyPort;
    property ProxyType: Integer read FProxyType write FProxyType;
  end;

var
  dm1: Tdm1;

implementation

{$R *.dfm}

uses
  urlFuncs, EMemos,
  fDockBase, fExtStorageList, fFtpProxySettings;

const
  ERR_INET_OPEN = 'Can not open Internet connection';
  ERR_INET_CONNECT = 'Can not establish Internet connection';
  ERR_WRITE_INET = 'Error writing data';

{$IFNDEF NO_LDAP}
type
  ELDAP = class(Exception);
  pCharArray = array of PChar;

procedure LDAPError(const S: string);
begin
  raise ELDAP.Create(S);
end;

procedure LDAPCheck(err: ULONG);
begin
  if (err <> LDAP_SUCCESS) then
    LDAPError(ldap_err2string(err));
end;

function GetLDAPScopeIdx(const AScope: String): Integer;
begin
  Result:= LDAP_SCOPE_BASE;
  if Length(AScope) > 0 then begin
    case Upcase(AScope[1]) of
      'O': Result:= LDAP_SCOPE_ONELEVEL;
      'S': Result:= LDAP_SCOPE_SUBTREE;
    end;
  end;
end;

function GetLDAPEmptyStrAsNil(const AStr: String): PChar;
begin
  if Length(AStr) > 0
  then Result:= PChar(AStr)
  else Result:= Nil;
end;

function GetLDAPPPChar(var AStr: String; const ADelimiter: Char): PPChar;
var
  n: Pointer;
  i, c, l, ofs: Integer;
begin
  if Length(AStr) = 0 then begin
    Result:= Nil;
    Exit;
  end;

  // if last is not terminated, count them
  l:= Length(AStr);
  if AStr[l] <> ADelimiter then begin
    AStr:= AStr + #0;
    c:= 1;
    Inc(l);
  end else c:= 0;
  // replace delimiter to PChar terminator
  for i:= 1 to l do begin
    if AStr[i] = ADelimiter then begin
      AStr[i]:= #0;
      Inc(c);
    end;
  end;
  // make room in AStr
  ofs:= SizeOf(Pointer) * (c + 1);
  SetLength(AStr, l + ofs); // + Nil ptr
  Move(AStr[1], AStr[1 + ofs], l);
  FillChar(AStr[1], ofs, #0);

  c:= 0;
  // fill pointers to (except last nil)
  n:= Pointer(Integer(@(AStr[1])) + ofs);
  for i:= 1 to l do begin
    if AStr[i + ofs] = #0 then begin
      Move(n, AStr[1 + c * SizeOf(Pointer)], SizeOf(Pointer));
      n:= Pointer(Integer(@(AStr[1])) + ofs + i);  // next to #0
      Inc(c);
    end;
  end;
  Result:= @(AStr[1]);
end;
{$ENDIF}

procedure Tdm1.DataModuleCreate(Sender: TObject);
var
  bmp: TBitmap;
begin
  FInetRoot:= Nil;
  FInetConnect:= Nil;
  FProxyHost:= '';
  FProxyUserName:= '';
  FProxyPassword:= '';
  FProxyPort:= 0;
  FProxyType:= 0;

  FOSVersionInfo.dwOSVersionInfoSize:= SizeOf(FOSVersionInfo);
  GetVersionEx(FOSVersionInfo);

  WOpenPictureDialog0:= wbmpExtDlg.TWOpenPictureDialog.Create(Self);
  WSavePictureDialog0:= wbmpExtDlg.TWSavePictureDialog.Create(Self);
  ImageList16.Clear;
  bmp:= TBitmap.Create;

  if not utilHttp.LoadGIF2Bitmap(wmleditutil.RESDLLNAME, 'buttons16', bmp) then begin
    MessageDlg(Format('button 16 resource library %s not found.', [wmleditutil.RESDLLNAME]),
      mtError, [mbCancel], 0);
    Exit;
  end;
  ImageList16.AddMasked(bmp, clOlive);


  if FOSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then begin
    ImageList24.Width:= 16;
    ImageList24.Height:= 16;
  end else begin
    {
    ImageList24.Width:= 24;
    ImageList24.Height:= 24;
    }
    if not utilHttp.LoadGIF2Bitmap(wmleditutil.RESDLLNAME, 'buttons24', bmp) then begin
      MessageDlg(Format('button 24 resource library %s not found.', [wmleditutil.RESDLLNAME]),
        mtError, [mbCancel], 0);
      Exit;
    end;
  end;
  ImageList24.AddMasked(bmp, clOlive);

  if not utilHttp.LoadGIF2Bitmap(wmleditutil.RESDLLNAME, 'buttonsmenu', bmp) then begin
    MessageDlg(Format('button menu resource library %s not found.', [wmleditutil.RESDLLNAME]),
      mtError, [mbCancel], 0);
    Exit;
  end;
  ImageListMenu.AddMasked(bmp, clFuchsia);  // clFuchsia

  bmp.Free;
end;

procedure Tdm1.DataModuleDestroy(Sender: TObject);
begin
  WSavePictureDialog0.Free;
  WOpenPictureDialog0.Free;
  Disconnect;
end;

{$IFNDEF NO_FTP}
procedure Tdm1.edOnListStorageSites(AFolderType: TFolderType; ASiteList: TStrings);
var
  i: Integer;
  prefix: String;
begin
  LoadSiteList(HKEY_CURRENT_USER, RGPath + RG_EXTERNALSTORAGE_SITES, ASiteList);
  i:= 0;
  case AFolderType of
{$IFNDEF NO_FTP}
    ftFTPList: prefix:= '=ftp://';
{$ENDIF}
{$IFNDEF NO_LDAP}
    ftLDAPList: prefix:= '=ldap://';
{$ENDIF}
    else Exit;
  end;

  while i < ASiteList.Count do begin
    if Pos(prefix, ASiteList[i]) > 0
    then Inc(i)
    else ASiteList.Delete(i);  // delete non-ftp items
  end;
  // ASiteList.Add('sample ftp=ftp://localhost:21/');
end;

procedure Tdm1.Connect(AProtocol: Integer; const AHost: String; APort: Integer; AUserName, APassword: String);
var
  AccessType: Integer;
  UserAgent: String;
  Host, UserName, Password: PChar;
  proxybypass: PChar;
  proxy: PChar;
  p: String;
begin
  UserAgent:= 'apoo editor 1.99';
  // no proxy by default
  AccessType:= INTERNET_OPEN_TYPE_PRECONFIG;
  proxybypass:= Nil;
  proxy:= Nil;
  if FProxyType <> 0 then begin
    p:= '';
    case AProtocol of
      INTERNET_SERVICE_FTP: p:= 'ftp=ftp://';
      INTERNET_SERVICE_HTTP: p:= 'http=http://';
    end;
    proxy:= PChar(FProxyHost + ':' + IntToStr(FProxyPort));
    AccessType:= INTERNET_OPEN_TYPE_PROXY;
  end;

  if Length(AHost) = 0
  then Host:= Nil
  else Host:= PChar(AHost);

  if Length(AUserName) = 0
  then UserName:= Nil
  else UserName:= PChar(AUserName);

  if Length(APassword) = 0
  then Password:= Nil
  else Password:= PChar(APassword);

  // Also, could switch to new API introduced in IE4/Preview2
  if InternetAttemptConnect(0) <> ERROR_SUCCESS then
    SysUtils.Abort;

  FInetRoot:= InternetOpen(PChar(UserAgent), AccessType, Proxy, ProxyByPass, 0);
  if (not Assigned(FInetRoot)) then
    raise Exception.Create(ERR_INET_OPEN);
  FInetConnect:= InternetConnect(FInetRoot, PChar(Host), APort, UserName,
    Password, AProtocol, 0, Cardinal(Self));
  if not Assigned(FInetConnect) then begin
    Disconnect;
    raise Exception.Create(ERR_INET_CONNECT);
  end;  
end;

procedure Tdm1.Disconnect;
begin
  if Assigned(FInetConnect) then
    InternetCloseHandle(FInetConnect);
  FInetConnect:= nil;
  if Assigned(FInetRoot) then
    InternetCloseHandle(FInetRoot);
  FInetRoot:= nil;
end;

procedure Tdm1.edOnStorageFolderList(ASender: TObject; AFolderType: TFolderType; const AURL: String; AFolderList: TStrings);
const
  MASK = '';
var
  p: TObject;
  // ftp address
  protocol, host, user, password, IPaddress, fn, bookmark: String;
  port: Integer;
  flags, ctx: Cardinal;
  fd: WIN32_FIND_DATA;
  h: HINTERNET;
  protname: String;
  // ldap
{$IFNDEF NO_FTP}
  userdn, baseDN, attrs, scope, filter: String;
  scopeIdx: Integer;
  pfilter, puserdn, ppwd: PChar;
  pattrs: PPChar;
  plmSearch, plmEntry: PLDAPMessage;
  pld: Pldap;
  pDN: PChar;
{$ENDIF}
begin
  AFolderList.Clear;
  case AFolderType of
    ftFTPNode: begin
      if not urlFuncs.ParseFtpUrl(AURL, protocol, user, password, host, IPaddress, fn, bookmark, port, 'ftp', 21)
      then Exit;
      protname:= 'ftp';
    end;
    ftLDAPNode: begin
{$IFNDEF NO_LDAP}
      if not ParseldapUrl(AURL, protocol, userdn, password, host, baseDN, attrs, scope, filter, port, 'ldap', 21)
      then Exit;
      protname:= 'ldap';
{$ENDIF}
    end;
  end;
  // check protocol name
  if CompareText(protname, protocol) <> 0 then Exit;

  case AFolderType of
    ftFTPNode: begin
      try
        Connect(INTERNET_SERVICE_FTP, host, port, user, password);
        FtpSetCurrentDirectory(FInetConnect, PChar(fn));

        flags:= 0;
        ctx:= 0;
        FillChar(fd, SizeOf(fd), 0);
        fd.dwFileAttributes:= FILE_ATTRIBUTE_ARCHIVE or // The file or directory is an archive file or directory. Applications use this attribute to mark files for backup or removal.
          FILE_ATTRIBUTE_COMPRESSED or // The file or directory is compressed. For a file, this means that all of the data in the file is compressed. For a directory, this means that compression is the default for newly created files and subdirectories.
          FILE_ATTRIBUTE_DIRECTORY or // The handle identifies a directory.
          // FILE_ATTRIBUTE_ENCRYPTED or // The file or directory is encrypted. For a file, this means that all data in the file is encrypted. For a directory, this means that encryption is the default for newly created files and subdirectories.
          FILE_ATTRIBUTE_HIDDEN or // The file or directory is hidden. It is not included in an ordinary directory listing.
          FILE_ATTRIBUTE_NORMAL or // The file or directory has no other attributes set. This attribute is valid only if used alone.
          FILE_ATTRIBUTE_OFFLINE or // The file data is not immediately available. This attribute indicates that the file data has been physically moved to offline storage. This attribute is used by Remote Storage, the hierarchical storage management software. Applications should not arbitrarily change this attribute.
          FILE_ATTRIBUTE_READONLY or // The file or directory is read-only. Applications can read the file but cannot write to it or delete it. In the case of a directory, applications cannot delete it.
          // FILE_ATTRIBUTE_REPARSE_POINT or // The file or directory has an associated reparse point.
          // FILE_ATTRIBUTE_SPARSE_FILE  or //The file is a sparse file.
          FILE_ATTRIBUTE_SYSTEM or // The file or directory is part of the operating system or is used exclusively by the operating system.
          FILE_ATTRIBUTE_TEMPORARY;
        h:= FtpFindFirstFile(FInetConnect, MASK, fd, flags, ctx);
        if Assigned(h) then begin
          repeat
            if (fd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0
            then Integer(p):= 1
            else Integer(p):= 0;
            AFolderList.AddObject(fd.cFileName, p);
          until not InternetFindNextFile(h, @fd);
        end;
      finally
        Disconnect;
      end;
    end;
    ftLDAPNode: begin
      scopeIdx:= GetLDAPScopeIdx(scope);
      puserdn:= GetLDAPEmptyStrAsNil(userdn);
      ppwd:= GetLDAPEmptyStrAsNil(password);
      pfilter:= GetLDAPEmptyStrAsNil(filter);
      pattrs:= GetLDAPPPChar(attrs, ',');

      // open connection
      pld:= ldap_open(PChar(host), port);
      if not Assigned(pld)
      then Exit;
      // authenticate
      LDAPCheck(ldap_simple_bind_s(pld, puserdn, ppwd));

      // perform search
      plmSearch:= Nil;
      LDAPCheck(ldap_search_s(pld, PChar(baseDN), scopeIdx, pfilter, PChar(pattrs), 0, plmSearch));
      try
        // initialize results
        // ...
        // loop thru entries
        plmEntry:= ldap_first_entry(pld, plmSearch);
        while Assigned(plmEntry) do begin
          pDN:= ldap_get_dn(pld, plmEntry);
          if False
          then Integer(p):= 0
          else Integer(p):= 1;  // directory
          AFolderList.AddObject(pDN, p);
          plmEntry:= ldap_next_entry(pld, plmEntry);
          // FreeMem(pDN);
        end;
      finally
        // free search results
        LDAPCheck(ldap_msgfree(plmSearch));
      end;
      // close connection
      LDAPCheck(ldap_unbind_s(pld));

    end;
  end;
end;

function Tdm1.OnGetStorageFile(AFolderType: TFolderType; const AURL: String): String;
var
  // ftp address
  protocol, host, user, password, IPaddress, fn, bookmark: String;
  port: Integer;
  Strm: TStream;
  f: HINTERNET;
  b: Byte;
  bytes: Cardinal;
  // ldap
  userdn, baseDN, attrs, scope, filter: String;
  i, scopeIdx: Integer;
  plmSearch, plmEntry: PLDAPMessage;
  pld: Pldap;
  pbe: PBerElement;
  atrvalues: String;
  pAttr, pfilter, puserdn, ppwd: PChar;
  pattrs, ppVals: PPChar;

begin
  Result:= '';
  case AFolderType of
    ftFTPNode: begin
      if not ParseFtpUrl(AURL, protocol, user, password, host, IPaddress, fn, bookmark, port, 'ftp', 21)
      then Exit;
      if CompareText('ftp', protocol) = 0 then begin
      end else Exit;
      Strm:= TStringStream.Create('');

      Connect(INTERNET_SERVICE_FTP, host, port, user, password);
      f:= FtpOpenFile(FInetConnect, PChar(fn), GENERIC_READ, FTP_TRANSFER_TYPE_UNKNOWN, 0);
      if Assigned(f) then begin
        while InternetReadFile(f, @b, 1, bytes) and (bytes > 0) do begin
          Strm.Write(b, 1);
        end;
        InternetCloseHandle(f);
      end;
      Disconnect;
      Result:= TStringStream(Strm).DataString;
      Strm.Free;
    end;
    ftLDAPNode: begin
      Result:= '';
      if not ParseldapUrl(AURL, protocol, userdn, password, host, baseDN, attrs, scope, filter, port, 'ldap', 21)
      then Exit;
      if CompareText('ldap', protocol) <> 0
      then Exit;
      scopeIdx:= 0; // 'base' instead of GetLDAPScopeIdx(scope);
      puserdn:= GetLDAPEmptyStrAsNil(userdn);
      ppwd:= GetLDAPEmptyStrAsNil(password);
      pfilter:= GetLDAPEmptyStrAsNil(filter);
      pattrs:= GetLDAPPPChar(attrs, ',');
      try
        // open connection
        pld:= ldap_open(PChar(host), port);
        if not Assigned(pld)
        then Exit;
        // authenticate
        LDAPCheck(ldap_simple_bind_s(pld, puserdn, ppwd));
        // perform search
        LDAPCheck(ldap_search_s(pld, PChar(baseDN), scopeIdx, pfilter, PChar(pattrs), 0, plmSearch));
        plmEntry:= ldap_first_entry(pld, plmSearch);
        if Assigned(plmEntry) then begin
          pAttr:= ldap_first_attribute(pld, plmEntry, pbe);
          while Assigned(pAttr) do begin
            // get value buffer
            ppVals:= ldap_get_values(pld, plmEntry, pAttr);
            if Assigned(ppVals) then begin
              try
                i:= 0;
                atrvalues:= '';
                while Assigned(pCharArray(ppVals)[I]) do begin
                  atrvalues:= atrvalues + pCharArray(ppVals)[I] + ',';
                  Inc(i);
                end;
                i:= Length(atrvalues);
                if i > 0
                then Delete(atrvalues, i, 1);  // delete last ',' char
              finally
                LDAPCheck(ldap_value_free(ppVals));  // free up attribute values
              end;
            end;
            Result:= Result + atrvalues;
            pAttr:= ldap_next_attribute(pld, plmEntry, pbe);
          end;
          // free search results
          LDAPCheck(ldap_msgfree(plmSearch));
        end;
        // close connection
        LDAPCheck(ldap_unbind_s(pld));
      finally
      end;

    end;
  end;
end;

function Tdm1.OnPutStorageFile(AFolderType: TFolderType; const AURL, AData: String): Integer;
var
  // ftp address
  protocol, host, user, password, IPaddress, fn, bookmark: String;
  port: Integer;
  Strm: TStream;
  f: HINTERNET;
  bytes: Cardinal;
  // ldap
  userdn, pwd, baseDN, attrs, scope, filter: String;
  i, scopeIdx: Integer;
  plmSearch, plmEntry: PLDAPMessage;
  pld: Pldap;
  pbe: PBerElement;
  atrvalues: String;
  pAttr, pfilter, puserdn, ppwd: PChar;
  pattrs, ppVals: PPChar;
begin
  Result:= -1;
  case AFolderType of
    ftFTPNode: begin
      if not ParseFtpUrl(AURL, protocol, user, password, host, IPaddress, fn, bookmark, port, 'ftp', 21)
      then Exit;
      if CompareText('ftp', protocol) = 0 then begin
      end else Exit;

      Strm:= TStringStream.Create(AData);
      Strm.Position:= 0;

      Connect(INTERNET_SERVICE_FTP, host, port, user, password);
      f:= FtpOpenFile(FInetConnect, PChar(fn), GENERIC_WRITE, FTP_TRANSFER_TYPE_BINARY, 0);
      if Assigned(f) then begin
        if (not InternetWriteFile(f, @AData[1], Length(AData), bytes)) or (bytes = 0) then begin
          raise Exception.Create(ERR_WRITE_INET);
        end;
        InternetCloseHandle(f);
      end;
      Disconnect;
      Strm.Free;
    end;
    ftLdapNode: begin
      if not ParseldapUrl(AURL, protocol, userdn, pwd, host, baseDN, attrs, scope, filter, port, 'ldap', 21)
      then Exit;
      if CompareText('ldap', protocol) <> 0
      then Exit;
      scopeIdx:= 0; // 'base' instead of GetLDAPScopeIdx(scope);
      puserdn:= GetLDAPEmptyStrAsNil(userdn);
      ppwd:= GetLDAPEmptyStrAsNil(pwd);
      pfilter:= GetLDAPEmptyStrAsNil(filter);
      pattrs:= GetLDAPPPChar(attrs, ',');
      try
        // open connection
        pld:= ldap_open(PChar(host), port);
        if not Assigned(pld)
        then Exit;
        // authenticate
        LDAPCheck(ldap_simple_bind_s(pld, puserdn, ppwd));
        // perform search
        LDAPCheck(ldap_search_s(pld, PChar(baseDN), scopeIdx, pfilter, PChar(pattrs), 0, plmSearch));
        plmEntry:= ldap_first_entry(pld, plmSearch);
        if Assigned(plmEntry) then begin
          pAttr:= ldap_first_attribute(pld, plmEntry, pbe);
          while Assigned(pAttr) do begin
            // get value buffer
            ppVals:= ldap_get_values(pld, plmEntry, pAttr);
            if Assigned(ppVals) then begin
              try
                i:= 0;
                atrvalues:= '';
                while Assigned(pCharArray(ppVals)[I]) do begin
                  atrvalues:= atrvalues + pCharArray(ppVals)[I] + ',';
                  Inc(i);
                end;
                i:= Length(atrvalues);
                if i > 0
                then Delete(atrvalues, i, 1);  // delete last ',' char
              finally
                LDAPCheck(ldap_value_free(ppVals));  // free up attribute values
              end;
            end;
            Result:= Length(AData);
            // .. add here if more than 1 attribute - what to do
            // just first attribute to replace
            Break;
            pAttr:= ldap_next_attribute(pld, plmEntry, pbe);
          end;
          // free search results
          LDAPCheck(ldap_msgfree(plmSearch));
        end;
        // close connection
        LDAPCheck(ldap_unbind_s(pld));
      finally
      end;

    end;
  end;
end;

function Tdm1.GetStorageProxy(AFolderType: TFolderType): String;
begin
  case AFolderType of
    ftFTPNode: begin
      Result:= fFtpProxySettings.ComposeProxyString('ftp proxy', FProxyHost,
        FProxyUserName, FProxyPassword, FProxyPort, FProxyType);
    end;
    ftHTTPNode: begin
      Result:= '';
    end;
    ftLDAPNode: begin
      Result:= '';
    end;
  end;
end;

procedure Tdm1.SetStorageProxy(AFolderType: TFolderType; const AProxyUrl: String);
var
  fDesc: String;
begin
  case AFolderType of
    ftFTPNode: begin
      if fFtpProxySettings.DecomposeProxyString(AProxyUrl, fDesc, FProxyHost,
        FProxyUserName, FProxyPassword, FProxyPort, FProxyType) then;
    end;
    ftHTTPNode: begin
    end;
    ftLDAPNode: begin
    end;
  end;
end;
{$ENDIF}

end.
