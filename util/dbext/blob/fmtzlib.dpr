library
  fmtzlib;
(*******************************************************************************
*                                                                             *
*   f  m  t  z  l  i  b                                                        *
*   formatting DLL for compressed zlib text in database's table               *
*   Copyright (c) 2006, Andrei Ivanov. All rights reserved.                    *
*   Part of is2sql.dll, demo DLL                                              *
*     function expand(AData, Aspecifier: PChar;                                *
*       var ABuf: PChar;  var ABufLen: Integer): Boolean;                     *
*   Usage:                                                                     *
*   $(dsRecords.ddata[expand@fmtzlib.dll?]:format)                            *
*   $(dsRecords.ddata[compress@fmtzlib.dll?[compresslevel]]:format)            *
*     where compresslevel 0 - none 1 - fast 2 - normal 3 - maximum            *
*                                                                              *
*   Created:       Feb 22 2006                                                *
*   Last Revision: Feb 22 2006                                                 *
*                                                                             *
*                                                                              *
*   Last fix     : Feb 22 2006                                                *
*   Files        : none                                                        *
*   Lines        : 110                                                        *
*   History      :                                                             *
*   Printed      : ---                                                        *
*                                                                              *
*                                                                             *
********************************************************************************)
(*##*)
{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }
{$R *.RES}
uses
  SysUtils, Classes, Registry, Windows,
  zlib;

const
  LNVERSION = '1.0';
  RGPATH = 'Software\ensen\is2sql\'+ LNVERSION;

var
  SaveExit: Pointer;
  Buffer: String;

function Decompress(var Buf: String): Boolean;
var
  zd: TDeCompressionStream;
  b: array[0..1023] of Byte;
  strmIn: TStream;
  c, len: Cardinal;
begin
  Result:= False;
  { Decompress the data }
  strmIn:= TStringStream.Create(buf);
  zd:= zlib.TDeCompressionStream.Create(strmin);

  buf:= '';
  len:= 0;
  repeat
    c:= zd.Read(b, SizeOf(b));
    if c > 0 then begin
      SetLength(buf, c + len);
      Move(b, Buf[len + 1], c);
      Inc(len, c);
    end;
    if c < SizeOf(b)
    then Break;
  until False;
  zd.Free;
  strmIn.Free;
  Result:= True;
end;

function expand(AData, Aspecifier: PChar;
  var ABuf: PChar; var ABufLen: Integer): Boolean; stdcall;
begin
  SetLength(Buffer, ABufLen);
  Move(AData^, Buffer[1], ABufLen);

  Result:= Decompress(Buffer);

  ABufLen:= Length(Buffer);
  ABuf:= PChar(Buffer);
end;

function Shrink(var Buf: String; ACompressionLevel: TCompressionLevel): Boolean;
var
  zc: TCompressionStream;
  strmIn,
  strmOut: TStream;
  c, len: Cardinal;
begin
  Result:= False;
  { Decompress the data }
  strmIn:= TStringStream.Create(buf);
  strmOut:= TStringStream.Create('');
  zc:= zlib.TCompressionStream.Create(ACompressionLevel, strmout);
  zc.CopyFrom(strmIn, strmIn.Size);
  zc.Free;
  strmIn.Free;
  Buf:= TStringStream(strmOut).DataString;
  strmOut.Free;
  Result:= True;
end;

function compress(AData, Aspecifier: PChar;
  var ABuf: PChar; var ABufLen: Integer): Boolean; stdcall;
var
  s: String;
  level: TCompressionLevel;
begin
  SetLength(Buffer, ABufLen);
  Move(AData^, Buffer[1], ABufLen);

  s:= ASpecifier;
  level:= TCompressionLevel(StrToIntDef(s, 2)); // default normal
  Result:= Shrink(Buffer, level);

  ABufLen:= Length(Buffer);
  ABuf:= PChar(Buffer);
end;

procedure LibExit;
begin
  ExitProc:= SaveExit;  // restore exit procedure chain
end;

procedure Init;
begin
  SaveExit:= ExitProc;  // save exit procedure chain
  ExitProc:= @LibExit;  // install LibExit exit procedure
end;

exports
  expand index 1 name 'expand',
  compress index 2 name 'compress ';

begin
  Init;
end.
