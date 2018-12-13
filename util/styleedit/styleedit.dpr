program styleedit;

{%ToDo 'styleedit.todo'}

uses
  Forms,
  fmain in 'fmain.pas' {FormMain},
  fSource in 'fSource.pas' {FormSource};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormSource, FormSource);
  Application.Run;
end.
