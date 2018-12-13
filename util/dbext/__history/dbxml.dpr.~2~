library
  dbxml;
(*##*)
(*******************************************************************************
*                                                                             *
*   d  b  X  M  L                                                              *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language (wml), xhtml, oeb parser dll                     *
*   Conditional defines: USE_BDE|USE_DBE|USE_IB|USE_ADO|USE_LDAP               *
*                                                                             *
*   Declared externals:                                                        *
*   function SetDbXMLParseReport(AOnReport: TReportEvent): Boolean            *
*   function StartDbXMLParse(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;    *
*     AVars: PWideChar; AOnReport: TReportEvent): LongWord                    *
*   function GetInfo: PWideChar;                                               *
*   function ClearThreadCache: Boolean;                                       *
*   function GetThreadCount: Integer; func SetMinThreads()                     *
*   function SetMinThreads(AValue: Integer): Integer;                         *
*   function SetMaxThreads(AValue: Integer): Integer;                          *
*   procedure SetGlobalVariables(AValue: PWideChar);                          *
*   Note:                                                                      *
*     PostMessage() is called in SPC.DLL.Specify  _wm variable in .ini file   *
*     default $0401                                                            *
*                                                                             *
*   How to use                                                                 *
*   create and set up callback by SetDbXMLParseReport function                *
*   pass source widestring to StartDbXMLParse                                  *
*   check in callback for rlFinishThread level, get parsed text               *
*     back                                                                     *
*   Before close application you can call ClearThreadCache function           *
*   You can obtain threads count by GetThreadCount                             *
*     min count of threads - SetMinThreads(0)                                 *
*     max count of threads - SetMaxThreads(0)                                  *
*   Conditional defines:                                                      *
*     USE_IB;GENXML;GENWML;GENXHTML;GENOEB;GENHHC;GENAPP;                      *
*                                                                             *
*   Revisions    : May 15 2002                                                 *
*   Last fix     : May 16 2002                                                *
*   Lines        : 170                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)
{ Externals declared:
  function GetInfo: PWideChar;
  function SetDbXMLParseReport(AOnReport: TReportEvent): Boolean;
  function StartDbXMLParse(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;
    AVars: PWideChar; AOnReport: TReportEvent): LongWord;
  function ClearThreadCache: Boolean;
  function GetThreadCount: Integer;
  function SetMinThreads(AValue: Integer): Integer;
  function SetMaxThreads(AValue: Integer): Integer;
  procedure SetGlobalVariables(AValue: PWideChar);  // comma delimited text
  procedure SetCriticalErrorList(AValue: PWideChar);
}
{ please do not use directives here, use Project|Options}
 {%ToDo 'dbxml.todo'}
{$IFNDEF USE_BDE}
{$IFNDEF USE_IB}
{$IFNDEF USE_ADO}
{$IFNDEF USE_DBE}
{$IFNDEF USE_LDAP}
Select menu Project|Options|Directories/Conditionals|Conditional defines,
define USE_BDE, USE_IB, USE_ADO, USE_DBE, USE_LDAP
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}

{$IFDEF USE_BDE}
{$LIBSUFFIX 'bde'}
{$ENDIF}
{$IFDEF USE_DBE}
{$LIBSUFFIX 'dbe'}
{$ENDIF}
{$IFDEF USE_IB}
{$LIBSUFFIX 'ib'}

{$ENDIF}
{$IFDEF USE_ADO}
{$LIBSUFFIX 'ado'}
{$ENDIF}
{$IFDEF USE_LDAP}
{$LIBSUFFIX 'ldap'}
{$ENDIF}

uses
  SysUtils,
  Classes,
  dbXmlImpl;

{$R *.res}

var
  SaveExit: Pointer;

{ library exit code }
procedure LibExit;
begin
  // clear cache before
  // ClearThreadCache;
  // restore exit procedure chain
  ExitProc:= SaveExit;
end;

procedure DLLExitProc(Reason: Integer); register; export;
begin
//  if Reason = Windows.DLL_PROCESS_DETACH then ClearThreadCache;
end;

exports
  Init name 'Init',
  Done name 'Done',
  GetInfo name 'GetInfo',
  StartDbXMLParse name 'StartDbXMLParse',
  SetDbXMLParseReport name 'SetDbXMLParseReport',
  ClearThreadCache name 'ClearThreadCache',
  GetThreadCount name 'GetThreadCount',
  SetMinThreads name 'SetMinThreads',
  SetMaxThreads name 'SetMaxThreads',
  SetGlobalVariables name 'SetGlobalVariables';

begin
  // save exit procedure chain
  // SaveExit:= ExitProc;
  // install LibExit exit procedure
  // ExitProc:= @LibExit;
end.
