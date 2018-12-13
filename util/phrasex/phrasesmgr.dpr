program phrasesmgr;

uses
  Forms,
  fmain in 'fmain.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
