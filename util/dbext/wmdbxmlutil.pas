unit
  wmdbxmlutil;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  m  d  b  x  m  l  u  t  i  l                                            *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   web datamodule supplemental routines                                      *
*   Part of wdbxml project (web gateway to database)                           *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Dec 01 2002                                                 *
*   Last fix     : Dec 20 2002                                                *
*   Lines        : 164                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  SysUtils, Classes, Windows, IniFiles,
  util1, isutil1, dbxmlint;

function GetDllPath: String;

function MkW3Aliases: TStrings;

function LoadIni(const ADllPath: String): Boolean;

function GetDrvIdx(var AUrl: String): Integer;

procedure DoLog(const AMsg: String);

const
  DEF_INIFILE = 'wdbxml.ini';
  DEFLOGDLL  = 'islog.dll';         { default dll name }
  DEFLOGFUNC = 'logfunc';           { default dll function name }
  DEFLOGSTARTFUNC = 'logstartfunc'; { default start logging function name }

var
  DBXMLDLLCalls: TDBXMLDLLCallsArray;

  LogFuncs: TLogThread;

  W3Aliases: TStrings;

  useUtf8,
  // dbCodepageIsUTF8: Boolean;
  forceUseDBContent: Boolean;

implementation

const
  MAX_PATH = 511;
var
  LogStruc: TLogStruc;
  DLLPath: String;

function GetDllPath: String;
var
  FN: array[0..MAX_PATH - 1] of Char;
begin
  SetString(Result, FN, GetModuleFileName(hInstance, FN, SizeOf(FN)));
  Result:= ExtractFilePath(Result);
end;

procedure ValidateW3SvcColon(AVirtualRoots: TStrings);
var
  i, L: Integer;
  S: String;
begin
  for i:= 0 to AVirtualRoots.Count - 1 do begin
    repeat
      S:= AVirtualRoots.Names[i];
      L:= Length(S);
      if (L < 0) or (not(S[L] in [#0..#32, ',']))
      then Break;
      S:= AVirtualRoots[i];
      Delete(S, L, 1);
      AVirtualRoots[i]:= S;
    until False;
  end;
  // set default "current" directory
  if AVirtualRoots.Values[''] = ''
  then AVirtualRoots.Add('=' + DLLPath);
  // set default "root" directory
  if AVirtualRoots.Values['/'] = ''
  then AVirtualRoots.Add('/=' + DLLPath);
end;

const
  RGW2SVCALIAS = '\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots';

function MkW3Aliases: TStrings;
begin
  Result:= TStringList.Create;
  AddEntireKey(RGW2SVCALIAS, Result);
  ValidateW3SvcColon(Result);
end;

function GetDrvIdx(var AUrl: String): Integer;
var
  d, L, len, longest: Integer;
begin
  d:= Low(DBXMLDLLCalls);
  longest:= 0;
  len:= 0;
  while d <= High(DBXMLDLLCalls) do begin
    if Pos(DBXMLDLLCalls[d].FPath, AUrl) = 1 then begin
      L:= Length(DBXMLDLLCalls[d].FPath);
      if L > len then begin
        longest:= d;
        len:= L;
      end;
    end;
    Inc(d);
  end;
  Result:= Longest;
  if len > 1  // if root '/', do not delete!
  then Delete(AUrl, 1, len);
end;

{ load db drivers DLLs into DBXMLDLLCalls global variable, error list, log
}
function LoadIni(const ADllPath: String): Boolean;
var
  ini: TIniFile;
  i, p, d, L: Integer;
  LogDLL, LogFunc, LogStartFunc, LogFile: String;
  ws: WideString;
  sl, errsl: TStrings;
  url, curDLLName: String;
  cl: ShortString;
  srchWindow, srchTitle: ANSIString;
  AppHandle,
  curDLLHandle: HWND;
  // buf: array[0..260] of Char;
begin
  DLLPath:= ADllPath;

  FillChar(LogStruc, SizeOf(TLogStruc), #0);
  FillChar(LogFuncs, SizeOf(TLogThread), #0);
  sl:= TStringList.Create;

  ini:= TIniFile.Create(util1.ConcatPath(DLLPath, DEF_INIFILE, '\'));

  // create IIS alias strings
  W3Aliases:= MkW3Aliases;
  // load aliases from section
  ini.ReadSectionValues('Aliases', sl);
  d:= 0;
  while d < sl.Count do begin
    p:= Pos('=', sl[d]);
    if p < 0 then begin
      sl.Delete(d);
      Continue;
    end;
    curDLLName:= util1.ConcatPath(DLLPath, Copy(sl[d], p + 1, MaxInt), '\');
    // validate url
    url:= Copy(sl[d], 1, p - 1);
    // store validated url and full path
    W3Aliases.Values[url]:= curDLLName;
    Inc(d);
  end;
  // load db drivers
  ini.ReadSectionValues('dbDrivers', sl);
  d:= 0;
  while d < sl.Count do begin
    p:= Pos('=', sl[d]);
    if p < 0 then begin
      sl.Delete(d);
      Continue;
    end;
    curDLLName:= util1.ConcatPath(DLLPath, Copy(sl[d], p + 1, MaxInt), '\');
    // validate url
    url:= Copy(sl[d], 1, p - 1);
    L:= Length(url);
    if L > 1 then begin
      if url[L] = '/'
      then Delete(url, L, 1);
    end;
    // store validated url and full path
    sl[d]:= url + '=' + curDLLName;

    if not FileExists(curDLLName) then begin
      sl.Delete(d);
      Continue;
    end;

    // try to load dll
    SetLength(DBXMLDLLCalls, d + 1);
    curDllHandle:= dbXMLInt.LoadDBXMLDLLCalls(curDLLName, url, DBXMLDLLCalls[d]);
    if curDllHandle = 0 then begin
      SetLength(DBXMLDLLCalls, d);
      sl.Delete(d);
      Continue;
    end;
    Inc(d);
  end;

  useUtf8:= CompareText(ini.ReadString('Common', 'codepage', ''), 'utf-8') = 0;
  // dbCodepageIsUTF8:= CompareText(ini.ReadString('Common', 'dbcodepage', ''), 'utf-8') = 0;
  forceUseDBContent:= CompareText(ini.ReadString('Common', 'forceDbContent', 'n'), 'y') = 0;

  Result:= Length(DBXMLDLLCalls) > 0;
  // load reconnect database error list for each driver
  errsl:= TStringList.Create;
  for d:= Low(DBXMLDLLCalls) to High(DBXMLDLLCalls) do begin
    ini.ReadSectionValues('ReconnectError' + DBXMLDLLCalls[d].FPath, errsl);
    // remove names=
    for i:= 0 to errsl.Count - 1 do begin
      p:= Pos('=', errsl[i]);
      if p > 0 then begin
        errsl[i]:= Copy(errsl[i], p + 1, 255);
      end;
    end;

    // set reconnect error list
    ws:= errsl.CommaText;  // comma delimited text like '"SQL...",
    DBXMLDLLCalls[d].FInit(PWideChar(ws), [], Nil);
  end;

  errsl.Free;
  
  // load global variables list
  ini.ReadSectionValues('GlobalVariables', sl);

  // fix some variables: remove class, windowtitle and fix hwnd variable
  srchWindow:= sl.Values['class'];
  srchTitle:= sl.Values['windowtitle'];
  // find out hwnd
  AppHandle:= StrToIntDef(sl.Values['hwnd'], 0);
  if AppHandle <> 0 then begin
    // check is it vakid window handle
    i:= Windows.GetClassName(AppHandle, PChar(@cl[1]), 255);
    SetLength(cl, i);
    if ANSICompareText(srchWindow, cl) <> 0 then begin
      AppHandle:= 0;
    end;
  end;
  if AppHandle = 0 then begin
    if Length(srchWindow) > 0 then begin
      // StrPCopy(buf, srchWindow);
      AppHandle:= Windows.FindWindow(PChar(srchWindow), PChar(srchTitle));
      if AppHandle = 0 then
        AppHandle:= Windows.FindWindow(PChar(srchWindow), Nil);
    end else begin;
      if Length(srchTitle) > 0 then begin
        AppHandle:= Windows.FindWindow(Nil, PChar(srchTitle));
      end;
    end;
  end;
  if AppHandle <> 0 then begin
    sl.Values['hwnd']:= '$' + IntToHex(AppHandle, 8);
  end;

  // remove class, windowtitle variables
  d:= sl.IndexOfName('class');
  if d >= 0
  then sl.Delete(d);
  d:= sl.IndexOfName('windowtitle');
  if d >= 0
  then sl.Delete(d);

  // global variables list
  ws:= sl.CommaText;  // comma delimited text like '"var1=1", "v="'
// util1.String2File('b.txt', ws, True);

  for d:= Low(DBXMLDLLCalls) to High(DBXMLDLLCalls) do begin
    DBXMLDLLCalls[d].FSetGlobalVariables(PWideChar(ws));
  end;
  // start logging
  LogDLL:= ini.ReadString('Log', 'DLL', DEFLOGDLL);
  LogFUNC:= ini.ReadString('Log', 'Func', DEFLOGFUNC);
  LogStartFunc:= ini.ReadString('Log', 'StartFunc', DEFLOGSTARTFUNC);
  LogFile:= ini.ReadString('Log', 'File', '');
  if isutil1.StartLog(LogStruc, DLLPath, LogDLL, LogFunc, LogStartFunc, LogFile, @LogFuncs) then begin
    DoLog('*****');
  end else begin;
  end;

  sl.Free;
  ini.Free;
end;

procedure DoLog(const AMsg: String);
begin
  LogStruc.remoteIP:= '0.0.0.0';
  LogStruc.t0:= Now;
  LogStruc.dt:= 0.001;
  LogStruc.len:= -1;
  LogStruc.empno:= -1;
  LogStruc.lst:= Copy(AMsg, 1, 255);
  if Assigned (LogFuncs.LogFunc)
  then LogFuncs.LogFunc(LogStruc);
end;

end.
