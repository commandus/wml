program phrasex;
{$APPTYPE CONSOLE}
{ TODO -oUser -cConsole Main : Insert code here }
uses
  SysUtils,
  phrasex_util;

var
  o: Text;
begin
  AssignFile(o, '');
  Rewrite(o);
  Writeln(MSG_COPYRIGHT);
  DoCmd;
  CloseFile(o);
end.
