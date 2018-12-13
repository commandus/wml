library storefile;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes, util1;

{$R *.res}

procedure NumberedFile(const AFileName: PChar); stdcall;
var
  p, e: String;
  o: Integer;
  s: String;
begin
  // rename file
  e:= '.xml';
  p:= ExtractFilePath(AFileName);
  o:= StrToIntDef('$' + util1.File2String(ConcatPath(p, 'nums.tmp' ,'\')), 1);
  s:= util1.File2String(AFileName);
  util1.String2File(ConcatPath(p, '' + IntToHex(o, 4) + '.xml', '\'), s);
  util1.String2File(ConcatPath(p, 'nums.tmp', '\'), IntToHex(o + 1, 4), True);
end;

exports
  NumberedFile name 'numberedfile';

begin
end.
