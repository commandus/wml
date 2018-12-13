program radwmlas;

uses
  Forms,
  fmain in 'fmain.pas' {FormMain},
  builder in 'builder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
