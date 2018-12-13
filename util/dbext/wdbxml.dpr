library
  wdbxml;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  d  b  x  m  l                                                           *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   ISAPI module gateway to the db drivers dbxml                              *
*                                                                              *
*   To create ISAPI filter, use wmdbxmlutil's global variables to keep        *
*     driver's array (load by LoadIni()) and then make calls of them           *
*     dbxmlint.TDBXMLDLLCalls declares calls                                  *
*   Note:                                                                      *
*     PostMessage() is called in SPC.DLL.Specify  _wm variable in .ini file   *                                                                           *
*     default $0401                                                            *
*                                                                             *
*   Conditional defines:                                                       *
*     USE_IB;GENXML;GENWML;GENXHTML;GENOEB;GENHHC;GENAPP;                     *
*   Revisions    : Dec 01 2002                                                 *
*   Last fix     : Dec 20 2002                                                *
*   Lines        : 283                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

uses
  SysUtils, WebBroker, ISAPIThreadPool, ISAPIApp, Windows,
  util1, isutil1, dbxmlInt, wmdbxmlutil,
  wmdbxml in 'wmdbxml.pas' {WebModule1: TWebModule};

{$R *.RES}

var
  SaveExit: Pointer;

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

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  // save exit procedure chain
  SaveExit:= ExitProc;
  // install LibExit exit procedure
  ExitProc:= @LibExit;

  Application.Initialize;
  SetLength(DBXMLDLLCalls, 0);
  // load db drivers DLLs into wmdbxmlutil.DBXMLDLLCalls, error list, log
  if LoadIni(GetDLLPath) then begin
    // wmdbxml.WebModule1.RecreateActions;
    DoLog(SysUtils.Format('Initialization file read from %s', [GetDLLPath]));
  end else DoLog(SysUtils.Format('Error read initialization file from %s', [GetDLLPath]));
  Application.CreateForm(TWebModule1, WebModule1); 
  Application.Run;
end.
