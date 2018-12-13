unit FComposerTaxonAbout;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TAXComposerTaxonAbout = class(TForm)
    CtlImage: TSpeedButton;
    NameLbl: TLabel;
    OkBtn: TButton;
    CopyrightLbl: TLabel;
    DescLbl: TLabel;
  end;

procedure ShowAXComposerTaxonAbout;

implementation

{$R *.DFM}

procedure ShowAXComposerTaxonAbout;
begin
  with TAXComposerTaxonAbout.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

end.
