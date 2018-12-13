program
  apooed;
{%ToDo 'apooed.todo'}
(*##*)
(*******************************************************************************
*                                                                             *
*   a  p  o  o  e  d                                                           *
*                                                                             *
*   Old name: wmledit3                                                         *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language, xhtml, oeb, smit, taxon editor                  *
*   Conditional defines: XML_IDX                                               *
*                                                                             *
*                                                                              *
*                                                                             *
*                                                                              *
*   Last revision: Jul 06 2001, Sep 27 2001, Nov 28 2001, Apr 29 2002         *
*                  Nov 25 2003                                                 *
*                                                                             *
*   Lines        : 98                                                          *
*   Project size :                                                            *
*   History      :                                                             *
*                                                                             *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

uses
  SysUtils,
  Classes,
  Forms,
  fSplash,
  fDockBase,
  dm in 'dm.pas' {dm1: TDataModule},
  util_dom in 'util_dom.pas',
  EMemoUndoRedo in 'EMemoUndoRedo.pas';

{$R *.RES}

type
  TStartOptions = (soNoSplash);
  TStartOptionset = set of TStartOptions;

var
  StartOptions: TStartOptionset = [];

// parse command line option
procedure ParseCommandLineOptions(const AOption: String);
begin
  if CompareText(AOption, 'NOSPLASH') = 0 then begin
    Include(StartOptions, soNoSplash);
  end;
end;

procedure ParseCommandLine;
var
  s: String;
  p: Integer;
begin
  // parse command line
  HaveFolder:= 0;
  FileList2Open.Clear;
  for p:= 1 to ParamCount do begin
    s:= ParamStr(p);
    if (Length(s) <= 0)
    then Continue;
    if (s[1] in ['-', '/', '\']) then begin
      // parse options
      Delete(s, 1, 1);
      ParseCommandLineOptions(s);
      Continue;
    end;
    if FileExists(s) or DirectoryExists(s)
    then FileList2Open.Add(s);
  end;
end;

begin
  FileList2Open:= TStringList.Create;
  ParseCommandLine;
{$IFDEF NOSPLASH}
  FormSplash:= Nil;
{$ELSE}
  if not (soNoSplash in StartOptions) then begin
    FormSplash:= TFormSplash.Create(Application);
    FormSplash.Show;
    FormSplash.Update;
  end else begin
  end;
{$ENDIF}
  Application.Initialize;
  // create data module first
  Application.Title := 'apoo editor';
  Application.CreateForm(Tdm1, dm1);
  Application.CreateForm(TFormDockBase, FormDockBase);
  Application.Run;
  FileList2Open.Free;
end.
