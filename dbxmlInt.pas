unit
  dbxmlint;
(*##*)
(*******************************************************************************
*                                                                             *
*   d  b  X  M  L  I  N  T                                                     *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language parser dll implementation                        *
*   Conditional defines: USE_BDE|USE_IB|USE_ADO|USE_LDAP                       *
*                                                                             *
*   Following functions prototypes declared:                                   *
*   function SetDbXMLParseReport(AOnReport: TReportEvent): Boolean            *
*   function StartDbXMLParse(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;    *
*     AVars: PWideChar; AOnReport: TReportEvent): LongWord                    *
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
*   check in callback for rlrlFinishThread level, get parsed text             *
*     back                                                                     *
*   Before close application call ClearThreadCache function                   *
*   You can obtain threads count by GetThreadCount                             *
*     min count of threads - SetMinThreads(0)                                 *
*     max count of threads - SetMaxThreads(0)                                  *
*                                                                             *
*   Revisions    : May 15 2002                                                 *
*   Last fix     : May 27 2002                                                *
*   Lines        : 170                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Windows, customxml, xmlsupported, xmlparse, wml;

type
  TPassContent = (pcParse, pcUrl);
  TPassContentSet = set of TPassContent;

  InitFunc = function(ACriticalErrors: PWideChar; AOptions: TParsersOptionSet;
    AEnv: Pointer): Boolean; stdcall;
  DoneFunc = function: Boolean; stdcall;                                      
  SetDbXMLParseReportFunc =  function (AOnReport: TReportEvent): Boolean; stdcall;
  // return thread handle
  StartDbXMLParseFunc =  function (ADoc: TEditableDoc; AXMLElementSrc: PWideChar;
    AVars: PWideChar; ACookies: PWideChar; AOnReport: TReportEvent; AContentPassed: TPassContentSet;
      AEnv: Pointer): LongWord; stdcall; // Apr 20 2007 AEnv: pass environment in thread
  ClearThreadCacheFunc = function : Boolean; stdcall;
  GetThreadCountFunc = function : Integer; stdcall;
  SetMinThreadsFunc = function (AValue: Integer): Integer; stdcall;
  SetMaxThreadsFunc = function (AValue: Integer): Integer; stdcall;
  SetGlobalVariablesFunc = procedure (AValue: PWideChar); stdcall;
  GetInfoFunc = function : PWideChar; stdcall;

  TDBXMLDLLCalls = record
    FHandle: THandle;
    FPath: String;
    FInit: InitFunc;
    FDone: DoneFunc;
    FSetDbXMLParseReport: SetDbXMLParseReportFunc;
    FStartDbXMLParse: StartDbXMLParseFunc;
    FClearThreadCache: ClearThreadCacheFunc;
    FGetThreadCount: GetThreadCountFunc;
    FSetMinThreads: SetMinThreadsFunc;
    FSetMaxThreads: SetMaxThreadsFunc;
    FSetGlobalVariables: SetGlobalVariablesFunc;
    FGetInfo: GetInfoFunc;
  end;

  // dynamic array of TDBXMLDLLCalls
  TDBXMLDLLCallsArray = array of TDBXMLDLLCalls;

{ load DLL by absolute or relative path, fill procedures variables
  Parameters
    AFileName -  DLL file name
  Return
    ADBXMLDLLCalls - DLL external procedure calls
    Result
      DLL handle
      0 - If DLL loading fails (external procedures missing), return 0
      ADBXMLDLLCalls set up to zero
}
function LoadDBXMLDLLCalls(AFileName: String; const APath: String; var ADBXMLDLLCalls: TDBXMLDLLCalls): THandle;

implementation

const
  InitFuncName = 'Init';
  DoneFuncName = 'Done';
  SetDbXMLParseReportFuncName = 'SetDbXMLParseReport';
  StartDbXMLParseFuncName = 'StartDbXMLParse';
  ClearThreadCacheFuncName = 'ClearThreadCache';
  GetThreadCountFuncName = 'GetThreadCount';
  SetMinThreadsFuncName = 'SetMinThreads';
  SetMaxThreadsFuncName = 'SetMaxThreads';
  SetGlobalVariablesFuncName = 'SetGlobalVariables';
  GetInfoFuncName = 'GetInfo';

{ load DLL by absolute or relative path, fill procedures variables
  Parameters
    AFileName -  DLL file name
  Return
    ADBXMLDLLCalls - DLL external procedure calls
    Result
      DLL handle
      0 - If DLL loading fails (external procedures missing), return 0
          ADBXMLDLLCalls set up to zero
}
function LoadDBXMLDLLCalls(AFileName: String; const APath: String; var ADBXMLDLLCalls: TDBXMLDLLCalls): THandle;
begin
  Result:= LoadLibrary(PChar(AFileName));
  FillChar(ADBXMLDLLCalls, SizeOf(ADBXMLDLLCalls), 0);
  if Result = 0 then begin
    Exit;
  end;
  with ADBXMLDLLCalls do begin
    FInit:= GetProcAddress(Result, InitFuncName);
    FDone:= GetProcAddress(Result, DoneFuncName);
    FSetDbXMLParseReport:= GetProcAddress(Result, SetDbXMLParseReportFuncName);
    FStartDbXMLParse:= GetProcAddress(Result, StartDbXMLParseFuncName);
    FClearThreadCache:= GetProcAddress(Result, ClearThreadCacheFuncName);
    FGetThreadCount:= GetProcAddress(Result, GetThreadCountFuncName);
    FSetMinThreads:= GetProcAddress(Result, SetMinThreadsFuncName);
    FSetMaxThreads:= GetProcAddress(Result, SetMaxThreadsFuncName);
    FSetGlobalVariables:= GetProcAddress(Result, SetGlobalVariablesFuncName);
    FGetInfo:= GetProcAddress(Result, GetInfoFuncName);
    if (
      Assigned(FInit) and
      Assigned(FDone) and
      Assigned(FSetDbXMLParseReport) and
      Assigned(FStartDbXMLParse) and
      Assigned(FClearThreadCache) and
      Assigned(FGetThreadCount) and
      Assigned(FSetMinThreads) and
      Assigned(FSetMaxThreads) and
      Assigned(FSetGlobalVariables) and  // comma delimited text like '"var1=1", "v="'
      Assigned(FGetInfo))
    then begin
    end else begin
      FreeLibrary(Result);
      Result:= 0;
    end;
    FHandle:= Result;
    FPath:= APath;
  end; { with }
end;

end.
