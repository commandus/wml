program wdem;

uses
  Forms,
  fmain in 'fmain.pas' {Form1},
  xdrOpenWave in 'xdrOpenWave.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
