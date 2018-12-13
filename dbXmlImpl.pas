unit
  dbxmlimpl;
(*##*)
(*******************************************************************************
*                                                                             *
*   d  b  X  M  L  I  M  P  L                                                  *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language parser dll implementation                        *
*   Conditional defines: USE_BDE|USE_IB|USE_ADO                                *
*                                                                             *
*   Following functions implemented:                                           *
*   function SetDbXMLParseReport(AOnReport: TReportEvent): Boolean            *
*   function StartDbXMLParse(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;    *
*   AVars: PWideChar; ACookies: PWideChar;                                    *
*   AOnReport: TReportEvent; AContentPassed: TPassContentSet): LongWord        *
*                                                                             *
*   function GetInfo: PWideChar;                                               *
*   function ClearThreadCache: Boolean;                                       *
*   function GetThreadCount: Integer; func SetMinThreads()                     *
*   function SetMinThreads(AValue: Integer): Integer;                         *
*   function SetMaxThreads(AValue: Integer): Integer;                          *
*   procedure SetGlobalVariables(AValue: PWideChar);                          *
*                                                                              *
*                                                                             *
*   How to use                                                                 *
*   create and set up callback by SetDbXMLParseReport function                *
*   pass source widestring to StartDbXMLParse                                  *
*   check in callback for rlFinishThread level, get parsed text               *
*     back                                                                     *
*   Before close application call ClearThreadCache function                   *
*   You can obtain threads count by GetThreadCount                             *
*     min count of threads - SetMinThreads(0)                                 *
*     max count of threads - SetMaxThreads(0)                                  *
*                                                                             *
*   Revisions    : May 15 2002                                                 *
*   Last fix     : May 16 2002                                                *
*   Lines        : 170                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)
{ You can declare externals in DLL:
  function GetInfo: PWideChar;
  function SetDbXMLParseReport(AOnReport: TReportEvent): Boolean;
  function StartDbXMLParse(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;
    AVars: PWideChar; ACookies: PWideChar; AOnReport: TReportEvent; AContentPassed: TPassContentSet): LongWord;
  function ClearThreadCache: Boolean;
  function GetThreadCount: Integer;
  function SetMinThreads(AValue: Integer): Integer;
  function SetMaxThreads(AValue: Integer): Integer;
  procedure SetGlobalVariables(AValue: PWideChar);
}
{ please do not use directives here, use Project|Options}

interface
uses
  SysUtils,
  Versions, xmlsupported, customxml, xmlParse, dbParser,
  util1, dbxmlint;

function Init(ACriticalErrors: PWideChar; AOptions: TParsersOptionSet): Boolean; stdcall;

function Done: Boolean; stdcall;

function GetInfo: PWideChar; stdcall;

{ AOnReport must wait for rlFinishThread indicated that
  procedure (ALevel: TReportLevel; AXMLElement: TXMLElement; const ASrc: String; AWhere: TPoint; const ADesc: String; var AContinueParse: Boolean) of object;
  ALevel = rlFinishThread
  AXMLElement - XML element to parse
  In dll and host application classes are different so do not use this object

  If parse is successed:
    AWhere.x = 0
    AWhere.y = 0
    ASrc = pointer to created ucs2 text
    ADesc = ''

  In error of pool is full and no way to create new parser thread:
    AWhere.x = -1
    AWhere.y = ThreadCount (default max 32 threads)
    ADesc = '*' (check for string length)

  Notes:
    All others ALevel such rlError you can skip and contains XML errors infotmation
    If thread is stopped by host application uses thread handle, OnReport(rlFinishThread,..) is called
}
function SetDbXMLParseReport(AOnReport: TReportEvent): Boolean; stdcall;

{ Set up global variables used by DbParserThreadPoolManager
  Parameters
    AValue - comma delimited text like '"var1=1", "v="'
  Return
    none
  Note
}
procedure SetGlobalVariables(AValue: PWideChar); stdcall;

{ Parameters
    ADoc    template document type
    AXMLElementSrc pointer XML source widestring
    AVars   comma-delimited variable list. If Nil, global variables 'll be used
  Returns
    Result  Thread handle. 0 indicates error: pool is full and no way to create new parser thread
}
function StartDbXMLParse(ADoc: TEditableDoc; AxmlElementSrc: PWideChar;
  AVars: PWideChar; ACookies: PWideChar; AOnReport: TReportEvent; AContentPassed: TPassContentSet;
  AEnv: Pointer): LongWord; stdcall;

{ call ClearThreadCache before closing application
  to stop threads
  I dont know, but if you dont, threads did not resumed before their die (called from Destroy, Clear methods)
}
function ClearThreadCache: Boolean; stdcall;

{ return count of threads in memory
}
function GetThreadCount: Integer; stdcall;

{ Set up max count of threads
  Parameters
    AValue - 0 do not set up, just return count of max threads
  Return
    Result - max of threads in memory
  Note
    Default value is 32
}
function SetMaxThreads(AValue: Integer): Integer; stdcall;

{ Set up min count of threads
  Parameters
    AValue - 0 do not set up, just return count of min threads
  Return
    Result - max of threads in memory
  Note
    Default value is 1
}
function SetMinThreads(AValue: Integer): Integer; stdcall;

implementation

var
  STR_DESC: WideString = 'xml database extension parser dll (dbXML) for ' +
{$IFDEF USE_BDE}
  'BDE'
{$ENDIF}
{$IFDEF USE_IB}
  'Interbase'
{$ENDIF}
{$IFDEF USE_ADO}
  'ADO'
{$ENDIF}
{$IFDEF USE_DBE}
  'dbExpress'
{$ENDIF}
{$IFDEF USE_LDAP}
  'dbLDAP'
{$ENDIF}
 + ' version %s';

function Init(ACriticalErrors: PWideChar; AOptions: TParsersOptionSet): Boolean; stdcall;
begin
  DbParserThreadPoolManager:= TDbParserThreadPool.Create(ACriticalErrors, AOptions);
  DispatchThread:= DbParserThreadPoolManager.DispatchThread;
  Result:= True;
end;

function Done: Boolean; stdcall;
begin
  DispatchThread:= nil;
  DbParserThreadPoolManager.Free;
  Result:= True;
end;

function GetInfo: PWideChar; stdcall;
begin
  Result:= PWideChar(STR_DESC);
  // Format(STR_DESC, [Versions.GetVersionInfo(LNG, 'FileVersion')])
  // Versions.GetVersionInfo(LNG, 'ProductName') +
  // Versions.GetVersionInfo(LNG, 'LegalCopyright'));
end;

{ AOnReport must wait for rlFinishThread indicated that
  procedure (ALevel: TReportLevel; AXMLElement: TXMLElement; const ASrc: String; AWhere: TPoint; const ADesc: String; var AContinueParse: Boolean) of object;
  ALevel = rlFinishThread
  AXMLElement - XML element to parse
  In dll and host application classes are different so do not use this object

  If parse is successed:
    AWhere.x = 0
    AWhere.y = 0
    ASrc = pointer to created ucs2 text
    ADesc = ''

  In error of pool is full and no way to create new parser thread:
    AWhere.x = -1
    AWhere.y = ThreadCount (default max 32 threads)
    ADesc = '*' (check for string length)

  Notes:
    All others ALevel such rlError you can skip and contains XML errors infotmation
    If thread is stopped by host application uses thread handle, OnReport(rlFinishThread,..) is called
}
function SetDbXMLParseReport(AOnReport: TReportEvent): Boolean; stdcall;
begin
  DbParserThreadPoolManager.DefOnReport:= AOnReport;
  Result:= True;
end;

{ Parameters
    AXMLElementSrc pointer XML source widestring
    AVars   comma-delimited variable list. If Nil, global variables 'll be used
  Returns                            
    Result  Thread handle. 0 indicates error: pool is full and no way to create new parser thread
}
function StartDbXMLParse(ADoc: TEditableDoc; AxmlElementSrc: PWideChar;
  AVars: PWideChar; ACookies: PWideChar; AOnReport: TReportEvent; AContentPassed: TPassContentSet;
  AEnv: Pointer): LongWord; stdcall;
begin
  Result:= DispatchThread(ADoc, AxmlElementSrc, AVars, ACookies, AOnReport, AContentPassed, AEnv);
end;

{ call ClearThreadCache before closing application
  to stop threads
  I dont know, but if you dont, threads did not resumed before their die (called from Destroy, Clear methods)
}
function ClearThreadCache: Boolean; stdcall;
var
  cnt: Integer;
begin
  DbParserThreadPoolManager.Clear;
  cnt:= MAX_WAITLOOPS;
  repeat
    Sleep(10);
    Dec(cnt);
  until (DbParserThreadPoolManager.ThreadCount = 0) or (cnt <= 0);
  Result:= True;
end;

{ return count of threads in memory
}
function GetThreadCount: Integer; stdcall;
begin
  Result:= DbParserThreadPoolManager.ThreadCount;
end;

{ Set up max count of threads
  Parameters
    AValue - 0 do not set up, just return count of max threads
  Return
    Result - max of threads in memory
  Note
    Default value is 32
}
function SetMaxThreads(AValue: Integer): Integer; stdcall;
begin
  if AValue > 0
  then DbParserThreadPoolManager.Max:= AValue;
  Result:= DbParserThreadPoolManager.Max;
end;

{ Set up min count of threads
  Parameters
    AValue - 0 do not set up, just return count of min threads
  Return
    Result - max of threads in memory
  Note
    Default value is 1
}
function SetMinThreads(AValue: Integer): Integer; stdcall;
begin
  if AValue > 0
  then DbParserThreadPoolManager.Min:= AValue;
  Result:= DbParserThreadPoolManager.Min;
end;

{ Set up global variables used by DbParserThreadPoolManager
  Parameters
    AValue - comma delimited text like '"var1=1", "v="'
  Return
    none
  Note
}
procedure SetGlobalVariables(AValue: PWideChar); stdcall;
begin
  DbParserThreadPoolManager.GlobalVars:= AValue;
end;

begin
  STR_DESC:= SysUtils.Format(STR_DESC, [Versions.GetVersionInfo(dbParser.LNG, 'FileVersion')]);
end.
